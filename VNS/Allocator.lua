-- Allocator -----------------------------------------
------------------------------------------------------

local Arrangement = require("Arrangement")

local Allocator = {}

--[[
--	related data
--	vns.allocator.target
--	vns.allocator.robotAllocated
--	vns.allocator.gene
--	vns.childrenRT[xxid].allocated
--]]

function Allocator.create(vns)
	vns.allocator = {}
	vns.allocator.robotAllocated = {}
end

function Allocator.reset(vns)
	vns.allocator = {}
	vns.allocator.robotAllocated = {}
end

function Allocator.addParent(vns)
	vns.Allocator.setMorphology(vns, nil)
end

function Allocator.deleteParent(vns)
	vns.Allocator.setMorphology(vns, vns.allocator.gene)
end

function Allocator.deleteChild(vns, idS)
	vns.allocator.robotAllocated[idS] = nil
	if vns.allocator.target ~= nil and 
	   vns.allocator.target.children ~= nil then
		for i, branchR in ipairs(vns.allocator.target.children) do
			if branchR.allocated == idS then
				branchR.allocated = nil
			end
		end
	end
end

function Allocator.setGene(vns, morph)
	if morph.robotTypeS ~= vns.robotTypeS then morph = {robotTypeS = vns.robotTypeS} end
	Allocator.calcMorphScale(vns, morph)
	vns.allocator.gene = morph
	vns.Allocator.setMorphology(vns, morph)
end

function Allocator.setMorphology(vns, morph)
	vns.allocator.target = morph
end

function Allocator.step(vns)
	-- receive branch
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "branch")) do
		Allocator.setMorphology(vns, msgM.dataT.target)
	end end

	-- check target
	if vns.parentR ~= nil and vns.allocator.target == nil then
		vns.Msg.send(vns.parentR.idS, "lostbranch")
	end
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "lostbranch")) do
		if vns.childrenRT[msgM.fromS] ~= nil then
			vns.childrenRT[msgM.fromS].lastSendBranch = nil
		end
	end

	-- calculate requiring for each branch
	if vns.allocator.target ~= nil then
		local target = vns.allocator.target
		if vns.parentR ~= nil then
			target.parentRequiring = target.parentScale - vns.parentR.scale
		end
		if target.children ~= nil then for i, branch in ipairs(target.children) do
			--branch.requiring = branch.scale
			if vns.childrenRT[branch.allocated] == nil then
				--[[
				branch.requiring = vns.ScaleManager.Scale:new()
				branch.requiring[branch.robotTypeS] = 1
				--]]
				branch.requiring = branch.scale
			else
				branch.requiring = branch.scale - vns.childrenRT[branch.allocated].scale
			end
		end end
	end

	Allocator.allocate(vns, "drone", irequire)
	Allocator.allocate(vns, "pipuck", irequire)
end

function Allocator.allocate(vns, allocating_type)
	-- allocate
	-- create childrenList
	local childrenList = {}
	local i = 0
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.robotTypeS == allocating_type then
			i = i + 1
			childrenList[i] = {
				positionV3 = robotR.positionV3,
				index = idS,
			}
		end
		---[[
		if vns.allocator.robotAllocated[idS] ~= nil and 
		   vns.allocator.robotAllocated[idS].requiring[allocating_type] ~= nil and
		   vns.allocator.robotAllocated[idS].requiring[allocating_type] < 0 then
			for j = 1, -vns.allocator.robotAllocated[idS].requiring[allocating_type] do
				i = i + 1
				childrenList[i] = {
					positionV3 = robotR.positionV3,
					index = nil,
				}
			end
		end
		--]]
	end

	if #childrenList == 0 then return end

	-- create positionList
		-- positions to children
	local positionList = {}
	local i = 0
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for j, branchR in pairs(vns.allocator.target.children) do
			if branchR.robotTypeS == allocating_type then
				local thisPosition = {
					positionV3 = branchR.positionV3,
					index = branchR,
				}
				if branchR.allocated ~= nil then
					i = i + 1
					positionList[i] = thisPosition
				end
				---[[
				if branchR.requiring[allocating_type] ~= nil and
			   	   branchR.requiring[allocating_type] > 0 then
					i = i + 1
					positionList[i] = thisPosition
				end
				--]]
			else
				if branchR.allocated ~= nil and
				   branchR.requiring[allocating_type] ~= nil and
				   branchR.requiring[allocating_type] > 0 then
					i = i + 1
					positionList[i] = {
						positionV3 = branchR.positionV3,
						index = vns.childrenRT[branchR.allocated] or branchR,
					}
				elseif branchR.allocated == nil and
				   branchR.requiring[allocating_type] ~= nil and
				   branchR.requiring[allocating_type] > 0 then
					i = i + 1
					positionList[i] = {
						positionV3 = branchR.positionV3,
						index = {positionV3 = branchR.positionV3, orientationQ = quaternion(), requiring = vns.ScaleManager.Scale:new()},
					}
				end
			end
		end
	end

		-- positions to parent
	local parentPosition = {positionV3 = vector3()}

	local moreChildren = #childrenList - #positionList
	for j = 1, moreChildren do
		i = i + 1
		if vns.parentR ~= nil then
			positionList[i] = {
				positionV3 = vns.parentR.positionV3,
				index = vns.parentR,
			}
		else
			positionList[i] = {
				positionV3 = vector3(),
				index = {positionV3 = vector3(), orientationQ = quaternion(), requiring = vns.ScaleManager.Scale:new()},
			}
		end
	end

	local costMatrix = {}
	for i = 1, #childrenList do
		costMatrix[i] = {}
		for j = 1, #positionList do
			if positionList[j].idS ~= nil and positionList[j].idS == childrenList[i].idS then
				costMatrix[i][j] = 999999999999999
			else
				local positionA = vector3(childrenList[i].positionV3)
				local positionB = vector3(positionList[j].positionV3)
				positionA.z = 0
				positionB.z = 0
				costMatrix[i][j] = (positionA - positionB):length()
			end
		end
	end

	DMSG(robot.id, "costMatrix")
	DMSG(costMatrix)

	DMSG(robot.id, allocating_type)
	DMSG("childrenList")
	DMSG(childrenList)
	DMSG("positionList")
	DMSG(positionList)


	local index = {}
	for i = 1, #positionList do index[i] = i end

	local arranger = Arrangement:newArranger(index)
	local miniresult = nil
	local minivalue = 999999999

	local result = arranger()
	while result ~= nil do
		local maxlength = 0
		for i = 1, #childrenList do
			if costMatrix[i][result[i]] > maxlength then
				maxlength = costMatrix[i][result[i]]
			end
		end
		if maxlength < minivalue then
			minivalue = maxlength
			miniresult = result
		end
		result = arranger()
	end

	-- find the farthest robot for the same position
	for i = 1, #positionList do
		positionList[i].allocated = nil
		positionList[i].allocatedcost = 0
		--positionList[i].allocatedcost = 9999999999999
	end
	for i = 1, #childrenList do
		local cost = (positionList[miniresult[i]].positionV3 * 0.5 - childrenList[i].positionV3):length()
		if costMatrix[i][miniresult[i]] > positionList[miniresult[i]].allocatedcost and
		--if cost < positionList[miniresult[i]].allocatedcost and
		   childrenList[i].index ~= nil then
			positionList[miniresult[i]].allocatedcost = costMatrix[i][miniresult[i]]
			positionList[miniresult[i]].allocated = childrenList[i]
		end
	end
	for i = 1, #childrenList do
		if positionList[miniresult[i]].allocated ~= childrenList[i] and
		   childrenList[i].index ~= nil then
			positionList[miniresult[i]] = {
				positionV3 = positionList[miniresult[i]].allocated.positionV3,
				index = positionList[miniresult[i]].allocated.index,
			}
			if positionList[miniresult[i]].index ~= nil then
				positionList[miniresult[i]].index = vns.childrenRT[positionList[miniresult[i]].index]
			end
		end
	end
	for i = 1, #positionList do
		positionList[i].allocated = nil
		positionList[i].allocatedcost = nil
	end
	for i = 1, #childrenList do
		childrenList[i].allocated = nil
	end

	DMSG(robot.id, "miniresult")
	DMSG(miniresult)

	for idS, branch in pairs(vns.allocator.robotAllocated) do
		if vns.childrenRT[idS] ~= nil and vns.childrenRT[idS].robotTypeS == allocating_type then
			vns.allocator.robotAllocated[idS] = nil
		end
	end
	if vns.allocator.target ~= nil and
	   vns.allocator.target.children ~= nil then
		for i, branch in ipairs(vns.allocator.target.children) do
			if branch.robotTypeS == allocating_type then
				branch.allocated = nil
			end
		end
	end

	-- allocate based on result
	for i = 1, #childrenList do
		if childrenList[i].index ~= nil then
			local child = vns.childrenRT[childrenList[i].index]
			if positionList[ miniresult[i] ].index.idS == nil then
				vns.allocator.robotAllocated[child.idS] = positionList[ miniresult[i] ].index
				positionList[ miniresult[i] ].index.allocated = child.idS
				if child.lastSendBranch ~= positionList[ miniresult[i] ].index then
					vns.Msg.send(child.idS, "branch", {target = positionList[ miniresult[i] ].index})
					child.lastSendBranch = positionList[ miniresult[i] ].index
				end
				child.goalPoint = {
					positionV3 = positionList[ miniresult[i] ].index.positionV3,
					orientationQ = positionList[ miniresult[i] ].index.orientationQ,
				}
				if child.assignTargetS ~= nil then
					vns.Assigner.assign(vns, child.idS, nil)
					vns.Msg.send(child.idS, "branch", {target = nil})
				end
			else
				vns.Assigner.assign(vns, child.idS, positionList[ miniresult[i] ].index.idS)
				vns.Msg.send(child.idS, "branch", {target = nil})
			end
		end
	end

	if vns.allocator.target ~= nil and
	   vns.allocator.target.children ~= nil then
		for i, branch in ipairs(vns.allocator.target.children) do
			print(i, branch.allocated)
		end
	end
	for idS, _ in pairs(vns.allocator.robotAllocated) do
		print(idS)
	end
end

function Allocator.calcMorphScale(vns, morph)
	Allocator.calcMorphChildrenScale(vns, morph)
	Allocator.calcMorphParentScale(vns, morph)
end

function Allocator.calcMorphChildrenScale(vns, morph)
	local sum = vns.ScaleManager.Scale:new()
	if morph.children ~= nil then
		for i, branch in ipairs(morph.children) do
			sum = sum + Allocator.calcMorphChildrenScale(vns, branch)
		end
	end
	if sum[morph.robotTypeS] == nil then
		sum[morph.robotTypeS] = 1
	else
		sum[morph.robotTypeS] = sum[morph.robotTypeS] + 1
	end
	morph.scale = sum
	return sum
end

function Allocator.calcMorphParentScale(vns, morph)
	if morph.parentScale == nil then
		morph.parentScale = vns.ScaleManager.Scale:new()
	end
	local sum = morph.parentScale + morph.scale
	if morph.children ~= nil then
		for i, branch in ipairs(morph.children) do
			branch.parentScale = sum - branch.scale
		end
		for i, branch in ipairs(morph.children) do
			Allocator.calcMorphParentScale(vns, branch)
		end
	end
end

function Allocator.create_allocator_node(vns)
	return function()
		Allocator.step(vns)
	end
end

return Allocator

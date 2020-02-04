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

	if vns.allocator.target ~= nil then
		local target = vns.allocator.target
		if vns.parentR ~= nil then
			target.parentRequiring = target.parentScale - vns.parentR.scale
		end
		if target.children ~= nil then for i, branch in ipairs(target.children) do
			--branch.requiring = branch.scale
			if branch.allocated == nil then
				branch.requiring = vns.ScaleManager.Scale:new()
				branch.requiring[branch.robotTypeS] = 1
			else
				branch.requiring = branch.scale - branch.allocated.scale
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
			childrenList[i] = robotR
			if vns.allocator.robotAllocated[idS] ~= nil and 
			   vns.allocator.robotAllocated[idS].requiring[allocating_type] ~= nil and
			   vns.allocator.robotAllocated[idS].requiring[allocating_type] < 0 then
				for j = 1, -vns.allocator.robotAllocated[idS].requiring[allocating_type] do
					i = i + 1
					childrenList[i] = robotR
				end
			end
		end
	end

	if #childrenList == 0 then return end

	-- create positionList
		-- target children
	local positionList = {}
	local i = 0
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for j, branchR in pairs(vns.allocator.target.children) do
			if branchR.allocated ~= nil and branchR.robotTypeS == allocating_type then
				i = i + 1
				positionList[i] = branchR
			end
			if branchR.requiring[allocating_type] ~= nil and
			   branchR.requiring[allocating_type] > 0 then
				i = i + 1
				if branchR.robotTypeS == allocating_type then
					positionList[i] = branchR
				else
					positionList[i] = branchR.allocated
				end
			end
		end
	end

	local parentPosition
	if vns.parentR ~= nil then
		parentPosition = vns.parentR
	else
		parentPosition = {positionV3 = vector3(), orientationQ = quaternion()}
	end

	local moreChildren = #childrenList - #positionList
	for j = 1, moreChildren do
		i = i + 1
		positionList[i] = parentPosition
	end

	local costMatrix = {}
	for i = 1, #childrenList do
		costMatrix[i] = {}
		for j = 1, #positionList do
			if positionList[j].idS ~= nil and positionList[j].idS == childrenList[i].idS then
				costMatrix[i][j] = 999999999999999
			else
				costMatrix[i][j] = (childrenList[i].positionV3 - positionList[j].positionV3):length()
			end
		end
	end

	DMSG(robot.id, "costMatrix")
	DMSG(costMatrix)

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

	-- allocate based on result
	-- find the farthest robot for the same position
	for i = 1, #positionList do
		positionList[i].allocated = nil
		positionList[i].allocatedcost = 0
	end
	for i = 1, #childrenList do
		if costMatrix[i][miniresult[i]] > positionList[miniresult[i]].allocatedcost then
			positionList[miniresult[i]].allocatedcost = costMatrix[i][miniresult[i]]
			positionList[miniresult[i]].allocated = childrenList[i]
		end
	end
	for i = 1, #childrenList do
		if positionList[miniresult[i]].allocated ~= childrenList[i] then
			positionList[miniresult[i]] = positionList[miniresult[i]].allocated
		end
	end
	for i = 1, #positionList do
		positionList[i].allocated = nil
		positionList[i].allocatedcost = nil
	end
	for i = 1, #childrenList do
		childrenList[i].allocated = nil
	end

	DMSG(robot.id, allocating_type)
	DMSG("childrenList")
	DMSG(childrenList, 1, "lastSendBranch")
	DMSG("positionList")
	DMSG(positionList, 1, "allocated")

	DMSG(robot.id, "miniresult")
	DMSG(miniresult)

	for i = 1, #childrenList do
		if positionList[ miniresult[i] ].idS == nil then
			if childrenList[i].lastSendBranch ~= positionList[ miniresult[i] ] then
				vns.Msg.send(childrenList[i].idS, "branch", {target = positionList[ miniresult[i] ]})
				childrenList[i].lastSendBranch = positionList[ miniresult[i] ]
			end
			vns.allocator.robotAllocated[childrenList[i].idS] = positionList[ miniresult[i] ]
			positionList[ miniresult[i] ].allocated = childrenList[i]
			childrenList[i].goalPoint = {
				positionV3 = positionList[ miniresult[i] ].positionV3,
				orientationQ = positionList[ miniresult[i] ].orientationQ,
			}
			if childrenList[i].assignTargetS ~= nil then
				vns.Assigner.assign(vns, childrenList[i].idS, nil)
				vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
			end
		else
			vns.Assigner.assign(vns, childrenList[i].idS, positionList[ miniresult[i] ].idS)
			vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
		end
	end

	--[[
	for i = 1, #childrenList do
		DMSG(robot.id, "i = ", i)
		DMSG(robot.id, "positionList")

		if miniresult == nil then
			if vns.parentR ~= nil then
				vns.Assigner.assign(vns, childrenList[i].idS, vns.parentR.idS)
				vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
			else
				vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
				childrenList[i].allocated = nil
				childrenList[i].goalPoint = {
					positionV3 = vector3(),
					orientationQ = quaternion(), 
				}
			end
		elseif positionList[miniresult[i] ].idS == nil then
			vns.Msg.send(childrenList[i].idS, "branch", {target = positionList[miniresult[i] ]})
			childrenList[i].allocated = positionList[miniresult[i] ]
			childrenList[i].goalPoint = {
				positionV3 = positionList[miniresult[i] ].positionV3,
				orientationQ = positionList[miniresult[i] ].orientationQ,
			}
			if childrenList[i].assignTargetS ~= nil then
				vns.Assigner.assign(vns, childrenList[i].idS, nil)
				vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
			end
		else
			vns.Assigner.assign(vns, childrenList[i].idS, positionList[miniresult[i] ].idS)
			vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
		end
	end
	--]]
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

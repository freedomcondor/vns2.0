-- Allocator -----------------------------------------
------------------------------------------------------

local Arrangement = require("Arrangement")

local Allocator = {}

--[[
--	related data
--	vns.allocator.target
--	vns.allocator.gene
--	vns.allocator.lastRequire
--	vns.childrenRT[xxid].allocated
--	vns.childrenRT[xxid].requiring
--]]

function Allocator.create(vns)
	vns.allocator = {}
end

function Allocator.reset(vns)
end

function Allocator.addParent(vns)
	vns.Allocator.setMorphology(vns, nil)
end

function Allocator.deleteParent(vns)
	vns.Allocator.setMorphology(vns, vns.allocator.gene)
end

function Allocator.setGene(vns, morph)
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

	-- what I still need
	local irequire = ineed - ihave
	DMSG("irequire")
	DMSG(irequire)
	DMSG("vns.allocator.lastRequire")
	DMSG(vns.allocator.lastRequire)
	DMSG(irequire == vns.allocator.lastRequire)
	if irequire == vns.allocator.lastRequire then
	else
		if vns.parentR ~= nil then
			vns.Msg.send(vns.parentR.idS, "need", {need = irequire})
			vns.allocator.lastRequire = irequire
		end
	end

	vns.ineed = ineed
	vns.ihave = ihave
	vns.irequire = irequire
	Allocator.allocate(vns, "drone", irequire)
	Allocator.allocate(vns, "pipuck", irequire)
end

function Allocator.allocate(vns, allocating_type, irequire)
	-- allocate
	-- create childrenList
	local childrenList = {}
	local i = 0
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.robotTypeS == allocating_type then
			i = i + 1
			childrenList[i] = robotR
		end
	end

	if #childrenList == 0 then return end

	-- create positionList
		-- target children
	local positionList = {}
	local i = 0
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for idS, robotR in pairs(vns.allocator.target.children) do
			if robotR.robotTypeS == allocating_type then
				i = i + 1
				positionList[i] = robotR
			end
		end
	end
		-- require positions
	if #positionList < #childrenList then
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.requiring ~= nil and robotR.requiring[allocating_type] ~= nil then
			for j = 1, robotR.requiring[allocating_type] do
				i = i + 1
				positionList[i] = robotR
			end
		end
	end end

	if irequire[allocating_type] ~= nil and irequire[allocating_type] < 0 then
		for j = 1, -irequire[allocating_type] do
			i = i + 1
			if vns.parentR ~= nil then
				positionList[i] = vns.parentR
			else
				positionList[i] = {positionV3 = vector3(), orientationQ = quaternion()}
			end
		end
	end

	if #positionList == 0 then return end

	DMSG(robot.id, allocating_type)
	DMSG("childrenList")
	DMSG(childrenList)
	DMSG("positionList")
	DMSG(positionList)

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

	DMSG(robot.id, "miniresult")
	DMSG(miniresult)

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
		elseif positionList[miniresult[i]].idS == nil then
			vns.Msg.send(childrenList[i].idS, "branch", {target = positionList[miniresult[i]]})
			childrenList[i].allocated = positionList[miniresult[i]]
			childrenList[i].goalPoint = {
				positionV3 = positionList[miniresult[i]].positionV3,
				orientationQ = positionList[miniresult[i]].orientationQ,
			}
			if childrenList[i].assignTargetS ~= nil then
				vns.Assigner.assign(vns, childrenList[i].idS, nil)
				vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
			end
		else
			vns.Assigner.assign(vns, childrenList[i].idS, positionList[miniresult[i]].idS)
			vns.Msg.send(childrenList[i].idS, "branch", {target = nil})
		end
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

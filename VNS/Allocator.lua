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

------------------------------------------------
local Need = {}
Need.__index = Need

function Need:new(table)
	local instance = {}
	setmetatable(instance, self)
	if table == nil then return instance end
	for i, v in pairs(table) do
		instance[i] = v
	end
	return instance
end

function Need.__add(A, B)
	local C = Need:new(A)
	if B == nil then return C end
	for i, v in pairs(B) do
		if C[i] == nil then 
			C[i] = v
		else
			C[i] = C[i] + v
		end
	end
	return C
end

function Need.__sub(A, B)
	local C = Need:new(A)
	if B == nil then return C end
	for i, v in pairs(B) do
		if C[i] == nil then 
			C[i] = -v
		else
			C[i] = C[i] - v
		end
	end
	return C
end

function Need.__equal(A, B)
	for i, v in pairs(A) do
		if A[i] ~= B[i] then return false end
	end
	for i, v in pairs(B) do
		if A[i] ~= B[i] then return false end
	end
	return true
end
------------------------------------------------

function Allocator.create(vns)
	vns.allocator = {}
	vns.allocator.lastRequire = Need:new()
end

function Allocator.reset(vns)
	vns.allocator.lastRequire = Need:new()
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.requiring = nil
		robotR.allocated = nil
	end
end

function Allocator.addParent(vns)
	vns.Allocator.setMorphology(vns, nil)
	vns.allocator.lastRequire = Need:new()
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.requiring = nil
		robotR.allocated = nil
	end
end

function Allocator.deleteParent(vns)
	vns.Allocator.setMorphology(vns, vns.allocator.gene)
	vns.allocator.lastRequire = Need:new()
end

function Allocator.setGene(vns, morph)
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

	-- receive need
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "need")) do
		local fromR
		if vns.parentR ~= nil and vns.parentR.idS == msgM.fromS then fromR = vns.parentR end
		if vns.childrenRT[msgM.fromS] ~= nil then fromR = vns.childrenRT[msgM.fromS] end
		if fromR ~= nil then fromR.requiring = Need:new(msgM.dataT.need) end
	end

	-- what I need on my end
	local ineed = Need:new()
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
	for idS, robotR in pairs(vns.allocator.target.children) do
		if ineed[robotR.robotTypeS] == nil then ineed[robotR.robotTypeS] = 0 end
		ineed[robotR.robotTypeS] = ineed[robotR.robotTypeS] + 1
	end end

	-- what I need from my children
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.requiring ~= nil then
			ineed = ineed + robotR.requiring
		end
	end

	-- what I have
	local ihave = Need:new()
	for idS, robotR in pairs(vns.childrenRT) do
		if ihave[robotR.robotTypeS] == nil then ihave[robotR.robotTypeS] = 0 end
		ihave[robotR.robotTypeS] = ihave[robotR.robotTypeS] + 1
	end

	-- what I still need
	local irequire = ineed - ihave
	if irequire ~= vns.allocator.lastRequire then
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

	DMSG("costMatrix")
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

	for i = 1, #childrenList do
		if positionList[miniresult[i]].idS == nil then
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

function Allocator.create_allocator_node(vns)
	return function()
		Allocator.step(vns)
	end
end

return Allocator

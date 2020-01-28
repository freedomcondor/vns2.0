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
	if table == nil then return instance end
	for i, v in pairs(table) do
		instance[i] = v
	end
	return instance
end

function Need:add(A, B)
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

function Allocator.setGene(vns, morph)
	vns.allocator.gene = morph
	vns.Allocator.setMorphology(vns, morph)
end

function Allocator.setMorphology(vns, morph)
	vns.allocator.target = morph
end

function Allocator.step(vns)
	-- about branch
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentS, "branch")) do
		self:setStructure(vns, vns.Msg.recoverTable(msgM.dataT.structure))
	end end

	-- allocate
	local childrenList = {}
	local i = 0
	for idS, robotR in pairs(vns.childrenRT) do
		i = i + 1
		childrenList[i] = robotR
	end

	local positionList = {}
	local i = 0
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for idS, robotR in pairs(vns.allocator.target.children) do
			i = i + 1
			positionList[i] = robotR
		end
	end

	local costMatrix = {}
	for i = 1, #childrenList do
		costMatrix[i] = {}
		for j = 1, #positionList do
			costMatrix[i][j] = (childrenList[i].positionV3 - positionList[j].positionV3):length()
		end
	end

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
		vns.Msg.send(childrenList[i].idS, "branch", {target = positionList[miniresult[i]]})
		childrenList[i].goalPoint = {
			positionV3 = positionList[miniresult[i]].positionV3,
			orientationQ = positionList[miniresult[i]].orientationQ,
		}
	end
end

function Allocator.create_allocator_node(vns)
	return function()
		Allocator.step(vns)
	end
end

return Allocator

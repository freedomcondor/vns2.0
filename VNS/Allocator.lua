-- Allocator -----------------------------------------
------------------------------------------------------
DMSG.register("Allocator")
--local Arrangement = require("Arrangement")
local MinCostFlowNetwork = require("MinCostFlowNetwork")

local Allocator = {}

--[[
--	related data
--	vns.allocator.target
--	vns.allocator.gene
--]]

function Allocator.create(vns)
	vns.allocator = {}
end

function Allocator.reset(vns)
	vns.allocator = {}
	vns.allocator.change = 0
end

function Allocator.addChild(vns)
	vns.allocator.change = 0
end

function Allocator.deleteChild(vns)
	vns.allocator.change = 0
end

function Allocator.addParent(vns)
	vns.Allocator.setMorphology(vns, nil)
	vns.allocator.change = 0
end

function Allocator.deleteParent(vns)
	vns.Allocator.setMorphology(vns, vns.allocator.gene)
	vns.allocator.change = 0
end

function Allocator.setGene(vns, morph)
	--if morph.robotTypeS ~= vns.robotTypeS then morph = {robotTypeS = vns.robotTypeS} end
	if morph.robotTypeS ~= vns.robotTypeS then morph = nil return end
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
		vns.allocator.change = 0
	end end

	if vns.allocator.change <= 0 then
		Allocator.exe_allocate(vns)
		vns.allocator.change = 10
	else
		vns.allocator.change = vns.allocator.change - 1
	end

	-- send cmd to children
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.allocate ~= nil then -- skip non-allocated children (this may happen if a child is newly recruited and haven't reported its scale)

		if robotR.allocate.idS == nil then
			-- it is a branch, send branch and disassign
			if robotR.robotTypeS == robotR.allocate.robotTypeS then
				vns.Msg.send(robotR.idS, "branch", {target = robotR.allocate})
			else
				vns.Msg.send(robotR.idS, "branch", {target = nil})
			end
			robotR.goalPoint = {
				positionV3 = robotR.allocate.positionV3,
				orientationQ = robotR.allocate.orientationQ,
			}
			---[[
			if vns.goalPoint ~= nil then
				robotR.goalPoint.positionV3 = vector3(robotR.goalPoint.positionV3):rotate(vns.goalPoint.orientationQ) +
				                              vns.goalPoint.positionV3
				robotR.goalPoint.orientationQ = robotR.goalPoint.orientationQ * vns.goalPoint.orientationQ
			end
			--]]
			if robotR.assignTargetS ~= nil then
				vns.Assigner.assign(vns, robotR.idS, nil)
			end
		else
			-- it is a robot, assign
			vns.Assigner.assign(vns, robotR.idS, robotR.allocate.idS)
			vns.Msg.send(robotR.idS, "branch", {target = nil})
		end
	end end
end

function Allocator.exe_allocate(vns)
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.allocate = nil
	end

	Allocator.allocate(vns, "drone")
	Allocator.allocate(vns, "pipuck")
	Allocator.allocate(vns, "builderbot")

	-- now every children has a allocate
	-- for each branch, 
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for index, branchR in ipairs(vns.allocator.target.children) do
			-- find the farthest same type child allocated to it
			--local dis = 0
			local dis = math.huge
			local theChild = nil
			for idS, robotR in pairs(vns.childrenRT) do
				if robotR.allocate == branchR and
				   robotR.robotTypeS == branchR.robotTypeS then
					--local relativeVector = robotR.positionV3 - branchR.positionV3
					--local relativeVector = vector3(robotR.positionV3 - branchR.positionV3 * 0.5)
					local relativeVector = vector3(robotR.positionV3)
					relativeVector.y = relativeVector.y / 3 -- TODO
					relativeVector.z = 0
					--if relativeVector:length() > dis then
					if relativeVector:length() < dis then
						dis = relativeVector:length()
						theChild = robotR
					end
				end
			end

			if theChild ~= nil then
				-- assign other children (all type) to this farthest child
				for idS, robotR in pairs(vns.childrenRT) do
					if robotR.allocate == branchR then
						--if robotR ~= theChild then
						if robotR.idS ~= theChild.idS then
							robotR.allocate = theChild
						end
					end
				end
			end
		end
	end
end

function Allocator.allocate(vns, allocating_type)
	-- create sources from children
	local i = 0
	local sourceSum = 0
	local sourceList = {}
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.scale[allocating_type] ~= nil and robotR.scale[allocating_type] ~= 0 then
			i = i + 1
			sourceList[i] = {
				number = robotR.scale[allocating_type],
				index = robotR,
			}
			sourceSum = sourceSum + robotR.scale[allocating_type]
		end
	end
	if vns.parentR ~= nil and vns.allocator.target ~= nil then
		local parentHas = vns.parentR.scale - vns.allocator.target.parentScale
		if parentHas[allocating_type] ~= nil and
		   parentHas[allocating_type] > 0 then
			i = i + 1
			sourceList[i] = {
				number = parentHas[allocating_type],
				index = vns.parentR,
			}
			sourceSum = sourceSum + parentHas[allocating_type]
		end
	end

	if #sourceList == 0 then return end
	sourceList.sum = sourceSum

	-- create targets from branch
	local i = 0
	local targetSum = 0
	local targetList = {}
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for _, branchR in ipairs(vns.allocator.target.children) do
			if branchR.scale[allocating_type] ~= nil and branchR.scale[allocating_type] ~= 0 then
				i = i + 1
				targetList[i] = {
					number = branchR.scale[allocating_type],
					index = branchR
				}
				targetSum = targetSum + branchR.scale[allocating_type]
			end
		end
	end

	--[[
	if vns.parentR ~= nil and vns.allocator.target ~= nil then
		local parentLack = vns.allocator.target.parentScale - vns.parentR.scale
		if parentLack[allocating_type] ~= nil and
		   parentLack[allocating_type] > 0 then
			i = i + 1
			targetList[i] = {
				number = parentLack[allocating_type],
				index = vns.parentR,
			}
			targetSum = targetSum + parentLack[allocating_type]
		end
	end
	--]]

	-- more children to parent
	if sourceSum > targetSum then
		i = i + 1
		if vns.parentR ~= nil then
			targetList[i] = {
				number = sourceSum - targetSum,
				index = vns.parentR,
			}
		else
			targetList[i] = {
				number = sourceSum - targetSum,
				index = {positionV3 = vector3(), orientationQ = quaternion(),},
			}
		end
	end
	-- create a cost matrix
	local originCost = {}
	for i = 1, #sourceList do originCost[i] = {} end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			local targetPosition = vector3(targetList[j].index.positionV3)
			--[[
			if vns.goalPoint ~= nil then
				targetPosition = targetPosition:rotate(vns.goalPoint.orientationQ) + vns.goalPoint.positionV3
			end
			--]]
			local relativeVector = sourceList[i].index.positionV3 - targetPosition
			relativeVector.z = 0
			originCost[i][j] = relativeVector:length()
			-- if the target is different type, allocate last -- TODO: DELETE
			---[[
			if targetList[j].index.robotTypeS ~= allocating_type then 
				originCost[i][j] = originCost[i][j] + 5
			end
			--]]
		end
	end

	GraphMatch(sourceList, targetList, originCost)

	-- find the farthest to for each children
	for i = 1, #sourceList do
		if sourceList[i].index ~= vns.parentR then -- ignore the source from parent
		if sourceList[i].index.robotTypeS == allocating_type then -- ignore the different type robot

		local dis = 0
		local maxT = nil
		for j = 1, #sourceList[i].to do
			local T = sourceList[i].to[j].target
			if originCost[i][T] > dis then
				dis = originCost[i][T]
				maxT = T
			end
		end

		sourceList[i].index.allocate = targetList[maxT].index
	end end end

	--[[
	DMSG("source list")
	DMSG(sourceList, 1, "children")
	DMSG("target list")
	DMSG(targetList, 1, "children")
	--]]
end

-------------------------------------------------------------------------------
function GraphMatch(sourceList, targetList, originCost)
	--DMSG("originCost")
	--DMSG(originCost)
	-- create a enhanced cost matrix
	-- and orderlist, to sort everything in originCost
	local orderList = {}
	local count = 0
	for i = 1, #sourceList do
		for j = 1, #targetList do
			count = count + 1
			orderList[count] = originCost[i][j]
		end
	end

	-- sort orderlist
	for i = 1, #orderList - 1 do
		for j = i + 1, #orderList do
			if orderList[i] > orderList[j] then
				local temp = orderList[i]
				orderList[i] = orderList[j]
				orderList[j] = temp
			end
		end
	end

	-- create a reverse index
	local reverseIndex = {}
	for i = 1, #orderList do reverseIndex[orderList[i]] = i end
	-- create an enhanced cost matrix
	local cost = {}
	for i = 1, #sourceList do
		cost[i] = {}
		for j = 1, #targetList do
			--cost[i][j] = (#orderList) ^ reverseIndex[originCost[i][j]]
			cost[i][j] = (sourceList.sum + 1) ^ reverseIndex[originCost[i][j]]
		end
	end

	--DMSG("cost")
	--DMSG(cost)

	-- create a flow network
	local C = {}
	local n = 1 + #sourceList + #targetList + 1
	for i = 1, n do C[i] = {} end
	-- 1, start
	-- 2 to #sourceList+1  source
	-- #sourceList+2 to #sourceList + #targetList + 1  target
	-- #sourceList + #target + 2   end
	for i = 1, #sourceList do
		C[1][1 + i] = sourceList[i].number
	end
	for i = 1, #targetList do
		C[#sourceList+1 + i][n] = targetList[i].number
	end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			C[1 + i][#sourceList+1 + j] = math.huge
		end
	end
	
	local W = {}
	local n = 1 + #sourceList + #targetList + 1
	for i = 1, n do W[i] = {} end

	for i = 1, #sourceList do
		W[1][1 + i] = 0
	end
	for i = 1, #targetList do
		W[#sourceList+1 + i][n] = 0
	end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			W[1 + i][#sourceList+1 + j] = cost[i][j]
		end
	end

	local F = MinCostFlowNetwork(C, W)

	for i = 1, #sourceList do
		sourceList[i].to = {}
		local count = 0
		for j = 1, #targetList do
			if F[1 + i][#sourceList+1 + j] ~= nil and
			   F[1 + i][#sourceList+1 + j] ~= 0 then
				count = count + 1
				sourceList[i].to[count] = {
					number = F[1 + i][#sourceList+1 + j],
					target = j,
				}
			end
		end
	end
end

-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
function Allocator.create_allocator_node(vns)
	return function()
		Allocator.step(vns)
	end
end

return Allocator

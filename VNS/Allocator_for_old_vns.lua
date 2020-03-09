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
	vns.allocator.allocated_children = {}
	vns.allocator.need = {}
	vns.allocator.myLastSentNeed = {}
end

function Allocator.reset(vns)
	vns.allocator = {}
	vns.allocator.allocated_children = {}
	vns.allocator.need = {}
	vns.allocator.myLastSentNeed = {}
end

function Allocator.addChild(vns)
end

function Allocator.deleteChild(vns, idS)
	vns.allocator.allocated_children[idS] = nil
	vns.allocator.need[idS] = nil
end

function Allocator.addParent(vns)
	vns.Allocator.setMorphology(vns, nil)
end

function Allocator.deleteParent(vns)
	vns.Allocator.setMorphology(vns, vns.allocator.gene)
end

function Allocator.setGene(vns, morph)
	if morph.robotTypeS ~= vns.robotTypeS then morph = nil return end
	Allocator.calcMorphScale(vns, morph)
	vns.allocator.gene = morph
	vns.Allocator.setMorphology(vns, morph)
end

function Allocator.setMorphology(vns, morph)
	vns.allocator.target = morph
	vns.allocator.allocated_children = {}
end

function Allocator.step(vns)
	-- receive branch
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "branch")) do
		Allocator.setMorphology(vns, msgM.dataT.target)
	end end

	-- allocate branch -- TODO: hungarian 
	if vns.allocator.target ~= nil and vns.allocator.target.children ~= nil then
		for _, branchT in ipairs(vns.allocator.target.children) do
			-- some branch is lost
			if branchT.actorS ~= nil and
			   vns.childrenRT[branchT.actorS] == nil then
				branchT.actorS = nil
			end

			-- some branch is not fulfilled
			if branchT.actorS == nil then
				-- try find the nearest child
				local nearestId = nil
				local nearestLen = 9999999
				for idS, childVns in pairs(vns.childrenRT) do
					if vns.allocator.allocated_children[idS] == nil and 
					   childVns.robotTypeS == branchT.robotTypeS then
						local len = (childVns.positionV3 - branchT.positionV3):length()
						if len < nearestLen then
							nearestLen = len
							nearestId = idS
						end
					end
				end

				if nearestId ~= nil then
					if vns.childrenRT[nearestId].assignTargetS ~= nil then
						vns.Assigner.assign(vns, nearestId, nil)
					end
					branchT.actorS = nearestId 
					vns.allocator.allocated_children[nearestId] = true
					vns.childrenRT[nearestId].goalPoint = {
						positionV3 = branchT.positionV3,
						orientationQ = branchT.orientationQ,
					}
					vns.Msg.send(nearestId, "branch", {target = branchT})
				end
			end
		end
	end

	-- more children set rallypoint to 0
	for idS, childVns in pairs(vns.childrenRT) do
		if vns.allocator.allocated_children[idS] == nil and
		   childVns.assignTargetS == nil then
			childVns.goalPoint = {
				positionV3 = vector3(),
				orientationQ = quaternion(),
			}
		end
	end

	-- need ----------------------------------------------------------------------
	-- receive need
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "need")) do
		if vns.childrenRT[msgM.fromS] ~= nil then
			vns.allocator.need[msgM.fromS] = vns.ScaleManager.Scale:new(msgM.dataT)
		end
	end

	local need = {}
	if vns.allocator.target ~= nil and
	   vns.allocator.target.children ~= nil then
		for idS, childVns in pairs(vns.childrenRT) do
			need[idS] = vns.ScaleManager.Scale:new(vns.allocator.need[idS])
			-- count already assigned robots
			for idSmore, childVnsmore in pairs(vns.childrenRT) do
				if childVnsmore.assignTargetS == idS then
					-- idSmore is a more robot assigned to idS
					if need[idS][childVnsmore.robotTypeS] ~= nil and need[idS][childVnsmore.robotTypeS] > 0 then
						need[idS][childVnsmore.robotTypeS] =
						need[idS][childVnsmore.robotTypeS] - 1
					else
						--self:unsign(idSmore, vns)
						vns.Assigner.assign(vns, idSmore, nil)
					end
				end
			end

			-- assign more robots
			for idSmore, childVnsmore in pairs(vns.childrenRT) do
				if need[idS][childVnsmore.robotTypeS] ~= nil and need[idS][childVnsmore.robotTypeS] > 0 then
					if vns.allocator.allocated_children[idSmore] == nil and 
					   childVnsmore.assignTargetS == nil then
						vns.Assigner.assign(vns, idSmore, idS)
						--self:assign(idSmore, idS, vns)
						need[idS][childVnsmore.robotTypeS] =
						need[idS][childVnsmore.robotTypeS] - 1
					end
				end
			end
		end 
	end

	-- count unallocated branches
	local unAllocatedBranchTN = vns.ScaleManager.Scale:new()
	if vns.allocator.target ~= nil and
	   vns.allocator.target.children ~= nil then
		for _, branchT in ipairs(vns.allocator.target.children) do
			if branchT.actorS == nil then
				if unAllocatedBranchTN[branchT.robotTypeS] == nil then
					unAllocatedBranchTN[branchT.robotTypeS] = 0 end
				unAllocatedBranchTN[branchT.robotTypeS] = 
					unAllocatedBranchTN[branchT.robotTypeS] + 1
			end
		end
	end

	--print("branch count")
	--showTable(unAllocatedBranchTN)

	-- count more robots
	local moreRobotsTN = vns.ScaleManager.Scale:new()
	for idS, childVns in pairs(vns.childrenRT) do
		if vns.allocator.allocated_children[idS] == nil and 
		   childVns.assignTargetS == nil then
			if moreRobotsTN[childVns.robotTypeS] == nil then
				moreRobotsTN[childVns.robotTypeS] = 0 end
			moreRobotsTN[childVns.robotTypeS] = 
				moreRobotsTN[childVns.robotTypeS] - 1
		end
	end

	--print("more robot")
	--showTable(moreRobotsTN)

	-- add children needs
	local totalNeedTN = vns.ScaleManager.Scale:new()
	for idS, childVns in pairs(vns.childrenRT) do
		if need[idS] ~= nil then
			totalNeedTN = totalNeedTN + need[idS]
		end
	end

	if vns.parentR ~= nil and need[vns.parentR.idS] ~= nil then
		totalNeedTN = totalNeedTN + need[vns.parentS]
	end

	totalNeedTN = totalNeedTN + unAllocatedBranchTN
	totalNeedTN = totalNeedTN + moreRobotsTN

	--print("total need")
	--showTable(totalNeedTN)

	-- send need to parent
	if vns.parentR ~= nil then
		local needForParent = totalNeedTN + vns.allocator.need[vns.parentS]
		for idS, childVns in pairs(vns.childrenRT) do
			if vns.allocator.allocated_children[idS] == nil and 
		   	   childVns.assignTargetS == vns.parentS then
				needForParent[childVns.robotTypeS] = 
					needForParent[childVns.robotTypeS] - 1
			end
		end

		if needForParent ~= vns.allocator.myLastSentNeed[vns.parentR.idS] then
			vns.Msg.send(vns.parentR.idS, "need", needForParent)
			vns.allocator.myLastSentNeed[vns.parentR.idS] = needForParent
		end
	end

	-- assign more to parent
	for idS, childVns in pairs(vns.childrenRT) do
		if vns.allocator.allocated_children[idS] == nil and
		   childVns.assignTargetS == nil and
		   vns.parentR ~= nil then
			vns.Assigner.assign(vns, idS, vns.parentR.idS)
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

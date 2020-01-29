-- Assigner -----------------------------------------
------------------------------------------------------
local Assigner = {}

--[[
--	related data
--	vns.assigner.targetS
--	vns.childrenRT.xxid.assignTargetS
--]]

function Assigner.create(vns)
	vns.assigner = {}
end

function Assigner.reset(vns)
	vns.assigner.targetS = nil
end

function Assigner.assign(vns, childIdS, assignToIdS)
	local childR = vns.childrenRT[childIdS]
	if childR == nil then return end

	vns.Msg.send(childIdS, "assign", {assignToS = assignToIdS})
	childR.assignTargetS = assignToIdS

	--update rally point immediately
	if vns.childrenRT[assignToIdS] ~= nil then
		childR.goalPoint = {
			positionV3 = vns.childrenRT[assignToIdS].positionV3,
			orientationQ = quaternion()
		}
	elseif vns.parentR ~= nil and vns.parentR.idS == assignToIdS then
		childR.goalPoint = {
			positionV3 = vns.parentR.positionV3,
			orientationQ = quaternion()
		}
	end
end

function Assigner.step(vns)
	-- listen to recruit from assigner.targetS
	for _, msgM in ipairs(vns.Msg.getAM(vns.assigner.targetS, "recruit")) do
		vns.Msg.send(msgM.fromS, "ack")
		if vns.parentR ~= nil and vns.parentR.idS ~= vns.assigner.targetS then
			vns.Msg.send(vns.parentR.idS, "dismiss")
			vns.parentR = nil
			local robotR = {
				idS = msgM.fromS,
				positionV3 = 
					vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
				orientationQ = msgM.dataT.orientationQ:inverse(),
				robotTypeS = msgM.dataT.fromTypeS,
			}
			vns.addParent(vns, robotR)
		end
		break
	end

	-- listen to assign
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "assign")) do
		vns.assigner.targetS = msgM.dataT.assignToS
	end end

	-- update assigning goalPoint
	for idS, childR in pairs(vns.childrenRT) do
		if childR.assignTargetS ~= nil then
			if vns.childrenRT[childR.assignTargetS] ~= nil then
				childR.goalPoint = {
					positionV3 = vns.childrenRT[childR.assignTargetS].positionV3,
					orientationQ = quaternion()
				}
			elseif vns.parentR ~= nil and vns.parentR.idS == childR.assignTargetS then
				childR.goalPoint = {
					positionV3 = vns.parentR.positionV3,
					orientationQ = quaternion()
				}
			end

		end
	end
end

------ behaviour tree ---------------------------------------
function Assigner.create_assigner_node(vns)
	return function()
		Assigner.step(vns)
	end
end

return Assigner

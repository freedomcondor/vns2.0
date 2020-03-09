-- Driver -----------------------------------------
------------------------------------------------------
local Driver = {}

function Driver.addChild(vns, robotR)
	robotR.goalSpeed = {
		positionV3 = vector3(),
		orientationV3 = vector3(),
	}
end

function Driver.prestep(vns)
	for idS, childR in pairs(vns.childrenRT) do
		childR.goalSpeed = {
			positionV3 = vector3(),
			orientationV3 = vector3(),
		}
	end
end

function Driver.deleteParent(vns)
	vns.goalPoint = nil
end

function Driver.step(vns)
	local self_transV3 = vector3()
	local self_rotateV3 = vector3()
	if vns.parentR ~= nil then
		for _, msgM in pairs(vns.Msg.getAM(vns.parentR.idS, "drive")) do
			-- a drive message data is:
			--	{ 	transV3, rotateV3,
			--		positionV3, orientationQ
			--	}
			local transV3 = msgM.dataT.transV3:rotate(vns.parentR.orientationQ)
			local rotateV3 = msgM.dataT.rotateV3:rotate(vns.parentR.orientationQ)
			--[[
			vns.goalPoint = {
				positionV3 = msgM.dataT.positionV3:rotate(vns.parentR.orientationQ) + 
				             vns.parentR.positionV3,
				orientationQ = msgM.dataT.orientationQ * vns.parentR.orientationQ
			}
			--]]
			Driver.move(transV3, rotateV3)
			self_transV3 = transV3
			self_rotateV3 = rotateV3
		end
	end

	-- send drive to children
	for _, robotR in pairs(vns.childrenRT) do
		local child_transV3, child_rotateV3

		if robotR.trajectory ~= nil then
			-- TODO trajectory
			child_transV3 = vector3()
			child_rotateV3 = vector3()
		elseif robotR.goalPoint ~= nil then
			local speed = 0.1
			local threshold = 0.35

			local goalPointTransV3, goalPointRotateV3

			local dV3 = robotR.goalPoint.positionV3 - robotR.positionV3
			dV3.z = 0
			local d = dV3:length()
			if d > threshold then 
				goalPointTransV3 = dV3:normalize() * speed
			else 
				goalPointTransV3 = dV3:normalize() * speed * (d / threshold)
			end

			local rotateQ = robotR.orientationQ:inverse() * robotR.goalPoint.orientationQ
			local angle, axis = rotateQ:toangleaxis()
			if angle > math.pi then angle = angle - math.pi * 2 end
			local goalPointRotateV3 = axis * angle

			child_transV3 = goalPointTransV3
			child_rotateV3 = goalPointRotateV3
		else
			child_transV3 = vector3()
			child_rotateV3 = vector3()
		end

		child_transV3 = child_transV3 + self_transV3
		child_rotateV3 = child_rotateV3 + self_rotateV3

		child_transV3 = child_transV3 + robotR.goalSpeed.positionV3
		child_rotateV3 = child_rotateV3 + robotR.goalSpeed.orientationV3

		vns.Msg.send(robotR.idS, "drive",
		{
			transV3 = child_transV3,
			rotateV3 = child_rotateV3,
			--positionV3 = robotR.goalPoint.positionV3,
			--orientationQ = robotR.goalPoint.orientationQ,
		})
	end
end

function Driver.create_driver_node(vns)
	return function()
		Driver.step(vns)
	end
end

function Driver:move(transV3, rotateV3)
	print("VNS.Driver.move needs to be implemented")
end

return Driver

-- Driver -----------------------------------------
------------------------------------------------------
local Driver = {}

function Driver.create(vns)
	vns.goal = {
		positionV3 = nil,
		orientationQ = nil,
		transV3 = vector3(),
		rotateV3 = vector3(),
	}
end

function Driver.addChild(vns, robotR)
	robotR.goal = {
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		transV3 = vector3(),
		rotateV3 = vector3(),
	}
end

function Driver.prestep(vns)
	vns.goal.positionV3 = nil
	vns.goal.orientationQ = nil
	vns.goal.transV3 = vector3()
	vns.goal.rotateV3 = vector3()

	for idS, childR in pairs(vns.childrenRT) do
		childR.goal.positionV3 = robotR.positionV3
		childR.goal.orientationQ = robotR.orientationQ
		childR.goal.transV3 = vector3()
		childR.goal.rotateV3 = vector3()
	end
end

function Driver.deleteParent(vns)
	vns.goal = {
		positionV3 = nil,
		orientationQ = nil,
		transV3 = vector3(),
		rotateV3 = vector3(),
	}
end

function Driver.step(vns)
	-- receive goal from parent
	if vns.parentR ~= nil then
		for _, msgM in pairs(vns.Msg.getAM(vns.parentR.idS, "drive")) do
			local receivedPositionV3 = vns.api.virtualFrame.V3_RtoV(
				vector3(msgM.dataT.positionV3):rotate(
					vns.api.virtualFrame.Q_VtoR(vns.parentR.orientationQ)
				) + 
				vns.api.virtualFrame.V3_VtoR(vns.parentR.positionV3)
			)

			local receivedOrientationQ = vns.api.virtualFrame.Q_RtoV(
				msgM.dataT.orientationQ * vns.api.virtualFrame.Q_VtoR(vns.parentR.orientationQ)
			)

			local receivedTransV3 = vns.api.virtualFrame.V3_RtoV(
				vector3(msgM.dataT.transV3):rotate(
					vns.api.virtualFrame.Q_VtoR(vns.parentR.orientationQ)
				)
			)

			local receivedRotateV3 = vns.api.virtualFrame.V3_RtoV(
				vector3(msgM.dataT.rotateV3):rotate(
					vns.api.virtualFrame.Q_VtoR(vns.parentR.orientationQ)
				)
			)

		print(receivedOrientationQ)
		vns.api.debug.drawArrow("green", 
		     vns.api.virtualFrame.V3_VtoR(receivedPositionV3),
		     vns.api.virtualFrame.V3_VtoR(receivedPositionV3 + vector3(1,0,0):rotate(receivedOrientationQ))
		)


			-- calc speed
			local goalPointTransV3, goalPointRotateV3

			local speed = 0.1
			local threshold = 0.35
			local dV3 = receivedPositionV3
			dV3.z = 0
			local d = dV3:length()
			if d > threshold then 
				goalPointTransV3 = dV3:normalize() * speed
			elseif d == 0 then
				goalPointTransV3 = vector3()
			else
				goalPointTransV3 = dV3:normalize() * speed * (d / threshold)
			end

			local rotateQ = receivedOrientationQ
			local angle, axis = rotateQ:toangleaxis()
			if angle ~= angle then angle = 0 end -- sometimes toangleaxis returns nan

			if angle > math.pi then angle = angle - math.pi * 2 end
			local goalPointRotateV3 = axis * angle

			local transV3 = goalPointTransV3 + receivedTransV3 + vns.goal.transV3
			local rotateV3 = goalPointRotateV3 + receivedRotateV3 + vns.goal.rotateV3

			Driver.move(transV3, rotateV3)
		end
	else
		local transV3 = vector3()
		local rotateV3 = vector3()

		transV3 = transV3 + vns.goal.transV3
		rotateV3 = rotateV3 + vns.goal.rotateV3

		Driver.move(transV3, rotateV3)
	end

	-- send drive to children
	for _, robotR in pairs(vns.childrenRT) do
		if robotR.trajectory ~= nil then
			-- TODO trajectory
			child_transV3 = vector3()
			child_rotateV3 = vector3()
			child_positionV3 = vector3()
			child_orientationQ = quaternion()
		else 
			child_positionV3 = robotR.goal.positionV3
			child_orientationQ = robotR.goal.orientationQ
			child_transV3 = robotR.goal.transV3
			child_rotateV3 = robotR.goal.rotateV3
		end

		--child_transV3 = child_transV3 + self_transV3
		--child_rotateV3 = child_rotateV3 + self_rotateV3

		--child_transV3 = child_transV3 + robotR.goalSpeed.positionV3
		--child_rotateV3 = child_rotateV3 + robotR.goalSpeed.orientationV3

print("child_positionV3 = ", child_positionV3)
print("child_orientationQ = ", child_orientationQ)
print("send position = ", vns.api.virtualFrame.V3_VtoR(child_positionV3))
print("send_orientationQ = ", vns.api.virtualFrame.Q_VtoR(child_orientationQ))

		vns.Msg.send(robotR.idS, "drive",
		{
			transV3 = vns.api.virtualFrame.V3_VtoR(child_transV3),
			rotateV3 = vns.api.virtualFrame.V3_VtoR(child_rotateV3),
			positionV3 = vns.api.virtualFrame.V3_VtoR(child_positionV3),
			orientationQ = vns.api.virtualFrame.Q_VtoR(child_orientationQ),
		})
	end
end

function Driver.create_driver_node(vns)
	return function()
		Driver.step(vns)
	end
end

function Driver.move(transV3, rotateV3)
	print("VNS.Driver.move needs to be implemented")
end

return Driver

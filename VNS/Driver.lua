-- Driver -----------------------------------------
------------------------------------------------------
local Driver = {}

function Driver.step(vns)
	if vns.parentR ~= nil then
		for _, msgM in pairs(vns.Msg.getAM(vns.parentR.idS, "drive")) do
			-- a drive message data is:
			--	{ transV3, rotateV3 }
			DMSG("I receive = ", msgM.dataT.transV3)

			local transV3 = msgM.dataT.transV3:rotate(vns.parentR.orientationQ)
			local rotateV3 = msgM.dataT.rotateV3:rotate(vns.parentR.orientationQ)
			Driver.move(transV3, rotateV3)

			DMSG("I move = ",transV3)
		end
	end

	-- send drive to children
	for _, robotR in pairs(vns.childrenRT) do
		if robotR.trajectory ~= nil then
			-- TODO trajectory
		elseif robotR.goalPoint ~= nil then
			local speed = 0.3
			local threshold = 0.15

			local goalPointTransV3, goalPointRotateV3

			local dV3 = robotR.goalPoint.positionV3 - robotR.positionV3
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


			DMSG("positionV3 = ",robotR.positionV3)
			DMSG("speedV3 = ",goalPointTransV3)

			vns.Msg.send(robotR.idS, "drive",
			{
				transV3 = goalPointTransV3,
				rotateV3 = goalPointRotateV3,
			}
		)
		end
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

--[[
--	Drone connector
--	the drone will always try to recruit seen pipucks
--]]


local DroneConnector = {}

function DroneConnector.preStep(vns)
	vns.connector.seenRobots = {}
end

function DroneConnector.step(vns)
	-- report my sight to all seen pipucks, and drones in parent and children
	--[[
	if vns.parentR ~= nil and vns.parentR.robotTypeS == "drone" then
		vns.Msg.send(vns.parentR.idS, "reportSight", {mySight = vns.connector.seenRobots})
	end

	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.robotTypeS == "drone" then
			vns.Msg.send(idS, "reportSight", {mySight = vns.connector.seenRobots})
		end
	end

	for idS, robotR in pairs(vns.connector.seenRobots) do
		vns.Msg.send(idS, "reportSight", {mySight = vns.connector.seenRobots})
	end
	--]]

	---[[
	-- broadcast my sight so other drones would see me
	vns.Msg.send("ALLMSG", "reportSight", {mySight = vns.connector.seenRobots})
	--]]

	-- for sight report, generate quadcopters
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "reportSight")) do
		vns.connector.seenRobots[msgM.fromS] = DroneConnector.calcQuadR(msgM.fromS, vns.connector.seenRobots, msgM.dataT.mySight)
	end

	-- convert vns.connector.seenRobots from real frame into virtual frame
	local seenRobotinR = vns.connector.seenRobots
	vns.connector.seenRobots = {}
	for idS, robotR in pairs(seenRobotinR) do
		vns.connector.seenRobots[idS] = {
			idS = idS,
			robotTypeS = robotR.robotTypeS,
			positionV3 = vns.api.virtualFrame.V3_RtoV(robotR.positionV3),
			orientationQ = vns.api.virtualFrame.Q_RtoV(robotR.orientationQ),
		}
	end
end

function DroneConnector.calcQuadR(idS, myVehiclesTR, yourVehiclesTR)
	local quadR = nil
	for _, robotR in pairs(yourVehiclesTR) do
		if myVehiclesTR[robotR.idS] ~= nil and
		   myVehiclesTR[robotR.idS].robotTypeS ~= "drone" then
			myRobotR = myVehiclesTR[robotR.idS]
			quadR = {
				idS = idS,
				positionV3 = myRobotR.positionV3 +
				             vector3(-robotR.positionV3):rotate(
							 	robotR.orientationQ:inverse() * myRobotR.orientationQ
							 ),
				orientationQ = robotR.orientationQ:inverse() * myRobotR.orientationQ,
				robotTypeS = "drone",
			}
			break
		end
	end
	return quadR
end

function DroneConnector.create_droneconnector_node(vns)
	return function()
		vns.DroneConnector.step(vns)
		return false, true
	end
end

return DroneConnector

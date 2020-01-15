--[[
--	Drone connector
--	the drone will always try to recruit seen pipucks
--]]


local DroneConnector = {}

function DroneConnector.step(vns)
	-- report my sight to my parent and TODO later assignTarget
	if vns.parentR ~= nil then
		vns.Msg.send(vns.parentR.idS, "reportForDuty", {mySight = vns.connector.seenRobots})
	end

	for idS, _ in pairs(vns.childrenRT) do
		vns.Msg.send(idS, "reportForDuty", {mySight = vns.connector.seenRobots})
	end

	--[[
	if vns.idS == "drone1" then
		vns.Msg.send("drone0", "reportForDuty", {mySight = vns.connector.seenRobots})
	end
	--]]

	-- if I don't have parent, ack a recruit
	if vns.parentR == nil then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			vns.parentR = {
				idS = msgM.fromS,
				positionV3 = 
					vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
				orientationQ = msgM.dataT.orientationQ:inverse(),
			}

			if msgM.dataT.fromTypeS == "pipuck" then
				vns.Msg.send(msgM.fromS, "ack", {
					positionV3 = vns.connector.seenRobots[msgM.fromS].positionV3,
					orientationQ = vns.connector.seenRobots[msgM.fromS].orientationQ,
				})
			else
				vns.Msg.send(msgM.fromS, "ack")
			end

			if vns.connector.waitingRobots[vns.parentS] ~= nil then
				vns.connector.waitingRobots[vns.parentS] = nil
			end
			break
		end
	end

	-- for sight report, generate quadcopters
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "reportForDuty")) do
		vns.connector.seenRobots[msgM.fromS] = DroneConnector.calcQuadR(msgM.fromS, vns.connector.seenRobots, msgM.dataT.mySight)
	end
end

function DroneConnector.create_droneconnector_node(vns)
	return 
	function()
		vns.DroneConnector.step(vns)
		vns.Connector.step(vns)
		vns.Connector.recruitAll(vns)
		
		return false, true
	end
	--[[
	{type = "sequence", children = {
		vns.Connector.create_connector_node(vns),
		function()
			vns.Connector.recruitAll(vns)
		end,
	},}
	--]]
end

function DroneConnector.calcQuadR(idS, myVehiclesTR, yourVehiclesTR)
	local quadR = nil
	for _, robotR in pairs(yourVehiclesTR) do
		if myVehiclesTR[robotR.idS] ~= nil then
			myRobotR = myVehiclesTR[robotR.idS]
			quadR = {
				idS = idS,
				positionV3 = myRobotR.positionV3 +
				             vector3(-robotR.positionV3):rotate(
							 	robotR.orientationQ:inverse() * myRobotR.orientationQ
							 ),
				orientationQ = robotR.orientationQ:inverse() * myRobotR.orientationQ
			}
			break
		end
	end
	return quadR
end

return DroneConnector

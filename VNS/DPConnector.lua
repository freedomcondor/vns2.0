--[[
--	Drone - Pipuck connector
--	the drone will always try to recruit seen pipucks
--]]


local DPConnector = {}

function DPConnector.step(vns)
	-- report my sight to my parent and TODO later assignTarget
	if vns.parentS ~= nil then
		vns.Msg.send(vns.parentS, "reportForDuty", {mySight = vns.seenRobots})
	end

	for idS, _ in pairs(vns.children) do
		vns.Msg.send(idS, "reportForDuty", {mySight = vns.seenRobots})
	end

	--[[
	if vns.idS == "drone1" then
		vns.Msg.send("drone0", "reportForDuty", {mySight = vns.seenRobots})
	end
	--]]

	if vns.parentS == nil then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			vns.parentS = msgM.fromS
			vns.Msg.send(msgM.fromS, "ack")
			if vns.connector.waitingRobots[vns.parentS] ~= nil then
				vns.connector.waitingRobots[vns.parentS] = nil
			end
			break
		end
	end

	-- for sight report, generate quadcopters
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "reportForDuty")) do
		vns.seenRobots[msgM.fromS] = DPConnector.calcQuadR(msgM.fromS, vns.seenRobots, msgM.dataT.mySight)
	end
end

function DPConnector.create_dpconnector_node(vns)
	return 
	function()
		vns.DPConnector.step(vns)
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

function DPConnector.calcQuadR(idS, myVehiclesTR, yourVehiclesTR)
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

return DPConnector

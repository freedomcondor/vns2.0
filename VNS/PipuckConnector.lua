--[[
--	Pipuck connector
--	the Pipuck listen to drone's recruit message, with deny
--]]

local PipuckConnector = {}

function PipuckConnector.step(vns)
	-- if I don't have parent, ack a recruit
	if vns.parentR == nil then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			vns.parentR = {
				idS = msgM.fromS,
				positionV3 = 
					vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
				orientationQ = msgM.dataT.orientationQ:inverse(),
			}
			vns.Msg.send(msgM.fromS, "ack")
			break
		end
	end

	-- for other recruit from a drone, recruit back
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "recruit")) do
		if vns.parentR ~= nil and msgM.fromS ~= vns.parentR.idS and 
		   msgM.dataT.fromTypeS == "drone" then -- TODO check assigner
			local robotR = {
				idS = msgM.fromS,
				positionV3 = vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
				orientationQ = msgM.dataT.orientationQ:inverse(),
				robotTypeS = "drone",
			}
			vns.Connector.recruit(vns, robotR)
			vns.connector.waitingRobots[robotR.idS].count = -1
		end
	end

	-- For any sight report, update quadcopter, add other pipucks to seenRobots
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "reportForDuty")) do
		if msgM.dataT.mySight[vns.idS] ~= nil then
			local common = msgM.dataT.mySight[vns.idS]
			local quad = {
				positionV3 = 
					vector3(-common.positionV3):rotate(
					common.orientationQ:inverse()),
				orientationQ = 
					common.orientationQ:inverse(),
			}

			-- update quadcopter location in children or parent
			if vns.childrenRT[msgM.fromS] ~= nil then
				vns.childrenRT[msgM.fromS].positionV3 = quad.positionV3
				vns.childrenRT[msgM.fromS].orientationQ = quad.orientationQ
				vns.childrenRT[msgM.fromS].updated = 0
			end
			if vns.parentR ~= nil and vns.parentR.idS == msgM.fromS then
				vns.parentR.positionV3 = quad.positionV3
				vns.parentR.orientationQ = quad.orientationQ
			end

			-- add other pipucks to seenRobots
			for idS, R in pairs(msgM.dataT.mySight) do
				if idS ~= vns.idS then
					vns.connector.seenRobots[idS] = {
						idS = idS,
						positionV3 = quad.positionV3 + 
						             vector3(R.positionV3):rotate(quad.orientationQ),
						--orientationQ = quad.orientationQ * R.orientationQ,
						orientationQ = R.orientationQ * quad.orientationQ,
						robotTypeS = "pipuck",
					}
				end
			end
		end
	end
end

function PipuckConnector.create_pipuckconnector_node(vns)
	return function()
		vns.PipuckConnector.step(vns)
		vns.Connector.step(vns)
		vns.Connector.recruitAll(vns)

		return false, true
	end
end

return PipuckConnector

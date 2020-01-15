--[[
--	Pipuck - Drone connector
--	the Pipuck listen to drone's recruit message, with deny
--]]

local PDConnector = {}

function PDConnector.step(vns)
	-- if I don't have parent, ack a recruit
	if vns.parentS == nil then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			vns.parentS = msgM.fromS
			vns.Msg.send(msgM.fromS, "ack")
			break
		end
	end

	-- deny all recruit from not my parent and not myAssignTarget
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "recruit")) do
		if msgM.fromS ~= vns.parentS and msgM.fromS ~= vns.myAssignParent and 
		   msgM.dataT.fromTypeS == "drone" then --check assigner
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

			-- update quadcopter location
			if vns.children[msgM.fromS] ~= nil then
				vns.children[msgM.fromS].positionV3 = quad.positionV3
				vns.children[msgM.fromS].orientationQ = quad.orientationQ
			end

			-- add other pipucks to seenRobots
			for idS, R in pairs(msgM.dataT.mySight) do
				if idS ~= vns.idS then
					vns.seenRobots[idS] = {
						idS = idS,
						positionV3 = quad.positionV3 + 
						             vector3(R.positionV3):rotate(quad.orientationQ),
						orientationQ = quad.orientationQ * R.orientationQ,
						robotTypeS = "pipuck",
					}
				end
			end
		end
	end
end

function PDConnector.create_pdconnector_node(vns)
	return
	function()
		vns.PDConnector.step(vns)
		vns.Connector.step(vns)
		vns.Connector.recruitAll(vns)

		return false, true
	end
	--[[
	{type = "sequence", children = {
		vns.Connector.create_connector_node(vns),
		function()
			vns.PDConnector.step(vns)
		end,
	},}
	--]]
end

return PDConnector

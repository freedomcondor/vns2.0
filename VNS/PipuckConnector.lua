--[[
--	Pipuck connector
--	the Pipuck listen to drone's recruit message, with deny
--]]

local PipuckConnector = {}

function PipuckConnector.step(vns)
	-- For any sight report, update quadcopter and other pipucks to seenRobots
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "reportSight")) do
		if msgM.dataT.mySight[vns.idS] ~= nil then
			local common = msgM.dataT.mySight[vns.idS]
			local quad = {
				idS = msgM.fromS,
				positionV3 = 
					vector3(-common.positionV3):rotate(
					common.orientationQ:inverse()),
				orientationQ = 
					common.orientationQ:inverse(),
				robotTypeS = "drone",
			}

			if vns.connector.seenRobots[quad.idS] == nil then --TODO average
				vns.connector.seenRobots[quad.idS] = quad
			end

			--[[
			-- add other pipucks to seenRobots
			for idS, R in pairs(msgM.dataT.mySight) do
				if idS ~= vns.idS and vns.connector.seenRobots[idS] == nil then -- TODO average
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
			--]]
		end
	end
end

function PipuckConnector.create_pipuckconnector_node(vns)
	return function()
		vns.PipuckConnector.step(vns)
		return false, true
	end
end

return PipuckConnector

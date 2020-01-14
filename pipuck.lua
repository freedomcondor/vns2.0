package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("pipuckAPI")
DMSG = require("DebugMessage")
DMSG.enable()

function init()
end

function step()
	pipuck_move(vector3(0.5, -0.5, 0), vector3(0,0,0))

	local message = robot.wifi.rx_data
	if message[1] ~= nil and message[1].toS == robot.id and message[1].cmdS == "recruit" then
		robot.wifi.tx_data({
			cmdS = "ack",
			toS = "drone0",
			fromS = robot.id,
		})
	end
end

function reset() end
function destroy() end

package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("pipuckAPI")
DMSG = require("DebugMessage")
DMSG.enable()

function init()
end

function step()
	pipuck_move(vector3(0.05, -0.05, 0), vector3(0,0,0))
end

function reset() end
function destroy() end

package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

require("pipuckAPI")
local VNS = require("VNS")

DMSG.enable()
--require("Debugger")

--local vns
function init()
	linkPipuckInterface(VNS)
end

function step()
	pipuck_move(vector3(1, 0, 0), vector3(0, 0, 0.1))
end

function reset() end
function destroy() end

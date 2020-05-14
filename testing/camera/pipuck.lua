package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

local api = require("pipuckAPI")

DMSG.enable()
--require("Debugger")

--local vns
function init()
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	api.postStep()
end

function reset() end
function destroy() end

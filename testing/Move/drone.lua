package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

require("droneAPI")
local VNS = require("VNS")

DMSG.enable()
--require("Debugger")

--local vns
function init()
	linkDroneInterface(VNS)
	drone_set_height(1.5)
	drone_enable_cameras()
end

function step()
	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) end
	process_time()
	drone_move(vector3(1, 0, 0), vector3(0, 0, 0.1))
end

function reset()
	init()
end

function destroy()
end

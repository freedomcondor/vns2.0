package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("droneAPI")
VNS = require("VNS")
BehaviorTree = require("luabt")
DMSG = require("DebugMessage")
DMSG.enable()

local vns
local seenRobots = {}

function init()
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create(robot.id)

	bt = BehaviorTree:create(VNS.create_vns_node(vns, seenRobots))
end

function step()
	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) return end

	process_time()
	--drone_set_speed(1.0, 0, 0, 0)
	
	drone_clear_seenRobots(seenRobots)
	drone_add_seenRobots(seenRobots, drone_detect_tags())
end

function reset()
end

function destroy()
end

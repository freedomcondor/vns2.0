package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("droneAPI")
VNS = require("VNS")
BehaviorTree = require("luabt")
DMSG = require("DebugMessage")
DMSG.enable()

require("Debugger")

--local vns
local seenRobots = {}

function init()
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create()
	DMSG("vns")
	DMSG(vns)
	bt = BehaviorTree.create(VNS.create_vns_node(vns, seenRobots))
end

function step()
	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) return end

	process_time()
	drone_clear_seenRobots(seenRobots)
	VNS.Msg.prestep()

	drone_add_seenRobots(seenRobots, drone_detect_tags())

	bt()

	for i, child in pairs(vns.children) do
		drawArrow("blue", 
			tostring(vector3(0,0,0)),
			tostring(child.positionV3)
		)

		drawArrow("red", 
			tostring(child.positionV3),
			tostring(child.positionV3 + vector3(1,0,0):rotate(child.orientationQ))
		)
	end
	--[[
	--]]
end

function reset()
	init()
end

function destroy()
end

-----------------------------------------------------------------------

VNS.Msg.sendTable = function(table)
	robot.wifi.tx_data(table)
end

VNS.Msg.getTablesAT = function(table)
	return robot.wifi.rx_data
end

VNS.Msg.myIDS = function()
	return robot.id
end

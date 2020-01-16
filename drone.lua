package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("droneAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")
DMSG = require("DebugMessage")
DMSG.enable()

--require("Debugger")

--local vns
function init()
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create("drone")
	bt = BehaviorTree.create(VNS.create_vns_node(vns))
end

function step()
	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) end

	process_time()
	vns.prestep(vns)

	drone_add_seenRobots(vns.connector.seenRobots, drone_detect_tags())

	bt()

	if vns.parentR ~= nil then
		drawArrow("green", 
			tostring(vector3(0,0,0)),
			tostring(vns.parentR.positionV3)
		)
	end

	for i, child in pairs(vns.childrenRT) do
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

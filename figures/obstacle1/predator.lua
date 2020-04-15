package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")
pairs = require("AlphaPairs")

local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

local right_speed = 0.002
local left_speed = 0.0025

--local vns
function init()
	robot.differential_drive.set_target_velocity(left_speed, -right_speed) 
end

function step()
	robot.differential_drive.set_target_velocity(left_speed, -right_speed) 
	local color = "black"
	local middle = vector3(0,0,0)
	local radius = 0.05
	robot.debug.draw("ring(" .. color .. ")(" .. 
		tostring(middle) .. ")(" ..
		tostring(radius) .. ")"
	)
end

function reset() end
function destroy() end

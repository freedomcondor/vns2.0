package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")
pairs = require("AlphaPairs")

local VNS = require("VNS")
require("pipuckAPI")

local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

local right_speed = 0.010
local left_speed = 0.01


local vns

--local vns
function init()
	linkPipuckInterface(VNS)
	vns = VNS.create("pipuck")
end

function step()
	vns.Msg.prestep(vns)
	local drone_positionV3
	local drone_orientationQ
	local flag = false
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "predator_location")) do
		local loc = msgM.dataT.positionV3
		local dir = msgM.dataT.orientationQ
		drone_positionV3 = vector3(-loc):rotate(
		                     dir:inverse())
		drone_orientationQ = dir:inverse()
		flag = true
		break
	end
	if flag == false then
		pipuck_move(vector3(1, 0, 0) * 0.15)
	else
		pipuck_move(drone_positionV3:normalize() * 0.15)
	end

	local color = "red"
	local middle = vector3(0,0,0)
	local radius = 0.05
	robot.debug.draw("ring(" .. color .. ")(" .. 
		tostring(middle) .. ")(" ..
		tostring(radius) .. ")"
	)
end

function reset() end
function destroy() end

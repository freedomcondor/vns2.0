package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

local api = require("droneAPI")
--local VNS = require("VNS")

DMSG.enable()
--require("Debugger")

--local vns
function init()
	api.init()
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	api.move(vector3(0,0,0), vector3(0,0,math.pi/100))

	--[[
	local tags = api.droneDetectTags()
	for i, tag in ipairs(tags) do
		api.debug.drawArrow("blue", vector3(), vector3(tag.positionV3))
	end
	--]]
	tags = api.droneDetectTags()
	seenRobots = api.droneAddSeenRobots(tags)
	for i, robot in pairs(seenRobots) do
		api.debug.drawArrow("blue", vector3(), api.virtualFrame.V3_VtoR(vector3(robot.positionV3)))
	end

	api.droneMaintainHeight(1.5)
	api.postStep()
end

function reset()
	init()
end

function destroy()
end

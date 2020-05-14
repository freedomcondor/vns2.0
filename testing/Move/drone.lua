package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

api = require("droneAPI")
--local VNS = require("VNS")

DMSG.enable()
--require("Debugger")

--local vns
function init()
--[[
	linkDroneInterface(VNS)
	drone_set_height(1.5)
	drone_enable_cameras()
	--]]
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	if api.stepCount > 20 then
		if robot.id == "drone0" then
			api.move(vector3(1/100,0,1), vector3(0,0,math.pi/100))
			--api.droneSetSpeed(0.1/10,0,0, 0)
		else
			api.move(vector3(0,0,1), vector3(0,0,3.1415926 / 100))
			--api.droneSetSpeed(0,0,0, 0.31415926/10)
		end
	end
	api.droneMaintainHeight(1.5)
	api.postStep()
	-- check height
--[[
	DMSG(robot.system)
	if drone_check_height(1.5) == false then drone_set_height(1.5) end
	process_time()
	drone_move(vector3(1, 0, 0), vector3(0, 0, 0))
--]]
end

function reset()
	init()
end

function destroy()
end

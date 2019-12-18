DMSG = require('DebugMessage')
DMSG.enable()

function init()
	set_speed(0, 0, 1.5, 0)
	--[[
	for i, camera in ipairs(robot.cameras_system) do
		--camera.enable()
		camera.disable()
	end
	--]]
end

function step()
	--set_speed(0, 0, 0, math.pi/6)
	set_speed(0, 0, 0, 0)
	robot.wifi.tx_data({aa = "aaa", bb = 5, cc = vector3(5, 6, 7), dd = quaternion(math.pi, vector3(0,0,1))})
	DMSG("cameras")
	DMSG(robot.cameras_system)
end

function reset()
   init()
end

function destroy()
end

function set_speed(x, y, z, th)
	local rad = robot.flight_system.orientation:length()
	
	robot.flight_system.set_targets(
		robot.flight_system.position + vector3(x,y,z),
		rad + th
	)
end

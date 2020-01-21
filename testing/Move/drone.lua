package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("droneAPI")
DMSG = require("DebugMessage")
DMSG.enable()

--[[
	drone_set_height(1.5)
	drone_enable_cameras()
	if drone_check_height(1.5) == false then drone_set_height(1.5) end
--]]

-- trajectory = { time: number -> { position: vector3, yaw: number }}
trajectory = {
   [10] =  { vector3( 0,  0, 1.25),  0.0},
   [20] =  { vector3( 1,  0, 1.25),  0.314},
   --[[
   [20] =  { vector3( 1,  1, 1.25),  0.0},
   [30] =  { vector3(-1,  1, 1.25),  0.0},
   [40] =  { vector3(-1, -1, 1.25),  0.0},
   [50] =  { vector3( 1, -1, 1.25),  0.0},
   --]]
}

function init()
	--[[
   for index, camera in ipairs(robot.cameras_system) do
      camera.enable()
   end
   time = 1
   --]]
end

function step()
	drone_set_speed(1, 0, 0, 0.0314)
	--[[
   for timestamp, path in pairs(trajectory) do
      if time == timestamp then
         robot.flight_system.set_targets(table.unpack(path))
         --log(tostring(time) .. ": " .. tostring(robot.flight_system.position))
      end
   end
   time = time + 1
   if robot.debug then
      robot.debug.draw("arrow(blue)(0,0,0)(0,0,-0.50)")
   end
   --]]
end

function reset()
   init()
end

function destroy()
end

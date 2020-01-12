-- trajectory = { time: number -> { position: vector3, yaw: number }}
trajectory = {
   [10] =  { vector3( 0,  0, 1.25),  0.0},
   [20] =  { vector3( 1,  1, 1.25),  0.0},
   [30] =  { vector3(-1,  1, 1.25),  0.0},
   [40] =  { vector3(-1, -1, 1.25),  0.0},
   [50] =  { vector3( 1, -1, 1.25),  0.0},
}

function init()
   for index, camera in ipairs(robot.cameras_system) do
      camera.enable()
   end
   time = 1
end

function step()
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
end

function reset()
   init()
end

function destroy()
end

luabt = require('luabt')

function init()
   -- obstacle avoidance behavior
   behavior = luabt.create({
      type = "selector",
      children = {{
         type = "sequence",
         children = {
            function() return false, closest_obstacle == "left" or closest_obstacle == "front" end,
            function() robot.differential_drive.set_target_velocity(0.05, 0.05) return true end,
         }}, {
         type = "sequence",
         children = {
            function() return false, closest_obstacle == "right" end,
            function() robot.differential_drive.set_target_velocity(-0.05, -0.05) return true end,

         }},
         function() robot.differential_drive.set_target_velocity(0.05, -0.05) return true end,
      }
   })
end

function step()
   -- process obstacles
   closest_obstacle = nil
   local obstacles = {
      left = robot.rangefinders[2].reading,
      front = robot.rangefinders[1].reading,
      right = robot.rangefinders[12].reading,
   }
   for obstacle, distance in pairs(obstacles) do
      if distance < 0.1 then
         if closest_obstacle == nil or distance < obstacles[closest_obstacle] then
            closest_obstacle = obstacle
         end
      end
   end
   -- tick obstacle avoidance behavior tree
   behavior()
   -- draw
   if robot.debug then
      robot.debug.draw("ring(yellow)(0,0,0)(0.25)")
   end
end

function reset() end
function destroy() end

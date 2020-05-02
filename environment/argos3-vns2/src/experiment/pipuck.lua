luabt = require('luabt')

function init()
   -- obstacle avoidance behavior
   robot.behavior = luabt.create({
      type = "selector",
      children = {{
         type = "sequence",
         children = {
            function() return false, obstacle_detected end,
            function() robot.differential_drive.set_target_velocity(0.05, 0.05) return true end,
         }},
         function() robot.differential_drive.set_target_velocity(0.05, -0.05) return true end,
      }
   })
end

function step()
   -- process obstacles
   obstacle_detected = false
   local rangefinders = {
      far_left  = robot.rangefinders[7].reading,
      left      = robot.rangefinders[8].reading,
      right     = robot.rangefinders[1].reading,
      far_right = robot.rangefinders[2].reading,
   }
   for rangefinder, reading in pairs(rangefinders) do
      if reading < 0.075 then
         obstacle_detected = true
      end
   end
   -- tick obstacle avoidance behavior tree
   robot.behavior()
   -- draw
   if robot.debug then
      robot.debug.loop_functions("\"string from pipuck.lua\"")
      robot.debug.draw("ring(yellow)(0,0,0)(0.25)")
   end
end

function reset() end
function destroy() end

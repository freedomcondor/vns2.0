function init()
   reset()
end

function step()
   if robot.lift_system.state == "inactive" then
      robot.lift_system.set_position(0.07);
   end
end

function reset()
   robot.differential_drive.set_target_velocity(0.01,0.01);
   robot.lift_system.calibrate();
end

function destroy()
end

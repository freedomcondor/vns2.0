package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

api = require("pipuckAPI")

DMSG.enable()
--require("Debugger")

--local vns
function init()
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	local speed = 1 / 100
	if api.stepCount > 20 then
		if robot.id == "pipuck0" then
			--api.pipuckSetWheelSpeed(speed, speed)
			--api.pipuckSetRotationSpeed(0, 3.1415926/100 * 4)
			--api.pipuckSetSpeed(0, 1/1000)
			api.move(vector3(1/100,0,0), vector3(0,0,math.pi/100))
		else
			api.move(vector3(1/100,0,0), vector3())
			--api.pipuckSetWheelSpeed(speed, speed)
			--api.pipuckSetSpeed(0, 3.1415926)
		end
	end
	api.postStep()
end

function reset() end
function destroy() end

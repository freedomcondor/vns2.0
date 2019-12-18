DMSG = require('DebugMessage')
luabt = require('luabt')

DMSG.enable()

function init()
end

function step()
	DMSG(robot.id, "get:")
	DMSG(robot.wifi.rx_data)
if robot.id == "pipuck1" then
	if robot.ground.left.reading < 0.6 then
		robot.wifi.tx_data({-0.05, 0.05})
    	set_velocity(-0.05, 0.05) 
	elseif robot.ground.right.reading < 0.6 then
		robot.wifi.tx_data({0.05, -0.05})
    	set_velocity(0.05, -0.05) 
	else
		robot.wifi.tx_data({0.05, 0.05})
    	set_velocity(0.05, 0.05) 
	end
else
	if robot.wifi.rx_data[1] ~= nil then
    	set_velocity(robot.wifi.rx_data[1][1], robot.wifi.rx_data[1][2]) 
	end
end
end

function set_velocity(x, y)
	robot.differential_drive.set_target_velocity(x, -y) 
end

function reset() end
function destroy() end

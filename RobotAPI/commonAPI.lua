time_step = 0.2

function process_time()
	time_step = 0.2
end

function drawArrow(color, begin, finish)
	if robot.debug == nil then return end
	robot.debug.draw("arrow(" .. color .. ")(" .. 
		tostring(begin) .. ")(" ..
		tostring(finish) .. ")"
	)
end

------------------------------------------------------
function linkCommonRobotInterface(VNS)
	VNS.Msg.sendTable = function(table)
		robot.wifi.tx_data(table)
	end

	VNS.Msg.getTablesAT = function(table)
		return robot.wifi.rx_data
	end

	VNS.Msg.myIDS = function()
		return robot.id
	end
end

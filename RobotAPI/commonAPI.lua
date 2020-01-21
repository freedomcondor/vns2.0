time_step = 0.2

function process_time()
	time_step = 0.2
end

function drawArrow(color, begin, finish)
	robot.debug.draw("arrow(" .. color .. ")(" .. 
		tostring(begin) .. ")(" ..
		tostring(finish) .. ")"
	)
end

function init()
end

function step()
	local color = "blue"
	local middle = vector3(0,0,0)
	local radius = 0.15
	robot.debug.draw("ring(" .. color .. ")(" .. 
		tostring(middle) .. ")(" ..
		tostring(radius) .. ")"
	)
end

function reset() end
function destroy() end

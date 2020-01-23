--[[
--	pipuck api
--]]

require("commonAPI")

function pipuck_set_velocity(x, y)
	local max = 0.5
	if x < -max then x = -max end
	if x >  max then x =  max end
	if y < -max then y = -max end
	if y >  max then y =  max end
	robot.differential_drive.set_target_velocity(x, -y) 
end

function pipuck_move(transV3, rotateV3)
	local left = transV3.x
	local right = transV3.x
	local turnrate = 1.5

	--left  = left  - transV3.y/transV3.x * turnrate
	--right = right + transV3.y/transV3.x * turnrate

	left  = left  - transV3.y * turnrate
	right = right + transV3.y * turnrate

	pipuck_set_velocity(left, right)
end

--[[
--	builderbot api
--]]

require("commonAPI")

function builderbot_set_velocity(x, y)
	local max = 0.2
	if x < -max then x = -max end
	if x >  max then x =  max end
	if y < -max then y = -max end
	if y >  max then y =  max end
	robot.differential_drive.set_target_velocity(x, -y) 
end

function builderbot_move(transV3, rotateV3)
	local left = transV3.x * 0.2
	local right = transV3.x * 0.2
	local turnrate = 0.5

	--left  = left  - transV3.y/transV3.x * turnrate
	--right = right + transV3.y/transV3.x * turnrate

	left  = left  - transV3.y * turnrate
	right = right + transV3.y * turnrate

	builderbot_set_velocity(left, right)
end


------------------------------------------------------
function linkBuilderbotInterface(VNS)
	VNS.Driver.move = function(transV3, rotateV3)
		builderbot_move(transV3, rotateV3)
	end
	linkCommonRobotInterface(VNS)
end


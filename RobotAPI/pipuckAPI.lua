--[[
--	pipuck api
--]]

require("commonAPI")

function pipuck_set_velocity(x, y)
	local max = 0.1
	if x < -max then x = -max end
	if x >  max then x =  max end
	if y < -max then y = -max end
	if y >  max then y =  max end
	robot.differential_drive.set_target_velocity(x, -y) 
end

function pipuck_move(transV3, rotateV3)
	local scaleN = tonumber(robot.params.move_scale or 0.25)
	local forward = transV3.x * scaleN

	local mem = forward

	local angle = math.atan(transV3.y / transV3.x) * 180 / math.pi
	local forward_threshold = 89
	--local forward_threshold = 30
	if angle > forward_threshold or angle < -forward_threshold then mem = 0 forward = 0 end

	local smalllimit = 0.03
	if 0 <= forward and forward < smalllimit then forward = smalllimit end
	if 0 > forward and forward >-smalllimit then forward =-smalllimit end

	local turnrate = transV3.y/forward * 0.01
	forward = mem

	pipuck_set_velocity(forward - turnrate, forward + turnrate)
end


------------------------------------------------------
function linkPipuckInterface(VNS)
	VNS.Driver.move = function(transV3, rotateV3)
		pipuck_move(transV3, rotateV3)
	end
	linkCommonRobotInterface(VNS)
end


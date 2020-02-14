--[[
--	drone api
--]]

require("commonAPI")

function drone_check_height(z)
	if robot.flight_system.position.z - 1.5 > 0.01 or 
	   robot.flight_system.position.z - 1.5 < -0.01 then 
		return false
	else
		return true
	end
end

function drone_set_height(z)
	local new_target = robot.flight_system.position
	local rad = robot.flight_system.orientation.z
	new_target.z = 1.5
	robot.flight_system.set_targets(new_target, rad)
end

function drone_set_speed(x, y, z, th)
	local rad = robot.flight_system.orientation.z
	local q = quaternion(rad, vector3(0,0,1))

	robot.flight_system.set_targets(
		robot.flight_system.position + vector3(x * time_step,y * time_step,z * time_step):rotate(q),
		rad + th * time_step
	)
end

function drone_move(transV3, rotateV3)
	local scaleN = 1.5
	local x = transV3.x * scaleN
	local y = transV3.y * scaleN
	local w = rotateV3:length()
	if rotateV3.z < 0 then w = -w end
	drone_set_speed(x, y, 0, w)
end

function drone_enable_cameras()
	for index, camera in ipairs(robot.cameras_system) do
		camera.enable()
	end 
end

function drone_detect_tags()
	local drone_offset = (quaternion(robot.flight_system.orientation.x, vector3(1,0,0)) *
	                     quaternion(robot.flight_system.orientation.y, vector3(0,1,0))):inverse()
	tags = {}
	index = {}
	for _, camera in ipairs(robot.cameras_system) do
		for _, tag in ipairs(camera.tags) do
			-- check existed
			if index[tag.id] == nil then
				index[tag.id] = true
				local robotTypeS
				if 0 <= tag.id and tag.id < 20 then robotTypeS = "pipuck"
				elseif 20 <= tag.id and tag.id < 40 then robotTypeS = "builderbot"
				end
				DMSG(tag.id)
				tags[#tags + 1] = {
					--idS = "pipuck" .. math.floor(tag.id),
					idS = robotTypeS .. math.floor(tag.id),
					positionV3 = (camera.transform.position + 
					              vector3(tag.position):rotate(camera.transform.orientation)
								 ):rotate(drone_offset),
					orientationQ = drone_offset * camera.transform.orientation * tag.orientation
				}
			end
		end
	end

	return tags
end

function drone_clear_seenRobots(seenRobots)
	for i, v in pairs(seenRobots) do
		seenRobots[i] = nil
	end
end

function drone_add_seenRobots(seenRobots, tags)
	for i, v in ipairs(tags) do
		seenRobots[v.idS] = v
		seenRobots[v.idS].robotTypeS = "pipuck"
	end
end

------------------------------------------------------
function linkDroneInterface(VNS)
	VNS.Driver.move = function(transV3, rotateV3)
		drone_move(transV3, rotateV3)
	end
	linkCommonRobotInterface(VNS)
end


--[[
--	drone api
--]]

local api = require("commonAPI")

---- actuator --------------------------
-- idealy, I would like to use robot.flight_system.set_targets only once per step
-- newPosition and newRad are recorded, and enforced at last in dronePostStep
api.actuator = {}
api.actuator.newPosition = robot.flight_system.position
api.actuator.newRad = robot.flight_system.orientation.z
function api.actuator.setNewLocation(locationV3, rad)
	api.actuator.newPosition = locationV3
	api.actuator.newRad = rad
end

---- Step Function ---------------------
function api.init()
	api.droneEnableCameras()
end

--function api.preStep() api.preStep() end

api.commonPostStep = api.postStep
function api.postStep()
	robot.flight_system.set_targets(api.actuator.newPosition, api.actuator.newRad)
	api.commonPostStep()
end

---- Height control --------------------
function api.droneCheckHeight(z)
	if robot.flight_system.position.z - z > 0.01 or 
	   robot.flight_system.position.z - z < -0.01 or
	   api.actuator.newPosition.z - z > 0.01 or
	   api.actuator.newPosition.z - z < -0.01 then 
		return false
	else
		return true
	end
end

function api.droneSetHeight(z)
	api.actuator.newPosition.z = z
end

function api.droneMaintainHeight(z)
	if api.droneCheckHeight(z) == false then
		api.droneSetHeight(z)
	end
end

---- speed control --------------------
-- everything in robot hardware's coordinate frame
function api.droneSetSpeed(x, y, z, th)
	-- x, y, z in m/s, x front, z up, y left
	-- th in rad/s, counter-clockwise positive
	local rad = robot.flight_system.orientation.z
	local q = quaternion(rad, vector3(0,0,1))

	-- tune these scalars to make x,y,z,th match m/s and rad/s
		-- 6 and 0.5 are roughly calibrated for simulation
	local transScalar = 6 
	local rotateScalar = 0.5

	x = x * transScalar * api.time.period
	y = y * transScalar * api.time.period
	z = z * transScalar * api.time.period
	th = th * rotateScalar * api.time.period

	api.actuator.setNewLocation(
		vector3(x,y,z):rotate(q) + robot.flight_system.position,
		rad + th
	)
end

api.setSpeed = api.droneSetSpeed
--api.move is implemented in commonAPI

---- Cameras -------------------------
function api.droneEnableCameras()
	for index, camera in ipairs(robot.cameras_system) do
		camera.enable()
	end 
end

function api.droneDetectLeds()
	-- takes tags in camera_frame_reference
	local led_dis = 0.02 -- distance between leds to the center
	local led_loc_for_tag = {
	vector3(led_dis, 0, 0),
	vector3(0, led_dis, 0),
	vector3(-led_dis, 0, 0),
	vector3(0, -led_dis, 0)
	} -- start from x+ , counter-closewise

	for _, camera in ipairs(robot.cameras_system) do
		for _, tag in ipairs(camera.tags) do
			tag.type = 0
			for j, led_loc in ipairs(led_loc_for_tag) do
				local led_loc_for_camera = vector3(led_loc):rotate(tag.orientation) + tag.position
				local color_number = camera.detect_led(led_loc_for_camera)
				if color_number ~= tag.type and color_number ~= 0 then
					tag.type = color_number
				end
			end
		end
	end
end

function api.droneDetectTags()
	-- This function returns a tags table, in real robot coordinate frame
	api.droneDetectLeds()
	-- when drone is tilting, we assuming the drone is still levelint out
	local drone_offset = (quaternion(robot.flight_system.orientation.x, vector3(1,0,0)) *
	                     quaternion(robot.flight_system.orientation.y, vector3(0,1,0))):inverse()

	-- add tags 
	tags = {}
	for _, camera in ipairs(robot.cameras_system) do
		for _, newTag in ipairs(camera.tags) do
			local positionV3 = 
			  (
			    camera.transform.position + 
			    vector3(newTag.position):rotate(camera.transform.orientation)
			  ):rotate(drone_offset)

			local orientationQ = 
				drone_offset * 
				camera.transform.orientation * 
				newTag.orientation

			-- check existed
			local flag = 0
			for i, existTag in ipairs(tags) do
				if (existTag.positionV3 - positionV3):length() < 0.02 then
					flag = 1
					break
				end
			end

			if flag == 0 then
				tags[#tags + 1] = {
					--idS = "pipuck" .. math.floor(tag.id),
					--idS = robotTypeS .. math.floor(tag.id),
					id = newTag.id,
					type = newTag.type,
					positionV3 = positionV3,
					orientationQ = orientationQ
				}
			end
		end
	end

	return tags
end

function api.droneAddSeenRobots(tags, seenRobotsInRealFrame)
	-- this function adds robots (in real frame) from seen tags (in real robot frames)
	local robotTypeIndex = {
		{index = 0, typeS = "block"},
		{index = 40, typeS = "pipuck"},
		{index = 60, typeS = "builderbot"},
	}

	for i, tag in ipairs(tags) do
		local robotTypeS = nil
		for i, item in ipairs(robotTypeIndex) do
			if tag.id <= item.index then robotTypeS = item.typeS break end
		end

		if robotTypeS ~= nil then
			local idS = robotTypeS .. math.floor(tag.id)
			--[[
			seenRobots[idS] = {
				idS = idS,
				robotTypeS = robotTypeS,
				positionV3 = api.virtualFrame.V3_RtoV(tag.positionV3),
				orientationQ = api.virtualFrame.Q_RtoV(tag.orientationQ),
				-- RtoV : from real coordinate frame to virtual frame
			}
			--]]
			seenRobotsInRealFrame[idS] = {
				idS = idS,
				robotTypeS = robotTypeS,
				positionV3 = tag.positionV3,
				orientationQ = tag.orientationQ,
			}
		end
	end
end

--[[
function drone_add_obstacles(obstacles, tags) -- tags is an array of R

	for i, v in pairs(obstacles) do
		obstacles[i] = nil
	end
	for i, tag in ipairs(tags) do
		if tag.robotTypeS == "block" then
			obstacles[#obstacles + 1] = tag
		end
	end
end
--]]

------------------------------------------------------
--[[
function api.linkDroneInterface(VNS)
	VNS.Driver.move = function(transV3, rotateV3)
		drone_move(transV3, rotateV3)
	end
	api.linkCommonRobotInterface(VNS)
end
--]]
return api

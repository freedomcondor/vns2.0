--[[
--	pipuck api
--]]

local api = require("commonAPI")

---- actuator --------------------------
api.actuator = {}
-- idealy, I would like to use robot.diff_drive.set_t_velocity only once per step
-- newLeft and newRight are recorded, and enforced at last in dronePostStep
api.actuator = {}
api.actuator.newLeft = 0
api.actuator.newRight = 0
function api.actuator.setNewWheelSpeed(x, y)
	api.actuator.newLeft = x
	api.actuator.newRight = y
end

---- Step Function ---------------------
--function api.preStep() api.preStep() end

api.commonPostStep = api.postStep
function api.postStep()
	robot.differential_drive.set_target_velocity(
		api.actuator.newLeft, 
		-api.actuator.newRight
	)
	api.commonPostStep()
end

---- speed control --------------------
-- everything in robot hardware's coordinate frame
function api.pipuckSetWheelSpeed(x, y)
	-- x, y in m/s
	-- the scalar is to make x,y match m/s
	local scalar = 1
	api.actuator.setNewWheelSpeed(x * scalar, y * scalar)
end

function api.pipuckSetRotationSpeed(x, th)
	-- x, in m/s, x front,
	-- th in rad/s, counter-clockwise positive
	local scalar = 0.23
	local aug = scalar * th
	api.pipuckSetWheelSpeed(x - aug, x + aug)
end

function api.pipuckSetSpeed(x, y)
	local th = math.atan(y/x)
	if x == 0 and y == 0 then th = 0 end
	local limit = math.pi / 50
	if th > limit then th = limit
	elseif th < -limit then th = -limit end
	api.pipuckSetRotationSpeed(x, th)
end

api.setSpeed = api.pipuckSetSpeed
--api.move is implemented in commonAPI

------------------------------------------------------
--[[
function api.linkPipuckInterface(VNS)
	VNS.Driver.move = function(transV3, rotateV3)
		pipuck_move(transV3, rotateV3)
	end
	api.linkCommonRobotInterface(VNS)
end
--]]

return api

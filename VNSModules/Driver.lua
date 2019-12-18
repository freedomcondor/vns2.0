-- Driver --------------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local Driver = {VNSMODULECLASS = true}
Driver.__index = Driver

function Driver:new()
	local instance = {}
	setmetatable(instance, self)
	instance.lastReceivedSpeed = {
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}
	return instance
end

function Driver:deleteParent(vns)
	self.lastReceivedSpeed = {
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}
end

function Driver:run(vns, paraT)
	-- listen to drive from parent
	local chillRate = 0.1
	self.lastReceivedSpeed.locV3 = self.lastReceivedSpeed.locV3 * chillRate
	self.lastReceivedSpeed.dirV3 = self.lastReceivedSpeed.dirV3 * chillRate
	for _, msgM in pairs(vns.Msg.getAM(vns.parentS, "drive")) do
		-- a drive message data is:
		--	{	yourLocV3, yourDirQ,
		--		transV3, rotateV3
		--	}
		
		msgM.dataT.transV3 = vns.Msg.recoverV3(msgM.dataT.transV3)
		msgM.dataT.rotateV3 = vns.Msg.recoverV3(msgM.dataT.rotateV3)
		msgM.dataT.yourLocV3 = vns.Msg.recoverV3(msgM.dataT.yourLocV3)
		msgM.dataT.yourDirQ = vns.Msg.recoverQ(msgM.dataT.yourDirQ)

		local transV3 = Linar.mySpeedToYou(
			msgM.dataT.transV3,
			msgM.dataT.yourDirQ
		)
		local rotateV3 = Linar.mySpeedToYou(
			msgM.dataT.rotateV3,
			msgM.dataT.yourDirQ
		)

		self.lastReceivedSpeed.locV3 = transV3
		self.lastReceivedSpeed.dirV3 = rotateV3 
	end

	local transV3 = self.lastReceivedSpeed.locV3
	local rotateV3 = self.lastReceivedSpeed.dirV3

	-- add emergency speed
	if vns.emergencySpeed ~= nil then
		local scalar = 1
		--transV3 = (transV3 + vns.emergencySpeed.locV3 * scalar):nor()
		--rotateV3 = (rotateV3 + vns.emergencySpeed.dirV3 * scalar):nor()
		transV3 = transV3 + vns.emergencySpeed.locV3 * scalar
		rotateV3 = rotateV3 + vns.emergencySpeed.dirV3 * scalar
	end

	-- add random speed
	if vns.randomWalkerSpeed ~= nil then
		local scalar = 1
		transV3 = transV3 + vns.randomWalkerSpeed.locV3 * scalar
		rotateV3 = rotateV3 + vns.randomWalkerSpeed.dirV3 * scalar
	end
	vns.move(transV3, rotateV3)

	-- send drive to children
	for _, robotVns in pairs(vns.childrenTVns) do
		if robotVns.rallyPoint == nil then 
			robotVns.rallyPoint = {
				locV3 = Vec3:create(),
				dirQ = Quaternion:create(),
			}
		end

		--print("childID", robotVns.idS)
		--print("childLocation", robotVns.locV3)
		--local ang = robotVns.dirQ:getAng()
		--if robotVns.dirQ:getAxis().z < 0 then ang = -ang end
		--print("childQuaternion", ang*180/math.pi)

		-- calc speed
		local totalTransV3, totalRotateV3

		-- add rallypointspeed
		local rallypointScalar = 2
		local dV3 = robotVns.rallyPoint.locV3 - robotVns.locV3
		local d = dV3:len()
		local rallypointTransV3 = rallypointScalar / d * dV3:nor()

		local rotateQ = robotVns.dirQ:inv() * robotVns.rallyPoint.dirQ
		local ang = rotateQ:getAng()
		if ang > math.pi then ang = ang - math.pi * 2 end
		local rallypointRotateV3 = rotateQ:getAxis() * ang

		if d < 30 then rallypointTransV3 = Vec3:create() end
		if rallypointRotateV3:len() < math.pi/12 then rallypointRotateV3 = Vec3:create() end

		totalTransV3 = rallypointTransV3
		totalRotateV3 = rallypointRotateV3

		local timestep = 1 / 50
		-- add parent speed
		local parentScalar = 0
		totalTransV3 = totalTransV3 + (transV3+rotateV3*robotVns.locV3) * timestep * parentScalar
		totalRotateV3 = totalRotateV3 + rotateV3 * timestep * parentScalar

		-- add obstacle avoidence
		local avoiderScalar = 15
		if robotVns.avoiderSpeed ~= nil then
		totalTransV3 = totalTransV3 + robotVns.avoiderSpeed.locV3 * avoiderScalar
		totalRotateV3 = totalRotateV3 + robotVns.avoiderSpeed.dirV3 * avoiderScalar

			-- clear avoiderspeed
		robotVns.avoiderSpeed.locV3 = Vec3:create()
		end
		
		-- send drive cmd
		vns.Msg.send(robotVns.idS, "drive",
			{	yourLocV3 = robotVns.locV3,
				yourDirQ = robotVns.dirQ,
				--transV3 = childTransV3,
				--rotateV3 = childRotateV3,
				transV3 = totalTransV3:nor(),
				rotateV3 = totalRotateV3:nor(),
			}
		)
	end
	--for each children
	--fly to rally point
end

function Driver:move(transV3, rotateV3)
	print("VNS.Modules.Driver.move needs to be implemented")
end

return Driver


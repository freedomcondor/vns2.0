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
	return instance
end

function Driver:run(vns, paraT)
	-- listen to drive from parent
	local transV3 = Vec3:create() 
	local rotateV3 = Vec3:create()
	for _, msgM in pairs(vns.Msg.getAM(vns.parentS, "drive")) do
		-- a drive message data is:
		--	{	yourLocV3, yourDirQ,
		--		transV3, rotateV3
		--	}
		
		msgM.dataT.transV3 = vns.Msg.recoverV3(msgM.dataT.transV3)
		msgM.dataT.rotateV3 = vns.Msg.recoverV3(msgM.dataT.rotateV3)
		msgM.dataT.yourLocV3 = vns.Msg.recoverV3(msgM.dataT.yourLocV3)
		msgM.dataT.yourDirQ = vns.Msg.recoverQ(msgM.dataT.yourDirQ)

		transV3 = Linar.mySpeedToYou(
			msgM.dataT.transV3,
			msgM.dataT.yourDirQ
		)
		rotateV3 = Linar.mySpeedToYou(
			msgM.dataT.rotateV3,
			msgM.dataT.yourDirQ
		)

		vns.move(transV3, rotateV3)
	end

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
		local timestep = 1 / 50
		local childTransV3 =  robotVns.rallyPoint.locV3 
		                    + (transV3 + rotateV3 * robotVns.locV3) * timestep
		                    - robotVns.locV3
		if childTransV3:len() < 30 then childTransV3 = Vec3:create()
		                           else childTransV3 = childTransV3:nor() end
		local childRotateQ = robotVns.rallyPoint.dirQ 
		                    * Quaternion:create(rotateV3.x,
		                                        rotateV3.y,
		                                        rotateV3.z,
		                                        rotateV3:len() * timestep)
		                    * robotVns.dirQ:inv()
		local ang = childRotateQ:getAng()
		if ang > math.pi then ang = ang - math.pi * 2 end
		local childRotateV3 = (childRotateQ:getAxis() * ang):nor()
		if childRotateV3:len() < math.pi/12 then childRotateV3 = Vec3:create()
		                           			else childRotateV3 = childRotateV3:nor() end
		--]]

		-- add parent move offset		-- TODO: may cause loop accumulate
		--[[
		childTransV3 = (childTransV3 + (transV3 + rotateV3 * robotVns.locV3) * 0.2):nor()
		childRotateV3 = (childRotateV3 + rotateV3 * 0.2):nor()
		--]]

		vns.Msg.send(robotVns.idS, "drive",
			{	yourLocV3 = robotVns.locV3,
				yourDirQ = robotVns.dirQ,
				transV3 = childTransV3,
				rotateV3 = childRotateV3,
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


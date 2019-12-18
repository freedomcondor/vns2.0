-- Predator Avoider --------------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local PrAvoider = {VNSMODULECLASS = true}
PrAvoider.__index = PrAvoider

function PrAvoider:new()
	local instance = {}
	setmetatable(instance, self)
	instance.currentSpeed = {
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}
	return instance
end

function PrAvoider:run(vns, paraT)
	if vns.emergencySpeed == nil then
		vns.emergencySpeed = {
			locV3 = Vec3:create(),
			dirV3 = Vec3:create(),
		}
	end

	local chillRate = 0.1
	self.currentSpeed.locV3 = self.currentSpeed.locV3 * chillRate
	self.currentSpeed.dirV3 = self.currentSpeed.dirV3 * chillRate

	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "emergency")) do
		if vns.childrenTVns[msgM.fromS] ~= nil or 
		   vns.parentS == msgM.fromS then -- else continue

		local transV3 = vns.Msg.recoverV3(msgM.dataT.transV3)
		local rotateV3 = vns.Msg.recoverV3(msgM.dataT.rotateV3)
		local yourLocV3 = vns.Msg.recoverV3(msgM.dataT.yourLocV3)
		local yourDirQ = vns.Msg.recoverQ(msgM.dataT.yourDirQ)

		if vns.childrenTVns[msgM.fromS] ~= nil then
			transV3 = vns.childrenTVns[msgM.fromS].dirQ:toRotate(transV3)
			rotateV3 = vns.childrenTVns[msgM.fromS].dirQ:toRotate(rotateV3)
		elseif vns.parentS == msgM.fromS then
			transV3 = Linar.mySpeedToYou(transV3, yourDirQ)
			rotateV3 = Linar.mySpeedToYou(rotateV3, yourDirQ)
		end
	
		-- add to currentSpeed
		self.currentSpeed.locV3 = self.currentSpeed.locV3 + transV3
		self.currentSpeed.dirV3 = self.currentSpeed.dirV3 + rotateV3
		
		-- message from children, send to parent
		if vns.childrenTVns[msgM.fromS] ~= nil then
			if vns.parentS ~= nil then
				vns.Msg.send(vns.parentS, "emergency", {
					transV3 = transV3, rotateV3 = rotateV3,
				})
			end
		end

		for idS, childVns in pairs(vns.childrenTVns) do
			if idS ~= msgM.fromS then
				vns.Msg.send(idS, "emergency", {
					transV3 = transV3, rotateV3 = rotateV3,
					yourLocV3 = childVns.locV3,
					yourDirQ = childVns.dirQ,
				})
			end
		end
	end end

	-- check boxes
	if paraT.predatorsTR ~= nil then
		local stimulateSpeed = {
			locV3 = Vec3:create(),
			dirV3 = Vec3:create(),
		}

		for i, predatorR in ipairs(paraT.predatorsTR) do
			stimulateSpeed.locV3 = 
			PrAvoider.add(predatorR.locV3, predatorR.dirQ,
			              stimulateSpeed.locV3,
			              60)
		end

		if stimulateSpeed.locV3:len() ~= 0 then
			if vns.parentS ~= nil then
				vns.Msg.send(vns.parentS, "emergency", {
					transV3 = stimulateSpeed.locV3, rotateV3 = Vec3:create(),
				})
			end
			for idS, childVns in pairs(vns.childrenTVns) do
				vns.Msg.send(idS, "emergency", {
					transV3 = stimulateSpeed.locV3, rotateV3 = Vec3:create(),
					yourLocV3 = childVns.locV3,
					yourDirQ = childVns.dirQ,
				})
			end
			self.currentSpeed.locV3 = self.currentSpeed.locV3 + stimulateSpeed.locV3
		end
	end

	vns.emergencySpeed = self.currentSpeed
end

function PrAvoider.add(locV3, dirQ, accumulateV3, threshold)
	local force = -locV3:nor()
	accumulateV3 = accumulateV3 + force
	return accumulateV3
end

return PrAvoider

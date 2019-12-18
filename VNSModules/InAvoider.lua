-- Inner Avoider --------------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local InAvoider = {VNSMODULECLASS = true}
InAvoider.__index = InAvoider

function InAvoider:new()
	local instance = {}
	setmetatable(instance, self)
	instance.parentLocV3 = Vec3:create()
	return instance
end

function InAvoider:deleteParent(vns)
	self.parentLocV3 = Vec3:create()
end

function InAvoider:run(vns, paraT)
	-- update parentLoc by drive message
	if vns.parentS ~= nil then
		for _,msgM in ipairs(vns.Msg.getAM(vns.parentS, "drive")) do
			local yourLocV3 = vns.Msg.recoverV3(msgM.dataT.yourLocV3)
			local yourDirQ = vns.Msg.recoverQ(msgM.dataT.yourDirQ)
			self.parentLocV3 = Linar.myVecToYou(Vec3:create(), yourLocV3, yourDirQ)
			break
		end
	else
		self.parentLocV3 = Vec3:create()
	end

	-- for each children avoid
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.avoiderSpeed == nil then
			childVns.avoiderSpeed = {
				locV3 = Vec3:create(),
				dirV3 = Vec3:create(),
			}
		end
		--childVns.avoiderSpeed.locV3 = Vec3:create()

		if childVns.robotType == "quadcopter" then
			-- avoid my parent
			childVns.avoiderSpeed.locV3 =
				InAvoider.add(childVns.locV3, self.parentLocV3, Quaternion:create(),
				            childVns.avoiderSpeed.locV3,
				            60)

			-- avoid my self
			childVns.avoiderSpeed.locV3 =
				InAvoider.add(childVns.locV3, Vec3:create(), Quaternion:create(),
				            childVns.avoiderSpeed.locV3,
				            60)

			-- avoid children
			for jidS, jchildVns in pairs(vns.childrenTVns) do
				if jchildVns.robotType == childVns.robotType then -- else continue
				if idS ~= jidS then -- else continue
	
				childVns.avoiderSpeed.locV3 =
					InAvoider.add(childVns.locV3, jchildVns.locV3, jchildVns.dirQ,
					            childVns.avoiderSpeed.locV3,
					            60)
			end end end
		end

		if childVns.robotType == "vehicle" then
			for jidS, robotR in pairs(paraT.vehiclesTR) do
				if jidS ~= idS then
					childVns.avoiderSpeed.locV3 =
						InAvoider.add(childVns.locV3, robotR.locV3, robotR.dirQ,
						            childVns.avoiderSpeed.locV3,
						            60)
				end
			end
		end
	end
end

function InAvoider.add(myLocV3, obLocV3, obDirQ, accumulatorV3, threshold)
	local dV3 = myLocV3 - obLocV3
	local d = dV3:len()
	if d == 0 then return accumulatorV3 end
	local ans = accumulatorV3
	if d < threshold then
		local transV3 = 0.2 / d * dV3:nor()
		local rotatedDV3 = Linar.myVecToYou(dV3, obLocV3, obDirQ)
		local roundV3 = 2 / d * dV3:nor()
		local q
		if rotatedDV3.x < 0 then
			q = Quaternion:create(0, 0, 1, math.pi/4) --* d/threshold)
		else
			q = Quaternion:create(0, 0, 1, math.pi/4) --* d/threshold)
		end
		ans = ans + transV3 + q:toRotate(roundV3)
	end

	return ans
end

return InAvoider


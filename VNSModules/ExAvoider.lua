-- External Avoider --------------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local ExAvoider = {VNSMODULECLASS = true}
ExAvoider.__index = ExAvoider

function ExAvoider:new()
	local instance = {}
	setmetatable(instance, self)
	return instance
end

function ExAvoider:run(vns, paraT)
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.avoiderSpeed == nil then
			childVns.avoiderSpeed = {
				locV3 = Vec3:create(),
				dirV3 = Vec3:create(),
			}
		end
		if childVns.robotType == "vehicle" then
			for i, boxR in ipairs(paraT.boxesTR) do
				childVns.avoiderSpeed.locV3 =
					ExAvoider.add(childVns.locV3, boxR.locV3, Quaternion:create(),
					              childVns.avoiderSpeed.locV3,
					              60)
			end
		end
	end
end

function ExAvoider.add(myLocV3, obLocV3, obDirQ, accumulatorV3, threshold)
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

return ExAvoider


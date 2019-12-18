-- Random Walker--------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local RandomWalker = {VNSMODULECLASS = true}
RandomWalker.__index = RandomWalker

function RandomWalker:new()
	local instance = {}
	setmetatable(instance, self)
	return instance
end

function RandomWalker:run(vns)
	-- work only no parent
	if vns.parentS ~= nil then 
		vns.randomWalkerSpeed = nil
		return 
	end

	--local x = math.random() - 0.5
	local x = math.random()
	local y = math.random() - 0.5
	local z = 0
	local transV3 = Vec3:create(x,y,z):nor() * 0.5

	x = 0
	y = 0 
	z = math.random() - 0.5
	--local rotateV3 = Vec3:create(x,y,z):nor() * 1.5
	local rotateV3 = Vec3:create(x,y,z):nor() * 0.5

	--vns.move(transV3, rotateV3)
	vns.randomWalkerSpeed = {
		locV3 = transV3,
		dirV3 = rotateV3,
	}
end

return RandomWalker

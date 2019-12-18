-- Shift Up ShiftUpper -------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")
local Maintainer = require("Maintainer")

local ShiftUpper = {VNSMODULECLASS = true}
setmetatable(ShiftUpper, Maintainer)
ShiftUpper.__index = ShiftUpper

function ShiftUpper:new()
	local instance = Maintainer:new()
	setmetatable(instance, self)
	return instance
end

function ShiftUpper:run(vns)
	Maintainer.run(self, vns)

	-- more children give to parent
	for idS, childVns in pairs(vns.childrenTVns) do
		if self.allocated[idS] == nil then
			self:assign(idS, vns.parentS, vns)
		end
	end
end

return ShiftUpper

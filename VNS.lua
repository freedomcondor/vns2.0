------------------------------------------------------
--	Weixu Zhu, Tutti mi chiamano Harry.
--		zhuweixu_harry@126.com
--
--	Version 2.0:
--		rearrange everything, try modular
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Msg = require("Message")
local Linar = require("Linar")

local Modules = {}
Modules.VehicleConnector = require("VehicleConnector")
Modules.QuadcopterConnector = require("QuadcopterConnector")
Modules.ParentWaitor = require("ParentWaitor")
Modules.ParentWaitorDeny = require("ParentWaitorDeny")
Modules.LostCounter = require("LostCounter")
Modules.RandomWalker = require("RandomWalker")
Modules.Assigner = require("Assigner")
Modules.Maintainer = require("Maintainer")
Modules.ShiftUpper = require("ShiftUpper")
Modules.Shifter = require("Shifter")
Modules.InAvoider = require("InAvoider")
Modules.ExAvoider = require("ExAvoider")
Modules.PrAvoider = require("PrAvoider")
Modules.Driver = require("Driver")

local VNS = {VNSCLASS = true}
VNS.__index = VNS

VNS.Modules = Modules
VNS.Msg = Msg

function VNS:new(option)
	return self:create(option)
end

function VNS:create(option)
	local instance = {}
	setmetatable(instance, self)

	instance.idS = option.idS
	instance.brainS = instance.idS
	instance.locV3 = option.locV3 or Vec3:create()
	instance.dirQ = option.dirQ or Quaternion:create()
	instance.parentS = nil
	instance.robotType = option.robotType

	instance.childrenTVns = {}

	instance.modules = {}
	for i, ModuleM in ipairs(self.EnableModules) do
		instance.modules[i] = ModuleM:new()
	end

	-- implicit module value: 
	--[[
	instance.rallyPoint = {	
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
	}
		-- used by driver module
	
	instance.avoiderSpeed = {
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}
		-- used by driver and avoider module
	
	instance.emergencySpeed = {
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}
		-- used by driver and preditor avoider module

	instance.updated
		-- used by connector and lostcount module

	instance.myAssignParent = nil
		-- used by Assigner
	--]]

	return instance
end

function VNS:reset()
	self.locV3 = Vec3:create()
	self.dirQ = Quaternion:create()

	self.rallyPoint = {	
		-- used by driver module
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
	}

	self.avoiderSpeed= {	
		-- used by driver module
		locV3 = Vec3:create(),
		dirV3 = Vec3:create(),
	}

	self:deleteParent()
	for idS, _ in pairs(self.childrenTVns) do
		self:deleteChild(idS)
	end

	for i, moduleM in pairs(self.modules) do
		if type(moduleM.reset) == "function" then 
			moduleM:reset(self) 
		end
	end
end

function VNS:run(paraT)
	self.Msg.prestep()
	for i, moduleM in ipairs(self.modules) do
		moduleM:run(self, paraT)
	end
end

function VNS:deleteChild(idS)
	for i, moduleM in pairs(self.modules) do
		if type(moduleM.deleteChild) == "function" then 
			moduleM:deleteChild(idS)
		end
	end
	self.childrenTVns[idS] = nil
end

function VNS:deleteParent()
	if self.parentS == nil then return end
	for i, moduleM in pairs(self.modules) do
		if type(moduleM.deleteParent) == "function" then 
			moduleM:deleteParent(self)
		end
	end
	self.parentS = nil
end

function VNS.move()
	print("VNS.move need to be implemented")
end

return VNS

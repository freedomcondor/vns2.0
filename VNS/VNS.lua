local VNS = {VNSCLASS = true}
VNS.__index = VNS

VNS.Msg = require("Message")

VNS.Connector = require("Connector")
VNS.DroneConnector = require("DroneConnector")
VNS.PipuckConnector = require("PipuckConnector")

VNS.Assigner = require("Assigner")
--VNS.Allocator = require("Allocator")
VNS.Allocator = require("Allocator")
VNS.ScaleManager = require("ScaleManager")
VNS.Avoider = require("Avoider")
VNS.Spreader = require("Spreader")
VNS.Driver= require("Driver")

VNS.Modules = {
	VNS.DroneConnector,
	VNS.PipuckConnector,
	VNS.Connector,

	VNS.ScaleManager,

	VNS.Assigner,
	VNS.Allocator,
	VNS.Avoider,
	VNS.Spreader,
	VNS.Driver,
}

--[[
--	vns = {
--		idS
--		brainS
--		robotTypeS
--		scale
--		
--		parentR
--		childrenRT
--
--	}
--]]

function VNS.create(myType)

	-- a robot =  {
	--     idS,
	--     positionV3, 
	--     orientationQ,
	--     robotTypeS = "drone",
	-- }

	local vns = {
		idS = VNS.Msg.myIDS(),
		robotTypeS = myType,
	}
	setmetatable(vns, VNS)

	for i, module in ipairs(VNS.Modules) do
		if type(module.create) == "function" then
			module.create(vns)
		end
	end

	VNS.reset(vns)
	return vns
end

function VNS.reset(vns)
	vns.parentR = nil
	vns.brainS = VNS.Msg.myIDS()
	vns.childrenRT = {}

	for i, module in ipairs(VNS.Modules) do
		if type(module.reset) == "function" then
			module.reset(vns)
		end
	end
end

function VNS.prestep(vns)
	vns.Msg.prestep(vns)
	for i, module in ipairs(VNS.Modules) do
		if type(module.prestep) == "function" then
			module.prestep(vns)
		end
	end
end

function VNS.addChild(vns, robotR)
	for i, module in ipairs(VNS.Modules) do
		if type(module.addChild) == "function" then
			module.addChild(vns, robotR)
		end
	end
end
function VNS.deleteChild(vns, idS)
	for i, module in ipairs(VNS.Modules) do
		if type(module.deleteChild) == "function" then
			module.deleteChild(vns, idS)
		end
	end
end

function VNS.addParent(vns, robotR)
	for i, module in ipairs(VNS.Modules) do
		if type(module.addParent) == "function" then
			module.addParent(vns, robotR)
		end
	end
end
function VNS.deleteParent(vns)
	for i, module in ipairs(VNS.Modules) do
		if type(module.deleteParent) == "function" then
			module.deleteParent(vns)
		end
	end
end

function VNS.setGene(vns, morph)
	for i, module in ipairs(VNS.Modules) do
		if type(module.setGene) == "function" then
			module.setGene(vns, morph)
		end
	end
end

function VNS.create_vns_node_without_drive(vns)
	local pre_connector_node
	if vns.robotTypeS == "drone" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.DroneConnector.create_droneconnector_node(vns),
		}}
	elseif vns.robotTypeS == "pipuck" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
		}}
	elseif vns.robotTypeS == "builderbot" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
		}}
	end

	return 

	{type = "sequence", children = {
		pre_connector_node,
		vns.Connector.create_connector_node(vns),
		vns.ScaleManager.create_scalemanager_node(vns),
		vns.Assigner.create_assigner_node(vns),
		vns.Allocator.create_allocator_node(vns),
		vns.Avoider.create_avoider_node(vns),
		vns.Spreader.create_spreader_node(vns),
		--vns.Driver.create_driver_node(vns),
	},}

end

function VNS.create_vns_node_without_drive_without_ackAll(vns)
	local pre_connector_node
	if vns.robotTypeS == "drone" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.DroneConnector.create_droneconnector_node(vns),
		}}
	elseif vns.robotTypeS == "pipuck" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
		}}
	elseif vns.robotTypeS == "builderbot" then
		pre_connector_node = {
			type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
		}}
	end

	return 

	{type = "sequence", children = {
		pre_connector_node,
		vns.Connector.create_connector_node_without_ackAll(vns),
		vns.ScaleManager.create_scalemanager_node(vns),
		vns.Assigner.create_assigner_node(vns),
		vns.Allocator.create_allocator_node(vns),
		vns.Avoider.create_avoider_node(vns),
		vns.Spreader.create_spreader_node(vns),
		--vns.Driver.create_driver_node(vns),
	},}

end

function VNS.create_vns_node(vns)
	return { 
		type = "sequence", children = {
		vns.create_vns_node_without_drive(vns),
		vns.Driver.create_driver_node(vns),
	},}
end

function VNS.create_vns_node_without_ackAll(vns)
	return { 
		type = "sequence", children = {
		vns.create_vns_node_without_drive_without_ackAll(vns),
		vns.Driver.create_driver_node(vns),
	},}
end

return VNS

local VNS = {VNSCLASS = true}
VNS.__index = VNS

VNS.Msg = require("Message")
VNS.Connector = require("Connector")
VNS.DroneConnector = require("DroneConnector")
VNS.PipuckConnector = require("PipuckConnector")

function VNS.create(myType)

	-- a robot =  {
	--     idS,
	--     positionV3, 
	--     orientationQ,
	--     robotTypeS = "drone",
	-- }

	local vns = {
		idS = VNS.Msg.myIDS(),
		brainS = VNS.Msg.myIDS(),
		robotTypeS = myType,

		parentR = nil,
		childrenRT = {},
	}

	setmetatable(vns, VNS)

	VNS.Connector.create(vns)
	return vns
end

function VNS.reset(vns)
	vns.parentR = nil
	vns.brainS = VNS.Msg.myIDS()
	vns.childrenRT = {}

	vns.Connector.reset(vns)
end

function VNS.prestep(vns)
	vns.Msg.prestep(vns)
	vns.Connector.prestep(vns)
end

function VNS.deleteChild(vns, idS)
	vns.Connector.deleteChild(vns, idS)
end

function VNS.deleteParent(vns)
	vns.Connector.deleteParent(vns)
end


function VNS.create_vns_node(vns)
	local connector_node
	if vns.robotTypeS == "drone" then
		connector_node = {
			type = "sequence", children = {
			VNS.DroneConnector.create_droneconnector_node(vns),
			--VNS.DDConnector.create_ddconnector_node(vns),
		}}
	elseif vns.robotTypeS == "pipuck" then
		connector_node = {
			type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
			--VNS.PPConnector.create_ppconnector_node(vns),
		}}
	end

	return 

	{type = "sequence", children = {
		connector_node,
	},}

end

return VNS

local VNS = {VNSCLASS = true}
VNS.__index = VNS

VNS.Msg = require("Message")
VNS.Connector = require("Connector")
VNS.DPConnector = require("DPConnector")
VNS.PDConnector = require("PDConnector")

function VNS.create(myType)
	local vns = {
		idS = VNS.Msg.myIDS(),
		parentS = nil,
		brainS = VNS.Msg.myIDS(),
		children = {},
		Msg = VNS.Msg,
		robotTypeS = myType,
	}

	setmetatable(vns, VNS)

	VNS.Connector.create(vns)
	return vns
end

function VNS.reset(vns)
	vns.parentS = nil
	vns.brainS = VNS.Msg.myIDS()
	vns.children = {}

	VNS.Connector.reset(vns)
end

function VNS.create_vns_node(vns)
	local connector_node
	if vns.robotTypeS == "drone" then
		connector_node = {
			type = "sequence", children = {
			VNS.DPConnector.create_dpconnector_node(vns),
			--VNS.DDConnector.create_ddconnector_node(vns),
		}}
	elseif vns.robotTypeS == "pipuck" then
		connector_node = {
			type = "sequence", children = {
			VNS.PDConnector.create_pdconnector_node(vns),
			--VNS.PPConnector.create_ppconnector_node(vns),
		}}
	end

	return 

	{type = "sequence", children = {
		connector_node,
	},}

end

return VNS

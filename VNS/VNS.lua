local VNS = {}

VNS.Msg = require("Message")
VNS.Connector = require("Connector")

function VNS.create()
	local vns = {
		parentS = nil,
		brainS = VNS.Msg.myIDS(),
		children = {},
		Msg = VNS.Msg
	}
	VNS.Connector.create(vns)
	return vns
end

function VNS.reset(vns)
	vns.parentS = nil
	vns.brainS = VNS.Msg.myIDS()
	vns.children = {}

	VNS.Connector.reset(vns)
end

function VNS.create_vns_node(vns, seenRobots)
	return 

	{type = "sequence", children = {
		VNS.Connector.create_connector_node(vns, seenRobots),
	},}

end

return VNS

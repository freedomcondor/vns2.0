local VNS = {}

VNS.Connector = require("Connector")

function VNS.create(idS)
	return {
		parentS = nil,
		brainS = idS,
		children = {},
	}
end

function VNS.create_vns_node(vns, seenRobots)
	return 

{type = "sequence", children = {
	VNS.Connector.create_connector_node(vns, seenRobots)
}}

end

return VNS

local ParentWaitor = {VNSMODULECLASS = true}
ParentWaitor.__index = ParentWaitor

function ParentWaitor:new()
	local instance = {}
	setmetatable(instance, self)
	return instance
end

function ParentWaitor:run(vns, paraT)
	if vns.parentS == nil then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			vns.parentS = msgM.fromS
			vns.Msg.send(msgM.fromS, "ack")
			break
		end
	end
end

return ParentWaitor

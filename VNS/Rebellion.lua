local Rebellion = {}

function Rebellion.rebel(vns)
	if vns.parentR ~= nil then
		vns.Msg.send(vns.parentR.idS, "rebel", {brainS = vns.brainS, scaleN = vns.scaleN})
	end
end

function Rebellion.step(vns)
	-- check rebel
	--TODO multiple rebel
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "rebel")) do
		if msgM.dataT.brainS == vns.brainS then
			vns.deleteChild(vns, msgM.fromS)
		elseif vns.childrenRT[msgM.fromS] ~= nil then
			-- tell other children we have a new brain
			vns.brainS = msgM.dataT.brainS
			for idS, robotR in pairs(vns.childrenRT) do
				if idS ~= msgM.fromS then
					vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS})
				end
			end

			-- put parent as child, send parent new rebel
			if vns.parentR ~= nil then
				vns.childrenRT[vns.parentR.idS] = vns.parentR
				vns.Msg.send(vns.parentR.idS, "rebel", {brainS = msgM.dataT.brainS, scaleN = msgM.dataT.scaleN})
			end

			-- set that child as parent
			vns.parentR = vns.childrenRT[msgM.fromS]
		end
	end
end

function Rebellion.getRebel(vns)
	if vns.parentR ~= nil then
		for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			if msgM.dataT.brainS ~= vns.brainS and msgM.dataT.scaleN > vns.scaleN then
				local robotR = {
					idS = msgM.fromS,
					positionV3 = 
						vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
					orientationQ = msgM.dataT.orientationQ:inverse(),
					robotTypeS = msgM.dataT.fromTypeS,
				}
				vns.addParent(vns, robotR)
				vns.Msg.send(msgM.fromS, "ack")
				vns.brainS = msgM.dataT.brainS
				vns.scaleN = msgM.dataT.scaleN

				for idS, robotR in pairs(vns.childrenRT) do
					vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS, scaleN = vns.scaleN})
				end

				Rebellion.rebel(vns)
				break
			end
		end
	end
end

function Rebellion.create_rebellion_node(vns)
	return function()
		Rebellion.step(vns)
		Rebellion.getRebel(vns)
	end
end

return Rebellion

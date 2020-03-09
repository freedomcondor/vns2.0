-- connector -----------------------------------------
------------------------------------------------------
local Connector = {}

--[[
	related data:
	vns.connector.waitingRobots = {}
	vns.connector.seenRobots
--]]

function Connector.create(vns)
	vns.connector = {}
	Connector.reset(vns)
end

function Connector.reset(vns)
	vns.connector.waitingRobots = {}
	vns.connector.seenRobots = {}
	vns.connector.brainSwitchCount = 0
end

function Connector.prestep(vns)
	vns.connector.seenRobots = {}
end

function Connector.recruit(vns, robotR)
	local numberN = math.random()

	local scaleN = 0
	if vns.scale ~= nil then scaleN = vns.scale:totalNumber() end

	vns.Msg.send(robotR.idS, "recruit", {	
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		fromTypeS = vns.robotTypeS,
		brainS = vns.brainS,
		scale = vns.scale,
		numberN = numberN,
	}) 

	vns.connector.waitingRobots[robotR.idS] = {
		numberN = numberN,
		idS = robotR.idS,
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		robotTypeS = robotR.robotTypeS,
		count = 0,
	}
end

function Connector.addChild(vns, robotR)
	vns.childrenRT[robotR.idS] = robotR
	vns.childrenRT[robotR.idS].updated = 0
end

function Connector.addParent(vns, robotR)
	vns.parentR = robotR
	vns.parentR.updated = 0
end

function Connector.deleteChild(vns, idS)
	vns.Msg.send(idS, "dismiss")
	vns.connector.waitingRobots[idS] = nil
	vns.childrenRT[idS] = nil
end

function Connector.deleteParent(vns)
	if vns.parentR == nil then return end
	vns.Msg.send(vns.parentR.idS, "dismiss")
	vns.parentR = nil
	Connector.changeBrain(vns, vns.idS)
end

function Connector.changeBrain(vns, newBrainS)
	if vns.brainS == newBrainS then return end

	vns.brainS = newBrainS

	local max = 0
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.scale:totalNumber() > max then
			max = robotR.scale:totalNumber()
		end
	end
	--vns.connector.brainSwitchCount = max + 2
	vns.connector.brainSwitchCount = 0

	for idS, robotR in pairs(vns.childrenRT) do
		vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS})
	end
	for idS, robotR in pairs(vns.connector.waitingRobots) do
		vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS})
	end
end

function Connector.update(vns)
	-- update waiting list
	for idS, robotR in pairs(vns.connector.seenRobots) do
		if vns.connector.waitingRobots[idS] ~= nil then
			vns.connector.waitingRobots[idS].positionV3 = robotR.positionV3
			vns.connector.waitingRobots[idS].orientationQ = robotR.orientationQ
		end
	end

	-- updated ++
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.updated = robotR.updated + 1
	end
	if vns.parentR ~= nil then
		vns.parentR.updated = vns.parentR.updated + 1
	end
	
	-- update vns childrenRT list
	for idS, robotR in pairs(vns.connector.seenRobots) do
		if vns.childrenRT[idS] ~= nil then
			vns.childrenRT[idS].positionV3 = robotR.positionV3
			vns.childrenRT[idS].orientationQ = robotR.orientationQ
			vns.childrenRT[idS].updated = 0
		end
	end

	-- update parent
	if vns.parentR ~= nil and vns.connector.seenRobots[vns.parentR.idS] ~= nil then
		vns.parentR.positionV3 = vns.connector.seenRobots[vns.parentR.idS].positionV3
		vns.parentR.orientationQ = vns.connector.seenRobots[vns.parentR.idS].orientationQ
		vns.parentR.updated = 0
	end

	-- check updated
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.updated == 3 then
			vns.deleteChild(vns, robotR.idS)
		end
	end
	if vns.parentR ~= nil and vns.parentR.updated == 3 then
		vns.deleteParent(vns)
	end
end

function Connector.brainSwitchCount(vns)
	if vns.connector.brainSwitchCount > 0 then
		vns.connector.brainSwitchCount = vns.connector.brainSwitchCount - 1
	end
end

function Connector.waitingCount(vns)
	for idS, robotR in pairs(vns.connector.waitingRobots) do
		robotR.count = robotR.count + 1
		if robotR.count == 3 then
			vns.connector.waitingRobots[idS] = nil
		end
	end
end

function Connector.step(vns)
	Connector.update(vns)
	Connector.waitingCount(vns)
	Connector.brainSwitchCount(vns)

	-- check ack
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "ack")) do
		if vns.connector.waitingRobots[msgM.fromS] ~= nil then
			vns.connector.waitingRobots[msgM.fromS].count = nil
			vns.connector.waitingRobots[msgM.fromS].numberN = nil
			vns.addChild(vns, vns.connector.waitingRobots[msgM.fromS])
			vns.connector.waitingRobots[msgM.fromS] = nil
		end
	end

	-- check dismiss
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "dismiss")) do
		if vns.parentR ~= nil and msgM.fromS == vns.parentR.idS then
			vns.deleteParent(vns)
		end
		if vns.childrenRT[msgM.fromS] ~= nil then
			vns.deleteChild(vns, msgM.fromS)
		end
	end

	-- check new brain
	for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "newBrain")) do
		if vns.parentR ~= nil and msgM.fromS == vns.parentR.idS then
			if vns.idS == msgM.dataT.newBrainS then
				vns.deleteParent(vns)
			else
				vns.Connector.changeBrain(vns, msgM.dataT.newBrainS)
			end
		end
	end

	-- valid check
	if vns.parentR ~= nil and vns.childrenRT[vns.parentR.idS] ~= nil then
		vns.deleteChild(vns, vns.parentR.idS)
		vns.deleteParent(vns)
	end
	-- check non parent commands
	for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "drive")) do
		if vns.parentR == nil or 
		   msgM.fromS ~= vns.parentR.idS then
			vns.Msg.send(msgM.fromS, "dismiss")
		end
	end
end

function Connector.recruitAll(vns)
	if vns.connector.brainSwitchCount ~= 0 then return end
	-- recruit new
	for idS, robotR in pairs(vns.connector.seenRobots) do
		if vns.childrenRT[idS] == nil and 
		   vns.connector.waitingRobots[idS] == nil and 
		   (vns.parentR == nil or vns.parentR.idS ~= idS) and
		   vns.brainS ~= idS then

			Connector.recruit(vns, robotR)
		end
	end
end

function Connector.ackAll(vns)
	if vns.parentR ~= nil then return end
	for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
	if vns.connector.brainSwitchCount == 0 and
	   msgM.dataT.brainS ~= vns.brainS and
	   msgM.dataT.brainS ~= vns.idS and
	   vns.childrenRT[msgM.fromS] == nil and
	   (
	      vns.ScaleManager.Scale:new(msgM.dataT.scale):totalNumber() > vns.scale:totalNumber() or
	      (
	         vns.ScaleManager.Scale:new(msgM.dataT.scale):totalNumber() == 
	                                                                   vns.scale:totalNumber() and
	         (
	            vns.connector.waitingRobots[msgM.fromS] == nil or
	            vns.connector.waitingRobots[msgM.fromS] ~= nil and
	            vns.connector.waitingRobots[msgM.fromS].numberN < msgM.dataT.numberN
	         )
	      )
	   )
	   then
		local robotR = {
			idS = msgM.fromS,
			positionV3 = 
				vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
			orientationQ = msgM.dataT.orientationQ:inverse(),
			robotTypeS = msgM.dataT.fromTypeS,
			scale = vns.ScaleManager.Scale:new(msgM.dataT.scale)
		}
		if vns.parentR ~= nil then
			vns.Msg.send(vns.parentR.idS, "dismiss")
			vns.parentR = nil
		end
		vns.addParent(vns, robotR)
		vns.Msg.send(msgM.fromS, "ack")
		vns.Connector.changeBrain(vns, msgM.dataT.brainS)
	end
	break
	end
	   
	--[[
	-- if I don't have parent, ack a recruit
	if vns.parentR == nil and vns.connector.brainSwitchCount == 0 then
		for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
			if msgM.dataT.brainS ~= vns.idS and 
			   vns.childrenRT[msgM.dataT.brainS] == nil and
			   vns.childrenRT[msgM.fromS] == nil and
			   (vns.connector.waitingRobots[msgM.fromS] == nil or
			    vns.connector.waitingRobots[msgM.fromS] ~= nil and
			    vns.connector.waitingRobots[msgM.fromS].numberN < msgM.dataT.numberN
			   )
			   then
				local robotR = {
					idS = msgM.fromS,
					positionV3 = 
						vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse()),
					orientationQ = msgM.dataT.orientationQ:inverse(),
					robotTypeS = msgM.dataT.fromTypeS,
					scale = vns.ScaleManager.Scale:new(msgM.dataT.scale)
				}
				vns.addParent(vns, robotR)
				vns.Msg.send(msgM.fromS, "ack")
				vns.brainS = msgM.dataT.brainS
				vns.connector.brainSwitchCount = vns.scale:totalNumber()
				for idS, robotR in pairs(vns.childrenRT) do
					vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS})
				end
				for idS, robotR in pairs(vns.connector.waitingRobots) do
					vns.Msg.send(idS, "newBrain", {newBrainS = vns.brainS})
				end
				break
			end
		end
	else
	end
	--]]
end

------ behaviour tree ---------------------------------------
function Connector.create_connector_node(vns)
	return function()
		Connector.step(vns)
		Connector.recruitAll(vns)
		Connector.ackAll(vns)
	end
end

return Connector

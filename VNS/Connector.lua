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
end

function Connector.prestep(vns)
	vns.connector.seenRobots = {}
end

function Connector.recruit(vns, robotR)
	vns.Msg.send(robotR.idS, "recruit", {	
		numberN = math.random(),
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		fromTypeS = vns.robotTypeS
	}) 

	vns.connector.waitingRobots[robotR.idS] = {
		idS = robotR.idS,
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		robotTypeS = robotR.robotTypeS,
		count = 0,
	}
end

function Connector.update(vns)
	-- update waiting list
	for idS, robotR in pairs(vns.connector.seenRobots) do
		if vns.connector.waitingRobots[idS] ~= nil then
			vns.connector.waitingRobots[idS].positionV3 = robotR.positionV3
			vns.connector.waitingRobots[idS].orientationQ = robotR.orientationQ
		end
	end

	-- updated
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.updated = robotR.updated + 1
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
	end

	-- check updated
	for idS, robotR in pairs(vns.childrenRT) do
		if robotR.updated == 3 then
			vns.Msg.send(robotR.idS, "dismiss")
			vns.deleteChild(vns, robotR.idS)
		end
	end
end

function Connector.deleteChild(vns, idS)
	vns.connector.waitingRobots[idS] = nil
	vns.childrenRT[idS] = nil
end

function Connector.deleteParent(vns)
	vns.parentR = nil
end

function Connector.waitingCount(vns)
	for idS, robotR in pairs(vns.connector.waitingRobots) do
		robotR.count = robotR.count + 1
		if robotR.count == 3 then
			vns.connector.waitingRobots[idS] = nil
		end
	end
end

function Connector.recruitAll(vns)
	-- recruit new
	for idS, robotR in pairs(vns.connector.seenRobots) do
		if vns.childrenRT[idS] == nil and 
		   vns.connector.waitingRobots[idS] == nil and 
		   (vns.parentR == nil or vns.parentR.idS ~= idS) and
		   vns.brainS ~= idS then

		   	   --if vns.robotTypeS == "drone" and robotR.idS == "pipuck1" then
			   --else
			
			Connector.recruit(vns, robotR)

			   --end
		end
	end
end

function Connector.step(vns)
	Connector.update(vns)
	Connector.waitingCount(vns)

	-- check ack
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "ack")) do
		if vns.connector.waitingRobots[msgM.fromS] ~= nil then
			vns.childrenRT[msgM.fromS] = vns.connector.waitingRobots[msgM.fromS]
			vns.childrenRT[msgM.fromS].count = nil
			vns.childrenRT[msgM.fromS].updated = 0
			vns.connector.waitingRobots[msgM.fromS] = nil

			-- if ack is with a position information, update new location (this may happen when a pipuck recruiting a drone)
			if msgM.dataT ~= nil and msgM.dataT.positionV3 ~= nil and msgM.dataT.orientationQ ~= nil then
				vns.childrenRT[msgM.fromS].positionV3 = 
					vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse())
				vns.childrenRT[msgM.fromS].orientationQ = 
					msgM.dataT.orientationQ:inverse()
			end
		end
	end

	-- check dismiss
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "dismiss")) do
		if vns.parentR ~= nil and msgM.fromS == vns.parentR.idS then
			vns.deleteParent(vns)
		end
	end
end

------ behaviour tree ---------------------------------------
function Connector.create_connector_node(vns)
	return function()
		Connector.step(vns)
		Connector.recruitAll(vns)
	end
end

return Connector

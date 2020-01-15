-- connector -----------------------------------------
------------------------------------------------------
local Connector = {}

--[[
	related data:
	vns.connector.waitingRobots = {}
--]]

function Connector.create(vns)
	vns.connector = {}
	vns.seenRobots = {}
	Connector.reset(vns)
end

function Connector.reset(vns)
	vns.connector.waitingRobots = {}
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
	if type(vns.seenRobots) ~= "table" then return end

	-- update waiting list
	for idS, robotR in pairs(vns.seenRobots) do
		if vns.connector.waitingRobots[idS] ~= nil then
			vns.connector.waitingRobots[idS].positionV3 = robotR.positionV3
			vns.connector.waitingRobots[idS].orientationQ = robotR.orientationQ
		end
	end

	-- update vns children list
	for idS, robotR in pairs(vns.seenRobots) do
		if vns.children[idS] ~= nil then
			vns.children[idS].positionV3 = robotR.positionV3
			vns.children[idS].orientationQ = robotR.orientationQ
			vns.children[idS].updated = true
		end
	end
end

function Connector.waitingCount(vns)
	-- lost count
	for idS, robotR in pairs(vns.connector.waitingRobots) do
		robotR.count = robotR.count + 1
		if robotR.count == 3 then
			vns.connector.waitingRobots[idS] = nil
		end
	end
end

function Connector.recruitAll(vns)
	-- recruit new
	for idS, robotR in pairs(vns.seenRobots) do
		if vns.children[idS] == nil and 
		   vns.connector.waitingRobots[idS] == nil and 
		   vns.parentS ~= idS and
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
			vns.children[msgM.fromS] = vns.connector.waitingRobots[msgM.fromS]
			vns.connector.waitingRobots[msgM.fromS] = nil
			if msgM.dataT ~= nil and msgM.dataT.positionV3 ~= nil and msgM.dataT.orientationQ ~= nil then
				vns.children[msgM.fromS].positionV3 = 
					vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse())
				vns.children[msgM.fromS].orientationQ = 
					msgM.dataT.orientationQ:inverse()
			end
		end
	end
end

function Connector.create_connector_node(vns)
	return function()
		Connector.step(vns)
	end
end

return Connector

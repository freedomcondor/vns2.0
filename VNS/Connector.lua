-- connector -----------------------------------------
------------------------------------------------------
local Connector = {}

--[[
	related data:
	vns.connector.waitingRobots = {}
--]]

function Connector.reset(vns)
	vns.connector.waitingRobots = {}
end


function Connector.recruit(vns, robotR)
	vns.Msg.send(robotR.idS, "recruit", {number = math.random()}) 
		--TODO: give vns status in the future
	vns.connector.waitingRobots[robotR.idS] = {
		idS = robotR.idS,
		positionV = robotR.positionV,
		orientationQ = robotR.orientationQ,
		robotTypeS = robotR.robotTypeS
		count = 0
	}
end

function Connector.update(vns, seenRobots)
	if type(seenRobots) ~= "table" then return end

	-- update waiting list
	for idS, robotR in pairs(robotListR) do
		if vns.connector.waitingRobots[idS] ~= nil then
			vns.connector.waitingRobots[idS].positionV = robotR.positionV
			vns.connector.waitingRobots[idS].orientationQ = robotR.orientationQ
		end
	end

	-- update vns children list
	for idS, robotR in pairs(robotListR) do
		if vns.children[idS] ~= nil then
			vns.children[idS].positionV = robotR.positionV
			vns.children[idS].orientationQ = robotR.orientationQ
			vns.children[idS].updated = true
		end
	end
end

function Connector.waitingCount(vns, robotListR)
	-- lost count
	for idS, robotR in pairs(vns.connector.waitingRobots) do
		robotR.count = robotR.count + 1
		if robotR.count == 3 then
			vns.connector.waitingRobots[idS] = nil
		end
	end
end

function Connector.step(vns, seenRobots)
	Connector.update(vns, seenRobots)
	Connector.waitingCount(vns, seenRobots)

	-- recruit new
	for idS, robotR in pairs(robotListR) do
		if vns.children[idS] == nil and 
		   vns.connector.waitingCount[idS] == nil and 
		   vns.parentS ~= idS and
		   vns.brainS ~= idS then
			Connector.recruit(vns, robotR)
		end
	end

	-- check ack
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "ack")) do
		if vns.connector.waitingRobots[msgM.fromS] ~= nil then
			vns.children[msgM.fromS] = vns.connector.waitingRobots[msgM.fromS]
			vns.connector.waitingRobots[msgM.fromS] = nil
		end
	end
end

function Connector.create_connector_node(vns, seenRobots)
	return Connector.step
end

return Connector

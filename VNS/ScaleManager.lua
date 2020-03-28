-- ScaleManager --------------------------------------
------------------------------------------------------
local ScaleManager = {}

--[[
--	related data
--	vns.scale
--	vns.parentR.scale
--	vns.parentR.lastSendScale
--	vns.childrenRT[xxx].scale
--	vns.childrenRT[xxx].lastSendScale
--]]

ScaleManager.Scale = require("Scale")

function ScaleManager.create(vns)
	vns.scale = ScaleManager.Scale:new()
end

function ScaleManager.reset(vns)
	vns.scale = ScaleManager.Scale:new()
end

function ScaleManager.addChild(vns, robotR)
	robotR.scale = ScaleManager.Scale:new()
end

function ScaleManager.step(vns)
	-- receive scale from parent
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "scale")) do
		vns.parentR.scale = ScaleManager.Scale:new(msgM.dataT.scale)
	end end
	-- receive scale from children
	for idS, robotR in pairs(vns.childrenRT) do 
		for _, msgM in ipairs(vns.Msg.getAM(idS, "scale")) do
			robotR.scale = ScaleManager.Scale:new(msgM.dataT.scale)
		end 
	end
	-- sum up scale
	local sumScale = ScaleManager.Scale:new()
	if vns.parentR ~= nil then sumScale = sumScale + vns.parentR.scale end
	for idS, robotR in pairs(vns.childrenRT) do 
		sumScale = sumScale + robotR.scale
	end
	--TODO: add myself
	if sumScale[vns.robotTypeS] == nil then
		sumScale[vns.robotTypeS] = 1
	else
		sumScale[vns.robotTypeS] = sumScale[vns.robotTypeS] + 1
	end
	vns.scale = sumScale

	-- report scale
	local toReport
	if vns.parentR ~= nil then 
		toReport = sumScale - vns.parentR.scale 
		if toReport ~= vns.parentR.lastSendScale then
			vns.Msg.send(vns.parentR.idS, "scale", {scale = toReport})
		end
	end
	for idS, robotR in pairs(vns.childrenRT) do 
		toReport = sumScale - robotR.scale 
		if toReport ~= robotR.lastSendScale then
			vns.Msg.send(idS, "scale", {scale = toReport})
		end
	end
end

function ScaleManager.create_scalemanager_node(vns)
	return function()
		ScaleManager.step(vns)
		return false, true
	end
end

return ScaleManager

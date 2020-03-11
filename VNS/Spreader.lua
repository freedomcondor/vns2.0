-- Spreader -----------------------------------------
------------------------------------------------------
local Spreader = {}

function Spreader.create(vns)
	vns.spreader = {}
	vns.spreader.spreading_speed = {positionV3 = vector3(), orientationV3 = vector3()}
end

function Spreader.step(vns, surpress_or_not)
	local chillRate = 0.1
	vns.spreader.spreading_speed.positionV3 = vns.spreader.spreading_speed.positionV3 * chillRate
	vns.spreader.spreading_speed.orientationV3 = vns.spreader.spreading_speed.orientationV3 * chillRate

	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "emergency")) do
		if vns.childrenRT[msgM.fromS] ~= nil or 
		   vns.parentR ~= nil and vns.parentR.idS == msgM.fromS then -- else continue
		
		local fromRobotR = vns.childrenRT[msgM.fromS] or vns.parentR

		local transV3 = msgM.dataT.transV3:rotate(fromRobotR.orientationQ)
		local rotateV3 = msgM.dataT.rotateV3:rotate(fromRobotR.orientationQ)

		vns.spreader.spreading_speed.positionV3 = vns.spreader.spreading_speed.positionV3 + transV3
		vns.spreader.spreading_speed.orientationV3 = vns.spreader.spreading_speed.orientationV3 + rotateV3

		-- message from children, send to parent
		if vns.childrenRT[msgM.fromS] ~= nil then
			if vns.parentR ~= nil then
				vns.Msg.send(vns.parentR.idS, "emergency", {
					transV3 = transV3, rotateV3 = rotateV3,
				})
			end
		end

		for idS, childR in pairs(vns.childrenRT) do
			if idS ~= msgM.fromS then
				vns.Msg.send(idS, "emergency", {
					transV3 = transV3, rotateV3 = rotateV3,
				})
			end
		end
	end end

	if surpress_or_not == true then
		vns.goalSpeed.positionV3 = vns.spreader.spreading_speed.positionV3
		vns.goalSpeed.orientationV3 = vns.spreader.spreading_speed.orientationV3
	else
		vns.goalSpeed.positionV3 = 
			vns.goalSpeed.positionV3 + vns.spreader.spreading_speed.positionV3
		vns.goalSpeed.orientationV3 = 
			vns.goalSpeed.orientationV3 + vns.spreader.spreading_speed.orientationV3
	end
end

function Spreader.create_spreader_node(vns)
	return function()
		Spreader.step(vns)
	end
end

return Spreader

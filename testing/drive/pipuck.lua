package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

local api = require("pipuckAPI")
local VNS = require("VNS")
local BT = require("luabt")

DMSG.enable()
--require("Debugger")

local bt
--local vns
Message = VNS.Msg

function init()
	api.linkRobotInterface(VNS)

	vns = VNS.create("pipuck")
	vns.api = api

	bt = BT.create
		{type = "sequence", children = {
			VNS.PipuckConnector.create_pipuckconnector_node(vns),
			VNS.Connector.create_connector_node(vns),
			VNS.ScaleManager.create_scalemanager_node(vns),
			VNS.Driver.create_driver_node(vns),
		}}
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	vns.preStep(vns)

	bt()
	
	for idS, robotR in pairs(vns.childrenRT) do
		robotR.goal.positionV3 = vector3(-0.5, 0, 0)
		robotR.goal.orientationQ = quaternion()
	end

	for i, robot in pairs(vns.childrenRT) do
		api.debug.drawArrow("blue", vector3(), api.virtualFrame.V3_VtoR(vector3(robot.positionV3)))
	end

	if vns.parentR == nil then
		api.move(vector3(), vector3(0,0,math.pi * 0.005))
	end
---[[
	if vns.parentR ~= nil then
		api.debug.drawArrow("green", vector3(), api.virtualFrame.V3_VtoR(vector3(vns.parentR.positionV3)))
		api.debug.drawArrow("green", 
		     api.virtualFrame.V3_VtoR(vector3(vns.parentR.positionV3)),
		     api.virtualFrame.V3_VtoR(
			 	vector3(vns.parentR.positionV3) +
				vector3(1, 0, 0):rotate(vns.parentR.orientationQ)
			 )
		)
	end
--]]

	vns.postStep(vns)
	api.postStep()
end

function reset() end
function destroy() end

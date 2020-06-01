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
		}}
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	vns.preStep(vns)

	api.move(vector3(0.01, 0, 0), vector3(0,0,math.pi/100))

	bt()
	
	for i, robot in pairs(vns.connector.seenRobots) do
		api.debug.drawArrow("blue", vector3(), api.virtualFrame.V3_VtoR(vector3(robot.positionV3)))
	end

	vns.postStep(vns)
	api.postStep()
end

function reset() end
function destroy() end

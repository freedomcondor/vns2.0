package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

local api = require("droneAPI")
local VNS = require("VNS")
local BT = require("luabt")

DMSG.enable()
--require("Debugger")

Message = VNS.Msg

local bt
--local vns

function init()
	api.linkRobotInterface(VNS)
	api.init()
	vns = VNS.create("drone")
	vns.api = api

	bt = BT.create
		{type = "sequence", children = {
			VNS.DroneConnector.create_droneconnector_node(vns),
		}}
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	vns.preStep(vns)

	api.move(vector3(0.01, 0, 0), vector3(0,0,math.pi/100))

	api.droneAddSeenRobots(
		api.droneDetectTags(),
		vns.connector.seenRobots
	)
	bt()

	for i, robot in pairs(vns.connector.seenRobots) do
		api.debug.drawArrow("blue", vector3(), api.virtualFrame.V3_VtoR(vector3(robot.positionV3)))
	end

	vns.postStep(vns)
	api.droneMaintainHeight(1.5)
	api.postStep()
end

function reset()
	init()
end

function destroy()
end

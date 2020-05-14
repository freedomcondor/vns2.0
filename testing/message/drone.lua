package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

local api = require("droneAPI")

Message = require("Message")
VNS = {Msg = Message}

DMSG.enable()
--require("Debugger")

-----------------------------------------
function init()
	api.linkRobotInterface(VNS)
end

function step()
	DMSG(robot.id, "-----------------------")
	api.preStep()
	Message.preStep()

	VNS.Msg.send("pipuck0", "IamCMDdronetoPipuck", {a = "aaa1", b = "bbb"})
	VNS.Msg.send("pipuck0", "IamCMDdronetoPipuck", {a = "aaa2", b = "bbb"})

	Message.postStep()
	api.postStep()
end

function reset()
	init()
end

function destroy()
end

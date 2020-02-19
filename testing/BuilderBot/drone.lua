package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")
--require("Debugger")

require("droneAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
DMSG.disable("Allocator")

	local dis = 0.5
	local structure = {
		robotTypeS = "drone",
		positionV3 = vector3(),
		orientationQ = quaternion(),
		children = {
			{	robotTypeS = "pipuck",
				positionV3 = vector3(dis, dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(dis, -dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(-dis, -dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(-dis, dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
			},
			{	robotTypeS = "drone",
				positionV3 = vector3(-dis*2, 0, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				children = {
					{	robotTypeS = "pipuck",
						positionV3 = vector3(-dis, -dis, 0),
						orientationQ = quaternion(0, vector3(0,0,1)),
					},
					{	robotTypeS = "pipuck",
						positionV3 = vector3(-dis, dis, 0),
						orientationQ = quaternion(0, vector3(0,0,1)),
					},
				},
			},
		},
	}

--local vns
function init()
	linkDroneInterface(VNS)
	drone_set_height(1.6)
	drone_enable_cameras()

	vns = VNS.create("drone")
	vns.setGene(vns, structure)
	bt = BehaviorTree.create(VNS.create_vns_node(vns))
end

function step()
	DMSG("--- drone step ---")
	-- check height
	if drone_check_height(1.6) == false then drone_set_height(1.6) end

	vns.prestep(vns)
	process_time()

	drone_add_seenRobots(vns.connector.seenRobots, drone_detect_tags())

	bt()

	for idS, robotR in pairs(vns.connector.seenRobots) do
		if robotR.robotTypeS == "block" and robotR.added == nil and
		   vns.allocator.target ~= nil then
			vns.allocator.target.children[6] = 
			{
				robotTypeS = "builderbot",
				positionV3 = vector3(-0.30, 0, 0):rotate(robotR.orientationQ) + robotR.positionV3,
				orientationQ = robotR.orientationQ,
				scale = vns.ScaleManager.Scale:new{builderbot = 1}
			}
			robotR.added = vns.allocator.target.children[6]
		end
	end

	---[[
	for idS, robotR in pairs(vns.childrenRT) do
		local relativeV3 = vector3()
		if robotR.goalPoint ~= nil then
			relativeV3 = robotR.positionV3 - robotR.goalPoint.positionV3
			relativeV3.z = 0
		end
		if robotR.robotTypeS == "builderbot" and
		   robotR.picking_cmd ~= true and 
		   robotR.goalPoint ~= nil and
		   relativeV3:length() < 0.05 then
			print("send builderbot_pick")
			vns.Msg.send(idS, "builderbot_pick")
			robotR.picking_cmd = true
		end
	end
	--]]

	--[[
	if vns.parentR ~= nil then
		drawArrow("green", 
			tostring(vector3(0,0,0)),
			tostring(vns.parentR.positionV3)
		)
	end
	--]]

	---[[
	for i, child in pairs(vns.childrenRT) do
		drawArrow("blue", 
			tostring(vector3(0,0,0)),
			tostring(child.positionV3)
		)

		--[[
		drawArrow("red", 
			tostring(child.positionV3),
			tostring(child.positionV3 + vector3(1,0,0):rotate(child.orientationQ))
		)
		--]]
	end
	--]]
end

function reset()
	init()
end

function destroy()
end

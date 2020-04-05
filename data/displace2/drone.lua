package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")
pairs = require("AlphaPairs")

require("droneAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

	local dis = 0.50
	local structure = {
		robotTypeS = "drone",
		positionV3 = vector3(),
		orientationQ = quaternion(),
		index = 1,
		children = {
			{	robotTypeS = "pipuck",
				positionV3 = vector3(dis, dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				index = 7,
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(dis, -dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				index = 8,
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(-dis, -dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				index = 9,
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(-dis, dis, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				index = 10,
			},
			{	robotTypeS = "drone",
				positionV3 = vector3(-dis*2, 0, 0),
				orientationQ = quaternion(0, vector3(0,0,1)),
				index = 2,
				children = {
					{	robotTypeS = "pipuck",
						positionV3 = vector3(-dis, -dis, 0),
						orientationQ = quaternion(0, vector3(0,0,1)),
						index = 11,
					},
					{	robotTypeS = "pipuck",
						positionV3 = vector3(-dis, dis, 0),
						orientationQ = quaternion(0, vector3(0,0,1)),
						index = 12,
					},
					{	robotTypeS = "drone",
						positionV3 = vector3(-dis*2, 0, 0),
						orientationQ = quaternion(0, vector3(0,0,1)),
						index = 3,
						children = {
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, -dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 13,
							},
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 14,
							},
							{	robotTypeS = "drone",
								positionV3 = vector3(-dis*2, 0, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 6,
								children = {
									{	robotTypeS = "pipuck",
										positionV3 = vector3(-dis, -dis, 0),
										orientationQ = quaternion(0, vector3(0,0,1)),
										index = 15,
									},
									{	robotTypeS = "pipuck",
										positionV3 = vector3(-dis, dis, 0),
										orientationQ = quaternion(0, vector3(0,0,1)),
										index = 16,
									},
								},
							},
						},
					},
					{	robotTypeS = "drone",
						positionV3 = vector3(0, -dis*2, 0),
						orientationQ = quaternion(math.pi/2, vector3(0,0,1)),
						index = 4,
						children = {
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, -dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 17,
							},
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 18,
							},
						},
					},
					{	robotTypeS = "drone",
						positionV3 = vector3(0, dis*2, 0),
						orientationQ = quaternion(-math.pi/2, vector3(0,0,1)),
						index = 5,
						children = {
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, -dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 19,
							},
							{	robotTypeS = "pipuck",
								positionV3 = vector3(-dis, dis, 0),
								orientationQ = quaternion(0, vector3(0,0,1)),
								index = 20,
							},
						},

					},

				},
			},
		},
	}

obstacles = {}

--local vns
local stepcount

function init()
	linkDroneInterface(VNS)
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create("drone")
	vns.setGene(vns, structure)
	if robot.id == "drone1" then
		bt = BehaviorTree.create(VNS.create_vns_node_without_ackAll(vns))
	else
		bt = BehaviorTree.create(VNS.create_vns_node(vns))
	end
	stepcount = 0
end

function step()
	stepcount = stepcount + 1
	numberN = math.floor(robot.random.uniform(2, 7))
	print(numberN)
	if stepcount == 1500 then
		local initial_position
		if robot.id == "drone1" then initial_position = vector3(0, 0, 0)
		elseif robot.id == "drone2" then initial_position = vector3(-1.0, 0, 0)
		elseif robot.id == "drone3" then initial_position = vector3(-0.5, 0.5, 0)
		elseif robot.id == "drone4" then initial_position = vector3(-1.5, -0.5, 0)
		elseif robot.id == "drone5" then initial_position = vector3(-2.0, 0, 0)
		elseif robot.id == "drone6" then initial_position = vector3(-2.5, 0.5, 0)
		end
		local numberx = robot.random.uniform(-3.7, 0.7)
		local numbery = robot.random.uniform(-0.7, 0.7)
		if (-1.7 < x_number) && (x_number < -0.3) then
			numbery = robot.random.uniform(-1.7, 1.7)
		end

		--robot.flight_system.position
		robot.flight_system.set_targets(
			vector3(1, 0, 0) - initial_position
		)
	end

	if vns.allocator.target == nil then
		robot.debug.loop_functions("-1")
	else
		robot.debug.loop_functions(tostring(vns.allocator.target.index))
	end

	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) end

	vns.prestep(vns)
	process_time()

	local tags = drone_detect_tags()
	drone_add_seenRobots(vns.connector.seenRobots, tags)
	drone_add_obstacles(vns.avoider.obstacles, tags)

	bt()

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

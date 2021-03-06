package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

require("droneAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

	local dis = 0.5
	--[[
	local structure = {
		positionV3 = vector3(),
		orientationQ = quaternion(),
		children = {
			{	robotTypeS = "pipuck",
				positionV3 = vector3(dis, 0, 0),
				orientationQ = quaternion(),
			},
			{	robotTypeS = "pipuck",
				positionV3 = vector3(-dis, 0, 0),
				orientationQ = quaternion(),
			},
			{	robotTypeS = "drone",
				positionV3 = vector3(-dis*2, 0, 0),
				orientationQ = quaternion(),
				children = {
					{	robotTypeS = "pipuck",
						positionV3 = vector3(-dis, 0, 0),
						orientationQ = quaternion(),
						children = {
							{	robotTypeS = "drone",
								positionV3 = vector3(0, 0, 0),
								orientationQ = quaternion(),
							},
						},
					},
				},
			},
		},
	}
	--]]
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
									--[[
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
									--]]
								},
							},
						},
					},
					{	robotTypeS = "drone",
						positionV3 = vector3(0, -dis*2, 0),
						orientationQ = quaternion(math.pi/2, vector3(0,0,1)),
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
					{	robotTypeS = "drone",
						positionV3 = vector3(0, dis*2, 0),
						orientationQ = quaternion(-math.pi/2, vector3(0,0,1)),
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
			},
		},
	}

--local vns
function init()
	linkDroneInterface(VNS)
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create("drone")
	vns.setGene(vns, structure)
	bt = BehaviorTree.create(VNS.create_vns_node(vns))

	robot.directional_leds.set_all_colors("blue")

	led_count = 0
end

function step()
	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) end

	robot.directional_leds.set_single_color(math.fmod(led_count, 4) + 1, "red")
	robot.directional_leds.set_single_color(math.fmod(led_count + 1, 4) + 1, "blue")
	robot.directional_leds.set_single_color(math.fmod(led_count + 2, 4) + 1, "green")
	robot.directional_leds.set_single_color(math.fmod(led_count + 3, 4) + 1, "black")
	led_count = led_count + 1

	vns.prestep(vns)
	process_time()

	drone_add_seenRobots(vns.connector.seenRobots, drone_detect_tags())

	bt()

	--[[
	if vns.parentR ~= nil then
		drawArrow("green", 
			tostring(vector3(0,0,0)),
			tostring(vns.parentR.positionV3)
		)
	end
	--]]

	--[[
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
		--] ]
	end
	--]]
end

function reset()
	init()
end

function destroy()
end

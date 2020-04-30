package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

package.path = package.path .. ";video/obstacle2/?.lua"

DMSG = require("DebugMessage")
pairs = require("AlphaPairs")

require("droneAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

local structure1 = require("structure1")
local structure2 = require("structure2")
local structure3 = require("structure3")

obstacles = {}

--local vns
function init()
	linkDroneInterface(VNS)
	drone_set_height(1.5)
	drone_enable_cameras()

	vns = VNS.create("drone")
	vns.setGene(vns, structure2)
	bt = BehaviorTree.create(VNS.create_vns_node(vns))
end

function step()
	if vns.idS == "drone1" then
		if vns.spreader.spreading_speed.flag == "blue" then
			vns.setGene(vns, structure2)
		elseif vns.spreader.spreading_speed.flag == "green" then
			vns.setGene(vns, structure3)
		else
			vns.setGene(vns, structure1)
		end
	end

	local flag_green = false
	if vns.spreader.spreading_speed.flag == "green" then
		flag_green = true
	end

	
	local formation_name = -1
	if vns.allocator.target ~= nil and 
	   vns.allocator.target.formation_name ~= nil then
		formation_name = vns.allocator.target.formation_name
	end
	if vns.allocator.target == nil then
		robot.debug.loop_functions("-1," .. tostring(formation_name))
	else
		robot.debug.loop_functions(tostring(vns.allocator.target.index) .. "," .. tostring(formation_name))
	end

	-- check height
	if drone_check_height(1.5) == false then drone_set_height(1.5) end

	vns.prestep(vns)
	process_time()

	local tags = drone_detect_tags()
	drone_add_seenRobots(vns.connector.seenRobots, tags)
	drone_add_obstacles(vns.avoider.obstacles, tags)

	if flag_green == true then
		for j, obstacle in ipairs(vns.avoider.obstacles) do
			if obstacle.robotTypeS == "block" and obstacle.type == 0 then
				obstacle.type = 1
			end
		end
	end

	bt()

	for _, obstacle in ipairs(vns.avoider.obstacles) do
		if obstacle.robotTypeS == "block" and obstacle.type == 0 then	
			vns.Msg.send("pipuck0", "predator_location", {
						positionV3 = obstacle.positionV3,
						orientationQ = obstacle.orientationQ,
					})
		end
	end
	
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
		--drawArrow("0,150,200,1", 
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
	--[[
	local color = "red"
	local middle = vector3(0,0,0)
	local radius = 0.10
	robot.debug.draw("ring(" .. color .. ")(" .. 
		tostring(middle) .. ")(" ..
		tostring(radius) .. ")"
	)
	 --]]
end

function reset()
	init()
end

function destroy()
end

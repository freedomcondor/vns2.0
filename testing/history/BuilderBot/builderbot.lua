package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

package.path = package.path .. ";Tools/BuilderBotLibrary/?.lua"
package.path = package.path .. ";Tools/BuilderBotLibrary/Tools/?.lua"
package.path = package.path .. ";Tools/BuilderBotLibrary/AppNode/?.lua"

DMSG = require("DebugMessage")
DebugMSG = require("DebugMessage")
--require("Debugger")

require("builderbotAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

api = require('BuilderBotAPI')
app = require('ApplicationNode')

DMSG.enable()
DMSG.disable("Allocator")

picking = false
BTDATA = {target = {}}

--local vns
function init()
	linkBuilderbotInterface(VNS)
	robot.camera_system.enable()
	vns = VNS.create("builderbot")
	vns.setGene(vns, {robotTypeS = "drone"})
	bt = BehaviorTree.create{type = "sequence", children = {
		VNS.create_vns_node_without_drive(vns),
		-- receive cmd and set pick
		{type = "selector", children = {
			-- not receive pick cmd?
			function()
				if vns.parentR ~= nil then
					for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "builderbot_pick")) do
						print("receive a pick")
						return false, false
					end
				end
				return false, true
			end,
			-- set picking = true
			function()
				picking = true
				return false, true
			end,
		}},
		-- check pick and do builderbot behaviour tree 
		{type = "selector", children = {
			-- check
			{type = "sequence", children = {
				function()
					if picking == false then
						return false, true
					else
						return false, false
					end
				end,
				-- otherwise
				function()
					print("drive")
				end,
				vns.Driver.create_driver_node(vns),
			}},

			{type = "sequence*", children = {
				-- picking 
				app.create_search_block_node(
					function()
						if api.blocks[1] ~= nil then
							BTDATA.target.reference_id = 1
							BTDATA.target.offset = vector3(0,0,0)
							return false, true
						else
							return true
						end
					end
				),
				app.create_curved_approach_block_node(BTDATA.target, 0.2),
				app.create_pickup_block_node(BTDATA.target, 0.2),
 
				function()
					print("end pick")
					picking = false
					return false, true
				end,
			}},
		}},
	}}

end

function step()
	DMSG("--- step ---")
	vns.prestep(vns)
	api.process()

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

function reset() end
function destroy() end

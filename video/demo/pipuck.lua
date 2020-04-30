package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")
pairs = require("AlphaPairs")

require("pipuckAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
--require("Debugger")

--local vns
function init()
	linkPipuckInterface(VNS)
	vns = VNS.create("pipuck")
	vns.setGene(vns, {robotTypeS = "drone"})
	bt = BehaviorTree.create(VNS.create_vns_node(vns))
end

function step()
	local color = "blue"
	local middle = vector3(0,0,0)
	local radius = 0.05
	robot.debug.draw("ring(" .. color .. ")(" .. 
		tostring(middle) .. ")(" ..
		tostring(radius) .. ")"
	)
	if vns.allocator.target == nil then
		robot.debug.loop_functions("-1")
	else
		robot.debug.loop_functions(tostring(vns.allocator.target.index))
	end

	vns.prestep(vns)

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

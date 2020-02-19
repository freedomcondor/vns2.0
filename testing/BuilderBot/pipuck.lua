package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";VNS/?.lua"
package.path = package.path .. ";Tools/?.lua"

DMSG = require("DebugMessage")

require("pipuckAPI")
local VNS = require("VNS")
local BehaviorTree = require("luabt")

DMSG.enable()
DMSG.disable("Allocator")
--require("Debugger")

--local vns
function init()
	linkPipuckInterface(VNS)
	vns = VNS.create("pipuck")
	vns.setGene(vns, {robotTypeS = "drone"})
	bt = BehaviorTree.create(VNS.create_vns_node(vns))
end

function step()
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

function reset() end
function destroy() end

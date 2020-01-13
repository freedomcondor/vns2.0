package.path = package.path .. ";RobotAPI/?.lua"
package.path = package.path .. ";Tools/?.lua"

require("pipuckAPI")

function init()
end

function step()
	pipuck_move(vector3(1.0, -1.0, 0), vector3(0,0,0))
end

function reset() end
function destroy() end

-- Avoider -----------------------------------------
------------------------------------------------------
local Avoider = {}

function Avoider.create(vns)
	vns.avoider = {}
	vns.avoider.obstacles = {}
end

function Avoider.step(vns, surpress_or_not)
	-- for each children avoid
	for idS, childR in pairs(vns.childrenRT) do
		local avoid_speed = {positionV3 = vector3(), orientationV3 = vector3()}
		--childVns.avoiderSpeed.locV3 = Vec3:create()

		if childR.robotTypeS == "drone" then
			-- avoid my parent
			if vns.parentR ~= nil then
				avoid_speed.positionV3 =
					Avoider.add(childR.positionV3, vns.parentR.positionV3,
				            	avoid_speed.positionV3,
				            	0.70)
			end

			-- avoid my self
			avoid_speed.positionV3 =
				Avoider.add(childR.positionV3, vector3(),
				            avoid_speed.positionV3,
				            0.70)

			-- avoid children
			for jidS, jchildR in pairs(vns.childrenRT) do
				if jchildR.robotTypeS == childR.robotTypeS then -- else continue
				if idS ~= jidS then -- else continue
	
				avoid_speed.positionV3 =
					Avoider.add(childR.positionV3, jchildR.positionV3,
				            	avoid_speed.positionV3,
				            	0.70)
			end end end
		end

		if childR.robotTypeS == "pipuck" then
			-- avoid seen pipucks
			for jidS, robotR in pairs(vns.connector.seenRobots) do
				if robotR.robotTypeS == "pipuck" and jidS ~= idS then
					avoid_speed.positionV3 =
						Avoider.add(childR.positionV3, robotR.positionV3,
									avoid_speed.positionV3,
						            0.15)
				end
			end

			-- avoid obstacles
			for j, obstacle in ipairs(vns.avoider.obstacles) do
				avoid_speed.positionV3 = 
					Avoider.add(childR.positionV3, obstacle.positionV3,
								avoid_speed.positionV3,
					            0.30)
			end
		end

		if surpress_or_not == true then
			childR.goalSpeed.positionV3 = avoid_speed.positionV3
		else
			childR.goalSpeed.positionV3 = 
				childR.goalSpeed.positionV3 + avoid_speed.positionV3
		end
	end

end

function Avoider.add(myLocV3, obLocV3, accumulatorV3, threshold)
	local dV3 = myLocV3 - obLocV3
	local d = dV3:length()
	if d == 0 then return accumulatorV3 end
	local ans = accumulatorV3
	if d < threshold then
		dV3:normalize()
		local transV3 = 0.015 / d * dV3
		ans = ans + transV3
	end
	return ans
end


function Avoider.create_avoider_node(vns)
	return function()
		Avoider.step(vns)
	end
end

return Avoider

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

		local drone_range = tonumber(robot.params.drone_range or 0.30)

		if childR.robotTypeS == "drone" then
			-- avoid my parent
			if vns.parentR ~= nil then
				avoid_speed.positionV3 =
					Avoider.add(childR.positionV3, vns.parentR.positionV3,
				            	avoid_speed.positionV3,
				            	drone_range)
			end

			-- avoid my self
			avoid_speed.positionV3 =
				Avoider.add(childR.positionV3, vector3(),
				            avoid_speed.positionV3,
				            drone_range)

			-- avoid children
			for jidS, jchildR in pairs(vns.childrenRT) do
				if jchildR.robotTypeS == childR.robotTypeS then -- else continue
				if idS ~= jidS then -- else continue
	
				avoid_speed.positionV3 =
					Avoider.add(childR.positionV3, jchildR.positionV3,
				            	avoid_speed.positionV3,
				            	drone_range)
			end end end

			-- avoid other seen robots
			if robot.params.avoid_seen_drones == "true" then
				for jidS, robotR in pairs(vns.connector.seenRobots) do
					if robotR.robotTypeS == "drone" and jidS ~= idS and
					   vns.childrenRT[jidS] == nil and 
					   vns.parentR ~= nil and vns.parentR.idS ~= jidS then

						avoid_speed.positionV3 =
							Avoider.add(childR.positionV3, robotR.positionV3,
				            			avoid_speed.positionV3,
				            			drone_range)
					end
				end
			end
		end

		if childR.robotTypeS == "pipuck" then
			-- avoid seen pipucks
			for jidS, robotR in pairs(vns.connector.seenRobots) do
				if robotR.robotTypeS == "pipuck" and jidS ~= idS then
					avoid_speed.positionV3 =
						Avoider.add(childR.positionV3, robotR.positionV3,
									avoid_speed.positionV3,
						            0.07)
				end
			end

			-- avoid obstacles
			for j, obstacle in ipairs(vns.avoider.obstacles) do
				avoid_speed.positionV3 = 
					--[[
					Avoider.add(childR.positionV3, obstacle.positionV3,
								avoid_speed.positionV3,
					            0.20)
					--]]
					Avoider.addObstacleForce(childR.positionV3, obstacle.positionV3,
								avoid_speed.positionV3,
					            0.15)
			end
		end

		if surpress_or_not == true then
			childR.goalSpeed.positionV3 = avoid_speed.positionV3
		else
			childR.goalSpeed.positionV3 = 
				childR.goalSpeed.positionV3 + avoid_speed.positionV3
		end
	end
	
	-- avoid predator
	for j, obstacle in ipairs(vns.avoider.obstacles) do
		if obstacle.robotTypeS == "block" and obstacle.type == 0 then
			local speed = tonumber(robot.params.run_away_speed or 0.1)
			vns.Spreader.emergency(vns, vector3(speed, 0, 0), vector3()) -- TODO: run away from predator
		end
		if obstacle.robotTypeS == "block" and obstacle.type == 4 then
			vns.Spreader.emergency(vns, vector3(), vector3(), "blue") -- TODO: run away from predator
		end
		if obstacle.robotTypeS == "block" and obstacle.type == 3 then
			vns.Spreader.emergency(vns, vector3(), vector3(), "green") -- TODO: run away from predator
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
		local scale = tonumber(robot.params.obstacle_scale or 0.010)
		local transV3 = scale / d / d * dV3
		if robot.params.obstacle_distance_level == "1" then
			transV3 = scale / d * dV3
		end
		ans = ans + transV3
	end
	return ans
end

function Avoider.addObstacleForce(myLocV3, obLocV3, accumulatorV3, threshold)
	local dV3 = myLocV3 - obLocV3
	local d = dV3:length()
	if d == 0 then return accumulatorV3 end
	local ans = accumulatorV3
	if d < threshold then
		dV3:normalize()
		local transV3 = 0.002 / d / d * dV3
		--transV3 = transV3:rotate(quaternion(math.pi/2, vector3()))
		transV3 = transV3:rotate(quaternion(0, vector3()))
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

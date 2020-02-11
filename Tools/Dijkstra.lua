function Dijkstra(w)
	-- w is a square of weight, w[i][j] = nil means no connect
	-- if w[i][j] is a table, means multiple connects between i and j
	-- find shortest path from 1 to i

	local INF = 1 / 0

	-- how many nodes
	local n = #w

	-- D[i] is the shortest distance from 1 to i
	local D = {0}
	-- D[i] is the unknown nodes
	local T = {}
	for i = 2, n do T[i] = INF end

	-- L[i] is the last node in the shortest path of i
	local L = {0}

	-- traverse all the nodes
	for i = 2, n do
		-- find a new shortest node
		local dis = INF
		local from = nil
		local to = nil
		-- from all known nodes
		for j, _ in pairs(D) do
			-- from all unknown nodes
			for k, _ in pairs(T) do
				if type(w[j][k]) == "table" then
					for l, _ in pairs(w[j][k]) do
						if type(w[j][k][l]) == "number" and D[j] + w[j][k][l] < dis then
							dis = D[j] + w[j][k][l]
							from = j
							to = k
						end
					end
				elseif type(w[j][k]) == "number" and D[j] + w[j][k] < dis then
					dis = D[j] + w[j][k]
					from = j
					to = k
				end
			end
		end

		-- see whether find one
		if from ~= nil then
			D[to] = dis
			L[to] = from
			T[to] = nil
		else
			-- no longer new nodes
			break
		end
	end

	return D, L
end

return Dijkstra

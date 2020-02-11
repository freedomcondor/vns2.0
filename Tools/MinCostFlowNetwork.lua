local Dijkstra = require("Dijkstra")

DMSG = require("DebugMessage")
DMSG.enable()

function MinCostFlowNetwork(c, w)
	local INF = 1/0
	-- w is the weight
	-- c is the capacity  c[i][j] = nil means no connect
	-- assume the flow is one-directional 
	-- if c[j][i] = xxx then c[j][i] = nil

	-- n is the number of nodes
	local n = #c

	-- f is the flow f[i][j] = flow
	local f = {}
	for i = 1, n do
		f[i] = {}
		for j = 1, n do
			if c[i][j] == nil then
				f[i][j] = nil
			else
				f[i][j] = 0
			end
		end
	end

	while true do
		-- create a substitule graph
		local g = {}
		for i = 1, n do g[i] = {} end
		for i = 1, n do
			for j = 1, n do
				if c[i][j] ~= nil then
					if f[i][j] <= 0 then
						g[i][j] = w[i][j]
					elseif f[i][j] >= c[i][j] then
						g[j][i] = -w[i][j]
					else
						g[i][j] = w[i][j]
						g[j][i] = -w[i][j]
					end
				end
			end
		end

		-- find the shortest path for the graph
		local D, L = Dijkstra(g)
		if D[n] == nil then
			break
		end

		-- find the max increment amount
		local amount = INF
		local node = n
		while node ~= 1 do
			local from = L[node]
			local edgeSpace
			if f[from][node] ~= nil then
				edgeSpace = c[from][node] - f[from][node]
			else
				edgeSpace = f[node][from]
			end

			if edgeSpace < amount then
				amount = edgeSpace
			end
			node = from
		end

		-- change f
		node = n
		while node ~= 1 do
			local from = L[node]
			if f[from][node] ~= nil then
				f[from][node] = f[from][node] + amount
			else
				f[node][from] = f[node][from] - amount
			end
			node = from
		end
	end

	return f
end

return MinCostFlowNetwork

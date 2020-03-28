rawpairs = pairs
alphapairs = function(intable)
	local index = {}
	for i, v in rawpairs(intable) do
		index[#index + 1] = i
	end
	table.sort(index)
	local i = 0;
	return 
	function()
		i = i + 1
		return index[i], intable[index[i]]
	end
end

return alphapairs

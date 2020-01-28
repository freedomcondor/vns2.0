--[[
--	Arrangement
--
--	Weixu Zhu
--	zhuweixu_harry@126.com
--
--	local arranger = Arrangement:newArranger{1, "aaa", {"nihao"}, 4, 5}
--	local result = arranger()
--		result = 1, "aaa", {"nihao"}, 4, 5
--	result = arranger()
--		result = 1, "aaa", {"nihao"}, 5, 4
--	result = arranger()
--		result = 1, "aaa", 4, {"nihao"}, 5
--	result = arranger()
--		result = 1, "aaa", 4, 5, {"nihao"}
--	..
--	until result = nil
--]]
local Arrangement = {}

function Arrangement:newArranger(array)
	-- array = {1 = xx, 2 = xx, 3 = xx}
	if #array == 0 then 
		local i = 1
		return function() 
			if i == 1 then 
				i = 0
				return {}
			else 
				return nil 
			end 
		end
	end

	local n = #array

	local head = array[1]
	local i = 1
	local subarray = {}
	for j = 2, n do subarray[j-1] = array[j] end
	local subarranger = Arrangement:newArranger(subarray)

	return function()
		local subresult = subarranger()
		if subresult == nil then
			if i == n then 
				return nil
			else
				i = i + 1
				head = array[i]
				for j = 1, i-1 do subarray[j] = array[j] end
				for j = i+1, n do subarray[j-1] = array[j] end
				subarranger = Arrangement:newArranger(subarray)
				subresult = subarranger()
			end
		end
		local result = {}
		result[1] = head
		for j = 2, n do result[j] = subresult[j-1] end
		return result
	end
end

return Arrangement

-----------------------------------------------------------
-- 	Weixu Zhu
-- 		zhuweixu_harry@126.com
--
-- 	Version 1.1 : 
-- 		add function for Vector3 and Quaternion recover
-- 	Version 2.0 :  
-- 		upgrade message searching problem
-- 	Version 3.0 :  
-- 		for vns2.0, delete vector3 and quaternion
-----------------------------------------------------------
local Message = {}

Message.list = {}
--[[
	ListArranged = true / nil
	"cmdname" = {list}
--]]

function Message.prestep()
	Message.list = {}
end

function Message.arrange()
	for iN, msgM in ipairs(Message.getTablesAT()) do
		if msgM.toS == Message.myIDS() then
			local i = #Message.list + 1
			Message.list[i] = msgM
			if Message.list[msgM.cmdS] == nil then
				Message.list[msgM.cmdS] = {}
			end
			local i = #Message.list[msgM.cmdS] + 1
			Message.list[msgM.cmdS][i] = msgM
		end
	end
	Message.list.ListArranged = true
end

function Message.send(toIDS, cmdS, dataT)
	Message.sendTable{
		toS = toIDS,
		fromS = Message.myIDS(),
		cmdS = cmdS,
		dataT = dataT,
	}
end

function Message.getAM(fromS, cmdS)
	if Message.list.ListArranged == nil then
		Message.arrange()
	end

	local listAM = {}
	local i = 0
	local searchList
	if cmdS == "ALLMSG" then searchList = Message.list
		                else searchList = Message.list[cmdS] or {} end
	for iN, msgM in ipairs(searchList) do
		if msgM.toS == Message.myIDS() then
		if fromS == "ALLMSG" or fromS == msgM.fromS then
		if cmdS == "ALLMSG" or cmdS == msgM.cmdS then
			i = i + 1
			listAM[i] = msgM
		end end end
	end

	return listAM
end

function Message.myIDS()
	print("Message.myIDS() needs to be implement")
end

function Message.sendTable(table)
	print("Message.sendTable() needs to be implement")
end

function Message.getTablesAT()
	print("Message.getTablesAT() needs to be implement")
end

return Message

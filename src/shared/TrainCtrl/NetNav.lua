local Networks = require(script.Parent.Networks)
local TrainSwitch = require(script.Parent.Switch)

local NetNav = {}

function SearchTroughConnection(Connection: number | table | nil, Value: number)
	if Connection == Value then
		return true
	end
	if type(Connection) == "table" then
		if table.find(Connection, Value) then
			return true
		end
	end
	return false
end

function NetNav.GetNextNode(From: number, To: number, TrainId: number, Network: number): number?
	local Net = Networks.GetNetwork(Network)
	if not Net then
		return
	end
	local ToNode = Net[To]
	local Direction: number? = nil
	local NextNode: number | table | nil = nil
	if SearchTroughConnection(ToNode.Fol, From) then
		Direction = false
		NextNode = ToNode.Pre
	else
		Direction = true
		NextNode = ToNode.Fol
	end
	print(Direction, NextNode)
	if type(NextNode) ~= "table" then
		return NextNode
	end
	local SwitchReturn = TrainSwitch.GetNextNode(To, Direction, TrainId, Network)
	return SwitchReturn and SwitchReturn or NextNode[1]
end

return table.freeze(NetNav)

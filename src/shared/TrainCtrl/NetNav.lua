local Networks = require(script.Parent.Networks)

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

function NetNav.GetNextNode(From: number, To: number, Network: number): number?
	local Net = Networks.GetNetwork(Network)
	if not Net or not From then
		return
	end
	local ToNode = Net[To]
	if SearchTroughConnection(ToNode.Fol, From) then
		return ToNode.Pre
	else
		return ToNode.Fol
	end
end

return table.freeze(NetNav)

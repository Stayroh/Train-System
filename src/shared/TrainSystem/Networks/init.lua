local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local NetworkInit = {}
local Types = require(TrainSystem.Types)

local Selection = {
	[1] = script.CurveTest,
}

local Networks = {}

function Insert(T, Value): number
	local Index = 1
	while T[Index] ~= nil do
		Index += 1
	end
	T[Index] = Value
	return Index
end

for i, v in pairs(Selection) do
	Networks[i] = table.freeze(require(v))
end

function NetworkInit:GetNetwork(Id: number): Types.NetworkType?
	return Networks[Id]
end

function NetworkInit:GetNode(NodeId: number, NetworkId: number): Types.NodeType
	local Net = Networks[NetworkId]
	return Net[NodeId]
end

function NetworkInit:Remove(NetworkId)
	Networks[NetworkId] = nil
end

function NetworkInit:Add(Network: Types.NetworkType): number
	return Insert(Networks, Network)
end

function NetworkInit:GetIdfromNetwork(Network: Types.NetworkType): number?
	return table.find(Networks, Network)
end

return NetworkInit

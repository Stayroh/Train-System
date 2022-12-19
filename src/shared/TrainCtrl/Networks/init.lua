local NetworkInit = {}

type Node = {
	Position: Vector3,
	Tangent: Vector3,
	UpVector: Vector3,
	Pre: number?,
	Fol: number?,
}

type NetworkType = { [number]: Node }

local Selection = {
	[1] = script.NetworkAlpha,
}

local Networks = {}

for i, v in pairs(Selection) do
	Networks[i] = table.freeze(require(v))
end

function NetworkInit:GetNetwork(Id: number): NetworkType?
	return Networks[Id]
end

function NetworkInit:GetIdfromNetwork(Network: NetworkType): number?
	return table.find(Networks, Network)
end

return table.freeze(NetworkInit)

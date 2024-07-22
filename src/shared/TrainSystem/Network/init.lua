local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local cache = {}
local Network: NetworkClass = {} :: NetworkClass

type NetworkClass = {
	__index: NetworkClass,
    getNode
	fromDescription: (description: { { position: Vector3, tangent: Vector3, roll: number, next: number, previous: number } }) -> Network,
    get:  (id: number) -> Network,
    remove: (id: number) -> nil,
}

export type Network = typeof(setmetatable(
    {} :: {
        nodes: { { position: Vector3, tangent: Vector3, roll: number, next: number, previous: number } }
    },
    Network
))

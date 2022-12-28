local Types = require(game.ReplicatedStorage.source.TrainCtrl.TrainClass)

local Train = {}
Train.__index = Train

local Constructors = {}

function Constructors.create(TrainId: number, Network: number, Wagons: table, From: number, To: number, T: number)
	local self = setmetatable({}, Train)
	self.Network = Network
	return self
end

return Constructors

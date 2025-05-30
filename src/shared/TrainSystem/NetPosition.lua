local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)

local Constructors = {}

function Constructors.new(From: number?, To: number?, T: number, Network: number): Types.TrainPosType
	local self = {}
	self.From = From
	self.To = To
	self.T = T
	self.Network = Network
	return self
end

return Constructors

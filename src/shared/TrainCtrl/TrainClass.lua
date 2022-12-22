local Train = {}
Train.__index = Train

local Constructors = {}

function Constructors.create(TrainId: number,)
	local self = setmetatable({},Train)
	self.Network
end

return Constructors

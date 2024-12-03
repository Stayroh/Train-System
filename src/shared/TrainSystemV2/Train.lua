--!strict

local Train: TrainClass = {} :: TrainClass
Train.__index = Train

type TrainClass = {
	__index: TrainClass,
	new: () -> Train,
}

export type Train = typeof(setmetatable({} :: {}, Train))

function Train.new(): Train
	local self = setmetatable({}, Train)
	return self
end

return Train

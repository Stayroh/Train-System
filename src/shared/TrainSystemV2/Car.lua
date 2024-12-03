--!strict

local Car: CarClass = {} :: CarClass
Car.__index = Car

type CarClass = {
	__index: CarClass,
	new: () -> Car,
}

export type Car = typeof(setmetatable(
	{} :: {
		name: string, -- Unique identifier for the car.
		wheelbase: number, --Distance between the front and rear bogies alignment points.
		interCarDistance: number?, -- Distance between the last bogie of this car and the first bogie of the next car. Can not exist on the last car.
	},
	Car
))

function Car.new(): Car
	local self = setmetatable({}, Car)
	return self
end

return Car

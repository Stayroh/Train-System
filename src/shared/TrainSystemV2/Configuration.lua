--!strict

export type Bogie = {
	name: string, -- Unique identifier for the bogie.
	primaryConnection: Vector3, -- The primary connection point of the bogie to the car.
	secondaryConnection: Vector3?, -- For shared bogies, the connetion point of the bogie to the secondary car. When exists, the following car will be forced to use the same bogie and not create their own.
	stiffness: number, -- The stiffness of the spring connecting the bogie to the car.
	damping: number, -- The damping of the spring connecting the bogie to the car.
	springOffset: number, -- The offset of the spring from the primary connection point.
	wheelRadius: number, -- The radius of the wheel. Used for updating the rotation of the wheel axis for visual connection between the wheel and the rail.
}

export type Car = {
	name: string, -- Unique identifier for the car.
	length: number, -- The length of the car.
	frontConnection: Vector3, -- The connection point of the front bogie to the car.
	rearConnection: Vector3, -- The connection point of the rear bogie to the car.
	bogie1: string, -- The unique identifier of the front bogie.
	bogie2: string, -- The unique identifier of the rear bogie.
	bogie1Reversed: boolean, -- If the front bogie is reversed. Mostly false
	bogie2Reversed: boolean, -- If the rear bogie is reversed. Mostly true
}

type Configuration = {
	cars: { [string]: Car },
	bogies: { [string]: Bogie },
}

local Configuration: Configuration = {
	cars = {
		sovietCarriage = {
			name = "SovietCarriage",
			length = 82,
			frontConnection = Vector3.new(0, 0.687, 27.592),
			rearConnection = Vector3.new(0, 0.687, -27.592),
			bogie1 = "SovietCarriageB",
			bogie2 = "SovietCarriageB",
			bogie1Reversed = false,
			bogie2Reversed = true,
		},
	},
	bogies = {
		sovietCarriageB = {
			name = "SovietCarriageB",
			primaryConnection = Vector3.new(0, -0.687, -27.592),
			stiffness = 100000,
			damping = 1000,
			springOffset = 0,
			wheelRadius = 0.5,
		},
	},
} :: Configuration

return Configuration

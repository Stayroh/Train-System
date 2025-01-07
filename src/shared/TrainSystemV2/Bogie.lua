--!strict
local Configuration = require(game.ReplicatedStorage.src.TrainSystemV2.Configuration)
local RouteNetwork = require(game.ReplicatedStorage.src.TrainSystemV2.RouteNetwork)

local Bogie: BogieClass = {} :: BogieClass
Bogie.__index = Bogie

type BogieClass = {
	__index: BogieClass,
	new: (
		name: string,
		routeNetwork: RouteNetwork.RouteNetwork,
		location: RouteNetwork.RouteNetworkLocation,
		reversed: boolean
	) -> Bogie,
	setLocation: (self: Bogie, location: RouteNetwork.RouteNetworkLocation) -> (),
	getConnection: (self: Bogie) -> CFrame,
	updatePhysics: (self: Bogie, speed: number, deltaTime: number) -> (),
	getZOffset: (self: Bogie) -> number,
}

export type Bogie = typeof(setmetatable(
	{} :: {
		name: string, -- Unique identifier for the bogie.
		model: Model, -- The model of the bogie.
		reversed: boolean, -- If the bogie is reversed.
		routeNetwork: RouteNetwork.RouteNetwork, -- The route network the bogie is on.
		location: RouteNetwork.RouteNetworkLocation, -- The location of the bogie on the route network.
		cf: CFrame, -- The CFrame of the bogie.
		lastCF: CFrame?, -- The last CFrame of the bogie.
		joint: Vector3, -- The primary connection point of the bogie to the car.
		stiffness: number, -- The stiffness of the spring connecting the bogie to the car.
		mass: number, -- Sum of the Mass of the attached Cars divided by the amount of it carrying bogies.
		damping: number, -- The damping of the spring connecting the bogie to the car.
		wheelRadius: number, -- The radius of the wheel. Used for updating the rotation of the wheel axis for visual connection between the wheel and the rail.
		shared: boolean, -- If the bogie is shared between cars. Mostly false
		springDisplacement: number, -- The displacement of the spring pivot.
		springVelocity: number, -- The velocity of the spring pivot.
		springOffset: number, -- The offset of the spring from the primary connection point.
	},
	Bogie
))

function Bogie:getConnection(): CFrame
	local offset = self.joint + self.springDisplacement * Vector3.new(0, 1, 0)
	return self.cf:ToWorldSpace(CFrame.new(offset))
end

function Bogie:getZOffset(): number
	return self.reversed and -self.joint.Z or self.joint.Z -- From perspective of the car
end

function Bogie:setLocation(location: RouteNetwork.RouteNetworkLocation)
	local cf = self.routeNetwork:getCFrames(location)
	cf = self.routeNetwork.displacementModifier + cf
	self.location = location
	local newCF = self.reversed and cf * CFrame.Angles(0, math.pi, 0) or cf
	self.lastCF = self.lastCF and self.cf or newCF
	self.cf = newCF
	self.model:PivotTo(self.cf)
end

function Bogie:updatePhysics(speed: number, deltaTime: number)
	--Update the visual rotation of each axle
	local rotationStep = speed * deltaTime / self.wheelRadius
	for i, axleValue in pairs(self.model:GetChildren()) do
		if axleValue.Name ~= "Axle" then
			continue
		end
		local axle = axleValue.Value
		axle.Transform = axle.Transform * CFrame.Angles(rotationStep, 0, 0)
	end

	--Update the spring physics
	self.springVelocity = self.lastCF and (self.springVelocity * self.lastCF.UpVector):Dot(self.cf.UpVector)
		or self.springVelocity

	local deltaHeight = self.lastCF
			and (self.springDisplacement - (self.cf.Position - self.lastCF.Position):Dot(self.lastCF.UpVector)) / self.cf.UpVector:Dot(
				self.lastCF.UpVector
			)
		or self.springDisplacement

	local bogieVelocity = self.lastCF and (self.cf.Position - self.lastCF.Position) / deltaTime or Vector3.new(0, 0, 0)
	local onAxisBogieVelocity = self.cf.UpVector:Dot(bogieVelocity)
	local springForce = -(deltaHeight - self.springOffset + self.springVelocity * deltaTime) * self.stiffness
	local dampingForce = -(self.springVelocity - onAxisBogieVelocity) * self.damping
	local gravityAcceleration = 40 * Vector3.new(0, -1, 0):Dot(self.cf.UpVector)
	local totalAccerelation = (springForce + dampingForce) / self.mass + gravityAcceleration
	local distance = totalAccerelation * deltaTime ^ 2 / 2 + self.springVelocity * deltaTime
	self.springVelocity += totalAccerelation * deltaTime
	local newSpringLength = distance + deltaHeight
	if newSpringLength > 10 then
		self.springVelocity = math.min(self.springVelocity, onAxisBogieVelocity)
		newSpringLength = math.clamp(newSpringLength, -10, 10)
	elseif newSpringLength < -10 then
		self.springVelocity = math.max(self.springVelocity, onAxisBogieVelocity)
		newSpringLength = math.clamp(newSpringLength, -10, 10)
	end
	self.springDisplacement = newSpringLength
end

function Bogie.new(
	name: string,
	routeNetwork: RouteNetwork.RouteNetwork,
	location: RouteNetwork.RouteNetworkLocation,
	reversed: boolean
): Bogie
	local self = setmetatable({}, Bogie) :: Bogie
	local thisConfig = Configuration.bogies[name]
	self.name = name
	self.routeNetwork = routeNetwork
	self.reversed = reversed
	self.joint = thisConfig.joint
	self.stiffness = thisConfig.stiffness * thisConfig.mass
	self.damping = thisConfig.damping * thisConfig.mass
	self.wheelRadius = thisConfig.wheelRadius
	self.shared = thisConfig.shared
	self.springOffset = thisConfig.springOffset
	self.mass = thisConfig.mass
	self.model = game.ReplicatedStorage.assets.Trains:findFirstChild(name, true):Clone()
	self.location = location
	self.cf = CFrame.new(0, 0, 0)
	self.lastCF = nil
	self.springDisplacement = 0
	self.springVelocity = 0
	return self
end

return Bogie

--!strict
local Spline = {}
Spline.__index = Spline

export type self = typeof(setmetatable(
	{} :: {
		StartPosition: Vector3,
		EndPosition: Vector3,
		StartTangent: Vector3,
		EndTangent: Vector3,
	},
	Spline
))

function Spline:Compute(t: number): Vector3 -- Bezier Spline
	self = self :: self
	local t2 = t * t
	local t3 = t2 * t
	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition
	return P0 * (1 - t) ^ 3 + P1 * 3 * t * (1 - t) ^ 2 + P2 * 3 * t2 * (1 - t) + P3 * t3
end

function Spline:ComputeTangent(t: number): Vector3
	self = self :: self
	local t2 = t * t

	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition

	-- Calculate the derivative of the Bezier spline
	local tangent = P0 * (-3 * (1 - t) ^ 2)
		+ P1 * (3 * (1 - t) ^ 2 - 6 * t * (1 - t))
		+ P2 * (6 * t * (1 - t) - 3 * t2)
		+ P3 * (3 * t2)

	return tangent
end

function Spline:ComputeAcceleration(t: number): Vector3
	self = self :: self

	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition

	-- Calculate the second derivative of the Bezier spline
	local acceleration = P0 * (6 * (1 - t)) + P1 * (-12 * (1 - t) + 6 * t) + P2 * (12 * (1 - t) - 6 * t) + P3 * (6 * t)

	return acceleration
end

function Spline.new(StartPosition: Vector3, EndPosition: Vector3, StartTangent: Vector3, EndTangent: Vector3): self
	local self: self = setmetatable({}, Spline) :: self
	self.StartPosition = StartPosition
	self.EndPosition = EndPosition
	self.StartTangent = StartTangent
	self.EndTangent = EndTangent
	return self
end

return Spline

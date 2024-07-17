--!strict
local Spline: SplineClass = {} :: SplineClass
Spline.__index = Spline

type SplineClass = {
	__index: SplineClass,
	computePoint: (self: Spline, t: number) -> Vector3,
	computeTangent: (self: Spline, t: number) -> Vector3,
	computeAcceleration: (self: Spline, t: number) -> Vector3,
	stepDistance: (self: Spline, t: number, distance: number, substeps: number) -> (number, boolean),
	new: (StartPosition: Vector3, EndPosition: Vector3, StartTangent: Vector3, EndTangent: Vector3) -> Spline,
}

export type Spline = typeof(setmetatable(
	{} :: {
		StartPosition: Vector3,
		EndPosition: Vector3,
		StartTangent: Vector3,
		EndTangent: Vector3,
	},
	Spline
))

function Spline:computePoint(t: number): Vector3
	local t2 = t * t
	local t3 = t2 * t
	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition
	return P0 * (1 - t) ^ 3 + P1 * 3 * t * (1 - t) ^ 2 + P2 * 3 * t2 * (1 - t) + P3 * t3
end

function Spline:computeTangent(t: number): Vector3
	local t2 = t * t

	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition

	local tangent = P0 * (-3 * (1 - t) ^ 2)
		+ P1 * (3 * (1 - t) ^ 2 - 6 * t * (1 - t))
		+ P2 * (6 * t * (1 - t) - 3 * t2)
		+ P3 * (3 * t2)

	return tangent
end

function Spline:computeAcceleration(t: number): Vector3
	local P0 = self.StartPosition
	local P1 = self.StartPosition + self.StartTangent
	local P2 = self.EndPosition - self.EndTangent
	local P3 = self.EndPosition

	local acceleration = P0 * (6 * (1 - t)) + P1 * (-12 * (1 - t) + 6 * t) + P2 * (12 * (1 - t) - 6 * t) + P3 * (6 * t)

	return acceleration
end

function Spline:stepDistance(t: number, distance: number, substeps: number): (number, boolean)
	if distance == 0 or substeps == 0 then
		return t, false
	end
	distance = distance / substeps
	for i = 1, substeps do
		local speed = self:computeTangent(t).Magnitude
		local deltaT = distance / speed
		t += deltaT
		if t >= 1 then
			local limitedT = 1 - t + deltaT
			local coveredDistance = (i - 1) * distance + limitedT * speed
			return distance - coveredDistance, true
		elseif t < 0 then
			local limitedT = -t + deltaT
			local coveredDistance = (i - 1) * distance + limitedT * speed
			return distance - coveredDistance, true
		end
	end
	return t, false
end

function Spline.new(StartPosition: Vector3, EndPosition: Vector3, StartTangent: Vector3, EndTangent: Vector3): Spline
	local self = setmetatable({}, Spline) :: Spline
	self.StartPosition = StartPosition
	self.EndPosition = EndPosition
	self.StartTangent = StartTangent
	self.EndTangent = EndTangent
	return self
end

return Spline

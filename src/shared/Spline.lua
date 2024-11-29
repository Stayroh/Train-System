--!strict
local Spline: SplineClass = {} :: SplineClass
Spline.__index = Spline

type SplineClass = {
	__index: SplineClass,
	getPoint: (self: Spline, t: number) -> Vector3,
	getTangent: (self: Spline, t: number) -> Vector3,
	getAcceleration: (self: Spline, t: number) -> Vector3,
	stepDistance: (self: Spline, t: number, distance: number, substeps: number) -> (number, boolean),
	new: (StartPosition: Vector3, EndPosition: Vector3, StartTangent: Vector3, EndTangent: Vector3) -> Spline,
}

export type Spline = typeof(setmetatable(
	{} :: {
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
	},
	Spline
))

function Spline:getPoint(t: number): Vector3
	local t2 = t * t
	local t3 = t2 * t
	return self.P0 * (1 - t) ^ 3 + self.P1 * 3 * t * (1 - t) ^ 2 + self.P2 * 3 * t2 * (1 - t) + self.P3 * t3
end

function Spline:getTangent(t: number): Vector3
	local t2 = t * t

	local tangent = self.P0 * (-3 * (1 - t) ^ 2)
		+ self.P1 * (3 * (1 - t) ^ 2 - 6 * t * (1 - t))
		+ self.P2 * (6 * t * (1 - t) - 3 * t2)
		+ self.P3 * (3 * t2)

	return tangent
end

function Spline:getAcceleration(t: number): Vector3
	local acceleration = self.P0 * (6 * (1 - t))
		+ self.P1 * (-12 * (1 - t) + 6 * t)
		+ self.P2 * (12 * (1 - t) - 6 * t)
		+ self.P3 * (6 * t)

	return acceleration
end

function Spline:stepDistance(t: number, distance: number, substeps: number): (number, boolean)
	if distance == 0 or substeps == 0 then
		return t, false
	end
	distance = distance / substeps
	for i = 1, substeps do
		local speed = self:getTangent(t).Magnitude
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

function Spline.new(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3): Spline
	local self = setmetatable({}, Spline) :: Spline
	self.P0 = P0
	self.P1 = P1
	self.P2 = P2
	self.P3 = P3
	local matrixForm = {
		{ 1, 0, 0, 0 },
		{ -3, 3, 0, 0 },
		{ 3, -6, 3, 0 },
		{ -1, 3, -3, 1 },
	}

	return self
end

return Spline

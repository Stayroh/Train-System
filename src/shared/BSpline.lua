--!strict
local Matrix = require(game.ReplicatedStorage.src.Matrix)

local BSpline: BSplineClass = {} :: BSplineClass
BSpline.__index = BSpline

type BSplineClass = {
	__index: BSplineClass,
	getPoint: (self: BSpline, t: number) -> Vector3,
	getTangent: (self: BSpline, t: number) -> Vector3,
	getAcceleration: (self: BSpline, t: number) -> Vector3,
	stepDistance: (self: BSpline, t: number, distance: number, substeps: number) -> (number, boolean),
	new: (
		StartPosition: Vector3,
		EndPosition: Vector3,
		StartTangent: Vector3,
		EndTangent: Vector3
	) -> BSpline,
}

export type BSpline = typeof(setmetatable(
	{} :: {
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
		matrixFormParameterized: Matrix.Matrix,
		dtMatrixFormParameterized: Matrix.Matrix,
		dt2MatrixFormParameterized: Matrix.Matrix,
	},
	BSpline
))

function BSpline:getPoint(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.matrixFormParameterized):getAsVector3()
end

function BSpline:getTangent(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.dtMatrixFormParameterized):getAsVector3()
end

function BSpline:getAcceleration(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.dt2MatrixFormParameterized):getAsVector3()
end

function BSpline:stepDistance(t: number, distance: number, substeps: number): (number, boolean)
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

function BSpline.new(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3): BSpline
	local self = setmetatable({}, BSpline) :: BSpline
	self.P0 = P0
	self.P1 = P1
	self.P2 = P2
	self.P3 = P3
	local pointMatrix = Matrix.new({ P0, P1, P2, P3 })
	self.matrixFormParameterized = Matrix.new({
		{ 1, 4, 1, 0 },
		{ -3, 0, 3, 0 },
		{ 3, -6, 3, 0 },
		{ -1, 3, -3, 1 },
	}) * pointMatrix * (1 / 6)
	self.dtMatrixFormParameterized = Matrix.new({
		{ -3, 0, 3, 0 },
		{ 6, -12, 6, 0 },
		{ -3, 9, -9, 3 },
		{ 0, 0, 0, 0 },
	}) * pointMatrix * (1 / 6)
	self.dt2MatrixFormParameterized = Matrix.new({
		{ 6, -12, 6, 0 },
		{ -6, 18, -18, 6 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
	}) * pointMatrix * (1 / 6)
	return self
end

return BSpline

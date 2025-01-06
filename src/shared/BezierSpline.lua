--!strict
local DisplacementModifier = require(game.ReplicatedStorage.src.DisplacementModifier)
local SplineSuper = require(game.ReplicatedStorage.src.SplineSuper)
local Matrix = require(game.ReplicatedStorage.src.Matrix)

local BezierSpline: BezierSplineClass = {} :: BezierSplineClass
BezierSpline.__index = BezierSpline
setmetatable(BezierSpline, SplineSuper)

type BezierSplineClass = {
	__index: BezierSplineClass,
	new: (
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
		displacementModifier: DisplacementModifier.DisplacementModifier?
	) -> BezierSpline,
	getBounds: (self: BezierSpline) -> Region3,
}

export type BezierSpline = typeof(setmetatable({} :: {}, BezierSpline)) & SplineSuper.SplineSuper

function BezierSpline:getBounds(): Region3
	local solvedForTMatrix = Matrix.new({
		{ -3, 9, -9, 3 },
		{ 6, -12, 6, 0 },
		{ -3, 3, 0, 0 },
	})

	local pointMatrix = Matrix.new({ self.P0, self.P1, self.P2, self.P3 })

	local abcMatrix = solvedForTMatrix * pointMatrix
	local minBounds, maxBounds = { math.huge, math.huge, math.huge }, { -math.huge, -math.huge, -math.huge }
	--Marginal cases first

	for t = 0, 1 do
		local point = self:getPoint(t)
		minBounds[1] = math.min(minBounds[1], point.X)
		minBounds[2] = math.min(minBounds[2], point.Y)
		minBounds[3] = math.min(minBounds[3], point.Z)
		maxBounds[1] = math.max(maxBounds[1], point.X)
		maxBounds[2] = math.max(maxBounds[2], point.Y)
		maxBounds[3] = math.max(maxBounds[3], point.Z)
	end

	for i = 1, 3 do
		local a, b, c = abcMatrix[1][i], abcMatrix[2][i], abcMatrix[3][i]
		local discriminant = b ^ 2 - 4 * a * c
		local tValues = {}
		if discriminant > 0 then
			local t1 = (-b + math.sqrt(discriminant)) / (2 * a)
			local t2 = (-b - math.sqrt(discriminant)) / (2 * a)
			if 0 <= t1 and t1 <= 1 then
				table.insert(tValues, t1)
			end
			if 0 <= t2 and t2 <= 1 then
				table.insert(tValues, t2)
			end
		elseif discriminant == 0 then
			local t = -b / (2 * a)
			if 0 <= t and t <= 1 then
				table.insert(tValues, t)
			end
		end

		for j = 1, #tValues do
			local point = self:getPoint(tValues[j])
			minBounds[i] = math.min(minBounds[i], i == 1 and point.X or i == 2 and point.Y or point.Z)
			maxBounds[i] = math.max(maxBounds[i], i == 1 and point.X or i == 2 and point.Y or point.Z)
		end
	end
	return Region3.new(
		Vector3.new(minBounds[1], minBounds[2], minBounds[3]),
		Vector3.new(maxBounds[1], maxBounds[2], maxBounds[3])
	)
end

function BezierSpline.new(
	P0: Vector3,
	P1: Vector3,
	P2: Vector3,
	P3: Vector3,
	displacementModifier: DisplacementModifier.DisplacementModifier?
): BezierSpline
	local matrixForm = Matrix.new({
		{ 1, 0, 0, 0 },
		{ -3, 3, 0, 0 },
		{ 3, -6, 3, 0 },
		{ -1, 3, -3, 1 },
	})

	local dtMatrixForm = Matrix.new({
		{ -3, 3, 0, 0 },
		{ 6, -12, 6, 0 },
		{ -3, 9, -9, 3 },
		{ 0, 0, 0, 0 },
	})

	local dt2MatrixForm = Matrix.new({
		{ 6, -12, 6, 0 },
		{ -6, 18, -18, 6 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
	})

	local self = setmetatable(
		SplineSuper.new(P0, P1, P2, P3, matrixForm, dtMatrixForm, dt2MatrixForm, displacementModifier) :: BezierSpline,
		BezierSpline
	) :: BezierSpline

	return self
end

return BezierSpline

--!strict
local SplineSuper = require(game.ReplicatedStorage.src.SplineSuper)
local Matrix = require(game.ReplicatedStorage.src.Matrix)

local BezierSpline: BezierSplineClass = {} :: BezierSplineClass
BezierSpline.__index = BezierSpline
setmetatable(BezierSpline, SplineSuper)

type BezierSplineClass = {
	__index: BezierSplineClass,
	new: (P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3) -> BezierSpline,
}

export type BezierSpline = typeof(setmetatable({} :: {}, BezierSpline)) & SplineSuper.SplineSuper

function BezierSpline.new(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3): BezierSpline
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
		SplineSuper.new(P0, P1, P2, P3, matrixForm, dtMatrixForm, dt2MatrixForm) :: BezierSpline,
		BezierSpline
	) :: BezierSpline

	return self
end

return BezierSpline

--!strict
local SplineSuper = require(game.ReplicatedStorage.src.SplineSuper)
local Matrix = require(game.ReplicatedStorage.src.Matrix)

local BSpline: BSplineClass = {} :: BSplineClass
BSpline.__index = BSpline
setmetatable(BSpline, SplineSuper)

type BSplineClass = {
	__index: BSplineClass,
	new: (P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3) -> BSpline,
}

export type BSpline = typeof(setmetatable({} :: {}, BSpline)) & SplineSuper.SplineSuper

function BSpline.new(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3): BSpline
	local matrixForm = Matrix.new({
		{ 1, 4, 1, 0 },
		{ -3, 0, 3, 0 },
		{ 3, -6, 3, 0 },
		{ -1, 3, -3, 1 },
	}) * (1 / 6)

	local dtMatrixForm = Matrix.new({
		{ -3, 0, 3, 0 },
		{ 6, -12, 6, 0 },
		{ -3, 9, -9, 3 },
		{ 0, 0, 0, 0 },
	}) * (1 / 6)

	local dt2MatrixForm = Matrix.new({
		{ 6, -12, 6, 0 },
		{ -6, 18, -18, 6 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
	}) * (1 / 6)

	local self = setmetatable(
		SplineSuper.new(P0, P1, P2, P3, matrixForm, dtMatrixForm, dt2MatrixForm) :: BSpline,
		BSpline
	) :: BSpline

	return self
end

return BSpline

--!strict
local Matrix = require(game.ReplicatedStorage.src.Matrix)

local BezierConverter: BezierConverter = {} :: BezierConverter

export type BezierConversion = {
	startPosition: Vector3,
	startHandle: Vector3,
	endPosition: Vector3,
	endHandle: Vector3,
}

type BezierConverter = {
	__index: BezierConverter,
	new: () -> BezierConverter,
	convert: (self: BezierConverter, P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3) -> BezierConversion,
}

function BezierConverter:convert(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3): BezierConversion
	local pointMatrix = Matrix.new({ P0, P1, P2, P3 })

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

	local matrixFormParameterized = matrixForm * pointMatrix
	local dtMatrixFormParameterized = dtMatrixForm * pointMatrix

	local startTVector = Matrix.new({ { 1, 0, 0, 0 } })
	local endTVector = Matrix.new({ { 1, 1, 1, 1 } })

	local startPoint = (startTVector * matrixFormParameterized):getAsVector3()
	local startVelocity = (startTVector * dtMatrixFormParameterized):getAsVector3()
	local endPoint = (endTVector * matrixFormParameterized):getAsVector3()
	local endVelocity = (endTVector * dtMatrixFormParameterized):getAsVector3()

	return {
		startPosition = startPoint,
		startHandle = startVelocity / 3,
		endPosition = endPoint,
		endHandle = -endVelocity / 3,
	}
end

return BezierConverter

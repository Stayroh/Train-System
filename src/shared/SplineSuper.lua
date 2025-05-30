--!strict
local Matrix = require(game.ReplicatedStorage.src.Matrix)
local Polynomial = require(game.ReplicatedStorage.src.Polynomial)
local SplineLut = require(game.ReplicatedStorage.src.SplineLut)
local DisplacementModifier = require(game.ReplicatedStorage.src.DisplacementModifier)
local SplineSuper: SplineSuperSuperClass = {} :: SplineSuperSuperClass
SplineSuper.__index = SplineSuper

type SplineSuperSuperClass = {
	__index: SplineSuperSuperClass,
	getPoint: (self: SplineSuper, t: number) -> Vector3,
	getVelocity: (self: SplineSuper, t: number) -> Vector3,
	getAcceleration: (self: SplineSuper, t: number) -> Vector3,
	intersectSphere: (
		self: SplineSuper,
		center: Vector3,
		radius: number,
		startTValue: number,
		direction: boolean
	) -> number?,
	new: (
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
		matrixForm: Matrix.Matrix,
		dtMatrixForm: Matrix.Matrix,
		dt2MatrixForm: Matrix.Matrix,
		displacementModifier: DisplacementModifier.DisplacementModifier?
	) -> SplineSuper,
}

export type SplineSuper = typeof(setmetatable(
	{} :: {
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
		matrixFormParameterized: Matrix.Matrix,
		dtMatrixFormParameterized: Matrix.Matrix,
		dt2MatrixFormParameterized: Matrix.Matrix,
		lut: SplineLut.SplineLut,
		displacementModifier: DisplacementModifier.DisplacementModifier?,
	},
	SplineSuper
))

function SplineSuper:intersectSphere(center: Vector3, radius: number, startTValue: number, direction: boolean): number?
	local centerArray = { center.X, center.Y, center.Z }
	local polynomialSum = Polynomial.new({ -radius ^ 2, 0, 0, 0, 0, 0, 0 })
	for d = 1, 3 do
		local rowVector = {
			self.matrixFormParameterized[1][d] - centerArray[d],
			self.matrixFormParameterized[2][d],
			self.matrixFormParameterized[3][d],
			self.matrixFormParameterized[4][d],
		}
		local squaredMatrix = Matrix.new({ { rowVector[1] }, { rowVector[2] }, { rowVector[3] }, { rowVector[4] } })
			* Matrix.new({ rowVector })
		local squaredPolynomialMatrix = squaredMatrix:getAntiDiagonalSum()
		local squaredPolynomial = Polynomial.new(squaredPolynomialMatrix[1])
		polynomialSum = polynomialSum + squaredPolynomial
	end
	local t = polynomialSum:sampledBisection(startTValue, direction and 1 or 0, 50, 50, 0.00001)
	return t
end

function SplineSuper:getPoint(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	local point = (tVector * self.matrixFormParameterized):getAsVector3()
	return point
end

function SplineSuper:getVelocity(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.dtMatrixFormParameterized):getAsVector3()
end

function SplineSuper:getAcceleration(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.dt2MatrixFormParameterized):getAsVector3()
end

function SplineSuper.new(
	P0: Vector3,
	P1: Vector3,
	P2: Vector3,
	P3: Vector3,
	matrixForm: Matrix.Matrix,
	dtMatrixForm: Matrix.Matrix,
	dt2MatrixForm: Matrix.Matrix,
	displacementModifier: DisplacementModifier.DisplacementModifier?
): SplineSuper
	local self = setmetatable({}, SplineSuper) :: SplineSuper
	self.P0 = P0
	self.P1 = P1
	self.P2 = P2
	self.P3 = P3
	local pointMatrix = Matrix.new({ P0, P1, P2, P3 })
	self.matrixFormParameterized = matrixForm * pointMatrix
	self.dtMatrixFormParameterized = dtMatrixForm * pointMatrix
	self.dt2MatrixFormParameterized = dt2MatrixForm * pointMatrix
	self.displacementModifier = displacementModifier
	self.lut = SplineLut.generate(self, 100, 100)
	return self
end

return SplineSuper

--!strict
local Matrix = require(game.ReplicatedStorage.src.Matrix)
local SplineLut = require(game.ReplicatedStorage.src.SplineLut)
local SplineSuper: SplineSuperSuperClass = {} :: SplineSuperSuperClass
SplineSuper.__index = SplineSuper

type SplineSuperSuperClass = {
	__index: SplineSuperSuperClass,
	getPoint: (self: SplineSuper, t: number) -> Vector3,
	getVelocity: (self: SplineSuper, t: number) -> Vector3,
	getAcceleration: (self: SplineSuper, t: number) -> Vector3,
	new: (
		P0: Vector3,
		P1: Vector3,
		P2: Vector3,
		P3: Vector3,
		matrixForm: Matrix.Matrix,
		dtMatrixForm: Matrix.Matrix,
		dt2MatrixForm: Matrix.Matrix
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
	},
	SplineSuper
))

function SplineSuper:getPoint(t: number): Vector3
	local tVector = Matrix.new({ { 1, t, t ^ 2, t ^ 3 } })
	return (tVector * self.matrixFormParameterized):getAsVector3()
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
	dt2MatrixForm: Matrix.Matrix
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
	self.lut = SplineLut.generate(self, 100, 100)
	return self
end

return SplineSuper

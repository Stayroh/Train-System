local Matrix: MatrixClass = {} :: MatrixClass
Matrix.__index = Matrix

type MatrixClass = {
	__index: MatrixClass,
	__eq: (lhs: Matrix, rhs: Matrix) -> boolean,
	__mul: (lhs: Matrix, rhs: Matrix | Vector3 | Vector2 | number) -> Matrix,
	new: (values: { { number } } | { Vector3 } | { Vector2 } | Vector3 | Vector2 | number) -> Matrix,
	getAsVector3: (self: Matrix) -> Vector3,
	getAsVector2: (self: Matrix) -> Vector2,
	getVector3FromRow: (self: Matrix, row: number) -> Vector3,
	getVector2FromRow: (self: Matrix, row: number) -> Vector2,
	getVector3FromColumn: (self: Matrix, column: number) -> Vector3,
	getVector2FromColumn: (self: Matrix, column: number) -> Vector2,
	getDiagonalSum: (self: Matrix) -> Matrix,
	getAntiDiagonalSum: (self: Matrix) -> Matrix,
}

export type Matrix = typeof(setmetatable({} :: { { any } }, Matrix))

function Matrix.__eq(lhs: Matrix, rhs: Matrix): boolean
	if #lhs ~= #rhs or #lhs[1] ~= #rhs[1] then
		return false
	end
	for i = 1, #lhs do
		for j = 1, #lhs[1] do
			if lhs[i][j] ~= rhs[i][j] then
				return false
			end
		end
	end
	return true
end

function Matrix.__mul(lhs: Matrix, rhs: Matrix | Vector3 | Vector2 | number): Matrix
	if type(rhs) == "number" then
		local result = {}
		for i = 1, #lhs do
			result[i] = {}
			for j = 1, #lhs[1] do
				result[i][j] = lhs[i][j] * rhs
			end
		end
		return setmetatable(result, Matrix) :: Matrix
	end

	if typeof(rhs) == "Vector3" or typeof(rhs) == "Vector2" then
		rhs = Matrix.new(rhs)
	end

	local resultWidth = #rhs[1]
	local resultHeight = #lhs
	local result = {}
	for i = 1, resultHeight do
		result[i] = {}
		for j = 1, resultWidth do
			local sum = 0
			for k = 1, #lhs[1] do
				sum += lhs[i][k] * rhs[k][j]
			end
			result[i][j] = sum
		end
	end
	return setmetatable(result, Matrix) :: Matrix
end

function Matrix:getAsVector3(): Vector3
	if #self > 1 then
		return Vector3.new(self[1][1], self[2] and self[2][1] or 0, self[3] and self[3][1] or 0)
	else
		return Vector3.new(self[1][1], self[1][2] or 0, self[1][3] or 0)
	end
end

function Matrix:getAsVector2(): Vector2
	if #self > 1 then
		return Vector2.new(self[1][1], self[2] and self[2][1] or 0)
	else
		return Vector2.new(self[1][1], self[1][2] or 0)
	end
end

function Matrix:getVector3FromRow(row: number): Vector3
	if row > #self then
		return Vector3.new()
	end
	return Vector3.new(self[row][1], self[row][2] or 0, self[row][3] or 0)
end

function Matrix:getVector2FromRow(row: number): Vector2
	if row > #self then
		return Vector2.new()
	end
	return Vector2.new(self[row][1], self[row][2] or 0)
end

function Matrix:getVector3FromColumn(column: number): Vector3
	if column > #self[1] then
		return Vector3.new()
	end
	return Vector3.new(self[1][column], self[2] and self[2][column] or 0, self[3] and self[3][column] or 0)
end

function Matrix:getVector2FromColumn(column: number): Vector2
	if column > #self[1] then
		return Vector2.new()
	end
	return Vector2.new(self[1][column], self[2] and self[2][column] or 0)
end

function Matrix:getAntiDiagonalSum(): Matrix
	local result = {}
	for i = 1, #self do
		for j = 1, #self[1] do
			local resultIndex = i + j - 1
			if not result[resultIndex] then
				result[resultIndex] = 0
			end
			result[resultIndex] += self[i][j]
		end
	end
	return setmetatable({ result }, Matrix) :: Matrix
end

function Matrix:getDiagonalSum(): Matrix
	local result = {}
	for i = 1, #self do
		for j = 1, #self[1] do
			local resultIndex = -i + j + #self
			if not result[resultIndex] then
				result[resultIndex] = 0
			end
			result[resultIndex] += self[i][j]
		end
	end
	return setmetatable({ result }, Matrix) :: Matrix
end

function Matrix.new(values: { { number } } | { Vector3 } | { Vector2 } | Vector3 | Vector2 | number): Matrix
	if type(values) == "number" then
		values = { { values } }
	elseif typeof(values) == "Vector3" then
		values = { { values.X }, { values.Y }, { values.Z } }
	elseif typeof(values) == "Vector2" then
		values = { { values.X }, { values.Y } }
	elseif type(values) ~= "table" then
		assert(nil, string.format("Invalid datatype for Matrix.new() got %s", typeof(values)))
	end
	local self = setmetatable({}, Matrix) :: Matrix
	local data = values :: { any }
	for i, v in pairs(data) do
		if typeof(v) == "Vector3" then
			data[i] = { v.X, v.Y, v.Z }
			continue
		elseif typeof(v) == "Vector2" then
			data[i] = { v.X, v.Y }
			continue
		elseif type(v) ~= "table" then
			assert(nil, string.format("Invalid datatype for Matrix.new() subcomponent got %s", typeof(v)))
		end
	end
	for i = 1, #data do
		local subarray = {}
		for j = 1, #data[1] do
			local v = data[i][j]
			if type(v) ~= "number" and v ~= nil then
				assert(nil, string.format("Invalid datatype for Matrix.new() field entry got %s", typeof(v)))
			elseif v == nil then
				v = 0
			end
			subarray[j] = v
		end
		self[i] = subarray
	end
	return self
end

return Matrix

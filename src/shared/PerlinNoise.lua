--!strict
--Module for 2D Perlin Noise and its gradient vector

local PerlinNoise = {}

local Permutation = require(game.ReplicatedStorage.src.Permutation)

function PerlinNoise:HashVector(input: Vector2): Vector2
	local x = math.floor(input.X)
	local y = math.floor(input.Y) + 1
	local xHash = Permutation[(Permutation[x % 256 + 1] + y) % 256 + 1] / 255 - 0.5
	local yHash = Permutation[(Permutation[y % 256 + 1] + x + 10) % 256 + 1] / 255 - 0.5
	return Vector2.new(xHash, yHash).Unit
end

function PerlinNoise:smootherstep(t: number): number
	return t * t * t * (t * (t * 6 - 15) + 10)
end

function PerlinNoise:smootherstep_derivative(t: number): number
	return 30 * t * t * (t * (t - 2) + 1)
end

function PerlinNoise:Compute(input: Vector2)
	local a_pos = Vector2.new(math.floor(input.X), math.floor(input.Y))
	local b_pos = Vector2.new(math.floor(input.X) + 1, math.floor(input.Y))
	local c_pos = Vector2.new(math.floor(input.X), math.floor(input.Y) + 1)
	local d_pos = Vector2.new(math.floor(input.X) + 1, math.floor(input.Y) + 1)

	local a_hash = self:HashVector(a_pos)
	local b_hash = self:HashVector(b_pos)
	local c_hash = self:HashVector(c_pos)
	local d_hash = self:HashVector(d_pos)

	local X = input.X % 1
	local Y = input.Y % 1
	local cell_pos = Vector2.new(X, Y)

	local a_dot = a_hash:Dot(cell_pos)
	local b_dot = b_hash:Dot(cell_pos - Vector2.new(1, 0))
	local c_dot = c_hash:Dot(cell_pos - Vector2.new(0, 1))
	local d_dot = d_hash:Dot(cell_pos - Vector2.new(1, 1))

	local a_derivative_to_x = a_hash.X * (1 - self:smootherstep(X)) * (1 - self:smootherstep(Y))
		- a_dot * self:smootherstep_derivative(X) * (1 - self:smootherstep(Y))
	local a_derivative_to_y = a_hash.Y * (1 - self:smootherstep(X)) * (1 - self:smootherstep(Y))
		- a_dot * (1 - self:smootherstep(X)) * self:smootherstep_derivative(Y)
	local b_derivative_to_x = b_hash.X * self:smootherstep(X) * (1 - self:smootherstep(Y))
		+ b_dot * self:smootherstep_derivative(X) * (1 - self:smootherstep(Y))
	local b_derivative_to_y = b_hash.Y * self:smootherstep(X) * (1 - self:smootherstep(Y))
		- b_dot * self:smootherstep(X) * self:smootherstep_derivative(Y)
	local c_derivative_to_x = c_hash.X * (1 - self:smootherstep(X)) * self:smootherstep(Y)
		- c_dot * self:smootherstep_derivative(X) * self:smootherstep(Y)
	local c_derivative_to_y = c_hash.Y * (1 - self:smootherstep(X)) * self:smootherstep(Y)
		+ c_dot * (1 - self:smootherstep(X)) * self:smootherstep_derivative(Y)
	local d_derivative_to_x = d_hash.X * self:smootherstep(X) * self:smootherstep(Y)
		+ d_dot * self:smootherstep_derivative(X) * self:smootherstep(Y)
	local d_derivative_to_y = d_hash.Y * self:smootherstep(X) * self:smootherstep(Y)
		+ d_dot * self:smootherstep(X) * self:smootherstep_derivative(Y)

	local gradient = Vector2.new(
		a_derivative_to_x + b_derivative_to_x + c_derivative_to_x + d_derivative_to_x,
		a_derivative_to_y + b_derivative_to_y + c_derivative_to_y + d_derivative_to_y
	)

	local value = a_dot * (1 - self:smootherstep(X)) * (1 - self:smootherstep(Y))
		+ b_dot * self:smootherstep(X) * (1 - self:smootherstep(Y))
		+ c_dot * (1 - self:smootherstep(X)) * self:smootherstep(Y)
		+ d_dot * self:smootherstep(X) * self:smootherstep(Y)

	return value, gradient
end

function PerlinNoise:OctavePerlin(input: Vector2, octaves: number, roughness: number, lacunarity: number)
	local total = 0
	local maxValue = 0
	local global_gradient = Vector2.new(0, 0)
	local col = Vector2.zero
	for i = 1, octaves do
		local influence = math.pow(roughness, i - 1)
		local frequency = math.pow(lacunarity, i - 1)
		local value, gradient = self:Compute(input * frequency)
		if value < 0 then
			value = -value
		end
		local local_gradient = global_gradient + gradient

		local slope = 1 / (1 + local_gradient.Magnitude * 2)
		if i == 1 then
			col = Vector2.one * slope
		end
		value = value * slope * influence
		global_gradient = global_gradient + gradient * influence * slope
		total = total + value
		maxValue = maxValue + influence
	end
	return total / maxValue, col
end

return PerlinNoise

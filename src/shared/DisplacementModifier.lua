--!strict
local DisplacementModifier: DisplacementModifierClass = {} :: DisplacementModifierClass
DisplacementModifier.__index = DisplacementModifier

type DisplacementModifierClass = {
	__index: DisplacementModifierClass,
	__add: (self: DisplacementModifier, other: Vector3 | CFrame) -> Vector3 | CFrame,
	getDisplacement: (self: DisplacementModifier, point: Vector3) -> Vector3,
	getOctaveDisplacement: (self: DisplacementModifier, point: Vector3) -> Vector3,
	new: (scale: Vector3, size: number, octaves: number, roughness: number) -> DisplacementModifier,
}

export type DisplacementModifier = typeof(setmetatable(
	{} :: {
		scale: Vector3,
		size: number,
		octaves: number,
		roughness: number,
	},
	DisplacementModifier
))

function DisplacementModifier:__add(other: Vector3 | CFrame): Vector3 | CFrame
	if typeof(other) == "Vector3" then
		return other + self:getOctaveDisplacement(other) * self.scale
	else
		local offset = self:getOctaveDisplacement(other.Position)
		local scaledOffset = other:VectorToWorldSpace(other:VectorToObjectSpace(offset) * self.scale)
		return other + scaledOffset
	end
end

function DisplacementModifier:getOctaveDisplacement(point: Vector3): Vector3
	local sum = Vector3.zero
	local max = 0
	for i = 1, self.octaves do
		local currentScale = 2 ^ (i - 1) / self.size
		local amplitude = self.roughness ^ (i - 1)
		max += amplitude
		sum += self:getDisplacement(point * currentScale) * amplitude
	end
	return sum / max
end

function DisplacementModifier:getDisplacement(point: Vector3): Vector3
	local x = math.noise(point.X + 1000, point.Y + 1000, point.Z - 1000)
	local y = math.noise(point.X - 1000, point.Y + 1000, point.Z + 1000)
	local z = math.noise(point.X + 1000, point.Y - 1000, point.Z + 1000)
	return Vector3.new(x, y, z)
end

function DisplacementModifier.new(
	scale: Vector3,
	size: number,
	octaves: number,
	roughness: number
): DisplacementModifier
	local self = setmetatable({}, DisplacementModifier)
	self.scale = scale
	self.size = size
	self.octaves = octaves
	self.roughness = roughness
	return self
end

return DisplacementModifier

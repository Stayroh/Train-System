--!strict
local DisplacementModifier: DisplacementModifierClass = {} :: DisplacementModifierClass
DisplacementModifier.__index = DisplacementModifier

type DisplacementModifierClass = {
	__index: DisplacementModifierClass,
	__add: (self: DisplacementModifier, other: Vector3 | CFrame) -> Vector3 | CFrame,
	getDisplacement: (self: DisplacementModifier, point: Vector3) -> Vector3,
	new: (scale: Vector3, size: number) -> DisplacementModifier,
}

export type DisplacementModifier = typeof(setmetatable(
	{} :: {
		scale: Vector3,
		size: number,
	},
	DisplacementModifier
))

function DisplacementModifier:__add(other: Vector3 | CFrame): Vector3 | CFrame
	if typeof(other) == "Vector3" then
		return other + self:getDisplacement(other)
	else
		local offset = self:getDisplacement(other.Position)
		return other + offset.X * other.RightVector + offset.Y * other.UpVector + offset.Z * other.LookVector
	end
end

function DisplacementModifier:getDisplacement(point: Vector3): Vector3
	local x = math.noise(point.X / self.size + 1000, point.Y / self.size + 1000, point.Z / self.size - 1000)
		* self.scale.X
	local y = math.noise(point.X / self.size - 1000, point.Y / self.size + 1000, point.Z / self.size + 1000)
		* self.scale.Y
	local z = math.noise(point.X / self.size + 1000, point.Y / self.size - 1000, point.Z / self.size + 1000)
		* self.scale.Z
	return Vector3.new(x, y, z)
end

function DisplacementModifier.new(scale: Vector3, size: number): DisplacementModifier
	local self = setmetatable({}, DisplacementModifier)
	self.scale = scale
	self.size = size
	return self
end

return DisplacementModifier

--Instructions for Copilot: Demo script to visualize Perlin noise in 3d space in form of parts in roblox, where the value determines the height of the part. and the gradient determines the color of the part like a normal map would look like.

local Resolution = Vector2.new(500, 500)
local Scale = 0.005
local PartSize = 1
local HeightScale = 1 / Scale
local WorldOffset = Vector3.new(0, 100, 0)

local PerlinNoise = require(game.ReplicatedStorage.src.PerlinNoise)

local Model = Instance.new("Model")
Model.Name = "PerlinNoise"
Model.Parent = workspace

for x = 1, Resolution.X do
	for y = 1, Resolution.Y do
		local input = Vector2.new(x, y + 1000) * Scale
		local value, color = PerlinNoise:OctavePerlin(input, 2, 0.5, 2)

		local height = value
		local paint = height
		local part = Instance.new("Part")
		part.CanCollide = false
		part.CastShadow = false
		part.Size = Vector3.new(PartSize, height * HeightScale, PartSize)
		part.Position = Vector3.new(x * PartSize, height * HeightScale / 2, y * PartSize) + WorldOffset
		part.Color = Color3.fromHSV(-paint * 2 / 3 + 2 / 3, 1, 1)
		if true then
			part.Color = color
		end
		part.Anchored = true
		part.Parent = Model
	end
end

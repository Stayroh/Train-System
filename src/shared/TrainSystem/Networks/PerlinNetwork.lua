local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Math = require(TrainSystem.Math)

local NodeList = {
	[1] = {
		Position = Vector3.new(0, 200, 0),
		Direction = Vector3.new(1, 0, 0),
	},
}

local function Noise(P: Vector3, Scale): Vector3
	P = P * Scale
	local X = math.noise(P.X + 234, P.Y, P.Z + 124)
	local Y = math.noise(P.X, P.Y + 544, P.Z - 124)
	local Z = math.noise(P.X - 234, P.Y - 544, P.Z)
	return Vector3.new(X, Y, Z)
end

for i = 1, 500 do
	local CurrentNode = NodeList[i]
	print(CurrentNode)
	local CurrentPosition = CurrentNode.Position
	local CurrentDirection = CurrentNode.Direction
	local NewDirection = (Noise(CurrentPosition, 0.01) * 0.05 + CurrentDirection).Unit
	local Position = NewDirection * Vector3.new(10, 5, 10) + CurrentPosition + Vector3.new(0, -0.5, 0)
	local Direction = Math:GetNextTangent(CurrentPosition, Position, CurrentDirection)
	NodeList[i + 1] = {
		Position = Position,
		Direction = Direction,
	}
end

local Module = {}

for i, v in pairs(NodeList) do
	Module[i] = {
		Position = v.Position,
		Tangent = v.Direction,
		ZRotation = 0,
		Pre = i ~= 1 and i - 1 or nil,
		Fol = i ~= #NodeList and i + 1 or nil,
	}
end

return Module

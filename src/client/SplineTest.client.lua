local Spline = require(game.ReplicatedStorage.src.Spline)

function Curvature(Spline: Spline.self, t: number): number
	local Tangent = Spline:ComputeTangent(t)
	local Acceleration = Spline:ComputeAcceleration(t)
	local Cross = Tangent:Cross(Acceleration)
	return Cross.Magnitude / Tangent.Magnitude ^ 3
end

function DrawSpline(Spline: Spline.self, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Point = Spline:Compute(t)
		local Part = Instance.new("Part")
		Part.Shape = Enum.PartType.Ball
		Part.Size = Vector3.new(0.25, 0.25, 0.25)
		Part.Color = Color
		Part.Anchored = true
		Part.Position = Point
		Part.Parent = Folder
	end
	return
end

function DrawTangentSpline(Spline: Spline.self, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:Compute(t)
		local Tangent = Spline:ComputeTangent(t)
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(0.1, 0.1, Tangent.Magnitude)
		Part.Color = Color
		Part.Anchored = true
		local Pos = Position:Lerp(Position + Tangent, 0.5)
		Part.CFrame = CFrame.lookAt(Pos, Pos + Tangent)
		Part.Parent = Folder
	end
	return
end

function DrawAccelerationSpline(Spline: Spline.self, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:Compute(t)
		local Tangent = Spline:ComputeAcceleration(t)
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(0.1, 0.1, Tangent.Magnitude)
		Part.Color = Color
		Part.Anchored = true
		local Pos = Position:Lerp(Position + Tangent, 0.5)
		Part.CFrame = CFrame.lookAt(Pos, Pos + Tangent)
		Part.Parent = Folder
	end
	return
end

function DrawCurvatureSpline(Spline: Spline.self, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:Compute(t)
		local Curvature = Curvature(Spline, t) * 10
		local Tangent = Spline:ComputeTangent(t)
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(0.1, 0.1, Curvature)
		Part.Color = Color
		Part.Anchored = true
		local UpVector = Vector3.new(0, 1, 0)
		local normal = Tangent:Cross(UpVector):Cross(Tangent).Unit * Curvature
		local Pos = Position:Lerp(Position + normal, 0.5)
		Part.CFrame = CFrame.lookAt(Pos, Pos + normal)
		Part.Parent = Folder
	end
	return
end

local CurrentPosition = Vector3.new(0, 0, 0)
local CurrentTangent = Vector3.new(10, 0, 0)
local Positions = {
	Vector3.new(10, 10, 0),
	Vector3.new(0, 20, 0),
	Vector3.new(-10, 10, 0),
	Vector3.new(0, 0, 0),
}
local Tangents = {
	Vector3.new(0, 10, 0),
	Vector3.new(-10, 0, 0),
	Vector3.new(0, -10, 0),
	Vector3.new(10, 0, 0),
}

local TangentScale = 5.52284749831

for i = 1, 4 do
	local SplineInstance =
		Spline.new(CurrentPosition, Positions[i], CurrentTangent.Unit * TangentScale, Tangents[i].Unit * TangentScale)
	DrawSpline(SplineInstance, 100, Color3.new(math.random(), math.random(), math.random()))
	--DrawTangentSpline(SplineInstance, 10, Color3.new(math.random(), math.random(), math.random()))
	--DrawAccelerationSpline(SplineInstance, 10, Color3.new(math.random(), math.random(), math.random()))
	DrawCurvatureSpline(SplineInstance, 10, Color3.new(math.random(), math.random(), math.random()))
	CurrentPosition = Positions[i]
	CurrentTangent = Tangents[i]
end

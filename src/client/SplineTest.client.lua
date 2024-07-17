--!strict
local Spline = require(game.ReplicatedStorage.src.Spline)

function getCurvature(Spline: Spline.Spline, t: number): number
	local Tangent = Spline:computeTangent(t)
	local Acceleration = Spline:computeAcceleration(t)
	local Cross = Tangent:Cross(Acceleration)
	return Cross.Magnitude / Tangent.Magnitude ^ 3
end

function DrawSpline(Spline: Spline.Spline, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Point = Spline:computePoint(t)
		local Part = Instance.new("Part")
		Part.Shape = Enum.PartType.Ball
		Part.Size = Vector3.new(0.25, 0.25, 0.25)
		Part.Color = Color:Lerp(Color3.fromRGB(0, 0, 0), (1 - t))
		Part.Anchored = true
		Part.Position = Point
		Part.Parent = Folder
	end
	return
end

function _DrawTangentSpline(Spline: Spline.Spline, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:computePoint(t)
		local Tangent = Spline:computeTangent(t)
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

function _DrawAccelerationSpline(Spline: Spline.Spline, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:computePoint(t)
		local Tangent = Spline:computeAcceleration(t)
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

function DrawCurvatureSpline(Spline: Spline.Spline, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local Position = Spline:computePoint(t)
		local Curvature = getCurvature(Spline, t) * 10
		local Tangent = Spline:computeAcceleration(t)
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

local mySpline = Spline.new(Vector3.new(0, 5, 0), Vector3.new(0, 5, 100), Vector3.new(0, 0, 5), Vector3.new(0, 0, 5))

DrawSpline(mySpline, 100, Color3.fromRGB(255, 0, 0))

wait(10)

local Part = Instance.new("Part")
Part.Size = Vector3.new(1, 0.5, 2)
Part.Anchored = true
Part.Parent = workspace

local t = 0
local lastPosition
while t <= 1 do
	local Position = mySpline:computePoint(t)
	local Tangent = mySpline:computeTangent(t)
	Part.CFrame = CFrame.lookAt(Position, Position + Tangent)
	local deltaT = game:GetService("RunService").Heartbeat:Wait()
	t = mySpline:stepDistance(t, deltaT * 10, 5)
	if lastPosition then
		local distance = (Position - lastPosition).Magnitude
		print(distance / deltaT)
		lastPosition = Position
	else
		lastPosition = Position
	end
end

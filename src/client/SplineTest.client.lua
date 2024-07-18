--!strict
local Spline = require(game.ReplicatedStorage.src.Spline)
local bSplineConversion = require(game.ReplicatedStorage.src.bSplineConversion)

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

local knotsFolder = workspace.knots
local knots = {}
do
	local i = 1
	while knotsFolder:FindFirstChild(tostring(i)) do
		knots[i] = knotsFolder[tostring(i)].Position
		i += 1
	end
end

for i, v in pairs(knots) do
	print(i, v)
end

local splines = bSplineConversion.bsplineToBezier(knots)

for i, spline in pairs(splines) do
	DrawSpline(spline, 100, Color3.fromRGB(255, 0, 0))
end

--[[
local spline1 =
	Spline.new(Vector3.new(0, 10, 0), Vector3.new(20, 35, 100), Vector3.new(100, 0, 0), Vector3.new(50, 40, -20))
local spline2 = Spline.new(spline1.EndPosition, spline1.StartPosition, spline1.EndTangent, spline1.StartTangent)

DrawSpline(spline1, 100, Color3.fromRGB(255, 0, 0))
DrawSpline(spline2, 100, Color3.fromRGB(0, 255, 0))

wait(2)

local subsamplingSteps = 4

local Part = Instance.new("Part")
Part.Size = Vector3.new(1, 0.5, 2)

Part.Anchored = true
Part.Parent = workspace

local t = 0
local currentSpline = spline1
local speed = 40

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	local slope = currentSpline:computeTangent(t).Unit:Dot(Vector3.new(0, 1, 0))
	local acceleration = -20 * slope
	local stepDistance = speed * deltaTime + 0.5 * acceleration * deltaTime ^ 2
	speed += acceleration * deltaTime
	local newT, didCross = currentSpline:stepDistance(t, stepDistance, subsamplingSteps)
	while didCross do
		if stepDistance > 0 then
			t = 0
		else
			t = 1
		end
		currentSpline = currentSpline == spline1 and spline2 or spline1
		stepDistance = newT
		newT, didCross = currentSpline:stepDistance(t, stepDistance, subsamplingSteps)
	end
	t = newT
	local position = currentSpline:computePoint(t)
	local CF = CFrame.lookAt(position, position + currentSpline:computeTangent(t))
	Part.CFrame = CF
	workspace.CurrentCamera.CFrame = CF
end)
]]

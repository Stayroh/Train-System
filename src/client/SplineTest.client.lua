--!strict
local Spline = require(game.ReplicatedStorage.src.Spline)
local BSpline = require(game.ReplicatedStorage.src.BSpline)
local SplineLut = require(game.ReplicatedStorage.src.SplineLut)

function getCurvature(Spline: Spline.Spline, t: number): number
	local Tangent = Spline:getTangent(t)
	local Acceleration = Spline:getAcceleration(t)
	local Cross = Tangent:Cross(Acceleration)
	return Cross.Magnitude / Tangent.Magnitude ^ 3
end

function DrawSpline(Spline: Spline.Spline, Lut, Resolution: number, Color: Color3): nil
	print(Lut)
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	local expectedLength = Lut.length / Resolution
	local minDistance, maxDistance = expectedLength, expectedLength
	local lastPosition
	for i = 0, Resolution do
		local t = i / Resolution
		local correctedT = Lut:getCorrectetT(t)
		local Point = Spline:getPoint(correctedT)
		local Part = Instance.new("Part")
		Part.Shape = Enum.PartType.Ball
		Part.Size = Vector3.new(0.25, 0.25, 0.25)
		Part.Color = Color:Lerp(Color3.fromRGB(0, 0, 0), (1 - t))
		Part.Anchored = true
		Part.Position = Point
		Part.Parent = Folder
		if lastPosition then
			local distance = (Point - lastPosition).Magnitude
			minDistance = math.min(minDistance, distance)
			maxDistance = math.max(maxDistance, distance)
		end
		lastPosition = Point
	end
	print("Deviation")
	print((maxDistance - minDistance) / expectedLength)
	print(minDistance, maxDistance)
	return
end

function _DrawTangentSpline(Spline: Spline.Spline, Lut, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local correctedT = Lut:getCorrectetT(t)
		local Position = Spline:getPoint(correctedT)
		local Tangent = Spline:getTangent(correctedT)
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
		local Position = Spline:getPoint(t)
		local Tangent = Spline:getAcceleration(t)
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
		local Position = Spline:getPoint(t)
		local Curvature = getCurvature(Spline, t) * 10
		local Tangent = Spline:getAcceleration(t)
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

local spline1, spline2

do
	local startPoint, endPoint, sTangent, eTangent =
		Vector3.new(0, 10, 0), Vector3.new(20, 5, 100), Vector3.new(120, -2, 0), Vector3.new(-100, 10, -20)
	spline1 = Spline.new(startPoint, startPoint + sTangent, endPoint - eTangent, endPoint)
	spline2 = Spline.new(endPoint, endPoint + eTangent, startPoint - sTangent, startPoint)
end

local Lut1 = SplineLut.generate(spline1, 100, 100)
local Lut2 = SplineLut.generate(spline2, 100, 100)

workspace.Start.Position = spline1.P0
workspace.End.Position = spline1.P3

local originalRail = workspace.Rail

local railSegmentLength = 8

local railFolder = Instance.new("Folder")
railFolder.Name = "Rail"
railFolder.Parent = workspace

--Bone0 Position must be fixed

local excpectedSpeed = 100

local upVector = Vector3.new(0, 1, 0)

local G = 192

function renderRailSegment(spline: Spline.Spline, Lut, t_start: number, t_end: number)
	local segment = originalRail:Clone()
	local bones = segment.Bone0:GetChildren()
	local correctedStartT = Lut:getCorrectetT(t_start)
	local startPosition = spline:getPoint(correctedStartT)
	local startTangent = spline:getTangent(correctedStartT)
	local startAcceleration = spline:getAcceleration(correctedStartT)
	local startCurveRadius = startTangent.Magnitude ^ 3 / startTangent:Cross(startAcceleration).Magnitude
	local startBank = math.atan(excpectedSpeed ^ 2 / (G * startCurveRadius))
	local startNormal = upVector:Cross(startTangent).Unit
	if startNormal:Dot(startAcceleration) < 0 then
		startNormal = -startNormal
	end
	local startCF = CFrame.lookAt(
		startPosition,
		startPosition - startTangent,
		math.sin(startBank) * startNormal + math.cos(startBank) * upVector
	)
	local offset = CFrame.new(0, 0, 4)
	segment.CFrame = startCF:ToWorldSpace(offset)
	segment.Bone0.WorldCFrame = startCF
	for i = 1, #bones do
		local bone = segment.Bone0:FindFirstChild("Bone" .. tostring(i)) :: Bone
		local alpha = i / #bones
		local t = t_start * (1 - alpha) + t_end * alpha
		local correctedT = Lut:getCorrectetT(t)
		local position = spline:getPoint(correctedT)
		local tangent = spline:getTangent(correctedT)
		local acceleration = spline:getAcceleration(correctedT)
		local curveRadius = tangent.Magnitude ^ 3 / tangent:Cross(acceleration).Magnitude
		local bank = math.atan(excpectedSpeed ^ 2 / (G * curveRadius))
		local normal = upVector:Cross(tangent).Unit
		if normal:Dot(acceleration) < 0 then
			normal = -normal
		end
		local cf = CFrame.lookAt(position, position - tangent, math.sin(bank) * normal + math.cos(bank) * upVector)
		bone.CFrame = startCF:ToObjectSpace(cf)
	end
	segment.Parent = railFolder
end
--[[
DrawSpline(spline1, Lut1, 100, Color3.fromRGB(255, 0, 0))
DrawSpline(spline2, Lut2, 100, Color3.fromRGB(0, 255, 0))

do
	local segmentCount = math.round(Lut1.length / railSegmentLength)
	local segmentT = 1 / segmentCount

	for i = 1, segmentCount do
		renderRailSegment(spline1, Lut1, (i - 1) * segmentT, i * segmentT)
	end
end

do
	local segmentCount = math.round(Lut2.length / railSegmentLength)
	local segmentT = 1 / segmentCount

	for i = 1, segmentCount do
		renderRailSegment(spline2, Lut2, (i - 1) * segmentT, i * segmentT)
	end
end

]]

for i = 1, #knots - 3 do
	local P0, P1, P2, P3 = knots[i], knots[i + 1], knots[i + 2], knots[i + 3]
	local spline = BSpline.new(P0, P1, P2, P3)
	local Lut = SplineLut.generate(spline, 100, 100)
	DrawSpline(spline, Lut, 100, Color3.fromRGB(0, 0, 255))

	local segmentCount = math.round(Lut.length / railSegmentLength)
	local segmentT = 1 / segmentCount

	for i = 1, segmentCount do
		renderRailSegment(spline, Lut, (i - 1) * segmentT, i * segmentT)
	end
end

--[[
local subsamplingSteps = 4

local t = 0
local currentSpline = spline1
local speed = 40

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	local slope = currentSpline:getTangent(t).Unit:Dot(Vector3.new(0, 1, 0))
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
	local position = currentSpline:getPoint(t)
	local CF = CFrame.lookAt(position, position + currentSpline:getTangent(t), currentSpline:getAcceleration(t))
	Part.CFrame = CF
	workspace.CurrentCamera.CFrame = CF
end)
]]

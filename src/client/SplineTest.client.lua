--!strict
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local BezierSpline = require(game.ReplicatedStorage.src.BezierSpline)
local BezierConverter = require(game.ReplicatedStorage.src.BezierConverter)
local RouteNetwork = require(game.ReplicatedStorage.src.TrainSystemV2.RouteNetwork)

function getCurvature(Spline: BezierSpline.BezierSpline, t: number): number
	local Tangent = Spline:getVelocity(t)
	local Acceleration = Spline:getAcceleration(t)
	local Cross = Tangent:Cross(Acceleration)
	return Cross.Magnitude / Tangent.Magnitude ^ 3
end

function DrawSpline(Spline: BezierSpline.BezierSpline, Lut, Resolution: number, Color: Color3): nil
	print(Lut)
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	local expectedLength = Lut.length / Resolution
	local minDistance, maxDistance = expectedLength, expectedLength
	local lastPosition
	for i = 0, Resolution do
		local t = i / Resolution
		local correctedT = Lut:inverseLookup(t)
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

function _DrawTangentSpline(Spline: BezierSpline.BezierSpline, Lut, Resolution: number, Color: Color3): nil
	local Folder = Instance.new("Folder")
	Folder.Name = "Spline"
	Folder.Parent = workspace
	for i = 0, Resolution do
		local t = i / Resolution
		local correctedT = Lut:inverseLookup(t)
		local Position = Spline:getPoint(correctedT)
		local Tangent = Spline:getVelocity(correctedT)
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

function _DrawAccelerationSpline(Spline: BezierSpline.BezierSpline, Resolution: number, Color: Color3): nil
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

function DrawCurvatureSpline(Spline: BezierSpline.BezierSpline, Resolution: number, Color: Color3): nil
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

local originalRail = workspace.BakedRail

local railSegmentLength = 9.39116

local railFolder = Instance.new("Folder")
railFolder.Name = "Rail"
railFolder.Parent = workspace

--Bone0 Position must be fixed

local upVector = Vector3.new(0, 1, 0)

local G = 40

function getCFrame(position: Vector3, tangent: Vector3, acceleration: Vector3, excpectedSpeed: number): CFrame
	local normal = tangent:Cross(upVector).Unit
	local curvatureVector = tangent:Cross(tangent:Cross(acceleration)) / tangent.Magnitude ^ 3
	local k = -normal:Dot(curvatureVector)
	local bankAngle = math.atan(excpectedSpeed ^ 2 * k / G)
	return CFrame.lookAt(position, position - tangent, math.sin(bankAngle) * normal + math.cos(bankAngle) * upVector)
end

function renderRailSegment(spline: BezierSpline.BezierSpline, t_start: number, t_end: number, parent: Folder)
	local segment = originalRail:Clone()
	local bones = segment.Bone0:GetChildren()
	local correctedStartT = spline.lut:inverseLookup(t_start)
	local startCF = getCFrame(
		spline:getPoint(correctedStartT),
		spline:getVelocity(correctedStartT),
		spline:getAcceleration(correctedStartT),
		3
	)
	local offset = CFrame.new(0, 0, 4)
	segment.CFrame = startCF:ToWorldSpace(offset)
	segment.Bone0.WorldCFrame = startCF
	for i = 1, #bones do
		local bone = segment.Bone0:FindFirstChild("Bone" .. tostring(i)) :: Bone
		local alpha = i / #bones
		local t = t_start * (1 - alpha) + t_end * alpha
		local correctedT = spline.lut:inverseLookup(t)
		local cf = getCFrame(
			spline:getPoint(correctedT),
			spline:getVelocity(correctedT),
			spline:getAcceleration(correctedT),
			3
		)
		bone.CFrame = startCF:ToObjectSpace(cf)
	end
	segment.Parent = parent
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

local railWidth = 9.338

local boundsFolder = Instance.new("Folder")
boundsFolder.Name = "Bounds"
boundsFolder.Parent = workspace

local nodes: { RouteNetwork.Node } = {}

local conversions: { BezierConverter.BezierConversion } = {}

for i = 1, #knots do
	local P0, P1, P2, P3 =
		knots[i],
		knots[i + 1] or knots[i + 1 - #knots],
		knots[i + 2] or knots[i + 2 - #knots],
		knots[i + 3] or knots[i + 3 - #knots]

	conversions[i] = BezierConverter:convert(P0, P1, P2, P3)
end

for i = 1, #conversions do
	nodes[i] = {
		position = conversions[i].startPosition,
		handle = conversions[i].startHandle,
		targetSpeed = 3,
		previousNode = (i - 2) % #conversions + 1,
		nextNode = i % #conversions + 1,
	}
end

local routeNetwork = RouteNetwork.new(nodes)

for splineIndex, spline in pairs(routeNetwork.splines) do
	local folder = Instance.new("Folder")
	folder.Name = "Spline" .. tostring(splineIndex)
	local segmentCount = math.round(spline.lut.length / railSegmentLength)
	local segmentT = 1 / segmentCount
	for i = 1, segmentCount do
		renderRailSegment(spline, (i - 1) * segmentT, i * segmentT, folder)
	end

	--Create Bounding Box
	local bounds = spline:getBounds()
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.Size = bounds.Size -- + Vector3.one * railWidth
	Part.CFrame = bounds.CFrame
	Part.Material = Enum.Material.Neon
	Part.BrickColor = BrickColor.random()
	Part.Transparency = 0.5
	Part.CanCollide = false
	Part.Parent = folder
	folder.Parent = railFolder
end

task.wait(5)

game:GetService("RunService").RenderStepped:Connect(function()
	local r = workspace.Sphere.Size.X / 2
	local pos = workspace.Sphere.Position
	local startLocation = {
		node1 = 1,
		node2 = 2,
		t = 0,
	}
	local intersectionLocation = routeNetwork:intersectSphere(pos, r, startLocation, 50)
	if intersectionLocation then
		local spline, t = routeNetwork:getSplineAndT(intersectionLocation)
		workspace.Point.Position = spline:getPoint(spline.lut:inverseLookup(t))
	end
end)

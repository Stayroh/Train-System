--!strict
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local DisplacementModifier = require(game.ReplicatedStorage.src.DisplacementModifier)
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
		knotsFolder[tostring(i)].Transparency = 1
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
	return CFrame.lookAt(position, position + tangent, math.sin(bankAngle) * normal + math.cos(bankAngle) * upVector)
end

function renderRailSegment(spline: BezierSpline.BezierSpline, t_start: number, t_end: number, parent: Folder)
	local segment = originalRail:Clone()
	local bones = segment.Bone0:GetChildren()
	local correctedStartT = spline.lut:inverseLookup(t_start)
	local startCF = getCFrame(
		spline:getPoint(correctedStartT, false),
		spline:getVelocity(correctedStartT),
		spline:getAcceleration(correctedStartT),
		3
	)
	startCF = spline.displacementModifier + startCF
	local offset = CFrame.new(0, 0, 4)
	segment.CFrame = startCF:ToWorldSpace(offset)
	segment.Bone0.WorldCFrame = startCF
	for i = 1, #bones do
		local bone = segment.Bone0:FindFirstChild("Bone" .. tostring(i)) :: Bone
		local alpha = i / #bones
		local t = t_start * (1 - alpha) + t_end * alpha
		local correctedT = spline.lut:inverseLookup(t)
		local cf = getCFrame(
			spline:getPoint(correctedT, false),
			spline:getVelocity(correctedT),
			spline:getAcceleration(correctedT),
			3
		)
		cf = spline.displacementModifier + cf
		bone.CFrame = startCF:ToObjectSpace(cf)
	end
	segment.Parent = parent
	--Create a part to later convert it to terrain
	--[[
	local middleT = (t_start + t_end) / 2
	local part = Instance.new("Part")
	part.CFrame = getCFrame(spline:getPoint(middleT), spline:getVelocity(middleT), spline:getAcceleration(middleT), 3)
	part.Position = part.Position - part.CFrame.UpVector * 7
	local distance = (spline:getPoint(t_end) - spline:getPoint(t_start)).Magnitude
	part.Size = Vector3.new(20, 8, distance + 2)
	part.Anchored = true
	part.Parent = parent
	]]
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
		previousNode = { index = (i - 2) % #conversions + 1, isSwitchNode = false },
		nextNode = { index = i % #conversions + 1, isSwitchNode = false },
	}
end

local displacementModifier = DisplacementModifier.new(Vector3.new(0, 0, 0), 40)
local routeNetwork = RouteNetwork.new(nodes, displacementModifier)

for splineIndex, spline in pairs(routeNetwork.splines) do
	local folder = Instance.new("Folder")
	folder.Name = "Spline" .. tostring(splineIndex)
	local segmentCount = math.round(spline.lut.length / railSegmentLength)
	local segmentT = 1 / segmentCount
	for i = 1, segmentCount do
		renderRailSegment(spline, (i - 1) * segmentT, i * segmentT, folder)
	end
	--[[
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
	]]
	folder.Parent = railFolder
end

task.wait(2)

game:GetService("RunService").RenderStepped:Connect(function()
	for i = 1, 1 do
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
	end
end)

local Train = require(game.ReplicatedStorage.src.TrainSystemV2.Train)
local lastCamPos = workspace.CurrentCamera.CFrame.Position
local layout: Train.TrainLayout = {
	{ car = "TGVEngine", reversed = false },
	{ car = "TGVConnection", reversed = false },
	{ car = "TGVCarriage", reversed = false },
	{ car = "TGVCarriage", reversed = true },
	{ car = "TGVConnection", reversed = true },
	--{ car = "TGVEngine", reversed = true },
	--[[
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "FlatcarTest", reversed = false },
	{ car = "FlatcarTest", reversed = false },

	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	{ car = "SovietCarriage", reversed = true },
	 ]]
}
local myTrain = Train.fromLayout(layout, { node1 = 45, node2 = 46, t = 0.1 }, routeNetwork)
myTrain.model.Parent = workspace.Trains
local speed = 300
local camToggle = false
local timeScale = 10.0
if camToggle then
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.FieldOfView = 100
end

function setFOV(distance)
	local S = 70
	local fov = 2 * math.atan(S / (2 * distance))
	workspace.CurrentCamera.FieldOfView = math.deg(fov)
end

workspace.some.Event:Connect(function(a)
	myTrain.cars[1].frontBogie.springPivot = myTrain.cars[1].frontBogie.springPivot + Vector3.new(0, a, 0)
end)
local running = true
workspace.toggleRuntime.Event:Connect(function()
	running = not running
end)

game:GetService("RunService").PreRender:Connect(function(deltaTime)
	deltaTime *= timeScale
	if not running then
		return
	end
	debug.profilebegin("Train")
	local acceleration = myTrain.averageSlopeSine * -300
	local stepDistance = deltaTime * speed + 0.5 * acceleration * deltaTime ^ 2
	speed += acceleration * deltaTime
	local newLocation = routeNetwork:stepDistance(myTrain.location, stepDistance)
	myTrain:setLocation(newLocation, speed, deltaTime)
	local myCar = myTrain.cars[1]
	local cf = myCar.cf
	local lookTo = cf.Position + cf.LookVector * 20
	local target = lookTo + cf.LookVector * 105 + cf.UpVector * 00
	local blend = math.pow(0.5, deltaTime * 4)
	lastCamPos = lastCamPos * blend + target * (1 - blend)
	local fixedLookTo = cf:PointToWorldSpace(Vector3.new(-2.258, 7.007, -32.064))
	local fixedTarget = fixedLookTo + cf.LookVector * 50 - cf.RightVector * 0 - cf.UpVector * 15
	if camToggle then
		workspace.CurrentCamera.CFrame = CFrame.lookAt(fixedLookTo, fixedTarget, cf.UpVector)
	end
	--setFOV((lastCamPos - lookTo).Magnitude)
end)

local TrainWorkerScript = script.Parent.TrainWorker

local function cloneTable(t)
	local clone = {}
	for i, v in pairs(t) do
		if type(v) == "table" then
			clone[i] = cloneTable(v)
		else
			clone[i] = v
		end
	end
	return clone
end
--[[
local routeNetworkClone = cloneTable(routeNetwork)

for i = 1, 4 do
	local actor = Instance.new("Actor")
	actor.Name = "TrainWorker_" .. tostring(i)
	actor.Parent = workspace.Trains
	local clone = TrainWorkerScript:Clone()
	clone.Parent = actor
	clone.Disabled = false
	actor:SendMessage("TrainSpawn", routeNetworkClone)
	task.wait(2.0)
end
]]

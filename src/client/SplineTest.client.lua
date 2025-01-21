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
		--knotsFolder[tostring(i)].Transparency = 1
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

function renderRailSegment(
	splineIndex: number,
	routeNetwork: RouteNetwork.RouteNetwork,
	t_start: number,
	t_end: number,
	parent: Folder
)
	local spline = routeNetwork.splines[splineIndex]
	local startTargetSpeed, endTargetSpeed
	if routeNetwork.splineNodes[splineIndex].startNode.isSwitchNode then
		startTargetSpeed = routeNetwork.switchNodes[routeNetwork.splineNodes[splineIndex].startNode.index].targetSpeed
	else
		startTargetSpeed = routeNetwork.nodes[routeNetwork.splineNodes[splineIndex].startNode.index].targetSpeed
	end

	if routeNetwork.splineNodes[splineIndex].endNode.isSwitchNode then
		endTargetSpeed = routeNetwork.switchNodes[routeNetwork.splineNodes[splineIndex].endNode.index].targetSpeed
	else
		endTargetSpeed = routeNetwork.nodes[routeNetwork.splineNodes[splineIndex].endNode.index].targetSpeed
	end

	local segment = originalRail:Clone()
	local bones = segment.Bone0:GetChildren()
	local correctedStartT = spline.lut:inverseLookup(t_start)
	local startCF = getCFrame(
		spline:getPoint(correctedStartT),
		spline:getVelocity(correctedStartT),
		spline:getAcceleration(correctedStartT),
		startTargetSpeed * (1 - t_start) + endTargetSpeed * t_start
	) * CFrame.Angles(0, math.pi, 0)

	local offset = CFrame.new(0, 0, 4)
	segment.CFrame = startCF:ToWorldSpace(offset)
	startCF = spline.displacementModifier + startCF
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
			startTargetSpeed * (1 - t) + endTargetSpeed * t
		)
		cf = cf * CFrame.Angles(0, math.pi, 0)
		cf = spline.displacementModifier + cf
		bone.WorldCFrame = cf
		--bone.CFrame = startCF:ToObjectSpace(cf) * CFrame.Angles(0, math.pi, 0)
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

--Set Collision Group to all trains
for _, part in pairs(game.ReplicatedStorage.assets.Trains:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CollisionGroup = "Train"
	end
end

local railWidth = 9.338

local boundsFolder = Instance.new("Folder")
boundsFolder.Name = "Bounds"
boundsFolder.Parent = workspace

local nodes: { RouteNetwork.Node } = {}
local switchNodes: { RouteNetwork.SwitchNode } = {}

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
	local generatedNode = Instance.new("Part")
	generatedNode.Size = Vector3.new(1, 1, 1)
	generatedNode.Position = conversions[i].startPosition
	generatedNode.Anchored = true
	generatedNode.CanCollide = false
	generatedNode.Shape = Enum.PartType.Ball
	generatedNode.Material = Enum.Material.Neon
	generatedNode.Color = Color3.fromRGB(255, 0, 0)
	generatedNode.Name = "Node" .. tostring(i)
	generatedNode.Parent = workspace.GeneratedNodes
	nodes[i] = {
		position = conversions[i].startPosition,
		handle = conversions[i].startHandle,
		targetSpeed = 3,
		previousNode = { index = (i - 2) % #conversions + 1, isSwitchNode = false },
		nextNode = { index = i % #conversions + 1, isSwitchNode = false },
	}
end

local switchA: RouteNetwork.SwitchNode = nodes[3]
local switchB: RouteNetwork.SwitchNode = nodes[18]
local switchC: RouteNetwork.SwitchNode = nodes[10]
local switchD: RouteNetwork.SwitchNode = nodes[30]

table.remove(nodes, 30)
table.remove(nodes, 18)
table.remove(nodes, 10)
table.remove(nodes, 3)
for i = 1, #nodes do
	nodes[i].previousNode = { index = (i - 2) % #nodes + 1, isSwitchNode = false }
	nodes[i].nextNode = { index = i % #nodes + 1, isSwitchNode = false }
end
nodes[2].nextNode = { index = 1, isSwitchNode = true }
nodes[3].previousNode = { index = 1, isSwitchNode = true }
nodes[8].nextNode = { index = 3, isSwitchNode = true }
nodes[9].previousNode = { index = 3, isSwitchNode = true }
nodes[15].nextNode = { index = 2, isSwitchNode = true }
nodes[16].previousNode = { index = 2, isSwitchNode = true }
nodes[26].nextNode = { index = 4, isSwitchNode = true }
nodes[27].previousNode = { index = 4, isSwitchNode = true }
switchA.nextNode = { { index = 3, isSwitchNode = false }, { index = 2, isSwitchNode = true } }
switchA.previousNode = { { index = 2, isSwitchNode = false } }
switchB.nextNode = { { index = 16, isSwitchNode = false }, { index = 1, isSwitchNode = true } }
switchB.previousNode = { { index = 15, isSwitchNode = false } }
switchC.nextNode = { { index = 9, isSwitchNode = false } }
switchC.previousNode = { { index = 8, isSwitchNode = false }, { index = 4, isSwitchNode = true } }
switchD.nextNode = { { index = 27, isSwitchNode = false } }
switchD.previousNode = { { index = 26, isSwitchNode = false }, { index = 3, isSwitchNode = true } }
switchA.nextSpline = {}
switchA.previousSpline = {}
switchB.nextSpline = {}
switchB.previousSpline = {}
switchC.nextSpline = {}
switchC.previousSpline = {}
switchD.nextSpline = {}
switchD.previousSpline = {}
switchA.nextSplineReversed = {}
switchA.previousSplineReversed = {}
switchB.nextSplineReversed = {}
switchB.previousSplineReversed = {}
switchC.nextSplineReversed = {}
switchC.previousSplineReversed = {}
switchD.nextSplineReversed = {}
switchD.previousSplineReversed = {}
switchA.nextSelection = 1
switchA.previousSelection = 1
switchB.nextSelection = 1
switchB.previousSelection = 1
switchC.nextSelection = 1
switchC.previousSelection = 1
switchD.nextSelection = 1
switchD.previousSelection = 1
switchA.targetSpeed = 0
switchB.targetSpeed = 0
switchC.targetSpeed = 0
switchD.targetSpeed = 0
switchNodes[1] = switchA
switchNodes[2] = switchB
switchNodes[3] = switchC
switchNodes[4] = switchD
print(switchNodes)
print(nodes)
local displacementModifier = DisplacementModifier.new(Vector3.new(0.3, 0.4, 0), 100, 2, 0.6)
local routeNetwork = RouteNetwork.new(nodes, switchNodes, displacementModifier)
print(routeNetwork)
print(routeNetwork.splineNodes)

for splineIndex, spline in pairs(routeNetwork.splines) do
	local folder = Instance.new("Folder")
	folder.Name = "Spline" .. tostring(splineIndex)
	local segmentCount = math.round(spline.lut.length / railSegmentLength)
	local segmentT = 1 / segmentCount
	for i = 1, segmentCount do
		renderRailSegment(splineIndex, routeNetwork, (i - 1) * segmentT, i * segmentT, folder)
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
			node1 = { index = 1, isSwitchNode = false },
			node2 = { index = 2, isSwitchNode = false },
			t = 0,
		}
		local intersectionLocation = routeNetwork:intersectSphere(pos, r, startLocation, 50, false)
		if intersectionLocation then
			local spline, t = routeNetwork:getSplineAndT(intersectionLocation)
			workspace.Point.Position = spline:getPoint(spline.lut:inverseLookup(t))
		end
	end
end)

local Train = require(game.ReplicatedStorage.src.TrainSystemV2.Train)
local lastCamPos = workspace.CurrentCamera.CFrame.Position
local layout: Train.TrainLayout = {
	--[[
	{ car = "TGVEngine", reversed = false },
	{ car = "TGVConnection", reversed = false },
	{ car = "TGVCarriage", reversed = false },
	{ car = "TGVCarriage", reversed = true },
	{ car = "TGVConnection", reversed = true },
	{ car = "TGVEngine", reversed = true },
	]]
	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = true },
	{ car = "FlatcarTest", reversed = false },
	{ car = "FlatcarTest", reversed = false },

	{ car = "SovietCarriage", reversed = false },
	{ car = "SovietCarriage", reversed = false },
	--[[
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

local switchSelection: { RouteNetwork.SwitchSelectionOverride } =
	{ { nextSelection = 1 }, { nextSelection = 1 }, { previousSelection = 1 }, { previousSelection = 1 } }

local myTrain = Train.fromLayout(
	layout,
	{ node1 = { index = 1, isSwitchNode = false }, node2 = { index = 2, isSwitchNode = false }, t = 0.1 },
	routeNetwork,
	switchSelection
)

local Switch1: BoolValue = game.ReplicatedStorage.Switch1
local Switch2: BoolValue = game.ReplicatedStorage.Switch2
Switch1:GetPropertyChangedSignal("Value"):Connect(function()
	if Switch1.Value then
		switchSelection[1] = { nextSelection = 2 }
		switchSelection[2] = { nextSelection = 2 }
	else
		switchSelection[1] = { nextSelection = 1 }
		switchSelection[2] = { nextSelection = 1 }
	end
end)

Switch2:GetPropertyChangedSignal("Value"):Connect(function()
	if Switch2.Value then
		switchSelection[3] = { previousSelection = 2 }
		switchSelection[4] = { previousSelection = 2 }
	else
		switchSelection[3] = { previousSelection = 1 }
		switchSelection[4] = { previousSelection = 1 }
	end
end)

myTrain.model.Parent = workspace.Trains
local speed = game.ReplicatedStorage.Speed.Value

game.ReplicatedStorage.Speed:GetPropertyChangedSignal("Value"):Connect(function()
	speed = game.ReplicatedStorage.Speed.Value
end)

local camToggle = false
local timeScale = 1.0
local framTimeCap = 1 / 240

if camToggle then
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.FieldOfView = 100
end

function setFOV(distance)
	local S = 70
	local fov = 2 * math.atan(S / (2 * distance))
	workspace.CurrentCamera.FieldOfView = math.deg(fov)
end

game.ReplicatedStorage.some.Event:Connect(function(a)
	myTrain.cars[1].frontBogie.springPivot = myTrain.cars[1].frontBogie.springPivot + Vector3.new(0, a, 0)
end)
local running = true
game.ReplicatedStorage.toggleRuntime.Event:Connect(function()
	running = not running
end)

game.ReplicatedStorage.PrintState.Event:Connect(function()
	print(myTrain)
end)

local player = game.Players.LocalPlayer

local rayParam = RaycastParams.new()
rayParam.FilterType = Enum.RaycastFilterType.Include
rayParam.FilterDescendantsInstances = { workspace.Trains }
local HRPVelocityOnTrain: Vector3? = nil
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
	deltaTime = math.max(framTimeCap, deltaTime) * timeScale
	if not running then
		return
	end
	debug.profilebegin("Train")
	if math.abs(myTrain.cars[1].cf.Position.Y) > 1000 then
		print("Train voided")
		print(myTrain.cars[1].cf.Position)
		print(myTrain.cars[1].frontBogie.springDisplacement)
	end
	--Evaluate Character Platform
	local character = player.Character
	local lastGroundCFrame
	local lastCar, lastWhichBogie
	local lastHRPCFrame
	local HRP
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
		if humanoidRootPart then
			HRP = humanoidRootPart
			local hit = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -20, 0), rayParam)
			if hit then
				local hitPart = hit.Instance
				local hitModel = hitPart:FindFirstAncestorWhichIsA("Model") :: Model
				if hitModel then
					local carIndex, whichBogie = myTrain:getBogieAndCarIndexFromModel(hitModel)
					local car
					if carIndex then
						car = myTrain.cars[carIndex]
					end
					if car and whichBogie == true then
						lastGroundCFrame = car.frontBogie.cf
					elseif car and whichBogie == false then
						lastGroundCFrame = car.rearBogie.cf
					elseif car then
						lastGroundCFrame = car.cf
					end
					if car then
						lastCar = car
						lastWhichBogie = whichBogie
					end
				end
			end
		end
	end
	--Train Calculation
	local acceleration = 0 --myTrain.averageSlopeSine * -300
	local stepDistance = deltaTime * speed + 0.5 * acceleration * deltaTime ^ 2
	speed += acceleration * deltaTime
	local newLocation = routeNetwork:stepDistance(myTrain.location, stepDistance, switchSelection)
	myTrain:setLocation(newLocation, speed, deltaTime)
	local myCar = myTrain.cars[1]
	local frontBogie = myCar.frontBogie
	local cf = myCar.cf
	local lookTo = cf.Position + cf.LookVector * 20
	local target = lookTo + cf.LookVector * 105 + cf.UpVector * 00
	local blend = math.pow(0.5, deltaTime * 4)
	lastCamPos = lastCamPos * blend + target * (1 - blend)
	local fixedLookTo = frontBogie.cf:PointToWorldSpace(Vector3.new(0, 7, 0))
	local fixedTarget = frontBogie.cf.Position
	if camToggle then
		workspace.CurrentCamera.CFrame =
			CFrame.lookAlong(fixedLookTo, -frontBogie.cf.upVector, frontBogie.cf.lookVector)
	end
	--setFOV((lastCamPos - lookTo).Magnitude)
	--Update Character
	if lastGroundCFrame and lastCar then
		local newGroundCFrame
		if lastWhichBogie == true then
			newGroundCFrame = lastCar.frontBogie.cf
		elseif lastWhichBogie == false then
			newGroundCFrame = lastCar.rearBogie.cf
		else
			newGroundCFrame = lastCar.cf
		end
		local _, deltaYRotation = lastGroundCFrame:ToObjectSpace(newGroundCFrame):ToEulerAnglesYXZ()
		if HRP then
			local lastHRPPosition = HRP.Position
			if HRPVelocityOnTrain == nil then
				HRP.AssemblyLinearVelocity = Vector3.zero
			end
			HRP.CFrame = newGroundCFrame:ToWorldSpace(lastGroundCFrame:ToObjectSpace(HRP.CFrame))
			HRPVelocityOnTrain = (HRP.Position - lastHRPPosition) / deltaTime
			workspace.CurrentCamera.CFrame = CFrame.fromEulerAnglesYXZ(0, deltaYRotation, 0)
				* workspace.CurrentCamera.CFrame
		end
	elseif HRP and HRPVelocityOnTrain then
		--print(HRPVelocityOnTrain)
		HRP.AssemblyLinearVelocity = HRPVelocityOnTrain
		HRPVelocityOnTrain = nil
	end
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

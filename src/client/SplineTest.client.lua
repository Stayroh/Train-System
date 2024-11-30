--!strict
if not game:IsLoaded() then
	game.Loaded:Wait()
end

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

function renderRailSegment(spline: Spline.Spline, Lut, t_start: number, t_end: number)
	local segment = originalRail:Clone()
	local bones = segment.Bone0:GetChildren()
	local correctedStartT = Lut:getCorrectetT(t_start)
	local startCF = getCFrame(
		spline:getPoint(correctedStartT),
		spline:getTangent(correctedStartT),
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
		local correctedT = Lut:getCorrectetT(t)
		local cf =
			getCFrame(spline:getPoint(correctedT), spline:getTangent(correctedT), spline:getAcceleration(correctedT), 3)
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

local luts = {}

for i = 1, #knots do
	local P0, P1, P2, P3 =
		knots[i],
		knots[i + 1] or knots[i + 1 - #knots],
		knots[i + 2] or knots[i + 2 - #knots],
		knots[i + 3] or knots[i + 3 - #knots]
	local spline = BSpline.new(P0, P1, P2, P3)
	local Lut = SplineLut.generate(spline, 100, 100)
	luts[i] = Lut

	local segmentCount = math.round(Lut.length / railSegmentLength)
	local segmentT = 1 / segmentCount

	for i = 1, segmentCount do
		renderRailSegment(spline, Lut, (i - 1) * segmentT, i * segmentT)
	end
end

task.wait(3)

workspace.Sounds.Minecart:Play()
workspace.Sounds.Wind:Play()

task.spawn(function()
	local songs = {
		workspace.Music.RussianGun,
		workspace.Music.Accordion,
		workspace.Music.Moscow,
		workspace.Music.FolkDance,
	}
	local currentSong = 1
	while true do
		local song = songs[currentSong]
		song.TimePosition = 0
		song:Play()
		song.Ended:Wait()
		currentSong = currentSong % #songs + 1
	end
end)

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

local currentDistance = 0
local LutIndex = 1
local speed = 0
local power = 40

local averageAcceleration = 0
local lastSpeed = 0

local totalTime = 0
game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	totalTime += deltaTime
	local Lut = luts[LutIndex]
	local spline = Lut.Spline
	local correctedT = Lut:getCorrectetT(currentDistance / Lut.length)
	local slope = spline:getTangent(correctedT).Unit:Dot(Vector3.new(0, 1, 0))
	local acceleration = -G * slope + ((LutIndex < 2 or LutIndex > #luts - 1) and power or 0)
	local stepDistance = speed * deltaTime + 0.5 * acceleration * deltaTime ^ 2
	speed += acceleration * deltaTime
	local blend = math.pow(0.5, deltaTime * 2)
	averageAcceleration = averageAcceleration * blend + (speed - lastSpeed) / deltaTime * (1 - blend)
	lastSpeed = speed
	local newDistance = currentDistance + stepDistance
	while newDistance > Lut.length or newDistance < 0 do
		if newDistance > Lut.length then
			if LutIndex == #luts then
				LutIndex = 1
				newDistance -= Lut.length
				Lut = luts[LutIndex]
				print("Forwards loop")
				continue
			end
			print("Forwards")
			newDistance -= Lut.length
			LutIndex += 1
			Lut = luts[LutIndex]
		else
			if LutIndex == 1 then
				LutIndex = #luts
				newDistance += luts[LutIndex].length
				Lut = luts[LutIndex]
				print("Backwards loop")
				continue
			end
			print("Backwards")

			LutIndex -= 1
			newDistance += luts[LutIndex].length
			Lut = luts[LutIndex]
		end
	end
	spline = Lut.Spline
	currentDistance = newDistance
	correctedT = Lut:getCorrectetT(currentDistance / Lut.length)
	local cf = getCFrame(
		spline:getPoint(correctedT),
		spline:getTangent(correctedT),
		spline:getAcceleration(correctedT),
		speed / 50
	) * CFrame.Angles(0, math.pi, 0)
	cf = cf + cf.UpVector * 4
	workspace.CurrentCamera.CFrame = cf
	local volume = math.min(speed / 500, 1)
	workspace.Sounds.Minecart.Volume = volume * 2
	workspace.Sounds.Wind.Volume = volume * 4
	local absAccel = math.max(0, averageAcceleration)
	workspace.CurrentCamera.FieldOfView = 60 + 60 * absAccel / (absAccel + 30)
	workspace.Particles.CFrame = cf + cf.LookVector * 24
	workspace.Debris.CFrame = cf + cf.LookVector * 12 - cf.UpVector * 2
end)

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

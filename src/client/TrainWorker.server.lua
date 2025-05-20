local actor = script:GetActor()
local RouteNetwork = require(game.ReplicatedStorage.src.TrainSystemV2.RouteNetwork)
local BezierSpline = require(game.ReplicatedStorage.src.BezierSpline)
local SplineLut = require(game.ReplicatedStorage.src.SplineLut)
local workerName = actor.Name

actor:BindToMessage("TrainSpawn", function(routeNetworkClone)
	print("Hiii")
	local routeNetwork: RouteNetwork.RouteNetwork =
		setmetatable(routeNetworkClone, RouteNetwork) :: RouteNetwork.RouteNetwork
	for i, spline in pairs(routeNetwork.splines) do
		setmetatable(spline, BezierSpline)
		setmetatable(spline.lut, SplineLut)
	end
	local train: { { part: BasePart, location: RouteNetwork.RouteNetworkLocation, position: Vector3 } } = {}
	local trainLocation: RouteNetwork.RouteNetworkLocation = {
		node1 = 1,
		node2 = 2,
		t = 0,
	}
	local trainSpeed = 100
	local radius = 10
	local partColor = BrickColor.random()
	for i = 1, 20 do
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Transparency = 0.5
		part.BrickColor = partColor
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		train[i] = {
			part = part,
			location = trainLocation,
			position = Vector3.zero,
		}
		part.Parent = actor
	end
	game:GetService("RunService").PreRender:ConnectParallel(function(deltaTime)
		debug.profilebegin(workerName .. " parallel")
		local stepDistance = trainSpeed * deltaTime
		for i = 1, 100 do
			trainLocation = routeNetwork:stepDistance(trainLocation, stepDistance)
			train[1].position = routeNetwork:getPoint(trainLocation)
			for i = 2, #train do
				local newLocation =
					routeNetwork:intersectSphere(train[i - 1].position, radius, train[i - 1].location, 3)
				if newLocation then
					train[i].location = newLocation
				end
				train[i].position = routeNetwork:getPoint(train[i].location)
			end
		end
		debug.profileend()
		task.synchronize()
		debug.profilebegin(workerName .. " serial")

		for i = 1, #train do
			train[i].part.Position = train[i].position
		end
	end)
end)

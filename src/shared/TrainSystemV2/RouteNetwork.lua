--!strict
local BezierSpline = require(game.ReplicatedStorage.src.BezierSpline)

local RouteNetwork: RouteNetworkClass = {} :: RouteNetworkClass
RouteNetwork.__index = RouteNetwork

type RouteNetworkClass = {
	__index: RouteNetworkClass,
	new: (nodes: { Node }) -> RouteNetwork,
	createSplines: (self: RouteNetwork) -> { BezierSpline.BezierSpline },
	checkNeighbourRelation: (self: RouteNetwork, currentNode: number, neighbourNode: number) -> boolean?, -- Returns true if nighbourNode is currentNode's nextNode, false if it is the previousNode, and nil if it is not a neighbour.
	getSplineAndT: (self: RouteNetwork, location: RouteNetworkLocation) -> (BezierSpline.BezierSpline, number, boolean), -- Returns the spline and the position on the spline for a given location. Also returns whether the spline is reversed from the perspective of the location.
	getConnectingSpline: (self: RouteNetwork, node1: number, node2: number) -> BezierSpline.BezierSpline, -- Returns the spline connecting two nodes.
	getPoint: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the position of a location on the route network.
	getVelocity: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the velocity of a location on the route network.
	getAcceleration: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the acceleration of a location on the route network.
	getFollowingNode: (self: RouteNetwork, node1: number, node2: number) -> number?, -- Returns the index of the node which is connected to node2 but not node1. Returns nil if no such node exists.
	stepDistance: (
		self: RouteNetwork,
		location: RouteNetworkLocation,
		distance: number
	) -> (RouteNetworkLocation, number), -- Returns a location that is distance away from the given location. Accepts all real numbers for distance. In case the the full distance can not be covered, it will go to the furthest possible location and return the remaining distance.
	itersectSphere: (
		self: RouteNetwork,
		center: Vector3,
		radius: number,
		traverseFrom: RouteNetworkLocation,
		maxSplines: number
	) -> RouteNetworkLocation?, -- Returns the location of the first intersection of a sphere with the route network. Returns nil if no intersection is found. Starts searching from traverseFrom in the direction of the next node. Stops after maxSplines splines have been traversed.
}

export type Node = {
	position: Vector3, -- Position of the node. Start or End of a bezier curve. (P0 or P3)
	handle: Vector3, -- Handle of the node. For next note, position + handle is P1. For previous node, position - handle is P2.
	nextNode: number?, -- Index of the next node in the route network.
	previousNode: number?, -- Index of the previous node in the route network.
	nextSpline: number?, -- Index of the next spline in the route network. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	previousSpline: number?, -- Index of the previous spline in the route network. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	nextSplineReversed: boolean?, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	previousSplineReversed: boolean?, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	targetSpeed: number, -- Target speed of the train at this node. Used for bank angle calculations.
} -- Direct association with a combination of a bezier anchor and handle.

export type RouteNetworkLocation = {
	node1: number, -- Index of the starting node.
	node2: number, -- Index of the ending node.
	t: number, -- Position between the two nodes. 0 is node1, 1 is node2. 0 ≤ t ≤ 1.
} -- Describes a specific location and direction on the route network. Orientation is determined by the order of the nodes, facing towards node2.

export type RouteNetwork = typeof(setmetatable(
	{} :: {
		nodes: { Node },
		splines: { BezierSpline.BezierSpline },
		totalLength: number, -- Total length of the route network. Calculated by summing the length of all splines.
	},
	RouteNetwork
))

function RouteNetwork:itersectSphere(
	center: Vector3,
	radius: number,
	traverseFrom: RouteNetworkLocation,
	maxSplines: number
): RouteNetworkLocation?
end

function RouteNetwork:getConnectingSpline(node1: number, node2: number): BezierSpline.BezierSpline
	local node = self.nodes[node1]
	if node.nextNode == node2 and node.nextSpline then
		return self.splines[node.nextSpline]
	elseif node.previousNode == node2 and node.previousSpline then
		return self.splines[node.previousSpline]
	end
	assert(false, string.format("No spline found between node %d and %d", node1, node2))
end

function RouteNetwork:getFollowingNode(node1: number, node2: number): number?
	local followingNodeDirectionOfNode2 = self:checkNeighbourRelation(node2, node1)
	assert(followingNodeDirectionOfNode2 ~= nil, string.format("Node %d is not a neighbour of node %d", node2, node1))
	if followingNodeDirectionOfNode2 then
		return self.nodes[node2].previousNode
	else
		return self.nodes[node2].nextNode
	end
end

function RouteNetwork:stepDistance(location: RouteNetworkLocation, distance: number): (RouteNetworkLocation, number)
	local node1, node2, t = location.node1, location.node2, location.t
	local didSwap = distance < 0
	if didSwap then
		node1, node2 = node2, node1
		t = 1 - t
	end
	distance = math.abs(distance)
	local spline = self:getConnectingSpline(node1, node2)
	local length = spline.lut:getLength()
	local targetDistance = length * t + distance
	while targetDistance > length do
		print("Crossed Spline")
		local nextNode = self:getFollowingNode(node1, node2)
		if not nextNode then
			local newLocation =
				{ node1 = didSwap and node2 or node1, node2 = didSwap and node1 or node2, t = didSwap and 0 or 1 }
			return newLocation, (targetDistance - length) * (didSwap and -1 or 1)
		end
		node1, node2 = node2, nextNode
		targetDistance -= length
		spline = self:getConnectingSpline(node1, node2)
		length = spline.lut:getLength()
	end
	t = targetDistance / length
	if didSwap then
		node1, node2 = node2, node1
		t = 1 - t
	end
	local newLocation = { node1 = node1, node2 = node2, t = t }
	return newLocation, 0
end

function RouteNetwork:getSplineAndT(location: RouteNetworkLocation): (BezierSpline.BezierSpline, number, boolean)
	local node1 = self.nodes[location.node1]
	if location.node2 == node1.nextNode and node1.nextSpline and node1.nextSplineReversed ~= nil then
		local spline = self.splines[node1.nextSpline]
		return spline, (node1.nextSplineReversed and 1 - location.t or location.t), node1.nextSplineReversed
	elseif location.node2 == node1.previousNode and node1.previousSpline and node1.previousSplineReversed ~= nil then
		local spline = self.splines[node1.previousSpline]
		return spline, (node1.previousSplineReversed and 1 - location.t or location.t), node1.previousSplineReversed
	end
	assert(false, string.format("No spline found between node %d and %d", location.node1, location.node2))
end

function RouteNetwork:getPoint(location: RouteNetworkLocation): Vector3
	local spline, t = self:getSplineAndT(location)
	return spline:getPoint(spline.lut:inverseLookup(t))
end

function RouteNetwork:getVelocity(location: RouteNetworkLocation): Vector3
	local spline, t, reversed = self:getSplineAndT(location)
	return spline:getVelocity(spline.lut:inverseLookup(t)) * (reversed and -1 or 1)
end

function RouteNetwork:getAcceleration(location: RouteNetworkLocation): Vector3
	local spline, t = self:getSplineAndT(location)
	return spline:getAcceleration(spline.lut:inverseLookup(t))
end

function RouteNetwork:checkNeighbourRelation(currentNode: number, neighbourNode: number): boolean?
	local node = self.nodes[currentNode]
	if node.nextNode == neighbourNode then
		return true
	elseif node.previousNode == neighbourNode then
		return false
	else
		return nil
	end
end

function RouteNetwork:createSplines(): { BezierSpline.BezierSpline }
	local splines = {}
	for i = 1, #self.nodes do
		local node = self.nodes[i]
		if node.nextNode and node.nextSpline == nil then
			local nextNode = self.nodes[node.nextNode]
			local isNextNodeNext = self:checkNeighbourRelation(node.nextNode, i)
			local P0 = node.position
			local P1 = P0 + node.handle
			local P3 = nextNode.position
			local P2 = P3 + nextNode.handle * (isNextNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			node.nextSpline = splineIndex
			node.nextSplineReversed = false
			if isNextNodeNext then
				nextNode.nextSpline = splineIndex
				nextNode.nextSplineReversed = true
			else
				nextNode.previousSpline = splineIndex
				nextNode.previousSplineReversed = true
			end
			self.totalLength += spline.lut:getLength()
		end
		if node.previousNode and node.previousSpline == nil then
			local previousNode = self.nodes[node.previousNode]
			local isPreviousNodeNext = self:checkNeighbourRelation(node.previousNode, i)
			local P0 = node.position
			local P1 = P0 - node.handle
			local P3 = previousNode.position
			local P2 = P3 + previousNode.handle * (isPreviousNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			node.previousSpline = splineIndex
			node.previousSplineReversed = false
			if isPreviousNodeNext then
				previousNode.nextSpline = splineIndex
				previousNode.nextSplineReversed = true
			else
				previousNode.previousSpline = splineIndex
				previousNode.previousSplineReversed = true
			end
			self.totalLength += spline.lut:getLength()
		end
	end
	print("Total length of route network: " .. self.totalLength)
	return splines
end

function RouteNetwork.new(nodes: { Node }): RouteNetwork
	local self = setmetatable({}, RouteNetwork)
	self.totalLength = 0
	self.nodes = nodes
	self.splines = self:createSplines()
	return self
end

return RouteNetwork

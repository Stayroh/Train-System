--!strict
local DisplacementModifier = require(game.ReplicatedStorage.src.DisplacementModifier)
local BezierSpline = require(game.ReplicatedStorage.src.BezierSpline)

local RouteNetwork: RouteNetworkClass = {} :: RouteNetworkClass
RouteNetwork.__index = RouteNetwork

type RouteNetworkClass = {
	__index: RouteNetworkClass,
	new: (
		nodes: { Node },
		switchNodes: { SwitchNode },
		displacementModifier: DisplacementModifier.DisplacementModifier?
	) -> RouteNetwork,
	createSplines: (self: RouteNetwork) -> { BezierSpline.BezierSpline },
	checkNeighbourRelation: (
		self: RouteNetwork,
		currentNode: NodeReference,
		neighbourNode: NodeReference
	) -> (boolean?, number?), -- Returns true if nighbourNode is currentNode's nextNode, false if it is the previousNode, and nil if it is not a neighbour.
	getSplineAndT: (self: RouteNetwork, location: RouteNetworkLocation) -> (BezierSpline.BezierSpline, number, boolean), -- Returns the spline and the position on the spline for a given location. Also returns whether the spline is reversed from the perspective of the location.
	getConnectingSpline: (self: RouteNetwork, node1: number, node2: number) -> (BezierSpline.BezierSpline, boolean), -- Returns the spline connecting two nodes. Also returns whether the spline is reversed from the perspective of node1 to node2.
	getPoint: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the position of a location on the route network.
	getVelocity: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the velocity of a location on the route network.
	getAcceleration: (self: RouteNetwork, location: RouteNetworkLocation) -> Vector3, -- Returns the acceleration of a location on the route network.
	getCFrames: (self: RouteNetwork, location: RouteNetworkLocation) -> CFrame, -- Returns the CFrame of a location on the route network.
	getTargetSpeed: (self: RouteNetwork, location: RouteNetworkLocation) -> number, -- Returns the target speed of a location on the route network.
	getFollowingNode: (self: RouteNetwork, node1: number, node2: number) -> number?, -- Returns the index of the node which is connected to node2 but not node1. Returns nil if no such node exists.
	getNodeByNodeReference: (self: RouteNetwork, nodeLink: NodeReference) -> Node | SwitchNode,
	stepDistance: (
		self: RouteNetwork,
		location: RouteNetworkLocation,
		distance: number
	) -> (RouteNetworkLocation, number), -- Returns a location that is distance away from the given location. Accepts all real numbers for distance. In case the the full distance can not be covered, it will go to the furthest possible location and return the remaining distance.
	intersectSphere: (
		self: RouteNetwork,
		center: Vector3,
		radius: number,
		traverseFrom: RouteNetworkLocation,
		maxSplines: number,
		invertLocation: boolean
	) -> RouteNetworkLocation?, -- Returns the location of the first intersection of a sphere with the route network. Returns nil if no intersection is found. Starts searching from traverseFrom in the direction of the next node. Stops after maxSplines splines have been traversed.
}

export type NodeReference = {
	index: number,
	isSwitchNode: boolean,
} -- Index of the node in the route network and wether it is a SwitchNode.

export type SwitchSelectionOverride = {
	nextSelection: number?,
	previousSelection: number?,
} -- Overrides the default selection of the switch node. Used for each Train to have its own switch selection.

export type SwitchNode = {
	position: Vector3, -- Position of the node. Start or End of a bezier curve. (P0 or P3)
	handle: Vector3, -- Handle of the node. For next note, position + handle is P1. For previous node, position - handle is P2.
	nextNode: { NodeReference }, -- Array of NodeReferences of the next connecting nodes.
	previousNode: { NodeReference }, -- Array of NodeReferences of the previous connecting nodes.
	nextSpline: { number }, -- Array of indices of the next spline in the route network. The Index of this array corrosponds to the nextNode array index. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	previousSpline: { number }, -- Array of indices of the previous spline in the route network. The Index of this array corrosponds to the previousNode array index. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	nextSplineReversed: { boolean }, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	previousSplineReversed: { boolean }, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	targetSpeed: number, -- Target speed of the train at this node. Used for bank angle calculations.
	nextSelection: number, -- Selection of the switch spline and connecting node to go for as the next node. Defualt is 1
	previousSelection: number, -- Selection of the switch spline and connecting node to go for as the previous node. Defualt is 1
} -- Like Node Type, but with multiple connections.

export type Node = {
	position: Vector3, -- Position of the node. Start or End of a bezier curve. (P0 or P3)
	handle: Vector3, -- Handle of the node. For next note, position + handle is P1. For previous node, position - handle is P2.
	nextNode: NodeReference?, -- NodeReference of the next connecting node.
	previousNode: NodeReference?, -- NodeReference of the previous connecting node.
	nextSpline: number?, -- Index of the next spline in the route network. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	previousSpline: number?, -- Index of the previous spline in the route network. Note that this will only exist after the RouteNetwork has been fully constructed. Meaning that this attribute will be overwritten by the RouteNetwork object and should not be there when passing the nodes to the RouteNetwork constructor.
	nextSplineReversed: boolean?, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	previousSplineReversed: boolean?, -- Whether this node connects to the end of the to this side connected spline. This happens when the spline was created be the other node.
	targetSpeed: number, -- Target speed of the train at this node. Used for bank angle calculations.
} -- Direct association with a combination of a qbezier anchor and handle.

export type RouteNetworkLocation = {
	node1: NodeReference,
	node2: NodeReference,
	t: number, -- Position between the two nodes. 0 is node1, 1 is node2. 0 ≤ t ≤ 1.
} -- Describes a specific location and direction on the route network. Orientation is determined by the order of the nodes, facing towards node2.

export type RouteNetwork = typeof(setmetatable(
	{} :: {
		nodes: { Node },
		switchNodes: { SwitchNode },
		displacementModifier: DisplacementModifier.DisplacementModifier?, -- Displacement modifier for the route network.
		splines: { BezierSpline.BezierSpline },
		totalLength: number, -- Total length of the route network. Calculated by summing the length of all splines.
	},
	RouteNetwork
))

function RouteNetwork:intersectSphere(
	center: Vector3,
	radius: number,
	traverseFrom: RouteNetworkLocation,
	maxSplines: number,
	invertDirection: boolean
): RouteNetworkLocation?
	local node1, node2 = traverseFrom.node1, traverseFrom.node2
	local t = traverseFrom.t
	if invertDirection then
		node1, node2 = node2, node1
		t = 1 - t
	end

	local spline, isReversed = self:getConnectingSpline(node1, node2)
	local startT = isReversed and 1 - t or t
	local intersectionT
	local i = 0
	while intersectionT == nil and i < maxSplines do
		local intersection = spline:intersectSphere(center, radius, spline.lut:inverseLookup(startT), not isReversed)
		if intersection then
			intersectionT = spline.lut:forwardLookup(intersection)
			break
		end
		local newNode2 = self:getFollowingNode(node1, node2)
		if not newNode2 then
			break
		end
		node1, node2 = node2, newNode2
		spline, isReversed = self:getConnectingSpline(node1, node2)
		startT = isReversed and 1 or 0
		i += 1
	end
	if intersectionT then
		if invertDirection then
			intersectionT = 1 - intersectionT
			node1, node2 = node2, node1
		end
		return { node1 = node1, node2 = node2, t = isReversed and 1 - intersectionT or intersectionT }
	else
		return nil
	end
end

function RouteNetwork:getNodeByNodeReference(nodeLink: NodeReference): Node | SwitchNode
	return nodeLink.isSwitchNode and self.switchNodes[nodeLink.index] or self.nodes[nodeLink.index]
end

function RouteNetwork:getConnectingSpline(node1: number, node2: number): (BezierSpline.BezierSpline, boolean)
	local node = self.nodes[node1]
	if node.nextNode == node2 and node.nextSpline and node.nextSplineReversed ~= nil then
		return self.splines[node.nextSpline], node.nextSplineReversed
	elseif node.previousNode == node2 and node.previousSpline and node.previousSplineReversed ~= nil then
		return self.splines[node.previousSpline], node.previousSplineReversed
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

function RouteNetwork:getCFrames(location: RouteNetworkLocation): CFrame
	local upVector = Vector3.new(0, 1, 0)
	local G = 40
	local spline, t = self:getSplineAndT(location)
	local correctedT = spline.lut:inverseLookup(t)
	local excpectedSpeed = self:getTargetSpeed(location)
	local point = spline:getPoint(correctedT)
	local velocity = spline:getVelocity(correctedT)
	local acceleration = spline:getAcceleration(correctedT)
	local normal = velocity:Cross(upVector).Unit
	local curvatureVector = velocity:Cross(velocity:Cross(acceleration)) / velocity.Magnitude ^ 3
	local k = -normal:Dot(curvatureVector)
	local bankAngle = math.atan(excpectedSpeed ^ 2 * k / G)
	return CFrame.lookAt(point, point + velocity, math.sin(bankAngle) * normal + math.cos(bankAngle) * upVector)
end

function RouteNetwork:getTargetSpeed(location: RouteNetworkLocation): number
	local node1Speed = self.nodes[location.node1].targetSpeed
	local node2Speed = self.nodes[location.node2].targetSpeed
	return node1Speed + (node2Speed - node1Speed) * location.t
end

function RouteNetwork:checkNeighbourRelation(
	currentNode: NodeReference,
	neighbourNode: NodeReference
): (boolean?, number?)
	if currentNode.isSwitchNode then
		local node = self.switchNodes[currentNode.index]
		for i = 1, #node.nextNode do
			if
				node.nextNode[i].index == neighbourNode.index
				and node.nextNode[i].isSwitchNode == neighbourNode.isSwitchNode
			then
				return true, i
			end
		end
		for i = 1, #node.previousNode do
			if
				node.previousNode[i].index == neighbourNode.index
				and node.previousNode[i].isSwitchNode == neighbourNode.isSwitchNode
			then
				return false, i
			end
		end
		return nil, nil
	else
		local node = self.nodes[currentNode.index]
		if
			node.nextNode
			and node.nextNode.index == neighbourNode.index
			and node.nextNode.isSwitchNode == neighbourNode.isSwitchNode
		then
			return true, nil
		elseif
			node.previousNode
			and node.previousNode.index == neighbourNode.index
			and node.previousNode.isSwitchNode == neighbourNode.isSwitchNode
		then
			return false, nil
		else
			return nil, nil
		end
	end
end

function RouteNetwork:createSplines(): { BezierSpline.BezierSpline }
	local splines = {}
	-- For all switch nodes
	for i = 1, #self.switchNodes do
		local switchNode = self.switchNodes[i]
		local selfReference = { index = i, isSwitchNode = true }
		-- For all next nodes
		for j = 1, #switchNode.nextNode do
			if switchNode.nextSpline[j] then
				continue
			end
			local nextNode = self:getNodeByNodeReference(switchNode.nextNode[j])
			local isNextNodeNext, nextNodeConnectionIndex =
				self:checkNeighbourRelation(switchNode.nextNode[j], selfReference)
			local P0 = switchNode.position
			local P1 = P0 + switchNode.handle
			local P3 = nextNode.position
			local P2 = P3 + nextNode.handle * (isNextNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3, self.displacementModifier)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			switchNode.nextSpline[j] = splineIndex
			switchNode.nextSplineReversed[j] = false
			if switchNode.nextNode[j].isSwitchNode then
				if isNextNodeNext then
					nextNode.nextSpline[nextNodeConnectionIndex] = splineIndex
					nextNode.nextSplineReversed[nextNodeConnectionIndex] = true
				else
					nextNode.previousSpline[nextNodeConnectionIndex] = splineIndex
					nextNode.previousSplineReversed[nextNodeConnectionIndex] = true
				end
			else
				if isNextNodeNext then
					nextNode.nextSpline = splineIndex
					nextNode.nextSplineReversed = true
				else
					nextNode.previousSpline = splineIndex
					nextNode.previousSplineReversed = true
				end
			end
			self.totalLength += spline.lut:getLength()
		end
		-- For all previous nodes
		for j = 1, #switchNode.previousNode do
			if switchNode.previousSpline[j] then
				continue
			end
			local previousNode = self:getNodeByNodeReference(switchNode.previousNode[j])
			local isPreviousNodeNext, previousNodeConnectionIndex =
				self:checkNeighbourRelation(switchNode.previousNode[j], selfReference)
			local P0 = switchNode.position
			local P1 = P0 - switchNode.handle
			local P3 = previousNode.position
			local P2 = P3 + previousNode.handle * (isPreviousNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3, self.displacementModifier)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			switchNode.previousSpline[j] = splineIndex
			switchNode.previousSplineReversed[j] = false
			if previousNodeConnectionIndex then
				if isPreviousNodeNext then
					previousNode.nextSpline[previousNodeConnectionIndex] = splineIndex
					previousNode.nextSplineReversed[previousNodeConnectionIndex] = true
				else
					previousNode.previousSpline[previousNodeConnectionIndex] = splineIndex
					previousNode.previousSplineReversed[previousNodeConnectionIndex] = true
				end
			else
				if isPreviousNodeNext then
					previousNode.nextSpline = splineIndex
					previousNode.nextSplineReversed = true
				else
					previousNode.previousSpline = splineIndex
					previousNode.previousSplineReversed = true
				end
			end
			self.totalLength += spline.lut:getLength()
		end
	end
	-- For all nodes
	for i = 1, #self.nodes do
		local node = self.nodes[i]
		local selfReference = { index = i, isSwitchNode = false }
		if node.nextNode and node.nextSpline == nil then
			local nextNode = self:getNodeByNodeReference(node.nextNode)
			local isNextNodeNext, nextNodeConnectionIndex = self:checkNeighbourRelation(node.nextNode, selfReference)
			local P0 = node.position
			local P1 = P0 + node.handle
			local P3 = nextNode.position
			local P2 = P3 + nextNode.handle * (isNextNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3, self.displacementModifier)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			node.nextSpline = splineIndex
			node.nextSplineReversed = false
			if node.nextNode.isSwitchNode then
				if isNextNodeNext then
					nextNode.nextSpline[nextNodeConnectionIndex] = splineIndex
					nextNode.nextSplineReversed[nextNodeConnectionIndex] = true
				else
					nextNode.previousSpline[nextNodeConnectionIndex] = splineIndex
					nextNode.previousSplineReversed[nextNodeConnectionIndex] = true
				end
			else
				if isNextNodeNext then
					nextNode.nextSpline = splineIndex
					nextNode.nextSplineReversed = true
				else
					nextNode.previousSpline = splineIndex
					nextNode.previousSplineReversed = true
				end
			end
			self.totalLength += spline.lut:getLength()
		end
		if node.previousNode and node.previousSpline == nil then
			local previousNode = self:getNodeByNodeReference(node.previousNode)
			local isPreviousNodeNext, previousNodeConnectionIndex =
				self:checkNeighbourRelation(node.previousNode, selfReference)
			local P0 = node.position
			local P1 = P0 - node.handle
			local P3 = previousNode.position
			local P2 = P3 + previousNode.handle * (isPreviousNodeNext and 1 or -1)
			local spline = BezierSpline.new(P0, P1, P2, P3, self.displacementModifier)
			local splineIndex = #splines + 1
			splines[splineIndex] = spline
			node.previousSpline = splineIndex
			node.previousSplineReversed = false
			if previousNodeConnectionIndex then
				if isPreviousNodeNext then
					previousNode.nextSpline[previousNodeConnectionIndex] = splineIndex
					previousNode.nextSplineReversed[previousNodeConnectionIndex] = true
				else
					previousNode.previousSpline[previousNodeConnectionIndex] = splineIndex
					previousNode.previousSplineReversed[previousNodeConnectionIndex] = true
				end
			else
				if isPreviousNodeNext then
					previousNode.nextSpline = splineIndex
					previousNode.nextSplineReversed = true
				else
					previousNode.previousSpline = splineIndex
					previousNode.previousSplineReversed = true
				end
			end
			self.totalLength += spline.lut:getLength()
		end
	end
	print("Total length of route network: " .. self.totalLength)
	return splines
end

function RouteNetwork.new(
	nodes: { Node },
	switchNodes: { SwitchNode },
	displacementModifier: DisplacementModifier.DisplacementModifier?
): RouteNetwork
	local self = setmetatable({}, RouteNetwork)
	self.totalLength = 0
	self.displacementModifier = displacementModifier
	self.nodes = nodes
	self.switchNodes = switchNodes
	self.splines = self:createSplines()
	return self
end

return RouteNetwork

local SharedSource = game.ReplicatedStorage.source
local TrainSystem = SharedSource.TrainCtrl
local Networks = require(TrainSystem.Networks)
local TrainSwitch = require(TrainSystem.Switch)
local Types = require(TrainSystem.Types)
local Math = require(SharedSource.Math)
local NetPosition = require(TrainSystem.NetPosition)

local NetNav = {}

function SearchTroughConnection(Connection: number | table | nil, Value: number)
	if Connection == Value then
		return true
	end
	if type(Connection) == "table" then
		if Value == nil and #Connection == 0 then
			return true
		elseif Value == nil then
			return false
		end
		if table.find(Connection, Value) then
			return true
		end
	end
	return false
end

function NetNav.IsLine(Start: Vector3, End: Vector3, Tangent: Vector3, Tolerance: number): boolean
	local Deviation = math.abs(Tangent:Dot((End - Start).Unit))
	return Deviation >= 1 - Tolerance
end

function NetNav.GetNextNode(From: number?, To: number, TrainId: number, Network: number): number?
	local Net = Networks.GetNetwork(Network)
	if not Net then
		return
	end
	local ToNode = Net[To]
	local Direction: boolean? = nil
	local NextNode: number | table | nil = nil
	if SearchTroughConnection(ToNode.Fol, From) then
		Direction = false
		NextNode = ToNode.Pre
	else
		Direction = true
		NextNode = ToNode.Fol
	end
	if type(NextNode) ~= "table" then
		return NextNode
	end
	local SwitchReturn = TrainSwitch.GetNextNode(To, Direction, TrainId, Network)
	return SwitchReturn and SwitchReturn or NextNode[1]
end

function NetNav.GetVecPos(Pos: Types.TrainPosType): Vector3
	local From = Networks.GetNode(Pos.From, Pos.Network)
	local To = Networks.GetNode(Pos.To, Pos.Network)
	if From == nil then
		return To.Tangent * Pos.T + To.Position
	end
	if To == nil then
		return From.Tangent * Pos.T + From.Position
	end
	if not NetNav.IsLine(From.Position, To.Position, From.Tangent, 0.01) and From and To then
		return Math.ArcLerp(From.Position, To.Position, From.Tangent, Pos.T)
	end
	if To == nil then
		return From.Tangent * Pos.T + From.Position
	end
	if From == nil then
		return To.Tangent * Pos.T + To.Position
	end
	return From.Position:Lerp(To.Position, Pos.T)
end

function NetNav.PositionInRadiusBackwards(
	TrainPos: Types.TrainPosType,
	Position: Vector3,
	Radius: number,
	AlternateRadius: number,
	TrainId: number
)
	local Net = Networks.GetNetwork(TrainPos.Network)
	local Backwards = {
		[1] = TrainPos.To,
		[2] = TrainPos.From,
	}
	local Iteration = 1
	if Position ~= nil then
		repeat
			if Iteration ~= 1 then
				Backwards[Iteration + 1] =
					NetNav.GetNextNode(Backwards[Iteration - 1], Backwards[Iteration], TrainId, TrainPos.Network)
			end
			local StartNode = Backwards[Iteration + 1]
			local EndNode = Backwards[Iteration]
			if StartNode == nil then
				local P = Net[EndNode].Position
				local Direction = Net[EndNode].Tangent
				local Offset = Iteration == 1 and TrainPos.T or 0
				local Intersection =
					Math.SemiGradSphereIntersection(P + Direction * Offset, Direction, Position, Radius, false)
				if Intersection then
					return NetPosition.new(nil, EndNode, Intersection + Offset, TrainPos.Network)
				else
					break
				end
			end
			if EndNode == nil then
				local P = Net[StartNode].Position
				local Direction = Net[StartNode].Tangent
				local Intersection =
					Math.LineSphereIntersection(P, P + Direction.Unit * TrainPos.T, Position, Radius, true, false)
				if Intersection then
					return NetPosition.new(StartNode, nil, Intersection, TrainPos.Network)
				end
				Iteration += 1
				continue
			end
			if (Net[StartNode].Position - Position).Magnitude < Radius then
				Iteration += 1
				continue
			end
			local Start = Net[StartNode].Position
			local End = Net[EndNode].Position
			local Tangent = Net[StartNode].Tangent
			local Intersection = nil
			if NetNav.IsLine(Start, End, Tangent, 0.001) then
				Intersection = Math.LineSphereIntersection(Start, End, Position, Radius, true)
			else
				Intersection = Math.ArcSphereIntersection(Start, End, Tangent, Position, Radius)
			end
			if Intersection then
				return NetPosition.new(StartNode, EndNode, Intersection, TrainPos.Network)
			end

			Iteration += 1
		until Iteration > 10
	end
	local AlternatePosition = NetNav.GetVecPos(TrainPos)
	Radius = AlternateRadius
	Iteration = 1
	repeat
		if Iteration ~= 1 and Position == nil then
			Backwards[Iteration + 1] =
				NetNav.GetNextNode(Backwards[Iteration - 1], Backwards[Iteration], TrainId, TrainPos.Network)
		end
		local StartNode = Backwards[Iteration + 1]
		local EndNode = Backwards[Iteration]
		if StartNode == nil then
			local P = Net[EndNode].Position
			local Direction = Net[EndNode].Tangent
			local Offset = Iteration == 1 and TrainPos.T or 0
			local Intersection =
				Math.SemiGradSphereIntersection(P + Direction * Offset, Direction, AlternatePosition, Radius, false)
			if Intersection then
				return NetPosition.new(nil, EndNode, Intersection + Offset, TrainPos.Network)
			else
				return NetPosition.new(nil, EndNode, Offset, TrainPos.Network)
			end
		end
		if EndNode == nil then
			local P = Net[StartNode].Position
			local Direction = Net[StartNode].Tangent
			local Intersection =
				Math.LineSphereIntersection(P, P + Direction * TrainPos.T, AlternatePosition, Radius, true, false)
			if Intersection then
				return NetPosition.new(StartNode, nil, Intersection, TrainPos.Network)
			end
			Iteration += 1
			continue
		end
		if (Net[StartNode].Position - AlternatePosition).Magnitude < Radius then
			Iteration += 1
			continue
		end
		local Start = Net[StartNode].Position
		local End = Net[EndNode].Position
		local Tangent = Net[StartNode].Tangent
		local Intersection = nil
		if NetNav.IsLine(Start, End, Tangent, 0.001) then
			Intersection = Math.LineSphereIntersection(Start, End, AlternatePosition, Radius, true)
		else
			Intersection = Math.ArcSphereIntersection(Start, End, Tangent, AlternatePosition, Radius)
		end
		if Intersection then
			return NetPosition.new(StartNode, EndNode, Intersection, TrainPos.Network)
		end

		Iteration += 1
		if Iteration > 10 then
			return NetPosition.new(StartNode, EndNode, 0, TrainPos.Network)
		end
	until Iteration > 10
end

return table.freeze(NetNav)

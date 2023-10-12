local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Networks = require(TrainSystem.Networks)
local TrainSwitch = require(TrainSystem.Switch)
local Types = require(TrainSystem.Types)
local Math = require(TrainSystem.Math)
local NetPosition = require(TrainSystem.NetPosition)

local LineTolerance = 0.0001

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

function NetNav:IsLine(Start: Vector3, End: Vector3, Tangent: Vector3, Tolerance: number): boolean
	local Deviation = math.abs(Tangent:Dot((End - Start).Unit))
	return Deviation >= 1 - Tolerance
end

function NetNav:GetNextNode(From: number?, To: number, TrainId: number, Network: number): number?
	local Net = Networks:GetNetwork(Network)
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
	local SwitchReturn = TrainSwitch:GetSwitchConnection(To, Direction, TrainId, Network)
	return SwitchReturn and SwitchReturn or NextNode[1]
end

function NetNav:CreateCFrame(Position, Tangent, Rotation): CFrame
	return CFrame.lookAt(Vector3.zero, Tangent):ToWorldSpace(CFrame.Angles(0, 0, Rotation)) + Position
end

function NetNav:StepDistance(Position: Types.TrainPosType, Distance: number, TrainId: number): Types.TrainPosType
	local Rest = Position.T
	local From, To = Position.From, Position.To
	local ToGo = Distance
	local Flip = false
	if Distance < 0 then
		ToGo *= -1
		From, To = To, From
		if From ~= nil and To ~= nil then
			Rest = 1 - Rest
		end
		Flip = true
	end
	local Pos
	while true do
		if To == nil then
			local D = Rest + ToGo
			Pos = NetPosition.new(From, To, D, Position.Network)
			break
		end
		if From == nil then
			if Rest >= ToGo then
				local D = Rest - ToGo
				Pos = NetPosition.new(From, To, D, Position.Network)
				break
			else
				ToGo -= Rest
				From, To = To, self:GetNextNode(From, To, TrainId, Position.Network)
				Rest = 0
				continue
			end
		end
		local Length = self:GetArcLength(From, To, Position.Network)
		if (1 - Rest) * Length >= ToGo then
			local D = ToGo / Length + Rest
			D = Flip and 1 - D or D
			Pos = NetPosition.new(From, To, D, Position.Network)
			break
		else
			ToGo -= (1 - Rest) * Length
			From, To = To, self:GetNextNode(From, To, TrainId, Position.Network)
			Rest = 0
		end
	end

	if Flip then
		return NetPosition.new(Pos.To, Pos.From, Pos.T, Pos.Network)
	end
	return Pos
end

function NetNav:GetArcLength(From: number, To: number, NetworkId: number)
	local N1 = Networks:GetNode(From, NetworkId)
	local N2 = Networks:GetNode(To, NetworkId)
	local P1, P2, T = N1.Position, N2.Position, N1.Tangent
	if self:IsLine(P1, P2, T, LineTolerance) then
		return (P1 - P2).Magnitude
	end
	local Origin, Radius = Math:SphereFromArc(P1, P2, T)
	return Radius * math.acos((P1 - Origin).Unit:Dot((P2 - Origin).Unit))
end

function NetNav:GetCFrame(Pos: Types.TrainPosType): CFrame
	local From = Networks:GetNode(Pos.From, Pos.Network)
	local To = Networks:GetNode(Pos.To, Pos.Network)
	local T = Pos.T
	if From == nil then
		local Position = To.Tangent * T + To.Position
		return self:CreateCFrame(Position, -To.Tangent, -To.ZRotation)
	end
	if To == nil then
		local Position = From.Tangent * T + From.Position
		return self:CreateCFrame(Position, From.Tangent, From.ZRotation)
	end
	if self:IsLine(From.Position, To.Position, From.Tangent, LineTolerance) and From and To then
		local Position = From.Position:Lerp(To.Position, T)
		local Direction = (To.Position - From.Position).Unit
		local A1 = (Direction:Dot(From.Tangent)) < 0 and -From.ZRotation or From.ZRotation
		local A2 = (Direction:Dot(To.Tangent)) < 0 and -To.ZRotation or To.ZRotation
		local Rotation = Math:AngleLerp(A1, A2, T)
		return self:CreateCFrame(Position, Direction, Rotation)
	end
	local Position, Tangent = Math:ArcLerp(From.Position, To.Position, From.Tangent, T, true)
	local Direction = (To.Position - From.Position).Unit
	local A1 = (Direction:Dot(From.Tangent)) < 0 and -From.ZRotation or From.ZRotation
	local A2 = (Direction:Dot(To.Tangent)) < 0 and -To.ZRotation or To.ZRotation
	local Rotation = Math:AngleLerp(A1, A2, T)
	return self:CreateCFrame(Position, Tangent, Rotation)
end

function NetNav:GetVecPos(Pos: Types.TrainPosType): Vector3
	local From = Networks:GetNode(Pos.From, Pos.Network)
	local To = Networks:GetNode(Pos.To, Pos.Network)
	if From == nil then
		return To.Tangent * Pos.T + To.Position
	end
	if To == nil then
		return From.Tangent * Pos.T + From.Position
	end
	if not self:IsLine(From.Position, To.Position, From.Tangent, LineTolerance) and From and To then
		return Math:ArcLerp(From.Position, To.Position, From.Tangent, Pos.T)
	end
	return From.Position:Lerp(To.Position, Pos.T)
end

function NetNav:PositionInRadiusBackwards(
	TrainPos: Types.TrainPosType,
	Position: Vector3,
	Radius: number,
	AlternateRadius: number,
	TrainId: number
)
	local Net = Networks:GetNetwork(TrainPos.Network)
	local Backwards = {
		[1] = TrainPos.To,
		[2] = TrainPos.From,
	}
	local Iteration = 1
	if Position then
		repeat
			if Iteration ~= 1 then
				Backwards[Iteration + 1] =
					self:GetNextNode(Backwards[Iteration - 1], Backwards[Iteration], TrainId, TrainPos.Network)
			end
			local StartNode = Backwards[Iteration + 1]
			local EndNode = Backwards[Iteration]
			if StartNode == nil then
				local P = Net[EndNode].Position
				local Direction = Net[EndNode].Tangent
				local Offset = Iteration == 1 and TrainPos.T or 0
				local Intersection =
					Math:SemiGradSphereIntersection(P + Direction * Offset, Direction, Position, Radius, false)
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
					Math:LineSphereIntersection(P, P + Direction.Unit * TrainPos.T, Position, Radius, true, false)
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
			if self:IsLine(Start, End, Tangent, 0.001) then
				Intersection = Math:LineSphereIntersection(Start, End, Position, Radius, true)
			else
				Intersection = Math:ArcSphereIntersection(Start, End, Tangent, Position, Radius)
			end
			if Intersection then
				return NetPosition.new(StartNode, EndNode, Intersection, TrainPos.Network)
			end

			Iteration += 1
		until Iteration > 10
	end
	local AlternatePosition = self:GetVecPos(TrainPos)
	Radius = AlternateRadius
	Iteration = 1
	repeat
		if Iteration ~= 1 and Position == nil then
			Backwards[Iteration + 1] =
				self:GetNextNode(Backwards[Iteration - 1], Backwards[Iteration], TrainId, TrainPos.Network)
		end
		local StartNode = Backwards[Iteration + 1]
		local EndNode = Backwards[Iteration]
		if StartNode == nil then
			local P = Net[EndNode].Position
			local Direction = Net[EndNode].Tangent
			local Offset = Iteration == 1 and TrainPos.T or 0
			local Intersection =
				Math:SemiGradSphereIntersection(P + Direction * Offset, Direction, AlternatePosition, Radius, false)
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
				Math:LineSphereIntersection(P, P + Direction * TrainPos.T, AlternatePosition, Radius, true, false)
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
		if self:IsLine(Start, End, Tangent, 0.001) then
			Intersection = Math:LineSphereIntersection(Start, End, AlternatePosition, Radius, true)
		else
			Intersection = Math:ArcSphereIntersection(Start, End, Tangent, AlternatePosition, Radius)
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

return NetNav

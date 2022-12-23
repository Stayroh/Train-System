local Networks = require(script.Parent.Networks)
local TrainSwitch = require(script.Parent.Switch)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local Math = require(game.ReplicatedStorage.source.Math)

local NetNav = {}

function SearchTroughConnection(Connection: number | table | nil, Value: number)
	if Connection == Value then
		return true
	end
	if type(Connection) == "table" then
		if table.find(Connection, Value) then
			return true
		end
	end
	return false
end

function IsLine(Start: Vector3, End: Vector3, Tangent: Vector3, Tolerance: number): boolean
	local Deviation = math.abs(Tangent:Dot((End - Start).Unit))
	return Deviation >= 1 - Tolerance
end

function NetNav.GetNextNode(From: number, To: number, TrainId: number, Network: number): number?
	local Net = Networks.GetNetwork(Network)
	if not Net then
		return
	end
	local ToNode = Net[To]
	local Direction: number? = nil
	local NextNode: number | table | nil = nil
	if SearchTroughConnection(ToNode.Fol, From) then
		Direction = false
		NextNode = ToNode.Pre
	else
		Direction = true
		NextNode = ToNode.Fol
	end
	print(Direction, NextNode)
	if type(NextNode) ~= "table" then
		return NextNode
	end
	local SwitchReturn = TrainSwitch.GetNextNode(To, Direction, TrainId, Network)
	return SwitchReturn and SwitchReturn or NextNode[1]
end

function NetNav.GetVecPos(Pos: Types.TrainPosType): Vector3
	local From = Networks.GetNode(Pos.From, Pos.Network)
	local To = Networks.GetNode(Pos.To, Pos.Network)
	return Math.ArcLerp(From.Position, To.Position, From.Tangent, Pos.T)
end

function NetNav.PositionInRadiusBackwards(
	TrainPos: Types.TrainPosType,
	Position: Vector3,
	Radius: number,
	AlternateRadius: number,
	TrainId: number
)
	local Net = Networks.GetNetwork(TrainPos.Network)
	local Backwards = setmetatable({
		[1] = TrainPos.To,
		[2] = TrainPos.From,
	}, {
		__index = function(T, Index)
			T[Index] = NetNav.GetNextNode(T[Index - 2], T[Index - 1], TrainId, TrainPos.Network)
		end,
	})

	local Iteration = 1
	repeat
		local StartNode = Backwards[Iteration + 1]
		local EndNode = Backwards[Iteration]
		if (Net[StartNode].Position - Position).Magnitude < Radius then
			continue
		end
		local Start = Net[StartNode].Position
		local End = Net[EndNode].Position
		local Tangent = Net[StartNode].Tangent
		local Intersection = Math.ArcSphereIntersection(Start, End, Tangent, Position, Radius)
		Iteration += 1
	until Iteration > 10
end

return table.freeze(NetNav)

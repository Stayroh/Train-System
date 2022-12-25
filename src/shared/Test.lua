local Module = {}
local Math = require(game.ReplicatedStorage.source.Math)
local Networks = require(game.ReplicatedStorage.source.TrainCtrl.Networks)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)

function Module.Alpha(From: number, To: number, T: number, Rotation: Vector3)
	local Points = workspace.Nodes:GetChildren()
	local SampleDisc = workspace.Disc
	local Circles = workspace.Circles
	local Sphere = workspace.Sphere
	local Result = workspace.Result
	Circles:ClearAllChildren()
	local Net: Types.NetworkType = {}
	for i, v in pairs(Points) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.UpVector = Vector3.new(0, 1, 0)
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			print(Net[i - 1].Position, Node.Position)
			Node.Tangent = Math.GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
		end
		Net[i] = Node
	end
	Net[1].Tangent = -Net[1].Tangent
	for i, v in pairs(Net) do
		if i == 1 then
			continue
		end
		local Pos: Vector3 = v.Position
		local LPos: Vector3 = Net[i - 1].Position
		local LTan = Net[i - 1].Tangent
		if NetNav.IsLine(LPos, Pos, LTan, 0.01) then
			continue
		end
		local Position, Radius = Math.SphereFromArc(LPos, Pos, LTan)
		local Up = (LPos - Position):Cross(Pos - Position).Unit
		local CF = (CFrame.lookAt(Vector3.zero, Up) * CFrame.fromEulerAnglesXYZ(Rotation.X, Rotation.Y, Rotation.Z))
			+ Position
		local Size = Vector3.new(0.001, Radius * 2, Radius * 2)
		local Copy: Part = SampleDisc:Clone()
		Copy.Size = Size
		Copy.CFrame = CF
		Copy.Parent = Circles
	end
	local Radius = Sphere.Size.X / 2
	local NetworkId = Networks.Add(Net)
	local Pos: Types.TrainPosType = {}
	Pos.From = From
	Pos.Network = NetworkId
	Pos.T = T
	Pos.To = To
	local Intersection = NetNav.PositionInRadiusBackwards(Pos, Sphere.Position, Radius, Radius, 1)
	print(Intersection)
	Result.Position = NetNav.GetVecPos(Intersection)
	Networks.Remove(NetworkId)
end

return Module

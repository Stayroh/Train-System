local Module = {}
local Math = require(game.ReplicatedStorage.source.Math)
local Networks = require(game.ReplicatedStorage.source.TrainCtrl.Networks)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local NetPosition = require(game.ReplicatedStorage.source.TrainCtrl.NetPosition)
local TrainClass = require(game.ReplicatedStorage.source.TrainCtrl.TrainClass)

function Module.Alpha(From: number, To: number, T: number, Description: Types.TrainDescription)
	local Points = workspace.Nodes:GetChildren()
	function search(name)
		for _, v in pairs(Points) do
			if v.Name == name then
				return v
			end
		end
	end
	local Po = {}
	local index = 1
	while search(tostring(index)) do
		Po[index] = search(tostring(index))
		index += 1
	end
	local SampleDisc = workspace.Disc
	local Circles = workspace.Circles
	Circles:ClearAllChildren()
	local Net: Types.NetworkType = {}
	for i, v in pairs(Po) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.ZRotation = 0
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			Node.Tangent = Math:GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
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
		if NetNav:IsLine(LPos, Pos, LTan, 0.001) then
			continue
		end
		local Position, Radius = Math:SphereFromArc(LPos, Pos, LTan)
		local Up = (LPos - Position):Cross(Pos - Position).Unit
		local CF = (CFrame.lookAt(Vector3.zero, Up) * CFrame.fromEulerAnglesXYZ(0, math.pi / 2, 0)) + Position
		local Size = Vector3.new(0.001, Radius * 2, Radius * 2)
		local Copy: Part = SampleDisc:Clone()
		Copy.Size = Size
		Copy.CFrame = CF
		Copy.Parent = Circles
	end
	local NetworkId = Networks:Add(Net)
	local Pos = NetPosition.new(From, To, T, NetworkId)
	local Train = TrainClass.fromDescription(Description, Pos)
	Networks:Remove(NetworkId)
end

return Module

local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Module = {}
local Math = require(TrainSystem.Math)
local Networks = require(TrainSystem.Networks)
local NetNav = require(TrainSystem.NetNav)
local Types = require(TrainSystem.Types)
local NetPosition = require(TrainSystem.NetPosition)
local TrainClass = require(TrainSystem.TrainClass)
local RunService = game:GetService("RunService")

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
	for i, v: BasePart in pairs(Po) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.ZRotation = math.rad(v:GetAttribute("ZRotation"))
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			Node.Tangent = Math:GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
		end
		Net[i] = Node
	end
	Net[1].Tangent = -Net[1].Tangent
	for i, v in pairs(Net) do
		if i <= 2 then
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
	TrainClass.fromDescription(Description, Pos)
	Networks:Remove(NetworkId)
end

function Module.Beta(From: number, To: number, Duration: number, Reversed: boolean, Description: Types.TrainDescription)
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
	for i, v: BasePart in pairs(Po) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.ZRotation = math.rad(v:GetAttribute("ZRotation"))
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			Node.Tangent = Math:GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
		end
		Net[i] = Node
	end
	Net[1].Tangent = -Net[1].Tangent
	for i, v in pairs(Net) do
		if i <= 2 then
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
	local Time = 0
	local Connection = nil
	local Pos = NetPosition.new(From, To, Reversed and 1 or 0, NetworkId)
	local Train = TrainClass.fromDescription(Description, Pos)
	Connection = RunService.Stepped:Connect(function(_, deltaTime)
		local TValue = Time / Duration
		Pos = NetPosition.new(From, To, Reversed and 1 - TValue or TValue, NetworkId)
		Train:Update(Pos)
		if Time >= Duration then
			Networks:Remove(NetworkId)
			Connection:Disconnect()
		end
		Time = math.min(Duration, Time + deltaTime)
	end)
end

function Module.Gamma(From: number, To: number, T: number, Description: Types.TrainDescription)
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
	for i, v: BasePart in pairs(Po) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.ZRotation = math.rad(v:GetAttribute("ZRotation"))
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			Node.Tangent = Math:GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
		end
		Net[i] = Node
	end
	Net[1].Tangent = -Net[1].Tangent
	for i, v in pairs(Net) do
		if i <= 2 then
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
	game:GetService("RunService").Heartbeat:Connect(function()
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
		Train:Update(Pos)
	end)
end

function Module.Delta()
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
	for i, v: BasePart in pairs(Po) do
		local Node = {}
		if i == 1 then
			local Tan: Vector3 = (Points[2].Position - v.Position).Unit
			Node.Tangent = Tan
		end
		Node.Position = v.Position
		Node.ZRotation = math.rad(v:GetAttribute("ZRotation"))
		if Net[i - 1] ~= nil then
			Node.Pre = i - 1
			Net[i - 1].Fol = i

			Node.Tangent = Math:GetNextTangent(Net[i - 1].Position, Node.Position, Net[i - 1].Tangent)
		end
		Net[i] = Node
	end
	Net[1].Tangent = -Net[1].Tangent
	for i, v in pairs(Net) do
		if i <= 2 then
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
	end
	return Networks:Add(Net)
end

return Module

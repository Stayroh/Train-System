local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local LocalizationService = game:GetService("LocalizationService")
local Networks = require(TrainSystem.Networks)
local Types = require(TrainSystem.Types)
type self = {}
local Navigation = {}
Navigation.__index = Navigation

export type Navigation = typeof(setmetatable({} :: self, Navigation))

function Navigation:ComputeShortestPath(Start: Types.TrainPosType, Target: Types.TrainPosType)
	if Start.Network ~= Target.Network then
		warn("Tried to find path between points in different networks.")
		return
	end
	--ToDo
	local Network = Networks:GetNetwork(Start.Network)
	local Stack = {}
	if Start.To then
		Stack[#Stack + 1] = { Start.To }
	end
	if Start.From then
		Stack[#Stack + 1] = { Start.From }
	end
	local Index = 1
	local Goal
	local function CheckTarget(Node): boolean
		if Node == nil then
			return false
		end
		return Target.From == Node or Target.To == Node
	end
	local function SearchStack(Node: number): number
		for i, v in next, Stack do
			if v[1] == Node then
				return i
			end
		end
	end
	if CheckTarget(Start.From) then
		if CheckTarget(Start.To) then
			return Target.T >= Start.T and { Start.From, Start.To } or { Start.To, Start.From}
		end
		Goal = { Start.From }
	elseif CheckTarget(Start.To) then
		Goal = { Start.To }
	end
	if not Goal then
		while true do
			if not Stack[Index] then
				break
			end
			local Node = Network[Stack[Index][1]]
			local Neighbors = {}
			if type(Node.Pre) == "table" then
				for i, v in next, Node.Pre do
					if not SearchStack(v) then
						Neighbors[#Neighbors + 1] = v
					end
				end
			else
				if not SearchStack(Node.Pre) then
					Neighbors[#Neighbors + 1] = Node.Pre
				end
			end
			if type(Node.Fol) == "table" then
				for i, v in next, Node.Fol do
					if not SearchStack(v) then
						Neighbors[#Neighbors + 1] = v
					end
				end
			else
				if not SearchStack(Node.Fol) then
					Neighbors[#Neighbors + 1] = Node.Fol
				end
			end
			for i, v in next, Neighbors do
				if CheckTarget(v) then
					Goal = { v, Index }
					break
				end
				Stack[#Stack + 1] = { v, Index }
			end
			if Goal then
				break
			end
			Index += 1
		end
	end
	if not Goal then
		return nil
	end
	local Path = {}
	while Goal do
		Path[#Path + 1] = Goal[1]
		Goal = Stack[Goal[2]]
	end
	if Path[#Path] == Start.From then
		Path[#Path + 1] = Start.To or "nil"
	else
		Path[#Path + 1] = Start.From or "nil"
	end
	local ReversedPath = {}
	local PathLength = #Path
	for i = 1, PathLength do
		ReversedPath[PathLength - i + 1] = Path[i]
	end
	if ReversedPath[#ReversedPath] == Target.From and Target.To then
		ReversedPath[#ReversedPath + 1] = Target.To
	elseif ReversedPath[#ReversedPath] == Target.To and Target.From then
		ReversedPath[#ReversedPath + 1] = Target.From
	elseif not (#ReversedPath == 2 and ReversedPath[1] == "nil") then
		ReversedPath[#ReversedPath + 1] = "nil"
	end
	return ReversedPath
end

local Constructors = {}

function Constructors.new(): Navigation
	local self = setmetatable({} :: self, Navigation)
	return self
end

return Constructors.new()

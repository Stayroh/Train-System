local Networks = require(game.ReplicatedStorage.source.TrainCtrl.Networks)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
type self = {}
local Navigation = {} :: self
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
	Stack[1] = { Start.From }
	Stack[2] = { Start.To }
	local Index = 1
	local Goal
	local function CheckTarget(Node): boolean
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
			Index += 1
		end
	end
	if not Goal then
		return nil
	end
end

local Constructors = {}

function Constructors.new(): Navigation
	local self = setmetatable({} :: self, Navigation)

	return self
end

return Constructors

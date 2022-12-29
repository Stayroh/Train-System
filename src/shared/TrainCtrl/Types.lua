local Types = {}

export type NodeType = {
	Position: Vector3,
	Tangent: Vector3,
	UpVector: Vector3,
	Pre: number | { [number]: number } | nil,
	Fol: number | { [number]: number } | nil,
} --Stores the information data about Position, Tangent, Upvector and connections of this node

export type NetworkType = { [number]: NodeType }

export type SwitchType = {
	Pre: {
		Visual: number,
		Individ: { [number]: number? },
	},
	Fol: {
		Visual: number,
		Individ: { [number]: number? },
	},
} --Gives information about the connections between nodes
--Visuel represents the visualy shown state / default value
--Individ is the individual direction for each Train passing that node for which this switch stands for

export type NetworkSwitches = { [number]: SwitchType } --Array of SwitchUpdates for this NetworkId where index stands for the node Id

export type SwitchUpdateType = { [number]: NetworkSwitches } --Dictonary for each NetworkId

export type WagonDecleration = {
	WagonSeries: string,
	WagonReference: Folder,
} --Stores reference to the model in workspace and wagon type for this wagon

export type TrainLineType = { [number]: WagonDecleration } --Array of wagons which form a train

export type TrainPosType = {
	From: number?,
	To: number?,
	T: number,
	Network: number,
} --Gives information about a trains position in percetual from, to manner and on which network it is

return Types

local Types = {}

export type NodeType = {
	Position: Vector3,
	Tangent: Vector3,
	ZRotation: number,
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

export type CarDescription = {
	Series: string,
	Reference: Folder,
	Reversed: boolean?,
} --Stores reference to the model in workspace and wagon type for this wagon

export type TrainDescription = {
	Cars: { [number]: CarDescription },
	Bogies: { [number]: Model },
	Id: number,
}

export type TrainPosType = {
	From: number?,
	To: number?,
	T: number,
	Network: number,
} --Gives information about a trains position in percetual "from, to" manner and on which network it is on
export type CarsDataType = {
	Front: Vector3,
	Rear: Vector3,
	frontBogie: string,
	rearBogie: string,
	frontReversed: boolean?,
	rearReversed: boolean?,
}

export type CarsDataListType = { [string]: CarsDataType }

export type BogiesDataType = {
	frontPivot: Vector3,
	rearPivot: Vector3?,
}

export type BogiesDataListType = { [string]: BogiesDataType }

export type SnapshotType = {
	Position: TrainPosType,
	Velocity: number,
	Acceleraction: number,
	PassedNodes: { [number]: number },
	TP: boolean,
}

return Types

local Types = {}

export type KnotType = {
	position: Vector3,
	tangent: Vector3,
	targetSpeed: number,
	successor: number | { [number]: number } | nil,
	predecessor: number | { [number]: number } | nil,
} --Stores the information data about Position, Tangent, Upvector and connections of this node

export type RouteNetworkType = { [number]: KnotType } --Array of Knots for this NetworkId where index stands for the node Id

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
	Stiffness: number,
	Damping: number,
	SpringOffset: number,
	WheelCircumference: number,
}

export type BogiesDataListType = { [string]: BogiesDataType }

export type SnapshotType = {
	Position: TrainPosType,
	Velocity: number,
	Acceleration: number,
	TP: boolean,
}

return Types

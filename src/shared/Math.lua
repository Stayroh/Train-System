local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angel: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angel) + GC:Cross(V1) * math.sin(Angel)
end

return Math

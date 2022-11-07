local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angel: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angel) + GC:Cross(V1) * math.sin(Angel)
end

function Math.ArcLatitudeIntersection(V1: Vector3, V2: Vector3, Height: number): number
	local GC = V1:Cross(V2).Unit
	local a = V1.Z
	local b = V1.Y * GC.X - V1.X * GC.Y
	local c = Height
	return math.atan(b / a) - math.acos(c / math.sqrt(a ^ 2 + b ^ 2))
end

return Math

local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.ArcLatitudeIntersection(V1: Vector3, V2: Vector3, Height: number): number
	local GC = V1:Cross(V2).Unit
	local a = V1.Z
	local b = V1.X * GC.Y - V1.Y * GC.X
	local c = Height
	local atan = math.atan(b / a)
	local acos = math.acos(c / math.sqrt(a ^ 2 + b ^ 2))
	local Alpha = atan - acos
	print(a, b, atan, acos, Alpha)
	return Alpha
end

return Math

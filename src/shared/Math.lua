local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.GetQuardant(Angle: number): number
	return math.ceil((Angle % (math.pi * 2)) / (math.pi / 2)) + 1
end

function Math.ArcLatitudeIntersection(V1: Vector3, V2: Vector3, Height: number): number?
	local GC = V1:Cross(V2).Unit
	local a = V1.Y
	local b = GC:Cross(V1).Unit.Y
	local c = Height
	local atan = math.atan2(b, a)
	local ToAcos = c / math.sqrt(a ^ 2 + b ^ 2)
	if ToAcos > 1 or ToAcos < -1 then
		return nil
	end
	local acos = math.acos(ToAcos)
	acos = (atan - acos) % (math.pi * 2) <= (atan + acos) % (math.pi * 2) and acos or -acos
	local Angle = atan - acos
	return Angle
end

function Math.GetTangent(RelativNext: Vector3, Tangent: Vector3): Vector3
	local d = -Tangent
	local Normal = RelativNext.Unit
	return d - 2 * d:Dot(Normal) * Normal
end

function Math.SphereSphereIntersection(
	Sphere1_Pos: Vector3,
	Sphere2_Pos: Vector3,
	Radius1: number,
	Radius2: number
): number
	local d = (Sphere1_Pos - Sphere2_Pos).Magnitude
	return (Radius1 ^ 2 - Radius2 ^ 2 + d ^ 2) / (2 * d)
end

function Math.SphereFromArc(Arc_P1: Vector3, Arc_P2: Vector3, Tangent_V1: Vector3)
	Arc_P2 -= Arc_P1
	local Tangent_V2 = Math.GetTangent(Arc_P2, Tangent_V1)
	local N_V1 = Tangent_V1:Cross(Arc_P2):Cross(Tangent_V1).Unit
	local N_V2 = Tangent_V2:Cross(-Arc_P2):Cross(Tangent_V2).Unit
	local Alpha = math.acos(N_V1:Dot(Arc_P2.Unit))
	local Beta = math.acos(N_V2:Dot(-Arc_P2.Unit))
	local Gamma = math.pi - (Alpha + Beta)
	local d = Arc_P2.Magnitude / math.sin(Gamma) * math.sin(Beta)
	return N_V1 * d + Arc_P1, d
end

function Math.ArcSphereIntersection(
	Arc_P1: Vector3,
	Arc_P2: Vector3,
	Tangent_V1: Vector3,
	Tangent_V2: Vector3,
	Sphere_Pos: Vector3,
	Radius: number
): number
send

return Math

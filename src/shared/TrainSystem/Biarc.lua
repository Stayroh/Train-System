local Biarc = {}

function Biarc:GetConnectionPoint(P1: Vector3, T1: Vector3, P2: Vector3, T2: Vector3): Vector3
    T1, T2 = T1.Unit, T2.Unit
    local DeltaT = T2 - T1
    local v = P2 - P1
    local a = DeltaT:Dot(DeltaT) - 4
    local b = 2*v:Dot(DeltaT)
    local c = v:Dot(v)
    local d = (-b + sqrt(b^2 - 4*a*c))/(2*a)
    local Q1 = T1 * d + P1
    local Q2 = T2 * d + P2
    local Pm = (Q2 + Q1) / 2
    return Pm
end

return Biarc
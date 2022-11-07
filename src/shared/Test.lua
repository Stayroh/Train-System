local Module = {}
local Math = require(game.ReplicatedStorage.source.Math)
function Module.Test(Height)
	local S = game.Workspace.Sphere
	local A = workspace.PointA
	local B = workspace.PointB
	local R = workspace.Result
	local Radius = S.Size.X / 2
	local V1 = (A.Position - S.Position).Unit
	local V2 = (B.Position - S.Position).Unit
	R.Position = (Math.RotateOverVector(V1, V2, Math.ArcLatitudeIntersection(V1, V2, Height)).Unit * Radius)
		+ S.Position
end
return Module

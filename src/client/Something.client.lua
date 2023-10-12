local NetPosition = require(game.ReplicatedStorage.src.TrainSystem.NetPosition)
local Path = require(game.ReplicatedStorage.src.TrainSystem.Navigation):ComputeShortestPath(
    NetPosition.new(1,2,0.5,1),
    NetPosition.new(1,2,0.3,1)
)

local function PrintTable(Table)
    print("{")
    for i,v in pairs(Table) do
        if type(v) == "table" then
            print(i .. " =")
            PrintTable(v)
        else
            print(i .. " = " .. v)
        end
    end
    print("}")
end

PrintTable(Path)
local module = {}

function module.a(player: Player, val1: number): boolean
    local a = val1 % 2 == 0
    return a
end

return module
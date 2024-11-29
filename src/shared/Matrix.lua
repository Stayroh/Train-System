local Matrix: MatrixClass = {} :: MatrixClass
Matrix.__index = Matrix

type MatrixClass = {
    __index: MatrixClass,
    new: (values: {{any}} | {Vector3} | {Vector2} | Vector3 | Vector2 | number) -> Matrix
}

export type Matrix = typeof(setmetatable(
    {} :: {
        values: {{any}},
        rows: number,
        columns: number
    },
    Matrix
))	


function Matrix.new(values: {{any}} | {Vector3} | {Vector2} | Vector3 | Vector2 | number): Matrix
    if type(values) == "number" then
        values = {{values}}
    elseif typeof(values) == "Vector3" then
        values = {{values.X, values.Y, values.Z}}
    elseif typeof(values) == "Vector2" then
        values = {{values.X, values.Y}}
    elseif type(values) ~= "table" then
        assert(nil, string.format("Invalid datatype for Matrix.new() got %s", typeof(values)))
    end
    local self = setmetatable({}, Matrix) :: Matrix
    self.rows = #values :: {any}
    for i,v in pairs values do  
    end
end

return Matrix
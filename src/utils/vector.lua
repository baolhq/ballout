local vector = {}

function vector.normalize(x, y)
    local length = math.sqrt(x * x + y * y)
    if length == 0 then
        return 0, 0
    end
    return x / length, y / length
end

function vector.reflect(vx, vy, nx, ny)
    -- Reflect vector (vx, vy) around normal (nx, ny)
    local dot = vx * nx + vy * ny
    return vx - 2 * dot * nx, vy - 2 * dot * ny
end

return vector

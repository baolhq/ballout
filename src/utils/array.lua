local array = {}

-- Get a slice of an array
function array.slice(arr, first, last, step)
    local res = {}

    for i = first, last or #arr, step do
        table.insert(res, arr[i])
    end

    return res
end

-- Check if array contains an element
function array.contains(arr, elem)
    for _, v in ipairs(arr) do
        if v == elem then return true end
    end
    return false
end

return array

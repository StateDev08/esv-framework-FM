ESV = ESV or {}
ESV.Functions = {}

function ESV.Functions.GetItemByName(name)
    return ESV.Items[name] or nil
end

function ESV.Functions.GetJobByName(name)
    return ESV.Jobs[name] or nil
end

function ESV.Functions.GetVehicleByModel(model)
    for _, v in ipairs(ESV.Vehicles) do
        if v.model == model then
            return v
        end
    end
    return nil
end

function ESV.Functions.FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return "$" .. formatted
end

function ESV.Functions.GeneratePhoneNumber()
    return string.format("%03d-%04d", math.random(100, 999), math.random(1000, 9999))
end

function ESV.Functions.GeneratePlate()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local plate = ""
    for i = 1, 3 do
        local idx = math.random(1, #chars)
        plate = plate .. chars:sub(idx, idx)
    end
    plate = plate .. " " .. string.format("%04d", math.random(1000, 9999))
    return plate
end

function ESV.Functions.GenerateAccountNumber()
    return string.format("DE%02d%04d%04d%04d",
        math.random(10, 99),
        math.random(1000, 9999),
        math.random(1000, 9999),
        math.random(1000, 9999)
    )
end

function ESV.Functions.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function ESV.Functions.TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

function ESV.Functions.DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in next, orig, nil do
            copy[ESV.Functions.DeepCopy(k)] = ESV.Functions.DeepCopy(v)
        end
        setmetatable(copy, ESV.Functions.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

return ESV.Functions

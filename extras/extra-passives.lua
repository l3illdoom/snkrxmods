ExtraPassive = Object:extend()
function ExtraPassive:init_passive(args)
    for k, v in pairs(args or {}) do self[k] = v end

    --[[
        Expects:
        key: name with underscores
        description: a function(lvl) that returns a description by level. 0 will be passed for the general description
    --]]

    local desc = {}
    for i = 0, 3 do
        desc[i] = self:description(i)
    end

    print('init_passive for ' .. self.key .. '. descriptions=' .. table.tostring(desc))

    EXTRA_PASSIVES[self.key] = self

    _G[self.key] = Image(self.key)
end

function ExtraPassive:desc(lvl, bonuses)
    local result = ''

    if lvl == 0 then
        result = '[yellow]'
        for i, v in ipairs(bonuses) do
            if i > 1 then
                result = result .. '/'
            end
            result = result .. v
        end
    else
        if lvl > 1 then
            result = result .. '[light_bg]'
        end
        for i, v in ipairs(bonuses) do
            if i > 1 then
                result = result .. '/'
            end
            if i == lvl then
                result = result .. '[yellow]' .. v .. '[light_bg]'
            else
                result = result .. v
            end
        end
    end

    return result .. '[fg]'
end

function ExtraPassive:find(passives)
    return table.any(passives, function(passive) return passive.passive == self.key end)
end
EXTRA_UNITS = { } -- map created during init_unit

MAX_CLASSES_PER_RUN = 11 -- set this to how many classes you want (ignoring explorer, that's always added).

CLASS_COLOR_STRINGS = {
    ['warrior'] = 'yellow',
    ['ranger'] = 'green',
    ['healer'] = 'green',
    ['conjurer'] = 'orange',
    ['mage'] = 'blue',
    ['nuker'] = 'red',
    ['rogue'] = 'red',
    ['enchanter'] = 'blue',
    ['psyker'] = 'fg',
    ['curser'] = 'purple',
    ['forcer'] = 'yellow',
    ['swarmer'] = 'orange',
    ['voider'] = 'purple',
    ['sorcerer'] = 'blue2',
    ['mercenary'] = 'yellow2',
    ['explorer'] = 'fg',
}

ALL_CLASSES = {
    'ranger',
    'warrior',
    'healer',
    'mage',
    'nuker',
    'conjurer',
    'rogue',
    'enchanter',
    'psyker',
    'curser',
    'forcer',
    'swarmer',
    'voider',
    'sorcerer',
    'mercenary'
}

ExtraUnit = Object:extend()
function ExtraUnit:init_unit(args)
    for k, v in pairs(args or {}) do self[k] = v end
    --[[
        expects the following:
        key: name of the unit, all lowercase, with underscores instead of spaces
        classes: a list of class names
        color: a color object
        color_string: a color in string form
        effect_name: the name of the lvl 3 ability
        tier: the unit's tier
        get_description: a function describing the unit
        get_effect_description: a function describing the lvl 3 ability
    --]]
    self.effect_name_gray = self.effect_name:gray()
    self.name = (self.key:gsub("_", " ")):titleCase()
    self.fires_projectiles = args.fires_projectiles or false
    self.attacks = args.attacks or false
    self.has_cooldown = args.has_cooldown or false
    EXTRA_UNITS[self.key] = self
end

function get_class_string(classes)
    result = ''
    for i, class in ipairs(classes) do
        if i ~= 1 then
            result = result .. ', '
        end
        result = result .. '[' .. CLASS_COLOR_STRINGS[class] .. ']' .. class:titleCase()
    end
    return (result:gsub('Conjurer', 'Builder'))
end

function ExtraUnit:get_class_string()
    return get_class_string(self.classes)
end

function ExtraUnit:get_effect_description_gray()
    desc = self.get_effect_description()
    return desc:gray()
end

function extraUnitsDraw(unit)
    for k, v in pairs(EXTRA_UNITS) do
        if (v.draw) then
            v:draw(unit)
        end
    end
end

function init_unit_pools(class_pool)
    if (class_pool) then
        run_class_pool = class_pool
    else
        local available_classes = table.shallow_copy(ALL_CLASSES)
        while #available_classes > MAX_CLASSES_PER_RUN do
            random:table_remove(available_classes)
        end
        table.insert(available_classes, 'explorer')
        run_class_pool = available_classes
    end

    local missing_classes = {}
    for _, v in ipairs(ALL_CLASSES) do
        if not table.contains(run_class_pool, v) then
            table.insert(missing_classes, v)
        end
    end

    missing_class_pool_strings = {
        get_class_string(table.select(missing_classes, function(_, index) return index % 2 == 1 end)),
        get_class_string(table.select(missing_classes, function(_, index) return index % 2 == 0 end)),
    }

    missing_class_pool_strings[1] = 'No: ' .. missing_class_pool_strings[1]

    print('classes this run: ' .. table.tostring(run_class_pool))
    print(missing_class_pool_string)

    run_tier_to_characters = {
        [1] = table.select(tier_to_characters[1], filterTierToClasses),
        [2] = table.select(tier_to_characters[2], filterTierToClasses),
        [3] = table.select(tier_to_characters[3], filterTierToClasses),
        [4] = table.select(tier_to_characters[4], filterTierToClasses)
    }

    print('tier 1 pool: ' .. #run_tier_to_characters[1])
    print('tier 2 pool: ' .. #run_tier_to_characters[2])
    print('tier 3 pool: ' .. #run_tier_to_characters[3])
    print('tier 4 pool: ' .. #run_tier_to_characters[4])

    run_passive_pool = removeClassPassives(run_passive_pool, missing_classes)
end

function filterTierToClasses(candidate)
    local classes = character_classes[candidate]
    for _, v in ipairs(classes) do
        if not table.contains(run_class_pool, v) then
            print('excluding ' .. candidate .. ' because of class ' .. v)
            return false
        end
    end
    return true
end

function removeClassPassives(passive_pool, missing_classes)
    for _, class in ipairs(missing_classes) do
        for _, passive in ipairs(passives_by_class[class]) do
            print('excluding ' .. passive .. ' due to ' .. class)
            table.delete(passive_pool, passive)
        end
    end
    print ('there are ' .. #passive_pool .. ' passives left in the pool')
    return passive_pool
    --return table.select(passive_pool, function(item)
    --    return not table.any(missing_classes, function(class)
    --        local contained = table.contains(passives_by_class[class], item)
    --        if (contained) then
    --            print (item .. ' removed due to ' .. class)
    --        end
    --        return contained
    --    end)
    --end)
end

require 'extras/MonumentBuilder'
-- init each new unit you want included
MonumentBuilder{}
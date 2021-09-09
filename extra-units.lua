MAX_CLASSES_PER_RUN = 12 -- set this to how many classes you want (ignoring explorer, that's always added).

EXTRA_UNITS = { } -- map created during init_unit
EXTRA_CLASSES = {} -- map created during init_class
EXTRA_PASSIVES = {} -- map created during init_passive

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
    'mercenary',
    'explorer'
}

UNITS_PER_CLASS_LEVEL = {
    ['ranger'] = {3, 6},
    ['warrior'] = {3, 6},
    ['healer'] = {2, 4},
    ['mage'] = {3, 6},
    ['nuker'] = {3, 6},
    ['conjurer'] = {2, 4},
    ['rogue'] = {3, 6},
    ['enchanter'] = {2, 4},
    ['psyker'] = {2, 4},
    ['curser'] = {2, 4},
    ['forcer'] = {2, 4},
    ['swarmer'] = {2, 4},
    ['voider'] = {2, 4},
    ['sorcerer'] = {2, 4, 6},
    ['mercenary'] = {2, 4},
    ['explorer'] = {1, 1}
}

ExtraClass = Object:extend()
function ExtraClass:init_class(args)
    for k, v in pairs(args or {}) do self[k] = v end
    --[[
        expects the following:
        key: name of the unit, all lowercase, with underscores instead of spaces
        color: a color object
        color_string: a color in string form
        levels: a table of how many units you need for each level
        stats: a table of the stat multipliers
        description: a function that given a lvl will display a formatted string
    --]]

    EXTRA_CLASSES[self.key] = self
    table.insert(ALL_CLASSES, self.key)
    UNITS_PER_CLASS_LEVEL[self.key] = self.levels
    CLASS_COLOR_STRINGS[self.key] = self.color_string
end

function ExtraClass:formatDescription(lvl, description)
    description = (description:gsub("lvl1", lvl == 1 and "yellow" or "light_bg"))
    description = (description:gsub("lvl2", lvl == 2 and "yellow" or "light_bg"))
    description = (description:gsub("lvl3", lvl == 3 and "yellow" or "light_bg"))
    return description
end

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
    self.name = (self.key:gsub("%_", " ")):titleCase()
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

function extraUnitsDraw2(unit)
    for k, v in pairs(EXTRA_UNITS) do
        if (v.draw2) then
            v:draw2(unit)
        end
    end
end

function init_unit_pools(class_pool)
    if (class_pool) then
        run_class_pool = class_pool
    else
        local available_classes = table.shallow_copy(ALL_CLASSES)
        table.delete(available_classes, 'explorer')
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

    if #missing_class_pool_strings[1] > 0 then
        missing_class_pool_strings[1] = 'No: ' .. missing_class_pool_strings[1]
    end

    print('classes this run: ' .. table.tostring(run_class_pool))
    print(table.tostring(missing_class_pool_strings))

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

    --display_class_stats()
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

function get_counts_by_class()
    local unit_count_by_class_count = {
    }

    for _, classes in pairs(character_classes) do
        for _, class in pairs(classes) do
            if not unit_count_by_class_count[class] then
                unit_count_by_class_count[class] = {}
            end
            local counts = unit_count_by_class_count[class]
            counts[#classes] = (counts[#classes] or 1) + 1
        end
    end
end

function display_class_stats()
    print(table.tostring(get_counts_by_class()))
end

function extraUnitsShoot(unit, crit, dmg_m, r, mods)
    local extra_unit = EXTRA_UNITS[unit.character]
    if (extra_unit and extra_unit[shoot]) then
        extra_unit:shoot(unit, crit, dmg_m, r, mods)
        return true
    end
    return false
end

function extraUnitsUpdate(unit, dt)
    for _, class in pairs(EXTRA_CLASSES) do
        if class.update then
            class:update(unit, dt)
        end
    end
    for _, extraUnit in pairs(EXTRA_UNITS) do
        if (extraUnit.update) then
            extraUnit:update(unit, dt)
        end
    end
end

function extraUnitsOnArenaEnter(level, loop, units, passives, shop_level, shop_xp, lock)
    local args = {
        level = level,
        units = units,
        loop = loop,
        passives = passives,
        shop_level = shop_level,
        shop_xp = shop_xp,
        lock = lock
    }
    for _, passive in pairs(EXTRA_PASSIVES) do
        if passive.onArenaEnter then
            passive:onArenaEnter(args)
        end
    end

    for _, class in pairs(EXTRA_CLASSES) do
        if class.onArenaEnter then
            class:onArenaEnter(args)
        end
    end

    for _, unit in pairs(EXTRA_UNITS) do
        if unit.onArenaEnter then
            unit:onArenaEnter(args)
        end
    end
end

function getFreshPassivePool()
    local entirePool = { -- default game passives
        'centipede', 'ouroboros_technique_r', 'ouroboros_technique_l', 'amplify', 'resonance', 'ballista', 'call_of_the_void', 'crucio', 'speed_3', 'damage_4', 'shoot_5', 'death_6', 'lasting_7',
        'defensive_stance', 'offensive_stance', 'kinetic_bomb', 'porcupine_technique', 'last_stand', 'seeping', 'deceleration', 'annihilation', 'malediction', 'hextouch', 'whispers_of_doom',
        'tremor', 'heavy_impact', 'fracture', 'meat_shield', 'hive', 'baneling_burst', 'blunt_arrow', 'explosive_arrow', 'divine_machine_arrow', 'chronomancy', 'awakening', 'divine_punishment',
        'assassination', 'flying_daggers', 'ultimatum', 'magnify', 'echo_barrage', 'unleash', 'reinforce', 'payback', 'enchanted', 'freezing_field', 'burning_field', 'gravity_field', 'magnetism',
        'insurance', 'dividends', 'berserking', 'unwavering_stance', 'unrelenting_stance', 'blessing', 'haste', 'divine_barrage', 'orbitism', 'psyker_orbs', 'psychosink', 'rearm', 'taunt', 'construct_instability',
        'intimidation', 'vulnerability', 'temporal_chains', 'ceremonial_dagger', 'homing_barrage', 'critical_strike', 'noxious_strike', 'infesting_strike', 'burning_strike', 'lucky_strike', 'healing_strike', 'stunning_strike',
        'silencing_strike', 'culling_strike', 'lightning_strike', 'psycholeak', 'divine_blessing', 'hardening', 'kinetic_strike',
    }

    for k, _ in pairs(EXTRA_PASSIVES) do
        table.push(entirePool, k)
    end

    return entirePool
end

-- require each unit you want included
require 'extras/MonumentBuilder'
require 'extras/Vampire'

require 'extras/laser/DotLaser'
require 'extras/laser/Sniper'
require 'extras/laser/RimeSeer'
require 'extras/laser/PsykerLaser'
require 'extras/laser/ForcerLaser'
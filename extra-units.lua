EXTRA_UNITS = { } -- map created during init_unit

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

function ExtraUnit:get_class_string()
    result = ''
    for i, class in ipairs(self.classes) do
        if i ~= 1 then
            result = result .. ', '
        end
        result = result .. '[' .. CLASS_COLOR_STRINGS[class] .. ']' .. class:titleCase()
    end
    return (result:gsub('Conjurer', 'Builder'))
end

function ExtraUnit:get_effect_description_gray()
    desc = self.get_effect_description()
    return desc:gray()
end

require 'extras/MonumentBuilder'
-- init each new unit you want included
MonumentBuilder{}
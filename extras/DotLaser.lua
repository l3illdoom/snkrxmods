require('extras/Laser')

DotLaser =  Laser:extend()

function DotLaser:init()
    self:init_unit({
        key = 'dot_laser',
        classes = {'voider', 'laser'},
        color = function() return purple[0] end,
        color_string = 'purple',
        effect_name = '[purple]Prism',
        tier = 1,
        has_cooldown = true,
        attacks = true,
        max_targets = function(player) return player.level == 3 and 4 or 2 end,
        max_targets_add = function(player) return player.level == 3 and 2 or 1 end,
        laser_acquire_range = 150,
        laser_acquire_frequency = 3,
        max_laser_range = 200,
        laser_color = function() return purple_transparent end
    })
end

function DotLaser:get_description(lvl)
    return '[fg]Fires up to two lasers that deals [yellow]' .. get_character_stat('dot_laser', lvl, 'dmg') ..'[fg] damage over time'
end

function DotLaser:get_effect_description()
    return '[fg]Acquires 2 targets at once and up to 4 total'
end

function DotLaser:target_acquired(unit, target)
    print('acquired a target')
    target:apply_dot(
            unit.dmg * (unit.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1),
            10000,
            purple_transparent,
            'dot_laser'
    )
end

function DotLaser:lost_target(unit, target)
    print('lost a target')
    if (target and target.cancel_dot) then
        target:cancel_dot('dot_laser')
    end
end
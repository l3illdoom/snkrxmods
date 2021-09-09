require('extras/laser/Laser')

DotLaser =  Laser:extend()

function DotLaser:init()
    self:init_unit({
        key = 'plasma_accelerator',
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
        max_laser_lock = 0,
        laser_requires_los = true,
        max_laser_range = 200,
        laser_color = function() return purple_transparent end
    })
end

function DotLaser:get_description(lvl)
    return '[fg]Fires lasers that deal increasing damage, starting at [yellow]' ..
            get_character_stat('plasma_accelerator', lvl, 'dmg') ..
            '[fg] damage per second'
end

function DotLaser:get_effect_description()
    return '[fg]Acquires 2 targets at once and up to 4 total'
end

function DotLaser:selectTarget(unit, enemiesInRange)
    return self:selectClosestTarget(unit, enemiesInRange)
end

function DotLaser:target_acquired(unit, target)
    local stage = 1
    local tag = 'add_dot_' .. target.id
    unit.t:every_immediate(1.05, function()
        if not target or not target.apply_dot or target.dead then
            unit.t:cancel(tag)
        end
        local dmg = LASER_CLASS.laser_damage:getStat(stage * unit.dmg)
                * (unit.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1)
        target:apply_dot(
                dmg,
                10000,
                purple_transparent,
                'dot_laser'
        )
        stage = stage + 1
    end, nil, nil, tag)
end

function DotLaser:lost_target(unit, target)
    if (target and target.remove_dot) then
        target:remove_dot('dot_laser')
    end
    if (target and target.id) then
        unit.t:cancel('add_dot_' .. target.id)
    end
end

DotLaser{}
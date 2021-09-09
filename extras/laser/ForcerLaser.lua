require('extras/laser/Laser')

ForcerLaser = Laser:extend()
ForcerLaser.key = 'telekinetic'

function ForcerLaser:init()
    self:init_unit({
        key = ForcerLaser.key,
        classes = {'forcer', 'laser'},
        color = function() return yellow[0] end,
        color_string = 'yellow',
        effect_name = '[yellow]Psy Rockin',
        tier = 3,
        has_cooldown = true,
        attacks = true,
        max_targets = function(player) return player.level == 3 and 6 or 4 end,
        max_targets_add = function(player) return player.level == 3 and 4 or 2 end,
        laser_acquire_range = 115,
        max_laser_range = 130,
        laser_acquire_frequency = function(player) return player.level == 3 and 1 or 2 end,
        max_laser_lock = 3,
        laser_color = function() return yellow_transparent_weak  end
    })
end


function ForcerLaser:get_description(lvl)
    return '[fg]Fires 2 lasers that push enemies away and deal [yellow]' ..
            get_character_stat(ForcerLaser.key, lvl, 'dmg') ..
            '[fg] damage per second'
end

function ForcerLaser:get_effect_description()
    return '[fg]Lasers galore'
end

function ForcerLaser:selectTarget(unit, enemiesInRange)
    return self:selectClosestTarget(unit, enemiesInRange)
end

function ForcerLaser:target_acquired(unit, target)
    local interval = 0.25
    unit.t:every_immediate(interval, function()
        local dmg = interval * unit.dmg * (unit.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1)
        target:hit(dmg, nil, nil, false)
        target:push(interval * 40 * (unit.knockback_m or 1), target:angle_to_object(unit) + math.pi)
    end, nil, nil, self:getTagFor(target))
end

function ForcerLaser:getTagFor(target)
    return 'push_' .. target.id
end

function ForcerLaser:lost_target(unit, target)
    if (target and target.id) then
        unit.t:cancel(self:getTagFor(target))
    end
end

ForcerLaser{}
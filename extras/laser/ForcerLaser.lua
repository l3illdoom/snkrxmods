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
        laser_acquire_range = 95,
        max_laser_range = 115,
        laser_acquire_frequency = function(player) return player.level == 3 and 1 or 2 end,
        max_laser_lock = 3,
        laser_color = function() return yellow_transparent end
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
        local dmg = LASER_CLASS.laser_damage:getStat(interval * unit.dmg)
                * (unit.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1)
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

function ForcerLaser:draw_laser(unit, target, laser_time)
    local angle = unit:angle_to_object(target) - math.pi / 2 -- no clue why I have to offset this angle
    graphics.push(unit.x, unit.y, angle)
    local distance = math.distance(target.x, target.y, unit.x, unit.y)
    local period = 25
    local frequency = 0.2
    local offset = (laser_time % frequency) / frequency * period
    local dots = (distance - offset) / period + 1

    for i=0, dots - 1 do
        local w = 3 + (i % 4) * .5
        local y = unit.y + i * period + offset
        graphics.push(unit.x, y, math.pi / 2) -- adjust for the triangle pointing to the right
        graphics.triangle(
                unit.x,
                y,
                w,
                w * 1.6,
                unit.laser_color
        )
        graphics.pop()
    end
    graphics.pop()
end

ForcerLaser{}
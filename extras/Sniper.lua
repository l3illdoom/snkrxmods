require 'extras/Laser'

Sniper = Laser:extend()

function Sniper:init()
    self:init_unit({
        key = 'sniper',
        classes = {'ranger', 'rogue', 'laser'},
        color = function() return green[0] end,
        color_string = 'green',
        effect_name = '[red]BOOM[fg] Headshot!',
        tier = 3,
        has_cooldown = true,
        attacks = true,
        launches_projectiles = true,
        max_targets = 1,
        laser_acquire_range = 200,
        laser_acquire_frequency = 2,
        max_laser_range = 275,
        max_laser_lock = 0, -- he doesn't lose aim due to timeout
        laser_color = function() return red_transparent_weak end
    })
end

function Sniper:get_description(lvl)
    return '[fg]Fires piercing arrows that deal [yellow]' ..
            2 * get_character_stat('sniper', lvl, 'dmg') ..
            '[fg] damage after aiming'
end

function Sniper:get_effect_description()
   return '[fg]Aims faster and prioritizes elites and special enemies'
end


function Sniper:target_acquired(unit, target)
    unit.t:every(unit.level == 3 and 3 or 5, function()
        unit:shoot(unit:angle_to_object(target), {
            pierce = 1000,
            is_an_arrow = true,
            dmg_m = 2,
            v = 340
        })
    end, nil, nil, 'shoot_' .. target.id)
end

function Sniper:lost_target(unit, target)
    unit.t:cancel('shoot_' .. target.id)
end

function Sniper:selectTarget(unit, enemiesInRange)
    if (unit.level == 3) then
        local priorities = table.select(enemiesInRange, function(enemy)
            return enemy.boss or enemy.speed_booster or enemy.exploder or
                    enemy.headbutter or enemy.tank or enemy.shooter or
                    enemy.spawner
        end)
        if #priorities > 0 then
            local selected = table.random(priorities)
            table.delete(enemiesInRange, selected)
            return selected
        end
    end

    return self.super:selectTarget(unit, enemiesInRange)
end

Sniper{}
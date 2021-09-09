require 'extras/laser/Laser'

RimeSeer = Laser:extend()

function RimeSeer:init()
    self:init_unit({
        key = 'rime_seer',
        classes = {'mage', 'laser'},
        color = function() return blue2[0] end,
        color_string = 'blue2',
        effect_name = '[blue2]Icy Mist',
        tier = 2,
        has_cooldown = true,
        attacks = true,
        launches_projectiles = false,
        max_targets = 1,
        laser_acquire_range = 110,
        laser_acquire_frequency = 3.5,
        max_laser_range = 150,
        laser_color = function() return blue2_transparent_weak end
    })
end

function RimeSeer:get_description(lvl)
    return '[fg]Fires a beam that deals [yellow]' ..
            get_character_stat('rime_seer', lvl, 'dmg') ..
            '[fg] damage per second and slows for [yellow]50%'
end

function RimeSeer:get_effect_description()
    return '[fg]Slows all enemies around its targets by [yellow]60%'
end


function RimeSeer:target_acquired(unit, target)
    target:apply_dot(
        unit.dmg * (unit.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1),
        10000,
        blue2_transparent_weak,
        'rime_seer'
    )
    if unit.level == 3 then
        unit.t:every_immediate(0.75, function()
            local shape = Circle(target.x, target.y, unit.area_size_m*18)
            local enemies = main.current.main:get_objects_in_shape(shape, main.current.enemies)
            HitCircle{group = main.current.effects, x = target.x, y = target.y, rs = shape.rs,
                      color = blue2_transparent_weak, duration = 0.1}

            if #enemies > 0 then
                frost1:play{pitch = random:float(0.8, 1.2), volume = 0.4}
            end
            for _, enemy in ipairs(enemies) do
                enemy:slow(0.6, 1)
                for i = 1, 2 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = blue2_transparent_weak} end
            end
        end, nil, nil, 'freeze_' .. target.id)
    else
        target.slowed = 0.5
    end
end

function RimeSeer:lost_target(unit, target)
    if unit.level == 3 then
        unit.t:cancel('freeze_' .. target.id)
    else
        if (target) then
            target.slowed = false
        end
    end
    if (target and target.cancel_dot) then
        target:remove_dot('rime_seer')
    end
end

RimeSeer{}
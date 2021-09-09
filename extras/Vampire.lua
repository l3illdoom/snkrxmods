Vampire = Object:extend()
Vampire:implement(ExtraUnit)
function Vampire:init(args)
    self:init_unit({
        key = 'vampire',
        classes = {'rogue', 'healer', 'enchanter'},
        color = function() return red[0] end,
        color_string = 'red',
        effect_name = '[red]Soul Suck',
        tier = 2,
        has_cooldown = true,
        fires_projectiles = true,
        attacks = true
    })
end

function Vampire:get_description(lvl)
    return '[fg]throws a short-range knife that deals [yellow]' .. 2*get_character_stat('vampire', lvl, 'dmg') .. '[fg] damage and creates a healing orb on hit'
end

function Vampire:get_effect_description()
    return '[fg]if the knife crits your team deals [yellow]20%[fg] more damage until end of combat'
end

function Vampire:init_player(player)
    player.attack_sensor = Circle(player.x, player.y, 45)
    player.t:cooldown(3, function() local enemies = player:get_objects_in_shape(player.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
        local closest_enemy = player:get_closest_object_in_shape(player.attack_sensor, main.current.enemies)
        if closest_enemy then
            player:shoot(player:angle_to_object(closest_enemy), {heals_on_hit = true, vampire_buff_on_crit = player.level == 3})
        end
    end, nil, nil, 'shoot')
end

function Vampire:shoot(unit, crit, dmg_m, r, mods)
    dmg_m = dmg_m*2

    HitCircle{group = main.current.effects, x = unit.x + 0.8*unit.shape.w*math.cos(r), y = unit.y + 0.8*unit.shape.w*math.sin(r), rs = 6}
    local t = {group = main.current.main, x = unit.x + 1.6*unit.shape.w*math.cos(r), y = unit.y + 1.6*unit.shape.w*math.sin(r), v = 250, r = r, color = unit.color, dmg = unit.dmg*dmg_m, crit = crit, character = unit.character,
               parent = unit, level = unit.level, vampire_buff_on_hit = crit and mods.vampire_buff_on_crit, is_a_knife = true}
    Projectile(table.merge(t, mods or {}))
    
    _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
end

function Vampire:projectile_init(projectile, args)
    projectile.heals_on_hit = args.heals_on_hit or false
    projectile.vampire_buff_on_hit = args.vampire_buff_on_hit or false
end

function Vampire:projectile_hit_enemy(projectile)
    if projectile.heals_on_hit then
        local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
        while #objects > 0 do
            check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
            objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
        end
        SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
            local check_circle = Circle(x, y, 2)
            local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
            if #objects == 0 then
                HealingOrb{group = main.current.main, x = x, y = y}
            end
        end}
    end

    if projectile.parent and projectile.vampire_buff_on_hit then
        local units = projectile.parent:get_all_units()
        for _, unit in ipairs(units) do
            unit.buffs.dmg:setMod('vampire', 0.2 + unit.buffs.dmg.mods['vampire'] or 1)
            unit.vampired = true
            unit.t:after(2, function() unit.vampired = false end)
        end
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.8}
    end
end

function Vampire:draw(unit)
    if (unit.vampired) then
        graphics.rectangle(unit.x, unit.y, 1.33*unit.shape.w, 1.33*unit.shape.h, 3, 3, red_transparent)
    end
end

Vampire{}
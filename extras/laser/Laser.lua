LaserClass = Object:extend()
LaserClass:implement(ExtraClass)

function LaserClass:init(args)
    self:init_class({
        key = 'laser',
        color = function() return white[0] end,
        color_string = 'fg',
        levels = {2, 4},
        stats = {
            hp = 1.1,
            dmg = 1.2,
            aspd = 1.1,
            area_dmg = 1,
            area_size = 1,
            def = 0.85,
            mvspd = 1.0
        },
    })
    laser = Image('laser')

    self.max_targets = BuffGroup{}
    self.max_targets_add = BuffGroup{}
    self.laser_acquire_range = BuffGroup{}
    self.max_laser_range = BuffGroup{}
    self.laser_acquire_frequency = BuffGroup{}
end

function LaserClass:description(lvl)
    return self:formatDescription(
        lvl,
        "[lvl1]2[light_bg]/[lvl2]4 [fg]- " ..
        "+[lvl1]1[light_bg]/[lvl2]2 [fg] max targets and " ..
        "+[lvl1]0[light_bg]/[lvl2]1 [fg] targets at once"
    )
end

Laser = Object:extend()
Laser:implement(ExtraUnit)

function Laser:init_player(player)
    local callOrDefault = function(fieldName, default)
        local field = self[fieldName]
        local preBuff
        if type(field) == "number" or type(field) == "table" then
            preBuff = field
        elseif field then
            preBuff = field(player)
        else
            preBuff = default
        end
        local buff = LASER_CLASS[fieldName]
        if buff then
            local postBuff = buff:getStat(preBuff)
            if preBuff ~= postBuff then
                print('buffed ' .. fieldName .. ' from ' .. preBuff .. ' to ' .. postBuff)
            end
            return postBuff
        else
            return preBuff
        end
    end

    player.laser_targets = {}
    player.max_targets = callOrDefault('max_targets', 1)
    player.max_targets_add = callOrDefault('max_targets_add', 1)
    player.laser_acquire_range = callOrDefault('laser_acquire_range', 140)
    player.max_laser_range = callOrDefault('max_laser_range', 200)
    player.laser_acquire_frequency = callOrDefault('laser_acquire_frequency', 4)
    player.laser_color = self.laser_color(player)
    player.max_laser_lock = callOrDefault('max_laser_lock', player.laser_acquire_frequency * 1.25)
    player.laser_requires_los = self.laser_requires_los or false

    player.attack_sensor = Circle(player.x, player.y, player.laser_acquire_range)
    local enemiesInRange = function()
        local enemies = player:get_objects_in_shape(player.attack_sensor, main.current.enemies)
        enemies = table.select(enemies, function(item) return not table.contains(player.laser_targets, item) end)
        return #enemies > 0 and enemies or nil
    end

    player.t:cooldown(
        player.laser_acquire_frequency,
        function() return #player.laser_targets < player.max_targets and enemiesInRange() end,
        function()
            local enemies = enemiesInRange()
            local add = math.min(player.max_targets - #player.laser_targets, #enemies, player.max_targets_add)
            for _ = 1, add do
                local acquired = self:selectTarget(player, enemies)
                self:target_acquired(player, acquired)
                table.insert(player.laser_targets, acquired)
                if (player.max_laser_lock > 0) then
                    player.t:after(player.max_laser_lock, function()
                        table.delete(player.laser_targets, acquired)
                        self:lost_target(player, acquired)
                    end, 'laser_lock_' .. acquired.id)
                end
            end
        end, nil, nil, 'shoot'
    )
    player.t:every(player.laser_requires_los and 0.15 or 0.25, function()
        for _, acquired in ipairs(player.laser_targets) do
            if player.dead or acquired.dead
                or math.distance(player.x, player.y, acquired.x, acquired.y) > player.max_laser_range
                or (player.laser_requires_los and self:laserLosBlocked(player, acquired))
            then
                table.delete(player.laser_targets, acquired)
                self:lost_target(player, acquired)
                player.t:cancel('laser_lock_'..acquired.id)
            end
        end
    end, nil, nil, 'laser_cancel')
end

function Laser:disableLaser(player)
    player.t:cancel('shoot')
    player.t:cancel('laser_cancel')
    for _, target in ipairs(player.laser_targets or {}) do
        self:lost_target(player, target)
    end
    player.laser_targets = nil
end

function Laser:laserLosBlocked(player, target)
    local line = Line(player.x, player.y, target.x, target.y)
    local colliding = main.current.main:get_objects_in_shape(line, {Seeker, EnemyCritter}, {target})
    return #colliding > 0
end

function Laser:draw2(unit)
    if (unit.laser_targets and #unit.laser_targets > 0) then
        for _, target in ipairs(unit.laser_targets) do
            graphics.line(unit.x, unit.y, target.x, target.y, unit.laser_color, 2)
        end
    end
end

function Laser:target_acquired(unit, target)
end

function Laser:lost_target(unit, target)
end

function Laser:selectTarget(unit, enemiesInRange)
    return random:table_remove(enemiesInRange)
end

function Laser:selectClosestTarget(unit, enemiesInRange)
    local closest = nil
    local closestDis = nil
    for _, enemy in ipairs(enemiesInRange) do
        local dis = math.distance(enemy.x, enemy.y, unit.x, unit.y)
        if closest == nil or dis < closestDis then
            closest = enemy
            closestDis = dis
        end
    end
    if closest then
        table.delete(enemiesInRange, closest)
        return closest
    end
    return random:table_remove(enemiesInRange)
end

function LaserClass:update(unit, dt)
    if not unit.laser_count_check then
        unit.laser_count_check = true
        local lvl = main.current.laser_level
        if unit.max_targets then
            unit.max_targets = unit.max_targets + (lvl == 2 and 2 or lvl == 1 and 1 or 0)
        end
        if unit.max_targets_add then
            unit.max_targets_add = unit.max_targets_add + (lvl == 2 and 1 or 0)
        end
    end
end

LASER_CLASS = LaserClass{}

require 'extras/laser/Telescope'
LaserClass = Object:extend()
LaserClass:implement(ExtraClass)

function LaserClass:init(args)
    self:init_class({
        key = 'laser',
        color = function() return white[0] end,
        color_string = 'fg',
        levels = {2, 4},
        stats = {
            hp = 1,
            dmg = 1.2,
            aspd = 1.1,
            area_dmg = 1,
            area_size = 1,
            def = 0.85,
            mvspd = 1.2
        },
    })
    laser = Image('laser')
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
    local callOrDefault = function(field, default)
        if type(field) == "number" or type(field) == "table" then
            return field
        elseif field then
            return field(player)
        else
            return default
        end
    end

    player.laser_targets = {}
    player.max_targets = callOrDefault(self.max_targets, 1)
    player.max_targets_add = callOrDefault(self.max_targets_add, 1)
    player.laser_acquire_range = callOrDefault(self.laser_acquire_range, 140)
    player.max_laser_range = callOrDefault(self.max_laser_range, 200)
    player.laser_acquire_frequency = callOrDefault(self.laser_acquire_frequency, 4)
    player.laser_color = self.laser_color(player)

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
            print('acquiring targets: ' .. #enemies .. ' possible enemies. adding: ' .. add)
            for _ = 1, add do
                local acquired = random:table_remove(enemies)
                self:target_acquired(player, acquired)
                table.insert(player.laser_targets, acquired)
            end
        end, nil, nil, 'shoot'
    )
    player.t:every(0.25, function()
        for _, acquired in ipairs(player.laser_targets) do
            if acquired.dead or math.distance(player.x, player.y, acquired.x, acquired.y) > player.max_laser_range then
                table.delete(player.laser_targets, acquired)
                self:lost_target(player, acquired)
            end
        end
    end, nil, nil, nil)
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
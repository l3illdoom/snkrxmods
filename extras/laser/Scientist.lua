require('extras/laser/Laser')

Scientist = Object:extend()
Scientist.key = 'scientist'
Scientist:implement(ExtraUnit)
function Scientist:init()
    self:init_unit({
        key = Scientist.key,
        classes = {'laser', 'conjurer'},
        color = function() return fg[0] end,
        color_string = 'fg',
        effect_name = '[fg]Rapid Construction',
        has_cooldown = true,
        attacks = true,
        tier = 3
    })
end

function Scientist:get_description(lvl)
    return '[fg]Constructs coils that shoot lightning at nearby units for [yellow]' ..
    get_character_stat(Scientist.key, lvl, 'dmg') .. ' [fg]damage'
end

function Scientist:get_effect_description()
    return '[fg]builds coils faster'
end

function Scientist:init_player(player)
    player.t:every(player.level == 3 and 7 or 10, function()
        Coil{group = main.current.main, x = player.x, y = player.y, parent = player, level = player.level}
    end, nil, nil, 'spawn')
end

Coil = Laser:extend()
Coil:implement(GameObject)
Coil:implement(Physics)

function Coil:init(args)
    self:init_game_object(args)
    self:set_as_circle(6, 'static', 'player')
    self:set_restitution(0)
    self.color = white[0]
    self.laser_color = function() return yellow2[0] end
    self.max_targets = 2
    self.max_targets_add = 2
    self.laser_acquire_range = 60
    self.laser_acquire_frequency = 0.75
    self.max_laser_range = 80
    self.max_laser_lock = 1.05
    self.laser_requires_los = false
    self.laser_thickness = 1.5
    self.lightning = {}
    self.lightning_redraw = 0.2

    self:init_player(self)

    self.t:after(12*(self.parent.conjurer_buff_m or 1), function()
        self:disableLaser(self)
        self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function()
            self.dead = true

            if self.parent.construct_instability then
                camera:shake(2, 0.5)
                local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
                Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
                _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            end
        end)
    end)
end

function Coil:update(dt)
    self:update_game_object(dt)
    LASER_CLASS:update(self, dt)

    -- update lightning locations and fade time if fading
    for k, v in pairs(self.lightning) do
        if v.fading then
            v.fade_time = v.fade_time + dt
            if v.fade_time >= 1 then
                self.lightning[k] = nil
            end
        else
            v.cur_time = v.cur_time + dt
            if v.cur_time > self.lightning_redraw then
                v.graphic = self:create_graphic(v.target)
                v.cur_time = v.cur_time - self.lightning_redraw
            end
        end
    end
end

function Coil:draw()
    if not self.hidden then
        graphics.circle(self.x, self.y, 3, self.color, 1)
    end

    for _, v in pairs(self.lightning) do
        local color = self.laser_color
        if v.fading then
            color = color:clone():fade(v.fade_time)
        end
        v.graphic:draw(color, self.laser_thickness)
    end
end

function Coil:target_acquired(unit, target)
    -- add dot
    local dmg = LASER_CLASS.laser_damage:getStat(self.parent.dmg)
            * (self.parent.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1)
    target:apply_dot(
            dmg,
            10000,
            yellow_transparent,
            'coil_laser_' .. unit.id
    )
    -- create line and turn it into lightning
    self.lightning[target.id] = {
        fading = false,
        fade_time = 0,
        graphic = self:create_graphic(target),
        target = target,
        cur_time = 0,
    }

    thunder1:play{pitch = 3, volume = 0.15}
end

function Coil:create_graphic(target)
    return Line(self.x, self.y, target.x, target.y):noisify(8, 4)
end

function Coil:lost_target(unit, target)
    -- remove dot
    if target and target.remove_dot then
        target:remove_dot('coil_laser_' .. unit.id)
    end
    -- start fading lightning
    local lightning = self.lightning[target.id]
    if lightning then
        lightning.fading = true
    end
end

Scientist{}
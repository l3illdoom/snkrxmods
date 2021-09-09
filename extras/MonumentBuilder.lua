
MonumentBuilder = Object:extend()
MonumentBuilder:implement(ExtraUnit)
function MonumentBuilder:init(args)
    self:init_unit({
        key = 'monument_builder',
        classes = {'conjurer', 'enchanter'},
        color = function() return purple[0] end,
        color_string = 'purple',
        effect_name = '[blue]Inspirational',
        tier = 3,
        has_cooldown = true
    })
end

function MonumentBuilder:get_description(lvl)
    return '[fg]creates a monument that inspires your nearby units to attack [yellow]33% [fg]faster'
end

function MonumentBuilder:get_effect_description()
    return '[fg]monuments last longer and add [yellow]33% [fg]defense'
end

function MonumentBuilder:init_player(player)
    player.t:every(14, function()
        Monument{group = main.current.main, x = player.x, y = player.y, color = player.color, parent = player, level = player.level}
    end, nil, nil, 'spawn')
end

Monument = Object:extend()
Monument:implement(GameObject)
Monument:implement(Physics)
function Monument:init(args)
    self:init_game_object(args)
    self:set_as_rectangle(9, 9, 'static', 'player')
    self:set_restitution(0.5)
    self.hfx:add('hit', 1)
    self.color = orange[0]
    self.heal_sensor = Circle(self.x, self.y, 48)

    self.vr = 0
    self.dvr = random:float(-math.pi/4, math.pi/4)

    buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}

    self.color = fg[0]
    self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
    self.rs = 0
    self.hidden = false
    self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
    self.t:after(0.2, function() self.color = args.color end)

    --[[self.t:every(self.parent.level == 3 and 3 or 6, function()
        self.hfx:use('hit', 0.2)
        HealingOrb{group = main.current.main, x = self.x, y = self.y}
        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
            local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)

            if #enemies > 0 then
                for _, enemy in ipairs(enemies) do
                    enemy.taunted = self
                    enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
                end
            end
        end

        if self.parent.rearm then
            self.t:after(0.25, function()
                self.hfx:use('hit', 0.2)
                HealingOrb{group = main.current.main, x = self.x, y = self.y}

                if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
                    local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
                    if #enemies > 0 then
                        for _, enemy in ipairs(enemies) do
                            enemy.taunted = self
                            enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
                        end
                    end
                end
            end)
        end
    end)

    --[[
    self.t:cooldown(3.33/(self.level == 3 and 2 or 1), function() return #self:get_objects_in_shape(self.heal_sensor, {Player}) > 0 end, function()
      local n = n or random:int(3, 4)
      for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
      heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      local units = self:get_objects_in_shape(self.heal_sensor, {Player})
      if self.level == 3 then
        local unit_1 = random:table_remove(units)
        local unit_2 = random:table_remove(units)
        if unit_1 then
          unit_1:heal(0.2*unit_1.max_hp*(self.heal_effect_m or 1))
          LightningLine{group = main.current.effects, src = self, dst = unit_1, color = green[0]}
        end
        if unit_2 then
          unit_2:heal(0.2*unit_2.max_hp*(self.heal_effect_m or 1))
          LightningLine{group = main.current.effects, src = self, dst = unit_2, color = green[0]}
        end
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
  
        if self.parent.rearm then
          self.t:after(1, function()
            heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            local unit_1 = random:table_remove(units)
            local unit_2 = random:table_remove(units)
            if unit_1 then
              unit_1:heal(0.2*unit_1.max_hp*(self.heal_effect_m or 1))
              LightningLine{group = main.current.effects, src = self, dst = unit_1, color = green[0]}
            end
            if unit_2 then
              unit_2:heal(0.2*unit_2.max_hp*(self.heal_effect_m or 1))
              LightningLine{group = main.current.effects, src = self, dst = unit_2, color = green[0]}
            end
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
          end)
        end
  
        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
              enemy.taunted = self
              enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
            end
          end
        end
  
      else
        local unit = random:table(units)
        unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
        LightningLine{group = main.current.effects, src = self, dst = unit, color = green[0]}
  
        if self.parent.rearm then
          self.t:after(1, function()
            heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            local unit = random:table(units)
            unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
            LightningLine{group = main.current.effects, src = self, dst = unit, color = green[0]}
          end)
        end
  
        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
              enemy.taunted = self
              enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
            end
          end
        end
      end
    end)
    ]]--

    self.t:after(12*(self.parent.conjurer_buff_m or 1)*(self.level == 3 and 1.25 or 1), function()
        self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function()
            self.dead = true

            if self.parent.construct_instability then
                camera:shake(2, 0.5)
                local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
                Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
                _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            end

            --todo: reduce effects of players in range
        end)
    end)
end

function Monument:update(dt)
    self:update_game_object(dt)
    self.vr = self.vr + self.dvr*dt
end

function Monument:draw()
    if self.hidden then return end

    graphics.push(self.x, self.y, math.pi/4, self.spring.x, self.spring.x)
    graphics.rectangle(self.x, self.y, 1.5*self.shape.w, 4, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    graphics.rectangle(self.x, self.y, 4, 1.5*self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    graphics.pop()

    graphics.push(self.x, self.y, self.r + self.vr, self.spring.x, self.spring.x)
    -- graphics.circle(self.x, self.y, self.shape.rs + random:float(-1, 1), self.color, 2)
    graphics.circle(self.x, self.y, self.heal_sensor.rs, self.color_transparent)
    local lw = math.remap(self.heal_sensor.rs, 32, 256, 2, 4)
    for i = 1, 4 do graphics.arc('open', self.x, self.y, self.heal_sensor.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
    graphics.pop()
end

function Monument:on_collision_enter(other, contact)
    if table.any(main.current.player:get_all_units(), function(v) v:is(other) end) then
       other.fairyd = true
        print(other.character .. ' entered collision')
    end
end

function Monument:on_collision_exit(other, contact)
    if table.any(main.current.player:get_all_units(), function(v) v:is(other) end) then
        other.fairyd = false
        print(other.character .. 'exited collision')
    end
end
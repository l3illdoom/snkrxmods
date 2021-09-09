require('extras/laser/Laser')
require('extras/extensions')

PsykerLaser = Object:extend()
PsykerLaser:implement(ExtraUnit)
PsykerLaser.key = 'laser_psyko'
function PsykerLaser:init()
    self:init_unit({
        key = PsykerLaser.key,
        classes = {'psyker', 'laser'},
        color = function() return fg[0] end,
        color_string = 'fg',
        effect_name = '[fg]Amplitude Modulation',
        tier = 2,
    })
end

function PsykerLaser:get_description(lvl)
    return '[fg]adds a short-range laser to each psyker orb that deals [yellow]' ..
        get_character_stat(PsykerLaser.key, lvl, 'dmg') ..
        ' [fg]damage'
end

function PsykerLaser:get_effect_description()
    return '[fg]increases orb laser range by [yellow]30% [fg]'
end

function PsykerLaser:init_player(player)
    Projectile.add_psyker_laser = player
end

function PsykerLaser:onArenaEnter(args)
    Projectile.add_psyker_laser = nil
end

override(Projectile, 'update', function(self, original, dt)
    original(self, dt)
    if self.attack_sensor then
        self.attack_sensor:move_to(self.x, self.y)
    end
    LASER_CLASS:update(self, dt)
end)

override(Projectile, 'init', function(self, original, args)
    original(self, args)
    if Projectile.add_psyker_laser and self.character == 'psyker' then
        OrbLaserInstance:init_player(self)
    end
end)

override(Projectile, 'draw', function(self, original)
    original(self)
    OrbLaserInstance:draw2(self)
end)

override(Player, 'hit', function(self, original, damage, from_undead)
    local was_dead = self.dead
    original(self, damage, from_undead)
    if not was_dead and self.dead and self.character == PsykerLaser.key then
        Projectile.add_psyker_laser = nil
        local allProjectiles = main.current.main:get_objects_by_class(Projectile)
        for _, orb in ipairs(table.select(allProjectiles, function(p) return p.character == 'psyker' end)) do
            OrbLaserInstance:disableLaser(orb)
        end
    end
end)

OrbLaser = Laser:extend()
function OrbLaser:init()
    self.max_targets = 1
    self.laser_acquire_range = function() return 45 * (Projectile.add_psyker_laser.level == 3 and 1.3 or 1) end
    self.laser_acquire_frequency = 0.5
    self.max_laser_range = function(player) return player.laser_acquire_range * 1.1 end
    self.laser_color = function() return fg_transparent_week end
    self.laser_thickness = 1.5
end

function OrbLaser:target_acquired(unit, target)
    local dmg = LASER_CLASS.laser_damage:getStat(Projectile.add_psyker_laser.dmg)
            * (Projectile.add_psyker_laser.dot_dmg_m or 1) * (main.current.chronomancer_dot or 1)
    target:apply_dot(
            dmg,
            10000,
            fg_transparent_weak,
            'orb_laser_' .. unit.id
    )
end

function OrbLaser:lost_target(unit, target)
    if target and target.remove_dot then
        target:remove_dot('orb_laser_' .. unit.id)
    end
end

PsykerLaser{}
OrbLaserInstance = OrbLaser{}
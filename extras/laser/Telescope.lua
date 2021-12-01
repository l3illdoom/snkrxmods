require('extras/extra-passives')

Telescope = ExtraPassive:extend()
Telescope.key = 'telescope'
function Telescope:init()
    self:init_passive({
        key = Telescope.key,
        class = 'laser',
        bonuses = {10, 20, 33}
    })
end

function Telescope:description(lvl)
    return '+' .. self:desc(lvl, self.bonuses) .. '% laser lock and tracking range'
end

function Telescope:onArenaEnter(args)
    print('Telescope:onArenaEnter, passives=' .. table.tostring(args.passives))
    local me = self:find(args.passives)
    local buff
    if me then
        buff = 1 + self.bonuses[me.level] / 100
        print('Telescope: found me, buff=' .. buff)
    end
    LASER_CLASS.max_laser_range:setMod(self.key, buff)
    LASER_CLASS.laser_acquire_range:setMod(self.key, buff)
end


TELESCOPE = Telescope{}
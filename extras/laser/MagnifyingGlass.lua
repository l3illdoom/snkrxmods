require('extras/extra-passives')

MagnifyingGlass = ExtraPassive:extend()
MagnifyingGlass.key = 'magnifying_glass'
function MagnifyingGlass:init()
    self:init_passive({
        key = MagnifyingGlass.key,
        class = 'laser',
        bonuses = {10, 20, 30}
    })
end

function MagnifyingGlass:description(lvl)
    return '+' .. self:desc(lvl, self.bonuses) .. '% damage to lasers'
end

function MagnifyingGlass:onArenaEnter(args)
    local me = self:find(args.passives)
    local buff
    if me then
        buff = 1 + self.bonuses[me.level] / 100
    end
    LASER_CLASS.laser_damage:setMod(self.key, buff)
end

MagnifyingGlass{}
def = {}

def.MonoOut = require 'mono'
def.VCO = require 'vco'
def.LFO = require 'lfo'
-- def.vca = require 'vca'

------ Create prototypes for display ------
protos = {}
for name, moddef in pairs(def) do
    proto = moddef()
    proto.def = moddef
    proto.locked = true
    table.insert(protos, proto)
end

------ Flow the layout ------
local padding = 10
local prev = nil
local maxw = {}
local row = 1
maxw[row] = 0
for name, mod in pairs(protos) do
    if prev then
        mod.SN.x, mod.SN.y = padding, prev.SN.y + prev.rect.bottom + padding * 3
        if mod.SN.y + mod.rect:h() > love.graphics.getHeight() then
            mod.SN.x = maxw[row] + padding * 5
            mod.SN.y = padding
            row = row + 1
            maxw[row] = 0
        end
    else
        mod.SN.x, mod.SN.y = padding, padding
    end
    if mod.rect:w() > maxw[row] then maxw[row] = mod.rect:w() end
    prev = mod
end

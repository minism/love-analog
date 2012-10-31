local VCA = Module:extend()

function VCA:init()
    Module.init(self, 'VCA', {
        ports = { Port('CV'), Port('In'), Port('Out')},
        knobs = { Knob('Amp') }
    })
end

return VCA
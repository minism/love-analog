local Speaker = Module:extend()

function Speaker:init()
    Module.init(self, 'Spkr', {
        ports = { Port('In') },
        knobs = { Knob('Vol') }
    })
end

return Speaker
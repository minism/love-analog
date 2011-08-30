local VCO = Module:extend()

function VCO:init()
    Module.init(self, 'VCO', {
        ports = { Port('CV'), Port('Out')},
        knobs = { Knob('Freq'), Knob('Phase') }
    })
end

return VCO
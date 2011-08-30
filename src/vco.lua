local VCO = Module:extend()

function VCO:init()
    Module.init(self, 'VCO', {
        ports = { Port('CV'), Port('Out')},
        knobs = { Knob('Freq'), Knob('Phase') }
    })
    self.freqRange = {60, 3000}
    self.phaseRange = {0, math.pi * 2}

    --- Waveform function
    local outPort = self.ports[2]
    function outPort.signal(t)
        -- Freq is logarthmic
        local range = self.freqRange[2] / self.freqRange[1]
        local freq = self.freqRange[1] * range ^ self.knobs[1].val
        -- Phase in linear
        local phase = self.knobs[2].val * 
                     (self.phaseRange[2] -self.phaseRange[1]) + self.phaseRange[1] 
        return math.sin(t * freq * twoPI + phase)
    end
end

return VCO
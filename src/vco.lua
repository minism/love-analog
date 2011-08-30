local VCO = Module:extend()

function VCO:init(freqRange, phaseRange)
    self.freqlow, self.freqhigh = 60, 3000
    local freqKnob = Knob('Freq')
    local phaseKnob = Knob('Phase')
    local cvFreq = Port('CV')
        cvFreq.signal = function(t)
            return cvFreq.out and cvFreq.out.signal(t) or 0 
        end
    local cvPhase = Port('CV')
        cvPhase.signal = function (t)
            return cvPhase.out and cvPhase.out.signal(t) or 0
        end
    local out = Port('Out', {
        signal = function (t)
            local freq = self.freqlow * (self.freqhigh / self.freqlow) ^ freqKnob.val
            local phase = phaseKnob.val * math.pi * 2
            return math.sin(t * freq * twoPI + freq * cvFreq.signal(t) + phase)
        end
    })
    Module.init(self, 'VCO', {
        ports = {cvFreq, cvPhase, out},
        knobs = {freqKnob, phaseKnob}
    })
end

return VCO
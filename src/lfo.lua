local LFO = Module:extend()

function LFO:init(freqRange, phaseRange)
    self.freqlow, self.freqhigh = 0.1, 60
    local freqKnob = Knob('Freq')
    local ampKnob = Knob('Amp')
    local cvFreq = Port('CV')
        cvFreq.signal = function(t)
            return cvFreq.out and cvFreq.out.signal(t) or 0 
        end
    local cvAmp = Port('CV')
        cvAmp.signal = function (t)
            return cvAmp.out and cvAmp.out.signal(t) or 0
        end
    local out = Port('Out', {
        signal = function (t)
            local freq = self.freqlow * (self.freqhigh / self.freqlow) ^ freqKnob.val
            local amp = ampKnob.val
            return math.sin(t * freq * twoPI) * amp
        end
    })

    Module.init(self, 'LFO', {
        ports = {cvFreq, cvAmp, out},
        knobs = {freqKnob, ampKnob}
    })
end

return LFO
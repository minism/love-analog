local BUFSIZE   = 2048
local RATE      = 44100
local BITS      = 16
local CHANNELS  = 1

local MonoOut = Module:extend()

--- Speaker output module with built in sampler
function MonoOut:init()
    Module.init(self, 'Mono Out', {
        ports = { Port('In') },
        knobs = { Knob('Vol') }
    })

    -- Sampling data
    self.activeSource = nil
    self.sampleQueue = Queue:new()
    self.sampleTimer = time.every(BUFSIZE / RATE, self:sampleClosure())
end

function MonoOut:sampleClosure()
    return function ()
        if self.locked then 
            self.sampleTimer:stop()
            return 
        end
        --- Generate a new sample from circuit connected to in
        port = self.ports[1].out
        if port then
            local sample = love.sound.newSoundData(BUFSIZE, RATE, BITS, CHANNELS)
            for i = 0, BUFSIZE - 1 do
                local t = i / RATE
                sample:setSample(i, port.signal(t) * self.knobs[1].val)
            end
            self.sampleQueue:push(sample)
        end

        --- Play the next sample in queue
        if not self.sampleQueue:isEmpty() then
            if self.activeSource then self.activeSource:stop() end
            local sample = self.sampleQueue:pop()
            self.activeSource = love.audio.newSource(sample)
            self.activeSource:play()
        end
    end
end

return MonoOut

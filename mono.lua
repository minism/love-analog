local RATE      = 44100
local BUFSIZE   = RATE / 4
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
    self.sourceQueue = Queue:new()

    -- Offset playback timer from sampleTimer
    self.sampleTimer = time.every(BUFSIZE / RATE, self:sampleClosure())
    self.playbackTimer = time.every(BUFSIZE / RATE, self:playbackClosure())
    self.playbackTimer.timeLeft = (BUFSIZE / RATE) / 2

    -- Global function counter
    self.ticks = 0
end

function MonoOut:playbackClosure()
    return function()
        if self.locked then
            self.playbackTimer:stop()
            return
        end

        --- Play the next sample in queue
        if not self.sampleQueue:isEmpty() then
            local sample = self.sampleQueue:pop()
            local source = love.audio.newSource(sample)
            source:play()

            -- Put the source in the active queue
            self.sourceQueue:push(source)
        end
    end
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
                self.ticks = self.ticks + 1
                local t = self.ticks / RATE
                sample:setSample(i, port.signal(t) * self.knobs[1].val)
            end
            self.sampleQueue:push(sample)

            -- Kill the top audio source in queue
            if not self.sourceQueue:isEmpty() then
                local source = self.sourceQueue:pop()
                source:stop()
            end
        end
    end
end

return MonoOut

--- Speaker
def.Speaker = Module:extend()

function def.Speaker:init()
    Module.init(self, 'Speaker', {
        ports = { Port('In') },
        knobs = { Knob('Vol') }
    })
end

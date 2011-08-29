require 'math'
require 'os'
require 'leaf'

twoPI = math.pi * 2

-- Namespace imports
console = leaf.console
Object  = leaf.Object
Rect    = leaf.Rect

require 'module'

function love.load()
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
    m = Module('VCO', {
                   ports = { Port('A'), Port('B') },
                   knobs = { Knob('A'), Knob('B') },
              })
end

function love.update(dt)
    --
end

function love.draw()
    m:draw()
    console.draw()
end 

function love.keypressed(key, unicode)
    --
end

function love.mousepressed(x, y, button)
    --
end

function love.quit()
    --
end

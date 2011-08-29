require 'math'
require 'os'
require 'leaf'

twoPI = math.pi * 2

-- Namespace imports
console = leaf.console
Object  = leaf.Object
Rect    = leaf.Rect
List    = leaf.List

require 'module'

function love.load()
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
    love.graphics.setFont(10)
    modules = List:new()
    modules:insert(Module('VCO', {
                   x = 20, y = 20,
                   ports = { Port('A'), Port('B') },
                   knobs = { Knob('C'), Knob('D') },
              }))
    modules:insert(Module('VCA', {
                   x = 100, y = 100,
                   ports = { Port('E'), Port('F') },
                   knobs = { Knob('G'), Knob('h') },
              }))
end

function love.update(dt)
    if mactive then
        mactive:mousemoved(love.mouse.getPosition())
    end
end

function love.draw()
    for mod in modules:iter() do
        mod:draw()
    end
    console.draw()
end 

function love.keypressed(key, unicode)
    --
end

function love.mousepressed(x, y, button)
    for mod in modules:iter() do
        if mod:mousepressed(x, y, button) then return true end
    end
end

function love.mousereleased(x, y, button)
    mactive = nil
end

function love.quit()
    --
end

require 'math'
require 'os'
require 'leaf'

twoPI = math.pi * 2

-- Namespace imports
console = leaf.console
Object  = leaf.Object
Rect    = leaf.Rect
List    = leaf.List
SceneNode = leaf.SceneNode


-- Root node in scene graph
rootSN  = SceneNode()

require 'module'

function love.load()
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
    love.graphics.setFont(10)
    modules = List:new()
    modules:insert(Module('Module A', {
                   x = 20, y = 20,
                   ports = { Port('A'), Port('B') },
                   knobs = { Knob('C'), Knob('D') },
              }))
    modules:insert(Module('Module B', {
                   x = 120, y = 20,
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
        for _, port in ipairs(mod.ports) do
            -- Draw connecting wire to output port
            if port.outp then
                local sx, sy = port:cpos()
                local dx, dy = port.outp:cpos()
                love.graphics.setColor(0, 255, 0)
                love.graphics.setLineWidth(2)
                love.graphics.line(sx, sy, dx, dy)
            end
        end
    end
    -- Draw temp wire
    love.graphics.setLineWidth(2)
    love.graphics.setColor(255, 0, 0)
    if tmpport then
        local x, y = tmpport:cpos()
        love.graphics.line(x, y, love.mouse.getPosition())
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
    if tmpport then  
        for mod in modules:iter() do
            if mod:tryConnect(x, y, tmpport) then break end
        end
    end
    mactive, tmpport = nil, nil
end

function love.quit()
    --
end

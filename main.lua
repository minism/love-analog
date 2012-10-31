require 'math'
require 'os'
require 'leaf'

twoPI = math.pi * 2
scrw, scrh = love.graphics.getWidth(), love.graphics.getHeight()

-- Namespace imports
console = leaf.console
time    = leaf.time
Object  = leaf.Object
Rect    = leaf.Rect
List    = leaf.List
Queue   = leaf.Queue
SceneNode = leaf.SceneNode

-- Globals
DRAWER = 200
TRASH = Rect(love.graphics.getWidth() - 150, love.graphics.getHeight() - 150,
             love.graphics.getWidth(), love.graphics.getHeight())
rootSN  = SceneNode()

require 'module'
require 'defs'

function love.load()
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
    love.graphics.setFont(10)
    modules = List:new()
end

function love.update(dt)
    time.update(dt)

    -- Detect mouse dragging
    if mactive then
        mactive:mousemoved(love.mouse.getPosition())
    end
    if mplacing then
        mplacing:mousemoved(love.mouse.getPosition())
    end
end

function love.draw()
    -- Draw audio load
    love.graphics.setColor(255, 255, 255)
    love.graphics.print('Active voices: ' .. love.audio.getNumSources(), scrw - 150, 25)

    -- Draw trash
    love.graphics.setColor(100, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.setLineStyle('rough')
    love.graphics.rectangle('line', TRASH:unpack())
    local cx, cy = TRASH:center()
    love.graphics.printf('DELETE', TRASH.left, cy, TRASH:w(), 'center')

    -- Draw drawer
    love.graphics.setColor(255, 255, 255)
    love.graphics.line(DRAWER, 0, DRAWER, love.graphics.getHeight())
    for name, mod in pairs(protos) do
        mod:draw()
    end

    -- Draw modules
    for mod in modules:iter() do
        mod:draw()
        for _, port in ipairs(mod.ports) do
            -- Draw connecting wire to output port
            if port.out then
                local sx, sy = port:cpos()
                local dx, dy = port.out:cpos()
                love.graphics.setColor(0, 255, 0)
                love.graphics.setLineWidth(2)
                love.graphics.line(sx, sy, dx, dy)
            end
        end
    end

    -- Draw temp mod
    if mplacing then
        mplacing:draw()
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
    for _, proto in pairs(protos) do
        if proto:mousepressed(x, y, button) then 
            mplacing = proto.def:new()
            mplacing.px, mplacing.py = proto.SN:toLocal(x, y)
            mplacing.ghost = true
            return true
        end
    end
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
    if mactive and TRASH:contains(x, y) then
        --
    end
    if mplacing and x - mplacing.px > DRAWER then
        mplacing.ghost = false
        modules:insert(mplacing)
    end
    mactive, tmpport, mplacing = nil, nil, nil
end

function love.quit()
    --
end

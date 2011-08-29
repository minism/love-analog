---- Generic module objects

local GSIZE = 48

--- Global position interface
Loc = Object:extend()

function Loc:init(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Loc:toLocal(x, y)
    return x - self.x, y - self.y
end

function Loc:toGlobal(x, y)
    return x + self.x, y + self.y
end

function Loc:push()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
end

Loc.pop = love.graphics.pop

--- Generic module component
Component = Object:extend()

function Component:init(label, p)
    local p = p or {}
    self.label = label or ''
    self.rect = Rect(GSIZE, GSIZE)
end

function Component:draw()
    -- Draw my graphics
    self:gfx()

    -- Draw label
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(self.label, 0, self.rect:getHeight() - 4 ,
                         self.rect:getWidth(), 'center')
end

function Component:gfx() end

function Component:mousepressed(x, y, button) 
    if self.rect:scale(0.6, 'center'):contains(x, y) then 
        mactive = self
        return true
    end
end

function Component:mousemoved(x, y) end


--- One way connection that sends data
Port = Component:extend()

function Port:init(label, p)
    local p = p or {}
    Component.init(self, label, p)
    self.inp = p.inp or nil
    self.outp = p.outp or nil
end

function Port:gfx()
    local cx, cy = self.rect:getWidth() / 2 - 1, self.rect:getHeight() / 2 - 1
    local r = GSIZE / 4
    love.graphics.setColor(120, 120, 200)
    love.graphics.circle('line', cx, cy, r)
    if self.inp or self.outp then
        love.graphics.setColor(150, 150, 150)
        love.graphics.circle('line', cx, cy, 2)
    end
end


--- Just.. you know... like, a knob
Knob = Component:extend()

function Knob:init(label, p)
    local p = p or {}
    Component.init(self, label, p)
    self.val = p.val or 0.0
end

function Knob:gfx()
    local cx, cy = self.rect:getWidth() / 2 - 1, self.rect:getHeight() / 2 - 1
    local r = GSIZE / 3
    -- Draw handle
    love.graphics.setColor(120, 200, 120)
    love.graphics.circle('line', cx, cy, r)
    -- Draw value indicator, 75% of knob range, rotated 5pi/4
    local theta = (3/4 * self.val - 5/8) * twoPI
    local vy = math.sin(theta) * r
    local vx = math.cos(theta) * r
    love.graphics.line(cx, cy, cx + vx, cy + vy)
end

function Knob:onClick()
end


--- Modules are collections of components
Module = Object:extend()

function Module:init(label, p)
    local p = p or {}
    self.L = Loc(p.x, p.y)
    self.label = label or '<noname>'
    self.rect = Rect(0, 0)
    self.ports = p.ports or {}
    self.knobs = p.knobs or {}
    self:reflow()
end

function Module:reflow()
    local rows = math.min(1, #self.ports) + math.min(1, #self.knobs)
    local cols = math.max(#self.ports, #self.knobs)
    self.rect = Rect(cols * GSIZE, rows * (GSIZE + GSIZE / 4))
end

function Module:addPort(port)
    table.insert(self.ports, port)
end

function Module:addKnob(knob)
    table.insert(self.knobs, knob)
end

function Module:draw()
    self.L:push()
        -- Frame
        love.graphics.setLineStyle('rough')
        love.graphics.setColor(255, 255, 255)
        if mactive == self then love.graphics.setColor(255, 0, 0) end
        love.graphics.rectangle('line', self.rect:unpack())

        -- Components
        for i, port in ipairs(self.ports) do
            love.graphics.push()
                love.graphics.translate((i - 1) * GSIZE, 0)
                port:draw()
            love.graphics.pop()
        end
        for i, knob in ipairs(self.knobs) do
            love.graphics.push()
                love.graphics.translate((i - 1) * GSIZE, GSIZE + GSIZE / 4)
                knob:draw()
            love.graphics.pop()
        end

        -- Label
        love.graphics.printf(self.label, 0, self.rect:getHeight() + 2, 
                             self.rect:getWidth(), 'center')
    self.L:pop()
end

function Module:mousepressed(x, y, button)
    local lx, ly = self.L:toLocal(x, y)
    if self.rect:contains(lx, ly) then
        for i, port in ipairs(self.ports) do
            local cx, cy = lx - (i - 1) * GSIZE, ly - 0
            if port:mousepressed(cx, cy, button) then
                return true
            end
        end
        for i, knob in ipairs(self.knobs) do
            local cx, cy = lx - (i - 1) * GSIZE, ly - GSIZE - GSIZE / 4
            if knob:mousepressed(cx, cy, button) then
                return true
            end
        end
        -- No component caught, move module
        mactive = self
        self.px, self.py = lx, ly
    end
end

function Module:mousemoved(x, y)
    self.L = Loc(x - self.px, y - self.py)
end

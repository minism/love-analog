---- Generic module objects

local GSIZE = 52
local SPACING = GSIZE / 4

--- Generic module component
Component = Object:extend()

function Component:init(label, p)
    local p = p or {}
    self.label = label or ''
    self.rect = Rect(GSIZE, GSIZE)
    self.SN = SceneNode()
end

function Component:draw()
    -- Draw my graphics
    self:gfx()

    -- Draw label
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(self.label, 0, self.rect:getHeight() - 8 ,
                         self.rect:getWidth(), 'center')
end

function Component:gfx() end

function Component:mousepressed(x, y, button) 
    if self.rect:scale(0.6, 'center'):contains(self.SN:toLocal(x, y)) then 
        mactive = self
        self.px, self.py = x, y
        return true
    end
end

function Component:mousemoved(x, y) end

--- One way connection that sends data
Port = Component:extend()

function Port:init(label, p)
    local p = p or {}
    Component.init(self, label, p)
    self.signal = p.signal or function(t) return 0 end
    self.r = GSIZE / 4
    self.out = nil
end

--- Returns absolute position of the center of the port
function Port:cpos()
    return self.SN:toGlobal(self.rect:w() / 2, self.rect:h() / 2)
end

function Port:gfx()
    local cx, cy = self.rect:getWidth() / 2 - 1, self.rect:getHeight() / 2 - 1
    -- Draw port
    love.graphics.setColor(120, 120, 200)
    love.graphics.setLineWidth(1)
    love.graphics.circle('line', cx, cy, self.r)
    if self.out then
        love.graphics.setColor(150, 150, 150)
        love.graphics.circle('line', cx, cy, 3)
    end
end

function Port:mousepressed(x, y)
    if Component.mousepressed(self, x, y) then
        -- Remove existing connections
        if self.out then
            self.out.out = nil
            self.out = nil
        end
        tmpport = self
        return true
    end
end

function Port:tryConnect(x, y, port)
    local cx, cy = self:cpos()
    if Rect(cx - self.r / 2, cy - self.r / 2,
            cx + self.r / 2, cy + self.r / 2):contains(x, y) then
        if self.out == nil then
            self.out = port
            port.out = self
        end
    end
end

--- Just.. you know... like, a knob
Knob = Component:extend()

function Knob:init(label, p)
    local p = p or {}
    Component.init(self, label, p)
    self.val = p.val or 0.5
end

function Knob:gfx()
    local cx, cy = self.rect:getWidth() / 2 - 1, self.rect:getHeight() / 2 - 1
    local r = GSIZE / 3
    -- Draw handle
    love.graphics.setLineWidth(1)
    love.graphics.setColor(120, 200, 120)
    love.graphics.circle('line', cx, cy, r)
    -- Draw value indicator, 75% of knob range, rotated 5pi/4
    local theta = (3/4 * self.val - 5/8) * twoPI
    local vy = math.sin(theta) * r
    local vx = math.cos(theta) * r
    love.graphics.setLineWidth(1)
    love.graphics.line(cx, cy, cx + vx, cy + vy)
end

function Knob:mousepressed(x, y)
    self.pval = self.val
    return Component.mousepressed(self, x, y)
end

function Knob:mousemoved(x, y)
    local range = -GSIZE * 3
    self.val = (y - self.py) / range + self.pval
    if self.val > 1 then self.val = 1
    elseif self.val < 0 then self.val = 0 end
end


--- Modules are collections of components
Module = Object:extend()

function Module:init(label, p)
    local p = p or {}
    self.SN = rootSN:addChild(p.x, p.y)
    self.label = label or '<noname>'
    self.rect = Rect(0, 0)
    self.ports = p.ports or {}
    self.knobs = p.knobs or {}
    -- Adjust layout
    self:reflow()
end

function Module:reflow()
    local rows = math.min(1, #self.ports) + math.min(1, #self.knobs)
    local cols = math.max(#self.ports, #self.knobs)
    for i, port in ipairs(self.ports) do
        port.SN = self.SN:addChild((i - 1) * GSIZE, 0)
    end
    for i, knob in ipairs(self.knobs) do
        knob.SN = self.SN:addChild((i - 1) * GSIZE, GSIZE + SPACING)
    end
    self.rect = Rect(cols * GSIZE, rows * (GSIZE + SPACING))
end

function Module:draw()
    self.SN:push()
        -- Frame
        love.graphics.setLineStyle('rough')
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255, 255, 255)
        if mactive == self then love.graphics.setColor(255, 0, 0) end
        love.graphics.rectangle('line', self.rect:unpack())

        -- Components
        for i, port in ipairs(self.ports) do
            port.SN:push()
                port:draw()
            port.SN:pop()
        end
        for i, knob in ipairs(self.knobs) do
            knob.SN:push()
                knob:draw()
            knob.SN:pop()
        end

        -- Label
        love.graphics.printf(self.label, 0, self.rect:getHeight(), 
                             self.rect:getWidth(), 'center')
    self.SN:pop()
end

function Module:tryConnect(x, y, inport)
    if self.rect:contains(self.SN:toLocal(x, y)) then
        for _, port in ipairs(self.ports) do
            if port ~= inport and port:tryConnect(x, y, inport) then
                return true
            end
        end
    end
end

function Module:mousepressed(x, y, button)
    if self.rect:contains(self.SN:toLocal(x, y)) then
        if not self.locked then
            for i, port in ipairs(self.ports) do
                if port:mousepressed(x, y, button) then
                    return true
                end
            end
            for i, knob in ipairs(self.knobs) do
                if knob:mousepressed(x, y, button) then
                    return true
                end
            end
            -- No component caught, move module
            mactive = self
        end
            self.px, self.py = self.SN:toLocal(x, y)
        return true
    end
end

function Module:mousemoved(x, y)
    if not self.locked then
        limit = self.ghost and 0 or DRAWER
        local px = self.px or 0; local py = self.py or 0
        self.SN.x, self.SN.y = math.max(limit, x - px), math.max(0, y - py)
    end
end
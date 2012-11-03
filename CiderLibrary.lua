
--# Frame
Frame = class()

-- Frame 
-- ver. 1.5
-- a simple rectangle for holding controls.
-- ====================

function Frame:init(left, bottom, right, top)
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
end

function Frame:inset(dx, dy)
    self.left = self.left + dx
    self.right = self.right - dx
    self.bottom = self.bottom + dy
    self.top = self.top - dy
end

function Frame:offset(dx, dy)
    self.left = self.left + dx
    self.right = self.right + dx
    self.bottom = self.bottom + dy
    self.top = self.top + dy
end
    
function Frame:draw()
    pushStyle()
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    popStyle()
end

function Frame:roundRect(r)
    pushStyle()
    insetPos = vec2(self.left + r,self.bottom + r)
    insetSize = vec2(self:width() - 2 * r,self:height() - 2 * r)

    rectMode(CORNER)
    rect(insetPos.x, insetPos.y, insetSize.x, insetSize.y)

    if r > 0 then
        smooth()
        lineCapMode(ROUND)
        strokeWidth(r * 2)

        line(insetPos.x, insetPos.y, 
             insetPos.x + insetSize.x, insetPos.y)
        line(insetPos.x, insetPos.y,
             insetPos.x, insetPos.y + insetSize.y)
        line(insetPos.x, insetPos.y + insetSize.y,
             insetPos.x + insetSize.x, insetPos.y + insetSize.y)
        line(insetPos.x + insetSize.x, insetPos.y,
             insetPos.x + insetSize.x, insetPos.y + insetSize.y)            
    end
    popStyle()
end

function Frame:gloss(baseclr)
    local i, t, r, g, b, y
    pushStyle()
    if baseclr == nil then baseclr = color(194, 194, 194, 255) end
    fill(baseclr)
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    r = baseclr.r
    g = baseclr.g
    b = baseclr.b
    for i = 1 , self:height() / 2 do
        r = r - 1
        g = g - 1
        b = b - 1
        stroke(r, g, b, 255)
        y = (self.bottom + self.top) / 2
        line(self.left, y + i, self.right, y + i)
        line(self.left, y - i, self.right, y - i)
    end
    popStyle()
end

function Frame:shade(base, step)
    pushStyle()
    strokeWidth(1)
    for y = self.bottom, self.top do
        i = self.top - y
        stroke(base - i * step, base - i * step, base - i * step, 255)
        line(self.left, y, self.right, y)
    end
    popStyle()
end

function Frame:touched(touch)
    if touch.x >= self.left and touch.x <= self.right then
        if touch.y >= self.bottom and touch.y <= self.top then
            return true
        end
    end
    return false
end

function Frame:ptIn(x, y)
    if x >= self.left and x <= self.right then
        if y >= self.bottom and y <= self.top then
            return true
        end
    end
    return false
end

function Frame:overlaps(f)
    if self.left > f.right or self.right < f.left or
    self.bottom > f.top or self.top < f.bottom then
        return false
    else
        return true
    end
end

function Frame:width()
    return self.right - self.left
end

function Frame:height()
    return self.top - self.bottom
end

function Frame:midX()
    return (self.left + self.right) / 2
end
    
function Frame:midY()
    return (self.bottom + self.top) / 2
end

--# DropList
DropList = class(Frame)

function DropList:init(s, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = s
    self.font = "ArialMT"
    self.fontSize = 14
    self.background = color(255, 255, 255, 255)
    self.foreground = color(31, 31, 31, 255)
    self.itemText = {}
    self.open = false
    self.selected = 1
    self:splitText()
end

function DropList:splitText()
    local i, k
    i = 0
    for k in string.gmatch(self.text,"([^;]+)") do
        i = i + 1
        self.itemText[i] = k
    end
end

function DropList:draw()
    local i, t, h
    pushStyle()
    font(self.font)
    fontSize(self.fontSize)
    textMode(CENTER)
    stroke(self.foreground)
    fill(self.background)
    rect(self.left, self.bottom, self:width(), self:height())
    fill(self.foreground)
    if self.open then
        for i, t in ipairs(self.itemText) do
            text(t, self:midX(), self.top - i * 30 + 15)
        end
        strokeWidth(2)
        stroke(243, 9, 9, 255)
        line(self.left + 4, self.top - self.selected * 30,
        self.right - 4, self.top - self.selected * 30)
        line(self.left + 4, self.top - self.selected * 30 + 30,
        self.right - 4, self.top - self.selected * 30 + 30)
    else
        text(self.itemText[self.selected], self:midX(), self:midY())
    end
    popStyle()
end

function DropList:touched(touch)
    local h
    h = #self.itemText * 30
    if self:ptIn(touch.x, touch.y) then
        if not self.open then 
            if touch.state == BEGAN then
                self.open = true
                self.bottom = self.top - h
            end
        else 
            self.selected = 
            math.floor((self.top - touch.y) / 30)
            if self.selected < 1 then self.selected = 1 
            elseif self.selected > #self.itemText then 
                self.selected = #self.itemText
            end 
        end
    end
    if touch.state == ENDED then
        self.open = false
        self.bottom = self.top - 30
    end
end
        
function DropList:initString()
    return "DropList('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end
    
    
--# Dialog
Dialog = class(Frame)

function Dialog:init(t, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = t
    self.inner = Frame(left + 4, bottom + 4, right - 4, top - 40)
    self.background = color(255, 255, 255, 255)
    self.foreground = color(20, 20, 20, 255)
    self.highlight = color(95, 159, 172, 37)
end

function Dialog:draw()
    pushMatrix()
    pushStyle()
    textMode(CENTER)
    textAlign(CENTER)
    fill(self.foreground)
    stroke(self.foreground)
    strokeWidth(2)
    self:roundRect(8)
    fill(self.background)
    stroke(self.background)
    text(self.text, self:midX(), self.top - 20)
    self.inner:roundRect(10)
    popStyle()
    popMatrix()
end

function Dialog:touched(touch)
    return self.inner:touched(touch)
end

function Dialog:initString()
    return "Dialog('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end

--# IconButton
IconButton = class(Frame)

-- IconButton 
-- ver. 1.5
-- a simple control that centers an image in a frame
-- ====================

function IconButton:init(img, left, bottom, right, top)
    Frame(self, left, bottom, right, top)
    self.img = img
    self.background = color(56, 56, 56, 255)
end

function IconButton:draw()
    fill(self.background)
    rect(self.left, self.bottom, self:width(), self:height())
    sprite(self.img, self:midX(), self:midY())
end




    

--# Label
Label = class(Frame)

-- Label 
-- ver. 1.5
-- a control for basic text label
-- ====================

function Label:init(s, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = s
    self.font = "ArialMT"
    self.fontSize = 14
    self.textAlign = CENTER
    self.background = color(222, 222, 222, 255)
    self.foreground = color(20, 20, 20, 255)
end

function Label:draw()
    pushStyle()
    font(self.font)
    textMode(self.textAlign)
    fontSize(self.fontSize)
    fill(self.foreground)
    text(self.text, self:midX(), self:midY())
    popStyle()
end

function Label:initString()
    return "Label('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end
--# Main
-- Cider Controls
-- =====================
-- Designed for use with the Cider interface designer
-- Use this file to test and demostrate controls in the library
-- =====================

function setup()
    btnTest = TextButton("Button", 100, HEIGHT - 100, 250, HEIGHT - 60)
    txtTest = TextBox("Text Box", 100, HEIGHT - 160, 250, HEIGHT - 130)
    sldTest = Slider("Slider", 100, 100, 400, 170, 0, 111, 20)
    swtTest = Switch("On;Off", 100, 200, 200, 230, 14, 48, 14)
    mlbTest = MultiButton("Left;Center;Right", 100, 400, 450, 440)
    lblTest = Label("Label Test", 100, 500, 350, 550)
    dlgTest = Dialog("Dialog Test", 100, 300, WIDTH - 100, 600)
    showDialog = false
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(181, 181, 181, 255)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    btnTest:draw()
    txtTest:draw()
    swtTest:draw()
    sldTest:draw()
    mlbTest:draw()
    lblTest:draw()
    if showDialog then dlgTest:draw() end
end

function touched(touch)
    if btnTest:touched(touch) then
        showDialog = true
    end
        
    txtTest:touched(touch)
    if swtTest:touched(touch) then
        CCActiveTextBox = nil
    end
    
    sldTest:touched(touch)
    mlbTest:touched(touch)
    lblTest:touched(touch)
end

function keyboard(key) 
    if CCActiveTextBox then
        CCActiveTextBox:acceptKey(key)
    end
end

--# MultiButton
MultiButton = class(Frame)

function MultiButton:init(s, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = s
    self.font = "ArialMT"
    self.fontSize = 14
    self.background = color(255, 255, 255, 255)
    self.foreground = color(20, 20, 20, 255)
    self.highlight = color(95, 159, 172, 37)
    self.selected = 1
    self.itemText = {}
    self:splitText()
end

function MultiButton:splitText()
    local i, k
    i = 0
    for k in string.gmatch(self.text,"([^;]+)") do
        i = i + 1
        self.itemText[i] = k
    end
end

function MultiButton:draw()
    local w, i, b, h
    pushStyle()
    w = (self:width()) / #self.itemText
    h = self:height()
    strokeWidth(2)
    fill(self.background)
    stroke(self.foreground)
    self:roundRect(6)
    noStroke()
    stroke(self.background)
    self:inset(2, 2)
    self:roundRect(6)
    self:inset(-2, -2)
    stroke(self.foreground)
    textMode(CENTER)
    font(self.font)
    fontSize(self.fontSize)
    
    for i, b in ipairs(self.itemText) do
        fill(self.foreground)
        strokeWidth(2)
        if i < #self.itemText then
            line(self.left + i * w, self.top, 
            self.left + i * w, self.bottom)
        end
        text(b, (self.left + i * w) - (w / 2), self:midY())
        noStroke()
            fill(0, 0, 0, 22)
        if i ~= self.selected then
            h = self:height()
            rect(self.left + i * w - w, self.bottom,
            w, h * 0.6 )
            rect(self.left + i * w - w, self.bottom,
            w, h * 0.4 )
            rect(self.left + i * w - w, self.bottom,
            w, h * 0.2 )
        else
            fill(self.highlight)
            rect(self.left + i * w - w, self:midY() - h/4,
            w, self:height() * 0.6)
            rect(self.left + i * w - w, self:midY(),
            w, self:height() * 0.4 )
            rect(self.left + i * w - w, self:midY() + h/4,
            w, self:height() * 0.3 )
        end
    end
    popStyle()
end

function MultiButton:touched(touch)
    if self:ptIn(touch.x, touch.y) then
        if touch.state == BEGAN and oldState ~= BEGAN then
            w = (self:width()) / #self.itemText
            i = math.floor((touch.x - self.left) / w) + 1
            self.selected = i
        end
        return true
    end
end

function MultiButton:initString()
    return "MultiButton('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end

--# PopMenu
PopMenu = class()

-- PopMenu 
-- ver. 1.0
-- a control that provides a simple menu
-- ====================

function PopMenu:init(x, y)
    self.x = x
    self.y = y
    self.items={}
    self.frames = {}
end

function PopMenu:draw()
    local h, w, x, i
    pushStyle()
    h = 10
    w = 100
    for i, item in ipairs(self.items) do
        h = h + 60
        if string.len(item) * 20 > w then
            w = string.len(item) * 20
        end  
    end
    w = w + 20
    fill(0, 0, 0, 255)
    rect(self.x, self.y, w, h)
    textAlign(CENTER)
    for i, item in ipairs(self.items) do
        self.frames[i] = Frame(self.x + 10, self.y + i * 60 - 50, 
            self.x + w - 10, self.y + i * 60 )
        self.frames[i]:gloss(color(255, 255, 255, 255))
        x = self.x + w / 2
        text(item, x, self.y + i * 60 - 24)
    end
    popStyle()
end

function PopMenu:touched(touch)
    local i
    for i, frame in ipairs(self.frames) do
        if frame:touched(touch) then
            fill(255, 14, 0, 255)
            frame:draw()
            return i
        end
    end
    return nil
end

--# Slider
Slider = class(Frame)

-- Slider 
-- ver. 1.6
-- a control that replicates the iparameter slider
-- ====================

-- 1.6    bug fix on initString

function Slider:init(s, left, bottom, right, top, min, max, val)
    Frame.init(self, left, bottom, right, top)
    self.font = "ArialMT"
    self.fontSize = 14
    self.text = s
    self.background = color(238, 238, 238, 255)
    self.foreground = color(31, 31, 31, 255)
    self.highlight = color(132, 179, 190, 255)
    self.min = min
    self.max = max
    self.val = val
end

function Slider:draw()
    local x, y, scale
    pushStyle()
    font(self.font)
    fontSize(self.fontSize)
    stroke(self.foreground)
    fill(self.background)
    h, w = textSize(self.max)
    scale = (self:width() - h * 2) / (self.max - self.min)
    x = self.left + h + ((self.val - self.min) * scale)
    y = self:midY()
    strokeWidth(3)
    line(self.left + h, y, self.right - h, y)
    stroke(self.background)
    line(self.left + h, y + 2, self.right - h, y + 2)
    stroke(self.background)
    line(self.left + h, y, self.right - h, y)
    strokeWidth(1)
    stroke(self.foreground)
    fill(self.highlight)
    ellipse(x, y, 20)
    fill(self.foreground)
    h, w = textSize("Slider")
    textMode(CENTER)
    textAlign(LEFT)
    text(self.min, self.left, y)
    textAlign(RIGHT)
    text(self.max, self.right, y)
    textAlign(CENTER)
    text(self.text, self:midX(), y + h / 2)
    if self.val > self.min and self.val < self.max then
        text(self.val, x, y - h / 2)
    end
    popStyle()
end

function Slider:touched(touch)
    local x, scale
    if touch.state == BEGAN or touch.state == MOVING then
        if self:ptIn(touch.x, touch.y) then
            x = touch.x - self.left - 10
            scale = ((self.right - self.left) - 20) /
             (self.max - self.min)
            self.val = math.floor(x / scale) + self.min
            if self.val < self.min then
                self.val = self.min
            elseif self.val > self.max then
                self.val = self.max
            end
            return true
        end
    end
end

function Slider:initString()
    return "Slider('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..", "..self.min..", "..
        self.max..", "..self.val..")"
end




--# Switch
Switch = class(Frame)

-- Switch 
-- ver. 1.5
-- a control for displaying a two position switch
-- ====================

-- notes 
-- 1.6 cosmetic changes
-- 1.5 implemented inheritance from Frame

function Switch:init(s, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = s
    self.font = "ArialMT"
    self.fontSize = 14
    self.background = color(255, 255, 255, 255)
    self.foreground = color(20, 20, 20, 255)
    self.highlight = color(97, 159, 173, 255)
    self.selected = true
    self.itemText = {}
    self:splitText()
end

function Switch:splitText()
    local i, k
    i = 0
    for k in string.gmatch(self.text,"([^;]+)") do
        i = i + 1
        self.itemText[i] = k
    end
end

function Switch:draw()
    pushStyle()
    font(self.font)
    fontSize(self.fontSize)
    strokeWidth(1)
    if self.selected then
        stroke(self.highlight)
        fill(self.highlight)
            h = self:height()
            self:roundRect(h/2)
            fill(255, 255, 255, 53)
            rect(self.left + h/2, self.top - 10, self:width() - h, 8)
        strokeWidth(1)
        stroke(76, 76, 76, 255)
        fill(227, 227, 227, 255)
        ellipse(self.right - h/2, self:midY(), self:height())
        fill(self.foreground)
        if #self.itemText > 0 then
            text(self.itemText[1], self:midX(), self:midY())
        end
    else
        fill(self.background)
        stroke(self.background)
        h = self:height()
        self:roundRect(h/2)
        fill(0, 0, 0, 18)
        rect(self.left + h, self.bottom + 2, self:width() - h*1.5, 8)
        strokeWidth(1)
        stroke(self.foreground)
        fill(self.background)
        ellipse(self.left + h/2, self:midY(), self:height())
        fill(self.foreground)
        if #self.itemText > 1 then
            text(self.itemText[2], self:midX(), self:midY())
        end
    end
    popStyle()
end

function Switch:touched(touch)
    if self:ptIn(touch.x, touch.y) then
        if touch.state == BEGAN then
            self.selected = not self.selected
        end
        return true
    else
        return false
    end
end

function Switch:initString()
    return "Switch('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end


--# TextBox
TextBox = class(Frame)

-- TextBox 
-- ver. 2.6
-- a control for basic string editing
-- ====================

-- 2.6 added CCActiveTextBox for managing text box selection
--     cosmetic improvements
--     improved keyboard handling

-- Improved TextBox by Twpster


CCActiveTextBox = nil

function TextBox:init(s, left, bottom, right, top)
    
    Frame.init(self, left, bottom, right, top)
    
    self.text = s
    self.font = "ArialMT"
    self.textAlign = LEFT
    self.fontSize = 14
    self.background = color(255, 255, 255, 255)
    self.foreground = color(20, 20, 20, 255)
    self.highlight = color(124, 142, 194, 255)
    self.blink = ElapsedTime
    self.blinkstate = true
    self.vLineSeparation = 2
    self.inset = 5
    self.scrollWidth = 25
    self.viewportStartingLine = 1

    self.scrolling = false
    self.keyPressed = false
    
    self.numberOfLines = 1
    self.pastNumberOfLines = 1
   
    self.lineNumber = 0
    self.lineTop = 0
    self.accumulator = ""
    self.textIndex = 0
    self.chunkIndex = 1
    
    self.xpositions = {}
    self.ypositions = {}
    self.lnumbers = {}
    self.widths = {}
    self.chunks = {}
    self.textTable = {}
    
    for Counter = 1, #self.text do
        table.insert(self.textTable, string.sub(self.text, Counter, Counter))
    end
    
    self.cursorXpos = 0
    self.cursorYtop = 0
    self.cursorYbottom = 0
    
    self.newlineChar = 10
    self.spaceChar = 32
    
    self.cursorIndex = #self.text
    
    -- Determine the number of lines that can be displayed in this TextBox
    
    local removeText = false
    
    if #self.text == 0 then
        removeText = true
        self.text = "Test"
    end
    
    w, h = textSize(self.text)
    self.lineHeight = h + self.vLineSeparation
    
    local rawDistance = self.top - self.bottom
    local actualDistance = rawDistance - (self.inset * 2)
    self.viewportLines = math.ceil(actualDistance / self.lineHeight) + 1
    
    if removeText then
        self.text = ""
    end
    
end


function TextBox:draw()
    
    local inset = 2
    
    pushStyle()
    pushMatrix()
    
    font(self.font)
    textMode(CORNER)
    textAlign(self.textAlign)
    fontSize(self.fontSize)
    
    noStroke()
    
    fill(self.foreground)
    self:offset(-1, 1)
    rect(self.left, self.bottom, self:width(), self:height())
    
    fill(self.background)
    self:offset(1, -1)
    rect(self.left, self.bottom, self:width(), self:height())
    
    fill(self.foreground)
    
    if self.scrolling then
    
        pushStyle()
        rectMode(CORNERS)
        
        -- Main rectangle
        
        fill(223, 213, 213, 255)
        
        rect(self.right, self.bottom, self.right+self.scrollWidth, self.top)
        
        -- Top scroll button
        
        fill(142, 161, 206, 255)
        
        rect(self.right, self.top-self.scrollWidth,
             self.right+self.scrollWidth, self.top)    
            
        -- Make the up arrow
        
        strokeWidth(3)
        stroke(0, 0, 0, 255)
        line(self.right + (.25 * self.scrollWidth),
             self.top + inset - (.5 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.top - inset)
                    
        line(self.right + (.5 * self.scrollWidth),
             self.top + inset - (.85 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.top - inset)
                
        line(self.right + self.scrollWidth - (.25 * self.scrollWidth),
             self.top + inset - (.5 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.top - inset)
        
        strokeWidth(1)             
                                                                                                                             
        -- Bottom scroll button
        
        rect(self.right, self.bottom,
             self.right+self.scrollWidth, self.bottom+self.scrollWidth)
            
        -- Make the down arrow
        
        strokeWidth(3)
        stroke(0, 0, 0, 255)
        line(self.right + (.25 * self.scrollWidth),
             self.bottom - inset + (.5 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.bottom + inset)
                    
        line(self.right + (.5 * self.scrollWidth),
             self.bottom - inset + (.85 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.bottom + inset)
                
        line(self.right + self.scrollWidth - (.25 * self.scrollWidth),
             self.bottom - inset + (.5 * self.scrollWidth),
             self.right + (.5 * self.scrollWidth),
             self.bottom + inset)
        
        strokeWidth(1)              
            
        -- Elevator indicator        
        
        fill(196, 164, 164, 255)
        
        if self.viewportStartingLine == 1 then
            self.indicatorBottom = self.top - self.scrollWidth
        else
        
            if self.viewportStartingLine == self.numberOfLines - self.viewportLines + 1 then
                self.indicatorBottom = self.bottom
            else
        
                local linesOutside = self.numberOfLines - self.viewportLines
        
                local verticalIncrement = ((self.top - self.bottom - (2 * self.scrollWidth)) 
                                             / linesOutside)
                                        
                local startVertical = self.bottom + self.scrollWidth
                                        
                local scrollPosition = linesOutside - self.viewportStartingLine
                
                self.indicatorBottom = startVertical + (scrollPosition * verticalIncrement)
                                        
            end
            
        end
        
        rect(self.right, self.indicatorBottom,
             self.right+self.scrollWidth, self.indicatorBottom+self.scrollWidth)
            
        popStyle() 
           
    end
    
    self:drawText()
    
    self:drawCursor()
    
    popMatrix()
    popStyle()
    
end

function TextBox:getText()
    return table.concat(self.textTable)
end

function TextBox:setText(theText)
    
    self.textTable = {}
    
    for Counter = 1, #theText do
        table.insert(self.textTable, string.sub(theText, Counter, Counter))
    
    end
    
    self.text = theText
      
end

function TextBox:chunkify(theText)
    
    local undecidedMode = 1
    local spaceMode = 2
    local nonSpaceMode = 3
    
    local theChar = ""
    local theCharValue = 0
    
    local theMode = undecidedMode
    
    self.chunks = {}
    self.chunkIndex = 1
      
    for Counter = 1, #theText do
        
        -- Get the current character
        
        theChar = string.sub(theText, Counter, Counter)
               
        -- Get the character code value of the current character
        
        theCharValue = string.byte(theText, Counter, Counter)
        
        if theCharValue == self.newlineChar then
                                       
            -- Current character is a new line character
                
            if theMode == spaceMode then
                    
                -- This is a return in space mode:
                -- Store space(s) as a chunk
                    
                theSpace = string.sub(theText, spaceIndex, Counter-1)
                self:addChunk(theSpace)
                
                -- Change the mode to undecided
                
                theMode = undecidedMode
                    
            else
                    
                if theMode == nonSpaceMode then
                        
                    -- This is a return in nonSpace mode:
                    -- Store nonSpace(s) as a chunk
                    
                    theNonSpace = string.sub(theText, nonSpaceIndex, Counter-1)
                    self:addChunk(theNonSpace)
                    
                    -- Change the mode to undecided
                
                    theMode = undecidedMode
                        
                else
                    
                    -- This is a return in undecided mode - do nothing here
                    
                end
                    
            end                
        
            -- Store return character as chunk
                
            self:addChunk(theChar)               
            
        else
            
            if theCharValue == self.spaceChar then
                                       
                -- Current character is a space
                
                if theMode == spaceMode then
                    
                    -- This is a space in space mode - do nothing
                    
                else
                    
                    if theMode == nonSpaceMode then
                        
                        -- This is a space in nonSpace mode:
                        -- Store nonSpace(s) as a chunk
                    
                        theNonSpace = string.sub(theText, nonSpaceIndex, Counter-1)
                        self:addChunk(theNonSpace)
                        
                        -- Set the space index and go to space mode
                        
                        spaceIndex = Counter
                        theMode = spaceMode
                        
                    else
                        
                        -- This is a space in undecided mode:
                        -- Set the space index and go to space mode
                        
                        spaceIndex = Counter
                        theMode = spaceMode
                        
                    end
                    
                 end
                
            else
                
                 -- Current character is a non-space character
                
                if theMode == spaceMode then
                    
                    -- This is a non-space in space mode:
                    -- Store space(s) as a chunk
                    
                    theSpace = string.sub(theText, spaceIndex, Counter-1)
                    self:addChunk(theSpace)
                
                    -- Change the mode to nonSpace
                    
                    nonSpaceIndex = Counter
                    theMode = nonSpaceMode
                    
                else
                    
                    if theMode == nonSpaceMode then
                        
                        -- This is a non-space in nonSpace mode - do nothing
                        
                    else
                        
                        -- This is a non-space in undecided mode:
                        -- Set the non-space index and go to nonSpace mode
                        
                        nonSpaceIndex = Counter
                        theMode = nonSpaceMode
                        
                    end
                    
                end
                
            end  
            
        end
        
    -- end the for loop
    
    end
    
    if theMode == nonSpaceMode then
                        
        -- Store nonSpace(s) as a chunk
                    
        theNonSpace = string.sub(theText, nonSpaceIndex)
        self:addChunk(theNonSpace)
        
    else
        
        if theMode == spaceMode then
                                        
            -- Store space(s) as a chunk
                    
            theSpace = string.sub(theText, spaceIndex)
            self:addChunk(theSpace)
            
        end
                      
    end
                        
end

function TextBox:addChunk(theChunk)
        
    numberOfChars = self:getNumberOfChars(theChunk)
    
    if numberOfChars == #theChunk then
        
        -- Chunk fits on a line
        
        self.chunks[self.chunkIndex] = theChunk
        self.chunkIndex = self.chunkIndex + 1
        
    else
        
        -- Chunk doesn't fit on a line
        -- Break off a line size chunk
        
        self.chunks[self.chunkIndex] = string.sub(theChunk, 1, numberOfChars)
        self.chunkIndex = self.chunkIndex + 1
        
        theRemaining = string.sub(theChunk, numberOfChars+1)
        
        -- Recursive call with the remaining
        
        self:addChunk(theRemaining)
        
    end 
    
end

function TextBox:drawText()
    
    self.lineNumber = 1
    self.textIndex = 1
    self.accumulator = ""
    
    local currentLine = ""    
    local theChunk = ""
    local theCharValue = 0
    
    self.xpositions = {}
    self.ypositions = {}
    self.widths = {}
    
    -- Build the chunk array using text
    
    self:chunkify(self.text)
    
    -- Draw lines with the chunks
    
    for Counter, Chunk in ipairs(self.chunks) do
        
        -- Get the current chunk
        
        theCharValue = string.byte(Chunk, 1, 1)
        
        if theCharValue == self.newlineChar then
                                       
            -- Current chunk is a new line character
            
            if #self.accumulator > 0 then
                self:drawLine()
            end
            
            self.accumulator = self.accumulator .. Chunk            
            self.lineNumber = self.lineNumber + 1             
            self:drawLine()                                             
            
        else
        
            currentLine = self.accumulator .. Chunk
            
            if textSize(currentLine) >= self:width() - (2 * self.inset) then
                    
                -- Chunk won't fit 
                 
                self:drawLine()  
                self.lineNumber = self.lineNumber + 1 
                
            end
            
            self.accumulator = self.accumulator .. Chunk                       
            
        end
        
    end        
    
    if #self.accumulator > 0 then
        self:drawLine()
    end
    
    self.numberOfLines = self.lineNumber
    
    -- Turn scrolling on
    
    if not self.scrolling then
        if self.numberOfLines > self.viewportLines then
           self.scrolling = true
        end
    end  
    
    -- Turn scrolling off
    
    if self.scrolling then
        if self.numberOfLines <= self.viewportLines then
            self.viewportStartingLine = 1
            self.scrolling = false
        end
    end 
    
    -- Scroll up or down if out of viewport
     
    if self.scrolling then
        
        if self.keyPressed then
            
            if self.pastNumberOfLines < self.numberOfLines then
                
                -- With this character we just added a line
                -- Scroll down one line
 
                self.viewportStartingLine = self.viewportStartingLine + 1
                
            else
                
                if self.pastNumberOfLines > self.numberOfLines then
                
                    -- With this character we just removed a line
                    -- Scroll up one line
 
                    self.viewportStartingLine = self.viewportStartingLine - 1
        
                end
                
            end
            
            self.keyPressed = false
            
        end
        
    end  
    
end

function TextBox:getNumberOfChars(theText)
    
    local widths = self:getCharWidths(theText)
    
    local numberOfChars = 1
    local totalWidth = 0
    
    while numberOfChars < #theText do
        
        totalWidth = totalWidth + widths[numberOfChars]
        
        if totalWidth >= self:width() - (2 * self.inset) then
            return numberOfChars
        end
        
        numberOfChars = numberOfChars + 1
        
    end
    
    return numberOfChars
    
end

function TextBox:getCharWidths(theText)
    
    local theChar = ""
    local theCharValue = 0
    
    local widths = {}
    
    local width = 0
    local height = 0
    
    for Counter = 1, #theText do    
        
        -- Get the current character
        
        theChar = string.sub(theText, Counter, Counter)
        
        -- Get the character code value of the current character 
        
        theCharValue = string.byte(theText, Counter, Counter)           
        
        if theCharValue == self.newlineChar then
                                       
            -- Current character is a new line character
        
            widths[Counter] = 0        
            
        else
        
            -- Determine the width of the character
        
            width, height = textSize(theChar)
        
            widths[Counter] = width - (width * 0.036)
            
        end
        
    end
    
    return widths 
    
end
 
function TextBox:drawCursor()
    
    local xpos = self.xpositions[self.cursorIndex]
    local ypos = self.ypositions[self.cursorIndex]
    
    local viewLineNumber = 1
    local emptyText = false
    
    if not ypos then
        
        self.cursorYbottom = self.top - self.inset - self.lineHeight
        self.cursorXpos = self.left + self.inset
        emptyText = true
        
    else
        
        self.cursorXpos = xpos
        self.cursorYbottom = ypos
        viewLineNumber = self.lnumbers[self.cursorIndex] - self.viewportStartingLine + 1
            
    end     
    
    local topValue = (viewLineNumber - 1) * self.lineHeight
    
    self.cursorYtop = self.top - self.inset - topValue
    
    if self == CCActiveTextBox then
        if self.blink < ElapsedTime - 0.3 then
            self.blink = ElapsedTime
            self.blinkstate = not self.blinkstate
        end
        if self.blinkstate then
            strokeWidth(3)
            stroke(self.highlight) 
            
            if emptyText then
                line(self.cursorXpos, self.cursorYbottom, self.cursorXpos, self.cursorYtop)
                return
            end
                
            if self.lnumbers[self.cursorIndex] >= self.viewportStartingLine and
            self.lnumbers[self.cursorIndex] < self.viewportStartingLine+self.viewportLines then
                 
                line(self.cursorXpos, self.cursorYbottom, self.cursorXpos, self.cursorYtop)
                
            end
        end
    end
    
end

function TextBox:drawLine()
            
    -- Draw what's in acumulator on the current line
      
    w, h = textSize(self.accumulator)
    
    self.lineHeight = h + self.vLineSeparation
    
    local viewLineNumber = self.lineNumber - self.viewportStartingLine + 1
    
    local topValue = (viewLineNumber - 1) * self.lineHeight
    self.lineTop = self.top - self.inset - topValue
  
    if self.lineNumber >= self.viewportStartingLine and
        self.lineNumber < self.viewportStartingLine+self.viewportLines then
        text(self.accumulator, self.left + self.inset, self.lineTop - h)
    end
         
    local xpos = self.left + self.inset
    local ypos = self.lineTop - h
    
    -- Get the character widths for this accumulator
    -- Add it to the widths table
    
    local widths = self:getCharWidths(self.accumulator)
    
    -- Use the widths to determine the cursor positions for each character
    
    for Counter = 1, #self.accumulator do
        
        self.widths[self.textIndex] = widths[Counter]
        
        xpos = xpos + self.widths[self.textIndex]
        
        self.xpositions[self.textIndex] = xpos       
        self.ypositions[self.textIndex] = ypos
        self.lnumbers[self.textIndex] = self.lineNumber
        
        self.textIndex = self.textIndex + 1
        
    end 

    self.accumulator = ""
    
end

function TextBox:acceptKey(k)
    
    self.pastNumberOfLines = self.numberOfLines
    self.keyPressed = true
    
    if k ~= nil then
        
        if string.byte(k) == nil then
            
            if string.len(self.text) > 0 then
                            
                table.remove(self.textTable, self.cursorIndex)
                self.text = self:getText()
                self.cursorIndex = self.cursorIndex - 1
                
            end
            
        else
            table.insert(self.textTable, self.cursorIndex+1, k)
            self.text = self:getText()
            self.cursorIndex = self.cursorIndex + 1
        end
    end
    
end

function TextBox:initString()
    return "TextBox('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end

function TextBox:touched(touch)
    
    if self:ptInScrollUp(touch.x, touch.y) and touch.state ~= ENDED and self.scrolling then
        if self.viewportStartingLine > 1 then
            self.viewportStartingLine = self.viewportStartingLine - 1
        end
    end
    
    if self:ptInScrollDown(touch.x, touch.y) and touch.state ~= ENDED and self.scrolling then
        if self.viewportStartingLine < self.numberOfLines - self.viewportLines + 1 then
            self.viewportStartingLine = self.viewportStartingLine + 1
        end
    end
    
    if self:ptIn(touch.x, touch.y) then
        CCActiveTextBox = self
        self:findCursorIndex(touch)
        if not isKeyboardShowing() then showKeyboard() end
        return true
    else
        return false
    end
end

function TextBox:findCursorIndex(touch)
    
    local minimumIndex = 0
    
    local totalDiff = 0
    local xDiff = 0
    local yDiff = 0
    
    if #self.text == 0 then
        return 0
    end
    
    local xpos = self.left + self.inset  
    local ypos = self.ypositions[1] + (self.lineHeight * 0.5)
    
    xDiff = touch.x - xpos
    yDiff = touch.y - ypos
    
    local minimumDiff = math.abs(xDiff) + math.abs(yDiff)
               
    for I, Xpos in ipairs(self.xpositions) do              
            
        ypos = self.ypositions[I] + (self.lineHeight * 0.5)            

        xDiff = touch.x - Xpos
        yDiff = touch.y - (self.ypositions[I] + (self.lineHeight * 0.5))
        totalDiff = math.abs(xDiff) + math.abs(yDiff)
        
        if minimumDiff > totalDiff then
            minimumDiff = totalDiff
            minimumIndex = I
        end               
        
    end
    
    self.cursorIndex = minimumIndex
    
end

function TextBox:ptInScrollUp(x, y)
    
    if x >= self.right and x <= self.right+self.scrollWidth then
        if y >= self.top-self.scrollWidth and y <= self.top then            
            return true
        end
    end
    
    return false
    
end

function TextBox:ptInScrollDown(x, y)
    
    if x >= self.right and x <= self.right+self.scrollWidth then
        if y >= self.bottom and y <= self.bottom+self.scrollWidth then            
            return true
        end
    end
    
    return false
    
end
    
--# TextButton
TextButton = class(Frame)

-- TextButton 
-- ver. 1.6
-- a control for displaying a simple button
-- ====================

-- 1.6    cosmetic changes

function TextButton:init(s, left, bottom, right, top)
    Frame.init(self, left, bottom, right, top)
    self.text = s
    self.font = "ArialMT"
    self.fontSize = 14
    self.itemText = {}
    self.background = color(0, 0, 0, 255)
    self.foreground = color(253, 253, 253, 255)
    self.highlight = color(123, 183, 197, 255)
    self.status = false
end

function TextButton:draw()
    pushStyle()
    font(self.font)
    fontSize(self.fontSize)
    if not self.status then
        stroke(self.background)
        fill(self.background)
        self:roundRect(5)
        self:offset(-4, 4)
        stroke(self.foreground)
        fill(self.foreground)
        self:roundRect(5)
        self:offset(2, -2)
        stroke(self.highlight)
        fill(self.highlight)
        self:roundRect(5)
        self:offset(2, -2)
        fill(255, 255, 255, 33)
        rect(self.left + 12, self.top - 12, 
             self:width()- 24, 8)
        fill(0, 0, 0, 36)
        rect(self.left + 12, self.bottom + 4, 
             self:width()- 24, 4)
        fill(self.background)
        text(self.text, self:midX(), self:midY() + 2)
    else
        stroke(self.foreground)
        fill(self.foreground)
        self:roundRect(5)
        self:offset(-4, 4)
        stroke(self.background)
        fill(self.background)
        self:roundRect(5)
        self:offset(2, -2)
        stroke(self.highlight)
        fill(self.highlight)
        self:roundRect(5)
        self:offset(2, -2)
        fill(255, 255, 255, 33)
        rect(self.left + 12, self.top - 12, 
             self:width()- 24, 8)
        fill(0, 0, 0, 36)
        rect(self.left + 12, self.bottom + 4, 
             self:width()- 24, 4)
        fill(self.background)
        text(self.text, self:midX() -2, self:midY() + 4)
    end
    popStyle()
end

function TextButton:touched(touch)
    if self:ptIn(touch.x, touch.y) and touch.state ~= ENDED then
        self.status = true
        return true
    else
        self.status = false
        return false
    end
end

function TextButton:initString()
    return "TextButton('"..self.text.."', " .. 
        self.left..", "..self.bottom..", "..
        self.right..", "..self.top..")"
end


--# Ttouch
Ttouch = class()

-- Translatable Touch 
-- ver. 1.0
-- maps fields of a touch but is easily modified.
-- ====================.

function Ttouch:init(touch)
    self.x = touch.x
    self.y = touch.y
    self.state = touch.state
    self.prevX = touch.prevX
    self.prevY = touch.prevY
    self.deltaX = touch.deltaX
    self.deltaY = touch.deltaY
    self.id = touch.id
    self.tapCount = touch.tapCount
    self.timer = 0
end

function Ttouch:translate(x, y)
    self.x = self.x - x
    self.y = self.y - y
end

-- ChickenScratches

-- displayMode(FULLSCREEN)
minSize = 30

-- Use this function to perform your initial setup
function setup()
    -- ===================
-- Copy into the init function
-- ===================

textBoxLeft = 440
textBoxTop = 600

textBox2Left = 440
textBox2Top = 480

LabelTop = 600

-- left bottom right top

label1001 = Label('Description', 440, 480, 560, 510)
textBox1002 = TextBox('', 440, textBox2Top-100, 570, textBox2Top)
button1007 = TextButton('Set Text', 440, 220, 570, 250)

label1008 = Label('Chicken Scratches', 440, 580, 560, 610)
label1008.fontSize = 35
end

-- This function gets called once every frame
function draw()

    -- This sets a dark background color 
    background(90, 124, 156, 255)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    
    -- ===================
    -- Copy into the draw function
    -- ===================
    label1001:draw()
    textBox1002:draw()
    button1007:draw()
    label1008:draw()
   
    
end

function touched(touch)
    
 -- ===================
-- Copy into the touched function
-- ===================

textBox1002:touched(touch)

if (button1007:touched(touch)) then
    
    -- print("The text is [" .. textBox1002.text .."]")
    -- print("Length of text is " .. textSize(textBox1002.text))
    
    -- textBox1002:chunkify(textBox1002.text)
    
    -- for I, Chunk in ipairs(textBox1002.chunks) do
    --     print(I .. " is chunk [" .. Chunk .. "]")
    -- end
    
    -- for I, Width in ipairs(textBox1002.widths) do
    --     print(I .. " is width " .. Width)
    -- end
    
    -- for I, Xpos in ipairs(textBox1002.xpositions) do
    --     print(I .. " is xpos " .. Xpos)
    -- end
    
    -- for I, Ypos in ipairs(textBox1002.ypositions) do
    --     print(I .. " is ypos " .. Ypos)
    -- end
    
    -- print("here is get text:  " .. textBox1002:getText())
    -- print(textBox1002.maxLines)
    
    textBox1002:setText("For God so loved the world that He gave His only Son so that all")
    
end

end

-- ===================
-- Copy into main, or modify your
-- existing keyboard function
-- ===================
  
function keyboard(key)
    if CCActiveTextBox then
       CCActiveTextBox:acceptKey(key)
    end
end

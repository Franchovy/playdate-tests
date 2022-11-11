import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local playerSprite = nil

local function initialize()
    local playerImage = gfx.image.new("images/player")
    playerSprite = gfx.sprite.new(playerImage)
    playerSprite:moveTo(200, 120)
    playerSprite:add()

    local backgroundImage = gfx.image.new("images/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0, 0)
            gfx.clearClipRect()
        end
    )
end

initialize()

function playdate.update()
    -- Main loop for the game
    --gfx.clear()
    --gfx.drawText("Hello World", 20, 20)
    gfx.sprite.update()
end

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "coin"

-- Libraries
local gfx <const> = playdate.graphics

-- Constants
local playerSpeed = 4

-- Sprites
local playerSprite = nil

local floorSprite = nil

-- Game Timer
local playTimer = nil
local playTime = 30 * 1000

-- Score tracker
local score = 0
local scorePerCoin = 10

local coin = Coin()

-- Game Reset Functions
local function resetTimer()
    playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

-- Game initialization method
local function initialize()
    -- Update random seed
    math.randomseed(playdate.getSecondsSinceEpoch())

    -- Create player sprite
    local playerImage = gfx.image.new("images/player")
    playerSprite = gfx.sprite.new(playerImage)
    playerSprite:moveTo(200, 120)
    playerSprite:setCollideRect(0, 0, playerSprite:getSize())
    playerSprite.collisionResponse = function(_, other)
        if other == coin.sprite then
            return gfx.sprite.kCollisionTypeOverlap
        end
        return gfx.sprite.kCollisionTypeFreeze
    end
    playerSprite:add()

    -- Create coin sprite
    coin:create()

    -- Create floor sprite
    local floorImage = gfx.image.new(400, 20)
    -- PUSH CONTEXT
    gfx.pushContext(floorImage)
    gfx.fillRect(0, 0, floorImage:getSize())
    gfx.popContext()
    -- Create floor sprite
    floorSprite = gfx.sprite.new(floorImage)
    floorSprite:setCollideRect(0, 0, floorSprite:getSize())
    floorSprite:moveTo(200, 230)
    floorSprite:add()


    -- Setup background
    local backgroundImage = gfx.image.new("images/background")
    -- Background drawing callback - draws background behind sprites
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0, 0)
            gfx.clearClipRect()
        end
    )

    -- Initialize timer
    resetTimer()
end

-- Run initialize method
initialize()

local gravityAcceleration = 3.5
local currentVerticalSpeed = 0
local playerInitialJumpSpeed = 15
local hasJumped = false

-- Main game loop
function playdate.update()

    -- Check if game is finished
    if playTimer.value == 0 then
        -- Allow game reset (Press A)
        if playdate.buttonIsPressed(playdate.kButtonA) then
            resetTimer()
            coin:move()
            score = 0
        end

        return
    end


    -- Check if player is touching coin
    if coin:getIsTouching(playerSprite) then
        coin:move()
        score += scorePerCoin
    end

    -- Key press detection for player movement
    hasJumped = playdate.buttonIsPressed(playdate.kButtonA)

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        playerSprite:moveBy(-playerSpeed, 0)
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        playerSprite:moveBy(playerSpeed, 0)
    end

    -- Detect if sprite is currently touching floor
    local isTouchingFloor = playerSprite.y + playerSprite.height >= floorSprite.y - 1

    -- Adapt vertical speed to whether sprite is jumping or touching floor
    if isTouchingFloor then
        if hasJumped then
            currentVerticalSpeed = -playerInitialJumpSpeed
        else
            currentVerticalSpeed = 0
        end
    elseif not hasJumped then
        currentVerticalSpeed += gravityAcceleration
    end

    -- Move sprite using adapted speed
    local actualX, actualY, _, _ = playerSprite:moveWithCollisions(
        playerSprite.x,
        playerSprite.y + currentVerticalSpeed
    )
    playerSprite:moveTo(actualX, actualY)


    --Update methods

    playdate.timer.updateTimers()

    gfx.sprite.update()

    -- Redraw updated Text on screen
    gfx.drawText("Time: " .. math.ceil(playTimer.value / 1000), 5, 5)
    gfx.drawTextAligned("Score: " .. score, 395, 5, kTextAlignment.right)
end

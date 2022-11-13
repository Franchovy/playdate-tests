import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries
local gfx <const> = playdate.graphics

-- Constants
local playerSpeed = 4

-- Sprites
local playerSprite = nil
local coinSprite = nil
local floorSprite = nil

-- Game Timer
local playTimer = nil
local playTime = 30 * 1000

-- Score tracker
local score = 0
local scorePerCoin = 10

-- Game Reset Functions
local function resetTimer()
    playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function moveCoin()
    local randX = math.random(40, 360)
    local randY = math.random(40, 160)
    coinSprite:moveTo(randX, randY)
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
    playerSprite:add()

    -- Create coin sprite
    local coinImage = gfx.image.new("images/coin")
    coinSprite = gfx.sprite.new(coinImage)
    coinSprite:setCollideRect(0, 0, coinSprite:getSize())
    coinSprite:add()
    moveCoin()


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
            moveCoin()
            score = 0
        end

        return
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


    -- Basic collision detection by returning list of overlapping sprites
    local collisions = coinSprite:overlappingSprites()
    if #collisions >= 1 then
        moveCoin()
        score += scorePerCoin
    end

    --Update methods

    playdate.timer.updateTimers()

    gfx.sprite.update()

    -- Redraw updated Text on screen
    gfx.drawText("Time: " .. math.ceil(playTimer.value / 1000), 5, 5)
    gfx.drawTextAligned("Score: " .. score, 395, 5, kTextAlignment.right)
end

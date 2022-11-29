import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

local coinSprite = nil


class('Coin', { sprite = nil }).extends()

function Coin:move()
    local randX = math.random(40, 360)
    local randY = math.random(40, 160)
    coinSprite:moveTo(randX, randY)
end

function Coin:create()
    local coinImage = gfx.image.new("images/coin")
    coinSprite = gfx.sprite.new(coinImage)
    coinSprite:setCollideRect(0, 0, coinSprite:getSize())
    coinSprite:add()
    self:move()

    self.sprite = coinSprite
end

function Coin:getIsTouching(sprite)
    local collisions = sprite:overlappingSprites()
    for _, v in ipairs(collisions) do
        if v == coinSprite then
            return true
        end
    end

    return false
end

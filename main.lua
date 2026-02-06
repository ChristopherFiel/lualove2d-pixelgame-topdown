function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sti = require 'libraries/sti'
    gameMap = sti('maps/test-map.lua')

    camera = require 'libraries/camera'
    cam = camera()

    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 0)

    player = {}
    player.collider = world:newBSGRectangleCollider(200, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 200
    player.y = 100
    player.speed = 300
    player.sprite = love.graphics.newImage('sprites/parrot.png')
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.down

    background = love.graphics.newImage('sprites/background.png')

    sounds = {}
    sounds.blip = love.audio.newSource('sounds/blip.wav', 'static')
    sounds.music = love.audio.newSource('sounds/music.mp3', 'stream')
    sounds.music:setLooping(true)

    treesCollider = {}
    if gameMap.layers["trees-collider"] then
        for i, obj in pairs(gameMap.layers["trees-collider"].objects) do
            local trees = world:newRectangleCollider(
                obj.x,
                obj.y,
                obj.width,
                obj.height
            )
            trees:setType("static")
            table.insert(treesCollider, trees)
        end
    end

    sounds.music:play()
end

function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0
    
    if love.keyboard.isDown("right")then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("left")then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end
    
    if love.keyboard.isDown("down")then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("up")then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()


    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight


    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
        gameMap:drawLayer(gameMap.layers['trees'])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
        -- world:draw()
    cam:detach()

    love.graphics.print("Hello World!", 10, 10)
end

function love.keypressed (key)
    if key == 'space' then
        sounds.blip:play()
    end

    if key == 'z' then
        sounds.music:stop()
    end

    if key == 'p' then
        sounds.music:play()
    end
end
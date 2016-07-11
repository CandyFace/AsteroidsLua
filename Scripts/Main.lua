--[[ Thee who read this code, 
shall be on his own, for truly there is no help to be given, 
nor is there any explanation for those who should be lost or confused.

An Asteroids clone made using PolyCode by CandyFace / Oliver Larsen - 2016 --]]

require "Scripts/Player"
require "Scripts/UI"
require "Scripts/Asteroid"
require "Scripts/Ammo"
require "Scripts/Debris"

-- worldScale, posIterations
scene = PhysicsScene2D(1.0, 60)
scene:setGravity(Vector2(0.0, 0.0))

-- sets the orthographic camera resolution
-- this is not the actual window resolution
resX = Services.Core:getScreenWidth()
resY = Services.Core:getScreenHeight()

--Initialize custom font
Services.FontManager:registerFont("Walkway", "Typefaces/Walkway_SemiBold.ttf")
								--			 640|		              480|
Services.Core:setVideoMode(Services.Core:getXRes(), Services.Core:getYRes(), false, true, 0, 0, false)
scene:getDefaultCamera():setOrthoSize(resX, resY)
level = SceneEntityInstance(scene, "Entities/level.entity")

-- makes level entity child of scene
scene:addChild(level)

-- Globals
isPressed = true
reloadAsteroids = false
maxBulletAliveTime = 3
bulletIndex = 1
debriPieces = 8
debriAngle = 0
debriTimer = 0
amountOfAsteroids = 4
newGame = true
gameOver = false

--Tables
debris = {}
asteroids = {}
bullet = {}

function Init()
	player = Player(scene)
	ui = UI()
	
	--Initializes 4 bullets on the screen
	for i = 1, 4 do
		bullet[i] = Ammo(scene)
		bullets = bullet[i]
	end
	
	for i = 1, debriPieces do
		debris[i] = Debris()
		totalDebris = debris[i]
	end
	
	-- initialize each asteroids in table as Asteroid constructor
	for i = 1, amountOfAsteroids do
		asteroids[i] = Asteroid(scene)
		totalAsteroids = asteroids[i]
	end

	gameLabel.visible = false
	descLabel.visible = false
	newGame = false
	gameOverTimer = 0
	finishScore = 3680
	waveTimer = 0
end

function Update(dt)
	if not newGame then
		player:Update(dt)
		ui:Update(dt)
		player:shield(dt)
		player:UpdatePlayerLife(player:getPlayerLife())
		player:UpdateExplosion()
	
		if reloadAsteroids then
			for i = 1, amountOfAsteroids do
				asteroids[i]:setAsteroidSize(7)
				asteroids[i]:setRandomPos(true)
				asteroids[i].asteroid.hit = false
				asteroids[i].asteroid:setPosition(random(Services.Core:getXRes()),random(Services.Core:getYRes()),0)
			end
			reloadAsteroids = false
		end
	
		if respawned then
			respawnTimer = respawnTimer + 1*dt
			player.hit = true
			player:Respawn()
		end
	
		--The score determines whether a wave has been completed
		if player:getPlayerScore() == finishScore then
			waveTimer = waveTimer + 1*dt
			if waveTimer >= 3 then
				waveTimer = 0
				finishScore = finishScore + 3680
				reloadAsteroids = true
			end
		end
	
		--Update debris
		for i = 1, count(debris) do
			debris[i]:UpdateDebris()
			debriTimer = debriTimer + 1 *dt
			if debris[i].alive then
				if debriTimer > 1 then
					--debris[i].debriMesh.enabled = false
					debris[i].alive = false
					debriTimer = 0
				end
			elseif  debriTimer > 3 then
				debris[i].debriMesh:setPositionX(10000)
			end
		end
	
		-- Count time as long as life is above 0
		if player.life > 0 then
			player.survivalTimer = player.survivalTimer + 1*dt
		end
	
		for index, object in pairs(asteroids) do
			if not object.asteroid.hit then
				object.asteroid:Roll(object.asteroid.rndRotVal * dt)
				object.asteroid:setPositionX(object.asteroid:getPosition().x + cos(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
				object.asteroid:setPositionY(object.asteroid:getPosition().y + sin(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
				if player.life > 0 then
					stayWithinBoundary(object.asteroid)
					if not player.shieldOn then
						if circleIntersection(player:getPlayer():getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize) then
							player:Explode(dt)
							player:takeDamage(dt)
							totalDebris:Spread(object)
							totalAsteroids:Split(object)
						end	
					end
		
					for i = 1, count(debris) do
						if circleIntersection(debris[i].debriMesh:getPosition2D(),player:getPlayer():getPosition2D(),20) then
							player:Explode(dt)
							player:takeDamage()
						end
					end
		
					for i = 1, count(bullet) do
						if circleIntersection(object.asteroid:getPosition2D(), bullet[i].shot:getPosition2D(), object.asteroid.colSize) then
							totalDebris:Spread(object)
							totalAsteroids:Split(object)
							bullet[i].shot:setPositionX(10000000)
							bullet[i].alive = false
							player.shotFired = false
							bullet[i].canShoot = true
							bulletIndex = 1
							bullet[i].timer = 0
						end
					end
				end
			end
		end
	
		--Update bullets when a shot has been fired
		for index, object in pairs(bullet) do
			object.timer = object.timer + 1*dt
			if player.shotFired then 
				if bulletIndex <= table.getn(bullet) then
					if object.canShoot then
						object.canShoot = false
						player:FireBullet(dt, object)
						player.shotFired = false
						object.timer = 0
					end
					bulletIndex = bulletIndex + 1
				end
			end
		object:UpdateBullet(dt)
		end
	
		--Update bullets when timer has passed x seconds
		for i = 1, count(bullet) do
			if bullet[i].timer >= maxBulletAliveTime then
				bullet[i].alive = false
				bullet[i].shot:setPosition(100000,100000,0)
				bullet[i].timer = maxBulletAliveTime
				bullet[i].canShoot = true
				player.shotFired = false
				bulletIndex = 1
			end
		end 
	end
end

-- function Split(object)
-- 	object.asteroid.explosion:Play()
-- 	object.asteroid.hit = true
-- 	object:setRandomPos(false)
-- 	player:setPlayerScore(player:getPlayerScore() + object.asteroid.point)
-- 	newPos = Vector2(object.asteroid:getPosition().x, object.asteroid:getPosition().y)
-- 	object.asteroid:setPositionX(100000000)
-- 	if object.asteroid.size >= object.asteroid.mediumASize then
-- 		object:setAsteroidSize(object.asteroid.size - 2)
-- 	end
	
-- 	if object.asteroid.size > object.asteroid.mediumASize then
-- 		object:setPositionXY(newPos.x, newPos.y)
-- 		object.astShape = random(1,4)
-- 		for i = 1, object.asteroid.canSplit do
-- 				table.insert(asteroids, Asteroid(scene))
-- 		end
-- 		object:setSplitSize(object.asteroid.split + 1)
-- 	end
-- end

-- function Debris(object, debriTarget)
-- 	for i = 1, count(debriTarget) do
-- 		debriTarget[i].position = Vector2(cos(degToRad(debriTarget[i].direction + debriAngle)) * 1.15, sin(degToRad(debriTarget[i].direction + debriAngle)) * 1.15)
-- 		debriTarget[i].velocity = Vector2(cos(degToRad(debriTarget[i].direction + debriAngle)) * debriTarget[i].debriSpeed, sin(degToRad(debriTarget[i].direction + debriAngle)) * debriTarget[i].debriSpeed)
-- 		debriAngle = debriAngle + 45
-- 		debriTarget[i].alive = true
-- 		debriTarget[i]:Fire(Vector2(debriTarget[i].position.x + object.asteroid:getPosition().x, debriTarget[i].position.y + object.asteroid:getPosition().y),
-- 		Vector2(debriTarget[i].velocity.x + 0, debriTarget[i].velocity.y + 0), 0)
-- 	end
-- end

function onKeyDown(key)
	if not newGame then
		if player.life > 0 and respawned == false then
			if key == KEY_x and isPressed then
				isPressed = false
				player.shotFired = true
			end
		end
	
	-- if key == KEY_TAB then
	-- 	debuggingSwitch = toggleDebugger(debuggingSwitch)
	-- end

	end

	if key == KEY_ESCAPE then
		Services.Core:Shutdown()
	end

	if key == KEY_SPACE and newGame then
		Init()
	end
end

function onKeyUp(key)
	isPressed = true
	if key == KEY_UP then
		player.thrustSound:Stop()
	end
end

function stayWithinBoundary(object)
	if object:getPosition().y < -Services.Core:getYRes() then
		object:setPositionY(Services.Core:getYRes())
	end

	if object:getPosition().y > Services.Core:getYRes() then
		object:setPositionY(-Services.Core:getYRes())
	end

	if object:getPosition().x >  Services.Core:getXRes() then
		object:setPositionX(- Services.Core:getXRes())
	end

	if object:getPosition().x < -Services.Core:getXRes() then
		object:setPositionX(Services.Core:getXRes())
	end
end

-- UI Setup --
scoreLabel = SceneLabel("", 80, "Walkway", Label.ANTIALIAS_STRONG, 0)
scene:addChild(scoreLabel)

timerLabel = SceneLabel("", 80, "Walkway", Label.ANTIALIAS_STRONG, 0)
scene:addChild(timerLabel)

gameOverLabel = SceneLabel("GAME OVER!", 80, "Walkway", Label.ANTIALIAS_STRONG,0)
gameLabel = SceneLabel("ASTEROIDS!", 160, "Walkway", Label.ANTIALIAS_STRONG,0)
descLabel = SceneLabel("Press SPACE to start!", 40, "Walkway", Label.ANTIALIAS_STRONG,0)
gameOverLabel.visible = false
gameLabel.visible = true
descLabel.visible = true
scene:addChild(gameOverLabel)
scene:addChild(gameLabel)
scene:addChild(descLabel)

descLabel:setPositionY(-Services.Core:getYRes() + 200)
scoreLabel:setPositionX(-Services.Core:getXRes() + 200)
scoreLabel:setPositionY(Services.Core:getYRes() - 100)
timerLabel:setPositionY(Services.Core:getYRes() - 100)

--	Debugging --
-- posYLabel = cast(level:getEntityById("posY", true), SceneLabel)
-- posXLabel = cast(level:getEntityById("posX", true), SceneLabel)
-- speedLabel = cast(level:getEntityById("speed", true), SceneLabel)
-- velXLabel = cast(level:getEntityById("velX", true), SceneLabel)
-- velYLabel = cast(level:getEntityById("velY", true), SceneLabel)

-- posXLabel:setPositionX(-Services.Core:getXRes() + 140)
-- posXLabel:setPositionY(Services.Core:getYRes() - 60)
-- posYLabel:setPositionX(-Services.Core:getXRes() + 140)
-- posYLabel:setPositionY(Services.Core:getYRes() - 100)
-- speedLabel:setPositionX(-Services.Core:getXRes() + 140)
-- speedLabel:setPositionY(Services.Core:getYRes() - 140)
-- velXLabel:setPositionX(-Services.Core:getXRes() + 140)
-- velXLabel:setPositionY(Services.Core:getYRes() - 180)
-- velYLabel:setPositionX(-Services.Core:getXRes() + 140)
-- velYLabel:setPositionY(Services.Core:getYRes() - 220)
--	END 	--

function degToRad(degrees)
	return degrees * math.pi/180
end

--TODO: Make line intersection algorithm
function circleIntersection(target, shooter, targetRadius)
	_checkX = target.x - shooter.x
	_checkY = target.y - shooter.y

	_rad = targetRadius

	if ((_checkX * _checkX) + (_checkY * _checkY) <= _rad * _rad) then
		return true
	else
		return false
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
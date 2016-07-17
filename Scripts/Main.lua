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
scene = Scene(Scene.SCENE_2D)

-- sets the orthographic camera resolution
-- this is not the actual window resolution
resX = Services.Core:getScreenWidth()
resY = Services.Core:getScreenHeight()

--Initialize custom font
Services.FontManager:registerFont("Walkway", "Typefaces/Walkway_SemiBold.ttf")
								--			 640|		              480|
Services.Core:setVideoMode(Services.Core:getXRes(), Services.Core:getYRes(), false, true, 0, 0, false)
Services.ResourceManager:addArchive("hdr.pak")
Services.ResourceManager:addDirResource("hdr", true)
scene:getDefaultCamera():setPostFilterByName("HDRProcessBloom")

scene:getDefaultCamera():getLocalShaderOptions()[1]:addParam(ProgramParam.PARAM_NUMBER, "brightThreshold"):setNumber(0.40)
scene:getDefaultCamera():getLocalShaderOptions()[2]:addParam(ProgramParam.PARAM_NUMBER, "blurSize"):setNumber(0.002)
scene:getDefaultCamera():getLocalShaderOptions()[3]:addParam(ProgramParam.PARAM_NUMBER, "blurSize"):setNumber(0.002)
scene:getDefaultCamera():getLocalShaderOptions()[4]:addParam(ProgramParam.PARAM_NUMBER, "bloomFactor"):setNumber(1.5)
scene:getDefaultCamera():getLocalShaderOptions()[4]:addParam(ProgramParam.PARAM_NUMBER, "exposure"):setNumber(0)
--print(scene:getDefaultCamera():getLocalShaderOptions()[1])	
--print(scene:getDefaultCamera():hasFilterShader())

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
coinTimer = 0
totalCoins = 0

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
	scoreLabel.visible = true
	timerLabel.visible = true
	coinLabel.visible = false
	creditLabel.visible = false
	newGame = false
	gameOverTimer = 0
	finishScore = 3680
	waveTimer = 0
	totalCoins = totalCoins - 1
end

function Update(dt)

	if totalCoins < 1 and newGame then
		coinTimer = coinTimer + 1 *dt
		if round(coinTimer,0) % 2 == 0 then
			coinLabel.visible = true
		else
			coinLabel.visible = false
		end
	end

	if not newGame then
		player:Update(dt)
		ui:Update(dt)
	
		if reloadAsteroids then
			for i = 1, amountOfAsteroids do
				asteroids[i]:setAsteroidSize(7)
				--asteroids[i]:setRandomPos(true)
				asteroids[i].asteroid.hit = false
				asteroids[i].asteroid:setPosition(random(Services.Core:getXRes()),random(Services.Core:getYRes()),0)
			end
			reloadAsteroids = false
		end
	
		if player.respawned then
			player.respawnTimer = player.respawnTimer + 1*dt
			player.hit = true
			player:Respawn()
		end
	
		--The score determines whether a wave has been completed
		if player.score == finishScore then
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
				if debriTimer > 0.5 then
					--debris[i].debriMesh.enabled = false
					debris[i].alive = false
					debriTimer = 0
				end
			elseif  debriTimer > 0.5 then
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
						if circleIntersection(player.playerMain:getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize) then
							player:Explode(dt)
							player:takeDamage(dt)
							totalDebris:Spread(object)
							totalAsteroids:Split(object)
						end	
					end
		
					for i = 1, count(debris) do
						if circleIntersection(debris[i].debriMesh:getPosition2D(),player.playerMain:getPosition2D(),20) then
							if not player.shieldOn then
								player:Explode(dt)
							end
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

function onKeyDown(key)
	if not newGame then
		if player.life > 0 and player.respawned == false then
			if key == KEY_x and isPressed then
				isPressed = false
				player.shotFired = true
			end
		end
	
	-- if key == KEY_TAB then
	-- 	debuggingSwitch = toggleDebugger(debuggingSwitch)
	-- end

	end

	if key == KEY_F1 then
		totalCoins = totalCoins + 1
	end

	if key == KEY_ESCAPE then
		Services.Core:Shutdown()
	end

	if key == KEY_SPACE and newGame and totalCoins > 0 then
		Init()
	end

	if key == KEY_s and not newGame and player.respawned == false then
		player:HyperSpace()
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
scoreLabel = SceneLabel("", 80, "Walkway", Label.ANTIALIAS_FULL, 0)
scene:addChild(scoreLabel)

timerLabel = SceneLabel("", 50, "Walkway", Label.ANTIALIAS_FULL, 0)
scene:addChild(timerLabel)

gameOverLabel = SceneLabel("GAME OVER!", 80, "Walkway", Label.ANTIALIAS_FULL,0)
gameLabel = SceneLabel("ASTEROIDS!", 160, "Walkway", Label.ANTIALIAS_FULL,0)
coinLabel = SceneLabel("Insert coin", 40, "Walkway", Label.ANTIALIAS_FULL,0)
descLabel = SceneLabel("Press SPACE to start!", 40, "Walkway", Label.ANTIALIAS_FULL,0)
creditLabel = SceneLabel("©1979 ATARI INC", 40, "Walkway", Label.ANTIALIAS_FULL,0)
gameOverLabel.visible = false
gameLabel.visible = true
descLabel.visible = true
gameLabel:setColorInt(152,181,193,255)
gameOverLabel:setColorInt(152,181,193,255)
descLabel:setColorInt(152,181,193,255)
coinLabel:setColorInt(152,181,193,255)
creditLabel:setColorInt(152,181,193,255)
scoreLabel:setColorInt(152,181,193,255)
timerLabel:setColorInt(152,181,193,255)
scene:addChild(gameOverLabel)
scene:addChild(gameLabel)
scene:addChild(descLabel)
scene:addChild(coinLabel)
scene:addChild(creditLabel)

creditLabel:setPositionY(-Services.Core:getYRes() + 50)
coinLabel:setPositionY(-Services.Core:getYRes() + 150)
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
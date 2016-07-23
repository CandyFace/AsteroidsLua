--[[ Thee who read this code, 
shall be venturing on their own terms, for truly there is no help to be given, 
nor is there any explanation for those who should be lost or confused.

An Asteroids clone made using PolyCode by CandyFace / Oliver Larsen - 2016 --]]

require "Scripts/Player"
require "Scripts/UI"
require "Scripts/Asteroid"
require "Scripts/Ammo"
require "Scripts/Debris"
require "Scripts/FlyingSaucer"

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

scene:getDefaultCamera():setOrthoSize(1440, 900)
level = SceneEntityInstance(scene, "Entities/level.entity")

-- makes level entity child of scene
scene:addChild(level)

-- Globals
isPressed = true
reloadAsteroids = false
maxBulletAliveTime = 1.5
bulletIndex = 1
debriPieces = 8
debriAngle = 0
debriTimer = 0
saucerTimer = 0
saucerBulletDelay = 0
amountOfAsteroids = 4
newGame = true
minExtra = 10000
maxExtra = 15000
highScore = 0
minCount = 10
maxCount = 20

--Tables
debris = {}
asteroids = {}
bullet = {}
saucer = {}
saucerBullet = {}

ui = UI()
ui:Init(scene)

function Init()
	player = Player(scene)

	--Initializes 4 bullets on the screen
	for i = 1, 4 do
		bullet[i] = Ammo(scene)
		bullets = bullet[i]
	end

	for i = 1, 10 do
		saucerBullet[i] = Ammo(scene)
		saucerBullets = saucerBullet[i]
	end

	saucer = FlyingSaucer(scene)
	
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
	highScoreLabel.visible = true
	coinLabel.visible = false
	creditLabel.visible = false
	newGame = false
	gameOverTimer = 0
	waitToSpawn = 3
	totalQuarters = totalQuarters - 1
	totalNumOfAsteroids = 28
 	saucerCountDown = random(minCount,maxCount)
end

function Update(dt)
	ui:Update(dt)
	if not newGame then
		player:Update(dt)
		--print(" " ..saucerCountDown)
		
		--Give player an extra life for getting x point.
		if player.visualScore >= minExtra and player.visualScore <= maxExtra then
			player:GainExtraLife()
			minExtra = minExtra + 10000
			maxExtra = maxExtra + 15000
		end
	
		if reloadAsteroids then
			for i = 1, amountOfAsteroids do
				asteroids[i]:RespawnAsteroids(asteroids[i])
			end
			reloadAsteroids = false
		end
	
		if player.respawned then
			player.respawnTimer = player.respawnTimer + 1*dt
			player.hit = true
			player:Respawn()
		end
	
		--The score determines whether a wave has been completed
		if totalNumOfAsteroids <= 0 then
			waitToSpawn = waitToSpawn - 1*dt
			if waitToSpawn <= 0 then
				waitToSpawn = 3
				--finishScore = finishScore + 2080
				totalNumOfAsteroids = 28
				spawnExistingAsteroids = false
				reloadAsteroids = true
				table.remove(asteroids)
			end
		end
	
	if player.life > 0 or gameOverTimer < 3 then
		saucer.saucerTimer = saucer.saucerTimer + 1*dt
		saucerCountDown = saucerCountDown - 1*dt

		for i = 1, count(debris) do
			if circleIntersection(debris[i].debriMesh:getPosition2D(),player.playerMain:getPosition2D(),20) then
				if not player.shieldOn then
					player:Explode(dt)
				end
				player:takeDamage()
			end
		end

		if not saucer.hit then
			saucer:FlyOnCountDown()
			for i = 1, count(bullet) do
				if saucer.canFly then
					if circleIntersection(saucer.flyingSaucer:getPosition2D(), bullet[i].shot:getPosition2D(), saucer.colSize) then
						saucer:scorePoint()
						totalDebris:Spread(saucer, saucer.flyingSaucer)
						saucer:Explode()
						bullet[i].shot:setPositionX(10000000)
						bullet[i].alive = false
						player.shotFired = false
						bullet[i].canShoot = true
						bulletIndex = 1
						bullet[i].timer = 0
					end
				end
			end

			if circleIntersection(player.playerMain:getPosition2D(), saucer.flyingSaucer:getPosition2D(), saucer.colSize) then
				if not player.shieldOn then
						player:Explode(dt)
				end
				totalDebris:Spread(saucer, saucer.flyingSaucer)
				player:takeDamage()
				saucer:Explode()
			end

			for i = 1, count(saucerBullet) do
				if circleIntersection(saucerBullet[i].shot:getPosition2D(), player.playerMain:getPosition2D(), 20) then
					if not player.shieldOn then
						player:Explode(dt)
					end
				saucerBullet[i].alive = false
				saucerBullet[i].shot:setPosition(100000,100000,0)
				player:takeDamage()
				saucer:Explode()
				end
			end
		end

		for index, object in pairs(asteroids) do
			if not object.asteroid.hit then
				object.asteroid:Roll(object.asteroid.rndRotVal * dt)
				
				if object.asteroid.randomDirection % 2 == 0 then
					object.asteroid:setPositionX(object.asteroid:getPosition().x - cos(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
					object.asteroid:setPositionY(object.asteroid:getPosition().y - sin(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
				else
					object.asteroid:setPositionX(object.asteroid:getPosition().x + cos(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
					object.asteroid:setPositionY(object.asteroid:getPosition().y + sin(degToRad(object.asteroid.rndRotVal)) * object.asteroid.rndSpeed)
				end
				stayWithinBoundary(object.asteroid)
				if not player.shieldOn then
					if circleIntersection(player.playerMain:getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize) then
						player:Explode(dt)
						player:takeDamage(dt)
						totalDebris:Spread(object, object.asteroid)
						totalAsteroids:Split(object)
						saucer:Explode()
					end	
				end
				--saucer can be destroyed, but only by smaller asteroids
				if object.asteroid.size < 5 then
					if circleIntersection(object.asteroid:getPosition2D(), saucer.flyingSaucer:getPosition2D(), object.asteroid.colSize) then
						totalDebris:Spread(object, object.asteroid)
						saucer:Explode()
						totalAsteroids:Split(object)
					end
				end
				for i = 1, count(saucerBullet) do
					if circleIntersection(saucerBullet[i].shot:getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize) then
						totalDebris:Spread(object, object.asteroid)
						totalAsteroids:Split(object)
						saucerBullet[i].alive = false
						saucerBullet[i].shot:setPosition(100000,100000,0)
						saucerBullet[i].canShoot = true
						saucer.shotFired = false
					end
				end
	
				for i = 1, count(bullet) do
					if circleIntersection(object.asteroid:getPosition2D(), bullet[i].shot:getPosition2D(), object.asteroid.colSize) then
						player:GatherPoint(object)
						totalDebris:Spread(object, object.asteroid)
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
	
			--Update bullets when saucer has shot
			--TODO: finish
			for index, object in pairs(saucerBullet) do
				saucerBulletDelay = saucerBulletDelay +1*dt
				object.timer = object.timer + 1*dt
				if round(saucerCountDown,0) % 2 == 0 then
					saucer.shotFired = true
				else
					saucer.shotFired = false
				end
				if saucer.shotFired then
					if object.canShoot and saucer.canFly and saucerBulletDelay > 5 then 
							object.canShoot = false
							saucer:FireBullet(dt, object, saucer)
							saucerBulletDelay = 0
							object.timer = 0
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
	
			--Update saucer bullets when timer has passed x seconds
			for i = 1, count(saucerBullet) do
				if saucerBullet[i].timer >= maxBulletAliveTime then
					saucerBullet[i].alive = false
					saucerBullet[i].shot:setPosition(100000,100000,0)
					saucerBullet[i].timer = maxBulletAliveTime
					saucerBullet[i].canShoot = true
					saucer.shotFired = false
				end
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

	if key == KEY_F3 then
		totalQuarters = totalQuarters + 1
	end

	if key == KEY_ESCAPE then
		Services.Core:Shutdown()
	end

	if key == KEY_SPACE and newGame and totalQuarters > 0 then
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
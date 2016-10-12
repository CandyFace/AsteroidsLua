--[[ Thee who read this code, 
shall be venturing on their own terms, for truly there is no help to be given, 
nor is there any explanation for those who should be lost or confused.

An Asteroids clone made using Polycode by CandyFace / Oliver Larsen - 2016 --
Thanks to: Ivan for creating Polycode and Fodinabor for helping understanding the engine]]

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

getShaderLocalOptions = scene:getDefaultCamera():getLocalShaderOptions()
paramNUMBER = ProgramParam.PARAM_NUMBER

getShaderLocalOptions[1]:addParam(paramNUMBER, "brightThreshold"):setNumber(0.40)
getShaderLocalOptions[2]:addParam(paramNUMBER, "blurSize"):setNumber(0.002)
getShaderLocalOptions[3]:addParam(paramNUMBER, "blurSize"):setNumber(0.002)
getShaderLocalOptions[4]:addParam(paramNUMBER, "bloomFactor"):setNumber(1.5)
getShaderLocalOptions[4]:addParam(paramNUMBER, "exposure"):setNumber(0)
--print(scene:getDefaultCamera():getLocalShaderOptions()[1])	
--print(scene:getDefaultCamera():hasFilterShader())

scene:getDefaultCamera():setOrthoSize(1440, 900)
level = SceneEntityInstance(scene, "Entities/level.entity")

-- makes level entity child of scene
scene:addChild(level)

-- Globals
reloadAsteroids = false
maxBulletAliveTime = 1.5
bulletIndex = 1
debriPieces = 8
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
sumOfPosX = 0
sumOfPosY = 0

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
			local circleIntersect = circleIntersection(debris[i].debriMesh:getPosition2D(),player.playerMain:getPosition2D(),20)
			if circleIntersect then
				player:Explode(dt)
				player:takeDamage()
			end
		end

		if not saucer.hit then
			saucer:FlyOnCountDown()
			for i = 1, count(bullet) do
				if saucer.canFly then
					local circleIntersect = circleIntersection(saucer.flyingSaucer:getPosition2D(), bullet[i].shot:getPosition2D(), saucer.colSize)
					if circleIntersect then
						local check_col = check_collision(saucer.flyingSaucer, bullet[i].shot)
							if check_col == 1 then
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
			end

			local circlePSIntersect = circleIntersection(player.playerMain:getPosition2D(), saucer.flyingSaucer:getPosition2D(), saucer.colSize)
			if circlePSIntersect then
				local check_col = check_collision(player.playerMain, saucer.flyingSaucer)
				if check_col == 1 then
					player:Explode(dt)
					totalDebris:Spread(saucer, saucer.flyingSaucer)
					player:takeDamage()
					saucer:Explode()
				end
			end

			for i = 1, count(saucerBullet) do
				local circleSBPIntersect = circleIntersection(saucerBullet[i].shot:getPosition2D(), player.playerMain:getPosition2D(), 20)
				if circleSBPIntersect then
					local check_col = check_collision(saucerBullet[i].shot, player.playerMain)
					if check_col == 1 then
						player:Explode(dt)
						saucerBullet[i].alive = false
						saucerBullet[i].shot:setPosition(100000,100000,0)
						player:takeDamage()
						saucer:Explode()
					end
				end
			end
		end

		for index, object in pairs(asteroids) do
			if not object.asteroid.hit then
				object.asteroid:Roll(object.asteroid.rndRotVal * dt)

				translateObject(object.asteroid)

				local asteroidBoundary = stayWithinBoundary(object.asteroid)
				local circlePAIntersect = circleIntersection(player.playerMain:getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize) 
				if circlePAIntersect then
					local check_col = check_collision(object.asteroid, player.playerMain)

					if check_col == 1 then
						player:Explode(dt)
						player:takeDamage(dt)
						totalDebris:Spread(object, object.asteroid)
						totalAsteroids:Split(object)
						saucer:Explode()
					end
				end
				--saucer can be destroyed, but only by smaller asteroids
				if object.asteroid.size < 5 then
					local circleASIntersect = circleIntersection(object.asteroid:getPosition2D(), saucer.flyingSaucer:getPosition2D(), object.asteroid.colSize)
					
					if circleASIntersect then
						totalDebris:Spread(object, object.asteroid)
						saucer:Explode()
						totalAsteroids:Split(object)
					
					end
				end
				for i = 1, count(saucerBullet) do
					local circleSAIntersect = circleIntersection(saucerBullet[i].shot:getPosition2D(), object.asteroid:getPosition2D(), object.asteroid.colSize)
					
					if circleSAIngersect then
						totalDebris:Spread(object, object.asteroid)
						totalAsteroids:Split(object)
						saucerBullet[i].alive = false
						saucerBullet[i].shot:setPosition(100000,100000,0)
						saucerBullet[i].canShoot = true
						saucer.shotFired = false
					end
				end
	
				local killTimer = 0
				for i = 1, count(bullet) do
					local circleABIntersect = circleIntersection(object.asteroid:getPosition2D(), bullet[i].shot:getPosition2D(), object.asteroid.colSize)
					if circleABIntersect then
						killTimer = killTimer + 1 * dt
						local check_col = check_collision(object.asteroid, bullet[i].shot)
						if check_col == 1 then
							player:GatherPoint(object)
							totalDebris:Spread(object, object.asteroid)
							totalAsteroids:Split(object)
							bullet[i].shot:setPositionX(10000000)
							bullet[i].alive = false
							player.shotFired = false
							bullet[i].canShoot = true
							bulletIndex = 1
							bullet[i].timer = 0
							killTimer = 0
						elseif killTimer >= 0.018 then
							player:GatherPoint(object)
							totalDebris:Spread(object, object.asteroid)
							totalAsteroids:Split(object)
							bullet[i].shot:setPositionX(10000000)
							bullet[i].alive = false
							player.shotFired = false
							bullet[i].canShoot = true
							bulletIndex = 1
							bullet[i].timer = 0
							killTimer = 0
						end
										print("killTimer: "..killTimer)
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
						debris[i].alive = false
						debriTimer = 0
					end
				elseif  debriTimer > 0.5 then
					debris[i].debriMesh:setPositionX(10000)
				end
			end
		
			--Update bullets when a shot has been fired
			for i = 1, count(bullet) do
				bullet[i].timer = bullet[i].timer + 1*dt
				if player.shotFired then 
					if bulletIndex <= table.getn(bullet) then
						if bullet[i].canShoot then
							bullet[i].canShoot = false
							player:FireBullet(dt, bullet[i])
							player.shotFired = false
							bullet[i].timer = 0
						end
						bulletIndex = bulletIndex + 1
					end
				end
			bullet[i]:UpdateBullet(dt)
			end
	
			--Update bullets when saucer has shot
			for i = 1, count(saucerBullet) do
				saucerBulletDelay = saucerBulletDelay +1*dt
				saucerBullet[i].timer = saucerBullet[i].timer + 1*dt
				if round(saucerCountDown,0) % 2 == 0 then
					saucer.shotFired = true
				else
					saucer.shotFired = false
				end
				if saucer.shotFired then
					if saucerBullet[i].canShoot and saucer.canFly and saucerBulletDelay > 5 then 
						saucerBullet[i].canShoot = false
						saucer:FireBullet(dt, saucerBullet[i], saucer)
						saucerBulletDelay = 0
						saucerBullet[i].timer = 0
					end
				end
			saucerBullet[i]:UpdateBullet(dt)
			end			

			--Update bullets when timer has passed x seconds
			updateObjectAtX(bullet, player)
			-- --Update saucer bullets when timer has passed x seconds
			updateObjectAtX(saucerBullet, saucer)
		end
	end
end

function translateObject(object)
	local translatedPos
	local objectPos = object:getPosition()
	if object.randomDirection % 2 == 0 then
		translatedPos = object:setPositionX(objectPos.x - cos(degToRad(object.rndRotVal)) * object.rndSpeed)
		translatedPos = object:setPositionY(objectPos.y - sin(degToRad(object.rndRotVal)) * object.rndSpeed)
		return translatedPos
	else
		translatedPos = object:setPositionX(objectPos.x + cos(degToRad(object.rndRotVal)) * object.rndSpeed)
		translatedPos = object:setPositionY(objectPos.y + sin(degToRad(object.rndRotVal)) * object.rndSpeed)
		return translatedPos
	end
end

local isPressed = true
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
	local playerPos = object:getPosition2D()
	local yRes = Services.Core:getYRes()
	local xRes = Services.Core:getXRes()
	if playerPos.y < -yRes then
		object:setPositionY(yRes)
	end

	if playerPos.y > yRes then
		object:setPositionY(-yRes)
	end

	if playerPos.x > xRes then
		object:setPositionX(-xRes)
	end

	if playerPos.x < -xRes then
		object:setPositionX(xRes)
	end
end

 function degToRad(degrees)
	return degrees * math.pi/180
end

local _checkX, _checkY, _rad
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

function updateObjectAtX(object1, object2)
	for i = 1, count(object1) do
		if object1[i].timer >= maxBulletAliveTime then
			object1[i].alive = false
			object1[i].shot:setPosition(100000,100000,0)
			object1[i].timer = maxBulletAliveTime
			object1[i].canShoot = true
			object2.shotFired = false
			
			if #object2 == #player then
				bulletIndex = 1
			end
		end
	end 
end

local pTotal
local p0, p1, p2, p3, p4, p5, p6, p7, ix, iy 
local COLLISION = 1
local NOCOLLSION = 0
local test = 0
function check_collision(object, target)
	local objectPos = object:getPosition2D()
	local targetPos = target:getPosition2D()
	local objectVertex = object:getMesh()
	local targetVertex = target:getMesh()
	local objectScale = object:getScale()
	local targetScale = target:getScale()
	local objectOrientationM = object:getConcatenatedRollMatrix()
	local targetOrientationM = target:getConcatenatedRollMatrix()

	for i = 0, asteroid:getMesh():getVertexCount() do
		local objectVPos0 = objectOrientationM:multVector(objectVertex:getVertexPosition(i))
		local objectVPos1 = objectOrientationM:multVector(objectVertex:getVertexPosition(i+1))
		for j = 0, target:getMesh():getVertexCount() do
			local targetVPos0 = targetOrientationM:multVector(targetVertex:getVertexPosition(j)) 
			local targetVPos1 = targetOrientationM:multVector(targetVertex:getVertexPosition(j+1))

			p0 = objectPos.x+objectVPos0.x*objectScale.x
			p1 = objectPos.y+objectVPos0.y*objectScale.y
			p2 = objectPos.x+objectVPos1.x*objectScale.x
			p3 = objectPos.y+objectVPos1.y*objectScale.y
			p4 = targetPos.x+targetVPos0.x*targetScale.x
			p5 = targetPos.y+targetVPos0.y*targetScale.y
			p6 = targetPos.x+targetVPos1.x*targetScale.x
			p7 = targetPos.y+targetVPos1.y*targetScale.y
			-- print("\n X: i+1 - targetPosX: ".. targetX.."\n objectPosX: ".. objectX.."\norientationValueX: ".. objectOrientationX.. "\nscaleValueX: ".. objectScaleX.."\nvertexPos: ".. objectVertex:getVertexPosition(i+1).x .."\nvertexXO: "..objectVertex:getVertexPosition(i+1).x*objectOrientationX.. "\n vertexX scaled: "..objectVertex:getVertexPosition(i+1).x*objectScaleX  .."\n  objectVPosO: "..  objectX+objectVertex:getVertexPosition(i+1).x*objectOrientationX*objectScaleX.."\nAFTER_________" )
			-- print("\n Y: i+1 - targetPosY: ".. targetY.."\n objectPosY: ".. objectY.."\norientationValueY: ".. objectOrientationY.. "\nscaleValueY: ".. objectScaleY.."\nvertexPos: ".. objectVertex:getVertexPosition(i+1  ).y .."\nvertexYO: ".. objectVertex:getVertexPosition(i+1).y*objectOrientationY.. "\n vertexY scaled: "..objectVertex:getVertexPosition(i+1).y*objectScaleY  .."\n  objectVPosO: ".. objectY+objectVertex:getVertexPosition(i+1).y*objectScaleY.."\nAFTER_________" )
			pTotal = get_line_intersection(p0,p1,p2,p3,p4,p5,p6,p7,0,0)
			if pTotal == 1 then
				return COLLISION
			end
		end
	end
end

--Returns 1 if the lines intersect, otherwise 0. In addition, if the lines 
--intersect the intersection point may be stored in the i_x and i_y.
--algorithm from http:--stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
local s1_x, s1_y, s2_x, s2_y
local s, t
function get_line_intersection(p0_x,  p0_y,  p1_x,  p1_y, p2_x,  p2_y,  p3_x,  p3_y,  i_x,  i_y)
    
    s1_x = p1_x - p0_x;     s1_y = p1_y - p0_y;
    s2_x = p3_x - p2_x;     s2_y = p3_y - p2_y;

    s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y);
    t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y);

    if (s >= 0 and s <= 1 and t >= 0 and t <= 1) then
    	--Collision detected
        if (i_x ~= nil) then
            i_x = p0_x + (t * s1_x)
        end
        if (i_y ~= nil) then
            i_y = p0_y + (t * s1_y)
        end
       --safety measure, sometimes t and s equals in scientific notation which should be avoided
       if t >= 0 and t <= 1 and s >= 0 and s <= 1 then
       		--player.intersectCircle:setPosition(i_x,i_y,0)
       		return 1 
       	end
    end
    return 0 -- No collision
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
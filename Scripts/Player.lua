class "Player"
require "Scripts/Ammo"
require "Scripts/Debris"
--------	Initializations	-----------

local turnSpeed = 4
local movementSpeed = 5
local keyInput = Services.Input -- shortening the call..
local velocity = Vector2(0.0,0.0)
local position = Vector2(0.0,0.0)
local bulletSpeed = 150
local score = 0
local life = 3
local invisTimer = 3
local counter = 1
local space = 50
local angle = 0
respawnTimer = 0
respawned = false

local friction = 0.0010

playerMain = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH)
playerMain.backfaceCulled = false
----- 			END 		----------

function Player:Player(scene)
	self.scene = scene
	self.collisionBody = scene:addCollisionChild(playerMain, PhysicsScene2DEntity.ENTITY_RECT)
	self.initRotation = playerMain:Roll(135) -- sets the rotation to 90, based on its origin value
	playerMain:getMesh():addVertex(-7.5, 7.5, 0.0)
	playerMain:getMesh():addVertex(-25, 0, 0.0)
	playerMain:getMesh():addVertex(15, -15, 0.0)
	playerMain:getMesh():addVertex(0, 25, 0.0)
	self.shotfired = false
	self.scene:addChild(playerMain)
	self.shootSound =  Sound("Sfx/pew.wav")
	self.thrustSound = Sound("Sfx/thrust2.wav")
	self.hit = false
	self.score = score
	self.life = life
	self.shieldOn = true
	self.maxLife = self.life + 1
	self.playerLifeCounter = {}
	self.survivalTimer = 0
	self.thrustTimer = 0
	self.thrustMeshCon = {}
	self.playerExplosionMesh = {}
	self.playerExplosionMeshLoc = {}
	self.playerExplosionMeshVel = {}
	self.playerExplosionMeshLocTotal = {}
	self.playerExplosionMeshVelTotal = {}
	thrustMesh = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH)
	thrustMesh.backfaceCulled = false
	thrustMesh:Roll(135)

	for i = 1, 4 do
		thrustMesh:getMesh():addVertex(-7.5, 7.5, 0.0)
		thrustMesh:getMesh():addVertex(-4.7, 13.8, 0.0)
		thrustMesh:getMesh():addVertex(-15, 15, 0.0)
		thrustMesh:getMesh():addVertex(-13.2, 5, 0.0)
		scene:addChild (thrustMesh)
		self.thrustMeshCon[i] = thrustMesh
	end
	
	--initialize life meshes
	for i = 0, self.maxLife do
		playerLifeMesh = SceneMesh.SceneMeshWithType(Mesh.TRIFAN_MESH)
		playerLifeMesh.backfaceCulled = false
		playerLifeMesh:getMesh():setMeshType(Mesh.LINE_LOOP_MESH)
		playerLifeMesh:getMesh():addVertex(-7.5, 7.5, 0.0)
		playerLifeMesh:getMesh():addVertex(-25, 0, 0.0)
		playerLifeMesh:getMesh():addVertex(15, -15, 0.0)
		playerLifeMesh:getMesh():addVertex(0, 25, 0.0)
		playerLifeMesh:Roll(135)
	
		playerLifeMesh:setPosition(-Services.Core:getXRes() + 100 + space, Services.Core:getYRes() - 180,  0)
		space = space + 50
		scene:addChild (playerLifeMesh)
		self.playerLifeCounter[i] = playerLifeMesh
	end

	for i = 1, 4 do 
		self.playerExplosionMesh[i] = SceneMesh.SceneMeshWithType(Mesh.LINE_MESH)
	end
	self.playerExplosionMesh[1]:getMesh():addVertex(-7.5, 7.5, 0.0)
	self.playerExplosionMesh[1]:getMesh():addVertex(-25, 0, 0.0)
	self.playerExplosionMesh[2]:getMesh():addVertex(-25, 0, 0.0)
	self.playerExplosionMesh[2]:getMesh():addVertex(15, -15, 0.0)	
	self.playerExplosionMesh[3]:getMesh():addVertex(15, -15, 0.0)	
	self.playerExplosionMesh[3]:getMesh():addVertex(0, 25, 0.0)
	self.playerExplosionMesh[4]:getMesh():addVertex(0, 25, 0.0)
	self.playerExplosionMesh[4]:getMesh():addVertex(-7.5, 7.5, 0.0)
	self.explosionAngle = 0
	self.position = Vector2(0,0)
	self.velocity = Vector2(0,0)
	self.direction = 0
	self.alive = false
	--self.debriMesh:setPosition(10000,10000,0)
	
	for i = 1, 4 do
		scene:addChild(self.playerExplosionMesh[i])
		self.playerExplosionMesh[i]:setPositionX(10000000)
	end

end

function Player:Update(dt)	
	angle = playerMain:getRoll() - 45 
	self.thrustTimer = self.thrustTimer + 0.5
	--print(velocity.x .. " " .. velocity.y)

	if player.life > 0 and respawned then
		self.thrustSound:Play(false)
		self.thrustSound:Stop()
	end

	if life > 0 and respawned == false then
		stayWithinBoundary(playerMain)
		stayWithinBoundary(thrustMesh)

		if Services.Input:getKeyState(KEY_UP) or Services.Input:getKeyState(KEY_UP) and Services.Input:getKeyState(KEY_LEFT) or Services.Input:getKeyState(KEY_UP) and Services.Input:getKeyState(KEY_RIGHT) then
			if not self.thrustSound:isPlaying() then
				self.thrustSound:Play(true)
			end
		end
		
		if keyInput:getKeyState(KEY_UP) then
			velocity = Vector2(velocity.x + cos(degToRad(angle))*movementSpeed*dt, 
							   velocity.y + sin(degToRad(angle))*movementSpeed*dt)
			for i = 1, 4 do
				if round(self.thrustTimer,0) % 2 == 0 then
					self.thrustMeshCon[i].visible = true
				elseif self.thrustTimer ~= 0 then
					self.thrustMeshCon[i].visible = false
				end
		end
		if self.thrustTimer > 10 then
			self.thrustTimer = 0
		end
		else
			--Stoke's law / friction force
			velocity.x = velocity.x - velocity.x * friction
			velocity.y = velocity.y - velocity.y * friction
			for i = 1, 4 do
				self.thrustMeshCon[i].visible = false
			end
		end
		playerMain:setPositionX(playerMain:getPosition().x + velocity.x)
		playerMain:setPositionY(playerMain:getPosition().y + velocity.y)
		thrustMesh:setPositionX(thrustMesh:getPosition().x + velocity.x)
		thrustMesh:setPositionY(thrustMesh:getPosition().y + velocity.y)
		--LEFT
		if keyInput:getKeyState(KEY_LEFT) then
			playerMain:Roll(turnSpeed)
			thrustMesh:Roll(turnSpeed)
		--RIGHT
		elseif keyInput:getKeyState(KEY_RIGHT) then		
			playerMain:Roll(-turnSpeed)
			thrustMesh:Roll(-turnSpeed)
		else 
			-- Nothing
		end
	end
end

function Player:UpdateExplosion()
	if self.hit then
		for i = 1, 4 do
			self.playerExplosionMesh[i]:setPosition(self.playerExplosionMesh[i]:getPosition().x + self.playerExplosionMeshVel[i].x * 0.1, self.playerExplosionMesh[i]:getPosition().y + self.playerExplosionMeshVel[i].y * 0.1, 0)
			self.playerExplosionMesh[i]:setRoll(angle +45)
		end
	end
end

function Player:FireBullet(dt, object)
	if not object.alive then
		object.pos = Vector2(cos(degToRad(object.direction + angle)) * 1.15, sin(degToRad(object.direction + angle)) * 1.15)
		object.vel = Vector2(cos(degToRad(object.direction + angle)) * bulletSpeed, sin(degToRad(object.direction + angle)) * bulletSpeed)

		object:Fire(Vector2(object.pos.x + playerMain:getPosition().x, object.pos.y + playerMain:getPosition().y),
			Vector2(object.vel.x + velocity.x, object.vel.y + velocity.y), object.timer)
	end
end

function Player:UpdatePlayerLife(life)
	self.life = life
	for i = 0, self.maxLife do
		local playerHP = self.playerLifeCounter[i]
		if self.life > i then
			playerHP.visible = true
		else
			playerHP.visible = false
		end
	end
end

--Ensuring no kill on spawn, and respawn
function Player:shield(dt)
	if self.shieldOn then
		invisTimer = invisTimer - 1*dt
		counter = counter + 4 *dt
		--print(counter .. " ")
			if round(counter,0) % 2 == 0 then
				playerMain.visible = false
			else
				playerMain.visible = true
			end
			if counter >= 3 then
				counter = 1
			end
		if invisTimer <= 0 then
			invisTimer = 3
			counter = 1
			self.shieldOn = false
			-- self.hit = false
		end
	end
end

function Player:takeDamage(dt)
	if life > 0 and not self.shieldOn then
		life = life - 1 
		velocity = Vector2(0,0)
		respawned = true
		playerMain:setPositionX(100000)
		thrustMesh:setPositionX(100000)
	end
	if life <= 0 then
		playerMain:setPositionX(100000)
		thrustMesh:setPositionX(100000)
	end
end

function Player:Respawn()
	if respawnTimer > 3 and not self.shieldOn and life > 0 then
		self.shieldOn = true
		playerMain:setPosition(0,0,0)
		thrustMesh:setPosition(0,0)

		for i = 1, 4 do
			self.playerExplosionMesh[i]:setPosition(10000,1000,1000)
		end
		self.hit = false
		respawnTimer = 0
		respawned = false
	end
end

function Player:Explode(dt)
	for i = 1, 4 do
		self.playerExplosionMeshLoc[i] = Vector2(cos(degToRad(self.direction + angle)), sin(degToRad(self.direction + angle)))
		self.playerExplosionMeshVel[i] = Vector2(cos(degToRad(self.direction + angle)) * 3, sin(degToRad(self.direction + angle)) * 3)

		self.playerExplosionMeshLocTotal[i] = Vector2(self.playerExplosionMeshLoc[i].x + playerMain:getPosition().x, self.playerExplosionMeshLoc[i].y + playerMain:getPosition().y)
		self.playerExplosionMeshVelTotal[i] = Vector2(self.playerExplosionMeshVel[i].x + velocity.x, self.playerExplosionMeshVel[i].y + velocity.y)
		
		self.playerExplosionMesh[i]:setPosition(self.playerExplosionMeshLocTotal[i].x, self.playerExplosionMeshLocTotal[i].y,0)
		angle = angle + random(360)
	end
end

function Player:getMovementSpeed()
	return movementSpeed
end

function Player:getPlayerPosX()
	return playerMain:getPosition().x
end

function Player:getPlayerPosY()
	return playerMain:getPosition().y
end

function Player:setPlayerPosX(_pos)
	playerMain:setPositionX(_pos)
end

function Player:getPlayerLifeMesh()
	return playerLifeMesh
end

function Player:setPlayerVelocity(_vel1, _vel2)
	velocity.x = _vel1
	velocity.y = _vel2
end 

function Player:getPlayerVelX()
	return velocity.x
end

function Player:getPlayerVelY()
	return velocity.y
end

function Player:getPlayerAngle()
	return angle
end

function Player:getPlayer()
	return playerMain
end

function Player:getPlayerScore()
	return score
end

function Player:setPlayerScore(_score)
	score = _score
end 

function Player:getPlayerLife()
	return life
end

function Player:setPlayerLife(_life)
	life = _life
end

function Player:getInvisTimer()
	return invisTimer
end

function Player:setInvisTimer(_invisTimer)
	invisTimer = _invisTimer
end
class "Player"

local keyInput = Services.Input -- shortening the call..
local counter = 1

function Player:Player(scene)
	self.playerMain = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH)
	self.playerMain.backfaceCulled = false
	self.turnSpeed = 4
	self.movementSpeed = 5
	self.bulletSpeed = 150
	self.friction = 0.0010
	self.invisTimer = 3
	self.scene = scene
	self.collisionBody = scene:addCollisionChild(self.playerMain, PhysicsScene2DEntity.ENTITY_RECT)
	self.initRotation = self.playerMain:Roll(135) -- sets the rotation to 90, based on its origin value
	self.playerMain:getMesh():addVertex(-7.5, 7.5, 0.0)
	self.playerMain:getMesh():addVertex(-25, 0, 0.0)
	self.playerMain:getMesh():addVertex(15, -15, 0.0)
	self.playerMain:getMesh():addVertex(0, 25, 0.0)
	self.shotfired = false
	self.scene:addChild(self.playerMain)
	self.shootSound =  Sound("Sfx/pew.wav")
	self.thrustSound = Sound("Sfx/thrust2.wav")
	self.explosionSound = Sound("Sfx/PlayerExplosion.wav")
	self.hit = false
	self.score = 0
	self.life = 3
	self.angle = 0
	self.shieldOn = true
	self.maxLife = self.life + 1
	self.playerLifeCounter = {}
	self.survivalTimer = 0
	self.thrustTimer = 0
	self.respawnTimer = 0
	self.respawned = false
	self.thrustMeshCon = {}
	self.playerExplosionMesh = {}
	self.playerExplosionMeshLoc = {}
	self.playerExplosionMeshVel = {}
	self.playerExplosionMeshLocTotal = {}
	self.playerExplosionMeshVelTotal = {}
	self.thrustMesh = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH)
	self.thrustMesh.backfaceCulled = false
	self.thrustMesh:Roll(135)

	for i = 1, 4 do
		self.thrustMesh:getMesh():addVertex(-7.5, 7.5, 0.0)
		self.thrustMesh:getMesh():addVertex(-4.7, 13.8, 0.0)
		self.thrustMesh:getMesh():addVertex(-15, 15, 0.0)
		self.thrustMesh:getMesh():addVertex(-13.2, 5, 0.0)
		scene:addChild (self.thrustMesh)
		self.thrustMeshCon[i] = self.thrustMesh
	end
	
	--initialize life meshes
	self.space = 50
	for i = 0, self.maxLife do
		self.playerLifeMesh = SceneMesh.SceneMeshWithType(Mesh.TRIFAN_MESH)
		self.playerLifeMesh.backfaceCulled = false
		self.playerLifeMesh:getMesh():setMeshType(Mesh.LINE_LOOP_MESH)
		self.playerLifeMesh:getMesh():addVertex(-7.5, 7.5, 0.0)
		self.playerLifeMesh:getMesh():addVertex(-25, 0, 0.0)
		self.playerLifeMesh:getMesh():addVertex(15, -15, 0.0)
		self.playerLifeMesh:getMesh():addVertex(0, 25, 0.0)
		self.playerLifeMesh:Roll(135)
	
		self.playerLifeMesh:setPosition(-Services.Core:getXRes() + 100 + self.space, Services.Core:getYRes() - 180,  0)
		self.space = self.space + 50
		scene:addChild (self.playerLifeMesh)
		self.playerLifeCounter[i] = self.playerLifeMesh
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
	self.velocity = Vector2(0,0)
	self.direction = 0
	self.alive = false
	
	for i = 1, 4 do
		scene:addChild(self.playerExplosionMesh[i])
		self.playerExplosionMesh[i]:setPositionX(10000000)
	end

end

function Player:Update(dt)	
	player:UpdatePlayerLife()
	player:shield(dt)
	player:UpdateExplosion()
	self.angle = self.playerMain:getRoll() - 45 
	self.thrustTimer = self.thrustTimer + 0.5
	--print(velocity.x .. " " .. velocity.y)


	if player.life >= 0 and self.respawned then
		self.thrustSound:Play(false)
		self.thrustSound:Stop()
	end

	if player.life > 0 and self.respawned == false then
		stayWithinBoundary(self.playerMain)
		stayWithinBoundary(self.thrustMesh)

		if keyInput:getKeyState(KEY_UP) or keyInput:getKeyState(KEY_UP) and keyInput:getKeyState(KEY_LEFT) or Services.Input:getKeyState(KEY_UP) and Services.Input:getKeyState(KEY_RIGHT) then
			if not self.thrustSound:isPlaying() then
				self.thrustSound:Play(true)
			end
		end
		
		if keyInput:getKeyState(KEY_UP) then
			self.velocity = Vector2(self.velocity.x + cos(degToRad(self.angle))*self.movementSpeed*dt, 
							   self.velocity.y + sin(degToRad(self.angle))*self.movementSpeed*dt)
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
			self.velocity.x = self.velocity.x - self.velocity.x * self.friction
			self.velocity.y = self.velocity.y - self.velocity.y * self.friction
			for i = 1, 4 do
				self.thrustMeshCon[i].visible = false
			end
		end
		self.playerMain:setPositionX(self.playerMain:getPosition().x + self.velocity.x)
		self.playerMain:setPositionY(self.playerMain:getPosition().y + self.velocity.y)
		self.thrustMesh:setPositionX(self.thrustMesh:getPosition().x + self.velocity.x)
		self.thrustMesh:setPositionY(self.thrustMesh:getPosition().y + self.velocity.y)
		--LEFT
		if keyInput:getKeyState(KEY_LEFT) then
			self.playerMain:Roll(self.turnSpeed)
			self.thrustMesh:Roll(self.turnSpeed)
		--RIGHT
		elseif keyInput:getKeyState(KEY_RIGHT) then		
			self.playerMain:Roll(-self.turnSpeed)
			self.thrustMesh:Roll(-self.turnSpeed)
		else 
			-- Nothing
		end
	end
end

function Player:UpdateExplosion()
	if self.hit then
		for i = 1, 4 do
			self.playerExplosionMesh[i]:setPosition(self.playerExplosionMesh[i]:getPosition().x + self.playerExplosionMeshVel[i].x * 0.1, self.playerExplosionMesh[i]:getPosition().y + self.playerExplosionMeshVel[i].y * 0.1, 0)
			self.playerExplosionMesh[i]:setRoll(self.angle +45)
		end
	end
end

function Player:FireBullet(dt, object)
	if not object.alive then
		object.pos = Vector2(cos(degToRad(object.direction + self.angle)) * 1.15, sin(degToRad(object.direction + self.angle)) * 1.15)
		object.vel = Vector2(cos(degToRad(object.direction + self.angle)) * self.bulletSpeed, sin(degToRad(object.direction + self.angle)) * self.bulletSpeed)

		object:Fire(Vector2(object.pos.x + self.playerMain:getPosition().x, object.pos.y + self.playerMain:getPosition().y),
			Vector2(object.vel.x + self.velocity.x, object.vel.y + self.velocity.y), object.timer)
	end
end

function Player:UpdatePlayerLife()
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
		self.invisTimer = self.invisTimer - 1*dt
		counter = counter + 4 *dt
		--print(counter .. " ")
			if round(counter,0) % 2 == 0 then
				self.playerMain.visible = false
			else
				self.playerMain.visible = true
			end
			if counter >= 3 then
				counter = 1
			end
		if self.invisTimer <= 0 then
			self.invisTimer = 3
			counter = 1
			self.shieldOn = false
		end
	end
end

function Player:takeDamage(dt)
	if self.life > 0 and not self.shieldOn then
		self.life = self.life - 1 
		self.velocity = Vector2(0,0)
		self.respawned = true
		self.playerMain:setPositionX(100000)
		self.thrustMesh:setPositionX(100000)
		self.explosionSound:Play()
	end
	if self.life <= 0 then
		self.playerMain:setPositionX(100000)
		self.thrustMesh:setPositionX(100000)
	end
end

function Player:Respawn()
	if self.respawnTimer > 3 and not self.shieldOn and self.life > 0 then
		self.shieldOn = true
		self.playerMain:setPosition(0,0,0)
		self.thrustMesh:setPosition(0,0)

		for i = 1, 4 do
			self.playerExplosionMesh[i]:setPosition(10000,1000,1000)
		end
		self.hit = false
		self.respawnTimer = 0
		self.respawned = false
	end
end

function Player:Explode(dt)
	for i = 1, 4 do
		self.playerExplosionMeshLoc[i] = Vector2(cos(degToRad(self.direction + self.angle)), sin(degToRad(self.direction + self.angle)))
		self.playerExplosionMeshVel[i] = Vector2(cos(degToRad(self.direction + self.angle)) * 3, sin(degToRad(self.direction + self.angle)) * 3)

		self.playerExplosionMeshLocTotal[i] = Vector2(self.playerExplosionMeshLoc[i].x + self.playerMain:getPosition().x, self.playerExplosionMeshLoc[i].y + self.playerMain:getPosition().y)
		self.playerExplosionMeshVelTotal[i] = Vector2(self.playerExplosionMeshVel[i].x + self.velocity.x, self.playerExplosionMeshVel[i].y + self.velocity.y)
		
		self.playerExplosionMesh[i]:setPosition(self.playerExplosionMeshLocTotal[i].x, self.playerExplosionMeshLocTotal[i].y,0)
		self.angle = self.angle + random(360)
	end
end

function Player:getPlayerLifeMesh()
	return playerLifeMesh
end

function Player:getPlayerAngle()
	return angle
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
class "Ammo"

function Ammo:Ammo(scene)
	self.shot = SceneMesh.SceneMeshWithType(Mesh.POINT_MESH)
	self.pShot = SceneMesh.SceneMeshWithType(Mesh.POINT_MESH)
	self.scene = scene
	self.alive = false
	self.timer = 3
	self.direction = 0
	self.size = 10
	self.pSize = 5
	self.canShoot = true
	self.vel = Vector2(0.0,0.0)
	self.pos = Vector2(0.0,0.0)
	self.nVel = Vector2(0,0)
	self.pNVel = Vector2(0,0)
	self.shot:getMesh():createVPlane ( self.size,  self.size,  0)
	self.pShot:getMesh():createVPlane ( self.pSize,  self.pSize,  0)
	self.shot:setColorInt(152,181,193,255)
	self.pShot:setColorInt(152,181,193,255)
	self.shot:setBlendingMode(2)
	self.pShot:setBlendingMode(2)
	self.shot:setPositionX(1000)
	-- emitter = SceneParticleEmitter(10,3.0,1.0)
	-- emitter:setParticleSize(10)
	-- emitter:setGravity(Vector3(0, 0, 0.0));
	-- emitter:loadTexture("dot.png")
	-- emitter:setDirectionDeviation(Vector3(0.0, 0.0, 25.0));
	-- self.shot:addChild(emitter)
	self.shot:addChild(self.pShot)
	scene:addChild(self.shot)
end

function Ammo:UpdateBullet(dt)
	if self.alive then
		self.shot:setPosition(self.shot:getPosition().x + self.nVel.x * 0.1, self.shot:getPosition().y + self.nVel.y * 0.1, 0)
		
		--places a particle shot behind the actual bullet, simulating the vector lighting from the arcade monitor
		self.pShot:setPosition(self.pShot:getPosition().x *0.42 - self.pNVel.x * 0.1, self.pShot:getPosition().y *0.42 - self.pNVel.y * 0.1, 0)
		stayWithinBoundary(self.shot)
	end
end

function Ammo:Fire(pos,vel, time)
	self.pos = pos
	self.alive = true
	self.nVel = vel
	self.pNVel = vel
	self.time = timer
	self.shot:setPosition(self.pos.x,self.pos.y,0)
	player.shootSound:Play()
end

function Ammo:getTimer()
	return timer
end

function Ammo:setTimer(_timer)
	timer = _timer
end

function Ammo:getShot()
	return shot
end

function Ammo:getIsBulletAlive()
	return alive
end

function Ammo:setIsBulletAlive(_alive)
	alive = _alive
end
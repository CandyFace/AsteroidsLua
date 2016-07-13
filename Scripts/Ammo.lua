class "Ammo"

function Ammo:Ammo(scene)
	self.shot = SceneMesh.SceneMeshWithType(Mesh.LINE_MESH)
	self.scene = scene
	self.alive = false
	self.timer = 3
	self.direction = 0
	self.size = 5
	self.canShoot = true
	self.vel = Vector2(0.0,0.0)
	self.pos = Vector2(0.0,0.0)
	self.nVel = Vector2(0,0)
	self.shot:getMesh():createVPlane ( self.size,  self.size,  0)
	self.colBody = scene:addCollisionChild(self.shot,  PhysicsScene2DEntity.ENTITY_RECT)
	self.shot:setPositionX(1000)
	scene:addChild(self.shot)
end

function Ammo:UpdateBullet(dt)
	if self.alive then
		self.shot:setPosition(self.shot:getPosition().x + self.nVel.x * 0.1, self.shot:getPosition().y + self.nVel.y * 0.1, 0)
		stayWithinBoundary(self.shot)
	end
end

function Ammo:Fire(pos,vel, time)
	self.pos = pos
	self.alive = true
	self.nVel = vel
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
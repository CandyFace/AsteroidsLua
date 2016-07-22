class "FlyingSaucer"

local position = Vector2(0.0,0.0)
local randomPos = true
local split = 0
local size = 7
-- All values in the struct will be independent when used
function FlyingSaucer:FlyingSaucer(scene) -- This works like constructor
	self.flyingSaucer = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH)
	self.flyingSaucer:getMesh():addVertex(15,0,0)
	self.flyingSaucer:getMesh():addVertex(5,-5,0)
	self.flyingSaucer:getMesh():addVertex(-5,-5,0)
	self.flyingSaucer:getMesh():addVertex(-15,0,0)
	self.flyingSaucer:getMesh():addVertex(15,0,0)
	self.flyingSaucer:getMesh():addVertex(5,5,0)
	self.flyingSaucer:getMesh():addVertex(-5,5,0)
	self.flyingSaucer:getMesh():addVertex(-3,10,0)
	self.flyingSaucer:getMesh():addVertex(3,10,0)
	self.flyingSaucer:getMesh():addVertex(5,5,0)
	self.flyingSaucer:getMesh():addVertex(-5,5,0)
	self.flyingSaucer:getMesh():addVertex(-15,0,0)
	self.randomPos = randomPos
	self.position = position
	self.size = size
	self.bulletSpeed = 150
	self.velocity = Vector2(0,0)
	self.randomDirection = random(0,10)
	self.randomRotation = random(0,10)
	self.saucerTimer = 0
	if self.randomPos then
		self.flyingSaucer:setPositionX(random(Services.Core:getXRes(),Services.Core:getXRes()))
		self.flyingSaucer:setPositionY(random(-Services.Core:getYRes(),Services.Core:getYRes()))
	else
		self.flyingSaucer:setPosition(self.position.x, self.position.y, 0)
	end
	self.hit = false
	self.canFly = false
	self.shotFired = false
	self.lineSmooth = true
	self.flyingSaucer:setColorInt(152,181,193,255)
	self.flyingSaucer:setBlendingMode(4)
	self.saucerSound = Sound("Sfx/saucer.wav")
	self.canDie = 3
	if self.randomRotation % 2 == 0 then
		self.rotVal = 45
	else
		self.rotVal = -45
	end
	self.rotVal = self.rotVal
	self.speed = 4
	self.flyingSaucer:Scale (2,2,2)
	self.point = 200
	self.colSize = 20
	self.explosion = Sound("Sfx/explosion2.wav")
	self.direction = 0
	self.shotAngle = 0
	--self.rndRotVal = math.random(-self.rotVal,self.rotVal)
	scene:addChild(self.flyingSaucer)
end

function FlyingSaucer:SmallerAsteroid()
	self.speed = 5
	self.rotVal = self.rotVal
	self.flyingSaucer:setScale(1.2,1.2,1.2)
	self.point = 1000
	self.colSize = 50
	self.explosion = Sound("Sfx/explosion3.wav")
	self.shotAngle = 0

	
end

function FlyingSaucer:ControlDirection(object, rDir)
	if object.randomDirection % 2 == 0 then
		object.flyingSaucer:setPositionX(object.flyingSaucer:getPosition().x - cos(degToRad(rDir)) * object.speed)
		object.flyingSaucer:setPositionY(object.flyingSaucer:getPosition().y - sin(degToRad(rDir)) * object.speed)
	else
		object.flyingSaucer:setPositionX(object.flyingSaucer:getPosition().x + cos(degToRad(rDir)) * object.speed)
		object.flyingSaucer:setPositionY(object.flyingSaucer:getPosition().y + sin(degToRad(rDir)) * object.speed)
	end
end

function FlyingSaucer:FlyOnCountDown()
	--print("Saucer ".. saucerCountDown)
	if saucerCountDown <= 0 and self.canFly then
		self.canFly = false
		saucerCountDown = random(minCount,maxCount)
	elseif saucerCountDown <= 0 then
		self.canFly = true
		saucerCountDown = random(minCount,maxCount)
		self.flyingSaucer:setPositionX(random(Services.Core:getXRes(),Services.Core:getXRes()))
		self.flyingSaucer:setPositionY(random(-Services.Core:getYRes(),Services.Core:getYRes()))
	end
	if self.canFly and saucerCountDown > 5 then
		stayWithinBoundary(self.flyingSaucer)
	end
	
	if self.canFly and self.saucerTimer > 3 then
		self:ControlDirection(self, self.rotVal)
		if self.saucerTimer > 6 then
			self.saucerTimer = 0
		end	
	elseif self.canFly and saucerCountDown < 5 then
			self:ControlDirection(self, self.rotVal)
	elseif self.canFly then
		self:ControlDirection(self, 0)
		if not self.saucerSound:isPlaying() then
			self.saucerSound:Play(true)
		end
	elseif not self.canFly then
		self.saucerSound:Stop()
	end

end

function FlyingSaucer:FireBullet(dt, object, saucer)
		--self.shotAngle = math.atan2(player.playerMain:getPosition().y - saucer.flyingSaucer:getPosition().y, player.playerMain:getPosition().x - saucer.flyingSaucer:getPosition().x)
		saucer:ShootingDifficulty(saucer)
		object.position = Vector2(cos(object.direction + saucer.shotAngle) * 1.15, sin(object.direction + saucer.shotAngle) * 1.15)
		object.velocity = Vector2(cos(object.direction + saucer.shotAngle) * saucer.bulletSpeed, sin(object.direction + saucer.shotAngle) * saucer.bulletSpeed)
		object.alive = true
		object:Fire(Vector2(object.position.x + saucer.flyingSaucer:getPosition().x, object.position.y + saucer.flyingSaucer:getPosition().y),
		Vector2(object.velocity.x + 0, object.velocity.y + 0), object.timer)
end

function FlyingSaucer:Explode()
	player.visualScore = player.visualScore + saucer.point 

	saucer.explosion:Play()
	saucer.flyingSaucer:setPosition(10000,10000,0)
	saucerCountDown = random(minCount,maxCount)
	saucer.canFly = false
	--print("candie :" .. saucer.canDie)
	if saucer.canDie > 0 then
		saucer.canDie = saucer.canDie - 1
	else
		saucer:SmallerAsteroid()
	end
end

function FlyingSaucer:ShootingDifficulty(saucer)
	if self.canDie > 0 then
		self.shotAngle = degToRad(random(-360,360))
	elseif player.visualScore <= 10000 then
		self.shotAngle = math.atan2(player.playerMain:getPosition().y - saucer.flyingSaucer:getPosition().y + random(-100,100), player.playerMain:getPosition().x - saucer.flyingSaucer:getPosition().x + random(-100,100))
	elseif player.visualScore >= 10000 and player.visualScore <= 35000 then 
		self.shotAngle = math.atan2(player.playerMain:getPosition().y - saucer.flyingSaucer:getPosition().y + random(-50,50), player.playerMain:getPosition().x - saucer.flyingSaucer:getPosition().x + random(-50,50))	
	else
		self.shotAngle = math.atan2(player.playerMain:getPosition().y - saucer.flyingSaucer:getPosition().y, player.playerMain:getPosition().x - saucer.flyingSaucer:getPosition().x)
	end
end

function FlyingSaucer:Fire(position, velocity, timer)
	self.position = position
	self.velocity = velocity
	self.alive = true
	self.time = timer

	self.flyingSaucer:setPosition(self.position.x, self.position.y,0)
end

function FlyingSaucer:setSize(_size)
	size = _size
end

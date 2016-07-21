class "Asteroid"

local position = Vector2(0.0,0.0)
local randomPos = true
local shape = 1
local split = 0
local size = 7

-- All values in the struct will be independent when used
function Asteroid:Asteroid(scene) -- This works like constructor
	asteroid = SceneMesh.SceneMeshWithType(Mesh.LINE_LOOP_MESH) 
	self.asteroid = asteroid --[[ 'self' is the newly created object ]] --
	self.randomPos = randomPos
	self.position = position
	if self.randomPos then
		asteroid:setPositionX(random(-Services.Core:getXRes() + 50, Services.Core:getXRes() - 50))
		asteroid:setPositionY(random(-Services.Core:getYRes() + 50, Services.Core:getYRes() - 50))
	else
		asteroid:setPosition(self.position.x, self.position.y, 0)
	end
	asteroid.shape = Asteroid:Shapes()
	--asteroid:getMesh():setMeshType(Mesh.LINE_LOOP_MESH)
	asteroid.hit = false
	self.shape = shape
	asteroid.split = split
	asteroid.size = size
	asteroid.canSplit = 2
	asteroid.mediumASize = 3
	asteroid.lineSmooth = true
	asteroid.randomDirection = random(0,10)
	asteroid:setColorInt(152,181,193,255)
	asteroid:setBlendingMode(2)
	if asteroid.size == 7 then
		asteroid.speed = 2
		asteroid.rotVal = 30
		asteroid:Scale (5, 5, 3)
		asteroid.point = 20
		asteroid.colSize = 100
		asteroid.explosion = Sound("Sfx/explosion.wav")
	elseif asteroid.size == 5 then
		asteroid.speed = 6
		asteroid.rotVal = 50
		asteroid:Scale (3,3,3)
		asteroid.point = 50
		asteroid.colSize = 50
		asteroid.explosion = Sound("Sfx/explosion2.wav")
	else
		asteroid.rotVal = 100
		asteroid.speed = 10
		asteroid:Scale (1,1,1)
		asteroid.point = 100
		asteroid.colSize = 20
		asteroid.explosion = Sound("Sfx/explosion3.wav")
	end
	asteroid.rndRotVal = math.random(-asteroid.rotVal,asteroid.rotVal)
	asteroid.rndSpeed = math.random(asteroid.speed)
	scene:addChild(asteroid)
end

function Asteroid:Shapes()
		if shape == 1 then
			asteroid:getMesh():addVertex(-4,-12, 0)
			asteroid:getMesh():addVertex(7,-13, 0)
			asteroid:getMesh():addVertex(13,-4, 0)
			asteroid:getMesh():addVertex(15,2, 0)
			asteroid:getMesh():addVertex(6,13, 0)
			asteroid:getMesh():addVertex(0,13, 0)
			asteroid:getMesh():addVertex(0,4, 0)
			asteroid:getMesh():addVertex(-8,15, 0)
			asteroid:getMesh():addVertex(-13,4, 0)
			asteroid:getMesh():addVertex(-7,1, 0)
			asteroid:getMesh():addVertex(-15,-3, 0)
		elseif shape == 2 then
			asteroid:getMesh():addVertex(-6,-12, 0)
			asteroid:getMesh():addVertex(0,-5, 0)
			asteroid:getMesh():addVertex(8,-12, 0)
			asteroid:getMesh():addVertex(15,-5, 0)
			asteroid:getMesh():addVertex(15,0, 0)
			asteroid:getMesh():addVertex(15,6, 0)
			asteroid:getMesh():addVertex(3,13, 0)
			asteroid:getMesh():addVertex(-7,13, 0)
			asteroid:getMesh():addVertex(-14,6, 0)
			asteroid:getMesh():addVertex(-13,-5, 0)
		elseif shape == 3 then
			asteroid:getMesh():addVertex(-7,-12, 0)
			asteroid:getMesh():addVertex(1,-9, 0)
			asteroid:getMesh():addVertex(8,-12, 0)
			asteroid:getMesh():addVertex(15,-5, 0)
			asteroid:getMesh():addVertex(8,-3, 0)
			asteroid:getMesh():addVertex(15,4, 0)
			asteroid:getMesh():addVertex(9,13, 0)
			asteroid:getMesh():addVertex(-3,10, 0)
			asteroid:getMesh():addVertex(-6,11, 0)
			asteroid:getMesh():addVertex(-14,7, 0)
			asteroid:getMesh():addVertex(-10,-1, 0)
			asteroid:getMesh():addVertex(-14,-5,0)
		elseif shape == 4 then
			asteroid:getMesh():addVertex(-7,-11, 0)
			asteroid:getMesh():addVertex(3,-11, 0)
			asteroid:getMesh():addVertex(13,-5, 0)
			asteroid:getMesh():addVertex(13,-2, 0)
			asteroid:getMesh():addVertex(2,2, 0)
			asteroid:getMesh():addVertex(13,8, 0)
			asteroid:getMesh():addVertex(6,14, 0)
			asteroid:getMesh():addVertex(1,10, 0)
			asteroid:getMesh():addVertex(-6,14, 0)
			asteroid:getMesh():addVertex(-15,5, 0)
			asteroid:getMesh():addVertex(-14,-5, 0)
			asteroid:getMesh():addVertex(-5,-7,0)
		end
		shape = shape + 1
		if shape > 4 then
			shape = 1
		end
end

function Asteroid:Split(object)
	object.asteroid.explosion:Play()
	object.asteroid.hit = true
	object:setRandomPos(false)
	player.score = player.score + object.asteroid.point
	player.visualScore = player.visualScore + object.asteroid.point
	newPos = Vector2(object.asteroid:getPosition().x, object.asteroid:getPosition().y)
	object.asteroid:setPositionX(100000000)
	if object.asteroid.size >= object.asteroid.mediumASize then
		object:setAsteroidSize(object.asteroid.size - 2)
	end
	
	if object.asteroid.size > object.asteroid.mediumASize then
		object:setPositionXY(newPos.x, newPos.y)
		object.astShape = random(1,4)
		for i = 1, object.asteroid.canSplit do
				table.insert(asteroids, Asteroid(scene))
		end
		object.asteroid.split = object.asteroid.split + 1
	end
end

function Asteroid:setAsteroidSize(_size)
	size = _size
end

function Asteroid:getAsteroidSize()
	return size
end

function Asteroid:setSplitSize(_split)
	split = _split
end

function Asteroid:getSplitSize()
	return split
end

function Asteroid:setRandomPos(_pos)
	randomPos = _pos
end

function Asteroid:getPositionXY()
	return position
end

function Asteroid:setPositionXY(_position1, _position2)
	position.x = _position1
	position.y = _position2
end

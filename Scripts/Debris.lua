class "Debris"

function Debris:Debris()
	self.debriMesh = SceneMesh.SceneMeshWithType(Mesh.LINE_MESH)
	self.debriMesh:getMesh():createVPlane ( 5,  5,  0)
	self.debriAngle = 0
	self.debriSpeed = 50
	self.position = Vector2(0,0)
	self.velocity = Vector2(0,0)
	self.direction = 0
	self.alive = false
	self.debriMesh:setColorInt(152,181,193,255)
	self.debriMesh:setPosition(10000,10000,0)
	self.debriMesh:setBlendingMode(2)
	scene:addChild(self.debriMesh)
end

function Debris:UpdateDebris()
	if self.alive then
		self.debriMesh:setPosition(self.debriMesh:getPosition().x + self.velocity.x * 0.1, self.debriMesh:getPosition().y + self.velocity.y * 0.1, 0)
	end
end

function Debris:Spread(object, objectType)
	for i = 1, count(debris) do
		debris[i].position = Vector2(cos(degToRad(debris[i].direction + self.debriAngle)) * 1.15, sin(degToRad(debris[i].direction + self.debriAngle)) * 1.15)
		debris[i].velocity = Vector2(cos(degToRad(debris[i].direction + self.debriAngle)) * debris[i].debriSpeed, sin(degToRad(debris[i].direction + self.debriAngle)) * debris[i].debriSpeed)
		self.debriAngle = self.debriAngle + 45
		debris[i].alive = true
		debris[i]:Fire(Vector2(debris[i].position.x + objectType:getPosition().x, debris[i].position.y + objectType:getPosition().y),
		Vector2(debris[i].velocity.x + 0, debris[i].velocity.y + 0), 0)
	end
end

--Should make a new class for fire, instead of copying it :/
function Debris:Fire(position, velocity)
	self.position = position
	self.velocity = velocity
	self.alive = true

	self.debriMesh:setPosition(self.position.x, self.position.y,0)
end
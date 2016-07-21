class "UI"
require "Scripts/Player"

function UI:Update(dt)
	if debuggingSwitch then
	-- 	posYLabel.enabled = true
	-- 	posXLabel.enabled = true
	-- 	speedLabel.enabled = true
	-- 	velXLabel.enabled = true
	-- 	velYLabel.enabled = true

	-- 	posYLabel:setText("posY: " .. String.NumberToString(Player:getPlayerPosY(), 1 ))
	-- 	posXLabel:setText("posX: " .. String.NumberToString(Player:getPlayerPosX(), 1 ))
	-- 	speedLabel:setText("speed: " .. String.NumberToString(Player:getInvisTimer(), 1 ))
	-- 	velXLabel:setText("velX: " .. String.NumberToString(Player:getPlayerVelX(), 1 ))
	-- 	velYLabel:setText("velY: " .. String.NumberToString(Player:getPlayerVelY(), 1 ))
	else
	scoreLabel:setText("" .. String.NumberToString(player.visualScore, 0))
	
	--display 0 until reaches x then remove 0
	if player.survivalTimer < 9.5 then
		timerLabel:setText("0"..String.NumberToString(player.survivalTimer, 0))
	else
		timerLabel:setText(String.NumberToString(player.survivalTimer, 0))
	end

	if player.life <= 0 then
		gameOverLabel.visible = true
		gameOver = true
		gameOverTimer = gameOverTimer + 1 *dt
		print(gameOverTimer)
	end

	if gameOverTimer > 3 then
		for i = 1, table.getn(asteroids) do
			scene:removeEntity(asteroids[i].asteroid)
			asteroids[i]:setRandomPos(true)
			asteroids[i]:setAsteroidSize(7)
			asteroids[i].asteroid.hit = true -- make sure every asteroid has been hit
		end
		-- gameOver = false
		scene:removeEntity(player.playerMain)
		scene:removeEntity(player.thrustMesh)

		for i = 1, 4 do
			scene:removeEntity(player.playerExplosionMesh[i])
		end

		for i = 1, 10 do
			scene:removeEntity(saucerBullet[i].shot)
			scene:removeEntity(saucerBullet[i].pShot)
		end
		saucer.saucerSound:Stop()
		scene:removeEntity(saucer.flyingSaucer)



		collectgarbage()
		newGame = true
		gameOverLabel.visible = false
		gameLabel.visible = true
		descLabel.visible = true
		scoreLabel.visible = false
		timerLabel.visible = false
		coinLabel.visible = true
		creditLabel.visible = true
		--Services.Core:Shutdown()
	end

	-- -- Disable debug labels
	-- posYLabel.enabled = false
	-- posXLabel.enabled = false
	-- speedLabel.enabled = false
	-- velXLabel.enabled = false
	-- velYLabel.enabled = false
	end

end

--debugger switch, used to call the debug panel when true.
function toggleDebugger(debuggingSwitch)
	if debuggingSwitch then
		print('Debugger is disabled') 
		return false
	else
		print('Debugger is enabled')
		return true
	end
end
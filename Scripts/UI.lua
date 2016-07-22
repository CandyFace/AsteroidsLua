class "UI"
require "Scripts/Player"

-- UI Setup --
function UI:Init(scene)
	coinLabelTimer = 0
	totalQuarters = 0
	scoreLabel = SceneLabel("", 80, "Walkway", Label.ANTIALIAS_FULL, 0)
	scene:addChild(scoreLabel)
	
	highScoreLabel = SceneLabel("", 50, "Walkway", Label.ANTIALIAS_FULL, 0)
	scene:addChild(highScoreLabel)
	
	gameOverLabel = SceneLabel("GAME OVER!", 80, "Walkway", Label.ANTIALIAS_FULL,0)
	gameLabel = SceneLabel("ASTEROIDS!", 160, "Walkway", Label.ANTIALIAS_FULL,0)
	coinLabel = SceneLabel("Insert coin", 40, "Walkway", Label.ANTIALIAS_FULL,0)
	descLabel = SceneLabel("Press SPACE to start!", 40, "Walkway", Label.ANTIALIAS_FULL,0)
	creditLabel = SceneLabel("©1979 ATARI INC", 40, "Walkway", Label.ANTIALIAS_FULL,0)
	gameOverLabel.visible = false
	gameLabel.visible = true
	descLabel.visible = true
	gameLabel:setColorInt(152,181,193,255)
	gameOverLabel:setColorInt(152,181,193,255)
	descLabel:setColorInt(152,181,193,255)
	coinLabel:setColorInt(152,181,193,255)
	creditLabel:setColorInt(152,181,193,255)
	scoreLabel:setColorInt(152,181,193,255)
	highScoreLabel:setColorInt(152,181,193,255)
	scene:addChild(gameOverLabel)
	scene:addChild(gameLabel)
	scene:addChild(descLabel)
	scene:addChild(coinLabel)
	scene:addChild(creditLabel)
	
	creditLabel:setPositionY(-Services.Core:getYRes() + 50)
	coinLabel:setPositionY(-Services.Core:getYRes() + 150)
	descLabel:setPositionY(-Services.Core:getYRes() + 200)
	scoreLabel:setPositionX(-Services.Core:getXRes() + 200)
	scoreLabel:setPositionY(Services.Core:getYRes() - 100)
	highScoreLabel:setPositionY(Services.Core:getYRes() - 100)
end

function UI:Update(dt)

	if not newGame then
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
			if highScore == 0 then
				highScoreLabel:setText("0"..String.NumberToString(highScore, 0))
			else
				highScoreLabel:setText(String.NumberToString(highScore, 0))
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
				highScore = player.visualScore
				-- gameOver = false
				scene:removeEntity(player.playerMain)
				scene:removeEntity(player.thrustMesh)
		
				for i = 1, 4 do
					scene:removeEntity(player.playerExplosionMesh[i])
				end

				for i = 1, debriPieces do
					scene:removeEntity(debris[i].debriMesh)
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
				highScoreLabel.visible = false
				coinLabel.visible = true
				creditLabel.visible = true
				--Services.Core:Shutdown()
			end
		end
	else
		ui:coinBlink(dt)
	end
	-- -- Disable debug labels
	-- posYLabel.enabled = false
	-- posXLabel.enabled = false
	-- speedLabel.enabled = false
	-- velXLabel.enabled = false
	-- velYLabel.enabled = false

end

function UI:coinBlink(dt)
	if totalQuarters < 1 and newGame then
	coinLabelTimer = coinLabelTimer + 1 *dt
		if round(coinLabelTimer,0) % 2 == 0 then
			coinLabel.visible = true
		else
			coinLabel.visible = false
		end
	end
end

-- --debugger switch, used to call the debug panel when true.
-- function toggleDebugger(debuggingSwitch)
-- 	if debuggingSwitch then
-- 		print('Debugger is disabled') 
-- 		return false
-- 	else
-- 		print('Debugger is enabled')
-- 		return true
-- 	end
-- end
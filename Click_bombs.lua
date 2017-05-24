-- Bombs (balls) are being spawned at random (0..MAX_W, 0..MAX_H), players can click on them to earn points
-- When player click somewhere, heart is printed there, when bomb is exploded by clicking, explosion effect will be there
-- There can be only MAX_BOMBS on map at the same time
-- Command "pause" will stop / start bombs from being spawned, command "!showbombs" will print box over every bomb every 0.5 sec
TIME_BETWEEN_BOMBS = 6
MAX_BOMBS = 30
MAX_H = 400
MAX_W = 800
EXPLOSION_POWER = 100
EXPLOSION_DISTANCE = 80

seconds = 0
bombs = {}
bombsDisplayed = false
pause = false

function eventLoop(currentTime, remainingTime)
	seconds = seconds + 0.5
	local obj = tfm.get.room.objectList;
	if seconds == TIME_BETWEEN_BOMBS then do
		seconds = 0
		if #bombs < MAX_BOMBS and not pause then do
			bombs[#bombs + 1] = tfm.exec.addShamanObject(6, math.random(0, MAX_W), math.random(0, MAX_H)) -- id 23 is bomb, but they're not working
		end end
	end end
	if bombsDisplayed then
		for i = 1, #bombs do
			ui.removeTextArea(i, nil)
			ui.addTextArea(i, i, nil, obj[bombs[i]].x - 5, obj[bombs[i]].y - 5, 10, 10, 0xFFFFFF, 0x0, 0.5, false)
		end
	end
end

function eventMouse(playerName, x, y)
	if #bombs > 0 then
		explodeBomb(x, y, playerName)
	end
	tfm.exec.displayParticle(5, x, y, 0, 0, 0, 0, nil)
end

function eventChatCommand(playerName, message)
	message = string.lower(message)
	if message == "showbombs" then do
		local obj = tfm.get.room.objectList;
		if bombsDisplayed then
			for i = 1, #bombs do
				ui.removeTextArea(i, nil)
			end
		else
			for i = 1, #bombs do
				ui.addTextArea(i, i, nil, obj[bombs[i]].x - 5, obj[bombs[i]].y - 5, 10, 10, 0xFFFFFF, 0x0, 0.5, false)
			end
		end
		bombsDisplayed = true --not bombsDisplayed
	end elseif message == "pause" then
		pause = not pause
	end
end

function eventNewPlayer(playerName)
	system.bindMouse(playerName, true)
	tfm.exec.respawnPlayer(playerName)
end

function eventPlayerLeft(playerName)
	system.bindMouse(playerName, false)
end

function explodeBomb(objX, objY, playerName)
	local best, bestVal = -1, 2000
	local bestValDebug = 99999
	for i = 1, #bombs do
		val = tfm.get.room.objectList[bombs[i]]
		local iVal = math.pow(val.x - objX, 2) + math.pow(val.y - objY, 2)
		if iVal < bestVal then
			best = i
			bestVal = iVal
		end
		if iVal < bestValDebug then
			bestValDebug = iVal
		end
	end
	print("Best: " .. bestValDebug)
	local iVal = tfm.get.room.objectList[bombs[best]]
	if best ~= -1 then do
		tfm.exec.removeObject(bombs[best])
		tfm.exec.explosion(iVal.x, iVal.y, EXPLOSION_POWER, EXPLOSION_DISTANCE, false)
		ui.removeTextArea(bombs[best], nil)
		tfm.exec.displayParticle(10, iVal.x, iVal.y, 0, 0, 0, 0, nil)
		bombs[best], bombs[#bombs] = bombs[#bombs], bombs[best]
		bombs[#bombs] = nil
		tfm.exec.setPlayerScore(playerName, 1, true)
	end end
end

-- programm

for playerName in pairs(tfm.get.room.playerList) do
	eventNewPlayer(playerName)
end
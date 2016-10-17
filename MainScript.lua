mouse = {}

function eventNewPlayer(playerName)
    for i = 1, 255 do
        tfm.exec.bindKeyboard(playerName, i, true, true)
    end
	mouse[playerName] = {
	                      ["spawn"] = {
	                        ["id"] = 0,
	                        ["need"] = false
	                      },
	                      ["jump"] = false
	                    }
end    

function eventKeyboard(playerName, key, down, x, y)
    if key == 79 then                           --'o'
        tfm.exec.setShaman(playerName)
    elseif key == 80 then                       --'p'
        tfm.exec.addShamanObject(24, x, y + 10)
    elseif key == 16 then                       --'Shift'
        tfm.exec.movePlayer(playerName, x, y - 50, false, 0, -10, false)
    elseif key == 9 then do                     -- 'tab'
		if mouse[playerName]["spawn"]["need"] == false and mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, true)
        end
        mouse[playerName]["spawn"]["need"] = true
    end elseif key == 192 then do                   -- 'apostrophe: [`] '
        mouse[playerName]["spawn"]["need"] = false
        if mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, false)
        end
    end elseif key == 219 then                  -- '['
        mouse[playerName]["spawn"]["id"] = 26   -- blue portal
    elseif key == 221 then       -- ']'
        mouse[playerName]["spawn"]["id"] = 27   -- orange portal
    elseif key == 66 then        -- 'u'
        mouse[playerName]["spawn"]["id"] = 59   -- bubble
    elseif key == 45 then        -- 'p'
        tfm.exec.explosion(x, y, 10, 50, false)
    elseif key == 115 then       -- 'F4'
        if mouse[playerName]["spawn"]["need"] == false and mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, true)
        end
        mouse[playerName]["jump"] = true
    end
end

function eventMouse(playerName, x, y)
    if mouse[playerName]["spawn"]["need"] == true then
        tfm.exec.addShamanObject(mouse[playerName]["spawn"]["id"], x, y, 0, 0, 0)
    end
    if mouse[playerName]["jump"] == true then do
        tfm.exec.movePlayer(playerName, x, y, false, 0, 0, false)
        if mouse[playerName]["spawn"]["need"] == false then do
            system.bindMouse(playerName, false)
        end
        end
        mouse[playerName]["jump"] = false
    end
    end
end

function eventEmotePlayed(playerName, emo)
    if emo == 7 then
        tfm.exec.setShaman(playerName)
    elseif emo == 4 then
        tfm.exec.setVampirePlayer(playerName)
    end
end

for name, player in pairs(tfm.get.room.playerList) do
    eventNewPlayer(name)
end
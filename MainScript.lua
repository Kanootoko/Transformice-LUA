mouse = {}
autoNewGame = true


function eventNewPlayer(playerName)
    for i = 1, 255 do
        tfm.exec.bindKeyboard(playerName, i, true, true)
    end
	mouse[playerName] = {
	                      ["spawn"] = {
	                        ["id"] = 0,
	                        ["need"] = false,
	                        ["ghost"] = false,
                            ["2steps"] = false,
                            ["1stStep"] = {["was"] = false, ["x"] = 0, ["y"] = 0}
	                      },
	                      ["jump"] = false
	                    }
end    

function eventPlayerLeft(playerName)
    if mouse[playerName]["spawn"]["need"] == true or mouse[playerName]["jump"] == true then
        system.bindMouse(playerName, false)
    end
    mouse[playerName] = nil
end

function eventPlayerDied(playerName)
    tfm.exec.respawnPlayer(playerName)
end

function eventKeyboard(playerName, key, down, x, y)
    if key == 79 then                           --'o'
        tfm.exec.setShaman(playerName)
    elseif key == 80 then                       --'p'
        tfm.exec.addShamanObject(24, x, y + 10)
    elseif key == 105 then                      -- gray-9
        tfm.exec.setNameColor(playerName, math.random(0, 0xFFFFFF))
    elseif key == 16 then                       --'Shift'
        tfm.exec.movePlayer(playerName, x, y - 50, false, 0, -10, false)
    elseif key == 9 then do                     -- 'tab'
		if mouse[playerName]["spawn"]["need"] == false and mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, true)
        end
        mouse[playerName]["spawn"]["need"] = true
    end elseif key == 192 then do               -- 'apostrophe: [`] '
        mouse[playerName]["spawn"]["need"] = false
        if mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, false)
        end
    end elseif key == 219 then                  -- '['
        mouse[playerName]["spawn"]["id"] = 26   -- blue portal
    elseif key == 221 then                      -- ']'
        mouse[playerName]["spawn"]["id"] = 27   -- orange portal
    elseif key == 66 then                       -- 'b'
        mouse[playerName]["spawn"]["id"] = 59   -- bubble
    elseif key == 120 then                      -- 'F9'
        mouse[playerName]["spawn"]["id"] = -1
    elseif key == 45 then                       -- 'insert'
        tfm.exec.explosion(x, y, 10, 50, false)
    elseif key == 115 then                      -- 'F4'
        if mouse[playerName]["spawn"]["need"] == false and mouse[playerName]["jump"] == false then
            system.bindMouse(playerName, true)
        end
        mouse[playerName]["jump"] = true
    elseif key == 104 then                      -- grey '8'
        tfm.exec.respawnPlayer(playerName)
    end
end

function eventChatCommand(playerName, message)
    message = string.lower(message)
    if message == "clear" then do
        local ids = {}
        local k = 1
        for i in pairs(tfm.get.room.objectList) do
            ids[k] = i
            k = k + 1
        end
        for i = 1, k do
            tfm.exec.removeObject(ids[i])
            ids[i] = nil
        end

    end elseif sameStart(message, "spawn") == true then
        mouse[playerName]["spawn"]["id"] = tonumber(string.sub(message, 7, string.len(message)))
    elseif message == "autonewgame" then
        autoNewGame = not autoNewGame
        tfm.exec.disableAutoNewGame(autoNewGame)
    elseif message == "ghost" then
        mouse[playerName]["spawn"]["ghost"] = not mouse[playerName]["spawn"]["ghost"]
    elseif message == "2steps" then
        if mouse[playerName]["spawn"]["2steps"] == false then
            mouse[playerName]["spawn"]["2steps"] = true
        else do
            mouse[playerName]["spawn"]["2steps"] = false
            mouse[playerName]["spawn"]["1stStep"]["was"] = false
        end
        end
    elseif message == "cheese" then
        tfm.exec.giveCheese(playerName)
    elseif message == "win" then
        tfm.exec.playerVictory(playerName)
    end
end

function killObject(objX, objY)
    local best, bestVal = -1, 2000
--    local bestValDebug = 99999
    for i, val in pairs(tfm.get.room.objectList) do
        local iVal = math.pow(val["x"] - objX, 2) + math.pow(val["y"] - objY, 2)
        if iVal < bestVal then
            best = val["id"]
            bestVal = iVal
        end
--        if iVal < bestValDebug then
--            bestValDebug = iVal
--        end
    end
--    print("Best: " .. bestValDebug)
    if best ~= -1 then
        tfm.exec.removeObject(best)
    end
end

function eventMouse(playerName, x, y)
    if mouse[playerName]["spawn"]["need"] == true then
        if mouse[playerName]["spawn"]["id"] == -1 then
            killObject(x, y)
        elseif mouse[playerName]["spawn"]["2steps"] == false then
            tfm.exec.addShamanObject(mouse[playerName]["spawn"]["id"], x, y, 0, 0, 0, mouse[playerName]["spawn"]["ghost"])
        else
            if mouse[playerName]["spawn"]["1stStep"]["was"] == false then do
                mouse[playerName]["spawn"]["1stStep"]["x"] = x
                mouse[playerName]["spawn"]["1stStep"]["y"] = y
                mouse[playerName]["spawn"]["1stStep"]["was"] = true
            end else do
                mouse[playerName]["spawn"]["1stStep"]["was"] = false
                local len = math.pow(mouse[playerName]["spawn"]["1stStep"]["x"] - x, 2) + math.pow(mouse[playerName]["spawn"]["1stStep"]["y"] - y, 2)
                local dx = (x - mouse[playerName]["spawn"]["1stStep"]["x"]) * len / 24000
                local dy = (y - mouse[playerName]["spawn"]["1stStep"]["y"]) * len / 24000
                local ans = percentLow(dx, dy)
                dx, dy = ans["a"], ans["b"]
--                print("x0 = " .. mouse[playerName]["spawn"]["1stStep"]["x"] .. ", y0 = " .. mouse[playerName]["spawn"]["1stStep"]["y"])
--                print("x1 = " .. x .. ", y1 = " .. y)
                print("dx = " .. dx .. ", dy = " .. dy)
                tfm.exec.addShamanObject(mouse[playerName]["spawn"]["id"],
                                         mouse[playerName]["spawn"]["1stStep"]["x"],
                                         mouse[playerName]["spawn"]["1stStep"]["y"],
                                         0, dx, dy, mouse[playerName]["spawn"]["ghost"]
                                        )

            end
            end
        end
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

function sameStart(str1, str2)
    local len = math.min(string.len(str1), string.len(str2))
    if string.sub(str1, 1, len) == string.sub(str2, 1, len) then
        return true
	else
	    return false
	end
end

function absMin(a, b)
    if math.abs(a) < math.abs(b) then
        return a
    else
        return b
    end
end

function sign(a)
    return a / math.abs(a)
end

function percentLow(a, b)
    local swap = false
    if absMin(a, b) == b then do
        a, b = b, a
        swap = true
    end
    end
    local newB = 40 * sign(b)
    local newA = a / b * newB
    if swap == true then
        a, b = b, a
    end
    return {["a"] = a, ["b"] = b}
end

-- programm

for playerName in pairs(tfm.get.room.playerList) do
    eventNewPlayer(playerName)
end
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(autoNewGame)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAfkDeath(true)
system.disableChatCommandDisplay("spawn", true)
system.disableChatCommandDisplay("ghost", true)
system.disableChatCommandDisplay("2steps", true)
system.disableChatCommandDisplay("win", true)
system.disableChatCommandDisplay("cheese", true)
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
                            ["1stStep"] = {["was"] = false, ["x"] = 0, ["y"] = 0},
                            ["speed"] = -1,
                            ["absoluteAngle"] = false,
                            ["angle"] = 0
	                      },
	                      ["jump"] = false,
	                      ["res"] = {["x"] = -1, ["y"] = -1}
	                    }
end    

function eventPlayerLeft(playerName)
    if mouse[playerName]["spawn"]["need"] == true or mouse[playerName]["jump"] == true then
        system.bindMouse(playerName, false)
    end
    mouse[playerName] = nil
end

function eventPlayerDied(playerName)
    if mouse[playerName] == nil then
        return
    end
    tfm.exec.respawnPlayer(playerName)
    if mouse[playerName]["res"]["x"] ~= -1 or mouse[playerName]["res"]["y"] ~= -1 then
        tfm.exec.movePlayer(playerName, mouse[playerName]["res"]["x"], mouse[playerName]["res"]["y"], false, 0, 0, false)
    end
end

function eventNewGame()
    for playerName in pairs(tfm.get.room.playerList) do
        mouse[playerName]["res"]["x"], mouse[playerName]["res"]["y"] = -1, -1
    end
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
    elseif key == 104 then do                   -- grey '8'
        tfm.exec.killPlayer(playerName)
        eventPlayerDied(playerName)
    end
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
    elseif message == "autonewgame" then do
        autoNewGame = not autoNewGame
        tfm.exec.disableAutoNewGame(autoNewGame)
    end elseif message == "ghost" then
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
    elseif message == "res" then do
        pl = tfm.get.room.playerList[playerName]
        mouse[playerName]["res"]["x"] = pl["x"]
        mouse[playerName]["res"]["y"] = pl["y"]
    end elseif message == "res null" then
        mouse[playerName]["res"]["x"], mouse[playerName]["res"]["y"] = -1, -1
    elseif sameStart(message, "speed") then do
        mouse[playerName]["spawn"]["speed"] = tonumber(string.sub(message, 7, string.len(message)))
        print(mouse[playerName]["spawn"]["speed"])
    end elseif sameStart(message, "angle") then
        mouse[playerName]["spawn"]["angle"] = tonumber(string.sub(message, 7, string.len(message)))
    elseif message == "absoluteangle" then
        mouse[playerName]["spawn"]["absoluteAngle"] = not mouse[playerName]["spawn"]["absoluteAngle"]
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
            tfm.exec.addShamanObject(mouse[playerName]["spawn"]["id"], x, y, mouse[playerName]["spawn"]["angle"], 0, 0, mouse[playerName]["spawn"]["ghost"])
        else
            if mouse[playerName]["spawn"]["1stStep"]["was"] == false then do
                mouse[playerName]["spawn"]["1stStep"]["x"] = x
                mouse[playerName]["spawn"]["1stStep"]["y"] = y
                mouse[playerName]["spawn"]["1stStep"]["was"] = true
            end else do
                mouse[playerName]["spawn"]["1stStep"]["was"] = false
                local vx = x - mouse[playerName]["spawn"]["1stStep"]["x"]  -- vector x0->x1
                local vy = y - mouse[playerName]["spawn"]["1stStep"]["y"]  -- vector y0->y1
                local dx, dy
                if mouse[playerName]["spawn"]["speed"] < 0 then do
                    local len = math.pow(vx, 2) + math.pow(vy, 2)
                    dx = vx * len / 24000
                    dy = vy * len / 24000
                    local ans = percentLow(dx, dy)
                    dx, dy = ans["a"], ans["b"]
                end
                else do
                    dx = mouse[playerName]["spawn"]["speed"] * sign(vx)
                    dy = math.abs(dx) * sign(vy)
                end
                end
--                print("x0 = " .. mouse[playerName]["spawn"]["1stStep"]["x"] .. ", y0 = " .. mouse[playerName]["spawn"]["1stStep"]["y"])
--                print("x1 = " .. x .. ", y1 = " .. y)
                print("dx = " .. dx .. ", dy = " .. dy)
                local angle
                if mouse[playerName]["spawn"]["absoluteAngle"] == true then
                    angle = mouse[playerName]["spawn"]["angle"]
                else
                    if mouse[playerName]["spawn"]["id"] == 17 then
                        angle = mouse[playerName]["spawn"]["angle"] + getAngleCannon(vx, vy)
                    else
                        angle = mouse[playerName]["spawn"]["angle"] + getAngle(vx, vy)
                    end
                end
                tfm.exec.addShamanObject(mouse[playerName]["spawn"]["id"],
                                         mouse[playerName]["spawn"]["1stStep"]["x"],
                                         mouse[playerName]["spawn"]["1stStep"]["y"],
                                         angle, dx, dy, mouse[playerName]["spawn"]["ghost"]
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
    if a > 0 then
        return 1
    elseif a == 0 then
        return 0
    else
        return -1
    end
end

function percentLow(a, b)
    local swap = false
    if absMin(40, b) == b and absMin(40, a) == a then
        return {["a"] = a, ["b"] = b}
    end
    if absMin(a, b) == b then do
        a, b = b, a
        swap = true
    end
    end
    local newB = 40 * sign(b)
    local newA = a / b * newB
    if swap == true then
        newA, newB = newB, newA
    end
    return {["a"] = newA, ["b"] = newB}
end

function getAngleCannon(x, y) -- returns (-) angle by vector coords
    print("math.atan = ", math.atan(x / y))

    if x > 0 then
        return 90 - math.deg(math.atan(x / y))
    else
        return -90 - math.deg(math.atan(x / y))
    end
end

function getAngle(x, y)
    y = -y
    if x == 0 then
        if y >= 0 then
            return -90
        else
            return 90
        end
    elseif y == 0 then
        if x >= 0 then
            return 0
        else
            return -180
        end
    end
    if x > 0 then
        return -math.deg(math.atan(y / x))
    else
        return -180 - math.deg(math.atan(y / x))
    end
end

function getAngleCannon(x, y)
    return getAngle(x, y) + 90
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
system.disableChatCommandDisplay("angle", true)
system.disableChatCommandDisplay("absoluteangle", true)
system.disableChatCommandDisplay("speed", true)
system.disableChatCommandDisplay("win", true)
system.disableChatCommandDisplay("cheese", true)
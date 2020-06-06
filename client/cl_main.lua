local investigating = false
local isSheriff = false
local finished = 0
local payout = math.random(Config.MinCash, Config.MaxCash)
local xp = math.random(Config.MinExp, Config.MaxExp)

RegisterCommand(
    "tes",
    function(source, args)

        local text = ""

        for i = 1, #args do

            text = text .. " " .. args[i]
        end

        text = text .. " "

        -- TO-DO: Show this text on chat

        startInvestigation(source)
    end
)

function startInvestigation(source)
    Citizen.CreateThread(
        function()
            local sourceCoords = GetEntityCoords(source)
            createInvestigationMapMarker(sourceCoords)
            while isSheriff do
                Citizen.Wait(0)
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local betweencoords =
                    GetDistanceBetweenCoords(
                    coords.x,
                    coords.y,
                    coords.z,
                    sourceCoords.x,
                    sourceCoords.y,
                    sourceCoords.z,
                    true
                )
                if betweencoords <= 2.2 then
                    drawText(Config.StartWorking, 0.50, 0.90, 0.7, 0.7, true, 255, 255, 255, 255, true)
                    if IsControlJustPressed(2, 0x4AF4D473) and not pressing and not started then
                        pressing = true
                        isSheriff = true
                        startInvestigating(source)
                    end
                end
            end
        end
    )
end

-- Sheriff Job Map Marker
function createInvestigationMapMarker(sourceCoords)
    Citizen.CreateThread(
        function()
            Wait(0)
            Citizen.InvokeNative(
                0x554d9d53f696d002,
                Config.SheriffJobSprite,
                sourceCoords.x,
                sourceCoords.y,
                sourceCoords.z
            )
        end
    )
end

-- Draw text
function drawText(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    Citizen.InvokeNative(0xADA9255D, 1)
    DisplayText(str, x, y)
end

-- Start investigation, show clues map markers, 
function startInvestigating(source)
    started = true
    if Config.ShowBlips then
        Citizen.InvokeNative(0x554d9d53f696d002, Config.PointSprite, Config.Point1.x, Config.Point1.y, Config.Point1.z)
    else
    end
    Citizen.CreateThread(
        function()
            local sourceCoords = GetEntityCoords(source)
            while true do
                Wait(0)
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local betweencoords =
                    GetDistanceBetweenCoords(
                    coords.x,
                    coords.y,
                    coords.z,
                    sourceCoords.x,
                    sourceCoords.y,
                    sourceCoords.z,
                    true
                )
                if betweencoords <= Config.PointDistance and not investigating and isSheriff then
                    drawText(Config.StartInvestigate, 0.50, 0.90, 0.7, 0.7, true, 255, 255, 255, 255, true)
                    if IsControlJustPressed(2, 0x4AF4D473) and not investigating then
                        investigateClue(source)
                    end
                else
                end
            end
        end
    )
end

-- Start investigating clues
function investigateClue(source)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    if not investigating and isSheriff and started then
        pressing = false
        FreezeEntityPosition(playerPed, Config.FreezeWhileInvestigate)
        TaskStartScenarioInPlace(
            playerPed,
            GetHashKey(Config.InvestigatingAnim),
            Config.InvestigatingTime,
            true,
            false,
            false,
            false
        )
        local timer = GetGameTimer() + Config.InvestigatingTime
        if isSheriff and started then
            Citizen.CreateThread(
                function()
                    while timer >= GetGameTimer() do
                        Wait(0)
                        investigating = true
                        drawText(
                            Config.TimerMsg ..
                                " " .. tonumber(string.format("%.0f", (((GetGameTimer() - timer) * -1) / 1000))),
                            0.50,
                            0.90,
                            0.7,
                            0.7,
                            true,
                            255,
                            255,
                            255,
                            255,
                            true
                        )
                    end
                    ClearPedTasksImmediately(PlayerPedId())
                    FreezeEntityPosition(playerPed, false)
                    investigating = false
                    finished = finished + 1
                    if isSheriff and started and finished < Config.NeededPoints then
                    elseif isSheriff and started and finished >= Config.NeededPoints then
                        -- TriggerServerEvent("redemrp_sheriffjob:addMoney", payout, xp)
                        finished = 0
                        startInvestigating(source)
                    else
                    end
                end
            )
        else
        end
    else
    end
end

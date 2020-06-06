RegisterNetEvent("redemrp_sheriffjob:setJob")
AddEventHandler(
    "redemrp_sheriffjob:setJob",
    function(jobname)
        local _jobname = jobname
        TriggerEvent(
            "redemrp:getPlayerFromId",
            source,
            function(user)
                user.setJob(_jobname)
                user.setJobgrade(1)
            end
        )
    end
)

RegisterNetEvent("redemrp_sheriffjob:addMoney")
AddEventHandler(
    "redemrp_sheriffjob:addMoney",
    function(payout, xp)
        local _payout = tonumber(payout)
        local _xp = tonumber(xp)
        TriggerEvent(
            "redemrp:getPlayerFromId",
            source,
            function(user)
                user.addMoney(tonumber(_payout))
                user.addXP(tonumber(_xp))
            end
        )
    end
)

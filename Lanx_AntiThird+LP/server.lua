local maxPing = 150 
local maxPacketLoss = 10.0 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        for _, playerId in ipairs(GetPlayers()) do
            local ping = GetPlayerPing(playerId)
            local packetLoss = GetPlayerPacketLoss(playerId) 

            if ping >= maxPing then
                TriggerClientEvent("packetAbuse:BlockWeapons", playerId, true)
                TriggerClientEvent("chat:addMessage", playerId, {
                    args = {"⚠️ Warning", "You Cant Use Weapons Because of Your Ping"}
                })
            elseif packetLoss >= maxPacketLoss then
                TriggerClientEvent("packetAbuse:BlockWeapons", playerId, true)
                TriggerClientEvent("chat:addMessage", playerId, {
                    args = {"⚠️ Warning", "You Cant Use Weapons Because of Your PacketLoss"}
                })
            else
                TriggerClientEvent("packetAbuse:BlockWeapons", playerId, false)
            end
        end
    end
end)

function GetPlayerPacketLoss(playerId)
    local endpoint = GetPlayerEndpoint(playerId)
    if endpoint then
        local status, result = pcall(function()
            return GetConvarInt("player_packet_loss_" .. playerId, 0)
        end)
        if status then
            return result
        end
    end
    return 0.0
end

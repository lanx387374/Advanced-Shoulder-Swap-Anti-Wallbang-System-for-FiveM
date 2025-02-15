local disableWeapons = false

RegisterNetEvent("packetAbuse:BlockWeapons")
AddEventHandler("packetAbuse:BlockWeapons", function(state)
    disableWeapons = state
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if disableWeapons then
            local playerPed = PlayerPedId()
            if IsPedArmed(playerPed, 7) then
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true) 
            end
        end
    end
end)
local camtoggle = false
local cam = nil
local waitTime = 1000

function ToggleCamera()
    local playerPed = PlayerPedId()

    if not IsPedArmed(playerPed, 14) or not IsPlayerFreeAiming(PlayerId()) then
        return
    end

    camtoggle = not camtoggle

    if camtoggle then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        AttachCamToPedBone(cam, playerPed, 31086, -0.3, -1.2, 0.1, GetEntityHeading(playerPed) + .0)
        SetCamAffectsAiming(cam, false)
        SetCamFov(cam, 50.0)
        RenderScriptCams(true, true, 500, true, true)
        Citizen.CreateThread(UpdateCameraRotation)
    else
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

function UpdateCameraRotation()
    while camtoggle do
        Citizen.Wait(1)
        if cam then
            SetCamRot(cam, GetEntityRotation(PlayerPedId(), 2), 2)
        end
    end
end

RegisterCommand("shoulderSwap", ToggleCamera, false)
RegisterKeyMapping("shoulderSwap", "Shoulder Swap", "keyboard", "E")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(waitTime)
        
        if IsPlayerFreeAiming(PlayerId()) then
            waitTime = 0
            if IsControlJustPressed(0, 246) then
                ToggleCamera()
            end
        else
            waitTime = 1000
            camtoggle = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local aiming = IsPlayerFreeAiming(PlayerId())

        if aiming then
            local hit, hitPos = GetBlockingObject()
            
            if hit then
                crosshairBlocked = true
                ShowXMark(hitPos)
                DisablePlayerFiring(PlayerId(), true) 
            else
                crosshairBlocked = false
            end
        else
            crosshairBlocked = false
        end
    end
end)

function GetBlockingObject()
    local playerPed = PlayerPedId()
    local startCoords = GetPedBoneCoords(playerPed, 0x6F06) 
    local forwardVector = GetEntityForwardVector(playerPed)
    local endCoords = startCoords + (forwardVector * 2.0)

    local rayHandle = StartShapeTestRay(startCoords.x, startCoords.y, startCoords.z, endCoords.x, endCoords.y, endCoords.z, -1, playerPed, 0)
    local _, hit, hitPos = GetShapeTestResult(rayHandle)

    if hit == 1 then
        return true, hitPos
    end
    return false, nil
end

function ShowXMark(pos)
    DrawText3D(pos.x, pos.y, pos.z, "🛑")
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- client/main.lua

ESX = exports["es_extended"]:getSharedObject()

local playerInAircraft = false
local aircraftBlips = {}

-- Function to check if the player is in an aircraft
function IsPlayerInAircraft()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleClass = GetVehicleClass(vehicle)

    return vehicleClass == 15 or vehicleClass == 64
end

-- Function to show aircraft on GPS
function ShowAircraftOnGPS()
    -- Clear existing blips
    for _, blip in ipairs(aircraftBlips) do
        RemoveBlip(blip)
    end
    aircraftBlips = {}

    -- Find all aircraft in the game
    for vehicle in EnumerateVehicles() do
        if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
            local blip = AddBlipForEntity(vehicle)
            SetBlipSprite(blip, 64) -- Helicopter icon
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 1)
            table.insert(aircraftBlips, blip)
        end
    end
end

-- Main thread to check player status and update GPS
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second

        if IsPlayerInAircraft() then
            if not playerInAircraft then
                playerInAircraft = true
            end
            ShowAircraftOnGPS()
        else
            if playerInAircraft then
                playerInAircraft = false
                -- Remove all aircraft blips when player is not in an aircraft
                for _, blip in ipairs(aircraftBlips) do
                    RemoveBlip(blip)
                end
                aircraftBlips = {}
            end
        end
    end
end)

-- Function to enumerate vehicles
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        if not handle or handle == -1 then
            EndFindVehicle(handle)
            return
        end

        local success
        repeat
            coroutine.yield(veh)
            success, veh = FindNextVehicle(handle)
        until not success

        EndFindVehicle(handle)
    end)
end

--[[
%% autostart
%% properties
%% events
%% globals
--]]

local HEATING_START_T           = 40
local HEATING_STOP_T            = 47
local MAX_FREON_T               = 57

local HOT_WATER_SENSOR_ID       = 57
local FREON_SENSOR_ID           = 72
local HEAT_PUMP_RELEY_ID        = 37
local WATER_PUMP_RELEY_ID       = 38
local START_HEATING_BUTTON_ID   = 70
local STOP_HEATING_BUTTON_ID    = 69

function water_t()
	return tonumber(fibaro:getValue(HOT_WATER_SENSOR_ID, "value"))
end

function freon_t()
	return tonumber(fibaro:getValue(FREON_SENSOR_ID, "value"))
end

function turnOn_heating()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(HEAT_PUMP_RELEY_ID, "value")) == 0)
    then
	    fibaro:call(HEAT_PUMP_RELEY_ID, "turnOn")
        fibaro:debug('Heat pump started')
    end
end

function turnOff_heating()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(HEAT_PUMP_RELEY_ID, "value")) == 1)
    then
	    fibaro:call(HEAT_PUMP_RELEY_ID, "turnOff")
        fibaro:debug('Heat pump stopped')
    end
end

function turnOn_pump()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(WATER_PUMP_RELEY_ID, "value")) == 0)
    then
	    fibaro:call(WATER_PUMP_RELEY_ID, "turnOn")
        fibaro:debug('Pump started')
    end
end

function turnOff_pump()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(WATER_PUMP_RELEY_ID, "value")) == 1)
    then
        fibaro:call(WATER_PUMP_RELEY_ID, "turnOff")
        fibaro:debug('Pump stopped')
    end
end

function start_heating()

    fibaro:debug('Water Heating started')


    while true do

        if (stop_heating_button_pressed())
        then
            fibaro:debug('Water Heating stopped')
            break
        end

        if (water_t() >= HEATING_STOP_T)
        then
            fibaro:debug('Water Heating completed')
            break
        end

        fibaro:debug('Water Heating in progress: ' .. water_t())

        turnOn_pump()

        if (freon_t() >= MAX_FREON_T)
        then
            turnOff_heating()
        end

        if (freon_t() < MAX_FREON_T)
        then
            turnOn_heating()
        end  

        fibaro:sleep(5000) -- Run every 5 SECOND
    end

    turnOff_pump()
    turnOff_heating()

end

function water_and_heat_pumps_started()
    return tonumber(fibaro:getValue(HEAT_PUMP_RELEY_ID, "value")) == 1 and tonumber(fibaro:getValue(WATER_PUMP_RELEY_ID, "value")) == 1
end

function start_heating_button_pressed()
    return fibaro:getValue(START_HEATING_BUTTON_ID, "value") == "1"
end

function stop_heating_button_pressed()
    return fibaro:getValue(STOP_HEATING_BUTTON_ID, "value") == "1"
end

function need_heating()
    -- if heating was manualy started
    if (
        (water_and_heat_pumps_started())
        or
        (start_heating_button_pressed())
    )
    then
    	return true
	end

    turnOff_pump()
    turnOff_heating()

    fibaro:debug('Water temperature: ' .. water_t())
    return water_t() < HEATING_START_T
end


while true do
    if (need_heating())
    then
        start_heating()
    end
    fibaro:sleep(5*1000)
end


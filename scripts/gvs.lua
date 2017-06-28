--[[
%% properties
%% events
%% globals
--]]

local HEATING_START_T   = 28
local HEATING_STOP_T    = 45

function water_t()
	return tonumber(fibaro:getValue(31, "value"))
end

function freon_t()
	return tonumber(fibaro:getValue(32, "value"))
end

function turnOn_heating()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(37, "value")) == 0)
    then
	    fibaro:call(37, "turnOn")
        fibaro:debug('Heat pump started')
    end
end

function turnOff_heating()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(37, "value")) == 1)
    then
	    fibaro:call(37, "turnOff")
        fibaro:debug('Heat pump stopped')
    end
end

function turnOn_pump()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(38, "value")) == 0)
    then
	    fibaro:call(38, "turnOn")
        fibaro:debug('Pump started')
    end
end

function turnOff_pump()
    fibaro:sleep(1000)
    if (tonumber(fibaro:getValue(38, "value")) == 1)
    then
        fibaro:call(38, "turnOff")
        fibaro:debug('Pump stopped')
    end
end

function start_heating()

    fibaro:debug('Water Heating started')


    while true do

        if (water_t() >= HEATING_STOP_T)
        then
            fibaro:debug('Water Heating completed')
            break
        end

        fibaro:debug('Water Heating in progress: ' .. water_t())

        turnOn_pump()

        if (freon_t() >= 57)
        then
            turnOff_heating()
        end

        if (freon_t() < 57)
        then
            turnOn_heating()
        end  

        fibaro:sleep(5000) -- Run every 5 SECOND
    end

    turnOff_pump()
    turnOff_heating()

end

function need_heating()
    fibaro:debug('Water Temp test started')

    for i=0,10,1 
    do
        if (water_t() > HEATING_START_T)
        then
            break
        end
        turnOn_pump()
        fibaro:sleep(30*1000)
    end
    turnOff_pump()
    turnOff_heating()


    fibaro:debug('Water Temp test completed: '..water_t())
    return water_t() < HEATING_START_T
end

turnOff_heating()
turnOff_pump()

while true do
    if (need_heating())
    then
        start_heating()
    end
    fibaro:sleep(30*60*1000) -- sleep for 30 minutes
end


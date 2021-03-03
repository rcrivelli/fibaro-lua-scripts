--[[
%% properties
2502 value
%% globals
--]]

if fibaro:countScenes()>1 then
  	--fibaro:debug("Kill second Scene...")
    --fibaro:debug("-")
 	fibaro:abort()
end

local luxId = 2502
local lux = tonumber(fibaro:getValue(luxId, "value"))
local luxThreshold = 20
local maxDuration = 30
local room = fibaro:getRoomNameByDeviceID(luxId)
local run = 0
local timeCounter = 0
local phoneID = {2462,2485}

fibaro:debug('Check Light on v.01 gestartet.')

if (lux > 20) then
  fibaro:debug('Das Licht im Raum '..room..' wurde eingeschaltet. Zeit bis zur Notification: '..maxDuration..' min.')
  ActionLightOn()
end



function ActionLightOn()
    run = 1
    while run == 1 do
        if(timeCounter >= maxDuration) then
            fibaro:debug('Das Licht im Raum '..room..' brennt seit '..maxDuration..' Minuten. Wenn möglich bitte ausschalten.')
            sendPush('Das Licht im Raum '..room..' brennt seit '..maxDuration..' Minuten. Wenn möglich bitte ausschalten.')
			run = 0
        else
            timeCounter = timeCounter + 1
		end
        fibaro:sleep(60*1000)
    end
end


function sendPush(text)
 if (phoneID[1] ~= nil) then
  for i=1, #phoneID do
     if phoneID[i] ~= nil then
       fibaro:debug('Versende Push an ID ' .. phoneID[i] .. ': ' .. text)
       fibaro:call(phoneID[i],'sendPush', text, 'alarm')
     end
  end
 end
end
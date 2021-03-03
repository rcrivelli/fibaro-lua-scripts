--[[
%% properties
2503 value
%% globals
--]]

local humID = 2503
local SecomatID = 2461
local highSummer = 60
local lowSummer = 50
local highWinter = 50
local lowWinter = 40
local durationSecomat = 30
local phoneID = {2462,2485} -- phone IDs for push notification
local run = 0
local Season = fibaro:getGlobalValue("Season")
local high = 0
local low = 0
local timeCounter = 0


if fibaro:countScenes()>1 then
  	--fibaro:debug("Kill second Scene...")
    --fibaro:debug("-")
 	fibaro:abort()
end

function actionToHigh()

    fibaro:call(SecomatID, "turnOn")
    run = 1

    while run == 1 do

        local hum = tonumber(fibaro:getValue(humID, "value"))
		if hum <= low then
            fibaro:call(SecomatID, "turnOff")
            local room = fibaro:getRoomNameByDeviceID(humID)

            Debug( 'blue', 'Luftfeuchtigkeit im Raum: ' .. room .. ' ist mit ' ..hum.. '% im ' ..Season.. ' wieder in Ordnung.')
            sendPush('Luftfeuchtigkeit im Raum: ' .. room .. ' ist mit ' ..hum.. '% im ' ..Season.. ' wieder in Ordnung. Secomat wurde ausgeschaltet.')
			run = 0

		elseif(timeCounter >= durationSecomat) then
            fibaro:call(SecomatID, "turnOff")
            local room = fibaro:getRoomNameByDeviceID(humID)

            Debug( 'blue', 'Luftfeuchtigkeit im Raum: ' .. room .. ' wurde auf ' ..hum.. '% gesenkt.')
            sendPush('Luftfeuchtigkeit im Raum: ' .. room .. ' wurde auf ' ..hum.. '% gesenkt. Der Secomat wurde ausgeschaltet.')
			run = 0
        else
            timeCounter = timeCounter + 1
		end

  		fibaro:sleep(60*1000)
	end

end

-- Funktion zum Versenden der Push
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


if (Season == "Sommer" or Season == "Herbst") then
    high = highSummer
    low = lowSummer
else
    high = highWinter
    low = lowWinter
end

Debug = function ( color, message )
  fibaro:debug(string.format('<%s style="color:%s;">%s', "span", color, message, "span"))
end

 local hum = tonumber(fibaro:getValue(humID, "value"))

fibaro:debug('Check Luftfeuchtigkeit v.01 gestartet.')

if (hum > high) then
  local room = fibaro:getRoomNameByDeviceID(humID)
  Debug( 'blue', 'Luftfeuchtigkeit im Raum: ' .. room .. ' ist mit ' ..hum.. '% im ' ..Season.. ' zu hoch.')
  sendPush('Luftfeuchtigkeit im Raum: ' .. room .. ' ist mit ' ..hum.. ' % zu hoch. Secomat für ' ..durationSecomat.. ' Min. eingeschaltet.')
  actionToHigh()
else
  local room = fibaro:getRoomNameByDeviceID(humID)
  Debug( 'green', 'Luftfeuchtigkeit im Raum: ' .. room .. ' ist mit ' ..hum.. ' % ok.')
end
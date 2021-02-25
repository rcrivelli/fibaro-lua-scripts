--[[
%% properties
2461 power
%% globals
--]]

--Überwacht die Leistungsaufnahme der Waschmaschine und verschickt bei Ende
--eine Pushnachricht. Die Überwachung wird erst ab einer bestimmten Leistung
--vorgenommen, damit nicht ohne Lauf Nachrichten verschickt werden. Zusätzlich
--wird das Symbol des VD geändert.

local Device = 2461 -- Wallplug Secomat
local phoneID = {2462} -- phone IDs for push notification
local Duration = 120 -- Nach [s] Sekunden ausschalten
local Counter = 0 -- Zählt die Anzahl Sekunden, die das Gerät lief
local PowerOff = 0 -- Definiert, ab welcher Schwelle das Gerät als ausgeschaltet gilt

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

if fibaro:countScenes()>1 then
  	--fibaro:debug("Kill second Scene...")
    --fibaro:debug("-")
 	fibaro:abort()
end

local run = 0
local power = tonumber(fibaro:getValue(Device, "power")) -- aktuelle Leistung


fibaro:debug("Verbrauch = "..power.." Watt")

-- Starterkennung
if power > PowerOff and power < 10000 and run == 0 then
  	local TimeS = os.time() --Startzeit sichern
  	--fibaro:debug(TimeS)
  	fibaro:debug(os.date("%d.%m.%Y - Secomat wurde gestartet und bezieht aktuell "..power.." Watt"))
	sendPush(os.date("%d.%m.%Y - Secomat wurde gestartet und bezieht aktuell "..power.." Watt"))
  	run = 1

  	--Überwachungsschleife
  	while run == 1 do

 		power = tonumber(fibaro:getValue(Device, "power")) -- aktuelle Leistung
		if power <= PowerOff then
			fibaro:call(Device, "turnOff")
			local CounterMin = Counter / 60
			local CounterStd = CounterMin / 60
			local CounterMsg = 0
			local Einheit = ""
			if (CounterStd > 1) then
				CounterMsg = tonumber(string.format("%.2f", CounterStd))
				Einheit = "Std."
			elseif(CounterMin > 1) then
				CounterMsg = tonumber(string.format("%.2f", CounterMin))
				Einheit = "Min."
			else
				CounterMsg = Counter
				Einheit = "Sek."
			end

			fibaro:debug(os.date("%d.%m.%Y - Der Secomat wurde manuell nach "..CounterMsg.." "..Einheit.." ausgeschaltet"))
			sendPush(os.date("%d.%m.%Y - Der Secomat wurde manuell nach "..CounterMsg.." "..Einheit.." ausgeschaltet"))

			run = 0
		else
			Counter = Counter + 1
		end

		if Counter >= Duration then
			fibaro:call(Device, "turnOff")
			sendPush(os.date("%d.%m.%Y - Secomat wurde ausgeschaltet - Zeit abgelaufen"))
			fibaro:debug("green",(os.date("%d.%m.%Y - Secomat ausgeschaltet - Zeit abgelaufen")))
			run = 0
		end

  		fibaro:sleep(1*1000)
	end

end

fibaro:debug("---")
--[[
%% autostart
%% properties
%% globals
--]]

--------------------------------------------------------------------------
local day  = {9, 00};
local night  = {22, 00};
 --Globale Variable "TimeOfDay" mit Inhalt Day,Night,Evening und Morning muss erstellt werden
---------------------------------------------------------------------------
if fibaro:countScenes() > 1 then
  fibaro:debug("stop scene");
  fibaro:abort();
end

function timeConvert(s)
  local timestring = s
  h, m = string.match(s, "(%d+):(%d+)")
  timestring = h*60 + m
  return tonumber(timestring)
end
fibaro:debug("start instanz");

function tempFunc()
  local timeout = 0;
  local TimeOfDay = fibaro:getGlobalValue("TimeOfDay")
  local day = os.date("%H:%M", -3600+ day[1]*60*60 + day[2]*60);
  local night = os.date("%H:%M", -3600+ night[1]*60*60 + night[2]*60);
  local ostime = os.date("%H:%M", os.time());

if (night > fibaro:getValue(1, "sunriseHour") and (ostime >= night or (ostime < fibaro:getValue(1, "sunriseHour") and ostime < day) ))
      or (night < fibaro:getValue(1, "sunriseHour") and ostime >= night and ostime < day and ostime < fibaro:getValue(1, "sunriseHour")) then
    if TimeOfDay ~= "Night" then
      fibaro:debug("Nacht");
      fibaro:setGlobal("TimeOfDay", "Night");
      if timeConvert(ostime) > timeConvert(fibaro:getValue(1, "sunriseHour")) then
        timeout = timeConvert(fibaro:getValue(1, "sunriseHour")) + (1439 - timeConvert(ostime))
      else
        timeout = timeConvert(fibaro:getValue(1, "sunriseHour")) - timeConvert(ostime)
      end
      fibaro:debug ("Minuten Pausiert: "..timeout)
    end
          --fibaro:abort();
  end

  if  ((ostime >= fibaro:getValue(1, "sunsetHour") or ostime < night) and night < fibaro:getValue(1, "sunriseHour"))
      or (ostime >= fibaro:getValue(1, "sunsetHour") and ostime < night) then
    if TimeOfDay ~= "Evening" then
      fibaro:debug("Abend");
      fibaro:setGlobal("TimeOfDay", "Evening");
      if timeConvert(ostime) < timeConvert(night) then
        timeout = timeConvert(night) - timeConvert(ostime)
      else
        timeout = timeConvert(night) + (1439 - timeConvert(ostime))
      end
      fibaro:debug ("Minuten Pausiert: "..timeout)
    end
          --fibaro:abort();
  end

  if ostime >= day and ostime < fibaro:getValue(1, "sunsetHour") then
    if TimeOfDay ~= "Day" then
      fibaro:debug("Tag");
      fibaro:setGlobal("TimeOfDay", "Day");
      if timeConvert(ostime) < timeConvert(fibaro:getValue(1, "sunsetHour")) then
        timeout = timeConvert(fibaro:getValue(1, "sunsetHour")) - timeConvert(ostime)
      else
        timeout = 0
      end
      fibaro:debug ("Minuten Pausiert: "..timeout)
    end
          --fibaro:abort();
  end

  if ostime >= fibaro:getValue(1, "sunriseHour") and ostime < day then
    if TimeOfDay ~= "Morning" then
      fibaro:debug("Sonnenaufgang");
      fibaro:setGlobal("TimeOfDay", "Morning");
      if timeConvert(ostime) < timeConvert(day) then
        timeout = timeConvert(day) - timeConvert(ostime)
      else
        timeout = 0
      end
      fibaro:debug ("Minuten Pausiert: "..timeout)
    end
          --fibaro:abort();
  end
  setTimeout(tempFunc, (2*1000 + timeout*60) )
end
tempFunc()
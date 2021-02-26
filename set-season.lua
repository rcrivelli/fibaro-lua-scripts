--[[
%% autostart
%% properties
%% globals
--]]
    local zeitschaltung = 0030

Debug = function ( color, message )
  fibaro:debug(string.format('<%s style="color:%s;">%s', "span", color, message, "span"))
end

function setSeason()
	local tNow = os.date("*t")
	local dayofyear = tNow.yday
	local season
	if (dayofyear >= 79) and (dayofyear < 172) then
        fibaro:setGlobal("Season", "Fruehling");
        Debug( 'blue', 'Season auf Fruehling gesetzt')
        fibaro:debug('Versende Push an ID ' .. phoneID[i] .. ': ' .. text)

    elseif (dayofyear >= 172) and (dayofyear < 265) then
        fibaro:setGlobal("Season", "Sommer");
        Debug( 'blue', 'Season auf Sommer gesetzt')

    elseif (dayofyear >= 265) and (dayofyear < 355) then
        fibaro:setGlobal("Season", "Herbst");
        Debug( 'blue', 'Season auf Herbst gesetzt')

	else
        fibaro:setGlobal("Season", "Winter");
        Debug( 'blue', 'Season auf Winter gesetzt')

    end
end


local sourceTrigger = fibaro:getSourceTrigger();

    function tempFunc()
    local currentDate = os.date("*t");
    local startSource = fibaro:getSourceTrigger();

    if ((((currentDate.wday == 1 or currentDate.wday == 2 or currentDate.wday == 3 or currentDate.wday == 4 or currentDate.wday == 5 or currentDate.wday == 6 or currentDate.wday == 7)
    and (tonumber(os.date("%H%M")) == zeitschaltung))))
    then
    setSeason()
    end
    setTimeout(tempFunc, 60*1000)
    end

    if (sourceTrigger["type"] == "autostart")
    then
    tempFunc()

    else
    local currentDate = os.date("*t");
    local startSource = fibaro:getSourceTrigger();

    if (startSource["type"] == "other")
    then
    setSeason()
    end
    end
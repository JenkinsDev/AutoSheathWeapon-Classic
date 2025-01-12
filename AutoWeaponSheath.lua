--[[--------------------------------------------------------------------
	Auto Weapon Sheath by Nomana-Kingsfall
	Edited by JenkinsDev
	CC BY 2.0 (https://creativecommons.org/licenses/by/2.0/)
----------------------------------------------------------------------]]

--[[
Wait
https://wowwiki-archive.fandom.com/wiki/USERAPI_wait
--]]

local waitTable = {};
local waitFrame = nil;

local function AutoSheath__wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent)
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable
      local i = 1
      while(i<=count) do
        local waitRecord = tremove(waitTable,i)
        local d = tremove(waitRecord,1)
        local f = tremove(waitRecord,1)
        local p = tremove(waitRecord,1)
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p})
          i = i + 1
        else
          count = count - 1
          f(unpack(p))
        end
      end
    end)
  end
  tinsert(waitTable,{delay,func,{...}})
  return true
end


--[[
Addon

v1 global cancel animation. Bug prone due to race-conditions
v2 simplified approach?
--]]

-- track if we should cancel the interval-esqueue flow of `sheath` invocations
local cancel = false

local function sheath()
	local isSheathed = GetSheathState() == 1
	if not isSheathed then
		ToggleSheath()
	end
end

local Addon = CreateFrame("Frame", "AutoSheath", UIParent, nil)

Addon:UnregisterAllEvents()
Addon:RegisterEvent("PLAYER_REGEN_ENABLED")
Addon:RegisterEvent("LOOT_CLOSED")
Addon:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)

function Addon:PLAYER_REGEN_ENABLED()
	AutoSheath__wait(0.5, function()
		sheath()
	end)
end

function Addon:LOOT_CLOSED()
	-- Classic: when auto looting is enabled and there is no loot
	-- the weapon is not automatically sheathed
	local infight = UnitAffectingCombat("player")
	if not infight then
		cancel = false
		sheath()
	end
	
end
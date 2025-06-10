--[[
ErnSpellBooks for OpenMW.
Copyright (C) 2025 Erin Pentecost

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
local types = require("openmw.types")
local settings = require("scripts.ErnSpellBooks.settings")
local core = require("openmw.core")

-- getValidSpell returns the Spell object, if it's valid.
-- otherwise, returns nil.
local function getValidSpell(spellOrSpellID)
    if spellOrSpellID == nil then
        error("validSpell() spell is nil")
        return nil
    end
    local spell = spellOrSpellID
    if spellOrSpellID.id == nil then
        -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(Spell)
        spell = core.magic.spells.records[tostring(spellOrSpellID)]
    end
    if spell == nil then
        error("getValidSpell() bad spell")
        return nil
    end
    
    if spell.type == core.magic.SPELL_TYPE.Spell and spell.cost > 0 then
        return spell
    end

    -- it turns out that most spells are garbage.
    if spell.alwaysSucceedFlag then
        return false
    end
    if spell.autocalcFlag ~= true then
        return false
    end
    if spell.cost < 5 then
        return false
    end

    return nil
end

local function spellOk(playerLevel, spell)
    return getValidSpell(spell) ~= nil
end

local function getRandomSpell(playerLevel)
    randList = {}
    for _, spell in pairs(core.magic.spells.records) do
        if spellOk(playerLevel, spell) then
            -- get random index to insert into. 1 to size+1.
            -- # is a special op that gets size
            insertAt = math.random(1, 1+#randList) 
            table.insert(randList, insertAt, spell)
        end
    end

    -- return a random suitable spell of a reasonable power level
    return randList[1]
end


return {
    getValidSpell = getValidSpell,
    getRandomSpell = getRandomSpell,
}
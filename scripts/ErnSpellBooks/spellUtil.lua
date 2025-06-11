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
        if spell == nil then
            error("getValidSpell() bad spell id: " .. tostring(spellOrSpellID))
        end
    end

    if spell == nil then
        return nil
    end

    if spell.type ~= core.magic.SPELL_TYPE.Spell then
        return nil
    end

    -- it turns out that most spells are garbage.
    if spell.cost < 5 then
        return nil
    end
    if spell.cost > 300 then
        -- these are usually weird spells not intended for players
        return nil
    end
    if spell.alwaysSucceedFlag then
        return nil
    end
    if spell.autocalcFlag ~= true then
        return nil
    end

    return spell
end

local function spellOk(playerLevel, spell)
    if getValidSpell(spell) == nil then
        return false
    end
    -- don't unlock high level spells right away.
    return (spell.cost / 11) <= playerLevel
end

-- return a random suitable spells of a reasonable power level
local function getRandomSpells(playerLevel, count)
    local randList = {}
    for _, spell in pairs(core.magic.spells.records) do
        if spellOk(playerLevel, spell) then
            -- get random index to insert into. 1 to size+1.
            -- # is a special op that gets size
            local insertAt = math.random(1, 1 + #randList)
            table.insert(randList, insertAt, spell)
            -- settings.debugPrint(spell.id .. " cost: " .. spell.cost)
        end
    end

    return {table.unpack(randList, 1, 1 + count)}
end

local function getSpellDuration(spellOrSpellID)
    if spellOrSpellID == nil then
        error("validSpell() spell is nil")
        return 0
    end
    local spell = spellOrSpellID
    if spellOrSpellID.id == nil then
        -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(Spell)
        spell = core.magic.spells.records[tostring(spellOrSpellID)]
        if spell == nil then
            error("getValidSpell() bad spell id: " .. tostring(spellOrSpellID))
        end
    end

    if spell == nil then
        return 0
    end

    local maxDuration = 0
    for _, effect in ipairs(spell.effects) do
        maxDuration = math.max(maxDuration, effect.duration)
    end
    return maxDuration
end

return {
    getValidSpell = getValidSpell,
    getRandomSpells = getRandomSpells,
    getSpellDuration = getSpellDuration,
}

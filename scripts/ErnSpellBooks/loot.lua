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
local settings = require("scripts.ErnSpellBooks.settings")
local world = require('openmw.world')
local types = require("openmw.types")
local core = require("openmw.core")
local storage = require('openmw.storage')
local spellsutil = require("scripts.ErnSpellBooks.spells")
local books = require("scripts.ErnSpellBooks.books")
local localization = core.l10n(settings.MOD_NAME)

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end

local lootTracker = storage.globalSection(settings.MOD_NAME .. "lootTracker")
lootTracker:setLifeTime(storage.LIFE_TIME.Temporary)

local function saveState()
    return lootTracker:asTable()
end

local function loadState(saved)
    lootTracker:reset(saved)
end

local function hasScrolls(containerInstance)
    -- types.Actor.inventory(self.object)
    local inventory = types.Container.inventory(containerInstance)
    for _, item in ipairs(inventory:getAll(types.Book)) do
        local bookRecord = types.Book.record(item)
        if bookRecord.enchant ~= nil then
            settings.debugPrint("found scroll ".. bookRecord.name .." in " .. containerInstance.id)
            return true
        end
    end
    return false
end

local function onObjectActive(object)
    if (object == nil) or (object.id == nil) then
        settings.debugPrint("bad object!")
        return
    end
    if (settings.debugMode() ~= true) and (lootTracker:get(object.id) == true) then
        --settings.debugPrint("object activated again")
        return
    end
    --settings.debugPrint("object activated for the first time")

    if (types.NPC.objectIsInstance(object)) then
        -- insert spell books!
        -- roll for each spell the actor actually knows.
        local actorSpells = types.Actor.spells(object)
        for _, spell in ipairs(actorSpells) do
            local validSpell = spellsutil.getValidSpell(spell)
            if validSpell ~= nil then
                settings.debugPrint("found spell " .. validSpell.name .. " on " .. object.id)
                if settings.spawnChance() > math.random(0, 99) then
                    core.sendGlobalEvent("ernCreateSpellbook", {
                        spellID = validSpell.id,
                        corruption = nil,
                        container = object,
                    })
                end
            end
        end
    elseif (types.Container.objectIsInstance(object)) then
        local containerRecord = types.Container.record(object)
        if (containerRecord.isOrganic ~= true) and hasScrolls(object) then
            if settings.spawnChance() > math.random(0, 99) then
                -- insert random book
                core.sendGlobalEvent("ernCreateSpellbook", {
                    spellID = spellsutil.getRandomSpell().id,
                    corruption = nil,
                    container = object,
                })
            end
        end
    else
        return
    end

    -- mark as done so we don't re-insert.
    lootTracker:set(object.id, true)
end



return {
    engineHandlers = {
        onObjectActive = onObjectActive,
    }
}
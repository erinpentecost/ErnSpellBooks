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
local vfs = require('openmw.vfs')
local localization = core.l10n(settings.MOD_NAME)

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end

-- corruptionTable maps a corruptionID to a function that takes in a data arg
-- with these fields: id, caster, target, spellID, bookRecordID (unique per spell book)
local corruptionTable = {}

-- data has .id and .func
local function registerCorruption(data)
    if (data == nil) or (data.id == nil) or (data.func == nil) then
        error("RegisterCorruption() bad data")
        return
    end
    settings.debugPrint("Registered " .. data.id .. " corruption handler.")
    corruptionTable[data.id] = data.func
end

local function registerHandlers()
    -- read all corruption scripts and register them.
    -- workaround for a bunch of restrictions.
    for fileName in vfs.pathsWithPrefix("scripts\\"..settings.MOD_NAME.."\\corruptions") do
        settings.debugPrint("found " .. fileName)
        local baseName = string.lower(string.match(fileName, '(%a+)[.]lua'))
        settings.debugPrint("requiring " .. baseName)
        corruptionHandler = require("scripts.ErnSpellBooks.corruptions." .. baseName)
        for id, func in pairs(corruptionHandler.corruptions) do
            registerCorruption({id = (baseName .. "_" .. id), func = func})
        end
    end
end

local function getCorruption(corruptionID)
    -- prefix name
    local corruptionPrefix = localization("corruption_" .. tostring(corruptionID) .. "_prefix")

    -- suffix name
    local corruptionSuffix = localization("corruption_" .. tostring(corruptionID) .. "_suffix")

    -- description
    local corruptionDescription = localization("corruption_" .. tostring(corruptionID) .. "_description")

    -- func
    func = corruptionTable[corruptionID]
    if func == nil then
        --settings.debugPrint("no func found for corruptionID during registration: " .. corruptionID)
        func = function(data)
            -- check table to see if we have it.
            local corruptionHandler = corruptionTable[data.id]
            if (corruptionHandler == nil) or (corruptionHandler.func == nil) then
                -- we didn't have it, so load them all.
                registerHandlers()
                -- check cache again since we reloaded it.
                corruptionHandler = corruptionTable[data.id]
            end
            if (corruptionHandler == nil) then
                error("no func found for corruptionID: " .. data.id)
            end
            settings.debugPrint("Invoking handler for corruptionID: " .. corruptionID)
            -- strip off namespace
            data.id = string.match(data.id, '%a+_(.+)')
            return corruptionHandler(data)
        end
    end

    return {
        prefix = corruptionPrefix,
        suffix = corruptionSuffix,
        description = corruptionDescription,
        func = func
    }
end

return {
    getCorruption = getCorruption,
    registerHandlers = registerHandlers
}

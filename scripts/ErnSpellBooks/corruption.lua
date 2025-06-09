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
local localization = core.l10n(settings.MOD_NAME)

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end
--[[
Corrupted spells are spells with some extra funky effect that occurs when you
successfully cast some spell.
These effects are stable for that spell; it won't be random each cast.

Corrupted effects might apply an effect on the caster OR on the target OR invoke some lua script.

Can I get away from making spells in omwaddon? Probably not.
https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(Effects)


We can even double magnitude of effects or durations by modifying activeEffects.
https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(ActorActiveEffects) -
ActorActiveEffects:modify(value, effectId, extraParam)
    Permanently modifies the magnitude of an active effect by modifying it by the provided value.
    Note that some active effect values, such as fortify attribute effects, have no practical effect of their own, and must be paired with explicitly modifying the target stat to have any effect.
    Parameters
        #number value :
        #string effectId : effect ID
        #string extraParam : Optional skill or attribute ID
]]

local function getCorruptionNameAndDescription(corruptionID)
    local corruptionPrefix = ""
    local prefixNameKey = "corruption_" .. tostring(corruptionID) .. "_prefix"
    corruptionPrefix = localization(prefixNameKey)
    if corruptionPrefix == prefixNameKey then
        corruptionPrefix = localization("corruption_notfound_prefix")
    end

    local corruptionSuffix = ""
    local suffixNameKey = "corruption_" .. tostring(corruptionID) .. "_sufix"
    corruptionSuffix = localization(suffixNameKey)
    if corruptionSuffix == suffixNameKey then
        corruptionSuffix = localization("corruption_notfound_suffix")
    end

    local corruptionDescription = ""
    local descriptionKey = "corruption_" .. tostring(corruptionID) .. "description"
    corruptionDescription = localization(descriptionKey)
    if corruptionDescription == descriptionKey then
        corruptionDescription = "BUG! No localization for corruptionID: " .. corruptionID
    end

    return {
        prefix = corruptionPrefix,
        suffix = corruptionSuffix,
        description = corruptionDescription
    }
end

local corruptionTable = {
    ["id"] = {},
}

return {
    getCorruptionNameAndDescription = getCorruptionNameAndDescription,
    corruptionPrefixTable = corruptionPrefixTable,
    corruptionSuffixTable = corruptionSuffixTable,
}
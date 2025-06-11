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
local interfaces = require("openmw.interfaces")
local settings = require("scripts.ErnSpellBooks.settings")
local spellUtil = require("scripts.ErnSpellBooks.spellUtil")
local types = require("openmw.types")
local core = require("openmw.core")
local self = require("openmw.self")
local localization = core.l10n(settings.MOD_NAME)
local ui = require('openmw.ui')

interfaces.Settings.registerPage {
    key = settings.MOD_NAME,
    l10n = settings.MOD_NAME,
    name = "name",
    description = "description"
}

local function onActive()
    if settings.debugMode() then
        core.sendGlobalEvent("ernCreateSpellbook", {
            spellID = 'weapon eater',
            corruption = nil,
            container = self
        })
        core.sendGlobalEvent("ernCreateSpellbook", {
            spellID = 'weapon eater',
            corruption = {
                ['prefixID'] = 'style',
                ['suffixID'] = 'normal'
            },
            container = self
        })
        core.sendGlobalEvent("ernCreateSpellbook", {
            spellID = spellUtil.getRandomSpells(50, 1)[1].id,
            corruption = nil,
            container = self
        })
        core.sendGlobalEvent("ernCreateSpellbook", {
            spellID = spellUtil.getRandomSpells(3, 1)[1].id,
            corruption = {
                ['prefixID'] = 'normal',
                ['suffixID'] = 'style'
            },
            container = self
        })
    end
end

-- params: data.spellName, data.corruptionName
local function showLearnMessage(data)
    settings.debugPrint("showLearnMessage")
    if data.spellName == nil then
        error("showLearnMessage() bad spellName")
        return
    end
    if data.corruptionPrefix == nil then
        ui.showMessage(localization("learnMessage", data))
    else
        ui.showMessage(localization("learnCorruptMessage", data))
    end
    -- equip the spell, too.
    local spell = core.magic.spells.records[data.spellID]
    types.Actor.setSelectedSpell(self, spell)
end

return {
    eventHandlers = {
        ernShowLearnMessage = showLearnMessage
    },
    engineHandlers = {
        onActive = onActive
    }
}


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
local world = require("openmw.world")
local types = require("openmw.types")
local settings = require("scripts.ErnSpellBooks.settings")
local core = require("openmw.core")
local localization = core.l10n(settings.MOD_NAME)

local bookShapes = {
    {
        ['icon'] = "icons\\m\\tx_book_04.dds",
        ['model'] = "meshes\\m\\text_octavo_05.nif",
    },
    {
        ['icon'] = "icons\\m\\tx_octavo_03.dds",
        ['model'] = "meshes\\m\\text_octavo_03.nif",
    },
    {
        ['icon'] = "icons\\m\\tx_folio_03.dds",
        ['model'] = "meshes\\m\\text_folio_03.nif",
    },
}

-- spell is a core.Magic.Spell.
-- corruption is some bag that has an "id" record field.
local function createBookRecord(spell, corruption)
    if spell == nil then
        error("createBookRecord(): spell is nil")
    end
    if (corruption ~= nil) and (corruption.id == nil) then
        error("createBookRecord(): corruption.id is nil")
    end

    local bookName = ""
    local bookBody = ""

    local corruptionCostMod = 0
    local corruptionName = ""
    if corruption ~= nil then
        corruptionCostMod = math.random(-50, 100)
        local key = "corruptionName_" .. tostring(corruption.id)
        corruptionName = localization(key)
        if corruptionName == key then
            corruptionName = localization("corruptionName_notfound")
        end

        bookName = localization("bookCorrupt_name", {spellName=spell.name, corruptionName=corruptionName})
        bookBody = localization("bookCorrupt_body", {spellName=spell.name, corruptionName=corruptionName})
    else
        bookName = localization("book_name", {spellName=spell.name})
        bookBody = localization("book_body", {spellName=spell.name})
    end

    -- ErnSpellBooks_LearnEnchantment
    shape = bookShapes[math.random(1, 3)]
    recordFields = {
        enchant = "ErnSpellBooks_LearnEnchantment",
        enchantCapacity = 1,
        icon = shape["icon"],
        isScroll = false,
        model = shape["model"],
        name = bookName,
        skill = nil,
        text = bookBody,
        value = math.max(1, settings.costScale() * math.ceil(math.min(3000, 20 + corruptionCostMod + (spell.cost ^ 1.5)))),
        weight = math.random(2, 4),
    }
    draftRecord = types.Book.createRecordDraft(recordFields)
    return world.createRecord(draftRecord)
end

return {
    createBookRecord = createBookRecord
}
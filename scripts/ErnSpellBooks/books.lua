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

    local corruptionName = ""
    if corruption ~= nil then
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

    -- TODO: map to a random model + icon: https://en.uesp.net/wiki/Morrowind:Books


    -- ErnSpellBooks_LearnEnchantment
    recordFields = {
        enchant = "ErnSpellBooks_LearnEnchantment",
        enchantCapacity = 1,
        icon = "icons\\m\\tx_parchment_02.dds",
        isScroll = false,
        model = "meshes\\m\\text_parchment_02.nif",
        name = bookName,
        skill = nil,
        text = bookBody,
        value = settings.costScale() * math.ceil(math.min(3000, math.max(30, spell.cost ^ 1.5))),
        weight = 3,
    }
    draftRecord = types.Book.createRecordDraft(recordFields)
    return world.createRecord(draftRecord)
end

return {
    createBookRecord = createBookRecord
}
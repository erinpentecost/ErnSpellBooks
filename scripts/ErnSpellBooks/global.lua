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
local books = require("scripts.ErnSpellBooks.books")
local localization = core.l10n(settings.MOD_NAME)

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end

-- Init settings first to init storage which is used everywhere.
settings.initSettings()

-- bookTracker should map a couple things:
-- ["actor_" .. actorID .. "_spell_" .. spellID] -> {bookRecordID}
-- ["book_" .. bookRecordID] -> {spell bag}
--
-- spell bag has: {spellID: <spellID>, corruption: {prefixID: <corruption id>, suffixID: <corruption id>,extraStuff}}
local bookTracker = storage.globalSection(settings.MOD_NAME .. "bookTracker")
bookTracker:setLifeTime(storage.LIFE_TIME.Temporary)

local function saveState()
    return bookTracker:asTable()
end

local function loadState(saved)
    bookTracker:reset(saved)
end

-- createSpellbook creates a spell book.
-- params: data.spellID, data.corruption, data.container
function createSpellbook(data)
    if (data.spellID == nil) or (data.spellID == "") then
        error("createSpellbook() bad spellID")
    end
    if (data.corruption ~= nil) then
        if (data.corruption['suffixID'] == nil) or (data.corruption['suffixID'] == "") then
            error("createSpellbook() bad suffixID")
        end
        if (data.corruption['prefixID'] == nil) or (data.corruption['prefixID'] == "") then
            error("createSpellbook() bad prefixID")
        end
    end
    if (data.container == nil) then
        error("createSpellbook() nil container")
    end

    -- make book
    local spell = core.magic.spells.records[data.spellID]  -- get by id
    local bookRecord = books.createBookRecord(spell, data.corruption)
    local bookInstance = world.createObject(bookRecord.id)

    settings.debugPrint("creating " .. bookRecord.name  .. " on " .. data.container.id)

    -- save what the book is attached to.
    bookTracker:set("book_" .. bookRecord.id, {
        ['spellID'] = data.spellID,
        ['corruption'] = data.corruption
    })

    -- put in target inventory
    bookInstance:moveInto(data.container)
end

-- params: caster, target, spellID
function handleSpellCast(data)
    if data.caster == nil then
        error("handleSpellCast caster is nil")
        return
    end
    if data.target == nil then
        error("handleSpellCast target is nil")
        return
    end
    if data.spellID == nil then
        error("handleSpellCast spellID is nil")
        return
    end

    local playerSpellKey = "actor_" .. data.caster.id .. "_spell_" .. data.spellID
    local sourceBook = bookTracker:get(playerSpellKey)

    if sourceBook == nil then
        settings.debugPrint("spell cast, but wasn't learned from a book")
    end

    settings.debugPrint("handleSpellCast from " .. sourceBook)

    local spellBag = bookTracker:get("book_" .. sourceBook)
    if spellBag == nil then
        error("missing book entry for " .. sourceBook)
        return
    end
    local corruption = spellBag['corruption']
    if (corruption == nil) then
        -- don't do anything for a normal spell
        return
    end
    if (corruption.suffixID == nil) then
        error("missing suffixID for " .. sourceBook)
        return
    end
    if (corruption.prefixID == nil) then
        error("missing prefixID for " .. sourceBook)
        return
    end
    settings.debugPrint(sourceBook .. " contains corruption prefix " .. corruption.prefixID .. " and suffix " .. corruption.suffixID)
    -- ok, have some corruption id at this point.
end

-- params: actor, bookRecordID
function learnSpell(data)
    if data.actor == nil then
        error("learnSpell actor is nil")
    end
    if data.bookRecordID == nil then
        error("learnSpell bookRecordID is nil")
    end
    print("learnSpell")

    local spellBag = bookTracker:get("book_" .. data.bookRecordID)
    if spellBag == nil then
        error("no spell book record for " .. data.bookRecordID)
        return
    end

    local spell = core.magic.spells.records[spellBag['spellID']]
    if spell == nil then
        error("unknown spell " .. spellBag['spellID'])
    end

    -- need to mark where the player learned the spell.
    -- this lets us pull corruption info, if any.
    local playerSpellKey = "actor_" .. data.actor.id .. "_spell_" .. spellBag['spellID']
    bookTracker:set(playerSpellKey, data.bookRecordID)

    -- actually add the spell to known spells
    local actorSpells = types.Actor.spells(data.actor)
    actorSpells:add(spell)
    

    -- notify player
    local prefixName = nil
    local suffixName = nil
    if spellBag['corruption'] ~= nil then
        local prefix = corruptionUtil.getCorruptionNameAndDescription(spellBag['corruption']['prefixID'])
        prefixName = prefix.name
        local suffix = corruptionUtil.getCorruptionNameAndDescription(spellBag['corruption']['suffixID'])
        suffixName = suffix.name
    end
    if (data.actor.type == types.Player) then
        -- data.spellName, data.corruptionName
        data.actor:sendEvent("ernShowLearnMessage", {
            spellName=spell.name,
            corruptionPrefixName=prefixName,
            corruptionSuffixName=suffixName,
        })
    end
end


return {
    eventHandlers = {
        ernCreateSpellbook = createSpellbook,
        ernHandleSpellCast = handleSpellCast,
        ernLearnSpell = learnSpell
    },
    engineHandlers = {
        onSave = saveState,
        onLoad = loadState
    }
}

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
]] local interfaces = require("openmw.interfaces")
local settings = require("scripts.ErnSpellBooks.settings")
local types = require("openmw.types")
local core = require("openmw.core")
local self = require("openmw.self")
local animation = require('openmw.animation')
local storage = require('openmw.storage')


local bookTracker = storage.globalSection(settings.MOD_NAME .. "bookTracker")

-- This is applied to all creatures, NPCs, and players (for self-casts).



-- handleSpellApply is invoked once per target.
local function handleSpellApply(caster, target, spell)
    settings.debugPrint("Spell Apply: " .. caster.id .. " cast " .. spell.id .. " on " .. target.id)

    core.sendGlobalEvent("ernHandleSpellApply", {
        caster = caster,
        target = target,
        spellID = spell.id
    })
end

-- handleSpellCast is invoked once per cast.
local function handleSpellCast(caster, spell)
    settings.debugPrint("Spell Cast: " .. caster.id .. " cast " .. spell.id)

    core.sendGlobalEvent("ernHandleSpellCast", {
        caster = caster,
        spellID = spell.id
    })
end

local function handleLearn(actor, bookRecord)
    settings.debugPrint("Learn Spell: " .. actor.id .. " learns " .. bookRecord.name)

    --types.Actor.clearSelectedCastable(self)

    core.sendGlobalEvent("ernLearnSpell", {
        actor = actor,
        bookRecordID = bookRecord.id
    })
end

-- isSpellBook returns true if a cast spell is from a book
local function isSpellBook(item)
    if (item ~= nil) and (item.type == types.Book) then
        local bookRecord = types.Book.record(item)
        if (bookRecord ~= nil) and (bookRecord.enchant ~= nil) then
            return bookTracker:get("book_" .. bookRecord.id) ~= nil
        end
    end
    return false
end

-- track spells we've already handled so we don't double-handle stuff.
local handledActiveSpellIds = {}

local function onUpdate(dt)
    for id, spell in pairs(types.Actor.activeSpells(self)) do
        if (spell.caster ~= nil) and (spell.caster.type == types.Player) and
            (handledActiveSpellIds[spell.activeSpellId] ~= true) then
            -- player cast a new spell on this actor
            -- activeSpellId is unique per spell per actor the ActiveSpell is on
            -- is it a real spell?
            if (spell.temporary) and -- Filter weird stuff.
            (spell.fromEquipment ~= true) and -- Filter weird stuff.
            (spell.item == nil) then -- Filter enchanted items.
                -- This doesn't mean the spell was cast normally by the player.
                -- It could be a potion or scroll.
                -- Let's assume the player cast it if they know the spell.
                if types.Actor.spells(spell.caster)[id] then
                    handleSpellApply(spell.caster, self, spell)
                end
            end
            -- don't handle this spell again
            handledActiveSpellIds[spell.activeSpellId] = true
        end
    end
end

local function onInactive()
    handledActiveSpellIds = {}
end

--local currentSelectedSpell = nil
local function onActive()
    -- TODO: move learning into an animation handler so I don't need
    -- to check for the special spell effect. I can just check if the
    -- spell was cast from a book directly.

    interfaces.AnimationController.addTextKeyHandler("spellcast", function(group, key)
        settings.debugPrint("spellcast start for actor " .. self.id .. ": " .. key)
        if key == "self start" or key == "touch start" or key == "target start" then
            local enchantedItem = types.Actor.getSelectedEnchantedItem(self)
            if isSpellBook(enchantedItem) then
                handleLearn(self, types.Book.record(enchantedItem))
                -- TODO: interrupt
                return false
            end
        elseif (key == "self release" or key == "touch release" or key == "target release") then
            local foundSpell = types.Actor.getSelectedSpell(self)
            if foundSpell ~= nil then
                settings.debugPrint("selected spell: " .. tostring(foundSpell.id))
                handleSpellCast(self, foundSpell)
            end
        end
    end)
end

return {
    engineHandlers = {
        onUpdate = onUpdate,
        onInactive = onInactive,
        onActive = onActive
    }
}

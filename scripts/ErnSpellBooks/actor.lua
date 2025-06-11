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
local types = require("openmw.types")
local core = require("openmw.core")
local self = require("openmw.self")

-- This is applied to all creatures, NPCs, and players (for self-casts).

local function handleSpellCast(caster, target, spell)
    settings.debugPrint("Spell Cast: " .. caster.id .. " cast " .. spell.id .. " on " .. target.id)

    core.sendGlobalEvent("ernHandleSpellCast", {
        caster = caster,
        target = target,
        spellID = spell.id
    })
end

local function handleLearn(actor, bookRecord)
    settings.debugPrint("Learn Spell: " .. actor.id .. " learns " .. bookRecord.name)

    types.Actor.clearSelectedCastable(self)

    core.sendGlobalEvent("ernLearnSpell", {
        actor = actor,
        bookRecordID = bookRecord.id
    })
end

-- track spells we've already handled so we don't double-handle stuff.
local handledActiveSpellIds = {}

local function onUpdate(dt)
    for id, spell in pairs(types.Actor.activeSpells(self)) do
        if (spell.caster ~= nil) and (spell.caster.type == types.Player) and
            (handledActiveSpellIds[spell.activeSpellId] ~= true) then
            -- player cast a new spell on this actor
            -- print("player casts " .. spell.name .. " (".. id .. ") .. activeID: " .. spell.activeSpellId)
            -- is it a real spell?
            if (spell.temporary) and -- Filter weird stuff.
            (spell.fromEquipment ~= true) and -- Filter weird stuff.
            (spell.item == nil) then -- Filter enchanted items.
                -- This doesn't mean the spell was cast normally by the player.
                -- It could be a potion or scroll.
                -- Let's assume the player cast it if they know the spell.
                if types.Actor.spells(spell.caster)[id] then
                    handleSpellCast(spell.caster, self, spell)
                end
            elseif (spell.item ~= nil) and (spell.item.type == types.Book) and (spell.caster.id == self.id) then
                local bookRecord = types.Book.record(spell.item)
                if (bookRecord ~= nil) and (bookRecord.enchant ~= nil) and
                    (string.lower(types.Book.record(spell.item).enchant) == "ernspellbooks_learnenchantment") then
                    handleLearn(self, bookRecord)
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

return {
    engineHandlers = {
        onUpdate = onUpdate,
        onInactive = onInactive
    }
}

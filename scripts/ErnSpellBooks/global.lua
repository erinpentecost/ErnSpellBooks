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
local books = require("scripts.ErnSpellBooks.books")

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end

-- Init settings first to init storage which is used everywhere.
settings.initSettings()



-- createSpellbook creates a spell book.
-- params: data.spellID, data.corruption, data.container
function createSpellbook(data)
    local spell = core.magic.spells.records[data.spellID]  -- get by id
    local bookRecord = books.createBookRecord(spell, data.corruption)
    local bookInstance = world.createObject(bookRecord.id)

    if (data.container.type == types.Actor) or (data.container.type == types.Player) or (data.container.type == types.Creature) then
        bookInstance:moveInto(types.Actor.inventory(data.container))
    elseif data.container.type == types.Container then
        bookInstance:moveInto(types.Container.inventory(data.container))
    else
        error("bad container")
    end
end


return {
    eventHandlers = {
        ernCreateSpellbook = createSpellbook
    },
}

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
local world = require('openmw.world')
local core = require("openmw.core")
local settings = require("scripts.ErnSpellBooks.settings")
local interfaces = require('openmw.interfaces')

if require("openmw.core").API_REVISION < 62 then
    error("OpenMW 0.49 or newer is required!")
end

-- The function that actually does the thing.
-- data has fields: id, caster, target, spellID, sourceBook
local function applyCorruption(data)
    -- create a fur_colovian_helm and make the target wear it.
    -- this is safe for beast races.
    local hatInstance = world.createObject("fur_colovian_helm")
    hatInstance:moveInto(data.target)
    core.sendGlobalEvent('UseItem',
        {object = hatInstance, actor = data.target, force = true})
end

-- Register the corruption in the ledger.
interfaces.ErnCorruptionLedger.registerCorruption({
    id="style",
    func=applyCorruption,
    minimumLevel=0,
})

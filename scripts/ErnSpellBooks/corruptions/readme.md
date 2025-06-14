# Development Notes

## Corruptions

Any `.lua` files in this folder will automatically be run in the global scope before the mod finishes starting.

You can register one or more corruptions in the same file.

To register a corruption:
```lua
local interfaces = require('openmw.interfaces')

interfaces.ErnCorruptionLedger.registerCorruption({
    id = "mycoolthing",
    onApply = myCorruptionOnApplyFunction,
    onCast = myCorruptionOnCastFunction,
    minimumLevel = 1,
    prefixName = "localized name of the corruption when used as a prefix",
    suffixName = "localized name of the corruption when used as a suffix",
    description = "localized description of the corruption inside the spellbook",
})
```

`id` must uniquely identify a type of corruption. It should be lowercase.

`onApply` runs in global scope. It is run once per target affected by a by spell, so it may be invoked multiple times for the same cast. It takes in a single argument, which is a table with these fields:

* `id` - This is the id you registered the corruption under.
* `caster` - This is the caster actor.
* `target` - This is a target affected by the spell.
* `spellID` - This is the spell ID for the base spell this corruption was attached to.
* `sourceBook` - This is the book record ID that the corrupted spell was cast from.

`onCast` runs in global scope. It is run once per spell cast. It takes in a single argument, which is a table with these fields:

* `id` - This is the id you registered the corruption under.
* `caster` - This is the caster actor.
* `spellID` - This is the spell ID for the base spell this corruption was attached to.
* `sourceBook` - This is the book record ID that the corrupted spell was cast from.

`minimumLevel` informs the loot generator to not spawn this corruption until the player level is at least this number. It's optional.

`prefixName`, `suffixName`, and `description` should be localized strings. The spell name will appear as "**Prefix** Fire Bite of **Suffix**". The description will end up in the spell book when it's read.

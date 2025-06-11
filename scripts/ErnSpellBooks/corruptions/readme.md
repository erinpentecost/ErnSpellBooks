# Corruptions

Any `.lua` files in this folder will automatically be run in the global scope before the mod finishes starting.

You can register one or more corruptions in the same file.

To register a corruption:
```lua
local interfaces = require('openmw.interfaces')

interfaces.ErnCorruptionLedger.registerCorruption({
    id = "mycoolthing",
    func = myCorruptionFunction,
    minimumLevel = 1,
})
```

`id` must uniquely identify a type of corruption. It should be lowercase.

`func` runs in global scope. It is run once per target affected by a by spell, so it may be invoked multiple times for the same cast. It takes in a single argument, which is a table with these fields:

* `id` - This is the id you registered the corruption under.
* `caster` - This is the caster actor.
* `target` - This is a target affected by the spell.
* `spellID` - This is the spell ID for the base spell this corruption was attached to.
* `sourceBook` - This is the book record ID that the corrupted spell was cast from.
* `frameID` - This is a number that changes every frame. You can use this to deduplicate multiple calls to your function. You'll need to do this if you want to be sure that something happens *once per cast* rather than *once per target*.

`minimumLevel` informs the loot generator to not spawn this corruption until the player level is at least this number. It's optional.

## Localization

You also need to add these fields to the localization file for every corruption you add:

```yaml
corruption_mycoolthing_prefix: "Gigantic"
corruption_mycoolthing_suffix: "the Giant"
corruption_mycoolthing_description: "Targets become increase in size."
```

The spell name will appear as "Gigantic *Fire Bite* of the Giant". The description will end up in the spell book when it's read.

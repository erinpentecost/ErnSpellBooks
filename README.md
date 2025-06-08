# ErnSpellBooks
OpenMW mod that adds Spell Books, which teach you a spell when you read them. Spell Books can be corrupted through a dark ritual that will increase their power but also add a random drawback.

![example](title_image.jpg)

## Installing
Extract [main](https://github.com/erinpentecost/ErnSpellBooks/archive/refs/heads/main.zip) to your `mods/` folder.


In your `openmw.cfg` file, and add these lines in the correct spots:

```yaml
data="/wherevermymodsare/mods/ErnSpellBooks-main"
content=ErnSpellBooks.omwaddon
content=ErnSpellBooks.omwscripts
```

## Contributing

Feel free to submit a PR to the [repo](https://github.com/erinpentecost/ErnSpellBooks) provided:

* You assert that all code submitted is your own work.
* You relinquish ownership of the code upon merge to `main`.
* You acknowledge your code will be governed by the project license.


## References

Learning a spell: https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(ActorSpells).add

Listing spells: https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(Spells).records
```
-- Print all powers
for _, spell in pairs(core.magic.spells.records) do
    if spell.types == core.magic.SPELL_TYPE.Power then
        print(spell.name)
    end
end
```
Determining properties of a spell:
https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(Spell)

Adding spells effects (used for corrupted drawbacks and benefits):
https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Actor).activeSpells
`ActorActiveSpells:add(options)`

Modifying effects directly: https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(ActorActiveEffects)

We can only corrupt a record of a spell per actor, not an instance. No duplicates with the same name allowed.

Detecting a spell is cast: If nothing else, monitor for magicka loss while in sell cast stance. Then look at https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Actor).getSelectedSpell
This will fail if the opponent cast damage magicka or drain magicka. Can also check for ActorActiveEffects, and if these are are active on the player (AND the SpellRange is NOT Self), skip application of corruption effects.

I'll probably need to create my own corruption spells in an ESM. Then I can match bonus effects with targets to the target of the original spell, rather than just doing Self targets for all corruption effects. Hopefully I can make a bunch in a script. This will be good because I can set them to ignore reflect and absorb.

It could be bypassed by using Potion effects!
`Actor.activeSpells(self):add({id = 'p_fortify_intelligence_s', effects = { 0 }, stackable = true})`
The `effects` list is a list of indices of effects on the spell, and duplicates are allowed. Spoiled potions only drain attributes. Most beverages, too. So getting negative effects from the potions list is kinda shit. (Except Silence and Light).
I think I can just use normal spells to apply effects, anyway. The problem with that is that they won't stack.

I can't -reliably- get the target of a non-self spell by raycasting since actors might move around before it is applied. When a spell is cast from the player, I can send an event to all actors in the cell that will cause them to check for the spell ID on their list of active spells onUpdate. Then I can assume the player did it.
Alternatively, just check active effects on all loaded actors every frame. With ` ActorActiveSpells:isSpellActive(recordOrId) `

### omwaddon
The omwaddon contains these entries:
* enchantment: `ErnSpellBooks_LearnEnchantment` (casts DrainMagicka on self for 1 sec)
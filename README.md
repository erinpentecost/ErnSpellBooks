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

### omwaddon
The omwaddon contains these entries:
* enchantment: `ErnSpellBooks_LearnEnchantment` (casts DrainMagicka on self for 1 sec)

### TODO
* Corruption Orbs
* More Corruptions
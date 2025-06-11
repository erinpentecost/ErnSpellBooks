# ErnSpellBooks
OpenMW mod that adds Spell Books, which teach you a spell when you read them. Rare Corrupted Spell Books have additional wild effects!

Spell Books can contain a huge variety of spells, since they are drawn from all existing (suitable) spells in your world, including those added from other mods.

Spell Books can spawn on magic-using NPCs or in appropriate containers. A few will also be for sale in any book shop, which will be restocked once per day.

![a wizard with a spellbook, created with AI](title_image.jpg)

## Installing
Extract [main](https://github.com/erinpentecost/ErnSpellBooks/archive/refs/heads/main.zip) to your `mods/` folder.


In your `openmw.cfg` file, and add these lines in the correct spots:

```yaml
data="/wherevermymodsare/mods/ErnSpellBooks-main"
content=ErnSpellBooks.omwaddon
content=ErnSpellBooks.omwscripts
```

## Contributing

Feel free to submit a PR to the [repo](https://github.com/erinpentecost/ErnSpellBooks) provided you certify that your contribution under the [Developer Certificate of Origin](https://developercertificate.org/).

### omwaddon
The omwaddon contains these entries:
* enchantment: `ErnSpellBooks_LearnEnchantment` (casts DrainMagicka on self for 1 sec)

### TODO
* Corruption Orbs
* More Corruptions
# Brainstorm: RPG Rules & Design & Whatnot

## General design goals
I am not sure if I prefer a fully player-created party or just a player-created
party leader. The latter would offer interesting choices and flexibility, but it
might also incentivise players to create a jack-of-all-trades instead of who
they actually want to play as.

A good compromise could be to allow players to generate additional characters at
a bar or something, but the game starts in a dungeon a la Privateer's Hold, where
they are joined by another character. Upon reaching the first town, they may
choose to generate additional characters. 

There should be additional incentive not to fill up your party asap, so it
doesn't become a no-brainer. Companions should bring something unique to the
table that cannot be easily replicated with generated characters.

I would also like smaller partys to have some kind of advantage so party size is
a meaningful choice. One obvious advantage of solo characters is that they are
not held back by other party members: A sneaky ninja doesn't have to worry that
the iron-clad knight will wake up the guards; a super-athletic climber can reach
the hightest mountain-tops without having to wait for the other characters,
etc.pp. They should also get a lot more experience.

### Pro and contra classes
In elder scrolls games, the lack of classes usually leads to some variation of a
sneaky spell-sword.  However, in a party-based RPG, that just doesn't seem
necessary. It seems that such games encourage specialisation, at least when the
party roster is fixed. 

I don't want classes, but I also don't want characters to be equally good at
everything. Initial attributes should not change too much over the course of the
game (like in M&M), but enough to allow for slow adaptation to the player's
playstyle.

### Attributes
I would like to avoid dump stats if possible, but not at the cost of, say,
making strength affect spell damage. Distributing points shouldn't be a mine
field of unforseeable consequences. 

Min-maxing should work, but it shouldn't be the clearly superior choice.

Maybe 'Well-rounded' characters should receive a mild xp boost (~10%)? 

My list of attributes currently looks as follows:

- Strength 
  - +max equipment weight
  - +ability to break stuff such as doors
  - +effectively wielding heavy weapons
  - +damage with many melee weapons
  - +chance to stun with heavy weapons
  - +armor penetration with heavy weapons
- Dexterity 
  - +dodging attacks
  - +melee accuracy (the chance to miss is lower than ranged, though... maybe 25%?)
  - +melee crit chance (although this could be a skill instead)
  - +initiative
  - +crit chance
- Endurance
  - +Health
  - +Resistance to physical damage, poison & disease
  - -chance to be stunned by strong attacks
  - +some kind of action point system?
- Perception
  - +crit chance
  - +ranged accuracy (esp. at longer range)
  - +magic accuracy (at range, could depend on additional factors)
  - easier to see things that are meant to be hidden (doors, traps, treasure)
  - spot enemies from further away and behind, less chance to be ambushed
- Intelligence
  - obviously higher magical affinity in some shape or form
  - either more exp or more skill points on level up
  - maybe more dialog options
  - +reading level and thus access to higher level spells/knowledge
- Willpower
  - +pain tolerance
  - -chance to be stunned by heavy weapons
  - +all mental and some magical resistances 
  - access to some alternative form of magic (restoration instead of destruction etc. ?)
  - +magical affinity
- Attunement
  - +magic points
  - +magical affinity
  - +sense arcane energy

#### Remarks, Problems & Uncertanties 
Strength is kind of a dump stat for dex and magic mains. While a magic user
could turtle up with high strength, dex users can rely on dodging for defense.
It could be fun to have a mage in the front row, wearing plate armour and
wielding a massive club for when their mp run out.

Perception is a bit of a dump stat for non-rogues/archers. Checking whether the
party spots something should probably not only consider the highest PER, but
also to a lesser extent other characters' PER if they are sufficiently high.
That by itself surely doesn't make PER attractive to all archetypes.

Attunement is a dump stat, kind of by design. Since int and wil have additional
uses, I want another stat that separates decdicated spell casters from the
rest. Having 3 stats related to magic could be a bit much, though.

Since INT gives either more exp or more skill points, it probably shouldn't be
possible to pump all skill points into one stat. In that case even barbarians
would strongly benefit from high int. Instead, high int should only allow characters
to spec in a greater variety of skills. This would make medium/high int a viable
choice for many archetypes. To lessen the effect for magic mains, they simply
should have more skills to maintain.

Charisma is missing. For every 100 fights, there's maybe one conversation with an npc, so this is utterly pointless. I may have some related skills and perks.

Choosing high Att without either Int or Wil is pointless. There should be a
spell class that solely focuses on Att (self targeted spells? Maybe monks would use these)

#### Attribute Distribution for Classic Archetypes

Fighter (as tank):
- Str ++
- Dex o/+
- End +/++
- Per --/o
- Int o
- Wil +/++
- Att --
Apart from high str and good end, fighters should also have at least average dex for
a decent hit-chance and initiative. If they go for pure melee, they can go with
low per. Int should be decent to allow them to learn multiple weapons/fighting
styles, although if they specialise they can forgo that requirement. A tank
needs good wil to stay on their feet.  Attunement is completely unnecessary
unless they want to go the spellsword route.

Barbarian Damage dealer:
- Str ++
- Dex +/++
- End ++
- Per --
- Int --
- Wil o/+
- Att --
Barbarians are highly specialised fighters and thus they can make due with low
int. The typical loincloth-wearing barbarian should have at least good dex and
end to somewhat offset their lack of armour, although they will probably still die
more easily than a figher. Unless they want to use throwables, they should keep
per low.  Wil should be average or better so they don't get knocked out all the
time. Att can be safely ignored.

Rogue:
- Str -/o/+
- Dex ++
- End o/+
- Per +/++
- Int o/+
- Wil --
- Att --/-
Depending on their fighting style and weapon, a rogue doesn't need a lot of str,
but high dex for thievery skills, dodging, high initiative and crit chance. 
Per also affects the latter, so it should be at least decent or better if they also
use ranged weapons and to detect stuff.
Int should be ok or better to maintain high skill levels. Wil is only
interesting for characters that get hit a lot and Att is only necessary if the
character wants to augment their abilities with magic.

Archer:
- Str o
- Dex +
- End o
- Per ++
- Int o
- Wil -
- Att --
Archers have one job, and for that they need to have max per and average str. For
close quarter combat however, they should be able to switch to melee, so good
dex is advisable unless they want to go full strength. Average int and min att
is good enough unless they want to use magic. Wil is also not important as
archers don't belong in the front row.

Mage:
- Str --
- Dex o
- End -
- Per o/+
- Int ++
- Wil o
- Att ++

A classic mage needs high int and att. If they mainly go for destructive spells,
they should also have good per so they actually hit their target. As the classic
mage is a glass cannon situated in the back row, they don't need to bother with
str or end, though they might want to have decent dex for dodging and stabbing
once their mp ran out.

Cleric:
- Str --/+
- Dex -/o
- End -/+
- Per --/+
- Int o/+
- Wil ++
- Att +/++
Clerics offer support and control, optionally with melee capabilities. If they
choose the latter and go with the classic choice of blunt weapons, good str and
end are advisable. Otherwise they should at least have decent dex for evasion.
If the cleric uses attack or control spells, they should have decent per. Int
can be a bit higher to allow a wider variety of spells, but is not strictly
necessary. However they need to max wil and have high att.


The Worst:
- Str -
- Dex --
- End ++
- Per ++
- Int --
- Wil -
- Att ++
A character with little offensive/defensive abilities, but lots of HP/MP.


### Derived stats
Derived stats are -- at least initially -- derived from attributes and race.
The most important of these are hp and mp, others are speed, initiative and weight.

HP = 10 + END^2 
on level up: HP += END

MP = 10 + ATT^2

AMX Plugins
===

These plugins are for use on your Counter-Strike or Day of Defeat servers running either <a href="http://amxmod.net/">AMX</a> or <a href="http://www.amxmodx.org/">AMX Mod X (AMXX)</a>.

Included Plugins
---

### plugin_cloakwar

Gives the winning team cloaking powers. Cloaked players
are revealed only for a few seconds after firing but 
they only have 1 health.

### plugin_clonewar

Makes all players use the same model.

### plugin_csevents

Announces events for Counter-Strike.

* Bomb exploded
* Bomb planted
* Bomb defused
* Bomb being planted
* Bomb being defused
* Player spawned with bomb
* Player picked up bomb
* Player dropped bomb
* Audio bomb countdown
* Hostage touched
* Hostage rescued
* Hostage killed (with punishment)
* Headshots (multiple messages)
* Knife kills (multiple messages)
* Grenade kills (multiple messages)
* Grenade suicides
* Player spawned as VIP
* VIP killed
* VIP escaped
* VIP failed to escape
* First kill (bonus health/money)
* Killstreak

### plugin_freezetag

Players freeze each other with their knives. Players
are unfrozen by their teammates. A team wins by freezing
all the players on the other team. (My favorite plugin)

### plugin_fun

Provides admin commands for all fun functions.

* amx_godmode - gives player gomode
* amx_noclip - gives player noclip
* amx_frags - changes player frags
* amx_armor - changes player armor
* amx_health - changes player health
* amx_maxspeed - changes player maxspeed
* amx_gravity - changes player gravity
* amx_money - changes player money
* amx_give - give a player a weapon/item
* amx_weapon - gives player weapons
* amx_tp - teleports a player to a coordinate
* amx_tpsave - saves a coordinate for teleporting
* amx_nohead - turns off headshots for a player
* amx_glow - makes a player glow
* amx_spawn - makes a player spawn
* amx_footsteps - changes player footsteps
* amx_lights - change map lighting

### plugin_funman

Fun manager. Turns on different fun modes based on the current map.

### plugin_gamble

This plugin allows players to gamble for certain
powers by saying "gamble!". They can also receive
negative effects. All powers are time limited.

* God Mode - Player cannot be killed
* Shield - Player not affected by any powers
* Speed - Player runs much faster
* Slow - Player runs much slower
* Stealth - Player is invisible
* Quad Damage - Player does 4x damage
* Protect - Player receives 1/4 damage
* Rambo - Player has infinite armor and ammo
* Leech - Player gets health from damage to others
* Absorb - Player absorbs damage into health
* Reflect - player does mirror damage to attackers
* Curse - Player receives mirror damage for attacking (can spread)
* Regen - Player slowly regains health
* Poison - Player slowly loses health (can spread)
* Death - Countdown until player death (can spread)
* Fireball - Player turns into a giant fireball and hurts others around him
* Medic - Player heals others around him
* Ghost - Player can fly through walls
* Hologram - Player becomes a hologram: can't harm others or be harmed
* Timebomb - Player becomes a timebomb. Explosion kills surrounding players.
* Oneshot - Bullets kill in one shot
* Explodeshot - Bullets do explosive damage
* Stunshot - Bullets have stun effect
* Cloak - Player is cloaked until he fires
* Lasershot - Player fires a powerful laser
* Grenadier - Player gets infinite grenades
* Flashshot - Bullets have a blinding effect
* Vampire - Players absorbs health from others around him
* AGshot - Bullets have a anti-gravity effect
* Splintershot - bullets splinter on impact
* Disarm - Player loses all his weapons
* Bury - Player is buried in the ground and can't move
* Blind - Player is blinded
* Drunk - Player staggers and has bad vision
* Bunny - Player jumps constantly
* Poor - Player loses all his money

**Requires plugin_powers and plugin_punish to work.**

### plugin_glowdamage

This plugin makes players glow briefly when 
damaged. There are team-based glow colors
as well as different colors for the amount
of damage dealt.

### plugin_gore

This plugin adds extra gore effects.

* Headshot blood
* Extra blood effects
* Bleeding on low health
* Gib explosion (knife, HE, high damage only)

### plugin_hunting

Hunting season mod. One team (hunters) have infinite ammo and
armor. The other team (bears) have lots of health and knives.
Teams switch roles every round.

**Requires plugin_powers to work.**

### plugin_ka

Knife arena. Players can only use knives.

### plugin_listen

Changes who can hear who.

* Admins can hear everyone
* Dead players can hear alive players
* Alive players can hear dead players

### plugin_mysql_ban

Simple ban management using a MySQL database.

Create a table to hold bans in your mysql database:

`CREATE TABLE banned ( 
banid varchar(32) NOT NULL PRIMARY KEY,
banname varchar(32),
adminid varchar(32),
adminname varchar(32),
reason varchar(255),
bandatetime int unsigned default 0
);`

### plugin_namechange

Prevents or punishes players for changing their names.

### plugin_powers

This plugin gives admins the ability to set positive
and negative effects on players.

* amx_god - player cannot be killed (different from set_user_godmode)
* amx_shield - player not affected by any powers
* amx_speed - player speed is modified
* amx_stealth - player visibility is modified
* amx_harm - player damage given is modified
* amx_protect - player damage received is modified
* amx_rambo - player has infinite armor and ammo
* amx_leech - player gets health from damage to others
* amx_absorb - player absorbs damage into health
* amx_reflect - player does mirror damage on attackers
* amx_curse - player receives mirror damage for attacking (can spread)
* amx_regen - player slowly regains health
* amx_poison - player slowly loses health (can spread)
* amx_death - countdown until player death (can spread)
* amx_fireball - player hurts others around him
* amx_medic - player heals others around him
* amx_ghost - player can fly through walls
* amx_hologram - player becomes a hologram: can't harm or be harmed
* amx_timebomb - player becomes a timebomb
* amx_oneshot - bullets kill in one shot
* amx_explodeshot - bullets do explosive damage
* amx_stunshot - bullets have stun effect
* amx_cloak - player is cloaked until he fires
* amx_lasershot - player fires a powerful laser
* amx_grenadier - player gets infinite grenades
* amx_flashshot - bullets have a blinding effect
* amx_vampire - players absorbs health from others around him
* amx_agshot - bullets have a anti-gravity effect
* amx_splintershot - bullets splinter on impact

### plugin_punish

This plugin gives admins the ability to punish
players in multiple ways.

* amx_disarm - removes all weapons from a player
* amx_bury - burys a player in the ground, drops all his weapons
* amx_unbury - unbury a player
* amx_gag - prevents player from speaking
* amx_ungag - ungag a player
* amx_smack - slaps a player multiple times
* amx_blind - blinds a player
* amx_unblind - removes blind from a player
* amx_drunk - makes player stagger and have bad vision
* amx_sober - removes drunk from a player
* amx_bunny - makes player constantly jump

### plugin_rambo

Gives a player infinite bullets. (For Day of Defeat only)

### plugin_slash

This plugin allows admins to execute amx commands
using 'say' and a slash '/'. It can also execute
a command on all players or a team using '@all' and
'@team' in place of the authid/nick parameter.

Examples:
To kick a player type '/kick playername'
To kick all players type '/kick @all'
To kick all players on a team type '/kick @team:TEAMID'
To ban all players for 10 minutes, type '/ban 10 @all'

Additional Commands:
Includes an IRC style '/me' command. If you say
'/me sucks', it'll replace the '/me' with your name
and print it to everyone.

### plugin_stealthwar

Makes the winning team invisible. Invisible players can only use knives.

### plugin_targetwar

Target war mod. One person on each team is randomly
selected to be a target. Only the target can die, 
everyone else has immunity. If the target dies, another
player is randomly selected to be a target.

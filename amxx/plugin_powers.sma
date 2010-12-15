/*
*	AMXMOD script.
*	(plugin_powers.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin gives admins the ability to set positive
*	and negative effects on players.
*
*	Commands:
*	amx_god - player cannot be killed (different from set_user_godmode)
*	amx_shield - player not affected by any powers
*	amx_speed - player speed is modified
*	amx_stealth - player visibility is modified
*	amx_harm - player damage given is modified
*	amx_protect - player damage received is modified
*	amx_rambo - player has infinite armor and ammo
*	amx_leech - player gets health from damage to others
*	amx_absorb - player absorbs damage into health
*	amx_reflect - player does mirror damage on attackers
*	amx_curse - player receives mirror damage for attacking (can spread)
*	amx_regen - player slowly regains health
*	amx_poison - player slowly loses health (can spread)
*	amx_death - countdown until player death (can spread)
*	amx_fireball - player hurts others around him
*	amx_medic - player heals others around him
*	amx_ghost - player can fly through walls
*	amx_hologram - player becomes a hologram: can't harm or be harmed
*	amx_timebomb - player becomes a timebomb
*	amx_oneshot - bullets kill in one shot
*	amx_explodeshot - bullets do explosive damage
*	amx_stunshot - bullets have stun effect
*	amx_cloak - player is cloaked until he fires
*	amx_lasershot - player fires a powerful laser
*	amx_grenadier - player gets infinite grenades
*	amx_flashshot - bullets have a blinding effect
*	amx_vampire - players absorbs health from others around him
*	amx_agshot - bullets have a anti-gravity effect
*	amx_splintershot - bullets splinter on impact
*
*/ 
#include <amxmodx>
#include <engine>
#include <fun>

// Constants
#define MAX_NAME_LENGTH 32
#define MAX_TEXT_LENGTH 512
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_SOUNDS 32

// Powers
#define POWERS_GOD		(1<<0)
#define POWERS_SHIELD		(1<<1)
#define POWERS_SPEED		(1<<2)
#define POWERS_STEALTH		(1<<3)
#define POWERS_HARM		(1<<4)
#define POWERS_PROTECT		(1<<5)
#define POWERS_RAMBO		(1<<6)
#define POWERS_LEECH		(1<<7)
#define POWERS_ABSORB		(1<<8)
#define POWERS_REFLECT		(1<<9)
#define POWERS_CURSE		(1<<10)
#define POWERS_REGEN		(1<<11)
#define POWERS_POISON		(1<<12)
#define POWERS_DEATH		(1<<13)
#define POWERS_FIREBALL		(1<<14)
#define POWERS_MEDIC		(1<<15)
#define POWERS_GHOST		(1<<16)
#define POWERS_HOLOGRAM		(1<<17)
#define POWERS_TIMEBOMB		(1<<18)
#define POWERS_CLOAK		(1<<19)
#define POWERS_ONESHOT		(1<<20)
#define POWERS_STUNSHOT		(1<<21)
#define POWERS_EXPLODESHOT	(1<<22)
#define POWERS_LASERSHOT	(1<<23)
#define POWERS_GRENADIER	(1<<24)
#define POWERS_FLASHSHOT	(1<<25)
#define POWERS_AGSHOT		(1<<26)
#define POWERS_SPLINTERSHOT	(1<<27)
#define POWERS_VAMPIRE		(1<<28)

#define POWERS_NONE			0
#define POWERS_TIMER_INTERVAL		1.0

// Message colors
#define POWERS_MSG_R		0
#define POWERS_MSG_G		200
#define POWERS_MSG_B		0

#define POWERS_MSG_CHANNEL	2

// FX temp entities
#define	TE_BEAMPOINTS		0
#define	TE_BEAMENTPOINT		1
#define	TE_GUNSHOT		2
#define	TE_EXPLOSION		3
#define	TE_TAREXPLOSION		4
#define	TE_SMOKE		5
#define	TE_TRACER		6
#define	TE_LIGHTNING		7
#define	TE_BEAMENTS		8
#define	TE_SPARKS		9
#define	TE_LAVASPLASH		10
#define	TE_TELEPORT		11
#define TE_EXPLOSION2		12
#define TE_BSPDECAL		13
#define TE_IMPLOSION		14
#define TE_SPRITETRAIL		15
#define TE_BEAM			16
#define TE_SPRITE		17
#define TE_BEAMSPRITE		18
#define TE_BEAMTORUS		19
#define TE_BEAMDISK		20
#define TE_BEAMCYLINDER		21
#define TE_BEAMFOLLOW		22
#define TE_GLOWSPRITE		23
#define TE_BEAMRING		24
#define TE_STREAK_SPLASH	25
#define TE_BEAMHOSE		26
#define TE_DLIGHT		27
#define TE_ELIGHT		28
#define TE_TEXTMESSAGE		29
#define TE_LINE			30
#define TE_BOX			31
#define TE_KILLBEAM		99
#define TE_LARGEFUNNEL		100
#define	TE_BLOODSTREAM		101
#define	TE_SHOWLINE		102
#define TE_BLOOD		103
#define TE_DECAL		104
#define TE_FIZZ			105
#define TE_MODEL		106
#define TE_EXPLODEMODEL		107
#define TE_BREAKMODEL		108
#define TE_GUNSHOTDECAL		109
#define TE_SPRITE_SPRAY		110
#define TE_ARMOR_RICOCHET	111
#define TE_PLAYERDECAL		112
#define TE_BUBBLES		113
#define TE_BUBBLETRAIL		114
#define TE_BLOODSPRITE		115
#define TE_WORLDDECAL		116
#define TE_WORLDDECALHIGH	117
#define TE_DECALHIGH		118
#define TE_PROJECTILE		119
#define TE_SPRAY		120
#define TE_PLAYERSPRITES	121
#define TE_PARTICLEBURST	122
#define TE_FIREFIELD		123
#define TE_PLAYERATTACHMENT		124
#define TE_KILLPLAYERATTACHMENTS	125
#define TE_MULTIGUNSHOT			126
#define TE_USERTRACER			127

// TE_EXPLOSION flags
#define TE_EXPLFLAG_NONE	0
#define TE_EXPLFLAG_NOADDITIVE	1
#define TE_EXPLFLAG_NODLIGHTS	2
#define TE_EXPLFLAG_NOSOUND	4
#define TE_EXPLFLAG_NOPARTICLES	8

// TE_FIREFIELD flags
#define TEFIRE_FLAG_ALLFLOAT	1
#define TEFIRE_FLAG_SOMEFLOAT	2
#define TEFIRE_FLAG_LOOP	4
#define TEFIRE_FLAG_ALPHA	8
#define TEFIRE_FLAG_PLANAR	16

// Sounds
#define SOUND_ATTACK		(1<<0)
#define SOUND_VICTIM		(1<<1)
#define SOUND_RANDOM_GIB	(1<<2)
#define SOUND_RANDOM_BLOOD	(1<<3)
#define SOUND_RANDOM_HURT	(1<<4)
#define SOUND_RANDOM_FLASH	(1<<5)

#define SOUND_BANG		0
#define SOUND_BEEP1		1
#define SOUND_BEEP2		2
#define SOUND_BEEP3		3
#define SOUND_BEEP4		4
#define SOUND_BEEP5		5
#define SOUND_BLOW		6
#define SOUND_BLOOD1		7
#define SOUND_BLOOD2		8
#define SOUND_BLOOD3		9
#define SOUND_EXPLODE1		10
#define SOUND_EXPLODE2		11
#define SOUND_GIB1		12
#define SOUND_GIB2		13
#define SOUND_GIB3		14
#define SOUND_GIB4		15
#define SOUND_HEARTBEAT		16
#define SOUND_HURT1		17
#define SOUND_HURT2		18
#define SOUND_HURT3		19
#define SOUND_ONESHOT		20
#define SOUND_SCREAM		21
#define SOUND_STUN		22
#define SOUND_STUNSHOT		23
#define SOUND_FLAME		24
#define SOUND_LASERSHOT		25
#define SOUND_LASERDEATH	26
#define SOUND_MEDIC		27
#define SOUND_FLASH1		28
#define SOUND_FLASH2		29
#define SOUND_AGSHOT		30
#define SOUND_AGHIT		31
#define SOUND_BULLETS		32

/************************************************************************
* CONFIGS:
************************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

// Notify player of powers (1=on,0=off)
#define MSG_POWERS 1

// Show special FX of powers (1=on,0=off)
#define FX_POWERS 1

// Multiplier for FX shake and fade
#define FX_MULT	(1<<12)

// Default powers values
// All MAX, COUNT, DISTANCE, and otherwise should be integers
// All RATIO and INTERVAL should be floats
#define DEFAULT_HEALTH_MAX 100
#define DEFAULT_LEECH_RATIO 1.0
#define DEFAULT_LEECH_MAX 100
#define DEFAULT_STEALTH_RATIO 0.9
#define DEFAULT_SPEED 260
#define DEFAULT_SPEED_RATIO 2.0
#define DEFAULT_HARM_RATIO 2.0
#define DEFAULT_ARMOR 100
#define DEFAULT_PROTECT_RATIO 0.75
#define DEFAULT_REFLECT_RATIO 1.0
#define DEFAULT_CURSE_RATIO 0.5
#define DEFAULT_ABSORB_RATIO 1.0
#define DEFAULT_ABSORB_MAX 250
#define DEFAULT_REGEN_HEALTH 5
#define DEFAULT_REGEN_INTERVAL 1.0
#define DEFAULT_REGEN_MAX 100
#define DEFAULT_POISON_DAMAGE 5
#define DEFAULT_POISON_INTERVAL 1.0
#define DEFAULT_DEATH_COUNT 20
#define DEFAULT_DEATH_DISTANCE 500
#define DEFAULT_FIREBALL_DAMAGE 20
#define DEFAULT_FIREBALL_INTERVAL 1.0
#define DEFAULT_FIREBALL_DISTANCE 300
#define DEFAULT_FIREBALL_TEAM 1
#define DEFAULT_MEDIC_HEALTH 20
#define DEFAULT_MEDIC_INTERVAL 2.0
#define DEFAULT_MEDIC_DISTANCE 300
#define DEFAULT_MEDIC_TEAM 0
#define DEFAULT_TIMEBOMB_COUNT 10
#define DEFAULT_TIMEBOMB_DISTANCE 2000
#define DEFAULT_STUNSHOT_DAMAGE 1
#define DEFAULT_STUNSHOT_COUNT 5
#define DEFAULT_EXPLODESHOT_RATIO 0.5
#define DEFAULT_EXPLODESHOT_DISTANCE 500
#define DEFAULT_CLOAK_HEALTH 1
#define DEFAULT_CLOAK_INTERVAL 5.0
#define DEFAULT_LASERSHOT_COUNT 10
#define DEFAULT_LASERSHOT_DISTANCE 300
#define DEFAULT_LASERSHOT_TEAM 0
#define DEFAULT_GRENADE_TYPE 1
#define DEFAULT_FLASHSHOT_DAMAGE 1
#define DEFAULT_FLASHSHOT_COUNT 5
#define DEFAULT_AGSHOT_DAMAGE 1
#define DEFAULT_AGSHOT_COUNT 5
#define DEFAULT_SPLINTER_DAMAGE 5
#define DEFAULT_SPLINTER_DISTANCE 500
#define DEFAULT_SPLINTER_TEAM 0
#define DEFAULT_VAMPIRE_HEALTH 20
#define DEFAULT_VAMPIRE_INTERVAL 2.0
#define DEFAULT_VAMPIRE_DISTANCE 1000
#define DEFAULT_VAMPIRE_TEAM 1
#define DEFAULT_VAMPIRE_MAX 200

/************************************************************
* MAIN
************************************************************/

// Globals
new gStunIndex[MAX_PLAYERS+1]		// stun count
new gGravityIndex[MAX_PLAYERS+1]	// floating count
new gPowersIndex[MAX_PLAYERS+1]		// powers sum
new gHealthIndex[MAX_PLAYERS+1]		// max health
new gWeaponIndex[MAX_PLAYERS+1]		// last weapon
new gAmmoIndex[MAX_PLAYERS+1]		// last ammo
new gMsg = MSG_POWERS			// msg check
new gFx = FX_POWERS			// fx check
new gTimer = 0				// global timer
new gShowDeathMsg = 0			// show death messages

// Powers indexes
new Float:gGodIndex[MAX_PLAYERS+1]		// Amount
new Float:gStealthIndex[MAX_PLAYERS+1]		// Amount
new Float:gSpeedIndex[MAX_PLAYERS+1]		// Ratio
new Float:gHarmIndex[MAX_PLAYERS+1]		// Ratio
new Float:gProtectIndex[MAX_PLAYERS+1]		// Ratio
new Float:gReflectIndex[MAX_PLAYERS+1]		// Ratio
new Float:gCurseIndex[MAX_PLAYERS+1]		// Ratio
new Float:gLeechIndex[MAX_PLAYERS+1]		// Ratio
new Float:gAbsorbIndex[MAX_PLAYERS+1]		// Ratio
new Float:gRegenIndex[MAX_PLAYERS+1][2]		// Amount, Max
new Float:gPoisonIndex[MAX_PLAYERS+1][2]	// Amount, Max
new Float:gDeathIndex[MAX_PLAYERS+1][3]		// Count, Start, Distance
new Float:gFireballIndex[MAX_PLAYERS+1][4]	// Amount, Interval, Distance, Team
new Float:gMedicIndex[MAX_PLAYERS+1][4]		// Amount, Interval, Distance, Team
new Float:gVampireIndex[MAX_PLAYERS+1][4]	// Amount, Interval, Distance, Team
new Float:gTimebombIndex[MAX_PLAYERS+1][3]	// Count, Start, Distance
new Float:gStunshotIndex[MAX_PLAYERS+1][2]	// Amount, Count
new Float:gExplodeshotIndex[MAX_PLAYERS+1][2]	// Ratio, Distance
new Float:gCloakIndex[MAX_PLAYERS+1][4]		// Amount, Count, Interval, Health
new Float:gLasershotIndex[MAX_PLAYERS+1][4]	// Count, Start, Distance, Team
new Float:gGrenadeIndex[MAX_PLAYERS+1][2]	// Grenade Type, Grenade Check
new Float:gFlashshotIndex[MAX_PLAYERS+1][2]	// Amount, Count
new Float:gAGshotIndex[MAX_PLAYERS+1][2]	// Amount, Count
new Float:gSplintershotIndex[MAX_PLAYERS+1][3]	// Amount, Distance, Team

// Sounds
new gSoundIndex[MAX_SOUNDS][MAX_NAME_LENGTH]

// Sprites
new spr_blood_spray
new spr_blood_drop
new spr_death_icon
new spr_explodeA
new spr_explodeB
new spr_explodeC
new spr_explodeD
new spr_explodeE
new spr_explodeF
new spr_explodeZ
new spr_glow
new spr_smoke
new spr_white
new spr_stunbeam
new spr_laserbeam1
new spr_laserbeam2
new spr_laserbeam3
new spr_laserhit
new spr_lasershock
new spr_laserspark
new spr_cloak
new spr_beam

// Models
new mdl_bone_arm
new mdl_bone_head
new mdl_bone_pelvis
new mdl_bone_ribcage
new mdl_bone_ribbone
new mdl_gib_flesh
new mdl_gib_head
new mdl_gib_legbone
new mdl_gib_lung
new mdl_gib_meat
new mdl_gib_spine
new mdl_skeleton

// Messages
new gmsgShake
new gmsgFade
new gmsgDeathMsg

/************************************************************
* ADMIN FUNCTIONS
************************************************************/

// POWERS
public admin_powers(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_powers < authid | part of nick >")
		return PLUGIN_HANDLED
	}

	// Find target player
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		powers_get(id,iPlayer)
	}
	return PLUGIN_HANDLED
}

// POWERS MSG
public admin_powersmsg(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_powersmsg < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[POWERS] Notify messages are now on.")
		gMsg = 1
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[POWERS] Notify messages are now off.")
		gMsg = 0
	}
	return PLUGIN_HANDLED
}

// POWERS FX
public admin_powersfx(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_powersfx < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[POWERS] Special FX are now on.")
		gFx = 1
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[POWERS] Special FX are now off.")
		gFx = 0
	}
	return PLUGIN_HANDLED
}

// NO POWERS
public admin_nopowers(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_nopowers < authid | part of nick > [no message]")
		return PLUGIN_HANDLED
	}

	// Find target player
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Remove powers
		gPowersIndex[iPlayer] = POWERS_NONE
		format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has no powers",sName)
		console_print(id,sMsg)

		// Suppress removal message if specified
		new bMsg = 1
		if (read_argc() == 3) {
			bMsg = 0
		}
		if (gMsg && bMsg) {
			format(sMsg,MAX_TEXT_LENGTH,"Powers: Your powers were removed!")
			player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
		}

		// Reset abilities
		player_reset(iPlayer)
		
		// Reset effects
		if (gFx) {
			powers_fx(iPlayer)
		}
	}
	return PLUGIN_HANDLED
}

// GOD
public admin_god(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_god < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_GOD)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has god powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You have God powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_GOD)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has god powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your God powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// SHIELD
public admin_shield(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_shield < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_SHIELD)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has shield powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You have Shield powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_SHIELD)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has shield powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Shield powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// SPEED
public admin_speed(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_speed < authid | part of nick > < on | off > [speed ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gSpeedIndex[iPlayer] = floatstr(sArg3)
			}
			else {
				gSpeedIndex[iPlayer] = DEFAULT_SPEED_RATIO
			}
			// Power on
			powers_add(iPlayer,POWERS_SPEED)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has speed powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Speed powers! (%i percent speed)",floatround(gSpeedIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_SPEED)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has speed powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Speed powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// STEALTH
public admin_stealth(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_stealth < authid | part of nick > < on | off > [stealth ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new Float:fRatio
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				fRatio = floatstr(sArg3)
				if (fRatio > 1.0) fRatio = 1.0
				gStealthIndex[iPlayer] = float(255 - floatround(fRatio*255))
			}
			else {
				gStealthIndex[iPlayer] = float(255 - floatround(DEFAULT_STEALTH_RATIO*255))
			}
			// Power on
			powers_add(iPlayer,POWERS_STEALTH)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has stealth powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Stealth powers! (%i percent visible)",floatround((gStealthIndex[iPlayer]/255)*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_STEALTH)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has stealth powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Stealth powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// PROTECT
public admin_protect(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_protect < authid | part of nick > < on | off > [damage ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gProtectIndex[iPlayer] = floatstr(sArg3)
			}
			else {
				gProtectIndex[iPlayer] = DEFAULT_PROTECT_RATIO
			}
			// Power on
			powers_add(iPlayer,POWERS_PROTECT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has protect powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Protect powers! (%i percent reduced damage)",floatround(gProtectIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_PROTECT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has protect powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Protect powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// RAMBO
public admin_rambo(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_rambo < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_RAMBO)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has rambo powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became Rambo! (Infinite Bullets and Armor)","")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_RAMBO)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has rambo powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer Rambo!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// LEECH
public admin_leech(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_leech < authid | part of nick > < on | off > [damage ratio] [health max]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		// Set player flag
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gLeechIndex[iPlayer] = floatstr(sArg3)
				gHealthIndex[iPlayer] = str_to_num(sArg4)
			}
			else {
				gLeechIndex[iPlayer] = DEFAULT_LEECH_RATIO
				gHealthIndex[iPlayer] = DEFAULT_LEECH_MAX
			}
			// Power on
			powers_add(iPlayer,POWERS_LEECH)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has leech powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Leech powers! (%i percent damage to health)",floatround(gLeechIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_LEECH)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has leech powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Leech powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// HARM
public admin_harm(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_harm < authid | part of nick > < on | off > [damage ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gHarmIndex[iPlayer] = floatstr(sArg3)
			}
			else {
				gHarmIndex[iPlayer] = DEFAULT_HARM_RATIO
			}
			// Power on
			powers_add(iPlayer,POWERS_HARM)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has harm powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Harm powers! (%i percent damage)",floatround(gHarmIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_HARM)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has harm powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Harm powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// ABSORB
public admin_absorb(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_absorb < authid | part of nick > < on | off > [damage ratio] [health max]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gAbsorbIndex[iPlayer] = floatstr(sArg3)
				gHealthIndex[iPlayer] = str_to_num(sArg4)
			}
			else {
				gAbsorbIndex[iPlayer] = DEFAULT_ABSORB_RATIO
				gHealthIndex[iPlayer] = DEFAULT_ABSORB_MAX
			}
			// Power on
			powers_add(iPlayer,POWERS_ABSORB)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has absorb powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Absorb powers! (%i percent damage absorb)",floatround(gAbsorbIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}

			// Force player to switch to knife only
			if (!is_user_alive(iPlayer)) {
				engclient_cmd(iPlayer,"weapon_knife")
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_ABSORB)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has absorb powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Absorb powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// REFLECT
public admin_reflect(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_reflect < authid | part of nick > < on | off > [damage ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gReflectIndex[iPlayer] = floatstr(sArg3)
			}
			else {
				gReflectIndex[iPlayer] = DEFAULT_REFLECT_RATIO
			}
			// Power on
			powers_add(iPlayer,POWERS_REFLECT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has reflect powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Reflect powers! (%i percent damage reflect)",floatround(gReflectIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_REFLECT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has reflect powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Reflect powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// CURSE
public admin_curse(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_curse < authid | part of nick > < on | off > [damage ratio]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gCurseIndex[iPlayer] = floatstr(sArg3)
			}
			else {
				gCurseIndex[iPlayer] = DEFAULT_CURSE_RATIO
			}
			// Power on
			powers_add(iPlayer,POWERS_CURSE)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has curse powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have been Cursed! (%i percent mirror damage)",floatround(gCurseIndex[iPlayer]*100))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_CURSE)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has curse powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer Cursed!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// REGENERATION
public admin_regen(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_regen < authid | part of nick > < on | off > [health amount] [time interval] [health max]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 6) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				gRegenIndex[iPlayer][0] = floatstr(sArg3)
				gRegenIndex[iPlayer][1] = floatstr(sArg4)
				gHealthIndex[iPlayer] = str_to_num(sArg5)
			}
			else {
				gRegenIndex[iPlayer][0] = float(DEFAULT_REGEN_HEALTH)
				gRegenIndex[iPlayer][1] = DEFAULT_REGEN_INTERVAL
				gHealthIndex[iPlayer] = DEFAULT_REGEN_MAX
			}
			// Power on
			powers_add(iPlayer,POWERS_REGEN)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has regen powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have Regeneration powers! (+%i health per cycle)",floatround(gRegenIndex[iPlayer][0]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_REGEN)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has regen powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Regeneration powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// POISON
public admin_poison(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_poison < authid | part of nick > < on | off > [health amount] [time interval]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gPoisonIndex[iPlayer][0] = floatstr(sArg3)
				gPoisonIndex[iPlayer][1] = floatstr(sArg4)
			}
			else {
				gPoisonIndex[iPlayer][0] = float(DEFAULT_POISON_DAMAGE)
				gPoisonIndex[iPlayer][1] = DEFAULT_POISON_INTERVAL
			}
			// Power on
			powers_add(iPlayer,POWERS_POISON)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has poison powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have been Poisoned! (-%i health per cycle)",floatround(gPoisonIndex[iPlayer][0]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_POISON)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has poison powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer Poisoned!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// DEATH
public admin_death(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_death < authid | part of nick > < on | off > [countdown time] [effect distance]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gDeathIndex[iPlayer][0] = float(gTimer)+(floatstr(sArg3)*100)
				gDeathIndex[iPlayer][1] = floatstr(sArg3)
				gDeathIndex[iPlayer][2] = floatstr(sArg4)
			}
			else {
				gDeathIndex[iPlayer][0] = float(gTimer)+(float(DEFAULT_DEATH_COUNT)*100)
				gDeathIndex[iPlayer][1] = float(DEFAULT_DEATH_COUNT)
				gDeathIndex[iPlayer][2] = float(DEFAULT_DEATH_DISTANCE)
			}
			// Power on
			powers_add(iPlayer,POWERS_DEATH)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has death powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Death!!! (%i seconds to live)",floatround(gDeathIndex[iPlayer][1]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_DEATH)
			if (gFx) {
				sound_stop(iPlayer)
			}
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has death powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You no longer have Death!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// FIREBALL
public admin_fireball(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_fireball < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect team]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 7) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				new sArg6[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				read_argv(6,sArg6,MAX_NAME_LENGTH)
				gFireballIndex[iPlayer][0] = floatstr(sArg3)
				gFireballIndex[iPlayer][1] = floatstr(sArg4)
				gFireballIndex[iPlayer][2] = floatstr(sArg5)
				gFireballIndex[iPlayer][3] = floatstr(sArg6)
			}
			else {
				gFireballIndex[iPlayer][0] = float(DEFAULT_FIREBALL_DAMAGE)
				gFireballIndex[iPlayer][1] = DEFAULT_FIREBALL_INTERVAL
				gFireballIndex[iPlayer][2] = float(DEFAULT_FIREBALL_DISTANCE)
				gFireballIndex[iPlayer][3] = float(DEFAULT_FIREBALL_TEAM)
			}
			// Power on
			powers_add(iPlayer,POWERS_FIREBALL)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has fireball powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Human Fireball! (%i damage per cycle)",floatround(gFireballIndex[iPlayer][0]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_FIREBALL)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has fireball powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Human Fireball!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// MEDIC
public admin_medic(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_medic < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect opponent]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 7) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				new sArg6[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				read_argv(6,sArg6,MAX_NAME_LENGTH)
				gMedicIndex[iPlayer][0] = floatstr(sArg3)
				gMedicIndex[iPlayer][1] = floatstr(sArg4)
				gMedicIndex[iPlayer][2] = floatstr(sArg5)
				gMedicIndex[iPlayer][3] = floatstr(sArg6)
			}
			else {
				gMedicIndex[iPlayer][0] = float(DEFAULT_MEDIC_HEALTH)
				gMedicIndex[iPlayer][1] = DEFAULT_MEDIC_INTERVAL
				gMedicIndex[iPlayer][2] = float(DEFAULT_MEDIC_DISTANCE)
				gMedicIndex[iPlayer][3] = float(DEFAULT_MEDIC_TEAM)
			}
			// Power on
			powers_add(iPlayer,POWERS_MEDIC)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has medic powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Medic! (+%i healing)",floatround(gMedicIndex[iPlayer][0]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_MEDIC)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has medic powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Medic!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// VAMPIRE
public admin_vampire(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_vampire < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect team] [health max]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 8) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				new sArg6[MAX_NAME_LENGTH]
				new sArg7[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				read_argv(6,sArg6,MAX_NAME_LENGTH)
				read_argv(7,sArg7,MAX_NAME_LENGTH)
				gVampireIndex[iPlayer][0] = floatstr(sArg3)
				gVampireIndex[iPlayer][1] = floatstr(sArg4)
				gVampireIndex[iPlayer][2] = floatstr(sArg5)
				gVampireIndex[iPlayer][3] = floatstr(sArg6)
				gHealthIndex[iPlayer] = str_to_num(sArg7)
			}
			else {
				gVampireIndex[iPlayer][0] = float(DEFAULT_VAMPIRE_HEALTH)
				gVampireIndex[iPlayer][1] = DEFAULT_VAMPIRE_INTERVAL
				gVampireIndex[iPlayer][2] = float(DEFAULT_VAMPIRE_DISTANCE)
				gVampireIndex[iPlayer][3] = float(DEFAULT_VAMPIRE_TEAM)
				gHealthIndex[iPlayer] = DEFAULT_VAMPIRE_MAX
			}
			// Power on
			powers_add(iPlayer,POWERS_VAMPIRE)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has vampire powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Vampire! (%i health per cycle)",floatround(gVampireIndex[iPlayer][0]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_VAMPIRE)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has vampire powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Vampire!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// GHOST
public admin_ghost(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_ghost < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_GHOST)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has ghost powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Ghost!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_GHOST)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has ghost powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Ghost!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// HOLOGRAM
public admin_hologram(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_hologram < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_HOLOGRAM)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has hologram powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Hologram!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_HOLOGRAM)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has hologram powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Hologram!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// TIMEBOMB
public admin_timebomb(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_timebomb < authid | part of nick > < on | off > [countdown time] [effect distance]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gTimebombIndex[iPlayer][0] = float(gTimer)+(floatstr(sArg3)*100)
				gTimebombIndex[iPlayer][1] = floatstr(sArg3)
				gTimebombIndex[iPlayer][2] = floatstr(sArg4)
			}
			else {
				gTimebombIndex[iPlayer][0] = float(gTimer)+(float(DEFAULT_TIMEBOMB_COUNT)*100)
				gTimebombIndex[iPlayer][1] = float(DEFAULT_TIMEBOMB_COUNT)
				gTimebombIndex[iPlayer][2] = float(DEFAULT_TIMEBOMB_DISTANCE)
			}
			// Power on
			powers_add(iPlayer,POWERS_TIMEBOMB)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has timebomb powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Human Timebomb! (%i seconds to live)",floatround(gTimebombIndex[iPlayer][1]))
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_TIMEBOMB)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has timebomb powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Human Timebomb!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// CLOAK
public admin_cloak(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[POWERS] Usage: amx_cloak < authid | part of nick > < on | off > [health amount] [uncloak time]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gCloakIndex[iPlayer][0] = float(0)
				gCloakIndex[iPlayer][1] = float(get_user_health(iPlayer))
				gCloakIndex[iPlayer][2] = floatstr(sArg4)
				gCloakIndex[iPlayer][3] = floatstr(sArg3)
			}
			else {
				gCloakIndex[iPlayer][0] = float(0)
				gCloakIndex[iPlayer][1] = float(get_user_health(iPlayer))
				gCloakIndex[iPlayer][2] = DEFAULT_CLOAK_INTERVAL
				gCloakIndex[iPlayer][3] = float(DEFAULT_CLOAK_HEALTH)
			}
			// Power on
			powers_add(iPlayer,POWERS_CLOAK)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has cloaking powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Cloaking powers!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_CLOAK)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has cloaking powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Cloaking powers!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// ONESHOT
public admin_oneshot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_oneshot < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			// Power on
			powers_add(iPlayer,POWERS_ONESHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has oneshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got One Shot Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_ONESHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has oneshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your One Shot Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// STUNSHOT
public admin_stunshot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_stunshot < authid | part of nick > < on | off > [damage amount] [effect time]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gStunshotIndex[iPlayer][0] = floatstr(sArg3)
				gStunshotIndex[iPlayer][1] = floatstr(sArg4)
			}
			else {
				gStunshotIndex[iPlayer][0] = float(DEFAULT_STUNSHOT_DAMAGE)
				gStunshotIndex[iPlayer][1] = float(DEFAULT_STUNSHOT_COUNT)
			}
			// Power on
			powers_add(iPlayer,POWERS_STUNSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has stunshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Stun Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_STUNSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has stunshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Stun Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// EXPLODESHOT
public admin_explodeshot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_explodeshot < authid | part of nick > < on | off > [damage ratio] [effect distance]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gExplodeshotIndex[iPlayer][0] = floatstr(sArg3)
				gExplodeshotIndex[iPlayer][1] = floatstr(sArg4)
			}
			else {
				gExplodeshotIndex[iPlayer][0] = DEFAULT_EXPLODESHOT_RATIO
				gExplodeshotIndex[iPlayer][1] = float(DEFAULT_EXPLODESHOT_DISTANCE)
			}
			// Power on
			powers_add(iPlayer,POWERS_EXPLODESHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has explodeshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Exploding Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_EXPLODESHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has explodeshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Exploding Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// LASERSHOT
public admin_lasershot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_lasershot < authid | part of nick > < on | off > [charge time] [effect distance] [effect team]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 6) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				gLasershotIndex[iPlayer][0] = floatstr(sArg3)
				gLasershotIndex[iPlayer][1] = floatstr(sArg3)
				gLasershotIndex[iPlayer][2] = floatstr(sArg4)
				gLasershotIndex[iPlayer][3] = floatstr(sArg5)
			}
			else {
				gLasershotIndex[iPlayer][0] = float(DEFAULT_LASERSHOT_COUNT)
				gLasershotIndex[iPlayer][1] = float(DEFAULT_LASERSHOT_COUNT)
				gLasershotIndex[iPlayer][2] = float(DEFAULT_LASERSHOT_DISTANCE)
				gLasershotIndex[iPlayer][3] = float(DEFAULT_LASERSHOT_TEAM)
			}
			// Power on
			powers_add(iPlayer,POWERS_LASERSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has lasershot powers",sName)
			console_print(id,sMsg)
			engclient_cmd(iPlayer,"weapon_knife")
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Laser Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_EXPLODESHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has lasershot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Laser Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// FLASHSHOT
public admin_flashshot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_flashshot < authid | part of nick > < on | off > [damage amount] [effect time]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gFlashshotIndex[iPlayer][0] = floatstr(sArg3)
				gFlashshotIndex[iPlayer][1] = floatstr(sArg4)
			}
			else {
				gFlashshotIndex[iPlayer][0] = float(DEFAULT_FLASHSHOT_DAMAGE)
				gFlashshotIndex[iPlayer][1] = float(DEFAULT_FLASHSHOT_COUNT)
			}
			// Power on
			powers_add(iPlayer,POWERS_FLASHSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has flashshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Flashbang Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_FLASHSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has flashshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Flashbang Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// AGSHOT
public admin_agshot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_agshot < authid | part of nick > < on | off > [damage amount] [gravity amount] [effect time]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 5) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				gAGshotIndex[iPlayer][0] = floatstr(sArg3)
				gAGshotIndex[iPlayer][1] = floatstr(sArg4)
			}
			else {
				gAGshotIndex[iPlayer][0] = float(DEFAULT_AGSHOT_DAMAGE)
				gAGshotIndex[iPlayer][1] = float(DEFAULT_AGSHOT_COUNT)
			}
			// Power on
			powers_add(iPlayer,POWERS_AGSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has agshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Anti-Gravity Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_AGSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has agshot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Anti-Gravity Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// SPLINTERSHOT
public admin_splintershot(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_splintershot < authid | part of nick > < on | off > [damage amount] [effect distance] [effect team]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 6) {
				new sArg3[MAX_NAME_LENGTH]
				new sArg4[MAX_NAME_LENGTH]
				new sArg5[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				read_argv(4,sArg4,MAX_NAME_LENGTH)
				read_argv(5,sArg5,MAX_NAME_LENGTH)
				gSplintershotIndex[iPlayer][0] = floatstr(sArg3)
				gSplintershotIndex[iPlayer][1] = floatstr(sArg4)
				gSplintershotIndex[iPlayer][2] = floatstr(sArg5)
			}
			else {
				gSplintershotIndex[iPlayer][0] = float(DEFAULT_SPLINTER_DAMAGE)
				gSplintershotIndex[iPlayer][1] = float(DEFAULT_SPLINTER_DISTANCE)
				gSplintershotIndex[iPlayer][2] = float(DEFAULT_SPLINTER_TEAM)
			}
			// Power on
			powers_add(iPlayer,POWERS_SPLINTERSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has splintershot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got Splinter Bullets!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_SPLINTERSHOT)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has splintershot powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You lost your Splinter Bullets!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

// GRENADIER
public admin_grenadier(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[POWERS] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[POWERS] Usage: amx_grenadier < authid | part of nick > < on | off > [grenade type <0=fb|1=he|2=smk>]")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		// Set status on target player
		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			if (read_argc() == 4) {
				new sArg3[MAX_NAME_LENGTH]
				read_argv(3,sArg3,MAX_NAME_LENGTH)
				gGrenadeIndex[iPlayer][0] = floatstr(sArg3)
			}
			else {
				gGrenadeIndex[iPlayer][0] = float(DEFAULT_GRENADE_TYPE)
			}
			// Power on
			powers_add(iPlayer,POWERS_GRENADIER)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" now has grenadier powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You became a Grenadier!")
				player_msg(iPlayer,sMsg,POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
		else {
			// Power off
			powers_remove(iPlayer,POWERS_GRENADIER)
			format(sMsg,MAX_TEXT_LENGTH,"[POWERS] ^"%s^" no longer has grenadier powers",sName)
			console_print(id,sMsg)
			if (gMsg) {
				player_msg(iPlayer,"Powers: You are no longer a Grenadier!",POWERS_MSG_R,POWERS_MSG_G,POWERS_MSG_B)
			}
		}
	}
	return PLUGIN_HANDLED
}

/************************************************************
* POWERS FUNCTIONS
************************************************************/

public powers_add(player,POWERS_FLAG)
{
	if (!(gPowersIndex[player]&POWERS_FLAG)) {
		gPowersIndex[player] += POWERS_FLAG
	}
	if (is_user_alive(player)) {
		// Abilities
		if (POWERS_FLAG==POWERS_GOD) {
			gGodIndex[player] = float(get_user_health(player))
			set_user_health(player,floatround(gGodIndex[player])+256)
		}
		else if (POWERS_FLAG==POWERS_SPEED) {
			set_user_maxspeed(player,gSpeedIndex[player]*float(DEFAULT_SPEED))
		}
		else if (POWERS_FLAG==POWERS_RAMBO) {
			set_user_armor(player,DEFAULT_ARMOR)
		}
		else if (POWERS_FLAG==POWERS_GHOST) {
			set_user_noclip(player,1)
		}
		else if (POWERS_FLAG==POWERS_HOLOGRAM) {
			set_user_godmode(player,1)
			set_user_hitzones(player,0,0)
		}
		else if (POWERS_FLAG==POWERS_CLOAK) {
			set_user_health(player,floatround(gCloakIndex[player][3]))
		}
		else if (POWERS_FLAG==POWERS_GRENADIER) {
			engclient_cmd(player,"weapon_knife")
		}
		else if (POWERS_FLAG==POWERS_ONESHOT || POWERS_FLAG==POWERS_STUNSHOT || POWERS_FLAG==POWERS_EXPLODESHOT || 
		POWERS_FLAG==POWERS_FLASHSHOT || POWERS_FLAG==POWERS_AGSHOT || POWERS_FLAG==POWERS_SPLINTERSHOT) {
			sound_play_one(player,SOUND_BULLETS)
		}
		// Effects
		if (gFx) {
			powers_fx(player)
		}
	}
	return PLUGIN_CONTINUE
}

public powers_remove(player,POWERS_FLAG)
{
	if (gPowersIndex[player]&POWERS_FLAG) {
		gPowersIndex[player] -= POWERS_FLAG
	}
	if (is_user_alive(player)) {
		// Abilities
		if (POWERS_FLAG==POWERS_GOD) {
			set_user_health(player,floatround(gGodIndex[player]))
		}
		else if (POWERS_FLAG==POWERS_SPEED) {
			player_reset_speed(player)
		}
		else if (POWERS_FLAG==POWERS_GHOST) {
			set_user_noclip(player,0)
		}
		else if (POWERS_FLAG==POWERS_HOLOGRAM) {
			set_user_godmode(player,0)
			set_user_hitzones(player)
		}
		else if (POWERS_FLAG==POWERS_CLOAK) {
			if (floatround(gCloakIndex[player][1]) > 0) {
				set_user_health(player,floatround(gCloakIndex[player][1]))
			}
			else {
				set_user_health(player,100)
			}
		}
		else if (POWERS_FLAG==POWERS_GRENADIER) {
			engclient_cmd(player,"weapon_knife")
			gGrenadeIndex[player][1] = float(0)
		}
		// Effects
		if (gFx) {
			powers_fx(player)
		}
	}
	return PLUGIN_CONTINUE
}

public powers_get(admin,player)
{
	new iFlags
	new sFlags[MAX_TEXT_LENGTH]
	iFlags = gPowersIndex[player]
	
	if (gPowersIndex[player]) {
		// List powers
		if (iFlags&POWERS_GOD) add(sFlags,MAX_TEXT_LENGTH,"god*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_SHIELD) add(sFlags,MAX_TEXT_LENGTH,"shield*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_SPEED) add(sFlags,MAX_TEXT_LENGTH,"speed*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_STEALTH) add(sFlags,MAX_TEXT_LENGTH,"stealth*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_HARM) add(sFlags,MAX_TEXT_LENGTH,"harm*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_RAMBO) add(sFlags,MAX_TEXT_LENGTH,"rambo*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_PROTECT) add(sFlags,MAX_TEXT_LENGTH,"protect*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_LEECH) add(sFlags,MAX_TEXT_LENGTH,"leech*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_ABSORB) add(sFlags,MAX_TEXT_LENGTH,"absorb*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_REFLECT) add(sFlags,MAX_TEXT_LENGTH,"reflect*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_REGEN) add(sFlags,MAX_TEXT_LENGTH,"regen*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_POISON) add(sFlags,MAX_TEXT_LENGTH,"poison*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_CURSE) add(sFlags,MAX_TEXT_LENGTH,"curse*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_DEATH) add(sFlags,MAX_TEXT_LENGTH,"death*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_FIREBALL) add(sFlags,MAX_TEXT_LENGTH,"fireball*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_MEDIC) add(sFlags,MAX_TEXT_LENGTH,"medic*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_GHOST) add(sFlags,MAX_TEXT_LENGTH,"ghost*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_HOLOGRAM) add(sFlags,MAX_TEXT_LENGTH,"hologram*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_TIMEBOMB) add(sFlags,MAX_TEXT_LENGTH,"timebomb*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_ONESHOT) add(sFlags,MAX_TEXT_LENGTH,"oneshot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_STUNSHOT) add(sFlags,MAX_TEXT_LENGTH,"stunshot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_EXPLODESHOT) add(sFlags,MAX_TEXT_LENGTH,"explodeshot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_CLOAK) add(sFlags,MAX_TEXT_LENGTH,"cloak*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_LASERSHOT) add(sFlags,MAX_TEXT_LENGTH,"lasershot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_FLASHSHOT) add(sFlags,MAX_TEXT_LENGTH,"flashshot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_VAMPIRE) add(sFlags,MAX_TEXT_LENGTH,"agshot*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_VAMPIRE) add(sFlags,MAX_TEXT_LENGTH,"vampire*",MAX_NAME_LENGTH)
		if (iFlags&POWERS_GRENADIER) add(sFlags,MAX_TEXT_LENGTH,"grenadier*",MAX_NAME_LENGTH)

		// Admin request
		if (admin) {
			new sName[MAX_NAME_LENGTH]
			get_user_name(player,sName,MAX_NAME_LENGTH)
			client_print(admin,print_console,"[POWERS] ^"%s^"'s powers: *%s (%i)",sName,sFlags,iFlags)
		}
		// Player request
		else {
			client_print(player,print_chat,"[POWERS] Your powers: *%s",sFlags,iFlags)
		}
	}
	else {
		// Admin request
		if (admin) {
			new sName[MAX_NAME_LENGTH]
			get_user_name(player,sName,MAX_NAME_LENGTH)
			client_print(admin,print_console,"[POWERS] ^"%s^" has no powers",sName)
		}
		// Player request
		else {
			client_print(player,print_chat,"[POWERS] You have no powers")
		}
	}
	return PLUGIN_CONTINUE
}

public powers_fx(player)
{
	if (is_user_alive(player)) {
		// Reset effects
		fx_normal(player)
		fx_remove_attachments(player)
	
		new iPowersFlags = gPowersIndex[player]
		if (iPowersFlags) {
			// Ordered by priority
			// No fx for speed, rambo, harm, oneshot, 
			// explodeshot, stunshot, flashshot, agshot, grenadier
			if (iPowersFlags&POWERS_GHOST) {
				fx_custom(player,kRenderFxGlowShell,20,20,20,kRenderTransAdd,255)
				fx_screen_fade(player,1,0,0,255,255,255,255)
			}
			else if (iPowersFlags&POWERS_CLOAK) {
				if (gTimer < gCloakIndex[player][0]) {
					// Visible cloaking effect
					if ((gCloakIndex[player][0]-gTimer) >= DEFAULT_CLOAK_INTERVAL) {
						fx_custom(player,kRenderFxGlowShell,0,255,0,kRenderTransAdd,1)
					}
					else {
						fx_custom(player,kRenderFxGlowShell,0,20,0,kRenderTransAdd,1)
					}
				}
				else {
					// Invisible
					fx_trans(player,0)
				}
			}
			else if (iPowersFlags&POWERS_HOLOGRAM) {
				fx_custom(player,kRenderFxHologram,0,0,0,kRenderTransAlpha,0)
				// play hologram sound
			}
			else if (iPowersFlags&POWERS_DEATH) {
				fx_glow(player,255,0,0,0)
				fx_death(player)
				fx_screen_fade(player,1,0,0,255,0,0,255)
				sound_play_one(player,SOUND_HEARTBEAT)
			}
			else if (iPowersFlags&POWERS_TIMEBOMB) {
				fx_custom(player,kRenderFxGlowShell,255,0,0,kRenderTransAlpha,50)
				sound_play_all(SOUND_BLOW,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM)
			}
			else if (iPowersFlags&POWERS_STEALTH) {
				fx_trans(player,floatround(gStealthIndex[player]))
			}
			else if (iPowersFlags&POWERS_GOD) {
				fx_glow(player,255,175,0,20)
				fx_screen_fade(player,1,0,0,255,175,0,255)
			}
			else if (iPowersFlags&POWERS_SHIELD) {
				fx_glow(player,0,100,255,20)
				fx_screen_fade(player,1,0,0,0,100,255,255)
			}
			else if (iPowersFlags&POWERS_FIREBALL) {
				fx_glow(player,255,75,0,255)
				fx_screen_fade(player,1,0,0,255,75,0,128)
			}
			else if (iPowersFlags&POWERS_MEDIC) {
				fx_glow(player,50,128,0,255)
				fx_screen_fade(player,1,0,0,100,255,0,128)
			}
			else if (iPowersFlags&POWERS_VAMPIRE) {
				fx_glow(player,50,0,255,255)
				fx_screen_fade(player,1,0,0,50,0,255,255)
			}
			else if (iPowersFlags&POWERS_PROTECT) {
				fx_glow(player,255,200,100,100)
				fx_screen_fade(player,1,0,0,200,100,100,128)
			}
			else if (iPowersFlags&POWERS_LEECH) {
				fx_glow(player,20,0,0,255)
				fx_screen_fade(player,1,0,0,255,0,0,128)
			}
			else if (iPowersFlags&POWERS_ABSORB) {
				fx_glow(player,4,8,20,255)
				fx_screen_fade(player,1,0,0,0,100,255,128)
			}
			else if (iPowersFlags&POWERS_REFLECT) {
				fx_glow(player,255,255,255,0)
				fx_screen_fade(player,1,0,0,255,255,255,128)
			}
			else if (iPowersFlags&POWERS_CURSE) {
				fx_glow(player,15,0,25,255)
				fx_screen_fade(player,1,0,0,150,0,255,255)
			}
			else if (iPowersFlags&POWERS_REGEN) {
				fx_glow(player,20,20,0,255)
				fx_screen_fade(player,1,0,0,255,255,0,255)
			}
			else if (iPowersFlags&POWERS_POISON) {
				fx_glow(player,0,20,0,255)
				fx_screen_fade(player,1,0,0,0,255,0,255)
			}
		}
	}
}

public powers_reset()
{
	new iPlayer, iPlayerFlags, iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers)

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i];
		iPlayerFlags = gPowersIndex[iPlayer]
		
		// Check player powers
		if (iPlayerFlags) {
			// Speed
			if (iPlayerFlags&POWERS_SPEED) {
				powers_add(iPlayer,POWERS_SPEED)
			}
			// Cloak
			if (iPlayerFlags&POWERS_CLOAK) {
				powers_add(iPlayer,POWERS_CLOAK)
			}
			// Hologram
			if (iPlayerFlags&POWERS_HOLOGRAM) {
				powers_add(iPlayer,POWERS_HOLOGRAM)
			}
			// Death
			if (iPlayerFlags&POWERS_DEATH) {
				powers_remove(iPlayer,POWERS_DEATH)
				if (gFx) {
					sound_stop(iPlayer)
				}
			}
			// Timebomb
			if (iPlayerFlags&POWERS_TIMEBOMB) {
				powers_remove(iPlayer,POWERS_TIMEBOMB)
			}
			// Armor
			if (iPlayerFlags&POWERS_RAMBO) {
				set_user_armor(iPlayer,DEFAULT_ARMOR)
			}
			// Grenadier
			if (iPlayerFlags&POWERS_GRENADIER) {
				new iGrenade
				new iGrenadeType = floatround(gGrenadeIndex[iPlayer][0])
				new sGrenade[MAX_NAME_LENGTH]

				if (iGrenadeType==0) {
					iGrenade = CSW_FLASHBANG
				}
				else if (iGrenadeType==1) {
					iGrenade = CSW_HEGRENADE
				}
				else if (iGrenadeType==2) {
					iGrenade = CSW_SMOKEGRENADE
				}
				get_weaponname(iGrenade,sGrenade,MAX_NAME_LENGTH)
				if (floatround(gGrenadeIndex[iPlayer][1])==2) {
					give_item(iPlayer,sGrenade)
				}
				gGrenadeIndex[iPlayer][1] = float(1)
				engclient_cmd(iPlayer,sGrenade)
			}
		}
		// Reset effects
		if (gFx) {
			powers_fx(iPlayer);
		}
	}
}

static powers_effect_local(player,source[3],range,power,amount)
{
	new iHP, iRecv, iRecvFlags, iDistance, iOrigin[3]
	new iPlayers[MAX_PLAYERS], iNumPlayers, iCount
	new Float:fRatio

	get_players(iPlayers,iNumPlayers,"a")
	for (new i = 0; i < iNumPlayers; i++) {
		iRecv = iPlayers[i]
		iRecvFlags = gPowersIndex[iRecv]
		if (player != iRecv && !(iRecvFlags&POWERS_GOD) && !(iRecvFlags&POWERS_SHIELD)) {
			get_user_origin(iRecv,iOrigin)
			iDistance = get_distance(iOrigin,source)
			if (iDistance < range) {
				fRatio = float(iDistance)/float(range)
				// ExplodeShot
				if (power&POWERS_EXPLODESHOT) {
					if (!(iRecvFlags&POWERS_EXPLODESHOT)) {
						new iDamage = floatround(amount*fRatio)
						if (get_user_health(iRecv) > iDamage) {
							user_slap(iRecv,iDamage)
						}
						else {
							set_user_health(iRecv,1)
						}
					}
				}
				// Fireball
				else if (power&POWERS_FIREBALL) {
					new iTeam1 = get_user_team(player)
					new iTeam2 = get_user_team(iRecv)
					new iTeamFlag = floatround(gFireballIndex[player][3])

					if ((iTeam1 != iTeam2) || (iTeam1 == iTeam2 && iTeamFlag)) {
						new iDamage = amount - floatround(amount*(float(iDistance)/float(range)))
						iHP = get_user_health(iRecv)+iDamage
						if (iHP < 1) {
							// Credit the kill
							player_kill(player,iRecv,0)

							if (gMsg) {
								new sName[MAX_NAME_LENGTH]
								new sMsg[MAX_TEXT_LENGTH]
								get_user_name(player,sName,MAX_NAME_LENGTH)
								format(sMsg,MAX_TEXT_LENGTH,"Powers: You got killed by %s the Human Fireball!",sName)
								player_msg(iRecv,sMsg,0,100,255)
							}
						}
						set_user_health(iRecv,iHP)
						if (gFx) {
							// Calculate new position
							new iOriginAim[3]
							get_user_origin(iRecv,iOriginAim,3)
							new iDistanceAim = (get_distance(iOrigin,iOriginAim))/10
							new iX = (iOriginAim[0] - iOrigin[0])/iDistanceAim
							new iY = (iOriginAim[1] - iOrigin[1])/iDistanceAim
							iOrigin[0] += iX
							iOrigin[1] += iY
	
							// Effects
							if (power&POWERS_FIREBALL){
								client_print(iRecv,print_notify,"* You lost %i health from a Human Fireball!",iDamage)
								if (gFx) {
									fx_fireball(iOrigin)
									fx_screen_fade(iRecv,1,0,0,255,50,0,128)
									sound_play(iRecv,POWERS_FIREBALL,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
								}
							}
						}
					}
				}
				// Medic
				else if (power&POWERS_MEDIC && (get_user_health(iRecv) < gHealthIndex[iRecv])) {
					new iTeam1 = get_user_team(player)
					new iTeam2 = get_user_team(iRecv)
					new iTeamFlag = floatround(gMedicIndex[player][3])

					if ((iTeam1 == iTeam2) || (iTeam1 != iTeam2 && iTeamFlag)) {
						new iDamage = amount - floatround(amount*(float(iDistance)/float(range)))
						iHP = get_user_health(iRecv)+iDamage
						if (iHP > gHealthIndex[iRecv]) iHP = gHealthIndex[iRecv]
						set_user_health(iRecv,iHP)
	
						client_print(iRecv,print_notify,"* You gained %i health from a Medic!",iDamage)
						
						if (gFx) {
							fx_screen_fade(iRecv,1,0,0,100,255,0,128)
							fx_health(iOrigin)
							sound_play(iRecv,POWERS_MEDIC,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
						}
					}
				}
				// Vampire
				else if (power&POWERS_VAMPIRE && (get_user_health(player) < gHealthIndex[player])) {
					new iTeam1 = get_user_team(player)
					new iTeam2 = get_user_team(iRecv)
					new iTeamFlag = floatround(gVampireIndex[player][3])

					if ((iTeam1 != iTeam2) || (iTeam1 == iTeam2 && iTeamFlag)) {
						new iRecvHP = get_user_health(iRecv)
						if (iRecvHP > 1) {
							iHP = iRecvHP-amount
							if (iHP < 1) iHP = 1
							set_user_health(iRecv,iHP)
							client_print(iRecv,print_notify,"* You lost %i health from a Vampire!",iRecvHP-iHP)
							
							iHP = get_user_health(player)+(iRecvHP-iHP)
							if (iHP > gHealthIndex[player]) iHP = gHealthIndex[player]
							set_user_health(player,iHP)
							if (gFx) {
								get_user_origin(player,iOrigin)
								fx_vampire(player,iRecv)
								fx_health(iOrigin)
							}
						}
					}
				}
				// Timebomb
				else if (power&POWERS_TIMEBOMB) {
					if (fRatio < 0.25) {
						// Credit the kill
						player_kill(player,iRecv,0)

						if (gMsg) {
							new sName[MAX_NAME_LENGTH]
							new sMsg[MAX_TEXT_LENGTH]
							get_user_name(player,sName,MAX_NAME_LENGTH)
							format(sMsg,MAX_TEXT_LENGTH,"Powers: You got killed by %s the Human Timebomb!",sName)
							player_msg(iRecv,sMsg,0,100,255)
						}
					}
					else {
						iHP = get_user_health(iRecv) - floatround(get_user_health(iRecv)*fRatio)
						user_slap(iRecv,iHP)
						client_print(iRecv,print_notify,"* You lost %i health from the Human Timebomb!",iHP)
					}
					if (gFx) {
						fx_screen_shake(iRecv,10,3,10)
						fRatio = fRatio*2
						if (fRatio > 1.0) fRatio = 1.0
						sound_play(iRecv,POWERS_TIMEBOMB,CHAN_AUTO,VOL_NORM*fRatio,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
					}
				}
				// Death
				else if (power&POWERS_DEATH) {
					if (!(iRecvFlags&POWERS_DEATH)) {
						// Credit the kill
						set_user_frags(player,get_user_frags(player)+1)

						// Pass on death
						iCount += 100
						powers_add(iRecv,POWERS_DEATH)
						gDeathIndex[iRecv][0] = float(gTimer) + (gDeathIndex[player][1]*100) + iCount
						gDeathIndex[iRecv][2] = gDeathIndex[player][2]
						if (gFx) {
							powers_fx(iRecv)
							fRatio = fRatio*2
							if (fRatio > 1.0) fRatio = 1.0
							sound_play(player,POWERS_DEATH,CHAN_AUTO,VOL_NORM*fRatio,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
						}
						if (gMsg) {
							new sName[MAX_NAME_LENGTH]
							new sMsg[MAX_TEXT_LENGTH]
							get_user_name(player,sName,MAX_NAME_LENGTH)
							format(sMsg,MAX_TEXT_LENGTH,"Powers: %s gave you Death!",sName)
							player_msg(iRecv,sMsg,200,200,0)
						}
					}
				}
				// LaserShot
				else if (power&POWERS_LASERSHOT) {
					new iTeam1 = get_user_team(player)
					new iTeam2 = get_user_team(iRecv)
					new iTeamFlag = floatround(gLasershotIndex[player][3])

					if ((iTeam1 != iTeam2) || (iTeam1 == iTeam2 && iTeamFlag)) {
						// Credit the kill
						player_kill(player,iRecv,gWeaponIndex[player])

						if (gFx) {
							// Effects
							fx_trans(iRecv,0)
							fx_bone_explode(iOrigin)
							fx_laser_shock(source,iOrigin)
							fx_sparks(iOrigin,spr_laserspark)
							// Sounds
							sound_play(iRecv,POWERS_LASERSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
							// Hide body
							iOrigin[2] = iOrigin[2]-20
							set_user_origin(iRecv,iOrigin)
						}
						if (gMsg) {
							new sName[MAX_NAME_LENGTH]
							new sMsg[MAX_TEXT_LENGTH]
							get_user_name(player,sName,MAX_NAME_LENGTH)
							format(sMsg,MAX_TEXT_LENGTH,"Powers: You were killed by %s^'s Laser Shot!",sName)
							player_msg(iRecv,sMsg,200,200,0)
						}
					}
				}
				// SplinterShot
				else if (power&POWERS_SPLINTERSHOT) {
					new iTeam1 = get_user_team(player)
					new iTeam2 = get_user_team(iRecv)
					new iTeamFlag = floatround(gSplintershotIndex[player][2])

					if ((iTeam1 != iTeam2) || (iTeam1 == iTeam2 && iTeamFlag)) {
						new iDamage = floatround(float(amount)*random_float(0.5,2.0))
						iHP = get_user_health(iRecv)-iDamage
						if (iHP < 1) {
							// Credit the kill
							player_kill(player,iRecv,gWeaponIndex[player])
						}
						else {
							set_user_health(iRecv,iHP)
						}
						if (gFx) {
							new iDest[3]
							get_user_origin(iRecv,iDest)
							fx_shot_splinter(source,iDest)
						}
						client_print(iRecv,print_notify,"* You lost %i health from a splinter bullet!",iDamage)
					}
				}
			} // End if
		}
	} // End for loop
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_powers()
{
	new iPlayer, iPlayerFlags, iPlayers[MAX_PLAYERS], iNumPlayers
	new iHP, iMax, iInterval, iTime

	get_players(iPlayers,iNumPlayers,"a")

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		iPlayerFlags = gPowersIndex[iPlayer]

		// If player has any powers
		if (iPlayerFlags) {
			// Cloak
			if (iPlayerFlags&POWERS_CLOAK) {
				if (gTimer > floatround(gCloakIndex[iPlayer][0])) {
					if (gFx) {
						powers_fx(iPlayer)
					}
				}
				// Random chance of decloaking
				if (!random_num(0,10)) {
					gCloakIndex[iPlayer][0] = float(gTimer) + (gCloakIndex[iPlayer][2]/2)
					if (gFx) {
						powers_fx(iPlayer)
					}
				}
			}
			// Regen
			if (iPlayerFlags&POWERS_REGEN) {
				iInterval = floatround(gRegenIndex[iPlayer][1]*100)
				if (!(gTimer%iInterval)) {
					iHP = get_user_health(iPlayer) + floatround(gRegenIndex[iPlayer][0])
					iMax = gHealthIndex[iPlayer]
					if (iHP > iMax) iHP = iMax
					set_user_health(iPlayer,iHP)
				}
			}
			// Poison
			if (iPlayerFlags&POWERS_POISON) {
				iInterval = floatround(gPoisonIndex[iPlayer][1]*100)
				if (!(gTimer%iInterval)) {
					iHP = get_user_health(iPlayer) - floatround(gPoisonIndex[iPlayer][0])
					if (iHP < 1) iHP = 1
					set_user_health(iPlayer,iHP)
				}
			}
			// Death
			if (iPlayerFlags&POWERS_DEATH) {
				// Explode player
				if (gTimer > floatround(gDeathIndex[iPlayer][0])) {
					user_kill(iPlayer,1)
				}
				else {
					// Stop sounds one tick from death
					if (gTimer == floatround(gDeathIndex[iPlayer][0]-(POWERS_TIMER_INTERVAL*100))) {
						sound_stop(iPlayer)
					}
					// Send message
					if (!(gTimer%100)) {
						iTime = 1+(floatround(gDeathIndex[iPlayer][0])-gTimer)/100
						client_print(iPlayer,print_notify,"* %i seconds to live...",iTime)
					}
				}
			}
			// Timebomb
			if (iPlayerFlags&POWERS_TIMEBOMB) {
				// Explode player
				if (gTimer > floatround(gTimebombIndex[iPlayer][0])) {
					user_kill(iPlayer,1)
				}
				else {
					// Send message
					if (!(gTimer%100)) {
						iTime = 1+(floatround(gTimebombIndex[iPlayer][0])-gTimer)/100
						client_print(iPlayer,print_notify,"* %i seconds until explosion ...",iTime)
					}
				}
			}
			// Fireball
			if (iPlayerFlags&POWERS_FIREBALL) {
				iInterval = floatround(gFireballIndex[iPlayer][1]*100)
				if (!(gTimer%iInterval)) {
					new iOrigin[3]
					get_user_origin(iPlayer,iOrigin)
					powers_effect_local(iPlayer,iOrigin,floatround(gFireballIndex[iPlayer][2]),POWERS_FIREBALL,-1*floatround(gFireballIndex[iPlayer][0]))
				}
			}
			// Medic
			if (iPlayerFlags&POWERS_MEDIC) {
				iInterval = floatround(gMedicIndex[iPlayer][1]*100)
				if (!(gTimer%iInterval)) {
					new iOrigin[3]
					get_user_origin(iPlayer,iOrigin)
					powers_effect_local(iPlayer,iOrigin,floatround(gMedicIndex[iPlayer][2]),POWERS_MEDIC,floatround(gMedicIndex[iPlayer][0]))
				}
			}
			// Vampire
			if (iPlayerFlags&POWERS_VAMPIRE) {
				iInterval = floatround(gVampireIndex[iPlayer][1]*100)
				if (!(gTimer%iInterval)) {
					new iOrigin[3]
					get_user_origin(iPlayer,iOrigin)
					if (gFx) {
						fx_remove_beam(iPlayer)
					}
					powers_effect_local(iPlayer,iOrigin,floatround(gVampireIndex[iPlayer][2]),POWERS_VAMPIRE,floatround(gVampireIndex[iPlayer][0]))
				}
			}
			// Lasershot
			if (iPlayerFlags&POWERS_LASERSHOT) {
				iInterval = 100
				if (!(gTimer%iInterval)) {
					// Laser ready
					if (gLasershotIndex[iPlayer][0] == 0) {
						if (gMsg) {
							new sMsg[MAX_TEXT_LENGTH]
							format(sMsg,MAX_TEXT_LENGTH,"Powers: Your Laser is ready to fire!")
							player_msg(iPlayer,sMsg,0,200,0)
						}
						client_cmd(iPlayer,"slot2;")
						gLasershotIndex[iPlayer][0] = -1.0
					}
					// Countdown
					else if (gLasershotIndex[iPlayer][0] > 0) {
						if (gMsg) {
							new sMsg[MAX_TEXT_LENGTH]
							format(sMsg,MAX_TEXT_LENGTH,"Powers: Charging Laser... %i seconds left!",floatround(gLasershotIndex[iPlayer][0]))
							player_msg(iPlayer,sMsg,100,100,100)
							sound_play_one(iPlayer,SOUND_BEEP1)
						}
						gLasershotIndex[iPlayer][0] -= 1
					}
				}
			}
		} // End powers check
		
		// Check for stunned players
		if (gStunIndex[iPlayer]) {
			if (gTimer > gStunIndex[iPlayer]) {
				player_reset_speed(iPlayer)
				set_user_gravity(iPlayer)
				gStunIndex[iPlayer] = 0
			}
			else {
				set_user_maxspeed(iPlayer,float(1))
				set_user_gravity(iPlayer,200.0)
			}
		}
		// Check for floating players
		if (gGravityIndex[iPlayer]) {
			if (gTimer > gGravityIndex[iPlayer]) {
				// Reset gravity
				set_user_gravity(iPlayer)
				gGravityIndex[iPlayer] = 0
			}
		}
	} // End for loop
	gTimer += floatround(POWERS_TIMER_INTERVAL*100)
}

public event_damage()
{	
	new iVictim = read_data(0)
	new iDamage = read_data(2)
	new iRecv, iWeapon, iBody, iHP, iMax, iOrigin[3]
	new iAttacker = get_user_attacker(iVictim,iWeapon,iBody)

	new iAttackerFlags = gPowersIndex[iAttacker]
	new iVictimFlags = gPowersIndex[iVictim]

	// Check player powers
	// Attackers
	if (iAttackerFlags) {
		// Harm
		if (iAttackerFlags&POWERS_HARM && !(iVictimFlags&POWERS_SHIELD)) {
			iHP = get_user_health(iVictim) + iDamage - floatround(iDamage*gHarmIndex[iAttacker])
			if (iHP < 1) iHP = 1
			set_user_health(iVictim,iHP)
		}
		// Leech
		if (iAttackerFlags&POWERS_LEECH) {
			// Cannot leech self or players with shield
			if (iAttacker != iVictim && !(iVictimFlags&POWERS_SHIELD)) {
				iHP = get_user_health(iAttacker) + floatround(iDamage*gLeechIndex[iAttacker])
				if (iAttackerFlags&POWERS_GOD) {
					set_user_health(iVictim,356)
				}
				else {
					iMax = gHealthIndex[iAttacker]
					if (iHP > iMax) iHP = iMax
					set_user_health(iAttacker,iHP)
				}
				if (gFx) {
					fx_screen_fade(iAttacker,1,0,0,255,0,0,128)
				}
				client_print(iAttacker,print_notify,"* You gained %i health from Leech!",floatround(iDamage*gLeechIndex[iAttacker]))
			}
		}
		// Curse
		if (iAttackerFlags&POWERS_CURSE) {
			iHP = get_user_health(iAttacker) - floatround(iDamage*gCurseIndex[iAttacker])
			if (iHP < 1) iHP = 1
			set_user_health(iAttacker,iHP)
			if (gFx) {
				fx_screen_fade(iAttacker,1,0,0,150,0,255,128)
				sound_play(iRecv,POWERS_CURSE,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
			}
			client_print(iAttacker,print_notify,"* You lost %i health from Curse!",floatround(iDamage*gCurseIndex[iAttacker]))
						
			// Give curse to victim
			if (iWeapon == CSW_KNIFE && !(iVictimFlags&POWERS_SHIELD)) {
				gCurseIndex[iVictim] = gCurseIndex[iAttacker]
				powers_add(iVictim,POWERS_CURSE)
				if (gFx) {
					fx_screen_fade(iVictim,1,0,0,150,0,255,255)
				}
				if (gMsg) {
					new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
					get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
					format(sMsg,MAX_TEXT_LENGTH,"Powers: You have been Cursed by %s!",sName)
					player_msg(iVictim,sMsg,200,200,200)
				}
			}
		}
		// OneShot
		if (iAttackerFlags&POWERS_ONESHOT && !(iVictimFlags&POWERS_SHIELD) 
		&& iWeapon != CSW_KNIFE && iWeapon != CSW_SMOKEGRENADE) {
			iRecv = iVictim
			if (iVictimFlags&POWERS_REFLECT) {
				iRecv = iAttacker
			}
			// Credit the kill
			player_kill(iAttacker,iRecv,iWeapon)

			if (gFx && !(iVictimFlags&POWERS_DEATH) && !(iVictimFlags&POWERS_TIMEBOMB)) {
				get_user_origin(iRecv,iOrigin)
				// Effects
				fx_trans(iRecv,0)
				fx_gib_explode(iOrigin)
				fx_blood_pool(iOrigin)
				// Sounds
				sound_play(iRecv,POWERS_ONESHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				// Hide body
				iOrigin[2] = iOrigin[2]-20
				set_user_origin(iRecv,iOrigin)
			}
			if (gMsg) {
				new sName[MAX_NAME_LENGTH]
				new sMsg[MAX_TEXT_LENGTH]
				get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You got killed %s^'s One Shot Bullet!",sName)
				player_msg(iRecv,sMsg,200,200,0)
			}
		}
		// ExplodeShot
		if (iAttackerFlags&POWERS_EXPLODESHOT && !(iVictimFlags&POWERS_SHIELD) 
		&& iWeapon != CSW_KNIFE && iWeapon != CSW_SMOKEGRENADE) {
			iRecv = iVictim
			if (iVictimFlags&POWERS_REFLECT) {
				iRecv = iAttacker
			}
			if (gFx) {
				new iSpriteIndex[4]
				iSpriteIndex[0] = spr_explodeD
				iSpriteIndex[1] = spr_explodeE
				iSpriteIndex[2] = spr_explodeF
				iSpriteIndex[3] = spr_explodeZ
				if (iRecv == iVictim) {
					get_user_origin(iAttacker,iOrigin,4)
				}
				else {
					get_user_origin(iAttacker,iOrigin,0)
				}
				fx_shot_explode(iOrigin,iSpriteIndex[random_num(0,3)],random_num(10,15))
			}
			iDamage = floatround(iDamage*gExplodeshotIndex[iAttacker][0])
			if (get_user_health(iRecv) > iDamage) {
				user_slap(iRecv,iDamage)
			}
			else {
				set_user_health(iRecv,1)
			}
			get_user_origin(iRecv,iOrigin)
			powers_effect_local(iRecv,iOrigin,floatround(gExplodeshotIndex[iAttacker][1]),POWERS_EXPLODESHOT,iDamage)
		}
		// StunShot
		if (iAttackerFlags&POWERS_STUNSHOT && !(iVictimFlags&POWERS_SHIELD) && !(iVictimFlags&POWERS_GHOST)
		&& iWeapon != CSW_KNIFE && iWeapon != CSW_SMOKEGRENADE) {
			iRecv = iVictim
			if (iVictimFlags&POWERS_REFLECT) {
				iRecv = iAttacker
			}
			iHP = get_user_health(iRecv) + iDamage - floatround(gStunshotIndex[iAttacker][0])
			if (iHP < 1) iHP = 1
			set_user_health(iRecv,iHP)
			
			// Stun effect if not already stunned and not dead
			if (!gStunIndex[iRecv] && is_user_alive(iRecv)) {
				player_drop_weapons(iRecv)
				set_user_maxspeed(iRecv,float(1))
				set_user_gravity(iRecv,200.0)
				gStunIndex[iRecv] = gTimer + (floatround(gStunshotIndex[iAttacker][1])*100)
				if (gFx) {
					get_user_origin(iRecv,iOrigin)
					fx_stun(iOrigin,floatround(gStunshotIndex[iAttacker][1])*10)
					fx_screen_shake(iRecv,10,3,10)
					sound_play(iRecv,POWERS_STUNSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				}
				if (gMsg) {
					new sName[MAX_NAME_LENGTH]
					new sMsg[MAX_TEXT_LENGTH]
					get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
					format(sMsg,MAX_TEXT_LENGTH,"Powers: You got stunned by %s!",sName)
					player_msg(iRecv,sMsg,200,200,0)
				}
			}
		}
		// AGShot
		if (iAttackerFlags&POWERS_AGSHOT && !(iVictimFlags&POWERS_SHIELD) && !(iVictimFlags&POWERS_GHOST)
		&& iWeapon != CSW_KNIFE && iWeapon != CSW_SMOKEGRENADE) {
			iRecv = iVictim
			if (iVictimFlags&POWERS_REFLECT) {
				iRecv = iAttacker
			}
			iHP = get_user_health(iRecv) + iDamage - floatround(gAGshotIndex[iAttacker][0])
			if (iHP < 1) iHP = 1
			set_user_health(iRecv,iHP)
			
			if (!gGravityIndex[iRecv] && is_user_alive(iRecv)) {
				player_drop_weapons(iRecv)
				set_user_gravity(iRecv,0.0001)
				client_cmd(iRecv,"+jump;wait;-jump;")
				gGravityIndex[iRecv] = gTimer + (floatround(gAGshotIndex[iAttacker][1])*100)
				if (gFx) {
					get_user_origin(iRecv,iOrigin)
					fx_gravity(iOrigin)
					sound_play(iRecv,POWERS_AGSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				}
				if (gMsg) {
					new sName[MAX_NAME_LENGTH]
					new sMsg[MAX_TEXT_LENGTH]
					get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
					format(sMsg,MAX_TEXT_LENGTH,"Powers: %s made you weightless!",sName)
					player_msg(iRecv,sMsg,200,200,0)
				}
			}
		}
		// Hologram
		if (iAttackerFlags&POWERS_HOLOGRAM) {
			// Restore health to victim
			iHP = get_user_health(iVictim) + iDamage
			set_user_health(iVictim,iHP)
			// Kill hologram
			user_kill(iAttacker,1)
		}
		// Poison
		if (iAttackerFlags&POWERS_POISON && !(iVictimFlags&POWERS_SHIELD) && !(iVictimFlags&POWERS_POISON)) {
			// Give poison to victim
			gPoisonIndex[iVictim][0] = gPoisonIndex[iAttacker][0]
			gPoisonIndex[iVictim][1] = gPoisonIndex[iAttacker][1]
			powers_add(iVictim,POWERS_POISON)
			if (gFx) {
				fx_screen_fade(iVictim,1,0,0,0,255,0,255)
			}
			if (gMsg) {
				new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
				get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You have been Poisoned by %s!",sName)
				player_msg(iVictim,sMsg,200,200,200)
			}
		}
		// FlashShot
		if (iAttackerFlags&POWERS_FLASHSHOT && !(iVictimFlags&POWERS_SHIELD)
		&& iWeapon != CSW_KNIFE && iWeapon != CSW_SMOKEGRENADE) {
			iRecv = iVictim
			if (iVictimFlags&POWERS_REFLECT) {
				iRecv = iAttacker
			}
			iHP = get_user_health(iRecv) + iDamage - floatround(gFlashshotIndex[iAttacker][0])
			if (iHP < 1) iHP = 1
			set_user_health(iRecv,iHP)

			// Flash
			if (gFx) {
				if (is_user_alive(iRecv)) {
					get_user_origin(iRecv,iOrigin)
					fx_flash(iOrigin)
					fx_screen_fade(iRecv,floatround(gFlashshotIndex[iAttacker][1]),floatround(gFlashshotIndex[iAttacker][1]),0,255,255,255,255)
					sound_play(iRecv,POWERS_FLASHSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				}
				else {
					// Reset screen
					fx_screen_fade(iVictim,1,0,0,0,0,0,0)
				}
			}
			if (gMsg) {
				new sName[MAX_NAME_LENGTH]
				get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
				client_print(iRecv,print_notify,"* You were blinded by %s!",sName)
			}
		}
	}
	// Victims
	if (iVictimFlags) {
		// God
		if (iVictimFlags&POWERS_GOD) {
			set_user_health(iVictim,floatround(gGodIndex[iVictim])+256)
		}
		// Protect
		if (iVictimFlags&POWERS_PROTECT) {
			iHP = get_user_health(iVictim) + floatround(iDamage*gProtectIndex[iVictim])
			set_user_health(iVictim,iHP)
		}
		// Reflect
		if (iVictimFlags&POWERS_REFLECT) {
			iHP = get_user_health(iAttacker) - floatround(iDamage*gReflectIndex[iVictim])
			if (iHP < 1) iHP = 1
			set_user_health(iAttacker,iHP)
			if (gFx) {
				new iDest[3]
				get_user_origin(iAttacker,iDest)
				get_user_origin(iVictim,iOrigin)
				fx_reflect(iOrigin,iDest)
			}
		}
		// Absorb
		if (iVictimFlags&POWERS_ABSORB) {
			iHP = get_user_health(iVictim) + iDamage + floatround(iDamage*gAbsorbIndex[iVictim])
			iMax = gHealthIndex[iVictim]
			if (iHP > iMax) iHP = iMax
			set_user_health(iVictim,iHP)
			if (gFx) {
				get_user_origin(iVictim,iOrigin)
				fx_health(iOrigin)
			}
			client_print(iVictim,print_notify,"* You gained %i health from Absorb!",floatround(iDamage*gAbsorbIndex[iVictim]))
		}
		// Armor
		if (iVictimFlags&POWERS_RAMBO) {
			set_user_armor(iVictim,DEFAULT_ARMOR);
		}
	}
	return PLUGIN_CONTINUE
}

public event_death()
{
	new iRange, iOrigin[3]
	new iKiller = read_data(1)
	new iVictim = read_data(2)
//	new sWeapon[MAX_NAME_LENGTH] = read_data(4)
//	new iHeadshot = read_data(3)

	new iKillerFlags = gPowersIndex[iKiller]
	new iVictimFlags = gPowersIndex[iVictim]

	// Check player powers
	// Killers
	if (iKillerFlags) {
		
	}
	// Victims
	if (iVictimFlags) {
		// Death
		if (iVictimFlags&POWERS_DEATH) {
			if (iKiller != iVictim) {
				sound_stop(iVictim)
			}
			get_user_origin(iVictim,iOrigin)
			iRange = floatround(gDeathIndex[iVictim][2])
			powers_effect_local(iVictim,iOrigin,iRange,POWERS_DEATH,0)
			powers_remove(iVictim,POWERS_DEATH)
			if (gFx) {
				// Effects
				fx_trans(iVictim,0)
				fx_remove_attachments(iVictim)
				fx_death_explode(iOrigin)
				fx_blood_pool(iOrigin)
				// Sound
				sound_play(iVictim,POWERS_DEATH,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				// Hide body
				iOrigin[2] = iOrigin[2]-20
				set_user_origin(iVictim,iOrigin)
			}
		}
		// Timebomb
		if (iVictimFlags&POWERS_TIMEBOMB) {
			get_user_origin(iVictim,iOrigin)
			iRange = floatround(gTimebombIndex[iVictim][2])
			powers_effect_local(iVictim,iOrigin,iRange,POWERS_TIMEBOMB,0)
			powers_remove(iVictim,POWERS_TIMEBOMB)
			if (gFx) {
				// Effects
				fx_trans(iVictim,0)
				fx_timebomb_explode(iOrigin)
				// Sounds
				sound_play(iVictim,POWERS_TIMEBOMB,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
				// Hide body
				iOrigin[2] = iOrigin[2]-20
				set_user_origin(iVictim,iOrigin)
			}
		}
		// Cloak
		if (iVictimFlags&POWERS_CLOAK) {
			if (gFx) {
				get_user_origin(iVictim,iOrigin)
				//fx_custom(iVictim,kRenderFxGlowShell,0,255,0,kRenderTransAlpha,50)
				fx_custom(iVictim,kRenderFxGlowShell,0,255,0,kRenderTransAdd,1)
				fx_sparks(iOrigin,spr_cloak)
				sound_play(iVictim,POWERS_CLOAK,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_VICTIM)
			}
		}
		// Curse
		if (iVictimFlags&POWERS_CURSE) {
			gCurseIndex[iKiller] = gCurseIndex[iVictim]
			powers_add(iKiller,POWERS_CURSE)
			if (gMsg) {
				new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
				get_user_name(iVictim,sName,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"Powers: You received Curse from %s!",sName)
				player_msg(iKiller,sMsg,200,200,200)
			}
		}
		// Grenadier
		if (iVictimFlags&POWERS_GRENADIER) {
			gGrenadeIndex[iVictim][1] = float(2)
		}
	}
	// Reset stun effect
	if (gStunIndex[iVictim]) {
		gStunIndex[iVictim] = 1
	}
	// Reset screen
	fx_screen_fade(iVictim,1,0,0,0,0,0,0)

	return PLUGIN_CONTINUE
}

public event_weapon()
{
	new iPlayer = read_data(0)
	new iWeapon = read_data(2)
	new iAmmo = read_data(3)
	new iPlayerFlags = gPowersIndex[iPlayer]

	// Check player powers
	if (iPlayerFlags) {
		// Speed
		if (iPlayerFlags&POWERS_SPEED) {
			set_user_maxspeed(iPlayer,gSpeedIndex[iPlayer]*float(DEFAULT_SPEED))
		}
		// Absorb
		if (iPlayerFlags&POWERS_ABSORB) {
			engclient_cmd(iPlayer,"weapon_knife")
		}
		// Cloak
		if (iPlayerFlags&POWERS_CLOAK) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				gCloakIndex[iPlayer][0] = float(gTimer)+(gCloakIndex[iPlayer][2]*100)
				if (gFx) {
					powers_fx(iPlayer)
				}
			}
		}
		// ExplodeShot
		if (iPlayerFlags&POWERS_EXPLODESHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo 
				&& iWeapon != CSW_KNIFE && iWeapon != CSW_HEGRENADE 
				&& iWeapon != CSW_SMOKEGRENADE) {
				if (gFx) {
					new iOrigin[3]
					new iSpriteIndex[2]
					iSpriteIndex[0] = spr_explodeA
					iSpriteIndex[1] = spr_explodeB
					get_user_origin(iPlayer,iOrigin,4)
					fx_shot_explode(iOrigin,iSpriteIndex[random_num(0,1)],5)
				}
			}
		}
		// OneShot
		if (iPlayerFlags&POWERS_ONESHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				if (gFx) {
					new iOrigin[3], iDest[3]
					get_user_origin(iPlayer,iOrigin,1)
					get_user_origin(iPlayer,iDest,4)
					if (get_user_team(iPlayer)==1) {
						fx_shot_beam(iOrigin,iDest,255,0,0,255)
					}
					else {
						fx_shot_beam(iOrigin,iDest,0,100,255,255)
					}
					sound_play(iPlayer,POWERS_ONESHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
				}
			}
		}
		// StunShot
		if (iPlayerFlags&POWERS_STUNSHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				if (gFx) {
					new iOrigin[3], iDest[3]
					get_user_origin(iPlayer,iOrigin,1)
					get_user_origin(iPlayer,iDest,4)
					fx_shot_beam(iOrigin,iDest,100,100,255,64)
					sound_play(iPlayer,POWERS_STUNSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
				}
			}
		}
		// LaserShot
		if (iPlayerFlags&POWERS_LASERSHOT) {
			if (gLasershotIndex[iPlayer][0] < 0) {
				// Same weapon and shot fired
				if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
					new iOrigin[3], iDest[3]
					get_user_origin(iPlayer,iOrigin)
					get_user_origin(iPlayer,iDest,3)
					powers_effect_local(iPlayer,iDest,floatround(gLasershotIndex[iPlayer][2]),POWERS_LASERSHOT,0)
					if (gFx) {
						fx_laser_beam(iOrigin,iDest)
						sound_play(iPlayer,POWERS_LASERSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
					}
					// Reset counter
					gLasershotIndex[iPlayer][0] = gLasershotIndex[iPlayer][1]
					engclient_cmd(iPlayer,"weapon_knife")
				}
			}
			else {
				engclient_cmd(iPlayer,"weapon_knife")
			}
		}
		// FlashShot
		if (iPlayerFlags&POWERS_FLASHSHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				if (gFx) {
					new iDest[3]
					get_user_origin(iPlayer,iDest,4)
					fx_shot_flash(iDest)
					sound_play(iPlayer,POWERS_FLASHSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
				}
			}
		}
		// AGShot
		if (iPlayerFlags&POWERS_AGSHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				if (gFx) {
					new iOrigin[3], iDest[3]
					get_user_origin(iPlayer,iOrigin,1)
					get_user_origin(iPlayer,iDest,4)
					fx_shot_beam(iOrigin,iDest,0,255,0,64)
					sound_play(iPlayer,POWERS_AGSHOT,CHAN_AUTO,VOL_NORM,ATTN_NORM,PITCH_NORM,SOUND_ATTACK)
				}
			}
		}
		// SplinterShot
		if (iPlayerFlags&POWERS_SPLINTERSHOT) {
			// Same weapon and shot fired
			if (gWeaponIndex[iPlayer] == iWeapon && gAmmoIndex[iPlayer] > iAmmo) {
				new iDest[3]
				get_user_origin(iPlayer,iDest,4)
				powers_effect_local(iPlayer,iDest,floatround(gSplintershotIndex[iPlayer][1]),POWERS_SPLINTERSHOT,floatround(gSplintershotIndex[iPlayer][0]))
				if (gFx) {
					new iOrigin[3]
					get_user_origin(iPlayer,iOrigin,1)
					fx_shot_beam(iOrigin,iDest,255,255,0,64)
				}
			}
		}
		// Grenadier
		if (iPlayerFlags&POWERS_GRENADIER) {
			new iGrenade
			new iGrenadeType = floatround(gGrenadeIndex[iPlayer][0])
			new sGrenade[MAX_NAME_LENGTH]

			if ((iWeapon != CSW_HEGRENADE) && (iWeapon != CSW_SMOKEGRENADE) && 
				(iWeapon != CSW_FLASHBANG) && (iWeapon != CSW_C4)) {
				
				if (iGrenadeType==0) {
					iGrenade = CSW_FLASHBANG
				}
				else if (iGrenadeType==1) {
					iGrenade = CSW_HEGRENADE
				}
				else if (iGrenadeType==2) {
					iGrenade = CSW_SMOKEGRENADE
				}
				get_weaponname(iGrenade,sGrenade,MAX_NAME_LENGTH)
				if (!floatround(gGrenadeIndex[iPlayer][1])) {
					give_item(iPlayer,sGrenade)
					gGrenadeIndex[iPlayer][1] = float(1)
				}
				engclient_cmd(iPlayer,sGrenade)
			}
		}
		// Infinite Bullets
		if (iPlayerFlags&POWERS_RAMBO) {
			new iClip, iOrigin[3]
			new sWeapon[MAX_NAME_LENGTH]
			iWeapon = get_user_weapon(iPlayer, iClip, iAmmo);
			if (iClip == 0) {
				get_weaponname(iWeapon,sWeapon,MAX_NAME_LENGTH)
				get_user_origin(iPlayer,iOrigin)
				iOrigin[2] -= 1000
				set_user_origin(iPlayer,iOrigin)
				engclient_cmd(iPlayer,"drop",sWeapon)
				give_item(iPlayer,sWeapon)
				iOrigin[2] += 1010
				set_user_origin(iPlayer,iOrigin)
				engclient_cmd(iPlayer,sWeapon)
			}
		}
	}
	
	// Floating players
	if (gGravityIndex[iPlayer]) {
		set_user_gravity(iPlayer,0.0001)
	}
	
	// Stunned players
	if (gStunIndex[iPlayer]) {
		player_drop_weapons(iPlayer)
	}
	
	// Set indexes
	gWeaponIndex[iPlayer] = iWeapon
	gAmmoIndex[iPlayer] = iAmmo
	
	return PLUGIN_CONTINUE
}

public event_grenade() {
	new iPlayer = read_data(1)
	gGrenadeIndex[iPlayer][1] = float(0)
	return PLUGIN_CONTINUE
}

public event_round_end() {
	new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers)

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]

		// Reset stunned players
		if (gStunIndex[iPlayer]) {
			gStunIndex[iPlayer] = 1
		}
	}
	set_task(5.0,"powers_reset",0,"")
	return PLUGIN_CONTINUE
}

public event_say_powers(id)
{
	powers_get(0,id)
	return PLUGIN_HANDLED
}

/************************************************************
* FX FUNCTIONS
************************************************************/

static fx_glow(player,r,g,b,size)
{
	set_user_rendering(player,kRenderFxGlowShell,r,g,b,kRenderNormal,size)
	return PLUGIN_CONTINUE
}

static fx_trans(player,amount)
{
	set_user_rendering(player,kRenderFxNone,0,0,0,kRenderTransAlpha,amount)
	return PLUGIN_CONTINUE
}

static fx_custom(player,fx,r,g,b,render,amount)
{
	set_user_rendering(player,fx,r,g,b,render,amount)
	return PLUGIN_CONTINUE
}

static fx_normal(player)
{
	set_user_rendering(player)
	return PLUGIN_CONTINUE
}

static fx_remove_attachments(player)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS)
	write_byte(player)
	message_end()
}

static fx_remove_beam(player)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(player)
	message_end()
}

static fx_blood_pool(origin[3])
{
	// Blood decals
	static const blood_small[7] = {191,192,193,194,195,196,197}
	static const blood_large[2] = {204,205}

	// Large splash, 3 times
	for (new i = 0; i < 3; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-50,50))
		write_coord(origin[1]+random_num(-50,50))
		write_coord(origin[2]-36)
		write_byte(blood_large[random_num(0,1)]) // index
		message_end()
	}
	
	// Small splash, 20 times
	for (new j = 0; j < 20; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-100,100))
		write_coord(origin[1]+random_num(-100,100))
		write_coord(origin[2]-36)
		write_byte(blood_small[random_num(0,6)]) // index
		message_end()
	}
}

static fx_bone_explode(origin[3])
{
	new bones[2]
	bones[0] = mdl_bone_arm
	bones[1] = mdl_bone_ribbone
	
	// Bone explosion
	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_bone_head)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Pelvis
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_bone_pelvis)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Ribcage
	for(new i = 0; i < random_num(1,2); i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_bone_ribcage)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Bones, 5 times
	for(new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(bones[random_num(0,1)])
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
}

static fx_gravity(origin[3]) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_TELEPORT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	message_end()
}

static fx_sparks(origin[3],sprite) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(sprite)
	write_byte(50) // count
	write_byte(10) // life
	write_byte(1) // scale
	write_byte(100) // velocity
	write_byte(100) // randomness
	message_end()
}

static fx_gib_explode(origin[3])
{
	new flesh[3], x, y, z
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	flesh[2] = mdl_gib_legbone

	// Gib explosion
	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_head)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_spine)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Lung
	for(new i = 0; i < random_num(1,2); i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Parts, 5 times
	for(new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(flesh[random_num(0,2)])
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Blood, 5 times
	for(new i = 0; i < 5; i++) {
		x = random_num(-100,100)
		y = random_num(-100,100)
		z = random_num(0,100)
		for(new j = 0; j < 5; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_spray)
			write_short(spr_blood_drop)
			write_byte(248) // color index
			write_byte(15) // size
			message_end()
		}
	}
}

static fx_death(player)
{
	// Death icon
	message_begin(MSG_ALL,SVC_TEMPENTITY)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(player)
	write_coord(40)
	write_short(spr_death_icon)
	write_short(floatround(gDeathIndex[player][1]*10)+50)
	message_end()
}

static fx_death_explode(origin[3])
{
	// Death explosion
	// Skeleton
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(0)
	write_coord(0)
	write_coord(100)
	write_angle(random_num(0,360))
	write_short(mdl_skeleton)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Blood explosion
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_PARTICLEBURST)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(100) // radius
	write_byte(70) // color
	write_byte(3) // life
	message_end()

	// Blood spray, 5 times
	for (new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-200,200))
		write_coord(random_num(-200,200))
		write_coord(random_num(50,300))
		write_byte(70) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}

static fx_timebomb_explode(origin[3])
{
	// Explosion
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+220)
	write_short(spr_explodeF)
	write_byte(50) // scale
	write_byte(15) // framerate
	write_byte(12) // flags
	message_end()
	
	// Blast center
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+100)
	write_short(spr_glow)
	write_byte(50) // scale
	write_byte(10) // framerate
	write_byte(14) // flags
	message_end()
	
	// Blast ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+1500)
	write_short(spr_white)
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(5) // life
	write_byte(10) // width
	write_byte(0) // noise
	write_byte(255) // r
	write_byte(255) // g
	write_byte(255) // b
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()
	
	// Blast particles
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_PARTICLEBURST)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(200) // radius
	write_byte(5) // color
	write_byte(3) // life
	message_end()
	
	// Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_short(spr_smoke)
	write_byte(50) // scale
	write_byte(5) // framerate
	message_end()
	
	// Burn decal
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_WORLDDECAL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-36)
	write_byte(46) // index
	message_end()
}

static fx_shot_beam(origin[3],dest[3],r,g,b,amount)
{
	// Tracer beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_beam)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(1) // life
	write_byte(5) // width
	write_byte(0) // amplitude
	write_byte(r) // r
	write_byte(g) // g
	write_byte(b) // b
	write_byte(amount) // brightness
	write_byte(0) // speed
	message_end()
}

static fx_shot_explode(origin[3],sprite,size)
{
	// Explosion
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(sprite)
	write_byte(size) // scale
	write_byte(30) // framerate
	write_byte(8) // flags
	message_end()
}

static fx_shot_flash(origin[3])
{
	// Glow
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_glow)
	write_byte(5) // scale
	write_byte(15) // framerate
	write_byte(14) // flags
	message_end()
	
	// Sparks
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPARKS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	message_end()
}

static fx_shot_splinter(origin[3],dest[3])
{
	// Splinter effect, 5 times
	for (new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(dest[0]+random_num(-50,50))
		write_coord(dest[1]+random_num(-50,50))
		write_coord(dest[2]+random_num(-30,30))
		write_short(spr_beam)
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(1) // life
		write_byte(5) // width
		write_byte(0) // amplitude
		write_byte(255) // r
		write_byte(255) // g
		write_byte(0) // b
		write_byte(random_num(64,128)) // brightness
		write_byte(0) // speed
		message_end()
	}
}

static fx_health(origin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_IMPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(75) // radius
	write_byte(10) // count
	write_byte(3) // life
	message_end()
}

static fx_fireball(origin[3])
{
	// Explosion
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_explodeC)
	write_byte(5) // scale
	write_byte(15) // framerate
	write_byte(12) // flags
	message_end()
	
	// Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_smoke)
	write_byte(10) // scale
	write_byte(15) // framerate
	message_end()
}

static fx_laser_beam(origin[3],dest[3])
{
	// Main beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_laserbeam1)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(10) // life
	write_byte(50) // width
	write_byte(0) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(200) // b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()

	// Surrounding Beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_laserbeam2)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(10) // life
	write_byte(30) // width
	write_byte(20) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(200) // b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()

	// Surrounding Beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_laserbeam3)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(10) // life
	write_byte(30) // width
	write_byte(10) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(200) // b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()

	// Laser start
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-20)
	write_short(spr_glow)
	write_byte(10) // scale
	write_byte(5) // framerate
	write_byte(14) // flags
	message_end()
	
	// Laser hit
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_laserhit)
	write_byte(20) // scale
	write_byte(30) // framerate
	write_byte(14) // flags
	message_end()

	// Burn decal
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_WORLDDECAL)
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_byte(46) // index
	message_end()
}

static fx_laser_shock(origin[3],dest[3])
{
	// Main beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_laserbeam1)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(10) // life
	write_byte(30) // width
	write_byte(100) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(200) // b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()

	// Laser shock
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(dest[0])
	write_coord(dest[1])
	write_coord(dest[2])
	write_short(spr_lasershock)
	write_byte(20) // scale
	write_byte(15) // framerate
	write_byte(14) // flags
	message_end()
}

static fx_reflect(origin[3],dest[3])
{
	// Spark
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_ARMOR_RICOCHET)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(50) // scale
	message_end()
	
	// Ricochet
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(dest[0]+random_num(-20,20))
	write_coord(dest[1]+random_num(-20,20))
	write_coord(dest[2]+random_num(-20,20))
	write_short(spr_beam)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(1) // life
	write_byte(10) // width
	write_byte(0) // amplitude
	write_byte(255) // r
	write_byte(255) // g
	write_byte(255) // b
	write_byte(128) // brightness
	write_byte(0) // speed
	message_end()
}

static fx_vampire(player,victim)
{
	new iOrigin[3], iDest[3]
	get_user_origin(player,iDest)
	get_user_origin(victim,iOrigin)
	
	// Sucking effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)
	write_short(player)
	write_short(victim)
	write_short(spr_beam)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(10) // life
	write_byte(50) // width
	write_byte(50) // amplitude
	write_byte(50) // r
	write_byte(0) // g
	write_byte(255) // b
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()
	
	// Blood
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(248) // color index
	write_byte(10) // size
	message_end()
}

static fx_stun(origin[3],time)
{
	// Main beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-36)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+20)
	write_short(spr_stunbeam)
	write_byte(1) // framestart
	write_byte(30) // framerate
	write_byte(time) // life
	write_byte(50) // width
	write_byte(255) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(200) // b
	write_byte(200) // brightness
	write_byte(100) // speed
	message_end()
	
	// Sub beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-36)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+20)
	write_short(spr_stunbeam)
	write_byte(1) // framestart
	write_byte(15) // framerate
	write_byte(time) // life
	write_byte(100) // width
	write_byte(255) // amplitude
	write_byte(200) // r
	write_byte(200) // g
	write_byte(255) // b
	write_byte(200) // brightness
	write_byte(50) // speed
	message_end()
}

public fx_flash(origin[3]) {
	// Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_smoke)
	write_byte(20) // scale
	write_byte(15) // framerate
	message_end()
	
	// Sparks
	for (new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_SPARKS)
		write_coord(origin[0]+random_num(-50,50))
		write_coord(origin[1]+random_num(-50,50))
		write_coord(origin[2]+random_num(-50,50))
		message_end()
	}
}

static fx_screen_shake(player,amount,time,freq)
{
	message_begin(MSG_ONE,gmsgShake,{0,0,0},player)
	write_short(amount*FX_MULT) // shake amount
	write_short(time*FX_MULT) // shake time
	write_short(freq*FX_MULT) // shake noise frequency
	message_end()
}

static fx_screen_fade(player,duration,hold,type,r,g,b,alpha)
{
	message_begin(MSG_ONE,gmsgFade,{0,0,0},player)
	write_short(duration*FX_MULT) // fade duration
	write_short(hold*FX_MULT) // fade hold time
	write_short(type) // fade type (in/out)
	write_byte(r) // fade red
	write_byte(g) // fade green
	write_byte(b) // fade blue
	write_byte(alpha) // fade alpha
	message_end()
}

/************************************************************
* SOUND FUNCTIONS
************************************************************/

static sound_play(player,power,chan,Float:vol,Float:attn,pitch,type)
{
	// Attacker sounds
	if (type&SOUND_ATTACK) {
		// OneShot
		if (power&POWERS_ONESHOT) {
			emit_sound(player,chan,gSoundIndex[SOUND_ONESHOT],vol,attn,0,pitch)
		}
		// StunShot
		else if (power&POWERS_STUNSHOT) {
			emit_sound(player,chan,gSoundIndex[SOUND_STUNSHOT],vol,attn,0,pitch)
		}
		// Curse
		else if (power&POWERS_CURSE) {
			emit_sound(player,chan,gSoundIndex[sound_random(SOUND_RANDOM_HURT)],vol,attn,0,pitch)
		}
		// LaserShot
		else if (power&POWERS_LASERSHOT) {
			emit_sound(player,chan,gSoundIndex[SOUND_LASERSHOT],vol,attn,0,pitch)
		}
	}
	// Victim sounds
	else if (type&SOUND_VICTIM) {
		// OneShot
		if (power&POWERS_ONESHOT) {
			emit_sound(player,chan,gSoundIndex[sound_random(SOUND_RANDOM_BLOOD)],vol,attn,0,pitch)
			emit_sound(player,chan,gSoundIndex[sound_random(SOUND_RANDOM_GIB)],vol,attn,0,pitch)
		}
		// StunShot
		else if (power&POWERS_STUNSHOT) {
			emit_sound(player,chan,gSoundIndex[SOUND_STUN],vol,attn,0,pitch)
		}
		// FlashShot
		else if (power&POWERS_FLASHSHOT) {
			emit_sound(player,chan,gSoundIndex[sound_random(SOUND_RANDOM_FLASH)],vol,attn,0,pitch)
		}
		// LaserShot
		else if (power&POWERS_LASERSHOT) {
			emit_sound(player,chan,gSoundIndex[SOUND_LASERDEATH],vol,attn,0,pitch)
		}
		// Death
		else if (power&POWERS_DEATH) {
			emit_sound(player,chan,gSoundIndex[SOUND_SCREAM],vol,attn,0,pitch)
			emit_sound(player,chan,gSoundIndex[SOUND_BLOOD2],vol,attn,0,pitch)
		}
		// Timebomb
		else if (power&POWERS_TIMEBOMB) {
			emit_sound(player,chan,gSoundIndex[SOUND_BANG],vol,attn,0,pitch)
			emit_sound(player,chan,gSoundIndex[SOUND_EXPLODE1],vol,attn,0,pitch)
		}
		// Cloak
		else if (power&POWERS_CLOAK) {
			emit_sound(player,chan,gSoundIndex[SOUND_LASERDEATH],vol,attn,0,pitch)
		}
		// Fireball
		else if (power&POWERS_FIREBALL) {
			emit_sound(player,chan,gSoundIndex[SOUND_FLAME],vol,attn,0,pitch)
		}
		// Medic
		else if (power&POWERS_MEDIC) {
			emit_sound(player,chan,gSoundIndex[SOUND_MEDIC],vol,attn,0,pitch)
		}
	}
}

static sound_play_all(sound,chan,Float:vol,Float:attn,pitch)
{
	new iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers)
	for (new i = 0; i < iNumPlayers; i++) {
		emit_sound(iPlayers[i],chan,gSoundIndex[sound],vol,attn,0,pitch)
	}
}

static sound_play_one(player,sound)
{
	client_cmd(player,"spk %s",gSoundIndex[sound])
}

static sound_stop(player)
{
	client_cmd(player,"stopsound")
}

static sound_random(sound)
{
	new iSound
	if (sound&SOUND_RANDOM_GIB) {
		switch (random_num(0,3)) {
			case 0:
				iSound = SOUND_GIB1
			case 1:			
				iSound = SOUND_GIB2
			case 2:
				iSound = SOUND_GIB3
			case 3:
				iSound = SOUND_GIB4
		}
	}
	else if (sound&SOUND_RANDOM_HURT) {
		switch (random_num(0,2)) {
			case 0:
				iSound = SOUND_HURT1
			case 1:
				iSound = SOUND_HURT2
			case 2:
				iSound = SOUND_HURT3
		}
	}
	else if (sound&SOUND_RANDOM_BLOOD) {
		switch (random_num(0,2)) {
			case 0:
				iSound = SOUND_BLOOD1
			case 1:
				iSound = SOUND_BLOOD2
			case 2:
				iSound = SOUND_BLOOD3
		}
	}
	else if (sound&SOUND_RANDOM_FLASH) {
		switch (random_num(0,1)) {
			case 0:
				iSound = SOUND_FLASH1
			case 1:
				iSound = SOUND_FLASH2
		}
	}
	return iSound
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

static player_find(id,arg[])
{
	new player = find_player("bl",arg)
	if (player) {
		new player2 = find_player("blj",arg)
		if (player!=player2){
			console_print(id,"[POWERS] Found multiple clients. Try again.")
			return 0
		}
	}
	else {
		player = find_player("c",arg)
	}
	if (!player){
		console_print(id,"[POWERS] Client with that authid or part of nick not found")
		return 0
	}
	return player
}

static player_reset(player)
{
	set_user_godmode(player,0)
	set_user_noclip(player,0)
	set_user_hitzones(player)
	set_user_gravity(player)
	player_reset_speed(player)
	sound_stop(player)
	gHealthIndex[player] = DEFAULT_HEALTH_MAX
}

static player_reset_speed(player)
{
	set_user_maxspeed(player)

	// HACK
	client_cmd(player,"slot2;wait;slot3;")
	engclient_cmd(player,"weapon_knife")
}

static player_msg(player,msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,POWERS_MSG_CHANNEL)
	show_hudmessage(player,msg)
}

static player_drop_weapons(player)
{
	new iWeapon, iWeaponIndex[MAX_WEAPONS], iNumWeapons
	new sCurrentWeapon[MAX_NAME_LENGTH]
	get_user_weapons(player,iWeaponIndex,iNumWeapons)
	for(new i = 0; i < iNumWeapons; i++) {	
		iWeapon = iWeaponIndex[i]
		if (iWeapon!=CSW_KNIFE && iWeapon!=CSW_C4 && iWeapon!=CSW_FLASHBANG && iWeapon!=CSW_SMOKEGRENADE && iWeapon!=CSW_HEGRENADE) {
			get_weaponname(iWeapon,sCurrentWeapon,MAX_NAME_LENGTH)
			engclient_cmd(player,"drop",sCurrentWeapon)
		}
	}
}

static player_kill(killer,victim,weapon)
{
	new sWeapon[MAX_NAME_LENGTH]
	set_user_frags(killer,get_user_frags(killer)+1)
	user_kill(victim,1)
	
	if (gShowDeathMsg) {
		get_weaponname(weapon,sWeapon,MAX_NAME_LENGTH)
		message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
		write_byte(killer)
		write_byte(victim)
		write_byte(0) // headshot
		write_string(sWeapon) // weapon
		message_end()
	}
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public client_connect(id)
{
	gPowersIndex[id] = POWERS_NONE
	gHealthIndex[id] = DEFAULT_HEALTH_MAX
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	gPowersIndex[id] = POWERS_NONE
	gHealthIndex[id] = DEFAULT_HEALTH_MAX
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	// Sounds
	copy(gSoundIndex[SOUND_BANG],MAX_NAME_LENGTH,"weapons/awp1.wav")
	copy(gSoundIndex[SOUND_BEEP1],MAX_NAME_LENGTH,"weapons/c4_beep1.wav")
	copy(gSoundIndex[SOUND_BEEP2],MAX_NAME_LENGTH,"weapons/c4_beep2.wav")
	copy(gSoundIndex[SOUND_BEEP3],MAX_NAME_LENGTH,"weapons/c4_beep3.wav")
	copy(gSoundIndex[SOUND_BEEP4],MAX_NAME_LENGTH,"weapons/c4_beep4.wav")
	copy(gSoundIndex[SOUND_BEEP5],MAX_NAME_LENGTH,"weapons/c4_beep5.wav")
	copy(gSoundIndex[SOUND_BLOW],MAX_NAME_LENGTH,"radio/blow.wav")
	copy(gSoundIndex[SOUND_BLOOD1],MAX_NAME_LENGTH,"player/headshot1.wav")
	copy(gSoundIndex[SOUND_BLOOD2],MAX_NAME_LENGTH,"player/headshot2.wav")
	copy(gSoundIndex[SOUND_BLOOD3],MAX_NAME_LENGTH,"player/headshot3.wav")
	copy(gSoundIndex[SOUND_EXPLODE1],MAX_NAME_LENGTH,"weapons/c4_explode1.wav")
	copy(gSoundIndex[SOUND_EXPLODE2],MAX_NAME_LENGTH,"weapons/hegrenade-1.wav")
	copy(gSoundIndex[SOUND_GIB1],MAX_NAME_LENGTH,"hornet/ag_hornethit1.wav")
	copy(gSoundIndex[SOUND_GIB2],MAX_NAME_LENGTH,"debris/bustflesh1.wav")
	copy(gSoundIndex[SOUND_GIB3],MAX_NAME_LENGTH,"debris/bustflesh2.wav")
	copy(gSoundIndex[SOUND_GIB4],MAX_NAME_LENGTH,"common/bodysplat.wav")
	copy(gSoundIndex[SOUND_HEARTBEAT],MAX_NAME_LENGTH,"player/heartbeat1.wav")
	copy(gSoundIndex[SOUND_HURT1],MAX_NAME_LENGTH,"player/bhit_flesh-1.wav")
	copy(gSoundIndex[SOUND_HURT2],MAX_NAME_LENGTH,"player/bhit_flesh-2.wav")
	copy(gSoundIndex[SOUND_HURT3],MAX_NAME_LENGTH,"player/bhit_flesh-3.wav")
	copy(gSoundIndex[SOUND_ONESHOT],MAX_NAME_LENGTH,"weapons/357_shot1.wav")
	copy(gSoundIndex[SOUND_SCREAM],MAX_NAME_LENGTH,"ambience/fallscream.wav")
	copy(gSoundIndex[SOUND_STUN],MAX_NAME_LENGTH,"debris/zap8.wav")
	copy(gSoundIndex[SOUND_STUNSHOT],MAX_NAME_LENGTH,"agrunt/ag_fire1.wav")
	copy(gSoundIndex[SOUND_FLAME],MAX_NAME_LENGTH,"ambience/flameburst1.wav")
	copy(gSoundIndex[SOUND_LASERSHOT],MAX_NAME_LENGTH,"debris/beamstart9.wav")
	copy(gSoundIndex[SOUND_LASERDEATH],MAX_NAME_LENGTH,"debris/beamstart7.wav")
	copy(gSoundIndex[SOUND_MEDIC],MAX_NAME_LENGTH,"items/smallmedkit1.wav")
	copy(gSoundIndex[SOUND_FLASH1],MAX_NAME_LENGTH,"weapons/flashbang-1.wav")
	copy(gSoundIndex[SOUND_FLASH2],MAX_NAME_LENGTH,"weapons/flashbang-2.wav")
	copy(gSoundIndex[SOUND_AGSHOT],MAX_NAME_LENGTH,"weapons/flashbang-1.wav")
	copy(gSoundIndex[SOUND_AGHIT],MAX_NAME_LENGTH,"weapons/flashbang-2.wav")

	for (new i = 0; i < MAX_SOUNDS; i++) {
		precache_sound(gSoundIndex[i])
	}

	// Sprites
	spr_blood_drop = precache_model("sprites/blood.spr")
	spr_blood_spray = precache_model("sprites/bloodspray.spr")
	spr_death_icon = precache_model("sprites/iplayerdead.spr")
	spr_explodeA = precache_model("sprites/Aexplo.spr")
	spr_explodeB = precache_model("sprites/Bexplo.spr")
	spr_explodeC = precache_model("sprites/Cexplo.spr")
	spr_explodeD = precache_model("sprites/Dexplo.spr")
	spr_explodeE = precache_model("sprites/Eexplo.spr")
	spr_explodeF = precache_model("sprites/Fexplo.spr")
	spr_explodeZ = precache_model("sprites/zerogxplode.spr")
	spr_glow = precache_model("sprites/animglow01.spr")
	spr_smoke = precache_model("sprites/steam1.spr")
	spr_white = precache_model("sprites/white.spr")
	spr_stunbeam = precache_model("sprites/Bolt1.spr")
	spr_laserbeam1 = precache_model("sprites/xenobeam.spr")
	spr_laserbeam2 = precache_model("sprites/ZBeam1.spr")
	spr_laserbeam3 = precache_model("sprites/lgtning.spr")
	spr_laserhit = precache_model("sprites/C-Tele1.spr")
	spr_lasershock = precache_model("sprites/XFlare1.spr")
	spr_cloak = precache_model("sprites/Cnt1.spr")
	spr_laserspark = precache_model("sprites/XFlare2.spr")
	spr_beam = precache_model("sprites/ZBeam6.spr")
	
	// Models
	mdl_bone_arm = precache_model("models/bonegibs.mdl")
	mdl_bone_head = precache_model("models/Bleachbones.mdl")
	mdl_bone_pelvis = precache_model("models/PELVIS.mdl")
	mdl_bone_ribcage = precache_model("models/RIBCAGE.mdl")
	mdl_bone_ribbone = precache_model("models/riblet1.mdl")
	mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
	mdl_gib_head = precache_model("models/GIB_Skull.mdl")
	mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
	mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
	mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
	mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")
	mdl_skeleton = precache_model("models/skeleton.mdl")

	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Powers","1.0","mike_cao")

	// Register commands
	register_concmd("amx_powers","admin_powers",ACCESS_LEVEL,"amx_powers < authid | part of nick >")
	register_concmd("amx_powersmsg","admin_powersmsg",ACCESS_LEVEL,"amx_powersmsg < 1 | 0 >")
	register_concmd("amx_powersfx","admin_powersfx",ACCESS_LEVEL,"amx_powersfx < 1 | 0 >")
	register_concmd("amx_nopowers","admin_nopowers",ACCESS_LEVEL,"amx_nopowers < authid | part of nick >")
	register_concmd("amx_god","admin_god",ACCESS_LEVEL,"amx_god < authid | part of nick > < on | off >")
	register_concmd("amx_shield","admin_shield",ACCESS_LEVEL,"amx_shield < authid | part of nick > < on | off >")
	register_concmd("amx_speed","admin_speed",ACCESS_LEVEL,"amx_speed < authid | part of nick > < on | off > [speed ratio]")
	register_concmd("amx_stealth","admin_stealth",ACCESS_LEVEL,"amx_stealth < authid | part of nick > < on | off > [stealth ratio]")
	register_concmd("amx_harm","admin_harm",ACCESS_LEVEL,"amx_harm < authid | part of nick > < on | off > [damage ratio]")
	register_concmd("amx_protect","admin_protect",ACCESS_LEVEL,"amx_protect < authid | part of nick > < on | off > [damage ratio]")
	register_concmd("amx_rambo","admin_rambo",ACCESS_LEVEL,"amx_rambo < authid | part of nick > < on | off >")
	register_concmd("amx_leech","admin_leech",ACCESS_LEVEL,"amx_leech < authid | part of nick > < on | off > [damage ratio] [health max]")
	register_concmd("amx_absorb","admin_absorb",ACCESS_LEVEL,"amx_absorb < authid | part of nick > < on | off > [damage ratio] [health max]")
	register_concmd("amx_reflect","admin_reflect",ACCESS_LEVEL,"amx_reflect < authid | part of nick > < on | off > [damage ratio]")
	register_concmd("amx_curse","admin_curse",ACCESS_LEVEL,"amx_curse < authid | part of nick > < on | off > [damage ratio]")
	register_concmd("amx_regen","admin_regen",ACCESS_LEVEL,"amx_regen < authid | part of nick > < on | off > [health amount] [time interval] [health max]")
	register_concmd("amx_poison","admin_poison",ACCESS_LEVEL,"amx_poison < authid | part of nick > < on | off > [health amount] [time interval]")
	register_concmd("amx_death","admin_death",ACCESS_LEVEL,"amx_death < authid | part of nick > < on | off > [countdown time] [effect distance]")
	register_concmd("amx_fireball","admin_fireball",ACCESS_LEVEL,"amx_fireball < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect team]")
	register_concmd("amx_medic","admin_medic",ACCESS_LEVEL,"amx_medic < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect opponent]")
	register_concmd("amx_ghost","admin_ghost",ACCESS_LEVEL,"amx_ghost < authid | part of nick > < on | off >")
	register_concmd("amx_hologram","admin_hologram",ACCESS_LEVEL,"amx_hologram < authid | part of nick > < on | off >")
	register_concmd("amx_timebomb","admin_timebomb",ACCESS_LEVEL,"amx_timebomb < authid | part of nick > < on | off > [countdown time] [effect distance]")
	register_concmd("amx_oneshot","admin_oneshot",ACCESS_LEVEL,"amx_oneshot < authid | part of nick > < on | off >")
	register_concmd("amx_stunshot","admin_stunshot",ACCESS_LEVEL,"amx_stunshot < authid | part of nick > < on | off > [damage amount] [effect time]")
	register_concmd("amx_explodeshot","admin_explodeshot",ACCESS_LEVEL,"amx_explodeshot < authid | part of nick > < on | off > [damage ratio] [effect distance]")
	register_concmd("amx_lasershot","admin_lasershot",ACCESS_LEVEL,"amx_lasershot < authid | part of nick > < on | off > [charge time] [effect distance] [effect team]")
	register_concmd("amx_cloak","admin_cloak",ACCESS_LEVEL,"amx_cloak < authid | part of nick > < on | off >")
	register_concmd("amx_flashshot","admin_flashshot",ACCESS_LEVEL,"amx_flashshot < authid | part of nick > < on | off > [damage amount] [effect time]")
	register_concmd("amx_agshot","admin_agshot",ACCESS_LEVEL,"amx_agshot < authid | part of nick > < on | off > [damage amount] [effect time]")
	register_concmd("amx_splintershot","admin_splintershot",ACCESS_LEVEL,"amx_splintershot < authid | part of nick > < on | off > [damage amount] [effect distance] [effect team]")
	register_concmd("amx_vampire","admin_vampire",ACCESS_LEVEL,"amx_vampire < authid | part of nick > < on | off > [health amount] [time interval] [effect distance] [effect team] [health max]")
	
	// Events
	register_clcmd("say powers","event_say_powers")
	register_event("DeathMsg","event_death","a")
	register_event("Damage","event_damage","b","2!0","3=0","4!0")
	register_event("CurWeapon","event_weapon","be","1=1")

        // Mod specific events
        new sMod[MAX_NAME_LENGTH]
        get_modname(sMod,MAX_NAME_LENGTH)

        if (equal(sMod,"cstrike")) {
		register_concmd("amx_grenadier","admin_grenadier",ACCESS_LEVEL,"amx_grenadier < authid | part of nick > < on | off > [grenade type <0=fb|1=he|2=smk>]")
		register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
		register_event("SendAudio","event_grenade","abcde","2&%!MRAD_FIREINHOLE")
	}

	// Messages
	gmsgShake = get_user_msgid("ScreenShake")
	gmsgFade = get_user_msgid("ScreenFade")
	gmsgDeathMsg = get_user_msgid("DeathMsg")

	// Controller	
	set_task(POWERS_TIMER_INTERVAL,"event_powers",999,"",0,"b")

	return PLUGIN_CONTINUE
}

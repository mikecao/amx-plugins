/*
*	AMXMOD script.
*	(plugin_gamble.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*       This plugin requires the following plugins to work:
*       (plugin_powers.sma)
*	(plugin_punish.sma)
*
*	This plugin allows players to gamble for certain
*	powers by saying "gamble!". They can also receive
*	negative effects.
*
*	Cvar:
*	amx_gamble_mode <1|0>
*
*/ 

#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

#define GAMBLE_NONE		0

// Powers
#define GAMBLE_GOD		1
#define GAMBLE_SHIELD		2
#define GAMBLE_SPEED		3
#define GAMBLE_STEALTH		4
#define GAMBLE_HARM		5
#define GAMBLE_PROTECT		6
#define GAMBLE_RAMBO		7
#define GAMBLE_LEECH		8
#define GAMBLE_ABSORB		9
#define GAMBLE_REFLECT		10
#define GAMBLE_CURSE		11
#define GAMBLE_REGEN		12
#define GAMBLE_POISON		13
#define GAMBLE_DEATH		14
#define GAMBLE_FIREBALL		15
#define GAMBLE_MEDIC		16
#define GAMBLE_GHOST		17
#define GAMBLE_HOLOGRAM		18
#define GAMBLE_TIMEBOMB		19
#define GAMBLE_CLOAK		20
#define GAMBLE_ONESHOT		21
#define GAMBLE_STUNSHOT		22
#define GAMBLE_EXPLODESHOT	23
#define GAMBLE_LASERSHOT	24
#define GAMBLE_FLASHSHOT	25
#define GAMBLE_AGSHOT		26
#define GAMBLE_SPLINTER		27
#define GAMBLE_VAMPIRE		28
#define GAMBLE_DISARM		29
#define GAMBLE_BURY		30
#define GAMBLE_BLIND		31
#define GAMBLE_DRUNK		32
#define GAMBLE_BUNNY		33

#define GAMBLE_MAX		33

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

// Max gambles per round
#define MAX_GAMBLE 3

// Time values for powers
// 999 = entire round
#define TIME_NONE		0
#define TIME_GOD		15
#define TIME_SHIELD		60
#define TIME_SPEED		60
#define TIME_STEALTH		60
#define TIME_HARM		30
#define TIME_PROTECT		60
#define TIME_RAMBO		60
#define TIME_LEECH		60
#define TIME_ABSORB		10
#define TIME_REFLECT		30
#define TIME_CURSE		30
#define TIME_REGEN		60
#define TIME_POISON		30
#define TIME_DEATH		20
#define TIME_FIREBALL		30
#define TIME_MEDIC		60
#define TIME_GHOST		60
#define TIME_HOLOGRAM		30
#define TIME_TIMEBOMB		10
#define TIME_CLOAK		60
#define TIME_ONESHOT		20
#define TIME_STUNSHOT		60
#define TIME_EXPLODESHOT	30
#define TIME_LASERSHOT		60
#define TIME_FLASHSHOT		60
#define TIME_AGSHOT		60
#define TIME_SPLINTER		60
#define TIME_VAMPIRE		60
#define TIME_BURY		20
#define TIME_BLIND		20
#define TIME_DRUNK		30
#define TIME_BUNNY		30

/************************************************************
* MAIN
************************************************************/

new gGamble, gTimer
new gGambleIndex[MAX_PLAYERS+1][3]
new gPosIndex[MAX_PLAYERS+1][3]

public admin_gamble(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_gamble < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_gamble_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Gambling mode is now on.")
		player_msg(0,"Gambling mode is now on! :)",0,200,0)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Gambling mode is now off.")
		player_msg(0,"Gambling mode is now off! :(",0,200,0)
	}
	gGamble = get_cvar_num("amx_gamble_mode")
	return PLUGIN_HANDLED
}

public do_gamble(id)
{
	if (gGamble) {
		if (is_user_alive(id)) {
			if (!gGambleIndex[id][0]) {
				if (gGambleIndex[id][2] < MAX_GAMBLE) {
					new sAuthid[MAX_NAME_LENGTH]
					get_user_name(id,sAuthid,MAX_NAME_LENGTH)

					// If multiple found, use authid instead
					new iPlayer = player_find(id,sAuthid)					
					if (!iPlayer) {
						get_user_authid(id,sAuthid,MAX_NAME_LENGTH)
					}
					
					switch (random_num(0,GAMBLE_MAX)) {
						case GAMBLE_GOD:
						{
							gGambleIndex[id][0] = GAMBLE_GOD
							gGambleIndex[id][1] = gTimer + TIME_GOD
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got God Mode",TIME_GOD,255,150,0)
							server_cmd("amx_god ^"%s^" on",sAuthid)
						}
						case GAMBLE_SHIELD:
						{
							gGambleIndex[id][0] = GAMBLE_SHIELD
							gGambleIndex[id][1] = gTimer + TIME_SHIELD
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Shield",TIME_SHIELD,0,100,255)
							server_cmd("amx_shield ^"%s^" on",sAuthid)
						}
						case GAMBLE_SPEED:
						{
							gGambleIndex[id][0] = GAMBLE_SPEED
							gGambleIndex[id][1] = gTimer + TIME_SPEED
							gGambleIndex[id][2] += 1
							if (random_num(0,1)) {
								gamble_msg(id,"got Speed",TIME_SPEED,200,200,200)
								server_cmd("amx_speed ^"%s^" on 2.0",sAuthid)
							}
							else {
								gamble_msg(id,"got Slow",TIME_SPEED,0,255,75)
								server_cmd("amx_speed ^"%s^" on 0.25",sAuthid)
							}
						}
						case GAMBLE_STEALTH:
						{
							gGambleIndex[id][0] = GAMBLE_STEALTH
							gGambleIndex[id][1] = gTimer + TIME_STEALTH
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Stealth",TIME_STEALTH,200,200,200)
							server_cmd("amx_stealth ^"%s^" on",sAuthid)
						}
						case GAMBLE_HARM:
						{
							gGambleIndex[id][0] = GAMBLE_HARM
							gGambleIndex[id][1] = gTimer + TIME_HARM
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Quad Damage (4x)",TIME_HARM,150,0,255)
							server_cmd("amx_harm ^"%s^" on 4.0",sAuthid)
						}
						case GAMBLE_PROTECT:
						{
							gGambleIndex[id][0] = GAMBLE_PROTECT
							gGambleIndex[id][1] = gTimer + TIME_PROTECT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Protection (1/4 Damage)",TIME_PROTECT,255,175,0)
							server_cmd("amx_protect ^"%s^" on 0.75",sAuthid)
						}
						case GAMBLE_RAMBO:
						{
							gGambleIndex[id][0] = GAMBLE_RAMBO
							gGambleIndex[id][1] = gTimer + TIME_RAMBO
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became Rambo",TIME_RAMBO,255,200,100)
							server_cmd("amx_rambo ^"%s^" on",sAuthid)
						}
						case GAMBLE_LEECH:
						{
							gGambleIndex[id][0] = GAMBLE_LEECH
							gGambleIndex[id][1] = gTimer + TIME_LEECH
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Leech",TIME_LEECH,255,0,25)
							server_cmd("amx_leech ^"%s^" on",sAuthid,200,0,0)
						}
						case GAMBLE_ABSORB:
						{
							gGambleIndex[id][0] = GAMBLE_ABSORB
							gGambleIndex[id][1] = gTimer + TIME_ABSORB
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Absorb",TIME_ABSORB,0,100,255)
							server_cmd("amx_absorb ^"%s^" on",sAuthid)
						}
						case GAMBLE_REFLECT:
						{
							gGambleIndex[id][0] = GAMBLE_REFLECT
							gGambleIndex[id][1] = gTimer + TIME_REFLECT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Reflect",TIME_REFLECT,255,200,0)
							server_cmd("amx_reflect ^"%s^" on",sAuthid)
						}
						case GAMBLE_CURSE:
						{
							gGambleIndex[id][0] = GAMBLE_CURSE
							gGambleIndex[id][1] = gTimer + TIME_CURSE
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Curse",TIME_CURSE,100,0,255)
							server_cmd("amx_curse ^"%s^" on",sAuthid)
						}
						case GAMBLE_REGEN:
						{
							gGambleIndex[id][0] = GAMBLE_REGEN
							gGambleIndex[id][1] = gTimer + TIME_REGEN
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Regeneration",TIME_REGEN,255,175,0)
							server_cmd("amx_regen ^"%s^" on",sAuthid)
						}
						case GAMBLE_POISON:
						{
							gGambleIndex[id][0] = GAMBLE_POISON
							gGambleIndex[id][1] = gTimer + TIME_POISON
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Poison",TIME_POISON,0,255,0)
							server_cmd("amx_poison ^"%s^" on",sAuthid)
						}
						case GAMBLE_DEATH:
						{
							gGambleIndex[id][0] = GAMBLE_DEATH
							gGambleIndex[id][1] = gTimer + TIME_DEATH + 5
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Death",TIME_DEATH,255,0,0)
							server_cmd("amx_death ^"%s^" on %i 500",sAuthid,TIME_DEATH)
						}
						case GAMBLE_FIREBALL:
						{
							gGambleIndex[id][0] = GAMBLE_FIREBALL
							gGambleIndex[id][1] = gTimer + TIME_FIREBALL
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Human Fireball",TIME_FIREBALL,255,75,0)
							server_cmd("amx_fireball ^"%s^" on",sAuthid)
						}
						case GAMBLE_MEDIC:
						{
							gGambleIndex[id][0] = GAMBLE_MEDIC
							gGambleIndex[id][1] = gTimer + TIME_MEDIC
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Medic",TIME_MEDIC,100,255,0)
							server_cmd("amx_medic ^"%s^" on",sAuthid)
						}
						case GAMBLE_GHOST:
						{
							gGambleIndex[id][0] = GAMBLE_GHOST
							gGambleIndex[id][1] = gTimer + TIME_GHOST
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Ghost",TIME_GHOST,150,150,255)
							server_cmd("amx_ghost ^"%s^" on",sAuthid)
							// Save last position
							new iOrigin[3]
							get_user_origin(id,iOrigin)
							gPosIndex[id][0] = iOrigin[0]
							gPosIndex[id][1] = iOrigin[1]
							gPosIndex[id][2] = iOrigin[2]
						}
						case GAMBLE_HOLOGRAM:
						{
							gGambleIndex[id][0] = GAMBLE_HOLOGRAM
							gGambleIndex[id][1] = gTimer + TIME_HOLOGRAM
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Hologram",TIME_HOLOGRAM,100,100,255)
							server_cmd("amx_hologram ^"%s^" on",sAuthid)
						}
						case GAMBLE_TIMEBOMB:
						{
							gGambleIndex[id][0] = GAMBLE_TIMEBOMB
							gGambleIndex[id][1] = gTimer + TIME_TIMEBOMB + 5
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Human Timebomb",TIME_TIMEBOMB,255,50,0)
							server_cmd("amx_timebomb ^"%s^" on %i 2000",sAuthid,TIME_TIMEBOMB)
						}
						case GAMBLE_CLOAK:
						{
							gGambleIndex[id][0] = GAMBLE_CLOAK
							gGambleIndex[id][1] = gTimer + TIME_CLOAK
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Cloaking",TIME_CLOAK,50,255,50)
							server_cmd("amx_cloak ^"%s^" on",sAuthid)
						}
						case GAMBLE_ONESHOT:
						{
							gGambleIndex[id][0] = GAMBLE_ONESHOT
							gGambleIndex[id][1] = gTimer + TIME_ONESHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got One Shot Bullets",TIME_ONESHOT,50,100,255)
							server_cmd("amx_oneshot ^"%s^" on",sAuthid)
						}
						case GAMBLE_STUNSHOT:
						{
							gGambleIndex[id][0] = GAMBLE_STUNSHOT
							gGambleIndex[id][1] = gTimer + TIME_STUNSHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Stun Bullets",TIME_STUNSHOT,255,0,75)
							server_cmd("amx_stunshot ^"%s^" on",sAuthid)
						}
						case GAMBLE_EXPLODESHOT:
						{
							gGambleIndex[id][0] = GAMBLE_EXPLODESHOT
							gGambleIndex[id][1] = gTimer + TIME_EXPLODESHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Exploding Bullets",TIME_EXPLODESHOT,255,100,0)
							server_cmd("amx_explodeshot ^"%s^" on",sAuthid)
						}
						case GAMBLE_LASERSHOT:
						{
							gGambleIndex[id][0] = GAMBLE_LASERSHOT
							gGambleIndex[id][1] = gTimer + TIME_LASERSHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Laser Bullets",TIME_LASERSHOT,255,100,0)
							server_cmd("amx_lasershot ^"%s^" on 10 300",sAuthid)
						}
						case GAMBLE_FLASHSHOT:
						{
							gGambleIndex[id][0] = GAMBLE_FLASHSHOT
							gGambleIndex[id][1] = gTimer + TIME_FLASHSHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Flashbang Bullets",TIME_FLASHSHOT,255,255,255)
							server_cmd("amx_flashshot ^"%s^" on",sAuthid)
						}
						case GAMBLE_AGSHOT:
						{
							gGambleIndex[id][0] = GAMBLE_AGSHOT
							gGambleIndex[id][1] = gTimer + TIME_AGSHOT
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Anti-Gravity Bullets",TIME_AGSHOT,0,200,0)
							server_cmd("amx_agshot ^"%s^" on",sAuthid)
						}
						case GAMBLE_SPLINTER:
						{
							gGambleIndex[id][0] = GAMBLE_SPLINTER
							gGambleIndex[id][1] = gTimer + TIME_SPLINTER
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got Splinter Bullets",TIME_SPLINTER,200,200,0)
							server_cmd("amx_splintershot ^"%s^" on",sAuthid)
						}
						case GAMBLE_VAMPIRE:
						{
							gGambleIndex[id][0] = GAMBLE_VAMPIRE
							gGambleIndex[id][1] = gTimer + TIME_VAMPIRE
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Vampire",TIME_VAMPIRE,50,0,255)
							server_cmd("amx_vampire ^"%s^" on",sAuthid)
						}
						case GAMBLE_DISARM:
						{
							gGambleIndex[id][0] = GAMBLE_NONE
							gGambleIndex[id][1] = TIME_NONE
							gGambleIndex[id][2] += 1
							gamble_msg(id,"lost all your weapons",TIME_NONE,200,200,200)
							server_cmd("amx_disarm ^"%s^"",sAuthid)
						}
						case GAMBLE_BURY:
						{
							gGambleIndex[id][0] = GAMBLE_BURY
							gGambleIndex[id][1] = gTimer + TIME_BURY
							gGambleIndex[id][2] += 1
							gamble_msg(id,"got buried in the ground",TIME_BURY,200,200,200)
							server_cmd("amx_bury ^"%s^"",sAuthid)
						}
						case GAMBLE_BLIND:
						{
							gGambleIndex[id][0] = GAMBLE_BLIND
							gGambleIndex[id][1] = gTimer + TIME_BLIND
							gGambleIndex[id][2] += 1
							client_print(id,print_chat,"* You gambled and became blind for %i seconds!",TIME_BLIND)
							server_cmd("amx_blind ^"%s^"",sAuthid)
						}
						case GAMBLE_DRUNK:
						{
							gGambleIndex[id][0] = GAMBLE_DRUNK
							gGambleIndex[id][1] = gTimer + TIME_DRUNK
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became Drunk",TIME_DRUNK,200,200,200)
							server_cmd("amx_drunk ^"%s^"",sAuthid)
						}
						case GAMBLE_BUNNY:
						{
							gGambleIndex[id][0] = GAMBLE_BUNNY
							gGambleIndex[id][1] = gTimer + TIME_BUNNY
							gGambleIndex[id][2] += 1
							gamble_msg(id,"became a Bunny",TIME_BUNNY,200,200,200)
							server_cmd("amx_bunny ^"%s^"",sAuthid)
						}
						default:
						{
							gGambleIndex[id][2] += 1
							gamble_msg(id,"lost all his money",TIME_NONE,200,200,200)
							set_user_money(id,0,1)
						}
					} // end switch
				}
				// gamble times check
				else {
					client_print(id,print_chat,"* Sorry, you can only gamble (%i) times per round.",MAX_GAMBLE)
				}
			}
			// gambled already check
			else {
				client_print(id,print_chat,"* Sorry, you can't gamble until your current powers run out.")
			}
		}
		// user alive check
		else {
			client_print(id,print_chat,"* Sorry, you can't gamble if you're dead.")
		}
	}
	// gamble on check
	else {
		client_print(id,print_chat,"* Sorry, gambling mode is not on :(")
	}
	return PLUGIN_HANDLED
}

public gamble_msg(id,msg[MAX_NAME_LENGTH],time,r,g,b)
{
	new sMsg[MAX_TEXT_LENGTH]
	new sName[MAX_NAME_LENGTH]
	new iPlayers[MAX_PLAYERS], iNumPlayers

        get_players(iPlayers,iNumPlayers,"c")

	get_user_name(id,sName,MAX_NAME_LENGTH)
	if (time == 999) {
		format(sMsg,MAX_TEXT_LENGTH,"%s gambled and %s for the entire round!",sName,msg)
	}
	else if (time > 0) {
		format(sMsg,MAX_TEXT_LENGTH,"%s gambled and %s for %i seconds!",sName,msg,time)
	}
	else {
		format(sMsg,MAX_TEXT_LENGTH,"%s gambled and %s!",sName,msg)
	}

	// Show gamble to self
	set_hudmessage(r,g,b,-1.0,0.30,0,6.0,6.0,0.5,0.15,1)
	show_hudmessage(id,sMsg)

	// Show gamble to all players
	for (new i = 0; i < iNumPlayers; i++) {
		client_print(iPlayers[i],print_chat,"* %s",sMsg)
	}
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_death()
{
	if (gGamble) {
		new iVictim = read_data(2)
		player_reset(iVictim)
	}
	return PLUGIN_CONTINUE
}

public event_respawn(id)
{
	if (gGamble) {
		new sMsg[MAX_TEXT_LENGTH]
		format(sMsg,MAX_TEXT_LENGTH,"-= GAMBLING MOD =-^n^nFeeling lucky? Type ^"gamble!^" to play.")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,sMsg)

		// Force bots to gamble
		if (is_user_bot(id)) {
			do_gamble(id)
		}
	}
	return PLUGIN_CONTINUE
}

public event_round_end()
{
	if (gGamble) {
		set_task(4.0,"event_reset",0,"")
	}
	gTimer = 0
	return PLUGIN_CONTINUE
}

public event_reset()
{
	new sAuthid[MAX_NAME_LENGTH]
	new iPlayers[MAX_PLAYERS], iNumPlayers

	get_players(iPlayers,iNumPlayers)

	for (new i = 0; i < iNumPlayers; i++) {
		get_user_name(iPlayers[i],sAuthid,MAX_NAME_LENGTH)

		// If multiple found, use authid instead
		new iPlayer = player_find(iPlayers[i],sAuthid)
		if (!iPlayer) {
			get_user_authid(iPlayer,sAuthid,MAX_NAME_LENGTH)
		}
		player_reset(iPlayers[i])
		server_cmd("amx_nopowers ^"%s^" 1",sAuthid)
	}
}

public event_gamble()
{
	gGamble = get_cvar_num("amx_gamble_mode")
	if (gGamble) {
		new sAuthid[MAX_NAME_LENGTH]
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)

		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			get_user_authid(iPlayer,sAuthid,MAX_NAME_LENGTH)

			// Powers ran out
			if (gTimer > gGambleIndex[iPlayer][1] && gGambleIndex[iPlayer][0] != GAMBLE_NONE) {
				// Remove powers
				new iGamble = gGambleIndex[iPlayer][0]
				if (iGamble == GAMBLE_GOD) {
					server_cmd("amx_god ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_SHIELD) {
					server_cmd("amx_shield ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_SPEED) {
					server_cmd("amx_speed ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_STEALTH) {
					server_cmd("amx_stealth ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_HARM) {
					server_cmd("amx_harm ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_PROTECT) {
					server_cmd("amx_protect ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_RAMBO) {
					server_cmd("amx_rambo ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_LEECH) {
					server_cmd("amx_leech ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_ABSORB) {
					server_cmd("amx_absorb ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_REFLECT) {
					server_cmd("amx_reflect ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_CURSE) {
					server_cmd("amx_curse ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_REGEN) {
					server_cmd("amx_regen ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_POISON) {
					server_cmd("amx_poison ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_DEATH) {
					server_cmd("amx_death ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_FIREBALL) {
					server_cmd("amx_fireball ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_MEDIC) {
					server_cmd("amx_medic ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_GHOST) {
					new iOrigin[3]
					iOrigin[0] = gPosIndex[iPlayer][0]
					iOrigin[1] = gPosIndex[iPlayer][1]
					iOrigin[2] = gPosIndex[iPlayer][2]
					set_user_origin(iPlayer,iOrigin)
					server_cmd("amx_ghost ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_HOLOGRAM) {
					server_cmd("amx_hologram ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_TIMEBOMB) {
					server_cmd("amx_timebomb ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_CLOAK) {
					server_cmd("amx_cloak ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_ONESHOT) {
					server_cmd("amx_oneshot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_STUNSHOT) {
					server_cmd("amx_stunshot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_EXPLODESHOT) {
					server_cmd("amx_explodeshot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_LASERSHOT) {
					server_cmd("amx_lasershot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_FLASHSHOT) {
					server_cmd("amx_flashshot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_AGSHOT) {
					server_cmd("amx_agshot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_SPLINTER) {
					server_cmd("amx_splintershot ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_VAMPIRE) {
					server_cmd("amx_vampire ^"%s^" off",sAuthid)
				}
				else if (iGamble == GAMBLE_BURY) {
					server_cmd("amx_unbury ^"%s^"",sAuthid)
				}
				else if (iGamble == GAMBLE_BLIND) {
					server_cmd("amx_unblind ^"%s^"",sAuthid)
				}
				else if (iGamble == GAMBLE_BUNNY) {
					server_cmd("amx_unbunny ^"%s^"",sAuthid)
				}
				else if (iGamble == GAMBLE_DRUNK) {
					server_cmd("amx_sober ^"%s^"",sAuthid)
				}
				gGambleIndex[iPlayer][0] = GAMBLE_NONE
				gGambleIndex[iPlayer][1] = TIME_NONE

				// Force bots to gamble again
				if (is_user_bot(iPlayer) && is_user_alive(iPlayer) && gGambleIndex[iPlayer][2] < MAX_GAMBLE) {
					do_gamble(iPlayer)
				}
			}
		}
		gTimer += 1
	}
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

public player_msg(player,msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(player,msg)
}

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

public player_reset(player) {
	new iGamble = gGambleIndex[player][0]
	new sAuthid[MAX_NAME_LENGTH]

	get_user_name(player,sAuthid,MAX_NAME_LENGTH)

	// If multiple found, use authid instead
	new iPlayer = player_find(player,sAuthid)
	if (!iPlayer) {
		get_user_authid(player,sAuthid,MAX_NAME_LENGTH)
	}

	if (iGamble == GAMBLE_BURY) {
		server_cmd("amx_unbury ^"%s^"",sAuthid)
	}
	else if (iGamble == GAMBLE_BLIND) {
		server_cmd("amx_unblind ^"%s^"",sAuthid)
	}
	else if (iGamble == GAMBLE_BUNNY) {
		server_cmd("amx_unbunny ^"%s^"",sAuthid)
	}
	else if (iGamble == GAMBLE_DRUNK) {
		server_cmd("amx_sober ^"%s^"",sAuthid)
	}
	
	gGambleIndex[player][0] = GAMBLE_NONE
	gGambleIndex[player][1] = TIME_NONE
	gGambleIndex[player][2] = 0
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public client_connect(id)
{
	gGambleIndex[id][0] = GAMBLE_NONE
	gGambleIndex[id][1] = TIME_NONE
	gGambleIndex[id][2] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	gGambleIndex[id][0] = GAMBLE_NONE
	gGambleIndex[id][1] = TIME_NONE
	gGambleIndex[id][2] = 0	
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Plugin Gamble","1.2","mike_cao")
	register_concmd("amx_gamble","admin_gamble",ACCESS_LEVEL,"amx_gamble < on | off >")
	register_clcmd("say gamble!","do_gamble",0,"")
	register_event("DeathMsg","event_death","a")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_cvar("amx_gamble_mode","1")
	set_task(1.0,"event_gamble",81,"",0,"b")
	return PLUGIN_CONTINUE
}

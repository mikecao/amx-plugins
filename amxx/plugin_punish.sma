/*
*	AMXMODX script.
*	(plugin_punish.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin gives admins the ability to punish
*	players in multiple ways.
*
*	Commands:
*	amx_disarm - removes all weapons from a player
*	amx_bury - burys a player in the ground, drops all his weapons
*	amx_unbury - unbury a player
*	amx_gag - prevents player from speaking
*	amx_ungag - ungag a player
*	amx_smack - slaps a player multiple times
*	amx_blind - blinds a player
*	amx_unblind - removes blind from a player
*	amx_drunk - makes player stagger and have bad vision
*	amx_sober - removes drunk from a player
*	amx_bunny - makes player constantly jump
*
*/
#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512
#define MAX_SOUNDS 2

#define SOUND_FLASH1	0
#define SOUND_FLASH2	1

#define PUNISH_NONE				0
#define PUNISH_GAG				(1<<0)
#define PUNISH_BLIND			(1<<1)
#define PUNISH_DRUNK			(1<<2)
#define PUNISH_BUNNY			(1<<3)

#define PUNISH_TIMER_INTERVAL 	1.0

/************************************************************
* CONFIGS
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

// Multiplier for FX shake and fade
#define FX_MULT	(1<<12)

/************************************************************
* MAIN
************************************************************/
			
// Globals
new gPunishIndex[MAX_PLAYERS+1]
new gSoundIndex[MAX_SOUNDS][MAX_NAME_LENGTH]
new gmsgShake
new gmsgFade

// DISARM
public admin_disarm(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_disarm < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		// Disarm target player
		player_disarm(iPlayer)
		console_print(id,"[AMX] %s was disarmed.",sName)
	}
	return PLUGIN_HANDLED
}

// BURY
public admin_bury(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_bury < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH+1], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		
		// Bury target player
		player_drop_weapons(iPlayer)
		player_bury(iPlayer)
		console_print(id,"[AMX] %s was buried.",sName)
	}
	return PLUGIN_HANDLED
}

// UNBURY
public admin_unbury(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_unbury < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH+1], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		
		// Unbury target player
		player_unbury(iPlayer)
		console_print(id,"[AMX] %s was unburied",sName)
	}
	return PLUGIN_HANDLED
}

// GAG
public admin_gag(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_gag < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		// Gag player
		new iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)
		
		for (new i = 0; i < iNumPlayers; i++) {
	        set_client_listen(iPlayers[i],iPlayer,0)
		}
		console_print(id,"[AMX] %s is gagged.",sName)
		punish_add(iPlayer,PUNISH_GAG)
		client_print(iPlayer,print_chat,"* You have been gagged!")
	}
	return PLUGIN_HANDLED
}

// UNGAG
public admin_ungag(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_ungag < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		// Gag player
		new iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)
		
		for (new i = 0; i < iNumPlayers; i++) {
	        set_client_listen(iPlayers[i],iPlayer,1)
		}
		console_print(id,"[AMX] %s is ungagged.",sName)
		punish_remove(iPlayer,PUNISH_GAG)
		client_print(iPlayer,print_chat,"* You are no longer gagged!")
	}
	return PLUGIN_HANDLED
}

// SMACK
public admin_smack(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_smack < authid | part of nick > [ number ]")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	new sArg2[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		// Smack target player
		new iNum = str_to_num(sArg2)
		if (iNum == 0) iNum = 10
		if (iNum > 100) iNum = 100
		for (new i = 0; i < iNum; i++) {
			user_slap(iPlayer,0,0)
		}
	}
	return PLUGIN_HANDLED
}

// BLIND
public admin_blind(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_blind < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		console_print(id,"[AMX] %s is blind.",sName)
		punish_add(iPlayer,PUNISH_BLIND)
		emit_sound(iPlayer,CHAN_AUTO,gSoundIndex[random_num(0,1)],VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		fx_screen_fade(iPlayer,1,10,0,255,255,255,255)
	}
	return PLUGIN_HANDLED
}

// UNBLIND
public admin_unblind(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_blind < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		console_print(id,"[AMX] %s is no longer blind.",sName)
		punish_remove(iPlayer,PUNISH_BLIND)
		emit_sound(iPlayer,CHAN_AUTO,gSoundIndex[random_num(0,1)],VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		fx_screen_fade(iPlayer,1,0,0,0,0,0,0)
	}
	return PLUGIN_HANDLED
}

// BUNNY
public admin_bunny(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_bunny < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	new sArg2[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		punish_add(iPlayer,PUNISH_BUNNY)
		console_print(id,"[AMX] %s was made a bunny.",sName)
		client_print(iPlayer,print_chat,"* You are a bunny rabbit!")
	}
	return PLUGIN_HANDLED
}

// UNBUNNY
public admin_unbunny(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_unbunny < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	new sArg2[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		punish_remove(iPlayer,PUNISH_BUNNY)
		console_print(id,"[AMX] %s is no longer a bunny.",sName)
		client_print(iPlayer,print_chat,"* You are no longer a bunny rabbit!")
	}
	return PLUGIN_HANDLED
}

// DRUNK
public admin_drunk(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_drunk < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	new sArg2[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		punish_add(iPlayer,PUNISH_DRUNK)
		client_print(iPlayer,print_chat,"* You are drunk!")
		console_print(id,"[AMX] %s is now drunk.",sName)
	}
	return PLUGIN_HANDLED
}

// SOBER
public admin_sober(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_sober < authid | part of nick >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	new sArg2[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_flags(iPlayer)&ADMIN_IMMUNITY) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" has immunity",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
		}
		punish_remove(iPlayer,PUNISH_DRUNK)
		console_print(id,"[AMX] %s is now sober.",sName)
		client_print(iPlayer,print_chat,"* You are now sober!")
	}
	return PLUGIN_HANDLED
}

/************************************************************
* HELPER FUNCTIONS
************************************************************/

public punish_add(player,PUNISH_FLAG)
{
	if (!(gPunishIndex[player]&PUNISH_FLAG)) {
		gPunishIndex[player] += PUNISH_FLAG
	}
	return PLUGIN_CONTINUE
}

public punish_remove(player,PUNISH_FLAG)
{
	if (gPunishIndex[player]&PUNISH_FLAG) {
		gPunishIndex[player] -= PUNISH_FLAG
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_gag(id)
{
	if (gPunishIndex[id]&PUNISH_GAG){
		client_print(id,print_notify,"[AMX] Sorry, you are gagged.")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE	
}

public event_punish()
{
	new iPlayer, iPlayerFlags, iPlayers[MAX_PLAYERS], iNumPlayers
	static const movement[4][] = {"+moveleft","+moveright","+forward","+back"}

	get_players(iPlayers,iNumPlayers,"a")

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		iPlayerFlags = gPunishIndex[iPlayer]
		if (iPlayerFlags&PUNISH_BLIND) {
			fx_screen_fade(iPlayer,1,10,0,255,255,255,255)
		}
		if (iPlayerFlags&PUNISH_DRUNK) {
			fx_screen_shake(iPlayer,10,10,10)
			client_cmd(iPlayer,movement[random_num(0,3)]) 
			client_cmd(iPlayer,"-moveleft;-moveright;-forward;-back") 
		}
		if (iPlayerFlags&PUNISH_BUNNY) {
			client_cmd(iPlayer,"+jump;wait;-jump;wait;+jump;wait;-jump;")
		}
	}
		
}

/************************************************************
* FX FUNCTIONS
************************************************************/

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
* PLAYER FUNCTIONS
************************************************************/

static player_find(id,arg[])
{
	new player = find_player("bl",arg)
	if (player){
		new player2 = find_player("blj",arg)
		if (player!=player2){
			console_print(id,"[AMX] Found multiple clients. Try again.")
			return 0		
		}
	}
	else {
		player = find_player("c",arg)
	}
	if (!player){
		console_print(id,"[AMX] Client with that authid or part of nick not found")
		return 0
	}
	return player
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

static player_bury(player)
{
	new iOrigin[3]
	get_user_origin(player,iOrigin)
	iOrigin[2] -= 20
	set_user_origin(player,iOrigin)
	return PLUGIN_CONTINUE
}

static player_unbury(player)
{
	new iOrigin[3]
	get_user_origin(player,iOrigin)
	iOrigin[2] += 30
	set_user_origin(player,iOrigin)
	return PLUGIN_CONTINUE
}

public player_disarm(player)
{
	new iOrigin[3]
	get_user_origin(player,iOrigin)
	iOrigin[2] -= 1000
	set_user_origin(player,iOrigin)
	player_drop_weapons(player)
	iOrigin[2] += 1010
	set_user_origin(player,iOrigin)
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public client_connect(id)
{
	gPunishIndex[id] = PUNISH_NONE
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	gPunishIndex[id] = PUNISH_NONE
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	copy(gSoundIndex[SOUND_FLASH1],MAX_NAME_LENGTH,"weapons/flashbang-1.wav")
	copy(gSoundIndex[SOUND_FLASH2],MAX_NAME_LENGTH,"weapons/flashbang-2.wav")

	for (new i = 0; i < MAX_SOUNDS; i++) {
		precache_sound(gSoundIndex[i])
	}
}

public plugin_init()
{
	register_plugin("Plugin Punish","1.0","mike_cao")
	register_concmd("amx_disarm","admin_disarm",ACCESS_LEVEL,"amx_disarm < authid | part of nick >")
	register_concmd("amx_gag","admin_gag",ACCESS_LEVEL,"amx_gag < authid | part of nick >")
	register_concmd("amx_ungag","admin_ungag",ACCESS_LEVEL,"amx_ungag < authid | part of nick >")
	register_concmd("amx_bury","admin_bury",ACCESS_LEVEL,"amx_bury < authid | part of nick >")
	register_concmd("amx_unbury","admin_unbury",ACCESS_LEVEL,"amx_unbury < authid | part of nick >")
	register_concmd("amx_smack","admin_smack",ACCESS_LEVEL,"amx_smack < authid | part of nick > < number >")
	register_concmd("amx_blind","admin_blind",ACCESS_LEVEL,"amx_blind < authid | part of nick >")
	register_concmd("amx_unblind","admin_unblind",ACCESS_LEVEL,"amx_unblind < authid | part of nick >")
	register_concmd("amx_drunk","admin_drunk",ACCESS_LEVEL,"amx_drunk < authid | part of nick >")
	register_concmd("amx_sober","admin_sober",ACCESS_LEVEL,"amx_sober < authid | part of nick >")
	register_concmd("amx_bunny","admin_bunny",ACCESS_LEVEL,"amx_bunny < authid | part of nick >")
	register_concmd("amx_unbunny","admin_unbunny",ACCESS_LEVEL,"amx_unbunny < authid | part of nick >")

	gmsgShake = get_user_msgid("ScreenShake")
	gmsgFade = get_user_msgid("ScreenFade")

	register_clcmd("say","event_gag")
	
	// Controller
	set_task(PUNISH_TIMER_INTERVAL,"event_punish",666,"",0,"b")

	return PLUGIN_CONTINUE
}

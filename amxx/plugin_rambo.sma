/*
*	AMXMODX script.
*	(plugin_punish.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin gives players infinite bullets.
*
*/
#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

/************************************************************
* CONFIGS
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

// Globals
new gMod[MAX_NAME_LENGTH]
new gRamboIndex[MAX_PLAYERS+1]

// Weapon names for DOD
new gDodWeapons[40][] = {
	"","amerknife","gerknife","colt","luger","garand","scopedkar","thompson","mp44",
	"spring","kar","bar","mp40","grenade","grenade2","grenade","grenade2",
	"mg42","30cal","spade","m1carbine","mg34","greasegun","fg42","k43","enfield",
	"sten","bren","webly","bazooka","pschreck","piat","scoped_fg42","fcarbine",
	"bayonet","scoped_enfield","mills_bomb","brit_knife","garandbutt","enf_bayonet"
}

public admin_rambo(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_rambo < authid | part of nick > < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (str_to_num(sArg2) == 1 || equal(sArg2,"on")) {
			gRamboIndex[iPlayer] = 1
			client_print(id,print_console,"[AMX] %s is now rambo.",sName)
		}
		else {
			gRamboIndex[iPlayer] = 0
			client_print(id,print_console,"[AMX] %s is no longer rambo.",sName)
		}
	}
	return PLUGIN_HANDLED
}

public event_weapon()
{
	new iPlayer = read_data(0)
	new iClip, iAmmo, iOrigin[3]
	new sWeapon[MAX_NAME_LENGTH]

	new iWeapon = get_user_weapon(iPlayer, iClip, iAmmo)

	if (iClip == 0 && gRamboIndex[iPlayer] == 1) {
		if (equal(gMod,"dod")) {
			format(sWeapon,MAX_NAME_LENGTH,"weapon_%s",gDodWeapons[iWeapon])
		}
		else {
			get_weaponname(iWeapon,sWeapon,MAX_NAME_LENGTH)
		}
		get_user_origin(iPlayer,iOrigin)
		iOrigin[2] -= 1000
		set_user_origin(iPlayer,iOrigin)
		engclient_cmd(iPlayer,"drop",sWeapon)
		give_item(iPlayer,sWeapon)
		iOrigin[2] += 1010
		set_user_origin(iPlayer,iOrigin)
		engclient_cmd(iPlayer,sWeapon)
	}

	return PLUGIN_CONTINUE
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

public player_find(id,arg[])
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

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public client_connect(id)
{
	gRamboIndex[id] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	gRamboIndex[id] = 0
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Rambo","1.0","mike_cao")
	register_event("CurWeapon","event_weapon","be","1=1")
	register_concmd("amx_rambo","admin_rambo",ACCESS_LEVEL,"amx_rambo < authid | part of nick > < on | off >")
	get_modname(gMod,MAX_NAME_LENGTH)
	return PLUGIN_CONTINUE
}

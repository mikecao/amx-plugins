/*
*	AMXMODX script.
*	(plugin_ka.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Knife arena. Players can only use knives.
*
*/ 

#include <amxmodx>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

public admin_ka(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_ka < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_knife_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Knife Arena is now on.")
		msg_display("Knife Arena is now on! :)",0,200,0)
		
		new iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)
		for (new i = 0; i < iNumPlayers; i++) {
			engclient_cmd(iPlayers[i],"weapon_knife")
		}
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Knife Arena is now off.")
		msg_display("Knife Arena is now off! :(",0,200,0)
	}
	return PLUGIN_HANDLED
}

public msg_display(msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(0,msg)
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_weapon()
{
	new iPlayer = read_data(0)
	if (get_cvar_num("amx_knife_mode")) {
		engclient_cmd(iPlayer,"weapon_knife")
	}
	return PLUGIN_CONTINUE
}

public event_respawn(id)
{
	if (get_cvar_num("amx_knife_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		format(sMsg,MAX_TEXT_LENGTH,"-= KNIFE ARENA MOD =-^n^nKnives only!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
		show_hudmessage(id,sMsg)
		engclient_cmd(id,"weapon_knife")
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Knife Arena","1.0","mike_cao")
	register_clcmd("amx_ka","admin_ka",ACCESS_LEVEL,"amx_ka < 0 | 1 >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("CurWeapon","event_weapon","be","1=1")
	register_cvar("amx_knife_mode","0")
	return PLUGIN_CONTINUE
}

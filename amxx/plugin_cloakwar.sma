/*
*	AMXMODX script.
*	(plugin_cloakwar.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin requires the following plugins to work:
*	(plugin_powers.sma)
*
*	Gives the winning team cloaking powers. Cloaked players
*	are revealed only for a few seconds after firing but 
*	they only have 1 health.
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

new gCloakTeam = 0

public admin_cloakwar(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_cloakwar < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_cloakwar_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Cloak War is now on.")
		msg_display("Cloak War is now on! :)",0,200,0)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Cloak War is now off.")
		msg_display("Cloak War is now off! :(",0,200,0)
		gCloakTeam = 0
		event_reset()
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

public event_cloak()
{
	new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
	new sName[MAX_NAME_LENGTH]
	get_players(iPlayers,iNumPlayers)

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_team(iPlayer)==gCloakTeam) {
			server_cmd("amx_cloak ^"%s^" on",sName)
		}
	}
}

public event_reset()
{
	new sName[MAX_NAME_LENGTH]
	new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers)
	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		server_cmd("amx_nopowers ^"%s^" 1",sName)
	}
}

public event_respawn(id)
{
	if (get_cvar_num("amx_cloakwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		new sTeam[MAX_TEXT_LENGTH]
		if (gCloakTeam==1) {
			copy(sTeam,MAX_NAME_LENGTH,"TERRORIST")
		}
		else if (gCloakTeam==2){
			copy(sTeam,MAX_NAME_LENGTH,"COUNTER-TERRORIST")
		}
		format(sMsg,MAX_TEXT_LENGTH,"-= CLOAK WARS MOD =-^n^nThe %s team is cloaked! Watch out!",sTeam)
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,sMsg)
	}
	return PLUGIN_CONTINUE
}

public event_round_t()
{
	if (get_cvar_num("amx_cloakwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		gCloakTeam = 1
		format(sMsg,MAX_TEXT_LENGTH,"The TERRORIST team won cloaking powers!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
		show_hudmessage(0,sMsg)
		set_task(4.0,"event_reset",0,"")
		set_task(5.0,"event_cloak",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_round_ct()
{
	if (get_cvar_num("amx_cloakwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		gCloakTeam = 2
		format(sMsg,MAX_TEXT_LENGTH,"The COUNTER-TERRORIST team won cloaking powers!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
		show_hudmessage(0,sMsg)
		set_task(4.0,"event_reset",0,"")
		set_task(5.0,"event_cloak",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_round_draw()
{
	if (get_cvar_num("amx_cloakwar_mode")) {
		gCloakTeam = random_num(1,2)
		set_task(4.0,"event_reset",0,"")
		set_task(5.0,"event_cloak",0,"")
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Cloak War","1.0","mike_cao")
	register_clcmd("amx_cloakwar","admin_cloakwar",ACCESS_LEVEL,"amx_ka < 0 | 1 >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_cvar("amx_cloakwar_mode","0")
	register_event("SendAudio","event_round_t","a","2&%!MRAD_terwin")
	register_event("SendAudio","event_round_ct","a","2&%!MRAD_ctwin")
	register_event("SendAudio","event_round_draw","a","2&%!MRAD_rounddraw")
	return PLUGIN_CONTINUE
}

/*
*	AMXMODX script.
*	(plugin_hunting.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*       This plugin requires the following plugins to work:
*       (plugin_powers.sma)
*
*	Hunting season mod. One team (hunters) have infinite ammo and
*	armor. The other team (bears) have lots of health and knives.
*	Teams switch roles every round.
*
*	Cvar:
*	amx_hunting_mode <1|0>
*
*/ 

#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

#define DEFAULT_HEALTH 3000

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A


/************************************************************
* MAIN
************************************************************/

new gHunterTeam = 1
new gBearHealth = DEFAULT_HEALTH
new gMsg[MAX_TEXT_LENGTH] = {"-= HUNTING SEASON MOD =-^n^nHunters VS. Bears^n^nTeam roles switch every round."}

public admin_hunting(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_hunting < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_hunting_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Hunting season is now on.")
		player_msg(0,"Hunting season is now on! :)",0,200,0)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Hunting season is now off.")
		player_msg(0,"Hunting season is now off! :(",0,200,0)
	}
	return PLUGIN_HANDLED
}

public admin_bear(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 2) {
                console_print(id,"[AMX] Usage: amx_bear < health >")
                return PLUGIN_HANDLED
        }
        new sArg1[MAX_NAME_LENGTH+1]
        read_argv(1,sArg1,MAX_NAME_LENGTH)
	
	gBearHealth = str_to_num(sArg1)
	client_print(id,print_console,"[AMX] Bear health set to %s",sArg1)

	return PLUGIN_HANDLED
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_respawn(id)
{
	if (get_cvar_num("amx_hunting_mode")) {
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,gMsg)

                new sAuthid[MAX_NAME_LENGTH]
                get_user_name(id,sAuthid,MAX_NAME_LENGTH)

                // If multiple found, use authid instead
                new iPlayer = player_find(id,sAuthid)
                if (!iPlayer) {
                        get_user_authid(id,sAuthid,MAX_NAME_LENGTH)
                }
		// Set user as a hunter or a bear
		if (get_user_team(id)==gHunterTeam) {
			server_cmd("amx_rambo ^"%s^" on",sAuthid)
			client_print(id,print_chat,"* You are a hunter! Go kill them bears!")
		}
		else {
			set_user_health(id,gBearHealth)
			client_print(id,print_chat,"* You are a bear! Rawr!")
                        engclient_cmd(id,"weapon_knife")
                        set_user_maxspeed(id,350.0)
		}
        }
	return PLUGIN_CONTINUE
}

public event_glow()
{
	if (get_cvar_num("amx_hunting_mode")) {
                new iPlayers[MAX_PLAYERS], iNumPlayers

                get_players(iPlayers,iNumPlayers)

                for (new i = 0; i < iNumPlayers; i++) {
                        if (get_user_team(iPlayers[i]) == gHunterTeam) {
				set_user_rendering(iPlayers[i])
			}
			else {
				set_user_rendering(iPlayers[i],kRenderFxGlowShell,255,255,255,kRenderNormal,200)
			}
                }
	
	}
	return PLUGIN_CONTINUE
}

public event_weapon()
{
	if (get_cvar_num("amx_hunting_mode")) {
	        new iPlayer = read_data(0)
		if (get_user_team(iPlayer) != gHunterTeam) {
			engclient_cmd(iPlayer,"weapon_knife")
			set_user_maxspeed(iPlayer,350.0)
		}
	}
	return PLUGIN_CONTINUE
}

public event_round_end()
{
	if (get_cvar_num("amx_hunting_mode")) {
		if (gHunterTeam == 1) {
			gHunterTeam = 2
		}
		else {
			gHunterTeam = 1
		}
		set_task(4.0,"event_reset",0,"")
		set_task(5.0,"event_glow",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_reset()
{
        if (get_cvar_num("amx_hunting_mode")) {
                new sAuthid[MAX_NAME_LENGTH]
                new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers

                get_players(iPlayers,iNumPlayers)

                for (new i = 0; i < iNumPlayers; i++) {
                        iPlayer = iPlayers[i]
                        get_user_authid(iPlayer,sAuthid,MAX_NAME_LENGTH)
                        server_cmd("amx_nopowers ^"%s^" 1",sAuthid)
                }
        }
        return PLUGIN_CONTINUE
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


/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Plugin Hunting Season","1.0","mike_cao")
	register_concmd("amx_hunting","admin_hunting",ACCESS_LEVEL,"amx_hunting < on | off >")
	register_concmd("amx_bear","admin_bear",ACCESS_LEVEL,"amx_bear < health >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_event("CurWeapon","event_weapon","be","1=1")
	register_cvar("amx_hunting_mode","0")
	return PLUGIN_CONTINUE
}

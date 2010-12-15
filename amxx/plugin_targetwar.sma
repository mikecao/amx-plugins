/*
*	AMXMODX script.
*	(plugin_targetwar.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Target war mod. One person on each team is randomly
*	selected to be a target. Only the target can die, 
*	everyone else has immunity. If the target dies, another
*	player is randomly selected to be a target.
*
*	Cvar:
*	amx_targetwar_mode <1|0>
*
*/ 

#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

#define FX_MULT (1<<12)

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A


/************************************************************
* MAIN
************************************************************/

new gMsg[MAX_TEXT_LENGTH] = {"-= TARGET WARS MOD =-^n^nSearch and destroy the target players."}
new gTargetT = 0
new gTargetCT = 0
new gmsgFade

public admin_targetwar(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_targetwar < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_targetwar_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Target wars is now on.")
		player_msg(0,"Target wars is now on! :)",0,200,0)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Target wars is now off.")
		player_msg(0,"Target wars is now off! :(",0,200,0)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_respawn(id)
{
	if (get_cvar_num("amx_targetwar_mode")) {
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,gMsg)
        }
	return PLUGIN_CONTINUE
}

public event_death()
{
	new iVictim = read_data(2)
	if (iVictim == gTargetT) {
		get_target_t()
	}
	else if (iVictim == gTargetCT) {
		get_target_ct()
	}
	return PLUGIN_CONTINUE
}

public event_target()
{
	if (get_cvar_num("amx_targetwar_mode")) {
                new iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)

		for (new i = 0; i < iNumPlayers; i++) {
			set_user_godmode(iPlayers[i],1)
		}

		get_target_t()
		get_target_ct()
	}
	return PLUGIN_CONTINUE
}

public event_round_end()
{
	if (get_cvar_num("amx_targetwar_mode")) {
		set_task(5.0,"event_target",0,"")
	}
	return PLUGIN_CONTINUE
}


/************************************************************
* HELPER FUNCTIONS
************************************************************/

public player_msg(player,msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(player,msg)
}

public get_target_ct()
{
	new iPlayers[MAX_PLAYERS], iNumPlayers
	new sName[MAX_NAME_LENGTH]

	get_players(iPlayers,iNumPlayers,"ae","CT")
	gTargetCT = iPlayers[random_num(0,iNumPlayers-1)]

	set_user_godmode(gTargetCT)
	fx_glow(gTargetCT,0,100,255,20)
	fx_screen_fade(gTargetCT,1,0,0,0,100,255,255)

	get_user_name(gTargetCT,sName,MAX_NAME_LENGTH)
	client_print(0,print_chat,"***** CT Target: %s *****",sName)
}

public get_target_t()
{
	new iPlayers[MAX_PLAYERS], iNumPlayers
	new sName[MAX_NAME_LENGTH]

	get_players(iPlayers,iNumPlayers,"ae","TERRORIST")
	gTargetT = iPlayers[random_num(0,iNumPlayers-1)]
	
	set_user_godmode(gTargetT)
	fx_glow(gTargetT,255,0,0,20)
	fx_screen_fade(gTargetT,1,0,0,255,0,0,255)

	get_user_name(gTargetT,sName,MAX_NAME_LENGTH)
	client_print(0,print_chat,"***** T Target: %s *****",sName)
}


static fx_glow(player,r,g,b,size)
{
        set_user_rendering(player,kRenderFxGlowShell,r,g,b,kRenderNormal,size)
        return PLUGIN_CONTINUE
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
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Plugin Hunting Season","1.0","mike_cao")
	register_concmd("amx_targetwar","admin_targetwar",ACCESS_LEVEL,"amx_targetwar < on | off >")
	register_event("DeathMsg","event_death","a")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_cvar("amx_targetwar_mode","0")

	gmsgFade = get_user_msgid("ScreenFade")

	return PLUGIN_CONTINUE
}

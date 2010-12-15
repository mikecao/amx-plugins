/*
*	AMXMODX script.
*	(plugin_hunting.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin requires the Vexd module.
*
*	Clone wars mod. All players have the same model.
*
*	Cvar:
*	amx_clonewar_mode <1|0>
*
*/ 

#include <amxmodx>
#include <fun>
#include <cstrike>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512
#define MODEL_INDEX 8

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A


/************************************************************
* MAIN
************************************************************/

new gMsg[MAX_TEXT_LENGTH] = {"-= CLONE WARS MOD =-^n^nAttack of the Clones!"}
new gModels[MODEL_INDEX][] = {"arctic","gign","gsg9","guerilla","leet","sas","urban","vip"}
new gModel[MAX_NAME_LENGTH]
new gFFDefault = 0
new gmsgStatusText

public admin_clonewar(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_clonewar < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_clonewar_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Clone wars mod is now on.")
		player_msg(0,"Clone wars is now on! :)",0,200,0)
		set_cvar_num("mp_friendlyfire",1)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Clone wars mod is now off.")
		player_msg(0,"Clone wars is now off! :(",0,200,0)
		set_cvar_num("mp_friendlyfire",gFFDefault)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_respawn(id)
{
	if (get_cvar_num("amx_clonewar_mode")) {
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,gMsg)

		cs_set_user_model(id,gModel)
        }
	return PLUGIN_CONTINUE
}

public event_damage()
{
        new iVictim = read_data(0)
        new iDamage = read_data(2)
        new iWeapon, iBody
        new iAttacker = get_user_attacker(iVictim,iWeapon,iBody)

	if (iVictim != iAttacker && get_user_team(iAttacker) == get_user_team(iVictim)) {
		new iHealth = get_user_health(iAttacker)
		set_user_health(iAttacker,iHealth-iDamage)
	}

	return PLUGIN_CONTINUE
}

public event_round_end()
{
	if (get_cvar_num("amx_clonewar_mode")) {
		format(gModel,MAX_NAME_LENGTH,"%s",gModels[random_num(0,MODEL_INDEX-1)])
	}
	return PLUGIN_CONTINUE
}

public event_msg()
{
	if (get_cvar_num("amx_clonewar_mode")) {
        	new sMsg[MAX_TEXT_LENGTH]
	        format(sMsg,MAX_TEXT_LENGTH,"Clone Wars Mod")
        	message_begin(MSG_ALL,gmsgStatusText,{0,0,0})
	        write_byte(0)
        	write_string(sMsg)
	        message_end()
	}
        return PLUGIN_HANDLED
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

public player_msg(player,msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(player,msg)
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Clone Wars","1.0","mike_cao")
	register_concmd("amx_clonewar","admin_clonewar",ACCESS_LEVEL,"amx_clonewar < on | off >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_cvar("amx_clonewar_mode","0")
	gFFDefault = get_cvar_num("mp_friendlyfire")
	gmsgStatusText = get_user_msgid("StatusText")
	set_task(0.5,"event_msg",0,"",0,"b")
	return PLUGIN_CONTINUE
}

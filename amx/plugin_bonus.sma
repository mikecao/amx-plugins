/*
*	AMXMOD script.
*	(plugin_bonus.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Gives bonuses for making early kills.
*
*/
#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_TEXT_LENGTH 512

#define ACCESS_LEVEL ADMIN_LEVEL_A

// Default on/off
new gBonusMode = 1

new gBonusCount = 0
new gBonusIndex[5] = { 50,40,30,20,10 }

public admin_bonuskill(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_bonuskill < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	if (str_to_num(sArg1)) {
		gBonusMode = 1
		client_print(id,print_console,"[AMX] Bonus health for kills is now ON.")
	}
	else {
		gBonusMode = 0
		client_print(id,print_console,"[AMX] Bonus health for kills is now OFF.")
	}
	
	return PLUGIN_HANDLED
}

public event_death()
{
	if (gBonusMode) {
		new iKiller = read_data(1)
		new iVictim = read_data(2)
		new sMsg[MAX_TEXT_LENGTH]
		new sName[MAX_NAME_LENGTH]
		get_user_name(iKiller,sName,MAX_NAME_LENGTH)
		
		if ((iKiller != iVictim) && (gBonusCount < sizeof gBonusIndex) && (get_user_team(iKiller) != get_user_team(iVictim))) {
			gBonusCount++
			set_user_health(iKiller,get_user_health(iKiller)+gBonusIndex[gBonusCount-1])
			if (gBonusCount == 1) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got the 1st kill! (+%i health)",sName,gBonusIndex[gBonusCount-1])
			}
			else if (gBonusCount == 2) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got the 2nd kill! (+%i health)",sName,gBonusIndex[gBonusCount-1])
			}
			else if (gBonusCount == 3) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got the 3rd kill! (+%i health)",sName,gBonusIndex[gBonusCount-1])
			}
			else {
				format(sMsg,MAX_TEXT_LENGTH,"%s got the %ith kill! (+%i health)",sName,gBonusCount,gBonusIndex[gBonusCount-1])
			}
			display_msg(sMsg,200,200,200)
		}
	}
	return PLUGIN_CONTINUE
}

public event_round_end() {
	gBonusCount = 0
}

public display_msg(msg[],r,g,b)
{
	set_hudmessage(r,g,b,-1.0,0.40,0,6.0,6.0,0.5,0.15,2)
	show_hudmessage(0,msg)
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Plugin Health Bonus","1.0","mike_cao")
	register_event("DeathMsg","event_death","a")
	register_event("SendAudio","event_round_end","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_concmd("amx_bonuskill","admin_bonuskill",ACCESS_LEVEL,"amx_powers < authid | part of nick >")
}
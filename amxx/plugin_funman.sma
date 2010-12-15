/*
*	AMXMODX script.
*	(plugin_funman.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Fun manager. Turns on different fun modes based
*	on the current map.
*
*	Cvar:
*	amx_funman_mode <1|0>
*
*/ 

#include <amxmodx>

#define MAX_NAME_LENGTH 32

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A


/************************************************************
* MAIN
************************************************************/

#define MAP_INDEX 4
#define FUN_INDEX 7

// Fun mode index
new gFunModes[FUN_INDEX][] = {
	"amx_gamble_mode",
	"amx_freezetag_mode",
	"amx_stealthwar_mode",
	"amx_cloakwar_mode",
	"amx_hunting_mode",
	"amx_targetwar_mode",
	"amx_knife_mode"
}

// Map index
new gMaps[MAP_INDEX][] = {
	"cs_assault",
	"de_dust",
	"de_aztec",
	"de_dust2"
}

// Fun modes tied to maps 
new gMapCvars[MAP_INDEX][] = {
	"amx_freezetag_mode",
	"amx_stealthwar_mode",
	"amx_cloakwar_mode",
	"amx_hunting_mode"
}

// Default fun mode
new gDefault[MAX_NAME_LENGTH] = "amx_gamble_mode"

public admin_funman(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_funman < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_funman_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Fun manager now on.")
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Fun manager is now off.")
	}
	return PLUGIN_HANDLED
}

public event_fun() {
	if (get_cvar_num("amx_funman_mode")) {
		new sMap[MAX_NAME_LENGTH]
		new isMatch = 0
		get_mapname(sMap,MAX_NAME_LENGTH)

		event_reset()

		for (new i = 0; i < MAP_INDEX; i++) {
			if (equal(sMap,gMaps[i])) {
				set_cvar_num(gMapCvars[i],1)
				isMatch = 1
				break
			}
		}

		if (!isMatch) {
			set_cvar_num(gDefault,1)
		}
	}
	return PLUGIN_HANDLED
}

public event_reset() {
	for (new i = 0; i < FUN_INDEX; i++) {
		set_cvar_num(gFunModes[i],0)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Fun Manager","1.0","mike_cao")
	register_concmd("amx_funman","admin_funman",ACCESS_LEVEL,"amx_funman < on | off >")
	register_cvar("amx_funman_mode","0")
	
	set_task(5.0,"event_fun")
	
	return PLUGIN_CONTINUE
}

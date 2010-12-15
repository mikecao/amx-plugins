/*
*	AMXMODX script.
*	(plugin_namechange.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Prevents or punishes players for changing their names.
*
*/
#include <amxmodx>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

new Float:gSpawnTime
new gNameIndex[MAX_PLAYERS+1][MAX_NAME_LENGTH]

/************************************************************
* CONFIG
************************************************************/

// Action to take for players changing their name
// 0 = do nothing
// 1 = change back to old name
// 2 = kill player
// 3 = disconnect player
new NAMECHANGE_ACTION = 3

// No name change allowed this many seconds after round starts
// Counter-strike only
#define DEFAULT_NAMECHANGE_TIME		30

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public event_respawn(id)
{
	gSpawnTime = get_gametime()
	return PLUGIN_CONTINUE
}

public client_connect(id)
{
	copy(gNameIndex[id],MAX_NAME_LENGTH,"")
	return PLUGIN_CONTINUE
}

// Name change
public client_infochanged(id)
{
	new sName[MAX_TEXT_LENGTH], sNewName[MAX_TEXT_LENGTH], sMod[MAX_NAME_LENGTH]
	get_user_name(id,sName,MAX_TEXT_LENGTH)
	get_user_info(id,"name",sNewName,MAX_TEXT_LENGTH)
	get_modname(sMod,MAX_NAME_LENGTH)
		
	if (!equal(sName,sNewName) && !equal(sNewName,gNameIndex[id])) {
		if (NAMECHANGE_ACTION <= 0) return PLUGIN_CONTINUE

		if (equal(sMod,"cstrike")) {
			if (is_user_alive(id) && get_gametime() > (gSpawnTime + DEFAULT_NAMECHANGE_TIME)) {
				client_print(id,print_console,"* You can't change your name %i seconds after the round has started.",DEFAULT_NAMECHANGE_TIME)
			}
			else {
				return PLUGIN_CONTINUE
			}
		}

		if (NAMECHANGE_ACTION == 1) {
			copy(gNameIndex[id],MAX_NAME_LENGTH,sName)
			client_cmd(id,"name ^"%s^"",sName)
		}
		else if (NAMECHANGE_ACTION == 2) {
			user_kill(id);
			client_cmd(id,"echo * Killed due to name change.")
		}
		else if (NAMECHANGE_ACTION == 3) {
			client_cmd(id,"echo * Reconnecting due to name change.;retry");
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Plugin Namechange","1.2","mike_cao")
	register_event("ResetHUD","event_respawn","be","1=1")
}

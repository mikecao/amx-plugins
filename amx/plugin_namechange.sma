/*
*	AMXMOD script.
*	(plugin_namechange.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Prevents players from changing their names
*	a certain time after the round has started.
*
*/
#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

new Float:gSpawnTime
new gNameIndex[MAX_PLAYERS+1][MAX_NAME_LENGTH]

/************************************************************
* CONFIG
************************************************************/

// No name change allowed this many seconds after round starts
#define DEFAULT_NAMECHANGE_TIME		30

// Kill the player for changing their name (1=on/0=off)
new NAMECHANGE_KILL = 0

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
	new sName[MAX_TEXT_LENGTH], sNewName[MAX_TEXT_LENGTH]
	get_user_name(id,sName,MAX_TEXT_LENGTH)
	get_user_info(id,"name",sNewName,MAX_TEXT_LENGTH)
		
	// Not allowed
	if (!equal(sName,sNewName) && !equal(sNewName,gNameIndex[id]) && get_gametime() > (gSpawnTime + DEFAULT_NAMECHANGE_TIME) && is_user_alive(id)) {
		client_print(id,print_console,"* You can't change your name %i seconds after the round has started.",DEFAULT_NAMECHANGE_TIME)
		
		if (NAMECHANGE_KILL == 1) {
			user_kill(id);
		}
		else {
			copy(gNameIndex[id],MAX_NAME_LENGTH,sName)
			client_cmd(id,"name ^"%s^"",sName)
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Plugin Namechange","1.1","mike_cao")
	register_event("ResetHUD","event_respawn","be","1=1")
}
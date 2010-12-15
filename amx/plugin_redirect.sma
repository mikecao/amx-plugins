/*
*	AMXMOD script.
*	(plugin_redirect.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Redirects players to another server if current server is full.
*
*/

#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_TEXT_LENGTH 256

new gServerName[MAX_TEXT_LENGTH] = "www.yourserver.com"
new gServerAddress[MAX_TEXT_LENGTH] = "1.2.3.4"

// Show redirect message?
new gMsg = 0

public client_connect(id)
{
	new iMaxPlayers = get_maxplayers()
	new iReservedSlots = 0
	
	if (cvar_exists("amx_reserved_slots")) {
		iReservedSlots = get_cvar_num("amx_reserved_slots")
	}
	new iPlayers = get_playersnum() + 1
	if (iPlayers > (iMaxPlayers - iReservedSlots)) {
		if (!(get_user_flags(id)&ADMIN_RESERVATION)) {
			if (gMsg) {
				client_cmd(id,"echo ^"Server is currently full.^"")
				client_cmd(id,"echo ^"Redirecting to %s^";wait;wait;",gServerName)
			}
			client_cmd(id,"connect %s",gServerAddress)
		}
	}
}


public plugin_init() {
	register_plugin("Plugin Redirect","1.0","mike_cao")
	return PLUGIN_CONTINUE
}

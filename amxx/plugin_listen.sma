/*
*	AMXMODX script.
*	(plugin_listen.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Cvar amx_listen:
*	"a" - Admins can hear everyone
*	"b" - Dead players can hear alive players
*	"c" - Alive players can hear dead players
*
*/
#include <amxmodx>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 256

#define LISTEN_ADMIN	(1<<0)
#define LISTEN_DEAD		(1<<1)
#define LISTEN_ALIVE	(1<<2)

/************************************************************
* CONFIGS
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

public event_say(id)
{
	new iFlags = get_listen_flags()
	
	// No flags
	if (!(iFlags&LISTEN_ADMIN) && !(iFlags&LISTEN_DEAD) && !(iFlags&LISTEN_ALIVE)) {
		return PLUGIN_CONTINUE
	}
	else {
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		new sName[MAX_NAME_LENGTH], sCommand[MAX_NAME_LENGTH], sMessage[MAX_TEXT_LENGTH]

		read_argv(0,sCommand,MAX_TEXT_LENGTH)
		read_argv(1,sMessage,MAX_TEXT_LENGTH)
		get_user_name(id,sName,MAX_NAME_LENGTH)
		get_players(iPlayers,iNumPlayers,"c")
		
		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			// Ignore self, ignore same status messages
			if ((iPlayer != id) && (is_user_alive(iPlayer) != is_user_alive(id))) {
				// If speaker is alive, echo to dead players
				if (is_user_alive(id) && iFlags&LISTEN_DEAD && !is_user_alive(iPlayer)) {
					// If team message, echo only to dead team members
					if (equal(sCommand,"say_team") && get_user_team(id)==get_user_team(iPlayer)) {
						client_print(iPlayer,print_chat, "(TEAM) (ALIVE) %s :    %s",sName,sMessage)
					}
					// Else echo to all dead players
					else {
						client_print(iPlayer,print_chat, "(ALIVE) %s :    %s",sName,sMessage)
					}
				}
				// If speaker is dead, echo to alive players
				else if (!is_user_alive(id) && iFlags&LISTEN_ALIVE && is_user_alive(iPlayer)) {
					// If team message, echo only to alive team members
					if (equal(sCommand,"say_team") && get_user_team(id)==get_user_team(iPlayer)) {
						client_print(iPlayer,print_chat, "(TEAM) (DEAD) %s :    %s",sName,sMessage)
					}
					// Else echo to all alive players
					else {
						client_print(iPlayer,print_chat, "(DEAD) %s :    %s",sName,sMessage)
					}
				}
				// If admin and allowed to listen
				else if (get_user_flags(iPlayer)&ACCESS_LEVEL && iFlags&LISTEN_ADMIN) {
					client_print(iPlayer,print_chat,"(LISTEN) %s :    %s",sName,sMessage)
				}
			} // end if
		} // end for
	}
	return PLUGIN_CONTINUE
}

public get_listen_flags()
{
	new sFlags[24]
	get_cvar_string("amx_listen",sFlags,3)
	return read_flags(sFlags)
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Plugin Listen","1.0","mike_cao")
	register_clcmd("say","event_say")
	register_clcmd("say_team","event_say")
	register_cvar("amx_listen","abc")

	return PLUGIN_CONTINUE
}

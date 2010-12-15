/*
*	AMXMODX script.
*	(plugin_slash.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin allows admins to execute amx commands
*	using 'say' and a slash '/'. It can also execute
*	a command on all players or a team using '@all' and
*	'@team' in place of the authid/nick parameter.
*
*	Examples:
*	To kick a player type '/kick playername'
*	To kick all players type '/kick @all'
*	To kick all players on a team type '/kick @team:TEAMID'
*	To ban all players for 10 minutes, type '/ban 10 @all'
*
*	Additional Commands:
*	Includes an IRC style '/me' command. If you say
*	'/me sucks', it'll replace the '/me' with your name
*	and print it to everyone.
*
*/ 

#include <amxmodx>

#define MAX_NAME_LENGTH 32
#define MAX_TEXT_LENGTH 192
#define MAX_PLAYERS 32

public admin_slash(id)
{
	new sName[MAX_NAME_LENGTH+1]
	new sArg[MAX_NAME_LENGTH+1]
	read_argv(1,sArg,MAX_NAME_LENGTH)

	// Check for '/' char
	if ( sArg[0] == '/' ) {
		new sCommand[MAX_TEXT_LENGTH+1]
		new sMessage[MAX_TEXT_LENGTH+1]
		new sTemp[MAX_TEXT_LENGTH+1]

		// Get data
		read_args(sMessage,MAX_TEXT_LENGTH)
		remove_quotes(sMessage)
		replace(sMessage,MAX_TEXT_LENGTH,"/","")
		
		// For all players
		if ( containi(sMessage,"@all") != -1 ) {
			new iPlayers[MAX_PLAYERS], iNumPlayers
			get_players(iPlayers,iNumPlayers)
		
			for (new i = 0; i < iNumPlayers; i++) {
				get_user_name(iPlayers[i],sName,MAX_NAME_LENGTH)
				copy(sTemp,MAX_TEXT_LENGTH,sMessage)
				replace(sTemp,MAX_TEXT_LENGTH,"@all","^"@name^"")
				replace(sTemp,MAX_TEXT_LENGTH,"@name",sName)
				format(sCommand,MAX_TEXT_LENGTH,"amx_%s",sTemp)
				client_cmd(id,sCommand)
			}
			copyc(sCommand,MAX_NAME_LENGTH,sTemp,' ')
			client_print(id,print_chat,"[AMX] Command ^"%s^" executed on all players",sCommand)
		}
		// For a team
		else if ( containi(sMessage,"@team:") != -1 ) {
			new sTeam[MAX_NAME_LENGTH]
			new sRemove[MAX_TEXT_LENGTH]
			new sMod[MAX_NAME_LENGTH]

			// Get team
			copy(sTemp,MAX_TEXT_LENGTH,sMessage)
			copyc(sRemove,MAX_TEXT_LENGTH,sTemp,'@')
			replace(sTemp,MAX_TEXT_LENGTH,sRemove,"")
			copyc(sTeam,MAX_TEXT_LENGTH,sTemp,' ')
			
			if ( containi(sTeam,"@team:") != -1 ) {
				replace(sMessage,MAX_TEXT_LENGTH,sTeam,"^"@name^"")
				replace(sTeam,MAX_TEXT_LENGTH,"@team:","")

				// Get mod
				get_modname(sMod,MAX_NAME_LENGTH)
				
				// Shortcuts for Counter-strike
				if (equal(sMod,"cstrike")) {
					if ( equal(sTeam,"T") ) {
						copy(sTeam,MAX_NAME_LENGTH,"TERRORIST")
					}
					else if ( equal(sTeam,"S") ) {
						copy(sTeam,MAX_NAME_LENGTH,"SPECTATOR")
					}
				}
			}
			else {
				client_print(id,print_chat,"[AMX] Team identifier not recognized")
				return PLUGIN_HANDLED
			}
			
			new iPlayers[MAX_PLAYERS], iNumPlayers
			get_players(iPlayers,iNumPlayers,"e",sTeam)

			if ( iNumPlayers ) {
				for (new i = 0; i < iNumPlayers; i++) {
					get_user_name(iPlayers[i],sName,MAX_NAME_LENGTH)
					copy(sTemp,MAX_TEXT_LENGTH,sMessage)
					replace(sTemp,MAX_TEXT_LENGTH,"@name",sName)
					format(sCommand,MAX_TEXT_LENGTH,"amx_%s",sTemp)
					client_cmd(id,sCommand)
				}
				copyc(sCommand,MAX_NAME_LENGTH,sTemp,' ')
				client_print(id,print_chat,"[AMX] Command ^"%s^" executed on team ^"%s^"",sCommand,sTeam)
			}
			else {
				client_print(id,print_chat,"[AMX] There are no players on team ^"%s^"",sTeam)
			}
		}
		else {
			format(sCommand,MAX_TEXT_LENGTH,"amx_%s",sMessage)
			client_cmd(id,sCommand)
		}

		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public admin_me(id)
{
	new sName[MAX_NAME_LENGTH+1]
	new sMessage[MAX_TEXT_LENGTH+1]
	
	// Get data
	get_user_name(id,sName,MAX_NAME_LENGTH)
	read_args(sMessage,MAX_TEXT_LENGTH)
	remove_quotes(sMessage)

	// Display message only to same status players
	new bAlive = is_user_alive(id)
	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if(is_user_alive(i) == bAlive) {
			client_print(i,print_chat,"%s %s",sName,sMessage)
		}
	}
	return PLUGIN_HANDLED
}

public plugin_init()
{
	register_plugin("Plugin Slash","1.1","mike_cao")
	register_clcmd("say","admin_slash",0,"say /command < params >")
	register_clcmd("amx_me","admin_me",0,"amx_me < text >")
	return PLUGIN_CONTINUE
}

/*
*	AMXMOD script.
*	(plugin_glowdamage.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin makes players glow briefly when 
*	damaged. There are team-based glow colors
*	as well as different colors for the amount
*	of damage dealt.
*
*	Use the cvar "amx_glowdamage_mode" in your admin.cfg
*	0 = off
*	1 = default glow damage
*	2 = team-based glow damage
*
*/ 

#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

// Color between shots (1=on, 0=off)
#define INTERMEDIATE_GLOW 0

new gGlow
new gGlowState[MAX_PLAYERS+1]

public admin_glowdamage(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		client_print(id, print_console,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		client_print(id, print_console,"[AMX] Usage: amx_glowdamage < 0 | 1 | 2 > [0=off,1=on,2=team-based]")
		return PLUGIN_HANDLED
	}

	new sArg[MAX_NAME_LENGTH+1]
	read_argv(1,sArg,MAX_NAME_LENGTH)
	set_cvar_num("amx_glowdamage_mode",str_to_num(sArg))
	
	if ( equal(sArg,"0") ) {
		client_print(id,print_console,"[AMX] Glow damage is now off")
		msg_display("Glow Damage Disabled.",0,200,0)
	}
	else if ( equal(sArg,"1") ) {
		client_print(id,print_console,"[AMX] Glow damage is now on")
		msg_display("Glow Damage Enabled.",0,200,0)
	}
	else if ( equal(sArg,"2") ) {
		client_print(id,print_console,"[AMX] Team-based glow damage is now on")
		msg_display("Team-based Glow Damage Enabled.",0,200,0)
	}

	return PLUGIN_HANDLED
}

public msg_display(msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(0,msg)
}

public player_glow_on(player,r,g,b,size)
{
	new Params[1]
	Params[0] = player
	set_user_rendering(player,kRenderFxGlowShell,r,g,b,kRenderNormal,size)
	set_task(0.5,"player_glow_off",0,Params,1);
	return PLUGIN_CONTINUE
}

public player_glow_off(Params[])
{
	set_user_rendering(Params[0])
	return PLUGIN_CONTINUE
}

public event_glowdamage()
{	
	new iR, iG, iB, iSize, iColor, iState
	new iVictim = read_data(0)
	new iDamage = read_data(2)
	new sTeam[MAX_NAME_LENGTH+1]
	
	gGlow = get_cvar_num("amx_glowdamage_mode")

	get_user_team(iVictim,sTeam,MAX_NAME_LENGTH);
	iColor = INTERMEDIATE_GLOW

	if (iColor) {
		iState = gGlowState[iVictim]
		if(iState) {
			gGlowState[iVictim] = 0
		} else {
			gGlowState[iVictim] = 1
		}
	}
	
	if (gGlow > 0 && !iState) {
		// Heavy damage
		if (iDamage > 30) {
			iSize = 20
			// Team-based
			if (gGlow == 2) {
				// Team 1
				if ( equal(sTeam,"TERRORIST") ) {
					iR = 255
					iG = 0
					iB = 0
				}
				// Team 2
				else if ( equal(sTeam,"CT") ) {
					iR = 0
					iG = 192
					iB = 255
				}
				// Default
				else {
					iR = 255
					iG = 128
					iB = 0
				}
			}
			// Non team-based
			else {
				iR = 255
				iG = 128
				iB = 0
			}
		}
		// Medium damage
		else if (iDamage > 20) {
			iSize = 10
			// Team-based
			if (gGlow == 2) {
				// Team 1
				if ( equal(sTeam,"TERRORIST") ) {
					iR = 128
					iG = 0
					iB = 0
				}
				// Team 2
				else if ( equal(sTeam,"CT") ) {
					iR = 0
					iG = 128
					iB = 192
				}
				// Default
				else {
					iR = 255
					iG = 96
					iB = 0
				}
			}
			// Non team-based
			else {
				iR = 255
				iG = 96
				iB = 0
			}
		}
		// Low damage
		else if (iDamage > 10) {
			iSize = 0
			// Team-based
			if (gGlow == 2) {
				// Team 1
				if ( equal(sTeam,"TERRORIST") ) {
					iR = 64
					iG = 0
					iB = 0
				}
				// Team 2
				else if ( equal(sTeam,"CT") ) {
					iR = 0
					iG = 64
					iB = 128
				}
				// Default
				else {
					iR = 255
					iG = 64
					iB = 0
				}
			}
			// Non team-based
			else {
				iR = 255
				iG = 64
				iB = 0
			}
		}
	}
	// Intermediate color
	else if ( gGlow > 0 && iState ) {
		iR = 255
		iG = 255
		iB = 255
	}
	// Glow player
	if (gGlow) {
		player_glow_on(iVictim,iR,iG,iB,iSize)
	}
	return PLUGIN_CONTINUE;
}

public plugin_init()
{
	register_plugin("Glow Damage","1.0","mike_cao")
	register_clcmd("amx_glowdamage","admin_glowdamage",ACCESS_LEVEL,"amx_glowdamage < 0 | 1 | 2 >")
	register_event("Damage","event_glowdamage","b","2!0","3=0","4!0")
	register_cvar("amx_glowdamage_mode","1")
	return PLUGIN_CONTINUE
}

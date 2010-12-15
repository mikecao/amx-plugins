/*
*	AMXMODX script.
*	(plugin_freezetag.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Players freeze each other with their knives. Players
*	are unfrozen by their teammates. A team wins by freezing
*	all the players on the other team.
*/ 

#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

#define TE_SPRITETRAIL		15

#define SOUND_FREEZE	0
#define SOUND_GLASS1	1
#define SOUND_GLASS2	2
#define SOUND_GLASS3	3

#define MAX_SOUNDS	4

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

new gFreezeIndex[MAX_PLAYERS+1]
new gmsgStatusText
new gFF

// Sounds
new gSoundIndex[MAX_SOUNDS][MAX_NAME_LENGTH]

// Sprites
new spr_ct_spark
new spr_t_spark

public admin_freezetag(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_freezetag < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_freezetag_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Freeze Tag is now on.")
		msg_display("Freeze Tag is now on! :)",0,200,0)
		set_cvar_num("mp_friendlyfire",1)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Freeze Tag is now off.")
		msg_display("Freeze Tag is now off! :(",0,200,0)

		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers)
		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			player_unfreeze(iPlayer,0)
			set_user_health(iPlayer,100)
		}
		set_cvar_num("mp_friendlyfire",gFF)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_death()
{
	new iVictim = read_data(2)
	if (get_cvar_num("amx_freezetag_mode")) {
		player_unfreeze(iVictim,1)
	}
	return PLUGIN_CONTINUE
}

public event_weapon()
{
	new iPlayer = read_data(0)
	new iWeapon = read_data(2)
	if (get_cvar_num("amx_freezetag_mode") && iWeapon != CSW_C4) {
		engclient_cmd(iPlayer,"weapon_knife")
		if (gFreezeIndex[iPlayer]) {
			player_freeze(iPlayer)
		}
	}
	return PLUGIN_CONTINUE
}

public event_damage()
{
	if (get_cvar_num("amx_freezetag_mode")) {
		new iVictim = read_data(0)
		new iWeapon, iBody
		new iAttacker = get_user_attacker(iVictim,iWeapon,iBody)

		// Restore health
		set_user_health(iVictim,456)
		
		if (iVictim != iAttacker) {
			new sName[MAX_NAME_LENGTH]
			get_user_name(iAttacker,sName,MAX_NAME_LENGTH)
			
			new iTeamA = get_user_team(iAttacker)
			new iTeamV = get_user_team(iVictim)
			new iFreezeA = gFreezeIndex[iAttacker]
			new iFreezeV = gFreezeIndex[iVictim]

			// Freeze player
			if ((iFreezeA == 0) && (iFreezeV == 0) && (iTeamA != iTeamV)) {
				set_user_frags(iAttacker,get_user_frags(iAttacker)+1)
				player_freeze(iVictim)
				event_check_frozen(iVictim)

				set_hudmessage(0,200,0,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
				show_hudmessage(iVictim,"You were frozen by %s!",sName)
			}
			// Unfreeze player
			else if ((iFreezeA == 0) && (iFreezeV == 1) && (iTeamA == iTeamV)) {
				player_unfreeze(iVictim,1)

				set_hudmessage(0,200,0,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
				show_hudmessage(iVictim,"You were unfrozen by %s!",sName)
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public event_check_frozen(player)
{
	if (get_cvar_num("amx_freezetag_mode")) {
		new iCheck = 0
		new iPlayers[MAX_PLAYERS], iNumPlayers
		new sTeam[MAX_NAME_LENGTH]

		get_user_team(player,sTeam,MAX_NAME_LENGTH)
		get_players(iPlayers,iNumPlayers,"ae",sTeam)

		for (new i = 0; i < iNumPlayers; i++) {
			iCheck += gFreezeIndex[iPlayers[i]]
		}
		// All players on team frozen
		if (iCheck >= iNumPlayers) {
			for (new i = 0; i < iNumPlayers; i++) {
				user_kill(iPlayers[i],1)
			}
			new sMsg[MAX_TEXT_LENGTH]
			format(sMsg,MAX_TEXT_LENGTH,"The entire %s team was frozen!",sTeam)
			set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
			show_hudmessage(0,sMsg)
		}
	}
}

public event_round_draw()
{
	if (get_cvar_num("amx_freezetag_mode")) {
		new iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers,"a")
		for (new i = 0; i < iNumPlayers; i++) {
			if (gFreezeIndex[iPlayers[i]]) {
				gFreezeIndex[iPlayers[i]] = 0
				player_unfreeze(iPlayers[i],0)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public event_team_action()
{
	if (get_cvar_num("amx_freezetag_mode")) {
		new sTeam[MAX_NAME_LENGTH]
		new sAction[MAX_NAME_LENGTH]
		read_logargv(1,sTeam,MAX_NAME_LENGTH)
		read_logargv(3,sAction,MAX_NAME_LENGTH)

		if (equal(sTeam,"TERRORIST")) {
			if (equal(sAction,"Target_Bombed") || equal(sAction,"VIP_Assassinated")) {
				event_slay_team(2)
			}
		}
		else if (equal(sTeam,"CT")) {
			if (equal(sAction,"Bomb_Defused") || equal(sAction,"All_Hostages_Rescued")) {
				event_slay_team(1)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public event_slay_team(team)
{
	new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers,"a")
	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		if (get_user_team(iPlayer)==team) {
			if (!gFreezeIndex[iPlayer]) {
				player_freeze(iPlayer)
			}
			user_kill(iPlayer)
		}
	}
}

public event_respawn(id)
{
	if (get_cvar_num("amx_freezetag_mode")) {
		set_user_health(id,456)
		gFreezeIndex[id] = 0

		new sMsg[MAX_TEXT_LENGTH]
		format(sMsg,MAX_TEXT_LENGTH,"-= FREEZE TAG MOD =-^n^nFreeze all your opponents to win!^nUnfreeze your teammates with your knife!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,sMsg)
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

static player_freeze(player) {
	gFreezeIndex[player] = 1
	set_user_maxspeed(player,1.0)

	if (get_user_team(player)==1) {
		set_user_rendering(player,kRenderFxGlowShell,255,0,0,kRenderNormal,100)
	}
	else {
		set_user_rendering(player,kRenderFxGlowShell,0,100,255,kRenderNormal,100)
	}
	emit_sound(player,CHAN_AUTO,gSoundIndex[SOUND_FREEZE],VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	show_score()
}

static player_unfreeze(player,fx) {
	gFreezeIndex[player] = 0
	set_user_maxspeed(player)
	client_cmd(player,"slot2;")
	set_user_rendering(player)
	
	if (fx) {
		new iOrigin[3]
		get_user_origin(player,iOrigin)
		if (get_user_team(player)==1) {
			fx_sparks(iOrigin,spr_t_spark)
		}
		else {
			fx_sparks(iOrigin,spr_ct_spark)
		}
		emit_sound(player,CHAN_AUTO,gSoundIndex[random_num(1,3)],VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	}
	show_score()
}

/************************************************************
* HELPER FUNCTIONS
************************************************************/

public show_score()
{
	if (get_cvar_num("amx_freezetag_mode")) {
		new iNumT = 0
		new iNumCT = 0
		for (new i = 0; i < MAX_PLAYERS; i++) {
			if (is_user_alive(i) && gFreezeIndex[i]==0) {
				if (get_user_team(i)==1) {
					iNumT += 1
				}
				else if (get_user_team(i)==2) {
					iNumCT += 1
				}
			}
		}

		new sMsg[MAX_TEXT_LENGTH]
		format(sMsg,MAX_TEXT_LENGTH," FreezeTag: (CT remaining: %i) (T remaining: %i)",iNumCT,iNumT)
		message_begin(MSG_ALL,gmsgStatusText,{0,0,0})
		write_byte(0)
		write_string(sMsg)
		message_end()
	}
	return PLUGIN_CONTINUE
}

public msg_display(msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(0,msg)
}

static fx_sparks(origin[3],sprite) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(sprite)
	write_byte(50) // count
	write_byte(10) // life
	write_byte(1) // scale
	write_byte(50) // velocity
	write_byte(100) // randomness
	message_end()
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_precache()
{
	// Sounds
	copy(gSoundIndex[SOUND_FREEZE],MAX_NAME_LENGTH,"debris/beamstart8.wav")
	copy(gSoundIndex[SOUND_GLASS1],MAX_NAME_LENGTH,"debris/bustglass1.wav")
	copy(gSoundIndex[SOUND_GLASS2],MAX_NAME_LENGTH,"debris/bustglass2.wav")
	copy(gSoundIndex[SOUND_GLASS3],MAX_NAME_LENGTH,"debris/bustglass3.wav")
	
	for (new i = 0; i < MAX_SOUNDS; i++) {
		precache_sound(gSoundIndex[i])
	}
			
	// Sprites
	spr_ct_spark = precache_model("sprites/XSpark1.spr")
	spr_t_spark = precache_model("sprites/Gwave1.spr")

	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Freeze Tag","1.0","mike_cao")
	register_clcmd("amx_freezetag","admin_freezetag",ACCESS_LEVEL,"amx_freezetag < 0 | 1 >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_cvar("amx_freezetag_mode","0")
	register_event("CurWeapon","event_weapon","be","1=1")
	register_event("Damage","event_damage","b","2!0","3=0","4!0")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_event("DeathMsg","event_death","a")
	register_event("SendAudio","event_round_draw","a","2&%!MRAD_rounddraw")
	register_logevent("event_team_action",6,"2=triggered")
	
	gmsgStatusText = get_user_msgid("StatusText")
	gFF = get_cvar_num("mp_friendlyfire")
	set_task(1.0,"show_score",0,"",0,"b")

	return PLUGIN_CONTINUE
}

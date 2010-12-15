/*
*	AMXMODX script.
*	(plugin_stealthwar.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Makes the winning team invisible. Invisible
*	players can only use knives.
*
*/

#include <amxmodx>
#include <fun>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512
#define MAX_SOUNDS 2

#define	TE_SMOKE		5

#define SOUND_FLASH1	0
#define SOUND_FLASH2	1

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

new gStealthTeam = 0
new gmsgStatusText

// Sprites
new spr_smoke

// Sounds
new gSoundIndex[MAX_SOUNDS][MAX_NAME_LENGTH]

public admin_stealthwar(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_stealthwar < 1 | 0 >")
		return PLUGIN_HANDLED
	}
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	set_cvar_num("amx_stealthwar_mode",str_to_num(sArg1))
	if (equal(sArg1,"1")) {
		client_print(id,print_console,"[AMX] Stealth War is now on.")
		msg_display("Stealth War is now on! :)",0,200,0)
	}
	else if (equal(sArg1,"0")) {
		client_print(id,print_console,"[AMX] Stealth War is now off.")
		msg_display("Stealth War is now off! :(",0,200,0)
		gStealthTeam = 0
		event_reset()
	}
	return PLUGIN_HANDLED
}

public msg_display(msg[],r,g,b)
{
	set_hudmessage(r,g,b,0.05,0.65,2,0.02,10.0,0.01,0.1,2)
	show_hudmessage(0,msg)
}



/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_stealth()
{
	new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
	new sName[MAX_NAME_LENGTH]
	new iOrigin[3]
	get_players(iPlayers,iNumPlayers)

	for (new i = 0; i < iNumPlayers; i++) {
		iPlayer = iPlayers[i]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (get_user_team(iPlayer)==gStealthTeam) {
			set_user_rendering(iPlayer,kRenderFxNone,0,0,0,kRenderTransAlpha,0)
			engclient_cmd(iPlayer,"weapon_knife")
			get_user_origin(iPlayer,iOrigin)
			fx_stealth(iOrigin)
			emit_sound(iPlayer,CHAN_AUTO,gSoundIndex[random_num(0,1)],VOL_NORM,ATTN_NORM,0,PITCH_NORM)
		}
	}
}

public event_reset()
{
	new iPlayers[MAX_PLAYERS], iNumPlayers
	get_players(iPlayers,iNumPlayers)
	for (new i = 0; i < iNumPlayers; i++) {
		set_user_rendering(iPlayers[i])
	}
}

public event_respawn(id)
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		new sTeam[MAX_TEXT_LENGTH]
		if (gStealthTeam==1) {
			copy(sTeam,MAX_NAME_LENGTH,"TERRORIST")
		}
		else if (gStealthTeam==2){
			copy(sTeam,MAX_NAME_LENGTH,"COUNTER-TERRORIST")
		}
		format(sMsg,MAX_TEXT_LENGTH,"-= STEALTH WARS MOD =-^n^nThe %s team is invisible and armed with knives!",sTeam)
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,10.0,0.5,0.15,1)
		show_hudmessage(id,sMsg)
	}
	return PLUGIN_CONTINUE
}

public event_round_t()
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		gStealthTeam = 1
		format(sMsg,MAX_TEXT_LENGTH,"The TERRORIST team won invisible powers!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
		show_hudmessage(0,sMsg)
		set_task(4.0,"event_reset",0,"")
		set_task(6.0,"event_stealth",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_round_ct()
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		gStealthTeam = 2
		format(sMsg,MAX_TEXT_LENGTH,"The COUNTER-TERRORIST team won invisible powers!")
		set_hudmessage(0,255,0,-1.0,0.25,0,6.0,6.0,0.5,0.15,1)
		show_hudmessage(0,sMsg)
		set_task(4.0,"event_reset",0,"")
		set_task(6.0,"event_stealth",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_round_draw()
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		gStealthTeam = random_num(1,2)
		set_task(4.0,"event_reset",0,"")
		set_task(6.0,"event_stealth",0,"")
	}
	return PLUGIN_CONTINUE
}

public event_weapon()
{
	new iPlayer = read_data(0)
	new iWeapon = read_data(2)
	if (get_cvar_num("amx_stealthwar_mode") && get_user_team(iPlayer)==gStealthTeam && iWeapon != CSW_C4) {
		engclient_cmd(iPlayer,"weapon_knife")
	}
	return PLUGIN_CONTINUE
}

public event_death()
{
	new iVictim = read_data(2)
	if (get_cvar_num("amx_stealthwar_mode") && get_user_team(iVictim)==gStealthTeam) {
		set_user_rendering(iVictim)
	}
	return PLUGIN_CONTINUE
}

public event_damage()
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		new iVictim = read_data(0)
		new iDamage = read_data(2)
		if (get_user_team(iVictim)==gStealthTeam) {
			if (get_user_health(iVictim) > 0) {
				// Heavy damage
				if (iDamage > 30) {
					player_vis_on(iVictim,192)
				}
				// Medium damage
				else if (iDamage > 15) {
					player_vis_on(iVictim,128)
				}
				// Low damage
				else {
					player_vis_on(iVictim,64)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public event_msg()
{
	if (get_cvar_num("amx_stealthwar_mode")) {
		new sMsg[MAX_TEXT_LENGTH]
		format(sMsg,MAX_TEXT_LENGTH,"Stealth Wars Mod")
		message_begin(MSG_ALL,gmsgStatusText,{0,0,0})
		write_byte(0)
		write_string(sMsg)
		message_end()
	}
	return PLUGIN_HANDLED
}

public fx_stealth(origin[3]) {
	// Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_smoke)
	write_byte(20) // scale
	write_byte(20) // framerate
	message_end()
}

/************************************************************
* PLAYER FUNCTIONS
************************************************************/

public player_vis_on(player,amount)
{
	new Params[1]
	Params[0] = player
	set_user_rendering(player,kRenderFxNone,0,0,0,kRenderTransAlpha,amount)
	set_task(1.0,"player_vis_off",0,Params,1);
	return PLUGIN_CONTINUE
}

public player_vis_off(Params[])
{
	set_user_rendering(Params[0],kRenderFxNone,0,0,0,kRenderTransAlpha,0)
	return PLUGIN_CONTINUE
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_precache()
{
	copy(gSoundIndex[SOUND_FLASH1],MAX_NAME_LENGTH,"weapons/flashbang-1.wav")
	copy(gSoundIndex[SOUND_FLASH2],MAX_NAME_LENGTH,"weapons/flashbang-2.wav")

	for (new i = 0; i < MAX_SOUNDS; i++) {
		precache_sound(gSoundIndex[i])
	}

	spr_smoke = precache_model("sprites/steam1.spr")
}

public plugin_init()
{
	register_plugin("Stealth War","1.0","mike_cao")
	register_clcmd("amx_stealthwar","admin_stealthwar",ACCESS_LEVEL,"amx_ka < 0 | 1 >")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_cvar("amx_stealthwar_mode","0")
	register_event("SendAudio","event_round_t","a","2&%!MRAD_terwin")
	register_event("SendAudio","event_round_ct","a","2&%!MRAD_ctwin")
	register_event("SendAudio","event_round_draw","a","2&%!MRAD_rounddraw")
	register_event("CurWeapon","event_weapon","be","1=1")
	register_event("DeathMsg","event_death","a")
	register_event("Damage","event_damage","b","2!0","3=0","4!0")

	gmsgStatusText = get_user_msgid("StatusText")
	set_task(0.5,"event_msg",0,"",0,"b")
	
	return PLUGIN_CONTINUE
}

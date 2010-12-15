/*
*	AMXMOD script.
*	(plugin_csevents.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin does a centersay announcement
*	for events in counter-strike. Event are configured
*	with the cvar "amx_csevents" using these flags:
*
*	a - Bomb exploded
*	b - Bomb planted
*	c - Bomb defused
*	d - Bomb being planted
*	e - Bomb being defused
*	f - Player spawned with bomb
*	g - Player picked up bomb
*	h - Player dropped bomb
*	i - Audio bomb countdown
*	j - Hostage touched
*	k - Hostage rescued
*	l - Hostage killed (with punishment)
*	m - Headshots (multiple messages)
*	n - Knife kills (multiple messages)
*	o - Grenade kills (multiple messages)
*	p - Grenade suicides
*	q - Player spawned as VIP
*	r - VIP killed
*	s - VIP escaped
*	t - VIP failed to escape
*	u - First kill (bonus health/money)
*	v - Killstreak
*
*/
#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_VAR_LENGTH 64
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

#define EVENT_BOMB_EXPLODE		(1<<0) // "a"
#define EVENT_BOMB_PLANTED 		(1<<1) // "b"
#define EVENT_BOMB_DEFUSED 		(1<<2) // "c"
#define EVENT_BOMB_PLANTING 	(1<<3) // "d"
#define EVENT_BOMB_DEFUSING 	(1<<4) // "e"
#define EVENT_BOMB_SPAWN 		(1<<5) // "f"
#define EVENT_BOMB_PICKUP	 	(1<<6) // "g"
#define EVENT_BOMB_DROPPED 		(1<<7) // "h"
#define EVENT_BOMB_COUNT 		(1<<8) // "i"
#define EVENT_HOSTAGE_TOUCHED	(1<<9) // "j"
#define EVENT_HOSTAGE_RESCUED	(1<<10) // "k"
#define EVENT_HOSTAGE_KILLED	(1<<11) // "l"
#define EVENT_HEADSHOT			(1<<12) // "m"
#define EVENT_KNIFE				(1<<13) // "n"
#define EVENT_HE_KILL			(1<<14) // "o"
#define EVENT_HESUICIDE			(1<<15) // "p"
#define EVENT_VIP_SPAWN			(1<<16) // "q"
#define EVENT_VIP_KILLED		(1<<17) // "r"
#define EVENT_VIP_ESCAPED		(1<<18) // "s"
#define EVENT_VIP_FAILED		(1<<19) // "t"
#define EVENT_FIRST_KILL		(1<<20) // "u"
#define EVENT_KILLSTREAK		(1<<21) // "v"

#define EVENT_MSG_ALL	0
#define EVENT_MSG_T		1
#define EVENT_MSG_CT	2

/************************************************************
* CONFIG
************************************************************/

// Number of hostages killed before punishment
#define DEFAULT_HOSTAGE_KILLS		2

// First kill gets a bonus (0=off,1=money,2=health,3=random)
#define DEFAULT_FIRST_KILL_BONUS	3

// Bonus money for a first kill
#define DEFAULT_FIRST_KILL_MONEY	1000

// Bonus health for a first kill
#define DEFAULT_FIRST_KILL_HEALTH	50

// Makes certain messages displayed to team only (1=yes,0=no)
new gTeamMsg = 1

// Text for headshot messages
// You have to adjust the index number if you change
// the number of messages
new gHeadshotIndex = 3
new gHeadshotText[3][] = {
	"got popped in the head by",
	"was headshot by",
	"lost his head from"
}

// Text for knife kill messages
// You have to adjust the index number if you change
// the number of messages
new gKnifeIndex = 3
new gKnifeText[3][] = {
	"got owned by",
	"was sliced and diced by",
	"got shanked by"
}

// Text for grenade kill messages
// You have to adjust the index number if you change
// the number of messages
new gGrenadeIndex = 4
new gGrenadeText[4][] = {
	"got blown to bits by",
	"felt the heat of",
	"was burned by",
	"got toasted by"
}

/************************************************************
* MAIN
************************************************************/

new gPlanter, gVIP, gBombTimer, gFirstKill, gDefuser
new gHostageIndex[MAX_PLAYERS+1]
new gKillIndex[MAX_PLAYERS+1]

/************************************************************
* EVENT FUNCTIONS
************************************************************/

// Player Events
public event_player_action()
{
	new sArg[MAX_VAR_LENGTH], sAction[MAX_VAR_LENGTH]
	new sName[MAX_NAME_LENGTH]
	new sMsg[MAX_TEXT_LENGTH]
	new iPlayer, iUserId
	new iFlags = get_event_flags()
	
	read_logargv(0,sArg,MAX_VAR_LENGTH)
	read_logargv(2,sAction,MAX_VAR_LENGTH)
	parse_loguser(sArg,sName,MAX_NAME_LENGTH,iUserId)
	iPlayer = find_player("k",iUserId)

	if (iPlayer) {
		// Bomb planted
		if (equal(sAction,"Planted_The_Bomb")) {
			if (iFlags&EVENT_BOMB_PLANTED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s planted the bomb!",sName)
				display_msg(sMsg,255,0,0,EVENT_MSG_ALL)
				if (iFlags&EVENT_BOMB_COUNT) {
					gBombTimer = get_cvar_num("mp_c4timer")
					set_task(1.0,"event_bomb_count",80,"",0,"b")
				}
			}
		}
		// Bomb defused
		else if (equal(sAction,"Defused_The_Bomb")) {
			if (iFlags&EVENT_BOMB_DEFUSED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s defused the bomb with %i seconds left!",sName,gBombTimer)
				display_msg(sMsg,0,100,255,EVENT_MSG_ALL)
			}
		}
		// Bomb defusing with a kit
		else if (equal(sAction,"Begin_Bomb_Defuse_With_Kit")) {
			if (iFlags&EVENT_BOMB_DEFUSING) {
				format(sMsg,MAX_TEXT_LENGTH,"%s is defusing the bomb with a kit...",sName)
				display_msg(sMsg,0,100,255,EVENT_MSG_CT)
			}
			gDefuser = iPlayer
		}
		// Bomb defusing without a kit
		else if (equal(sAction,"Begin_Bomb_Defuse_Without_Kit")) {
			if (iFlags&EVENT_BOMB_DEFUSING) {
				format(sMsg,MAX_TEXT_LENGTH,"%s is defusing the bomb with his bare hands...",sName)
				display_msg(sMsg,0,100,255,EVENT_MSG_CT)
			}
			gDefuser = iPlayer
		}
		// Spawned with the bomb
		else if (equal(sAction,"Spawned_With_The_Bomb")) {
			if (iFlags&EVENT_BOMB_SPAWN) {
				format(sMsg,MAX_TEXT_LENGTH,"%s has the bomb!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_ALL)
			}
			gPlanter = iPlayer
		}
		// Dropped bomb
		else if (equal(sAction,"Dropped_The_Bomb")) {
			if (iFlags&EVENT_BOMB_DROPPED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s dropped the bomb!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_T)
			}
		}
		// Picked up bomb
		else if (equal(sAction,"Got_The_Bomb")) {
			if (iFlags&EVENT_BOMB_PICKUP) {
				format(sMsg,MAX_TEXT_LENGTH,"%s picked up the bomb!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_T)
			}
			gPlanter = iPlayer
		}
		// Hostage touched
		else if (equal(sAction,"Touched_A_Hostage")) {
			if (iFlags&EVENT_HOSTAGE_TOUCHED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s found a hostage!",sName)
				display_msg(sMsg,0,50,128,EVENT_MSG_CT)
			}
		}
		// Hostage rescued
		else if (equal(sAction,"Rescued_A_Hostage")) {
			if (iFlags&EVENT_HOSTAGE_RESCUED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s rescued a hostage!",sName)
				display_msg(sMsg,0,100,255,EVENT_MSG_ALL)
			}
		}
		// Hostage killed
		else if (equal(sAction,"Killed_A_Hostage")) {
			if (iFlags&EVENT_HOSTAGE_KILLED) {
				gHostageIndex[iPlayer] += 1
				if (gHostageIndex[iPlayer] >= DEFAULT_HOSTAGE_KILLS) {
					user_kill(iPlayer,1)
					format(sMsg,MAX_TEXT_LENGTH,"%s was punished for killing hostages!",sName)
					display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
				
				}
				else {
					format(sMsg,MAX_TEXT_LENGTH,"%s killed a hostage!",sName)
					display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
				}
			}
		}
		// VIP spawn
		else if (equal(sAction,"Became_VIP")) {
			if (iFlags&EVENT_VIP_SPAWN) {
				format(sMsg,MAX_TEXT_LENGTH,"%s has become the VIP!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_ALL)
			}
			gVIP = iPlayer
		}
		// VIP assassinated
		else if (equal(sAction,"Assassinated_The_VIP")) {
			if (iFlags&EVENT_VIP_KILLED) {
				new sNameVIP[MAX_NAME_LENGTH]
				get_user_name(gVIP,sNameVIP,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"%s assassinated %s the VIP!",sName,sNameVIP)
				display_msg(sMsg,255,0,0,EVENT_MSG_ALL)
			}
		}
		// VIP escaped
		else if (equal(sAction,"Escaped_As_VIP")) {
			if (iFlags&EVENT_VIP_ESCAPED) {
				format(sMsg,MAX_TEXT_LENGTH,"%s the VIP has escaped!",sName)
				display_msg(sMsg,0,100,255,EVENT_MSG_ALL)
			}
		}
	}
	return PLUGIN_CONTINUE
}

// Bomb planting
public event_bomb_planting(id)
{
	new sName[MAX_NAME_LENGTH]
	new sMsg[MAX_TEXT_LENGTH]
	new iFlags = get_event_flags()
	if (read_data(1) == 3 && gPlanter) {
		if (iFlags&EVENT_BOMB_PLANTING) {
			get_user_name(gPlanter,sName,MAX_NAME_LENGTH)
			format(sMsg,MAX_TEXT_LENGTH,"%s is planting the bomb...",sName)
			display_msg(sMsg,255,0,0,EVENT_MSG_T)
		}
	}
	return PLUGIN_CONTINUE
}

// Bomb counter
public event_bomb_count()
{
	new iFlags = get_event_flags()
	gBombTimer -= 1
	if (gBombTimer > 0) {
		if (iFlags&EVENT_BOMB_COUNT) {
			new sSound[MAX_VAR_LENGTH]
			if (gBombTimer == 30 || gBombTimer == 20) {
				num_to_word(gBombTimer,sSound,MAX_VAR_LENGTH)
				client_cmd(0,"spk ^"vox/%s seconds until explosion^"",sSound)
			}
			else if (gBombTimer < 11) {
				num_to_word(gBombTimer,sSound,MAX_VAR_LENGTH)
				client_cmd(0,"spk ^"vox/%s^"",sSound)
			}
		}
	}
	else {
		remove_task(80)
	}
	return PLUGIN_CONTINUE
}

// Death events
public event_death()
{
	new iFlags = get_event_flags()
	new iKiller = read_data(1)
	new iVictim = read_data(2)
	new iHeadshot = read_data(3)
	new sMsg[MAX_TEXT_LENGTH]
	new sWeapon[MAX_NAME_LENGTH]
	new sNameKiller[MAX_NAME_LENGTH], sNameVictim[MAX_NAME_LENGTH]

	read_data(4,sWeapon,MAX_NAME_LENGTH)
	get_user_name(iKiller,sNameKiller,MAX_NAME_LENGTH)
	get_user_name(iVictim,sNameVictim,MAX_NAME_LENGTH)
	
	if (iKiller > 0 && iVictim > 0 && iKiller != iVictim) {
		// First kill
		if (iFlags&EVENT_FIRST_KILL && !gFirstKill && (get_user_team(iKiller) != get_user_team(iVictim))) {
			new iMode = DEFAULT_FIRST_KILL_BONUS
			if (iMode > 0) {
				new iNum = DEFAULT_FIRST_KILL_BONUS
				if (iNum == 3) {
					iNum = random_num(1,2)
				}
				if (iNum == 1) {
					format(sMsg,MAX_TEXT_LENGTH,"%s got the first kill! ($%i)",sNameKiller,DEFAULT_FIRST_KILL_MONEY)
					new iMoney = get_user_money(iKiller)+DEFAULT_FIRST_KILL_MONEY
					if (iMoney > 16000) iMoney = 16000
					set_user_money(iKiller,iMoney)
				}
				else if (iNum == 2) {
					format(sMsg,MAX_TEXT_LENGTH,"%s got the first kill! (+%i HP)",sNameKiller,DEFAULT_FIRST_KILL_HEALTH)
					set_user_health(iKiller,get_user_health(iKiller)+DEFAULT_FIRST_KILL_HEALTH)
				}
			}
			else {
				format(sMsg,MAX_TEXT_LENGTH,"%s got the first kill!",sNameKiller)
			}
			gFirstKill = 1
			display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
		}
		// Headshot
		if (iFlags&EVENT_HEADSHOT && iHeadshot) {
			format(sMsg,MAX_TEXT_LENGTH,"%s %s %s^'s bullet!",sNameVictim,gHeadshotText[random_num(0,gHeadshotIndex-1)],sNameKiller)
			display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
		}
		// Grenade kills
		if (iFlags&EVENT_HE_KILL && equal(sWeapon,"grenade")) {
			format(sMsg,MAX_TEXT_LENGTH,"%s %s %s^'s grenade!",sNameVictim,gGrenadeText[random_num(0,gGrenadeIndex-1)],sNameKiller)
			display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
		}
		// Knife kills
		if (iFlags&EVENT_KNIFE && equal(sWeapon,"knife")) {
			format(sMsg,MAX_TEXT_LENGTH,"%s %s %s^'s knife!",sNameVictim,gKnifeText[random_num(0,gKnifeIndex-1)],sNameKiller)
			display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
		}

		// Killstreak
		if (iFlags&EVENT_KILLSTREAK) {
			gKillIndex[iKiller] += 1
			gKillIndex[iVictim] = 0
			if (gKillIndex[iKiller] == 3) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got %i kills in a row!",sNameKiller,gKillIndex[iKiller])
				display_msg(sMsg,200,200,200,EVENT_MSG_ALL)
			}
			else if (gKillIndex[iKiller] == 10) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got %i kills in a row!",sNameKiller,gKillIndex[iKiller])
				display_msg(sMsg,255,200,100,EVENT_MSG_ALL)
			}
			else if (gKillIndex[iKiller] == 20) {
				format(sMsg,MAX_TEXT_LENGTH,"%s got %i kills in a row!",sNameKiller,gKillIndex[iKiller])
				display_msg(sMsg,255,175,0,EVENT_MSG_ALL)
			}
		}
	}
	else {
		// HE Suicide
		if (iFlags&EVENT_HESUICIDE && equal(sWeapon,"grenade")) {
			format(sMsg,MAX_TEXT_LENGTH,"%s got owned by his own grenade!",sNameVictim)
			display_msg(sMsg,200,200,200,EVENT_MSG_ALL)
		}
	}
	return PLUGIN_CONTINUE
}

// Team events
public event_team_action()
{
	new sName[MAX_NAME_LENGTH]
	new sTeam[MAX_NAME_LENGTH], sAction[MAX_NAME_LENGTH]
	new sMsg[MAX_TEXT_LENGTH]
	new iFlags = get_event_flags()

	read_logargv(1,sTeam,MAX_VAR_LENGTH)
	read_logargv(3,sAction,MAX_VAR_LENGTH)

	if (equal(sTeam,"TERRORIST")) {
		if (equal(sAction,"Target_Bombed")) {
			if (iFlags&EVENT_BOMB_EXPLODE && gPlanter > 0) {
				get_user_name(gPlanter,sName,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"%s^'s bomb exploded!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_ALL)
				remove_task(80)

				if (gDefuser) {
					get_user_name(gDefuser,sName,MAX_NAME_LENGTH)
					format(sMsg,MAX_TEXT_LENGTH,"%s failed to defuse the bomb!",sName)
					display_msg_sub(sMsg,0,200,0,EVENT_MSG_ALL)
				}
			}
		}
		else if (equal(sAction,"VIP_Assassinated")) {
			// Nothing
		}
	}
	else if (equal(sTeam,"CT")) {
		if (equal(sAction,"VIP_Not_Escaped")) {
			if (iFlags&EVENT_VIP_FAILED && gVIP > 0) {
				get_user_name(gVIP,sName,MAX_NAME_LENGTH)
				format(sMsg,MAX_TEXT_LENGTH,"%s the VIP failed to escape!",sName)
				display_msg(sMsg,0,200,0,EVENT_MSG_ALL)
			}
		}
		else if (equal(sAction,"Bomb_Defused")) {
			// Nothing
		}
		else if (equal(sAction,"Hostages_Not_Rescued")) {
			// Nothing
		}
		else if (equal(sAction,"All_Hostages_Rescued")) {
			// Nothing
		}
	}
	return PLUGIN_CONTINUE
}

// World events
public event_world_action()
{
	new sAction[MAX_NAME_LENGTH]
	read_logargv(1,sAction,MAX_VAR_LENGTH)
	
	if (equal(sAction,"Round_Start")) {
		gBombTimer = 0
		gFirstKill = 0
	}
	else if (equal(sAction,"Round_End")) {
		gBombTimer = 0
		gPlanter = 0
		gVIP = 0
		gDefuser = 0
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* HELPER FUNCTIONS
************************************************************/

public display_msg(msg[],r,g,b,team)
{
	set_hudmessage(r,g,b,-1.0,0.30,0,6.0,6.0,0.5,0.15,1)
	if (team > 0 && gTeamMsg == 1) {
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers,"a")
		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			if (get_user_team(iPlayer)==team) {
				show_hudmessage(iPlayer,msg)
			}
		}
	}
	else {
		show_hudmessage(0,msg)
	}
}

public display_msg_sub(msg[],r,g,b,team)
{
	set_hudmessage(r,g,b,-1.0,0.35,0,6.0,6.0,0.5,0.15,2)
	if (team > 0 && gTeamMsg == 1) {
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers,"a")
		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			if (get_user_team(iPlayer)==team) {
				show_hudmessage(iPlayer,msg)
			}
		}
	}
	else {
		show_hudmessage(0,msg)
	}
}

public get_event_flags()
{
	new sFlags[24]
	get_cvar_string("amx_csevents",sFlags,24)
	return read_flags(sFlags)
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public client_connect(id)
{
	gKillIndex[id] = 0
	gHostageIndex[id] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	gKillIndex[id] = 0
	gHostageIndex[id] = 0	
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Plugin CS Events","1.1","mike_cao")
	
	// General events
	register_event("DeathMsg","event_death","a")
	register_event("BarTime","event_bomb_planting","be","1=3")
	
	// Log events
	register_logevent("event_player_action",3,"1=triggered")
	register_logevent("event_team_action",6,"2=triggered")
	register_logevent("event_world_action",2,"0=World triggered")
	
	// Cvars
	register_cvar("amx_csevents","abcdefghijklmnopqrstuv")
}
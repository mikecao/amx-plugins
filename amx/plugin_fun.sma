/*
*	AMXMOD script.
*	(plugin_fun.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Provides admin commands for all fun functions.
*	
*	amx_godmode - gives player gomode
*	amx_noclip - gives player noclip
*	amx_frags - changes player frags
*	amx_armor - changes player armor
*	amx_health - changes player health
*	amx_maxspeed - changes player maxspeed
*	amx_gravity - changes player gravity
*	amx_money - changes player money
*	amx_weapon - gives player weapons
*	amx_tp - teleports a player to a coordinate
*	amx_tpsave - saves a coordinate for teleporting
*	amx_nohead - turns off headshots for a player
*	amx_glow - makes a player glow
*
*/

#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

#define MAX_MONEY	999999

/************************************************************
* CONFIG
************************************************************/

// Admin access level
#define ACCESS_LEVEL ADMIN_LEVEL_A

/************************************************************
* MAIN
************************************************************/

// Globals
new Float:gMaxspeedIndex[MAX_PLAYERS+1]
new gMoneyIndex[MAX_PLAYERS+1][2]	// real money, fake money
new gTeleportIndex[3]

// GODMODE
public admin_godmode(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_godmode < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer)	{
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			set_user_godmode(iPlayer,1)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" now has godmode.",sName)
			console_print(id,sMsg)
		}
		else {
			set_user_godmode(iPlayer,0)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" no longer has godmode.",sName)
			console_print(id,sMsg)
		}
	}
	return PLUGIN_HANDLED
}

// NO CLIP
public admin_noclip(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_noclip < authid | part of nick > < on | off >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer)	{
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			set_user_noclip(iPlayer,1)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" now has noclip.",sName)
			console_print(id,sMsg)
		}
		else {
			set_user_noclip(iPlayer,0)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" no longer has noclip.",sName)
			console_print(id,sMsg)
		}
	}
	return PLUGIN_HANDLED
}

// FRAGS
public admin_frags(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_frags < authid | part of nick > < frags >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer)	{
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_frags(iPlayer,str_to_num(sArg2))
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s frags set to %i.",sName,str_to_num(sArg2))
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// ARMOR
public admin_armor(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_armor < authid | part of nick > < armor >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer)	{
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_armor(iPlayer,str_to_num(sArg2))
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s armor set to %i.",sName,str_to_num(sArg2))
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// HEALTH
public admin_health(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_health < authid | part of nick > < health >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer)	{
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_health(iPlayer,str_to_num(sArg2))
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s health set to %i.",sName,str_to_num(sArg2))
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// MAXSPEED
public admin_maxspeed(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_maxspeed < authid | part of nick > < maxspeed >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		gMaxspeedIndex[iPlayer] = floatstr(sArg2)
		set_user_maxspeed(iPlayer,gMaxspeedIndex[iPlayer])
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s maxspeed set to %i.",sName,str_to_num(sArg2))
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// GRAVITY
public admin_gravity(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_gravity < authid | part of nick > < gravity >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_gravity(iPlayer,floatstr(sArg2))
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s gravity set to %i.",sName,str_to_num(sArg2))
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// GLOW
public admin_glow(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 6) {
		console_print(id,"[AMX] Usage: amx_glow < authid | part of nick > < r > < g > < b > < size >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	new sArg3[MAX_NAME_LENGTH]
	new sArg4[MAX_NAME_LENGTH]
	new sArg5[MAX_NAME_LENGTH]		
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	read_argv(3,sArg3,MAX_NAME_LENGTH)
	read_argv(4,sArg4,MAX_NAME_LENGTH)
	read_argv(5,sArg5,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)		
		fx_glow(iPlayer,str_to_num(sArg2),str_to_num(sArg3),str_to_num(sArg4),str_to_num(sArg5))
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is now glowing.",sName)
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// TELEPORT
public admin_tp(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_tp < authid | part of nick > [x] [y] [z]")
		return PLUGIN_HANDLED
	}
	
	// Find target player
	new sArg1[MAX_NAME_LENGTH+1]
	read_argv(1,sArg1,MAX_NAME_LENGTH)

	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (!is_user_alive(iPlayer)) {
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is dead",sName)
			console_print(id,sMsg)
			return PLUGIN_HANDLED
        }
		// Teleport to specified coordinates
		if (read_argc() == 5) {
			new iOrigin[3]
			new sArg2[1], sArg3[1], sArg4[1]
			read_argv(2,sArg2,MAX_NAME_LENGTH)
			read_argv(3,sArg3,MAX_NAME_LENGTH)
			read_argv(4,sArg4,MAX_NAME_LENGTH)
			iOrigin[0] = str_to_num(sArg2)
			iOrigin[1] = str_to_num(sArg3)
			iOrigin[2] = str_to_num(sArg4)
			set_user_origin(iPlayer,iOrigin)
		}
		// Teleport to saved coordinates
		else {
			new iOrigin[3]
			iOrigin[0] = gTeleportIndex[0]
			iOrigin[1] = gTeleportIndex[1]
			iOrigin[2] = gTeleportIndex[2]
			set_user_origin(iPlayer,iOrigin)
		}
		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" was teleported.",sName)
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// TELEPORT SAVE
public admin_tpsave(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_tpsave < authid | part of nick > [x] [y] [z]")
		return PLUGIN_HANDLED
	}

	// Save specified coordinates
	if (read_argc() == 5) {
		new sArg2[1], sArg3[1], sArg4[1]
		read_argv(2,sArg2,MAX_NAME_LENGTH)
		read_argv(3,sArg3,MAX_NAME_LENGTH)
		read_argv(4,sArg4,MAX_NAME_LENGTH)
		gTeleportIndex[0] = str_to_num(sArg2)
		gTeleportIndex[1] = str_to_num(sArg3)
		gTeleportIndex[2] = str_to_num(sArg4)
	}
	// Save current position coordinates
	else {
		get_user_origin(id,gTeleportIndex)
	}
	console_print(id,"[AMX] Coordinates (%i,%i,%i) saved.",gTeleportIndex[0],gTeleportIndex[1],gTeleportIndex[2])

	return PLUGIN_HANDLED
}

// MONEY
public admin_money(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[AMX] Usage: amx_money < authid | part of nick > < money >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		new iMoney = str_to_num(sArg2)
		if (iMoney > MAX_MONEY) iMoney = MAX_MONEY
		gMoneyIndex[iPlayer][0] = get_user_money(iPlayer)
		gMoneyIndex[iPlayer][1] = iMoney

		if (iMoney > 16000) {
			set_user_money(iPlayer,10000,0)
		}
		else {
			set_user_money(iPlayer,iMoney,0)
		}
		player_money(iPlayer,gMoneyIndex[id][1],1)

		format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^"'s money set to %i.",sName,iMoney)
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

// WEAPON
public admin_weapon(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 4) {
		console_print(id,"[AMX] Usage: amx_weapon < authid | part of nick > < weapon group > < weapon id >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	new sArg3[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	read_argv(3,sArg3,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new iGroup = str_to_num(sArg2)
		new iWeapon = str_to_num(sArg3)
		
		// All weapons
		if (iGroup == 0 && iWeapon == 0) {
			for (new i = 0; i < 5; i++) {
				server_cmd("amx_weapon ^"%s^" %i 0",sArg1,i+1)
			}
			server_cmd("amx_weapon ^"%s^" 8 0",sArg1)
		}
		// Pistols
		else if (iGroup == 1) {
			if (iWeapon == 0) {
				for (new i = 0; i < 6; i++) {
					server_cmd("amx_weapon ^"%s^" 1 %i",sArg1,i+1)
				}
			}
			else if (iWeapon == 1) {
				give_item(iPlayer,"weapon_usp")
				for (new i = 0; i < 8; i++) {
					give_item(iPlayer,"ammo_45acp")
				}
			}
			else if (iWeapon == 2) {
				give_item(iPlayer,"weapon_glock18")
				for (new i = 0; i < 8; i++) {
					give_item(iPlayer,"ammo_9mm")
				}
			}
			else if (iWeapon == 3) {
				give_item(iPlayer,"weapon_deagle")
				for (new i = 0; i < 7; i++) {
					give_item(iPlayer,"ammo_50ae")
				}
			}
			else if (iWeapon == 4) {
				give_item(iPlayer,"weapon_p228")
				for (new i = 0; i < 6; i++) {
					give_item(iPlayer,"ammo_357sig")
				}
			}
			else if (iWeapon == 5) {
				give_item(iPlayer,"weapon_elite")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_9mm")
				}
			}
			else if (iWeapon == 6) {
				give_item(iPlayer,"weapon_fiveseven")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_57mm")
				}
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Shotguns
		else if (iGroup == 2) {
			if (iWeapon == 0) {
				for (new i = 0; i < 2; i++) {
					server_cmd("amx_weapon ^"%s^" 2 %i",sArg1,i+1)
				}
			}
			else if (iWeapon == 1) {
				give_item(iPlayer,"weapon_elite")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_9mm")
				}
			}
			else if (iWeapon == 2) {
				give_item(iPlayer,"weapon_fiveseven")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_57mm")
				}
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Sub machine guns
		else if (iGroup == 3) {
			if (iWeapon == 0) {
				for (new i = 0; i < 5; i++) {
					server_cmd("amx_weapon ^"%s^" 3 %i",sArg1,i+1)
				}
			}
			else if (iWeapon == 1) {
				give_item(iPlayer,"weapon_mp5navy")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_9mm")
				}
			}
			else if (iWeapon == 2) {
				give_item(iPlayer,"weapon_tmp")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_9mm")
				}
			}
			else if (iWeapon == 3) {
				give_item(iPlayer,"weapon_p90")
				for (new i = 0; i < 4; i++) {
					give_item(iPlayer,"ammo_57mm")
				}
			}
			else if (iWeapon == 4) {
				give_item(iPlayer,"weapon_mac10")
				for (new i = 0; i < 6; i++) {
					give_item(iPlayer,"ammo_45acp")
				}
			}
			else if (iWeapon == 5) {
				give_item(iPlayer,"weapon_ump45")
				for (new i = 0; i < 6; i++) {
					give_item(iPlayer,"ammo_45acp")
				}
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Rifles
		else if (iGroup == 4) {
			if (iWeapon == 0) {
				for (new i = 0; i < 8; i++) {
					server_cmd("amx_weapon ^"%s^" 4 %i",sArg1,i+1)
				}
			}
			else if (iWeapon == 1) {
				give_item(iPlayer,"weapon_ak47")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_762nato")
				}
			}
			else if (iWeapon == 2) {
				give_item(iPlayer,"weapon_sg552")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_556nato")
				}
			}
			else if (iWeapon == 3) {
				give_item(iPlayer,"weapon_m4a1")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_556nato")
				}
			}
			else if (iWeapon == 4) {
				give_item(iPlayer,"weapon_aug")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_556nato")
				}
			}
			else if (iWeapon == 5) {
				give_item(iPlayer,"weapon_scout")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_762nato")
				}
			}
			else if (iWeapon == 6) {
				give_item(iPlayer,"weapon_awp")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_338magnum")
				}
			}
			else if (iWeapon == 7) {
				give_item(iPlayer,"weapon_g3sg1")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_762nato")
				}
			}
			else if (iWeapon == 8) {
				give_item(iPlayer,"weapon_sig550")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_556nato")
				}
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Machine guns
		else if (iGroup == 5) {
			if (iWeapon == 0 || iWeapon == 1) {
				give_item(iPlayer,"weapon_m249")
				for (new i = 0; i < 3; i++) {
					give_item(iPlayer,"ammo_556nato")
				}
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Equipment
		else if (iGroup == 8) {
			if (iWeapon == 0) {
				give_item(iPlayer,"item_kevlar")
				give_item(iPlayer,"item_assaultsuit")
				/* These don't work
				give_item(iPlayer,"weapon_flashbang")
				give_item(iPlayer,"weapon_hegrenade")
				give_item(iPlayer,"weapon_smokegrenade")
				*/
				if (get_user_team(iPlayer)==2) {
					give_item(iPlayer,"item_thighpack")
				}
			}
			if (iWeapon == 1) {
				give_item(iPlayer,"item_kevlar")
			}
			else if (iWeapon == 2) {
				give_item(iPlayer,"item_assaultsuit")
			}
			else if (iWeapon == 3) {
				give_item(iPlayer,"weapon_flashbang")
			}
			else if (iWeapon == 4) {
				give_item(iPlayer,"weapon_hegrenade")
			}
			else if (iWeapon == 5) {
				give_item(iPlayer,"weapon_smokegrenade")
			}
			else if (iWeapon == 6) {
				give_item(iPlayer,"item_thighpack")
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		else {
			client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
		}
	}
	return PLUGIN_HANDLED
}

// NO HEADSHOT
public admin_nohead(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[AMX] Usage: amx_nohead < authid | part of nick > < 1 | 0 >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)
	
	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (str_to_num(sArg2)==1) {
			set_user_hitzones(iPlayer,1,253)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is now headshot-proof.",sName)
		}
		else {
			set_user_hitzones(iPlayer,1,255)
			format(sMsg,MAX_TEXT_LENGTH,"[AMX] ^"%s^" is no longer headshot-proof.",sName)
		}
		console_print(id,sMsg)
	}
	return PLUGIN_HANDLED
}

/************************************************************
* EVENT FUNCTIONS
************************************************************/

public event_weapon()
{
	new iPlayer = read_data(0)

	// Maxspeed
	if (floatround(gMaxspeedIndex[iPlayer]) > 0) {
		set_user_maxspeed(iPlayer,gMaxspeedIndex[iPlayer])
	}
	return PLUGIN_CONTINUE
}

public event_money(id)
{
	new iMoney = read_data(1)
	new iMoneyChange = iMoney - gMoneyIndex[id][0]
	new iFakeMoney = gMoneyIndex[id][1]
	gMoneyIndex[id][0] = iMoney

	if (iFakeMoney > 16000) {
		iFakeMoney += iMoneyChange
		if (iFakeMoney > MAX_MONEY) iFakeMoney = MAX_MONEY
		gMoneyIndex[id][1] = iFakeMoney
		set_user_money(id,10000,0)
		gMoneyIndex[id][0] = 10000
		player_money(id,iFakeMoney,0)
	}
	return PLUGIN_CONTINUE
}

/************************************************************
* FX FUNCTIONS
************************************************************/

static fx_glow(player,r,g,b,size)
{
	set_user_rendering(player,kRenderFxGlowShell,r,g,b,kRenderNormal,size)
	return PLUGIN_CONTINUE
}

/************************************************************
* HELPER FUNCTIONS
************************************************************/

static player_money(id,money,flash)
{
	message_begin(MSG_ONE,102,{0,0,0},id)
	write_long(money)
	write_byte(flash)
	message_end()
}

static player_find(id,arg[])
{
	new iPlayer = find_player("bl",arg)
	if (iPlayer){
		new iPlayer2 = find_player("blj",arg)
		if (iPlayer!=iPlayer2){
			console_print(id,"[AMX] Found multiple clients. Try again.")
			return 0		
		}
	}
	else {
		iPlayer = find_player("c",arg)
	}
	if (!iPlayer){
		console_print(id,"[AMX] Client with that authid or part of nick not found")
		return 0
	}
	return iPlayer
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Plugin Fun","1.0","mike_cao")
	register_concmd("amx_godmode","admin_godmode",ACCESS_LEVEL,"amx_godmode < authid | part of nick > < on | off >")
	register_concmd("amx_noclip","admin_noclip",ACCESS_LEVEL,"amx_noclip < authid | part of nick > < on | off >")
	register_concmd("amx_frags","admin_frags",ACCESS_LEVEL,"amx_frags < authid | part of nick > < frags >")
	register_concmd("amx_armor","admin_armor",ACCESS_LEVEL,"amx_armor < authid | part of nick > < armor >")
	register_concmd("amx_health","admin_health",ACCESS_LEVEL,"amx_health < authid | part of nick > < health >")
	register_concmd("amx_maxspeed","admin_maxspeed",ACCESS_LEVEL,"amx_maxspeed < authid | part of nick > < maxspeed >")
	register_concmd("amx_gravity","admin_gravity",ACCESS_LEVEL,"amx_gravity < authid | part of nick > < gravity >")
	register_concmd("amx_tp","admin_tp",ACCESS_LEVEL,"amx_tp < authid | part of nick >")
	register_concmd("amx_tpsave","admin_tpsave",ACCESS_LEVEL,"amx_tpsave")
	register_concmd("amx_money","admin_money",ACCESS_LEVEL,"amx_money < authid | part of nick > < money >")
	register_concmd("amx_weapon","admin_weapon",ACCESS_LEVEL,"amx_weapon < authid | part of nick > < weapon group > < weapon id >")
	register_concmd("amx_nohead","admin_nohead",ACCESS_LEVEL,"amx_nohead < authid | part of nick > < 1 | 0 >")
	register_concmd("amx_glow","admin_glow",ACCESS_LEVEL,"amx_glow < authid | part of nick > < r > < g > < b > < size >")
	register_event("Money","event_money","b")
	return PLUGIN_CONTINUE
}

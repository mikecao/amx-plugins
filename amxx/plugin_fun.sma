/*
*	AMXMODX script.
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
*	amx_give - give a player a weapon/item
*	amx_weapon - gives player weapons
*	amx_tp - teleports a player to a coordinate
*	amx_tpsave - saves a coordinate for teleporting
*	amx_nohead - turns off headshots for a player
*	amx_glow - makes a player glow
*	amx_spawn - makes a player spawn
*	amx_footsteps - changes player footsteps
*	amx_lights - change map lighting
*
*/
#include <amxmodx>
#include <fun>
#include <engine>
#include <cstrike>

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32
#define MAX_WEAPONS 32
#define MAX_TEXT_LENGTH 512

#define MAX_MONEY	999999
#define PISTOL_INDEX    6
#define SHOTGUN_INDEX   8
#define SUB_INDEX       13
#define RIFLE_INDEX     23
#define WEAPON_INDEX	24
#define ITEM_INDEX	6

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

new gWeaponIndex[WEAPON_INDEX][] = {
	"usp","glock18","deagle","p228","elite","fiveseven", // pistols
	"m3","xm1014", // shotguns
	"mp5navy","tmp","p90","mac10","ump45", // subs
	"ak47","sg552","m4a1","aug","scout","awp","g3sg1","sg550","famas","galil", // rifles
	"m249" // machine guns
}

new gItemIndex[ITEM_INDEX][] = {
	"item_kevlar","item_assaultsuit","item_thighpack", // items
	"weapon_hegrande","weapon_flashbang","weapon_smokegrenade" // grenades
}

new gAmmoIndex[WEAPON_INDEX][] = {
	"ammo_45acp","ammo_9mm","ammo_50ae","ammo_357sig","ammo_9mm","ammo_57mm", // pistols
	"ammo_buckshot","ammo_buckshot", // shotguns
	"ammo_9mm","ammo_9mm","ammo_57mm","ammo_45acp","ammo_45acp", // subs
	"ammo_762nato","ammo_556nato","ammo_556nato","ammo_556nato","ammo_762nato",
	"ammo_338magnum","ammo_762nato","ammo_45acp","ammo_556nato","ammo_556nato", // rifles
	"ammo_556natobox" // machine guns
}

new gClipIndex[WEAPON_INDEX] = {
	8,8,7,6,4,4, // pistols 
	4,4, // shotguns
	4,4,2,9,9, // subs
	3,3,3,3,3,3,3,3,3,3, // rifles
	3 // machine guns
}

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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			set_user_godmode(iPlayer,1)
			console_print(id,"[AMX] ^"%s^" now has godmode.",sName)
		}
		else {
			set_user_godmode(iPlayer,0)
			console_print(id,"[AMX] ^"%s^" no longer has godmode.",sName)
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

		if (equal(sArg2,"on") || str_to_num(sArg2)) {
			set_user_noclip(iPlayer,1)
			console_print(id,"[AMX] ^"%s^" now has noclip.",sName)
		}
		else {
			set_user_noclip(iPlayer,0)
			console_print(id,"[AMX] ^"%s^" no longer has noclip.",sName)
		}
	}
	return PLUGIN_HANDLED
}

// INVISIBLE 
public admin_invisible(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 2) {
                console_print(id,"[AMX] Usage: amx_invisible < authid | part of nick > < on | off >")
                return PLUGIN_HANDLED
        }

        // Get data
        new sArg1[MAX_NAME_LENGTH]
        new sArg2[MAX_NAME_LENGTH]
        read_argv(1,sArg1,MAX_NAME_LENGTH)
        read_argv(2,sArg2,MAX_NAME_LENGTH)

        // Find player
        new iPlayer = player_find(id,sArg1)
        if (iPlayer)    {
                new sName[MAX_NAME_LENGTH]
                get_user_name(iPlayer,sName,MAX_NAME_LENGTH)

                if (equal(sArg2,"on") || str_to_num(sArg2)) {
			fx_trans(iPlayer,0)
                        console_print(id,"[AMX] ^"%s^" is now invisible.",sName)
                }
                else {
			fx_trans(iPlayer,255)
                        console_print(id,"[AMX] ^"%s^" no longer invisible.",sName)
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_frags(iPlayer,str_to_num(sArg2))
		console_print(id,"[AMX] ^"%s^"'s frags set to %i.",sName,str_to_num(sArg2))
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_armor(iPlayer,str_to_num(sArg2))
		console_print(id,"[AMX] ^"%s^"'s armor set to %i.",sName,str_to_num(sArg2))
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_health(iPlayer,str_to_num(sArg2))
		console_print(id,"[AMX] ^"%s^"'s health set to %i.",sName,str_to_num(sArg2))
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		gMaxspeedIndex[iPlayer] = floatstr(sArg2)
		set_user_maxspeed(iPlayer,gMaxspeedIndex[iPlayer])
		console_print(id,"[AMX] ^"%s^"'s maxspeed set to %i.",sName,str_to_num(sArg2))
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		set_user_gravity(iPlayer,floatstr(sArg2))
		console_print(id,"[AMX] ^"%s^"'s gravity set to %i.",sName,str_to_num(sArg2))
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)		
		fx_glow(iPlayer,str_to_num(sArg2),str_to_num(sArg3),str_to_num(sArg4),str_to_num(sArg5))
		console_print(id,"[AMX] ^"%s^" is now glowing.",sName)
	}
	return PLUGIN_HANDLED
}

// SPAWN
public admin_spawn(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 2) {
                console_print(id,"[AMX] Usage: amx_spawn < authid | part of nick >")
                return PLUGIN_HANDLED
        }

        // Get data
        new sArg1[MAX_NAME_LENGTH]
        read_argv(1,sArg1,MAX_NAME_LENGTH)

        // Find player
        new iPlayer = player_find(id,sArg1)
        if (iPlayer) {
                new sName[MAX_NAME_LENGTH]
                get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		spawn(iPlayer)
                console_print(id,"[AMX] ^"%s^" was spawned.",sName)
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (!is_user_alive(iPlayer)) {
			console_print(id,"[AMX] ^"%s^" is dead",sName)
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
		console_print(id,"[AMX] ^"%s^" was teleported.",sName)
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

// GIVE
public admin_give(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 3) {
                console_print(id,"[AMX] Usage: amx_give < authid | part of nick > < weapon/item name >")
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
		give_item(iPlayer,sArg2)
                new sName[MAX_NAME_LENGTH]
                get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		console_print(id,"[AMX] ^"%s^" was given ^"%s.^"",sName,sArg2)
	}
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		
		new iMoney = str_to_num(sArg2)
		if (iMoney > MAX_MONEY) iMoney = MAX_MONEY
		gMoneyIndex[iPlayer][0] = cs_get_user_money(iPlayer)
		gMoneyIndex[iPlayer][1] = iMoney

		if (iMoney > 16000) {
			cs_set_user_money(iPlayer,10000,0)
		}
		else {
			cs_set_user_money(iPlayer,iMoney,0)
		}
		player_money(iPlayer,gMoneyIndex[iPlayer][1],1)

		console_print(id,"[AMX] ^"%s^"'s money set to %i.",sName,iMoney)
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
	if (read_argc() < 3) {
		console_print(id,"[AMX] Usage: amx_weapon < authid | part of nick > < weapon group > < weapon id >")
		console_print(id,"Groups: 0=ALL, 1=pistols, 2=shotguns, 3=subs, 4=rifles, 5=machineguns, 6=equip")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	new sArg2[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	read_argv(2,sArg2,MAX_NAME_LENGTH)

	new iGroup = str_to_num(sArg2)

	if (read_argc() == 3) {
	 	if (iGroup == 1) {
			console_print(id,"Pistols: 1=usp, 2=glock18, 3=deagle, 4=p228, 5=elite, 6=fiveseven")
		}
		else if (iGroup == 2) {
			console_print(id,"Shotguns: 1=m3, 2=xm1014")
		}
                else if (iGroup == 3) {
                        console_print(id,"Subs: 1=mp5navy, 2=tmp, 3=p90, 4=mac10, 5=ump45")
                }
                else if (iGroup == 4) {
                        console_print(id,"Rifles: 1=ak47, 2=sg552, 3=m4a1, 4=aug, 5=scout, 6=awp, 7=g3sg1")
			console_print(id,"        8=sg550, 9=famas, 10=galil")
                }
                else if (iGroup == 5) {
                        console_print(id,"Machine guns: 1=m249")
                }
                else if (iGroup == 6) {
                        console_print(id,"Equipment: 1=kevlar, 2=armor, 3=defusekit, 4=he, 5=flashbang, 6=smoke")
                }
                else {
                        console_print(id,"Group: (%i) is not valid.",iGroup)
                }
		return PLUGIN_HANDLED
	}

	new sArg3[MAX_NAME_LENGTH]
	read_argv(3,sArg3,MAX_NAME_LENGTH)
	
	new iWeapon = str_to_num(sArg3)

	// Find player
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		
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
				for (new i = 0; i < PISTOL_INDEX; i++) {
					server_cmd("amx_weapon ^"%s^" 1 %i",sArg1,i+1)
				}
			}
			else if (iWeapon > 0 && iWeapon <= PISTOL_INDEX) {
				player_weapon(iPlayer,iWeapon)
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Shotguns
		else if (iGroup == 2) {
			if (iWeapon == 0) {
				for (new i = 0; i < (SHOTGUN_INDEX-PISTOL_INDEX); i++) {
					server_cmd("amx_weapon ^"%s^" 2 %i",sArg1,i+1)
				}
			}
			else if (iWeapon > 0 && iWeapon <= (SHOTGUN_INDEX-PISTOL_INDEX)) {
				player_weapon(iPlayer,iWeapon+PISTOL_INDEX)	
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Sub machine guns
		else if (iGroup == 3) {
			if (iWeapon == 0) {
				for (new i = 0; i < (SUB_INDEX-SHOTGUN_INDEX); i++) {
					server_cmd("amx_weapon ^"%s^" 3 %i",sArg1,i+1)
				}
			}
                        else if (iWeapon > 0 && iWeapon <= (SUB_INDEX-SHOTGUN_INDEX)) {
                                player_weapon(iPlayer,iWeapon+SHOTGUN_INDEX)
                        }
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Rifles
		else if (iGroup == 4) {
			if (iWeapon == 0) {
				for (new i = 0; i < (RIFLE_INDEX-SUB_INDEX); i++) {
					server_cmd("amx_weapon ^"%s^" 4 %i",sArg1,i+1)
				}
			}
                        else if (iWeapon > 0 && iWeapon <= (RIFLE_INDEX-SUB_INDEX)) {
                                player_weapon(iPlayer,iWeapon+SUB_INDEX)
                        }
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Machine guns
		else if (iGroup == 5) {
			if (iWeapon == 0 || iWeapon == 1) {
                                player_weapon(iPlayer,RIFLE_INDEX+1)
			}
			else {
				client_print(id,print_console,"[AMX] Weapon (%i) (%i) not recognized.",iGroup,iWeapon)
			}
		}
		// Equipment
		else if (iGroup == 6) {
			if (iWeapon == 0) {
				for (new i = 0; i < ITEM_INDEX; i++) {
					give_item(iPlayer,gItemIndex[i])
				}
			}
			else if (iWeapon > 0 && iWeapon <= ITEM_INDEX) {
				give_item(iPlayer,gItemIndex[iWeapon])
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
		new sName[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (str_to_num(sArg2)==1) {
			set_user_hitzones(iPlayer,1,253)
			console_print(id,"[AMX] ^"%s^" is now headshot-proof.",sName)
		}
		else {
			set_user_hitzones(iPlayer,1,255)
			console_print(id,"[AMX] ^"%s^" is no longer headshot-proof.",sName)
		}
	}
	return PLUGIN_HANDLED
}

// LIGHTS
public admin_lights(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 2) {
                console_print(id,"[AMX] Usage: amx_lights < a - z >")
                return PLUGIN_HANDLED
        }

        // Get data
        new sArg1[MAX_NAME_LENGTH]
        read_argv(1,sArg1,MAX_NAME_LENGTH)

	set_lights(sArg1)
        console_print(id,"[AMX] Map lighting set to ^"%s^".",sArg1)

        return PLUGIN_HANDLED
}

// FOOTSTEPS 
public admin_footsteps(id)
{
        // Check access level
        if (!(get_user_flags(id)&ACCESS_LEVEL)) {
                console_print(id,"[AMX] You have no access to that command")
                return PLUGIN_HANDLED
        }
        // Check arguments
        if (read_argc() < 3) {
                console_print(id,"[AMX] Usage: amx_footsteps < authid | part of nick > < on | off >")
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
                new sName[MAX_NAME_LENGTH]
                get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		if (equal(sArg2,"off") || str_to_num(sArg2) == 0) {
			set_user_footsteps(iPlayer,1)
		}
		else {
			set_user_footsteps(iPlayer,0)
		}
                console_print(id,"[AMX] ^"%s^"'s footsteps set to %s.",sName,sArg2)
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
		cs_set_user_money(id,10000,0)
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

static fx_trans(player,amount)
{
        set_user_rendering(player,kRenderFxNone,0,0,0,kRenderTransAlpha,amount)
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

static player_weapon(player,weapon)
{
	new sWeapon[MAX_NAME_LENGTH]
	format(sWeapon,MAX_NAME_LENGTH,"weapon_%s",gWeaponIndex[weapon])
	give_item(player,sWeapon)
	for (new i = 0; i < gClipIndex[weapon]; i++) {
		give_item(player,gAmmoIndex[weapon])
	}
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_init()
{
	register_plugin("Fun Commands","1.0","mike_cao")
	register_concmd("amx_godmode","admin_godmode",ACCESS_LEVEL,"amx_godmode < authid | part of nick > < on | off >")
	register_concmd("amx_noclip","admin_noclip",ACCESS_LEVEL,"amx_noclip < authid | part of nick > < on | off >")
	register_concmd("amx_invisible","admin_invisible",ACCESS_LEVEL,"amx_invisible < authid | part of nick > < on | off >")
	register_concmd("amx_frags","admin_frags",ACCESS_LEVEL,"amx_frags < authid | part of nick > < frags >")
	register_concmd("amx_armor","admin_armor",ACCESS_LEVEL,"amx_armor < authid | part of nick > < armor >")
	register_concmd("amx_health","admin_health",ACCESS_LEVEL,"amx_health < authid | part of nick > < health >")
	register_concmd("amx_maxspeed","admin_maxspeed",ACCESS_LEVEL,"amx_maxspeed < authid | part of nick > < maxspeed >")
	register_concmd("amx_gravity","admin_gravity",ACCESS_LEVEL,"amx_gravity < authid | part of nick > < gravity >")
	register_concmd("amx_tp","admin_tp",ACCESS_LEVEL,"amx_tp < authid | part of nick >")
	register_concmd("amx_tpsave","admin_tpsave",ACCESS_LEVEL,"amx_tpsave")
	register_concmd("amx_give","admin_give",ACCESS_LEVEL,"amx_give < authid | part of nick > < weapon/item name >")
	register_concmd("amx_weapon","admin_weapon",ACCESS_LEVEL,"amx_weapon < authid | part of nick > < weapon group > < weapon id >")
	register_concmd("amx_nohead","admin_nohead",ACCESS_LEVEL,"amx_nohead < authid | part of nick > < 1 | 0 >")
	register_concmd("amx_glow","admin_glow",ACCESS_LEVEL,"amx_glow < authid | part of nick > < r > < g > < b > < size >")
	register_concmd("amx_spawn","admin_spawn",ACCESS_LEVEL,"amx_spawn < authid | part of nick >")
	register_concmd("amx_footsteps","admin_footsteps",ACCESS_LEVEL,"amx_footsteps < authid | part of nick > < on | off >")

        new sMod[MAX_NAME_LENGTH]
        get_modname(sMod,MAX_NAME_LENGTH)

	if (equal(sMod,"cstrike")) {
		register_concmd("amx_money","admin_money",ACCESS_LEVEL,"amx_money < authid | part of nick > < money >")
		register_event("Money","event_money","b")
	}
	return PLUGIN_CONTINUE
}

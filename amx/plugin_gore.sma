/*
*	AMXMOD script.
*	(plugin_gore.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	This plugin adds gore effects. It is configured
*	with the cvar "amx_gore" using these flags:
*
*	a - Headshot blood
*	b - Extra blood effects
*	c - Bleeding on low health
*	d - Gib explosion (knife, HE, high damage only)
*
*/
#include <amxmod>

#define MAX_NAME_LENGTH 32
#define MAX_VAR_LENGTH 64
#define MAX_PLAYERS 32
#define MAX_TEXT_LENGTH 512

#define GORE_HEADSHOT 		(1<<0) // "a"
#define GORE_BLOOD		 	(1<<1) // "b"
#define GORE_BLEEDING	 	(1<<2) // "c"
#define GORE_GIB			(1<<3) // "d"

#define TE_BLOODSPRITE		115
#define	TE_BLOODSTREAM		101
#define TE_MODEL			106
#define TE_WORLDDECAL		116

/************************************************************
* MAIN
************************************************************/

new gHealthIndex[MAX_PLAYERS+1]

new mdl_gib_flesh
new mdl_gib_head
new mdl_gib_legbone
new mdl_gib_lung
new mdl_gib_meat
new mdl_gib_spine

new spr_blood_drop
new	spr_blood_spray

public event_damage()
{
	new iFlags = get_gore_flags()
	new iVictim = read_data(0)
	gHealthIndex[iVictim] = get_user_health(iVictim)
	
	if (iFlags&GORE_BLOOD) {
		new iOrigin[3]
		get_user_origin(iVictim,iOrigin)
		fx_blood(iOrigin)
		fx_blood_small(iOrigin,10)
	}
	return PLUGIN_CONTINUE
}

public event_death()
{
	new iFlags = get_gore_flags()
	new iOrigin[3]
	new sWeapon[MAX_NAME_LENGTH]
	new iVictim = read_data(2)
	new iHeadshot = read_data(3)
	
	read_data(4,sWeapon,MAX_NAME_LENGTH)
	
	if (iFlags&GORE_HEADSHOT && iHeadshot) {
		get_user_origin(iVictim,iOrigin)
		fx_headshot(iOrigin)
	}
	else if (iFlags&GORE_GIB && (equal(sWeapon,"knife") || equal(sWeapon,"grenade") || (gHealthIndex[iVictim] - get_user_health(iVictim)) > 100)) {
		get_user_origin(iVictim,iOrigin)
		// Effects
		fx_trans(iVictim,0)
		fx_gib_explode(iOrigin,5)
		fx_blood_large(iOrigin,3)
		fx_blood_small(iOrigin,20)
		// Hide body
		iOrigin[2] = iOrigin[2]-20
		set_user_origin(iVictim,iOrigin)
	}
}

public event_blood()
{

	new iFlags = get_gore_flags()
	if (iFlags&GORE_BLEEDING) {
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers, iOrigin[3]
		get_players(iPlayers,iNumPlayers,"a")
		for (new i = 0; i < iNumPlayers; i++) {
			iPlayer = iPlayers[i]
			if (get_user_health(iPlayer) < 20) {
				get_user_origin(iPlayer,iOrigin)
				fx_bleed(iOrigin)
				fx_blood_small(iOrigin,5)
			}
		}
	}
}

public event_respawn(id)
{
	gHealthIndex[id] = get_user_health(id)
	return PLUGIN_CONTINUE
}

public get_gore_flags()
{
	new sFlags[24]
	get_cvar_string("amx_gore",sFlags,24)
	return read_flags(sFlags)
}

/************************************************************
* FX FUNCTIONS
************************************************************/

static fx_trans(player,amount)
{
	set_user_rendering(player,kRenderFxNone,0,0,0,kRenderTransAlpha,amount)
	return PLUGIN_CONTINUE
}

public fx_blood(origin[3])
{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSPRITE)
		write_coord(origin[0]+random_num(-20,20))
		write_coord(origin[1]+random_num(-20,20))
		write_coord(origin[2]+random_num(-20,20))
		write_short(spr_blood_spray)
		write_short(spr_blood_drop)
		write_byte(248) // color index
		write_byte(10) // size
		message_end()
}

public fx_bleed(origin[3])
{
	// Blood spray
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(random_num(-100,100)) // x
	write_coord(random_num(-100,100)) // y
	write_coord(random_num(-10,10)) // z
	write_byte(70) // color
	write_byte(random_num(50,100)) // speed
	message_end()
}

static fx_blood_small(origin[3],num)
{
	// Blood decals
	static const blood_small[7] = {190,191,192,193,194,195,197}
	
	// Small splash
	for (new j = 0; j < num; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-100,100))
		write_coord(origin[1]+random_num(-100,100))
		write_coord(origin[2]-36)
		write_byte(blood_small[random_num(0,6)]) // index
		message_end()
	}
}

static fx_blood_large(origin[3],num)
{
	// Blood decals
	static const blood_large[2] = {204,205}

	// Large splash
	for (new i = 0; i < num; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-50,50))
		write_coord(origin[1]+random_num(-50,50))
		write_coord(origin[2]-36)
		write_byte(blood_large[random_num(0,1)]) // index
		message_end()
	}
}

static fx_gib_explode(origin[3],num)
{
	new flesh[3], x, y, z
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	flesh[2] = mdl_gib_legbone

	// Gib explosion
	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_head)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_spine)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Lung
	for(new i = 0; i < random_num(1,2); i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Parts, 5 times
	for(new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(flesh[random_num(0,2)])
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Blood
	for(new i = 0; i < num; i++) {
		x = random_num(-100,100)
		y = random_num(-100,100)
		z = random_num(0,100)
		for(new j = 0; j < 5; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_spray)
			write_short(spr_blood_drop)
			write_byte(248) // color index
			write_byte(15) // size
			message_end()
		}
	}
}

public fx_headshot(origin[3])
{
	// Blood spray, 5 times
	for (new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(101)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+30)
		write_coord(random_num(-20,20)) // x
		write_coord(random_num(-20,20)) // y
		write_coord(random_num(50,300)) // z
		write_byte(70) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}

/************************************************************
* PLUGIN FUNCTIONS
************************************************************/

public plugin_precache()
{
	spr_blood_drop = precache_model("sprites/blood.spr")
	spr_blood_spray = precache_model("sprites/bloodspray.spr")

	mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
	mdl_gib_head = precache_model("models/GIB_Skull.mdl")
	mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
	mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
	mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
	mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")
}

public plugin_init()
{
	register_plugin("Plugin Gore","1.0","mike_cao")
	register_event("DeathMsg","event_death","a")
	register_event("Damage","event_damage","b","2!0","3=0","4!0")
	register_event("ResetHUD","event_respawn","be","1=1")
	register_cvar("amx_gore","abcd")
	set_task(1.0,"event_blood",0,"",0,"b")

	return PLUGIN_CONTINUE
}

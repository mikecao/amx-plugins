/*
*	AMXMOD script.
*	(plugin_mysql_ban.sma)
*	by mike_cao <mike@mikecao.com>
*	This file is provided as is (no warranties).
*
*	Simple ban management using a mySQL database.
*
*	Create a table to hold bans in your mysql database:
*
*	CREATE TABLE banned ( 
*		banid varchar(32) NOT NULL PRIMARY KEY,
*		reason varchar(255),
*		adminid int default 0,
*		moddatetime bigint default 0
*	);
*
*/
#include <amxmod>
#include <mysql> 

new logfilename[] = "addons/amx/logs/mysql_ban.log"

#define ACCESS_LEVEL 		ADMIN_BAN
#define MAX_NAME_LENGTH 	32
#define MAX_TEXT_LENGTH		512
#define MAX_HOST_LENGTH		64

// Ban a player
public admin_mysql_ban(id)
{
	new sMysqlHost[MAX_HOST_LENGTH]
	new sMysqlUser[MAX_NAME_LENGTH]
	new sMysqlPass[MAX_NAME_LENGTH]
	new sMysqlDB[MAX_NAME_LENGTH]
	new sMysqlError[MAX_NAME_LENGTH]
	new iMysql = 0

	get_cvar_string("amx_mysql_host",sMysqlHost,MAX_HOST_LENGTH)
	get_cvar_string("amx_mysql_user",sMysqlUser,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_pass",sMysqlPass,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_db",sMysqlDB,MAX_NAME_LENGTH)

	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[AMX] Usage: amx_mysql_ban < wonid | ip address > < reason >")
		return PLUGIN_HANDLED
	}
	
	// Connect to database
	iMysql = mysql_connect(sMysqlHost,sMysqlUser,sMysqlPass,sMysqlDB,sMysqlError,MAX_NAME_LENGTH)

	if (iMysql < 1) {
		// Catch errors
		mysql_error(iMysql,sMysqlError,MAX_NAME_LENGTH)
		server_print("[AMX] MySQL error : could not connect : '%s'",sMysqlError)
		return PLUGIN_HANDLED
	}
	else {
		new sQuery[MAX_TEXT_LENGTH]
		new sBanid[MAX_NAME_LENGTH]
		new sReason[MAX_TEXT_LENGTH]
		new sAdminid[MAX_NAME_LENGTH]
		new sName[MAX_NAME_LENGTH]
		new sModDateTime[MAX_NAME_LENGTH]
		read_argv(1,sBanid,MAX_NAME_LENGTH)
		read_argv(2,sReason,MAX_TEXT_LENGTH)
		get_user_authid(id,sAdminid,MAX_NAME_LENGTH)
		get_user_name(id,sName,MAX_NAME_LENGTH)
		get_time("%Y%m%d%H%M%S",sModDateTime,MAX_NAME_LENGTH)
		
		// Do query
		format(sQuery,256,"INSERT INTO banned (banid,reason,adminid,moddatetime) VALUES ('%s','%s',%s,%s)",sBanid,sReason,sAdminid,sModDateTime)
		mysql_query(iMysql,sQuery)
		client_print(id,print_console,"[AMX] The wonid/ip ^"%s^" has been banned.",sBanid)
		log_to_file(logfilename,"^"%s<%d><%s><>^" banned ^"%s^" for ^"%s^"",sName,get_user_userid(id),sAdminid,sBanid,sReason)

		// Close connection
		mysql_close(iMysql)
	}
	return PLUGIN_HANDLED
}

// Unban a player
public admin_mysql_unban(id)
{
	new sMysqlHost[MAX_HOST_LENGTH]
	new sMysqlUser[MAX_NAME_LENGTH]
	new sMysqlPass[MAX_NAME_LENGTH]
	new sMysqlDB[MAX_NAME_LENGTH]
	new sMysqlError[MAX_NAME_LENGTH]
	new iMysql = 0

	get_cvar_string("amx_mysql_host",sMysqlHost,MAX_HOST_LENGTH)
	get_cvar_string("amx_mysql_user",sMysqlUser,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_pass",sMysqlPass,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_db",sMysqlDB,MAX_NAME_LENGTH)

	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	// Check arguments
	if (read_argc() < 3) {
		console_print(id,"[AMX] Usage: amx_mysql_unban < wonid | ip address > < reason >")
		return PLUGIN_HANDLED
	}
	
	// Connect to database
	iMysql = mysql_connect(sMysqlHost,sMysqlUser,sMysqlPass,sMysqlDB,sMysqlError,MAX_NAME_LENGTH)

	if (iMysql < 1) {
		// Catch errors
		mysql_error(iMysql,sMysqlError,MAX_NAME_LENGTH)
		server_print("[AMX] MySQL error : could not connect : '%s'",sMysqlError)
		return PLUGIN_HANDLED
	}
	else {
		new sQuery[MAX_TEXT_LENGTH]
		new sBanid[MAX_NAME_LENGTH]
		new sReason[MAX_TEXT_LENGTH]
		new sAdminid[MAX_NAME_LENGTH]
		new sName[MAX_NAME_LENGTH]
		read_argv(1,sBanid,MAX_NAME_LENGTH)
		read_argv(2,sReason,MAX_TEXT_LENGTH)
		get_user_authid(id,sAdminid,MAX_NAME_LENGTH)
		get_user_name(id,sName,MAX_NAME_LENGTH)
				
		// Do query
		format(sQuery,256,"DELETE FROM banned WHERE banid='%s'",sBanid)
		mysql_query(iMysql,sQuery)
		client_print(id,print_console,"[AMX] The wonid/ip ^"%s^" has been unbanned.",sBanid)
		log_to_file(logfilename,"^"%s<%d><%s><>^" unbanned ^"%s^" for ^"%s^"",sName,get_user_userid(id),sAdminid,sBanid,sReason)

		// Close connection
		mysql_close(iMysql)
	}
	return PLUGIN_HANDLED
}

// Find a player
static player_find(id,arg[])
{
	new player = find_player("bl",arg)
	if (player) {
		new player2 = find_player("blj",arg)
		if (player!=player2){
			console_print(id,"[POWERS] Found multiple clients. Try again.")
			return 0
		}
	}
	else {
		player = find_player("c",arg)
	}
	if (!player){
		console_print(id,"[POWERS] Client with that authid or part of nick not found")
		return 0
	}
	return player
}

// Get a player's wonid
public admin_getwonid(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}

	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_getwonid < part of name >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		format(sMsg,MAX_TEXT_LENGTH,"* ^"%s^"'s wonid is %i",sName,get_user_wonid(iPlayer))
		client_print(id,print_chat,sMsg)
		client_print(id,print_console,sMsg)
	}
	return PLUGIN_HANDLED
}

// Get a player's ip address
public admin_getip(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}

	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_getip < part of name >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[32], sMsg[MAX_TEXT_LENGTH], sIPAddress[MAX_NAME_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		get_user_ip(id,sIPAddress,MAX_NAME_LENGTH,1)
		format(sMsg,MAX_TEXT_LENGTH,"* ^"%s^"'s ip address is %s",sName,sIPAddress)
		client_print(id,print_chat,sMsg)
		client_print(id,print_console,sMsg)
	}
	return PLUGIN_HANDLED
}

public client_connect(id)
{
	new sMysqlHost[MAX_HOST_LENGTH]
	new sMysqlUser[MAX_NAME_LENGTH]
	new sMysqlPass[MAX_NAME_LENGTH]
	new sMysqlDB[MAX_NAME_LENGTH]
	new sMysqlError[MAX_NAME_LENGTH]
	new iMysql = 0

	get_cvar_string("amx_mysql_host",sMysqlHost,MAX_HOST_LENGTH)
	get_cvar_string("amx_mysql_user",sMysqlUser,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_pass",sMysqlPass,MAX_NAME_LENGTH)
	get_cvar_string("amx_mysql_db",sMysqlDB,MAX_NAME_LENGTH)

	// Connect to database
	iMysql = mysql_connect(sMysqlHost,sMysqlUser,sMysqlPass,sMysqlDB,sMysqlError,MAX_NAME_LENGTH)

	if (iMysql < 1) {
		// Catch errors
		mysql_error(iMysql,sMysqlError,32)
		server_print("[AMX] MySQL error : could not connect : '%s'",sMysqlError)
		return PLUGIN_HANDLED
	}
	else {
		new sQuery[MAX_TEXT_LENGTH]
		new sAuthid[MAX_NAME_LENGTH]
		new sIPAddress[MAX_NAME_LENGTH]
		new sName[MAX_NAME_LENGTH]
		get_user_authid(id,sAuthid,MAX_NAME_LENGTH)
		get_user_ip(id,sIPAddress,MAX_NAME_LENGTH,1)
		get_user_name(id,sName,MAX_NAME_LENGTH)
		
		// Do query
		format(sQuery,256,"SELECT banid FROM banned WHERE banid='%s' OR banid='%s'",sAuthid,sIPAddress)
		mysql_query(iMysql,sQuery)

		// If result, then player is banned
		if (mysql_nextrow(iMysql)) {
			log_to_file(logfilename,"^"%s<%d><%s><>^" from ^"%s^" was rejected.",sName,get_user_userid(id),sAuthid,sIPAddress)
			client_cmd(id,"clear;echo * You are banned from this server.;disconnect")
			return PLUGIN_HANDLED
		}
		mysql_close(iMysql)
	}
	return PLUGIN_CONTINUE
}

public plugin_init() 
{ 
	register_plugin("Plugin MySQL Ban","1.0","mike_cao")
	register_cvar("amx_mysql_host","66.111.48.230")
	register_cvar("amx_mysql_user","root")
	register_cvar("amx_mysql_pass","")
	register_cvar("amx_mysql_db","amx")
	
	register_concmd("amx_mysql_ban","admin_mysql_ban",ACCESS_LEVEL,"amx_mysql_ban < wonid | ip > < reason >")
	register_concmd("amx_mysql_unban","admin_mysql_unban",ACCESS_LEVEL,"amx_mysql_unban < wonid | ip > < reason >")
	register_concmd("amx_getwonid","admin_getwonid",ACCESS_LEVEL,"getwonid < part of name >")
	register_concmd("amx_getip","admin_getip",ACCESS_LEVEL,"getip < part of name >")
	
	return PLUGIN_CONTINUE
} 

/*
*	AMXMODX script.
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
*		banname varchar(32),
*		adminid varchar(32),
*		adminname varchar(32),
*		reason varchar(255),
*		bandatetime int unsigned default 0
*	);
*
*/
#include <amxmodx>
#include <mysql>

new logfilename[] = "mysql_ban.log"

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
		console_print(id,"[AMX] Usage: amx_mysql_ban < authid | ip address > < reason >")
		return PLUGIN_HANDLED
	}

	// Try to get banned user's name
	new sBanName[MAX_NAME_LENGTH]
	new sBanId[MAX_NAME_LENGTH]
	read_argv(1,sBanId,MAX_NAME_LENGTH)
	new iPlayer = find_player("c",sBanId)
	if (!iPlayer) iPlayer = find_player("d",sBanId)
	if (iPlayer) {
		get_user_name(iPlayer,sBanName,MAX_NAME_LENGTH)

		// Kick the user
		server_cmd("kick #%d",get_user_userid(iPlayer))
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
		new sReason[MAX_TEXT_LENGTH]
		new sAdminId[MAX_NAME_LENGTH]
		new sAdminName[MAX_NAME_LENGTH]
		read_argv(2,sReason,MAX_TEXT_LENGTH)
		get_user_authid(id,sAdminId,MAX_NAME_LENGTH)
		get_user_name(id,sAdminName,MAX_NAME_LENGTH)
		
		// Do query
		format(sQuery,MAX_TEXT_LENGTH,"INSERT INTO banned VALUES ('%s','%s','%s','%s','%s',%i)",sBanId,sBanName,sAdminId,sAdminName,sReason,get_systime())
		mysql_query(iMysql,sQuery)
		client_print(id,print_console,"[AMX] User ^"%s (%s)^" has been banned.",sBanName,sBanId)
		log_to_file(logfilename,"^"%s<%d><%s><>^" banned ^"%s (%s)^" for ^"%s^"",sAdminName,get_user_userid(id),sAdminId,sBanName,sBanId,sReason)

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
		console_print(id,"[AMX] Usage: amx_mysql_unban < authid | ip address > < reason >")
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
		new sBanId[MAX_NAME_LENGTH]
		new sReason[MAX_TEXT_LENGTH]
		new sAdminId[MAX_NAME_LENGTH]
		new sAdminName[MAX_NAME_LENGTH]
		read_argv(1,sBanId,MAX_NAME_LENGTH)
		read_argv(2,sReason,MAX_TEXT_LENGTH)
		get_user_authid(id,sAdminId,MAX_NAME_LENGTH)
		get_user_name(id,sAdminName,MAX_NAME_LENGTH)
				
		// Do query
		format(sQuery,MAX_TEXT_LENGTH,"DELETE FROM banned WHERE banid='%s'",sBanId)
		mysql_query(iMysql,sQuery)
		client_print(id,print_console,"[AMX] The wonid/ip ^"%s^" has been unbanned.",sBanId)
		log_to_file(logfilename,"^"%s<%d><%s><>^" unbanned ^"%s^" for ^"%s^"",sAdminName,get_user_userid(id),sAdminId,sBanId,sReason)

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
			console_print(id,"[AMX] Found multiple clients. Try again.")
			return 0
		}
	}
	else {
		player = find_player("c",arg)
	}
	if (!player){
		console_print(id,"[AMX] Client with that authid or part of nick not found")
		return 0
	}
	return player
}

// Get a player's authid
public admin_getid(id)
{
	// Check access level
	if (!(get_user_flags(id)&ACCESS_LEVEL)) {
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_HANDLED
	}

	// Check arguments
	if (read_argc() < 2) {
		console_print(id,"[AMX] Usage: amx_getid < part of name >")
		return PLUGIN_HANDLED
	}

	// Get data
	new sArg1[MAX_NAME_LENGTH]
	read_argv(1,sArg1,MAX_NAME_LENGTH)
	
	// Player checks
	new iPlayer = player_find(id,sArg1)
	if (iPlayer) {
		new sName[MAX_NAME_LENGTH], sAuthid[MAX_NAME_LENGTH], sMsg[MAX_TEXT_LENGTH]
		get_user_name(iPlayer,sName,MAX_NAME_LENGTH)
		get_user_authid(iPlayer,sAuthid,MAX_NAME_LENGTH)
		format(sMsg,MAX_TEXT_LENGTH,"* ^"%s^"'s authid is %s",sName,sAuthid)
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
	if (!is_user_bot(id)) {
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
			format(sQuery,MAX_TEXT_LENGTH,"SELECT banid FROM banned WHERE banid='%s'",sIPAddress)
			mysql_query(iMysql,sQuery)

			// If result, then player is banned
			if (mysql_nextrow(iMysql)) {
				log_to_file(logfilename,"^"%s<%d><%s><>^" from ^"%s^" was rejected by ip address.",sName,get_user_userid(id),sAuthid,sIPAddress)
				client_cmd(id,"clear;echo * You are banned from this server.;disconnect")
				return PLUGIN_HANDLED
			}
			mysql_close(iMysql)
		}
	}
	return PLUGIN_CONTINUE
}

public client_authorized(id)
{
	if (!is_user_bot(id)) {
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
        	        new sName[MAX_NAME_LENGTH]
	                get_user_authid(id,sAuthid,MAX_NAME_LENGTH)
        	        get_user_name(id,sName,MAX_NAME_LENGTH)

	                // Do query
        	        format(sQuery,256,"SELECT banid FROM banned WHERE banid='%s'",sAuthid)
                	mysql_query(iMysql,sQuery)

	                // If result, then player is banned
        	        if (mysql_nextrow(iMysql)) {
                	        log_to_file(logfilename,"^"%s<%d><%s><>^" was rejected by STEAM id.",sName,get_user_userid(id),sAuthid)
	                        client_cmd(id,"clear;echo * You are banned from this server.;disconnect")
        	                return PLUGIN_HANDLED
                	}
	                mysql_close(iMysql)
	        }
	}
        return PLUGIN_CONTINUE
}


public plugin_init() 
{ 
	register_plugin("Plugin MySQL Ban","1.1","mike_cao")
	register_cvar("amx_mysql_host","127.0.0.1")
	register_cvar("amx_mysql_user","root")
	register_cvar("amx_mysql_pass","")
	register_cvar("amx_mysql_db","amx")
	
	register_concmd("amx_mysql_ban","admin_mysql_ban",ACCESS_LEVEL,"amx_mysql_ban < authid | ip > < reason >")
	register_concmd("amx_mysql_unban","admin_mysql_unban",ACCESS_LEVEL,"amx_mysql_unban < authid | ip > < reason >")
	register_concmd("amx_getwonid","admin_getid",ACCESS_LEVEL,"amx_getid < part of name >")
	register_concmd("amx_getip","admin_getip",ACCESS_LEVEL,"amx_getip < part of name >")
	
	return PLUGIN_CONTINUE
} 

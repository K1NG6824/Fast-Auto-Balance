#include <cstrike>
#include <csgo_colors>

int 	g_iMaxDopust;
bool 	g_bMSG, 
		g_bAflag;
char 	gsAflag[32];

public Plugin: myinfo =
{
	name = "Fast Auto Balance",
	author = "K1NG",
	version = "1.1",
	url = "https://projecttm.ru/"
};

public OnPluginStart()
{
	LoadTranslations("k1_fab.phrases");
	HookEvent("player_death",Event_Death);
	KeyValues hKv = new KeyValues("FAB");
	
	if(!FileToKeyValues(hKv, "addons/sourcemod/configs/FAB.cfg") )
	{
		SetFailState("Не удалось открыть файл %s", "addons/sourcemod/configs/FAB.cfg");
		return;
	}
 
	g_iMaxDopust = hKv.GetNum("MaxAD", 1);
	g_bMSG = !!hKv.GetNum("msg", 1);
	g_bAflag = !!hKv.GetNum("admin_imune", 1);
    hKv.GetString("admin_flags", gsAflag, sizeof(gsAflag), "z");
	if(g_iMaxDopust < 1)
		g_iMaxDopust = 1;
	delete hKv;
}

public void Event_Death(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if(GetClientTeam(iClient) <= CS_TEAM_SPECTATOR)
		return;

 	int ClientT, ClientCT;
 	for(int i = 1; i <= MaxClients; i++)
	{
		if(ValidClient(i)) 
		{
			if(GetClientTeam(i) == CS_TEAM_T)
				ClientT++;
			else if(GetClientTeam(i) == CS_TEAM_CT)
				ClientCT++;
		}
	}
	if(ClientT > ClientCT)
	{
		if(ClientT-ClientCT > g_iMaxDopust && ValidClient(iClient) && GetClientTeam(iClient) == CS_TEAM_T && (!g_bAflag || !CheckFlags(iClient, gsAflag)))
		{
			CS_SwitchTeam(iClient, CS_TEAM_CT);
			if(g_bMSG) CGOPrintToChat(iClient, "%T", "FAB_Chat_CT", iClient);
		}
	}
	else if(ClientT < ClientCT)
	{
		if(ClientCT-ClientT > g_iMaxDopust && ValidClient(iClient) && GetClientTeam(iClient) == CS_TEAM_CT && (!g_bAflag || !CheckFlags(iClient, gsAflag)))
		{
			CS_SwitchTeam(iClient, CS_TEAM_T);
			if(g_bMSG) CGOPrintToChat(iClient, "%T", "FAB_Chat_T", iClient);
		}
	}
}

stock bool ValidClient(int client, bool bots = true, bool dead = true)
{
	if (client <= 0)
		return false;

	if (client > MaxClients)
		return false;

	if (!IsClientInGame(client))
		return false;

	if (IsFakeClient(client) && !bots)
		return false;

	if (IsClientSourceTV(client))
		return false;

	if (IsClientReplay(client))
		return false;

	if (!IsPlayerAlive(client) && !dead)
		return false;

	return true;
}

stock bool CheckFlags(int client, const char[] flags)
{
	if(ReadFlagString(flags) & GetUserFlagBits(client))
		return true;

	return false;
}
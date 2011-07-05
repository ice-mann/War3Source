

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"


public Plugin:myinfo= 
{
	name="W3S Engine HP Regen",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};


new Float:nextRegenTime[MAXPLAYERSCUSTOM];
new tf2displayskip[MAXPLAYERSCUSTOM];
public OnPluginStart()
{

}

public OnGameFrame()
{
	decl Float:playervec[3];
		
	new Float:now=GetEngineTime();
	for(new client=1;client<=MaxClients;client++)
	{
		if(ValidPlayer(client,true))
		{
			if(nextRegenTime[client]<now){
				new Float:fbuffsum=0.0;
				if(!W3GetBuffHasTrue(client,bBuffDenyAll)){
					fbuffsum+=W3GetBuffSumFloat(client,fHPRegen);
				}
				fbuffsum-=W3GetBuffSumFloat(client,fHPDecay);
				//PrintToChat(client,"regein tick %f %f",fbuffsum,now);
				if(fbuffsum>0.01){ //heal
					War3_HealToMaxHP(client,1);  
					
					if(War3_GetGame()==TF){
						tf2displayskip[client]++;
						if(tf2displayskip[client]>4){
							new Float:VecPos[3];
							GetClientAbsOrigin(client,VecPos);
							VecPos[2]+=55.0;
							War3_TF_ParticleToClient(0, GetClientTeam(client)==2?"healthgained_red":"healthgained_blu", VecPos);
							tf2displayskip[client]=0;
						}
					}
				}
				if(fbuffsum<0.01){ //decay
					if(War3_GetGame()==Game_TF&&W3Chance(0.25)){
						GetClientAbsOrigin(client,playervec);
						War3_TF_ParticleToClient(0, GetClientTeam(client)==2?"healthlost_red":"healthlost_blu", playervec);
					}
					if(GetClientHealth(client)>1){
						SetEntityHealth(client,GetClientHealth(client)-1);
						
					}
					else{
						War3_DealDamage(client,1,_,_,GameTF()?"bleed_kill":"damageovertime",_,W3DMGTYPE_TRUEDMG);
					}
				}
				new Float:nexttime=FloatAbs(1.0/fbuffsum);
				if(nexttime<2.0&&nexttime>0.01){
					//ok we use this value
					//DP("nexttime<1.0&&nexttime>0.01");
				}
				else{
					nexttime=2.0;
				}
				nextRegenTime[client]=now+nexttime;
			}
		}
	}
}
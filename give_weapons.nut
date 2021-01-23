IncludeScript("vs_library")

::SMain <- this;
::mainScript <- 0;

function OnPostSpawn() 
{
	mainScript = self.GetScriptScope();
}

::OnGameEvent_round_start <- function(data)
{
	SendToConsole("mp_respawn_immunitytime 0")
	//SendToConsole("bot_kick")
	// reset all
	foreach(ply in ::VS.GetAllPlayers())
	{
		local s = _init_scope(ply);
		if(s.bot == false && s.networkid != "BOT")
		{
			for(local i = 0; i < 13; i+=4)
			{
				if(playerEquipment[i] == s.userid)
				{
					i = 100;
				}
				else if(playerEquipment[i] == "null" &&s.userid != "" && s.userid != null)
				{
					ScriptPrintMessageChatAll(" \x04 Assigning ID \x07"+s.userid+"\x04 to \x07"+s.name);
					ScriptPrintMessageChatAll(" \x04 Network ID \x07"+s.networkid)
					playerEquipment[i] = s.userid;
					givePlayerWeapons(s.userid)
					i = 100;
				}
			}
		}
		else
		{
			if(false)
			{
				ScriptPrintMessageChatAll(" \x04 Network ID: \x07"+s.networkid)
				ScriptPrintMessageChatAll(" \x04 Name: \x07"+s.name)
				ScriptPrintMessageChatAll(" \x04 UserID: \x07"+s.userid)
				ScriptPrintMessageChatAll(" \x04 Bot: \x07"+s.bot)
			}
			
			giveBotWeapons(s.userid);
		}
	
	}

	local ft = FrameTime();
	foreach( i,v in ::VS.GetAllPlayers() )
		::delay("::VS.Events.ForceValidateUserid(activator)", i*ft, ::ENT_SCRIPT, v);

}.bindenv(this);
function giveBotWeapons(id)
{
	local player = VS.GetPlayerByUserid(id);
			
	EntFire("equip_strip", "Use", "", 0, player);
		
	equipPlayerArmor(player);

	//EquipWeapon("weapon_ak47",60,player)
		
	EquipWeapon("weapon_glock",60,player)
	
	EquipWeapon("weapon_knife",60,player)
}

::_init_scope <- function(s)
{
	s.ValidateScriptScope();
	s = s.GetScriptScope();
	if( !("userid" in s) ) s.userid <- "";
	if( !("networkid" in s) ) s.networkid <- "";
	if( !("name" in s) ) s.name <- "";
	if( !("bot" in s) ) s.bot <- s.networkid == "BOT";
	return s;
}
::OnGameEvent_player_say <- function( data )
{
	local msg = data.text				// get the chat message
	if(msg.slice(0,1) != "!") return	// if the message isn't a command, leave
	
	local id = data.userid;
	
	SMain.SayCommand(msg.slice(1), id)
	
	SMain.givePlayerWeapons(id);
}

function SayCommand( msg, id)
{
	local buffer = split( msg, " " )
	local val, cmd = buffer[0]

	if( buffer.len() > 1 )
    {
        val = buffer[1];
    }
    
    //val = val.tointeger();
    for(local i = 0; i < 13; i+=4)
    {
        if(id == playerEquipment[i])
        {
            switch(cmd.tolower())
            {
                case "g":
                case "gun":
					if(SetPrimary(val,i) == true)
					{
						ScriptPrintMessageChatAll("Primary: "+ playerEquipment[i+1]);
					}
                    break;
                case "p":
                case "pistol":
					if(SetPistol(val,i) == true)
					{
						ScriptPrintMessageChatAll("Pistol: "+ playerEquipment[i+2]);
					}
                    break;
                case "k":
                case "knife":
					if(SetKnife(val,i) == true)
					{
						ScriptPrintMessageChatAll("Knife: "+ playerEquipment[i+3]);
					}
                    break;
				case "hs":
				case "headshot":
					HeadshotOnly();
					break;
				case "arm":
					ScriptPrintMessageChatAll("Arm attached");
					break;
				case "a":
				case "armor":
				case "armour":
				case "kev":
				case "kevlar":
					if(equipArmor == true)
					{
						ScriptPrintMessageChatAll("Armor is: Off");
						equipArmor = false;
					}
					else
					{
						ScriptPrintMessageChatAll("Armor is: On");
						equipArmor = true;
					}
					armorChanged = true;
					break;
				case "h":	
				case "help":
					ScriptPrintMessageChatAll(" \x04 !a: \x05 armor");
					ScriptPrintMessageChatAll(" \x04 !b: \x05 bump mines");
					ScriptPrintMessageChatAll(" \x04 !helm: \x05 helmet");
					ScriptPrintMessageChatAll(" \x04 !hs: \x05 headshot only");
					ScriptPrintMessageChatAll(" \x04 !g: \x05 guns");
					ScriptPrintMessageChatAll(" \x04 !p: \x05 pistols");
					ScriptPrintMessageChatAll(" \x04 !k: \x05 knives");
					break;
				case "helm":
				case "helmet":
					if(equipHelmet == true)
					{
						ScriptPrintMessageChatAll("Helmet is: Off");
						equipHelmet = false;
					}
					else
					{
						ScriptPrintMessageChatAll("Helmet is: On");
						equipHelmet = true;
					}
					armorChanged = true;
					break;
				case "b":
				case "bump":
				case "bumpmines":
					if(giveBumpMines == true)
					{
						SendToConsole("sv_falldamage_scale 1");
						ScriptPrintMessageChatAll("Bump Mines: Off");
						giveBumpMines = false;
					}
					else
					{
						SendToConsole("sv_falldamage_scale 0");
						ScriptPrintMessageChatAll("Bump Mines: On");
						giveBumpMines = true;
					}
					armorChanged = true;
					break;
                default:
                    ScriptPrintMessageChatAll("Invalid command.");
                    break;
            }
        }
    }
}

function SetPrimary(val,i)
{
	if(val != null)
	{
	switch (val.tolower())
	{
	//Rifle
	case "ak47":
	case "ak":
		playerEquipment[i + 1] = "weapon_ak47";
		break;
	case "m4":
	case "m4a4":
		playerEquipment[i + 1] = "weapon_m4a1";
		break;
	case "m4a1":
	case "m4a1s":
		playerEquipment[i + 1] = "weapon_m4a1_silencer";
		break;
	case "aug":
		playerEquipment[i + 1] = "weapon_aug";
		break;
	case "sg":
	case "sg553":
	case "codgun":
		playerEquipment[i + 1] = "weapon_sg556";
		break;
	case "galil":
	case "gal":
		playerEquipment[i + 1] = "weapon_galilar";
		break;
	case "fam":
	case "famas":
		playerEquipment[i + 1] = "weapon_famas";
		break;
	case "awp":
		playerEquipment[i + 1] = "weapon_awp";
		break;
	case "ssg":
	case "ssg08":
	case "scout":
	case "scoot":
		playerEquipment[i + 1] = "weapon_ssg08";
		break;
	case "g3sg1":
	case "dakdak":
	case "dak":
	case "g3":
		playerEquipment[i + 1] = "weapon_g3sg1";
	case "scar":
	case "scar20":
		playerEquipment[i + 1] = "weapon_scar20";
		break;
		
	//Heavy
	case "nova":
		playerEquipment[i + 1] = "weapon_nova";
		break;
	case "xm":
	case "xm1014":
		playerEquipment[i + 1] = "weapon_xm1014";
		break;
	case "saw":
	case "sawedoff":
		playerEquipment[i + 1] = "weapon_sawedoff";
		break;
	case "mag":
	case "mag7":
		playerEquipment[i + 1] = "weapon_mag7";
		break;
	case "m249":
	case "m2":
	case "m24":
		playerEquipment[i + 1] = "weapon_m249";
		break;
	case "negev":
	case "neg":
		playerEquipment[i + 1] = "weapon_negev";
		break;
		
	//Smg
	case "mac":
	case "mac10":
		playerEquipment[i + 1] = "weapon_mac10";
		break;	
	case "mp9":
		playerEquipment[i + 1] = "weapon_mp9";
		break;
	case "mp7":
		playerEquipment[i + 1] = "weapon_mp7";
		break;
	case "mp5":
	case "mp5sd":
		playerEquipment[i + 1] = "weapon_mp5sd";
		break;			
	case "p90":
		playerEquipment[i + 1] = "weapon_p90";
		break;
	case "ump":
	case "ump45":
		playerEquipment[i + 1] = "weapon_ump45";
		break;
	case "bizon":
	case "pp":
	case "ppbizon":
		playerEquipment[i + 1] = "weapon_bizon";
		break;	
	default:
		ScriptPrintMessageChatAll("Invalid command.");
		return false;
		break;
	}
	}
	else
	{
		ScriptPrintMessageChatAll(" \x04 Rifles:");
		ScriptPrintMessageChatAll(" \x05 AK-47, M4A4, M4A1-S, Aug, SG 553, Galil AR, Famas, AWP, Scar-20");
		ScriptPrintMessageChatAll(" \x05 G3SG1");
		ScriptPrintMessageChatAll(" \x04 Heavy:")
		ScriptPrintMessageChatAll(" \x05 Nova, XM1014, Sawed-Off, Mag-7, M249, Negev");
		ScriptPrintMessageChatAll(" \x04 SMGs:");
		ScriptPrintMessageChatAll(" \x05 Mac-10, MP9, MP7, MP5-SD, P90, UMP-45, PP-Bizon");
		return false;
	}
	return true;
}
function SetPistol(val,i)
{
	if(val != null)
	{
	switch (val.tolower())
	{
		
	case "usp":
	case "usp-s":
		playerEquipment[i + 2] = "weapon_usp_silencer";
		break;
		
	case "p2000":
	case "p2k":
	case "p200":
		playerEquipment[i + 2] = "weapon_hkp2000";
		break;
		
	case "glock":
	case "glock18":
		playerEquipment[i + 2] = "weapon_glock";
		break;	
		
	case "tec":
	case "tec9":
		playerEquipment[i + 2] = "weapon_tec9";
		break;
		
	case "fiveseven":
	case "57":
	case "five":
	case "seven":
		playerEquipment[i + 2] = "weapon_fiveseven";
		break;
	
	case "dual":
	case "dualies":
	case "berettas":
	case "dualberettas":
		playerEquipment[i + 2] = "weapon_elite";
		break;
	
	case "deagle":
	case "deag":
		playerEquipment[i + 2] = "weapon_deagle";
		break;
	
	case "p250":
	case "p25":
	case "p2":
		playerEquipment[i + 2] = "weapon_p250";
		break;
	
	case "cz":
	case "cz75":
	case "cz75a":
		playerEquipment[i + 2] = "weapon_cz75a";
		break;
		
	case "rev":
	case "revolver":
	case "yeehaw":
	case "r8":
		playerEquipment[i + 2] = "weapon_revolver";
		break;
		
	default:
		ScriptPrintMessageChatAll("Invalid command.");
		return false;
		break;
	}
	}
	else
	{
		ScriptPrintMessageChatAll(" \x04 Pistols: ")
		ScriptPrintMessageChatAll(" \x05 USP-S, P200, Glock, Tec-9, FiveSeven, Dual Berettas, P250");
		ScriptPrintMessageChatAll(" \x05 CZ-75, Deagle, Revolver");
		return false;
	}
	return true;
}
function SetKnife(val,i)
{
	if(val != null)
	{
		switch (val.tolower())
	{
	case "m9":
		playerEquipment[i + 3] = "weapon_knife_m9_bayonet";
		break;
	case "bay":
	case "bayonet":
		playerEquipment[i + 3] = "weapon_bayonet";
		break;
	case "butt":
	case "butterfly":
		playerEquipment[i + 3] = "weapon_knife_butterfly";
		break;
	case "karambit":
	case "kara":
		playerEquipment[i + 3] = "weapon_knife_karambit";
		break;
	case "flip":
		playerEquipment[i + 3] = "weapon_knife_flip";
		break;
	case "falcon":
	case "falchion":
	case "fal":
	case "falc":
		playerEquipment[i + 3] = "weapon_knife_falchion";
		break;
	case "gut":
		playerEquipment[i + 3] = "weapon_knife_gut";
		break;
	case "hunt":
	case "huntsman":
		playerEquipment[i + 3] = "weapon_knife_tactical";
		break;
	case "buttplugs":
	case "buttplug":
	case "shadow":
	case "daggers":
	case "dagger":
	case "shadowdaggers":
	case "shadowdagger":
		playerEquipment[i + 3] = "weapon_knife_push";
		break;
	case "bowie":
	case "bow":
		playerEquipment[i + 3] = "weapon_knife_survival_bowie";
		break;
	case "ursus":
	case "ur":
		playerEquipment[i + 3] = "weapon_knife_ursus";
		break;
	case "navaja":
	case "nava":
		playerEquipment[i + 3] = "weapon_knife_gypsy_jackknife";
		break;
	case "stiletto":
	case "stil":
		playerEquipment[i + 3] = "weapon_knife_stiletto";
		break;
	case "talon":
	case "tal":
		playerEquipment[i + 3] = "weapon_knife_widowmaker";
		break;
	case "classic":
	case "class":
	case "css":
		playerEquipment[i + 3] = "weapon_knife_css";
		break;
	case "skel":
	case "skeleton":
		playerEquipment[i + 3] = "weapon_knife_skeleton";
		break;
	case "gold":
		playerEquipment[i + 3] = "weapon_knifegg";
		break;
	case "nomad":
	case "nom":
	case "no":
		playerEquipment[i + 3] = "weapon_knife_outdoor";
		break;
	case "paracord":
	case "para":
		playerEquipment[i + 3] = "weapon_knife_cord";
		break;	
	case "survival":
	case "sur":
		playerEquipment[i + 3] = "weapon_knife_canis";
		break;			
	case "ghost":
		playerEquipment[i + 3] = "weapon_knife_ghost";
		break;
	default:
		ScriptPrintMessageChatAll("Invalid command.");
		return false;
		break;
	}
	}
	else
	{
		ScriptPrintMessageChatAll(" \x04 Knives: ");
		ScriptPrintMessageChatAll(" \x05 M9, Bayonet, Butterfly, Karambit, Flip, Huntsman, Shadow Daggers");
		ScriptPrintMessageChatAll(" \x05 Bowie, Ursus, Navaja, Stiletto, Talon, Classic, Skeleton, Nomad");
		ScriptPrintMessageChatAll(" \x05 Paracord, Survival, Ghost, Gold, Falchion");
		return false;
	}
	return true;
}

function givePlayerWeapons(id)
{
	//might need to change to stripknife and shit because i need to keep the players armor
	for(local i = 0; i < 13; i+=4)
    {
        if(playerEquipment[i] != "null" && playerEquipment[i] == id)
        {
            local player = VS.GetPlayerByUserid(playerEquipment[i]);
			
			//stripPrimary(player);
			//stripKnife(player);

			EntFire("equip_strip", "Use", "", 0, player);
			
			equipPlayerArmor(player);

            EquipWeapon(playerEquipment[i+1],60,player)
			
            EquipWeapon(playerEquipment[i+2],60,player)
			
            EquipWeapon(playerEquipment[i+3],60,player)
            EntFire("weapon_knife", "addoutput", "classname weapon_knifegg")
        }
    }
}
function equipPlayerArmor(player)
{
	if(equipArmor == true && equipHelmet == true)
	{
		EquipWeapon("item_assaultsuit",60,player);
	}
	else if(equipArmor == true)
	{
		EquipWeapon("item_kevlar",60,player)
	}
	if(giveBumpMines == true)
	{
		EquipWeapon("weapon_bumpmine",60,player);
		EquipWeapon("weapon_bumpmine",60,player);
	}
}
function giveServerWeapons()	//Called on player spawn - fired once - when more than one person spawns this would fire multiple times
{
	for(local i = 0; i < 13; i+=4)
    {
        if(playerEquipment[i] != "null")
        {
            local player = VS.GetPlayerByUserid(playerEquipment[i]);
			
			EntFire("equip_strip", "Use", "", 0, player);
			
			equipPlayerArmor(player);

            EquipWeapon(playerEquipment[i+1],60,player)
			
            EquipWeapon(playerEquipment[i+2],60,player)
			
            EquipWeapon(playerEquipment[i+3],60,player)
            EntFire("weapon_knife", "addoutput", "classname weapon_knifegg")
        }
    }
}
function stripKnife(ply)
{
    local knife = Entities.FindByClassnameWithin(null,"weapon_knife",ply.GetOrigin(),2.0);
    
    if(knife) 
    {
        ScriptPrintMessageChatAll("knife dead");
        knife.Destroy();
    }
    
    local egg = Entities.FindByClassnameWithin(null,"weapon_knifegg",ply.GetOrigin(),2.0);
    
    if(egg) 
    {
        ScriptPrintMessageChatAll("egg dead");
        egg.Destroy();
    }
    
    local fist = Entities.FindByClassnameWithin(null,"weapon_fist",ply.GetOrigin(),2.0);
    
	if(fist) 
    {
        ScriptPrintMessageChatAll("fist dead");
        fist.Destroy();
    }
}

function reset()
{
    for(local i = 0; i < 13; i+=4)
    {
        ScriptPrintMessageChatAll("Playerid "+playerEquipment[i]+" is now null");
        playerEquipment[i] = "null";
    }
}

function EquipWeapon(weapon, ammo, player)
{
    //Make required entities
    local equip = Entities.CreateByClassname("game_player_equip")
    equip.__KeyValueFromInt(weapon, ammo)

    //Give weapon to the player
    EntFireByHandle(equip, "use", "", 0, player, player)
    
    //Destroy the entity so we don't end up with a bunch of them
    equip.Destroy()
}

function HeadshotOnly()
{
	if(headshotOnly == true)
	{
		headshotOnly = false;
		SendToConsole("mp_damage_headshot_only 0");
		ScriptPrintMessageChatAll("Headshot Only: Off");
	}
	else
	{
		headshotOnly = true;
		SendToConsole("mp_damage_headshot_only 1");
		ScriptPrintMessageChatAll("Headshot Only: On")
	}
}


function ServerCommands()	//This is not used because logic auto is better//good for reference though
{
	//invunrabiltity
	SendToConsole("mp_respawn_immunitytime 0")

	//end warmup
	SendToConsole("mp_warmup_end")
	SendToConsole("mp_warmuptime 0")

	//roundtime
	SendToConsole("mp_roundtime 60")
	SendToConsole("mp_roundtime_defuse 60")
	SendToConsole("mp_roundtime_hostage 60")
	SendToConsole("mp_timelimit 0")

	//maxrounds
	SendToConsole("mp_maxrounds 100")

	//halftime
	SendToConsole("mp_halftime 0")
	SendToConsole("mp_halftime_duration 0")

	//roundtimedelays
	SendToConsole("mp_round_restart_delay 1")
	SendToConsole("mp_freezetime 0")

	//ffa
	SendToConsole("mp_solid_teammates 1")
	SendToConsole("mp_teammates_are_enemies 1")
	SendToConsole("mp_autokick 0")
	SendToConsole("mp_autoteambalance 0")
	//nextmap
	SendToConsole("mp_endmatch_votenextmap 0")
	SendToConsole("mp_endmatch_votenextmap_keepcurrent 1")

	//spectators
	SendToConsole("mp_forcecamera 0")

	//default weapons
	SendToConsole("mp_ct_default_primary 0")
	SendToConsole("mp_ct_default_secondary 0")
	SendToConsole("mp_t_default_primary 0")
	SendToConsole("mp_t_default_secondary 0")
}

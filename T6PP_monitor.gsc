#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;

main()
{
    file = fs_fopen("timer", "write");
    fs_write( file, "0|0" );
    fs_fclose( file );
}

init()
{
    flag_init("timer_start");
    level.papm_version = "v1.2";
    level.split_number = 0;
    level thread on_player_connect();
}

on_player_connect()
{
    level waittill( "connected", player );
    if(getdvar("scr_allowFileIo") == "")
    {
        player iprintln("^8[^3T6EE^8][^5" + level.papm_version + "^8]^1 Unsupported plutonium version! Update your client");
        return;
    }

    setdvar("scr_allowFileIo", 1);
    setdvar("cg_flashScriptHashes", 1);

    if(victis_map())
    {
        level thread upgrade_dvars();
        player thread persistent_upgrades_bank();
    }
    level thread game_start_wait();
    level thread game_over_wait();
    level thread gametime_monitor();
    level thread split_monitor();
    player thread on_player_spawned();
}

game_start_wait()
{
    if(level.script == "zm_prison")
    {
        level thread mob_start_wait();
    }
    flag_wait( "initial_blackscreen_passed" );
    flag_set("timer_start");
}


mob_start_wait()
{
    runner = getplayers()[0];
    while(!flag("timer_start"))
    {
        if(isdefined(runner.afterlife_visionset) && runner.afterlife_visionset == 1)
        {
            wait 0.45;
            flag_set("timer_start");
        }
        wait 0.05;
    }
}

game_over_wait()
{
    flag_init("game_over");
    level waittill( "end_game" );
    wait 1;
    flag_set("game_over");
}

gametime_monitor()
{
    flag_wait("timer_start");
    start_time = getTime();
    while(!flag("game_over"))
    {
        if(level.split_number == level.splits.size) flag_set("game_over");
        timer_file = fs_fopen("timer", "write");
        str = level.split_number + "|" + (getTime() - start_time);
        fs_write( timer_file, str );
        fs_fclose( timer_file );
        wait 0.05;
    }
}

split_monitor()
{
    switch(level.script)
    {
        case "zm_buried":
            level.splits = strtok("paralyzer|power_on|mansion|pack_a_punch", "|");
            break;

        default:
            break;
    }

    flag_wait("timer_start");
    while(level.split_number < level.splits.size)
    {
        check_split(level.splits[level.split_number], is_flag(level.splits[level.split_number]));
        level.split_number++;
    }
}


check_split(split, is_flag)
{
    if(is_flag)
    {
        flag_wait(split);
    }
    else
    {
        switch(split)
        {
            case "paralyzer":
                wait 5; // security for the start

                last_debug_time = 0;

                while (true)
                {
                    foreach(player in getplayers())
                    {
                        weapons = player GetWeaponsList();

                        // Debug une fois toutes les 2 secondes
                        if (getTime() - last_debug_time > 2)
                        {
                            last_debug_time = getTime();
                        }

                        foreach(weapon in weapons)
                        {
                            // Vérifie si le nom contient "slowgun" (plus flexible)
                            if (isSubStr(weapon, "slowgun"))
                            {
                                return;
                            }
                        }
                    }
                    wait 0.1;
                }
                break;

            case "power_on":
                while(!flag("power_on")) wait 0.05;
                break;

            case "mansion":
                mansion_origin = (2745, 825, -165);  // Coord
                mansion_radius = 500;                // radius

                while(true)
                {
                    foreach(player in getplayers())
                    {
                        if(distance(player.origin, mansion_origin) < mansion_radius)
                            return;
                    }
                    wait 0.05;
                }
                break;

            case "pack_a_punch":
                wait 5; // petite pause de sécurité
                last_debug_time = 0;

                while (true)
                {
                    foreach(player in getplayers())
                    {
                        weapons = player GetWeaponsList();

                        // Debug une fois toutes les 2 secondes
                        if (getTime() - last_debug_time > 2)
                        {
                            last_debug_time = getTime();
                        }

                        foreach(weapon in weapons)
                        {
                            // Détection Paralyzer PAP
                            if (isSubStr(weapon, "slowgun") && (isSubStr(weapon, "_upgraded_zm") || isSubStr(weapon, "_pap")))
                            {
                                player iprintln("^7Well played, ^1BornFat ^7didn't think you'd make it! (jk wp)");
                                return;
                            }
                        }
                    }
                    wait 0.1;
                }
                break;
        }
    }
}


is_flag(split_name)
{
    switch(split_name)
    {
        case "paralyzer":
        case "power_on":
        case "mansion":
        case "pack_a_punch":
            return 0;
        default:
            return 1;
    }
}


show_start_message()
{
    flag_wait( "initial_players_connected" );
    wait 1;

    self iprintln("^8[^3T6PAP^8] [^5" + level.papm_version + "^8] ^8github.com/kerogs/T6PAP-LiveSplit ^8[^1Made in BornFat^8]");
}

upgrade_dvars()
{
    foreach(upgrade in level.pers_upgrades)
    {
        foreach(stat_name in upgrade.stat_names)
        {
            level.eet_upgrades[level.eet_upgrades.size] = stat_name;
        }
    }

    create_bool_dvar("full_bank", 1);
    create_bool_dvar("pers_insta_kill", level.script != "zm_transit");

    foreach(pers_perk in level.eet_upgrades)
    {
        create_bool_dvar(pers_perk, 1);
    }
}

persistent_upgrades_bank()
{
    foreach(upgrade in level.pers_upgrades)
    {
        for(i = 0; i < upgrade.stat_names.size; i++)
        {
            val = (getdvarint(upgrade.stat_names[i]) > 0) * upgrade.stat_desired_values[i];
            self maps\mp\zombies\_zm_stats::set_client_stat(upgrade.stat_names[i], val);
        }
    }

    flag_wait("initial_blackscreen_passed");
    if(getdvarint("full_bank"))
    {
        self maps\mp\zombies\_zm_stats::set_map_stat("depositBox", level.bank_account_max, level.banking_map);
        self.account_value = level.bank_account_max;
    }
}

victis_map()
{
    return (level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried");
}


create_bool_dvar( dvar, start_val )
{
    if( getdvar( dvar ) == "" ) setdvar( dvar, start_val);
}

array_contains(arr, val)
{
    for(i = 0; i < arr.size; i++)
    {
        if(arr[i] == val) return true;
    }
    return false;
}

on_player_spawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self thread show_start_message();
    }
}
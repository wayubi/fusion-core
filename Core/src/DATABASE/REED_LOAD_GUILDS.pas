unit REED_LOAD_GUILDS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Guilds_Pre_Parse(UID : String = '*');
    procedure PD_Load_Guilds_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);

    procedure PD_Load_Guilds_Settings(tg : TGuild; path : String);

    function select_load_guild(UID : String; tp : TPlayer; guildid : Cardinal) : TGuild;
    function guild_is_online(tg : TGuild) : Boolean;

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Guilds Pre Parse --------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Pre_Parse(UID : String = '*');
    var
        basepath : String;
        pfile : String;
        accountlist : TStringList;
        i : Integer;
        tp : TPlayer;
    begin
        basepath := AppPath + 'gamedata\Accounts\';
        pfile := 'Account.txt';
        accountlist := get_list(basepath, pfile);

        basepath := AppPath + 'gamedata\Guilds\';

        for i := 0 to accountlist.Count - 1 do begin
            if Player.IndexOf(reed_convert_type(accountlist[i], 0, -1)) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(reed_convert_type(accountlist[i], 0, -1))] as TPlayer;

            pfile := 'Guild.txt';
            PD_Load_Guilds_Parse(UID, tp, get_list(basepath, pfile), basepath);

            if (UID <> '*') then Break;
        end;

        FreeAndNil(accountlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Guilds Parse ------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);
    var
        i : Integer;
        pfile : String;
        path : String;
        tg : TGuild;
    begin

        for i := 0 to resultlist.Count - 1 do begin
            path := basepath + resultlist[i] + '\';

            tg := select_load_guild(UID, tp, reed_convert_type(resultlist[i], 0, -1));
            if not assigned(tg) then Continue;

            if (UID <> '*') then
                if guild_is_online(tg) then Continue;


            pfile := 'Guild.txt';
            PD_Load_Guilds_Settings(tg, path + pfile);


            NowGuildID := (tg.ID + 1);

            if (UID = '*') then begin
                GuildList.AddObject(tg.ID, tg);
            end;

        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Guilds Settings ---------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Settings(tg : TGuild; path : String);
    begin
        tg.Name := retrieve_data(0, path);
        tg.ID := retrieve_data(1, path, 1);
        tg.LV := retrieve_data(2, path, 1);
        tg.EXP := retrieve_data(3, path, 1);
        tg.NextEXP := GExpTable[tg.LV];
        tg.GSkillPoint := retrieve_data(4, path, 1);
        tg.Notice[0] := retrieve_data(5, path);
        tg.Notice[1] := retrieve_data(6, path);
        tg.Agit := retrieve_data(7, path);
        tg.Emblem := retrieve_data(8, path, 1);
        tg.Present := retrieve_data(9, path, 1);
        tg.DisposFV := retrieve_data(10, path, 1);
        tg.DisposRW := retrieve_data(11, path, 1);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Parties Members ---------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Parties_Members(tpa : TParty; path : String);
    var
        i, j : Integer;
        tc : TChara;
    begin

        for i := 0 to 11 do begin
            tpa.MemberID[i] := 0;
        end;

        for i := 0 to retrieve_length(path) do begin
            j := retrieve_value(path, 0, 0);

            if Chara.IndexOf(j) = -1 then Continue;
            tc := Chara.Objects[Chara.IndexOf(j)] as TChara;

            tpa.MemberID[i] := j;
            tpa.Member[i] := tc;
            tc.PartyName := tpa.Name;
            tc.PartyID := tpa.ID;
        end;

    end;
    { ------------------------------------------------------------------------------------- }

    

    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - Party Supplemental Functions                                                }
    { ------------------------------------------------------------------------------------- }

    
    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - select_load_guild                                                           }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To allow guild parsing to create or select the proper guild for loading.     }
    { Parameters:                                                                           }
    {  - UID : String, Represents the account ID to load.                                   }
    {  - tp : TPlayer, Represents the player data.                                          }
    {  - guildid : Cardinal, Represents the guild's ID.                                     }
    { Results:                                                                              }
    {  - Result : TParty, Represents the selected guild.                                    }
    { ------------------------------------------------------------------------------------- }
    function select_load_guild(UID : String; tp : TPlayer; guildid : Cardinal) : TGuild;
    var
        i : Integer;
        tg : TGuild;
    begin

        if (UID <> '*') then begin

            for i := 0 to 8 do begin
                if tp.CName[i] = '' then Continue;
                if tp.CData[i] = nil then Continue;

                if (tp.CData[i].GuildID = guildid) then begin
                    if GuildList.IndexOf(guildid) = -1 then Continue;
                    tg := GuildList.Objects[GuildList.IndexOf(guildid)] as TGuild;
                    Break;
                end;
            end;

        end else begin
            tg := TGuild.Create;
        end;

        Result := tg;
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - guild_is_online                                                             }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To see if any guild members are online for loading purposes.                 }
    { Parameters:                                                                           }
    {  - tg : TGuild, Represents the party data to check.                                   }
    { Results:                                                                              }
    {  - Result : Boolean, Represents the return value of whether or not onnline.           }
    { ------------------------------------------------------------------------------------- }
    function guild_is_online(tg : TGuild) : Boolean;
    var
        i : Integer;
    begin
        Result := False;

        for i := 0 to tg.RegUsers - 1 do begin
            if (tg.MemberID[i] <> 0) then begin
                if tg.Member[i].Login <> 0 then begin
                    Result := True;
                    Break;
                end;
            end;
        end;

    end;
    { ------------------------------------------------------------------------------------- }

end.

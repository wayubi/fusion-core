unit REED_LOAD_GUILDS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Guilds_Pre_Parse(UID : String = '*');
    procedure PD_Load_Guilds_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);

    procedure PD_Load_Guilds_Settings(tg : TGuild; path : String);
    procedure PD_Load_Guilds_Members(tg : TGuild; path : String);
    procedure PD_Load_Guilds_Positions(tg : TGuild; path : String);
    procedure PD_Load_Guilds_Skills(tg : TGuild; path : String);

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

            pfile := 'Members.txt';
            PD_Load_Guilds_Members(tg, path + pfile);

            pfile := 'Positions.txt';
            PD_Load_Guilds_Positions(tg, path + pfile);

            pfile := 'Skills.txt';
            PD_Load_Guilds_Skills(tg, path + pfile);


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
    { - R.E.E.D - Load Guilds Members ----------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Members(tg : TGuild; path : String);
    var
        i : Integer;
        tc : TChara;
    begin

        { -- Clear Member List -- }
        for i := 0 to tg.RegUsers - 1 do begin
            if Chara.IndexOf(tg.MemberID[i]) = -1 then Continue;
            tc := Chara.Objects[Chara.IndexOf(tg.MemberID[i])] as TChara;

            tc.GuildName := '';
            tc.GuildID := 0;
            tc.ClassName := '';
            tc.GuildPos := 0;

            if (i = 0) then tg.MasterName := '';
            tg.Member[i] := nil;
            tg.SLV := 0;
        end;
        tg.RegUsers := 0;
        { -- Clear Member List -- }

        { -- Assign Members -- }
        for i := 0 to retrieve_length(path) do begin
            tg.MemberID[i] := retrieve_value(path, i, 0);
            tg.MemberPos[i] := retrieve_value(path, i, 1);
            tg.MemberEXP[i] := retrieve_value(path, i, 2);
            if ((tg.MemberID[i]) <> 0) then Inc(tg.RegUsers, 1);

            if Chara.IndexOf(tg.MemberID[i]) = -1 then Continue;
            tc := Chara.Objects[Chara.IndexOf(tg.MemberID[i])] as TChara;

            tc.GuildName := tg.Name;
            tc.GuildID := tg.ID;
            tc.ClassName := tg.PosName[tg.MemberPos[i]];
            tc.GuildPos := i;

            if (i = 0) then tg.MasterName := tc.Name;
            tg.Member[i] := tc;
            tg.SLV := tg.SLV + tc.BaseLV;
        end;
        { -- Assign Members -- }

    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Guilds Members ----------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Positions(tg : TGuild; path : String);
    var
        i : Integer;
    begin

        for i := 0 to 19 do begin
            tg.PosName[i] := retrieve_value(path, i, 4);

            if (retrieve_value(path, i, 1) = 'Y') then tg.PosInvite[i] := True
            else tg.PosInvite[i] := False;

            if (retrieve_value(path, i, 2) = 'Y') then tg.PosPunish[i] := True
            else tg.PosPunish[i] := False;

            tg.PosEXP[i] := retrieve_value(path, i, 3);
        end;

    end;
    { ------------------------------------------------------------------------------------- }
    

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Guilds Members ----------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Guilds_Skills(tg : TGuild; path : String);
    var
        i, skillindex : Integer;
    begin

        for i := 10000 to 10004 do begin
            if GSkillDB.IndexOf(i) = -1 then Continue;
            tg.GSkill[i].Data := GSkillDB.IndexOfObject(i) as TSkillDB;
        end;

        for i := 0 to retrieve_length(path) do begin
            skillindex := retrieve_value(path, i, 0);
            if GSkillDB.IndexOf(skillindex) = -1 then Continue;
            tg.GSkill[skillindex].Lv := retrieve_value(path, i, 1);
            tg.GSkill[skillindex].Card := False;
        end;

        tg.MaxUsers := 16;
        if (tg.GSkill[10004].Lv > 0) then
            tg.MaxUsers := tg.MaxUsers + tg.GSkill[10004].Data.Data1[tg.GSkill[10004].Lv];
            
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - Guild Supplemental Functions                                                }
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

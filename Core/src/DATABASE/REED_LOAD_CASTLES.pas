unit REED_LOAD_CASTLES;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Castles_Pre_Parse(UID : String = '*');
    procedure PD_Load_Castles_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);

    procedure PD_Load_Castles_Settings(tgc : TCastle; path : String);

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Castles Pre Parse -------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Castles_Pre_Parse(UID : String = '*');
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

        basepath := AppPath + 'gamedata\Castles\';

        for i := 0 to accountlist.Count - 1 do begin
            if Player.IndexOf(reed_convert_type(accountlist[i], 0, -1)) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(reed_convert_type(accountlist[i], 0, -1))] as TPlayer;

            pfile := 'Castle.txt';
            PD_Load_Castles_Parse(UID, tp, get_list(basepath, pfile), basepath);

            if (UID <> '*') then Break;
        end;

        FreeAndNil(accountlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Castles Parse ------------------------------------------------------ }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Castles_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);
    var
        i, GID : Integer;
        pfile : String;
        path : String;
        tg : TGuild;
        tgc : TCastle;
    begin

        for i := 0 to resultlist.Count - 1 do begin
            path := basepath + resultlist[i] + '\';

            if (UID <> '*') then begin

                tgc := CastleList.Objects[CastleList.IndexOf(resultlist[i])] as TCastle;

                pfile := 'Castle.txt';
                GID := retrieve_data(1, path + pfile, 1);

                if GuildList.IndexOf(GID) = -1 then Continue;
                tg := GuildList.Objects[GuildList.IndexOf(GID)] as TGuild;
                if guild_is_online(tg) then Continue;

            end else begin
                tgc := TCastle.Create;
            end;


            pfile := 'Castle.txt';
            PD_Load_Castles_Settings(tgc, path + pfile);


            if (UID = '*') then begin
                CastleList.AddObject(tgc.Name, tgc);
            end;

        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Castles Settings --------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Castles_Settings(tgc : TCastle; path : String);
    begin
        tgc.Name := retrieve_data(0, path);
        tgc.GID := retrieve_data(1, path, 1);
        tgc.GName := retrieve_data(2, path);
        tgc.GMName := retrieve_data(3, path);
        tgc.GKafra := retrieve_data(4, path, 1);
        tgc.EDegree := retrieve_data(5, path, 1);
        tgc.ETrigger := retrieve_data(6, path, 1);
        tgc.DDegree := retrieve_data(7, path, 1);
        tgc.DTrigger := retrieve_data(8, path, 1);
        tgc.GuardStatus[0] := retrieve_data(9, path, 1);
        tgc.GuardStatus[1] := retrieve_data(10, path, 1);
        tgc.GuardStatus[2] := retrieve_data(11, path, 1);
        tgc.GuardStatus[3] := retrieve_data(12, path, 1);
        tgc.GuardStatus[4] := retrieve_data(13, path, 1);
        tgc.GuardStatus[5] := retrieve_data(14, path, 1);
        tgc.GuardStatus[6] := retrieve_data(15, path, 1);
        tgc.GuardStatus[7] := retrieve_data(16, path, 1);
    end;
    { ------------------------------------------------------------------------------------- }

end.

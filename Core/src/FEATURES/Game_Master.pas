unit Game_Master;

interface

uses
    IniFiles, Classes, SysUtils, Common, List32;

type TGM_Table = class
    ID : Integer;
    Level : Byte;
end;

var
    GM_ALIVE : Byte;
    GM_ITEM : Byte;
    GM_SAVE : Byte;
    GM_RETURN : Byte;
    GM_DIE : Byte;
    GM_AUTO : Byte;
    GM_HCOLOR : Byte;
    GM_CCOLOR : Byte;
    GM_HSTYLE : Byte;
    GM_KILL : Byte;
    GM_GOTO : Byte;
    GM_SUMMON : Byte;
    GM_WARP : Byte;
    GM_BANISH : Byte;
    GM_JOB : Byte;
    GM_BLEVEL : Byte;
    GM_JLEVEL : Byte;
    GM_CHANGESTAT : Byte;
    GM_SKILLPOINT : Byte;
    GM_SKILLALL : Byte;
    GM_STATALL : Byte;
    GM_ZENY : Byte;
    GM_CHANGESKILL : Byte;
    GM_MONSTER : Byte;
    GM_SPEED : Byte;
    GM_WHOIS : Byte;
    GM_OPTION: Byte;
    GM_RAW : Byte;
    GM_UNIT : Byte;
    GM_STAT : Byte;
    GM_REFINE : Byte;
    GM_GLEVEL : Byte;
    GM_IRONICAL : Byte;
    GM_MOTHBALL : Byte;
    
    GM_AEGIS_B : Byte;
    GM_AEGIS_NB : Byte;
    GM_AEGIS_BB : Byte;
    GM_AEGIS_HIDE : Byte;
    GM_AEGIS_RESETSTATE : Byte;
    GM_AEGIS_RESETSKILL : Byte;
    
    GM_ATHENA_HEAL : Byte;
    GM_ATHENA_KAMI : Byte;
    GM_ATHENA_ALIVE : Byte;
    GM_ATHENA_KILL : Byte;
    GM_ATHENA_DIE : Byte;
    GM_ATHENA_JOBCHANGE : Byte;
    GM_ATHENA_HIDE : Byte;
    GM_ATHENA_OPTION : Byte;
    GM_ATHENA_STORAGE : Byte;
    GM_ATHENA_SPEED : Byte;
    GM_ATHENA_WHO3 : Byte;
    GM_ATHENA_WHO2 : Byte;
    GM_ATHENA_WHO : Byte;
    GM_ATHENA_JUMP : Byte;
    GM_ATHENA_JUMPTO : Byte;
    GM_ATHENA_WHERE : Byte;
    GM_ATHENA_RURA : Byte;
    GM_ATHENA_WARP : Byte;
    GM_ATHENA_RURAP : Byte;
    GM_ATHENA_SEND : Byte;
    GM_ATHENA_WARPP : Byte;
    GM_ATHENA_CHARWARP : Byte;
    

    GM_Access_DB : TIntList32;

    procedure load_commands();
    procedure save_commands();

    procedure parse_commands(tc : TChara; str : String);
    function check_level(id : Integer; cmd : Integer) : Boolean;
    procedure error_message(tc : TChara; str : String);
    procedure save_gm_log(tc : TChara; str : String);

    function command_alive(tc : TChara) : String;
    function command_item(tc : TChara; str : String) : String;
    function command_save(tc : TChara) : String;
    function command_return(tc : TChara) : String;
    function command_die(tc : TChara) : String;
    function command_auto(tc : TChara; str : String) : String;
    function command_hcolor(tc : TChara; str : String) : String;
    function command_ccolor(tc : TChara; str : String) : String;
    function command_hstyle(tc : TChara; str : String) : String;
    function command_kill(str : String) : String;

implementation

    procedure load_commands();
    var
        ini : TIniFile;
        sl : TStringList;
    begin
        ini := TIniFile.Create(AppPath + 'gm_commands.ini');
        sl := TStringList.Create();
        sl.Clear;
        ini.ReadSectionValues('Fusion GM Commands', sl);

        if sl.IndexOfName('ALIVE') > -1 then GM_ALIVE := StrToInt(sl.Values['ALIVE']) else GM_ALIVE := 1;
        if sl.IndexOfName('ITEM') > -1 then GM_ITEM := StrToInt(sl.Values['ITEM']) else GM_ITEM := 1;
        if sl.IndexOfName('SAVE') > -1 then GM_SAVE := StrToInt(sl.Values['SAVE']) else GM_SAVE := 1;
        if sl.IndexOfName('RETURN') > -1 then GM_SAVE := StrToInt(sl.Values['RETURN']) else GM_RETURN := 1;
        if sl.IndexOfName('DIE') > -1 then GM_DIE := StrToInt(sl.Values['DIE']) else GM_DIE := 1;
        if sl.IndexOfName('AUTO') > -1 then GM_AUTO := StrToInt(sl.Values['AUTO']) else GM_AUTO := 1;
        if sl.IndexOfName('HCOLOR') > -1 then GM_HCOLOR := StrToInt(sl.Values['HCOLOR']) else GM_HCOLOR := 1;
        if sl.IndexOfName('CCOLOR') > -1 then GM_CCOLOR := StrToInt(sl.Values['CCOLOR']) else GM_CCOLOR := 1;
        if sl.IndexOfName('HSTYLE') > -1 then GM_HSTYLE := StrToInt(sl.Values['HSTYLE']) else GM_HSTYLE := 1;
        if sl.IndexOfName('KILL') > -1 then GM_KILL := StrToInt(sl.Values['KILL']) else GM_KILL := 1;

        sl.Free;
        ini.Free;
    end;

    procedure save_commands();
    var
        ini : TIniFile;
    begin
        ini := TIniFile.Create(AppPath + 'gm_commands.ini');

        ini.WriteString('Fusion GM Commands', 'ALIVE', IntToStr(GM_ALIVE));
        ini.WriteString('Fusion GM Commands', 'ITEM', IntToStr(GM_ITEM));
        ini.WriteString('Fusion GM Commands', 'SAVE', IntToStr(GM_SAVE));
        ini.WriteString('Fusion GM Commands', 'RETURN', IntToStr(GM_RETURN));
        ini.WriteString('Fusion GM Commands', 'DIE', IntToStr(GM_DIE));
        ini.WriteString('Fusion GM Commands', 'AUTO', IntToStr(GM_AUTO));
        ini.WriteString('Fusion GM Commands', 'HCOLOR', IntToStr(GM_HCOLOR));
        ini.WriteString('Fusion GM Commands', 'CCOLOR', IntToStr(GM_CCOLOR));
        ini.WriteString('Fusion GM Commands', 'HSTYLE', IntToStr(GM_HSTYLE));
        ini.WriteString('Fusion GM Commands', 'KILL', IntToStr(GM_KILL));

        ini.Free;
    end;

    procedure parse_commands(tc : TChara; str : String);
    var
        error_msg : String;
    begin
        str := Copy(str, Pos(' : ', str) + 4, 256);
        error_msg := '';

        if ( (copy(str, 1, length('alive')) = 'alive') and (check_level(tc.ID, GM_ALIVE)) ) then error_msg := command_alive(tc)
        else if ( (copy(str, 1, length('item')) = 'item') and (check_level(tc.ID, GM_ITEM)) ) then error_msg := command_item(tc, str)
        else if ( (copy(str, 1, length('save')) = 'save') and (check_level(tc.ID, GM_SAVE)) ) then error_msg := command_save(tc)
        else if ( (copy(str, 1, length('return')) = 'return') and (check_level(tc.ID, GM_RETURN)) ) then error_msg := command_return(tc)
        else if ( (copy(str, 1, length('die')) = 'die') and (check_level(tc.ID, GM_DIE)) ) then error_msg := command_die(tc)
        else if ( (copy(str, 1, length('auto')) = 'auto') and (check_level(tc.ID, GM_AUTO)) ) then error_msg := command_auto(tc, str)
        else if ( (copy(str, 1, length('hcolor')) = 'hcolor') and (check_level(tc.ID, GM_HCOLOR)) ) then error_msg := command_hcolor(tc, str)
        else if ( (copy(str, 1, length('ccolor')) = 'ccolor') and (check_level(tc.ID, GM_CCOLOR)) ) then error_msg := command_ccolor(tc, str)
        else if ( (copy(str, 1, length('hstyle')) = 'hstyle') and (check_level(tc.ID, GM_HSTYLE)) ) then error_msg := command_hstyle(tc, str)
        else if ( (copy(str, 1, length('kill')) = 'kill') and (check_level(tc.ID, GM_KILL)) ) then error_msg := command_kill(str)
        ;

        if (error_msg <> '') then error_message(tc, error_msg);
        if (Option_GM_Logs) then save_gm_log(tc, error_msg);
    end;

    function check_level(id : Integer; cmd : Integer) : Boolean;
    var
        GM_Access : TGM_Table;
        idx : Integer;
        tGM : TGM_Table;
    begin
        Result := False;
        idx := GM_Access_DB.IndexOf(id);

        if (idx <> -1) then begin
            tGM := GM_Access_DB.Objects[idx] as TGM_Table;
            if ( (tGM.ID = id) and (tGM.Level >= cmd) ) then Result := True;
        end;
    end;

    procedure error_message(tc : TChara; str : String);
    begin
        WFIFOW(0, $009a);
        WFIFOW(2, length(str) + 4);
        WFIFOS(4, str, length(str));
        tc.Socket.SendBuf(buf, length(str) + 4);
    end;

    procedure save_gm_log(tc : TChara; str : String);
    var
        logfile : TStringList;
        timestamp : TDateTime;
        filename : String;
    begin
        timestamp := Now;
        filename := StringReplace(DateToStr(timestamp), '/', '_', [rfReplaceAll, rfIgnoreCase]);
        logfile := TStringList.Create;

        if FileExists(AppPath + 'logs\GM_COMMANDS-' + filename + '.txt') then begin
            logfile.LoadFromFile(AppPath + 'logs\GM_COMMANDS-' + filename + '.txt');
		end;

        str := '[' + DateToStr(timestamp) + '-' + TimeToStr(timestamp) + '] ' + IntToStr(tc.ID) + ': ' + str + ' (' + tc.Name + ')';
        logfile.Add(str);
        logfile.SaveToFile(AppPath + 'logs\GM_COMMANDS-' + filename + '.txt');
        logfile.Free;
    end;

    function command_alive(tc : TChara) : String;
    var
        tm : TMap;
    begin
        Result := 'GM_ALIVE Activated';

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tc.HP := tc.MAXHP;
        tc.SP := tc.MAXSP;
        tc.Sit := 3;
        SendCStat1(tc, 0, 5, tc.HP);
        SendCStat1(tc, 0, 7, tc.SP);
        WFIFOW(0, $0148);
        WFIFOL(2, tc.ID);
        WFIFOW(6, 100);
        SendBCmd(tm, tc.Point, 8);
    end;

    function command_item(tc : TChara; str : String) : String;
    var
        sl : TStringList;
        td : TItemDB;
        i, j, k : Integer;
    begin
        Result := 'GM_ITEM Activated';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 6, 256);

        if sl.Count = 2 then begin
            Val(sl[0], i, k);

            if k <> 0 then Exit;
            if ItemDB.IndexOf(i) = -1 then Exit;

            Val(sl[1], j, k);

            if k <> 0 then Exit;
            if (j <= 0) or (j > 30000) then Exit;

            td := ItemDB.IndexOfObject(i) as TItemDB;

            if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
                k := SearchCInventory(tc, i, td.IEquip);

                if k <> 0 then begin
                    if tc.Item[k].Amount + j > 30000 then Exit;
                    if td.IEquip then j := 1;

                    tc.Item[k].ID := i;
                    tc.Item[k].Amount := tc.Item[k].Amount + j;
                    tc.Item[k].Equip := 0;
                    tc.Item[k].Identify := 1;
                    tc.Item[k].Refine := 0;
                    tc.Item[k].Attr := 0;
                    tc.Item[k].Card[0] := 0;
                    tc.Item[k].Card[1] := 0;
                    tc.Item[k].Card[2] := 0;
                    tc.Item[k].Card[3] := 0;
                    tc.Item[k].Data := td;

                    tc.Weight := tc.Weight + cardinal(td.Weight) * cardinal(j);
                    SendCStat1(tc, 0, $0018, tc.Weight);

                    SendCGetItem(tc, k, j);
                end;
            end

            else begin
                WFIFOW( 0, $00a0);
                WFIFOB(22, 2);
                tc.Socket.SendBuf(buf, 23);
            end;
        end;

        sl.Free();
    end;

    function command_save(tc : TChara) : String;
    var
        str : String;
    begin
        Result := 'GM_SAVE Activated';

        tc.SaveMap := tc.Map;
        tc.SavePoint.X := tc.Point.X;
        tc.SavePoint.Y := tc.Point.Y;

        Result := 'Saved at ' + tc.Map + ' (' + IntToStr(tc.Point.X) + ',' + IntToStr(tc.Point.Y) + ')';
    end;

    function command_return(tc : TChara) : String;
    begin
        Result := 'GM_RETURN Activated';

        SendCLeave(tc.Socket.Data, 2);
        tc.Map := tc.SaveMap;
        tc.Point := tc.SavePoint;
        MapMove(tc.Socket, tc.Map, tc.Point);
    end;

    function command_die(tc : TChara) : String;
    var
        tm : TMap;
    begin
        Result := 'GM_DIE Activated';

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tc.Sit := 1;
        tc.HP := 0;
        SendCStat1(tc, 0, 5, tc.HP);
        WFIFOW( 0, $0080);
        WFIFOL( 2, tc.ID);
        WFIFOB( 6, 1);
        SendBCmd(tm, tc.Point, 7);
    end;

    function command_auto(tc : TChara; str : String) : String;
    var
        sl : TStringList;
        j, k : Integer;
    begin
        Result := 'GM_AUTO Activated';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 5, 256);

        if sl.Count = 0 then Exit;
        Val(sl.Strings[0], j, k);
        if (k <> 0) or (j < 0) then Exit;
        tc.Auto := j;

        if sl.Count = 3 then begin
            Val(sl.Strings[1], tc.A_Skill, k);
            Val(sl.Strings[2], tc.A_Lv, k);
        end;

        sl.Free;
    end;

    function command_hcolor(tc : TChara; str : String) : String;
    var
        tm : TMap;
        i, k : Integer;
    begin
        Result := 'GM_HCOLOR Activated';

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        Val(Copy(str, 8, 256), i, k);
        if (k = 0) and (i >= 0) and (i <= 8) then begin
            tc.HairColor := i;
            UpdateLook(tm, tc, 6, i, 0, true);
        end;
    end;

    function command_ccolor(tc : TChara; str : String) : String;
    var
        tm : TMap;
        i, k : Integer;
    begin
        Result := 'GM_CCOLOR Activated';

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        Val(Copy(str, 8, 256), i, k);
        if (k = 0) and (i >= 0) and (i <= 77) then begin
            tc.ClothesColor := i;
            UpdateLook(tm, tc, 7, i, 0, true);
        end;
    end;

    function command_hstyle(tc : TChara; str : String) : String;
    var
        tm : TMap;
        i, k : Integer;
    begin
        Result := 'GM_HSTYLE Activated';

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        Val(Copy(str, 8, 256), i, k);
        if (k = 0) and (i >= 0) and (i <= 19) then begin
            tc.Hair := i;
            UpdateLook(tm, tc, 1, i, 0, true);
        end;
    end;

    function command_kill(str : String) : String;
    var
        s : String;
        tc1 : TChara;
        tm : TMap;
    begin
        Result := 'GM_KILL Activated';

        s := Copy(str, 6, 256);
        if (CharaName.Indexof(s) <> -1) then begin
            tc1 := CharaName.Objects[CharaName.Indexof(s)] as TChara;

            if (tc1.Login = 2) then begin
                tm := Map.Objects[Map.IndexOf(tc1.Map)] as TMap;
                tc1.HP := 0;
                tc1.Sit := 1;
                SendCStat1(tc1, 0, 5, tc1.HP);

                WFIFOW( 0, $0080);
                WFIFOL( 2, tc1.ID);
                WFIFOB( 6, 1);
                SendBCmd(tm, tc1.Point, 7);

                Result := 'GM_KILL Success. ' + s + ' has been killed.';
            end else begin
                Result := 'GM_KILL Failure. ' + s + ' is not logged in.';
            end;
        end else begin
            Result := 'GM_KILL Failure. ' + s + ' is an invalid character name.';
        end;
    end;

end.

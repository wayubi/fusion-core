unit Game_Master;

interface

uses
    IniFiles, Classes, SysUtils, Common, List32, MMSystem;

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
    GM_OPTION : Byte;
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
    function command_goto(tc : TChara; str : String) : String;
    function command_summon(tc : TChara; str : String) : String;
    function command_warp(tc : TChara; str : String) : String;
    function command_banish(str : String) : String;
    function command_job(tc : TChara; str : String) : String;
    function command_blevel(tc : TChara; str : String) : String;
    function command_jlevel(tc : TChara; str : String) : String;
    function command_changestat(tc : TChara; str : String) : String;
    function command_skillpoint(tc : TChara; str : String) : String;
    function command_skillall(tc : TChara) : String;
    function command_statall(tc : TChara) : String;
    function command_zeny(tc : TChara; str : String) : String;
    function command_changeskill(tc : TChara; str : String) : String;

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

        GM_ALIVE := StrToIntDef(sl.Values['ALIVE'], 1);
        GM_ITEM := StrToIntDef(sl.Values['ITEM'], 1);
        GM_SAVE := StrToIntDef(sl.Values['SAVE'], 1);
        GM_RETURN := StrToIntDef(sl.Values['RETURN'], 1);
        GM_DIE := StrToIntDef(sl.Values['DIE'], 1);
        GM_AUTO := StrToIntDef(sl.Values['AUTO'], 1);
        GM_HCOLOR := StrToIntDef(sl.Values['HCOLOR'], 1);
        GM_CCOLOR := StrToIntDef(sl.Values['CCOLOR'], 1);
        GM_HSTYLE := StrToIntDef(sl.Values['HSTYLE'], 1);
        GM_KILL := StrToIntDef(sl.Values['KILL'], 1);
        GM_GOTO := StrToIntDef(sl.Values['GOTO'], 1);
        GM_SUMMON := StrToIntDef(sl.Values['SUMMON'], 1);
        GM_WARP := StrToIntDef(sl.Values['WARP'], 1);
        GM_BANISH := StrToIntDef(sl.Values['BANISH'], 1);
        GM_JOB := StrToIntDef(sl.Values['JOB'], 1);
        GM_BLEVEL := StrToIntDef(sl.Values['BLEVEL'], 1);
        GM_JLEVEL := StrToIntDef(sl.Values['JLEVEL'], 1);
        GM_CHANGESTAT := StrToIntDef(sl.Values['CHANGESTAT'], 1);
        GM_SKILLPOINT := StrToIntDef(sl.Values['SKILLPOINT'], 1);
        GM_SKILLALL := StrToIntDef(sl.Values['SKILLALL'], 1);
        GM_STATALL := StrToIntDef(sl.Values['STATALL'], 1);
        GM_ZENY := StrToIntDef(sl.Values['ZENY'], 1);
        GM_CHANGESKILL := StrToIntDef(sl.Values['CHANGESKILL'], 1);
        GM_MONSTER := StrToIntDef(sl.Values['MONSTER'], 1);
        GM_SPEED := StrToIntDef(sl.Values['SPEED'], 1);
        GM_WHOIS := StrToIntDef(sl.Values['WHOIS'], 1);
        GM_OPTION := StrToIntDef(sl.Values['OPTION'], 1);
        GM_RAW := StrToIntDef(sl.Values['RAW'], 1);
        GM_UNIT := StrToIntDef(sl.Values['UNIT'], 1);
        GM_STAT := StrToIntDef(sl.Values['STAT'], 1);
        GM_REFINE := StrToIntDef(sl.Values['REFINE'], 1);
        GM_GLEVEL := StrToIntDef(sl.Values['GLEVEL'], 1);
        GM_IRONICAL := StrToIntDef(sl.Values['IRONICAL'], 1);
        GM_MOTHBALL := StrToIntDef(sl.Values['MOTHBALL'], 1);
        
        GM_AEGIS_B := StrToIntDef(sl.Values['AEGIS_B'], 1);
        GM_AEGIS_NB := StrToIntDef(sl.Values['AEGIS_NB'], 1);
        GM_AEGIS_BB := StrToIntDef(sl.Values['AEGIS_BB'], 1);
        GM_AEGIS_HIDE := StrToIntDef(sl.Values['AEGIS_HIDE'], 1);
        GM_AEGIS_RESETSTATE := StrToIntDef(sl.Values['AEGIS_RESETSTATE'], 1);
        GM_AEGIS_RESETSKILL := StrToIntDef(sl.Values['AEGIS_RESETSKILL'], 1);
        
        GM_ATHENA_HEAL := StrToIntDef(sl.Values['ATHENA_HEAL'], 1);
        GM_ATHENA_KAMI := StrToIntDef(sl.Values['ATHENA_KAMI'], 1);
        GM_ATHENA_ALIVE := StrToIntDef(sl.Values['ATHENA_ALIVE'], 1);
        GM_ATHENA_KILL := StrToIntDef(sl.Values['ATHENA_KILL'], 1);
        GM_ATHENA_DIE := StrToIntDef(sl.Values['ATHENA_DIE'], 1);
        GM_ATHENA_JOBCHANGE := StrToIntDef(sl.Values['ATHENA_JOBCHANGE'], 1);
        GM_ATHENA_HIDE := StrToIntDef(sl.Values['ATHENA_HIDE'], 1);
        GM_ATHENA_OPTION := StrToIntDef(sl.Values['ATHENA_OPTION'], 1);
        GM_ATHENA_STORAGE := StrToIntDef(sl.Values['ATHENA_STORAGE'], 1);
        GM_ATHENA_SPEED := StrToIntDef(sl.Values['ATHENA_SPEED'], 1);
        GM_ATHENA_WHO3 := StrToIntDef(sl.Values['ATHENA_WHO3'], 1);
        GM_ATHENA_WHO2 := StrToIntDef(sl.Values['ATHENA_WHO2'], 1);
        GM_ATHENA_WHO := StrToIntDef(sl.Values['ATHENA_WHO'], 1);
        GM_ATHENA_JUMP := StrToIntDef(sl.Values['ATHENA_JUMP'], 1);
        GM_ATHENA_JUMPTO := StrToIntDef(sl.Values['ATHENA_JUMPTO'], 1);
        GM_ATHENA_WHERE := StrToIntDef(sl.Values['ATHENA_WHERE'], 1);
        GM_ATHENA_RURA := StrToIntDef(sl.Values['ATHENA_RURA'], 1);
        GM_ATHENA_WARP := StrToIntDef(sl.Values['ATHENA_WARP'], 1);
        GM_ATHENA_RURAP := StrToIntDef(sl.Values['ATHENA_RURAP'], 1);
        GM_ATHENA_SEND := StrToIntDef(sl.Values['ATHENA_SEND'], 1);
        GM_ATHENA_WARPP := StrToIntDef(sl.Values['ATHENA_WARPP'], 1);
        GM_ATHENA_CHARWARP := StrToIntDef(sl.Values['ATHENA_CHARWARP'], 1);

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
        ini.WriteString('Fusion GM Commands', 'GOTO', IntToStr(GM_GOTO));
        ini.WriteString('Fusion GM Commands', 'SUMMON', IntToStr(GM_SUMMON));
        ini.WriteString('Fusion GM Commands', 'WARP', IntToStr(GM_WARP));
        ini.WriteString('Fusion GM Commands', 'BANISH', IntToStr(GM_BANISH));
        ini.WriteString('Fusion GM Commands', 'JOB', IntToStr(GM_JOB));
        ini.WriteString('Fusion GM Commands', 'BLEVEL', IntToStr(GM_BLEVEL));
        ini.WriteString('Fusion GM Commands', 'JLEVEL', IntToStr(GM_JLEVEL));
        ini.WriteString('Fusion GM Commands', 'CHANGESTAT', IntToStr(GM_CHANGESTAT));
        ini.WriteString('Fusion GM Commands', 'SKILLPOINT', IntToStr(GM_SKILLPOINT));
        ini.WriteString('Fusion GM Commands', 'SKILLALL', IntToStr(GM_SKILLALL));
        ini.WriteString('Fusion GM Commands', 'STATALL', IntToStr(GM_STATALL));
        ini.WriteString('Fusion GM Commands', 'ZENY', IntToStr(GM_ZENY));
        ini.WriteString('Fusion GM Commands', 'CHANGESKILL', IntToStr(GM_CHANGESKILL));
        ini.WriteString('Fusion GM Commands', 'MONSTER', IntToStr(GM_MONSTER));
        ini.WriteString('Fusion GM Commands', 'SPEED', IntToStr(GM_SPEED));
        ini.WriteString('Fusion GM Commands', 'WHOIS', IntToStr(GM_WHOIS));
        ini.WriteString('Fusion GM Commands', 'OPTION', IntToStr(GM_OPTION));
        ini.WriteString('Fusion GM Commands', 'RAW', IntToStr(GM_RAW));
        ini.WriteString('Fusion GM Commands', 'UNIT', IntToStr(GM_UNIT));
        ini.WriteString('Fusion GM Commands', 'STAT', IntToStr(GM_STAT));
        ini.WriteString('Fusion GM Commands', 'REFINE', IntToStr(GM_REFINE));
        ini.WriteString('Fusion GM Commands', 'GLEVEL', IntToStr(GM_GLEVEL));
        ini.WriteString('Fusion GM Commands', 'IRONICAL', IntToStr(GM_IRONICAL));
        ini.WriteString('Fusion GM Commands', 'MOTHBALL', IntToStr(GM_MOTHBALL));
        
        ini.WriteString('Aegis GM Commands', 'AEGIS_B', IntToStr(GM_AEGIS_B));
        ini.WriteString('Aegis GM Commands', 'AEGIS_NB', IntToStr(GM_AEGIS_NB));
        ini.WriteString('Aegis GM Commands', 'AEGIS_BB', IntToStr(GM_AEGIS_BB));
        ini.WriteString('Aegis GM Commands', 'AEGIS_HIDE', IntToStr(GM_AEGIS_HIDE));
        ini.WriteString('Aegis GM Commands', 'AEGIS_RESETSTATE', IntToStr(GM_AEGIS_RESETSTATE));
        ini.WriteString('Aegis GM Commands', 'AEGIS_RESETSKILL', IntToStr(GM_AEGIS_RESETSKILL));
        
        ini.WriteString('Athena GM Commands', 'ATHENA_HEAL', IntToStr(GM_ATHENA_HEAL));
        ini.WriteString('Athena GM Commands', 'ATHENA_KAMI', IntToStr(GM_ATHENA_KAMI));
        ini.WriteString('Athena GM Commands', 'ATHENA_ALIVE', IntToStr(GM_ATHENA_ALIVE));
        ini.WriteString('Athena GM Commands', 'ATHENA_KILL', IntToStr(GM_ATHENA_KILL));
        ini.WriteString('Athena GM Commands', 'ATHENA_DIE', IntToStr(GM_ATHENA_DIE));
        ini.WriteString('Athena GM Commands', 'ATHENA_JOBCHANGE', IntToStr(GM_ATHENA_JOBCHANGE));
        ini.WriteString('Athena GM Commands', 'ATHENA_HIDE', IntToStr(GM_ATHENA_HIDE));
        ini.WriteString('Athena GM Commands', 'ATHENA_OPTION', IntToStr(GM_ATHENA_OPTION));
        ini.WriteString('Athena GM Commands', 'ATHENA_STORAGE', IntToStr(GM_ATHENA_STORAGE));
        ini.WriteString('Athena GM Commands', 'ATHENA_SPEED', IntToStr(GM_ATHENA_SPEED));
        ini.WriteString('Athena GM Commands', 'ATHENA_WHO3', IntToStr(GM_ATHENA_WHO3));
        ini.WriteString('Athena GM Commands', 'ATHENA_WHO2', IntToStr(GM_ATHENA_WHO2));
        ini.WriteString('Athena GM Commands', 'ATHENA_WHO', IntToStr(GM_ATHENA_WHO));
        ini.WriteString('Athena GM Commands', 'ATHENA_JUMP', IntToStr(GM_ATHENA_JUMP));
        ini.WriteString('Athena GM Commands', 'ATHENA_JUMPTO', IntToStr(GM_ATHENA_JUMPTO));
        ini.WriteString('Athena GM Commands', 'ATHENA_WHERE', IntToStr(GM_ATHENA_WHERE));
        ini.WriteString('Athena GM Commands', 'ATHENA_RURA', IntToStr(GM_ATHENA_RURA));
        ini.WriteString('Athena GM Commands', 'ATHENA_WARP', IntToStr(GM_ATHENA_WARP));
        ini.WriteString('Athena GM Commands', 'ATHENA_RURAP', IntToStr(GM_ATHENA_RURAP));
        ini.WriteString('Athena GM Commands', 'ATHENA_SEND', IntToStr(GM_ATHENA_SEND));
        ini.WriteString('Athena GM Commands', 'ATHENA_WARPP', IntToStr(GM_ATHENA_WARPP));
        ini.WriteString('Athena GM Commands', 'ATHENA_CHARWARP', IntToStr(GM_ATHENA_CHARWARP));

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
        else if ( (copy(str, 1, length('goto')) = 'goto') and (check_level(tc.ID, GM_GOTO)) ) then error_msg := command_goto(tc, str)
        else if ( (copy(str, 1, length('summon')) = 'summon') and (check_level(tc.ID, GM_SUMMON)) ) then error_msg := command_summon(tc, str)
        else if ( (copy(str, 1, length('warp')) = 'warp') and (check_level(tc.ID, GM_WARP)) ) then error_msg := command_warp(tc, str)
        else if ( (copy(str, 1, length('banish')) = 'banish') and (check_level(tc.ID, GM_BANISH)) ) then error_msg := command_banish(str)
        else if ( (copy(str, 1, length('job')) = 'job') and (check_level(tc.ID, GM_JOB)) ) then error_msg := command_job(tc, str)
        else if ( (copy(str, 1, length('blevel')) = 'blevel') and (check_level(tc.ID, GM_BLEVEL)) ) then error_msg := command_blevel(tc, str)
        else if ( (copy(str, 1, length('jlevel')) = 'jlevel') and (check_level(tc.ID, GM_JLEVEL)) ) then error_msg := command_jlevel(tc, str)
        else if ( (copy(str, 1, length('changestat')) = 'changestat') and (check_level(tc.ID, GM_CHANGESTAT)) ) then error_msg := command_changestat(tc, str)
        else if ( (copy(str, 1, length('skillpoint')) = 'skillpoint') and (check_level(tc.ID, GM_SKILLPOINT)) ) then error_msg := command_skillpoint(tc, str)
        else if ( (copy(str, 1, length('skillall')) = 'skillall') and (check_level(tc.ID, GM_SKILLALL)) ) then error_msg := command_skillall(tc)
        else if ( (copy(str, 1, length('statall')) = 'statall') and (check_level(tc.ID, GM_STATALL)) ) then error_msg := command_statall(tc)
        else if ( (copy(str, 1, length('zeny')) = 'zeny') and (check_level(tc.ID, GM_ZENY)) ) then error_msg := command_zeny(tc, str)
        else if ( (copy(str, 1, length('changeskill')) = 'changeskill') and (check_level(tc.ID, GM_CHANGESKILL)) ) then error_msg := command_changeskill(tc, str)
        ;

        if (error_msg <> '') then error_message(tc, error_msg);
        if ( (Option_GM_Logs) and (error_msg <> '') ) then save_gm_log(tc, error_msg);
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

        CreateDir('logs');
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

    function command_goto(tc : TChara; str : String) : String;
    var
        s : String;
        tc1 : TChara;
    begin
        Result := 'GM_GOTO Activated';

        s := Copy(str, 6, 256);
        if CharaName.Indexof(s) <> -1 then begin
            tc1 := CharaName.Objects[CharaName.Indexof(s)] as TChara;
            if (tc.Hidden = false) then SendCLeave(tc, 2);
            tc.tmpMap := tc1.Map;
            tc.Point := tc1.Point;
            MapMove(tc.Socket, tc1.Map, tc1.Point);

            Result := 'GM_GOTO Success. ' + tc.Name + ' warped to ' + s + '.';
        end else begin
            Result := 'GM_GOTO Failure. ' + s + ' is an invalid character name.';
        end;
    end;

    function command_summon(tc : TChara; str : String) : String;
    var
        s : String;
        tc1 : TChara;
    begin
        Result := 'GM_SUMMON Activated';

        s := Copy(str, 8, 256);
        if CharaName.Indexof(s) <> -1 then begin
            Result := 'GM_SUMMON Success. ' + s + ' warped to ' + tc.Name + '.';
            tc1 := CharaName.Objects[CharaName.Indexof(s)] as TChara;

            if (tc1.Login = 2) then begin
                SendCLeave(tc1, 2);
                tc1.Map := tc.Map;
                tc1.Point := tc.Point;
                MapMove(tc1.Socket, tc.Map, tc.Point);
            end else begin
                tc1.Map := tc.Map;
                tc1.Point := tc.Point;

                Result := Result + ' But ' + s + ' is offline.';
            end;

        end else begin
            Result := 'GM_SUMMON Failure. ' + s + ' is an invalid character name.';
        end;
    end;

    function command_warp(tc : TChara; str : String) : String;
    var
        sl : TStringList;
        i, j, k : Integer;
        ta : TMapList;
    begin
        Result := 'GM_WARP Failure.';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 6, 256);

        if sl.Count <> 3 then Exit;
        Val(sl.Strings[1], i, k);

        if k <> 0 then Exit;
        Val(sl.Strings[2], j, k);

        if k <> 0 then Exit;
        if MapList.IndexOf(LowerCase(sl.Strings[0])) = -1 then Exit;

        ta := MapList.Objects[MapList.IndexOf(LowerCase(sl.Strings[0]))] as TMapList;
        if (i < 0) or (i >= ta.Size.X) or (j < 0) or (j >= ta.Size.Y) then Exit;

        if (tc.Hidden = false) then SendCLeave(tc, 2);
        tc.tmpMap := LowerCase(sl.Strings[0]);
        tc.Point := Point(i,j);
        MapMove(tc.Socket, LowerCase(sl.Strings[0]), Point(i,j));

        sl.Free;
        Result := 'GM_WARP Success. Warp to ' + tc.tmpMap + ' (' + IntToStr(i) + ',' + IntToStr(j) + ').'; 
    end;

    function command_banish(str : String) : String;
    var
        sl : TStringList;
        i, j, k : Integer;
        ta : TMapList;
        tc1 : TChara;
        s : String;
    begin
        Result := 'GM_BANISH Failure.';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 8, 256);

        if (sl.Count <> 4) then begin
            Result := Result + ' Missing information.';
            Exit;
        end;

        Val(sl[sl.Count - 2], i, k);
        if k <> 0 then Exit;

        Val(sl[sl.Count - 1], j, k);
        if k <> 0 then Exit;

        if MapList.IndexOf(sl.Strings[sl.Count - 3]) <> -1 then begin
            ta := MapList.Objects[MapList.IndexOf(sl.Strings[sl.Count - 3])] as TMapList;
            if (i < 0) or (i >= ta.Size.X) or (j < 0) or (j >= ta.Size.Y) then Exit;

            for k := 0 to sl.Count - 4 do begin
                s := s + ' ' + sl.Strings[k];
                s := Trim(s);
            end;

            if CharaName.Indexof(s) <> -1 then begin
                tc1 := CharaName.Objects[CharaName.Indexof(s)] as TChara;
                Result := 'GM_BANISH Success. ' + s + ' warped to ' + ta.Name + ' (' + IntToStr(i) + ', ' + IntToStr(j) + ').';

                if (tc1.Login = 2) then begin
                    SendCLeave(tc1, 2);
                    tc1.tmpMap := sl.Strings[sl.Count - 3];
                    tc1.Point := Point(i,j);
                    MapMove(tc1.Socket, tc1.tmpMap, tc1.Point);
                end else begin
                    tc1.Map := sl.Strings[sl.Count - 3];
                    tc1.Point := Point(i,j);
                    Result := Result + ' ' + s + ' is offline.';
                end;
            end else begin
                Result := Result + ' ' + s + ' is an invalid character name.';
            end;
        end else begin
            Result := 'GM_BANISH Failure. ' + sl.Strings[sl.Count - 3] + ' is not a valid map name.';
        end;

        sl.Free;
    end;

    function command_job(tc : TChara; str : String) : String;
    var
        i, j, k : Integer;
        tm : TMap;
    begin
        Result := 'GM_JOB Failure.';

        if (tc.JID <> 0) or ((DebugCMD and $0020) <> 0) then begin
            Val(Copy(str, 5, 256), i, k);
            if (k = 0) and (i >= 0) and (i <= MAX_JOB_NUMBER) and (i <> 13) then begin
                tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;

                // Colus, 20040203: Added unequip of items when you #job
                for  j := 1 to 100 do begin
                    if tc.Item[j].Equip = 32768 then begin
                        tc.Item[j].Equip := 0;
                        WFIFOW(0, $013c);
                        WFIFOW(2, 0);
                        tc.Socket.SendBuf(buf, 4);
                    end else if tc.Item[j].Equip <> 0 then begin
                        WFIFOW(0, $00ac);
                        WFIFOW(2, j);
                        WFIFOW(4, tc.Item[j].Equip);
                        tc.Item[j].Equip := 0;
                        WFIFOB(6, 1);
                        tc.Socket.SendBuf(buf, 7);
                    end;
                end;

                // Darkhelmet, 20040212: Added to remove all ticks when changing jobs.
                for j := 1 to MAX_SKILL_NUMBER do begin
                    if tc.Skill[j].Data.Icon <> 0 then begin
                        if tc.Skill[j].Tick >= timeGetTime() then begin
                            UpdateIcon(tm, tc, tc.Skill[j].Data.Icon, 0);
                        end;
                    end;
                    tc.Skill[j].Tick := timeGetTime();
                    tc.Skill[j].Effect1 := 0;
                end;

                if (i > LOWER_JOB_END) then begin
                    i := i - LOWER_JOB_END + UPPER_JOB_BEGIN; // 24 - 23 + 4000 = 4001, remort novice
                    tc.ClothesColor := 1; // This is the default clothes palette color for upper classes
                end else begin
                    tc.ClothesColor := 0;
                end;

                tc.JID := i;

                if (tc.Option <> 0) then begin
                    tc.Option := 0;
                    WFIFOW(0, $0119);
                    WFIFOL(2, tc.ID);
                    WFIFOW(6, 0);
                    WFIFOW(8, 0);
                    WFIFOW(10, tc.Option);
                    WFIFOB(12, 0);
                    SendBCmd(tc.MData, tc.Point, 13);
                end;

                CalcStat(tc);
                SendCStat(tc, true); // Add the true to recalc sprites
                SendCSkillList(tc);

                // Colus, 20040303: Using newer packet to allow upper job changes
                UpdateLook(tm, tc, 0, i);

                Result := 'GM_JOB Success. New Job ID is ' + IntToStr(i) + '.';
            end else begin
                Result := Result + ' Job ID is out of range.';
            end;
        end;
    end;

    function command_blevel(tc : TChara; str : String) : String;
    var
        i, k, w3 : Integer;
        oldlevel : Integer;
    begin
        Result := 'GM_BLEVEL Failure.';

        oldlevel := tc.BaseLV;
        Val(Copy(str, 8, 256), i, k);

        if (k = 0) and (i >= 1) and (i <= 199) and (i <> tc.BaseLV) then begin
            if tc.BaseLV > i then begin
                tc.BaseLV := i;

                for i := 0 to 5 do begin
                    tc.ParamBase[i] := 1;
                end;

                tc.StatusPoint := 48;

                for i := 1 to tc.BaseLV - 1 do begin
                    tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
                end;
            end

            else begin
                w3 := tc.BaseLV;
                tc.BaseLV := i;

                for i := w3 to tc.BaseLV - 1 do begin
                    tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
                end;
            end;

            tc.BaseEXP := tc.BaseNextEXP - 1;
            tc.BaseNextEXP := ExpTable[0][tc.BaseLV];

            CalcStat(tc);
            SendCStat(tc);
            SendCStat1(tc, 0, $000b, tc.BaseLV);
            SendCStat1(tc, 0, $0009, tc.StatusPoint);
            SendCStat1(tc, 1, $0001, tc.BaseEXP);

            Result := 'GM_BLEVEL Success. level changed from ' + IntToStr(oldlevel) + ' to ' + IntToStr(tc.BaseLV) + '.';
        end else begin
            Result := Result + ' Incomplete information or level out of range.';
        end;
    end;

    function command_jlevel(tc : TChara; str : String) : String;
    var
        i, j, k : Integer;
        oldlevel : Integer;
    begin
        Result := 'GM_JLEVEL Failure.';

        oldlevel := tc.JobLV;
        Val(Copy(str, 8, 256), i, k);

        if (k = 0) and (i >= 1) and (i <= 99) and (i <> tc.JobLV) then begin
            tc.JobLV := i;

            for i := 1 to MAX_SKILL_NUMBER do begin
                if not tc.Skill[i].Card then tc.Skill[i].Lv := 0;
            end;

            if tc.JID = 0 then tc.SkillPoint := tc.JobLV - 1
            else if tc.JID < 7 then tc.SkillPoint := tc.JobLV - 1 + 9
            else tc.SkillPoint := tc.JobLV - 1 + 49 + 9;

            SendCSkillList(tc);

            tc.JobEXP := tc.JobNextEXP - 1;

            if tc.JID < 13 then begin
                j := (tc.JID + 5) div 6 + 1;
            end else begin
                j := 3;
            end;

            tc.JobNextEXP := ExpTable[j][tc.JobLV];

            CalcStat(tc);
            SendCStat(tc);
            SendCStat1(tc, 0, $0037, tc.JobLV);
            SendCStat1(tc, 0, $000c, tc.SkillPoint);
            SendCStat1(tc, 1, $0002, tc.JobEXP);


            Result := 'GM_JLEVEL Success. level changed from ' + IntToStr(oldlevel) + ' to ' + IntToStr(tc.JobLV) + '.';
        end else begin
            Result := Result + ' Incomplete information or level out of range.';
        end;
    end;

    function command_changestat(tc : TChara; str : String) : String;
    var
        sl : TStringList;
        i, j, k : Integer;
    begin
        Result := 'GM_CHANGESTAT Failure.';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 12, 256);

        if (sl.Count = 2) then begin
            Val(sl[0], i, k);

            if(i >= 0) and (i <= 5) then begin
                Val(sl[1], j, k);

                if(j >= 1) and (j <= 99) then begin
                    tc.ParamBase[i] := j;
                    CalcStat(tc);
                    SendCStat(tc);
                    SendCStat1(tc, 0, $0009, tc.StatusPoint);

                    Result := 'GM_CHANGESTAT Success. Stat ' + IntToStr(i) + ' changed to ' + IntToStr(j) + '.';
                end;
            end else begin
                Result := Result + ' Incorrect stat index number.';
            end;
        end else begin
            Result := Result + ' Incomplete information.';
        end;

        sl.Free;
    end;

    function command_skillpoint(tc : TChara; str : String) : String;
    var
        i, k : Integer;
    begin
        Result := 'GM_SKILLPOINT Failure.';

        Val(Copy(str, 12, 256), i, k);
        if (k = 0) and (i >= 0) and (i <= 1001) then begin
            tc.SkillPoint := i;
            SendCStat1(tc, 0, $000c, tc.SkillPoint);
            Result := 'GM_SKILLPOINT Sucess. Skill Point amount set to ' + IntToStr(i) + '.';
        end else begin
            Result := Result + ' Skill Point amount out of range {0-1001}.';
        end;
    end;

    function command_skillall(tc : TChara) : String;
    var
        j, i : Integer;
    begin
        Result := 'GM_SKILLALL Failure.';

        j := tc.JID;
        if (j > UPPER_JOB_BEGIN) then j := j - UPPER_JOB_BEGIN + LOWER_JOB_END;
        // (RN 4001 - 4000 + 23 = 24)

        for i := 1 to 157 do begin
            if (tc.Skill[i].Data.Job1[j]) or (tc.Skill[i].Data.Job2[j]) then begin
                tc.Skill[i].Lv := tc.Skill[i].Data.MasterLV;
            end;
        end;

        for i := 210 to MAX_SKILL_NUMBER do begin
            if (tc.Skill[i].Data.Job1[j]) or (tc.Skill[i].Data.Job2[j]) then begin
                tc.Skill[i].Lv := tc.Skill[i].Data.MasterLV;
            end;
        end;

        tc.SkillPoint := 1000;
        SendCSkillList(tc);
        CalcStat(tc);
        SendCStat(tc);

        Result := 'GM_SKILLALL Success.';
    end;

    function command_statall(tc : TChara) : String;
    var
        i : Integer;
    begin
        Result := 'GM_STATALL Failure.';

        for i := 0 to 5 do begin
            tc.ParamBase[i] := 99;
        end;

        tc.StatusPoint := 1000;
        CalcStat(tc);
        SendCStat(tc);
        SendCStat1(tc, 0, $0009, tc.StatusPoint);

        Result := 'GM_STATALL Success.';
    end;

    function command_zeny(tc : TChara; str : String) : String;
    var
        i, k : Integer;
    begin
        Result := 'GM_ZENY Failure.';

        Val(Copy(str, 6, 256), i, k);
        if (k = 0) and (i >= -2147483647) and (i <= 2147483647) then begin
            if (tc.Zeny + i <= 2147483647) and (tc.Zeny + i >= 0) then begin
                tc.Zeny := tc.Zeny + i;
                SendCStat1(tc, 1, $0014, tc.Zeny);

                Result := 'GM_ZENY Success. ' + IntToStr(abs(i)) + ' Zeny';
                if (i = 0) then begin
                    tc.Zeny := i;
                    Result := Result + ' set.';
                end else
                if (i > 0) then begin
                    Result := Result + ' added.';
                end else if (i < 0) then begin
                    Result := Result + ' subtracted.';
                end;
            end else begin
                Result := Result + ' Zeny on hand amount out of range {0-2147483647).';
            end;
        end else begin
            Result := Result + ' Zeny amount out of range {-2147483647-2147483647).';
        end;
    end;

    function command_changeskill(tc : TChara; str : String) : String;
    var
        i, j, k : Integer;
        sl : TStringList;
    begin
        Result := 'GM_CHANGESKILL Failure.';

        sl := TStringList.Create;
        sl.DelimitedText := Copy(str, 13, 256);

        if (sl.Count = 2) then begin
            Val(sl.Strings[0], i, k);
            if k <> 0 then Exit;
            Val(sl.Strings[1], j, k);
            if k <> 0 then Exit;

            if ((i >= 1) and (i <= 157)) or ((i >= 210) and (i <= MAX_SKILL_NUMBER)) then begin
                if (j > tc.Skill[i].Data.MasterLV) then j := tc.Skill[i].Data.MasterLV;
                tc.Plag := i;
                tc.PLv := j;
                tc.Skill[i].Plag := true;
                SendCSkillList(tc);
                CalcStat(tc);
                SendCStat(tc);

                Result := 'GM_CHANGESKILL Success. Skill ' + IntToStr(i) + ' set to ' + IntToStr(j) + '.';
            end else begin
                Result := Result + ' Skill selection out of range. {1-157,210-' + IntToStr(MAX_SKILL_NUMBER) + '}.';
            end;
        end else begin
            Result := Result + ' Incomplete information.';
        end;

        sl.Free;
    end;

end.

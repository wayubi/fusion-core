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

    GM_Access_DB : TIntList32;

    procedure load_commands();
    procedure save_commands();
    procedure parse_commands(tc : TChara; str : String);
    function check_level(id : Integer; cmd : Integer) : Boolean;
    procedure command_alive(tc : TChara);
    procedure command_item();

implementation

    procedure load_commands();
    var
        ini : TIniFile;
        sl : TStringList;
    begin
        ini := TIniFile.Create(AppPath + 'gm_commands.ini');
        sl := TStringList.Create();
        sl.Clear;
        ini.ReadSectionValues('GM Commands', sl);

        if sl.IndexOfName('ALIVE') > -1 then GM_ALIVE := StrToInt(sl.Values['ALIVE']) else GM_ALIVE := 1;
        if sl.IndexOfName('ITEM') > -1 then GM_ITEM := StrToInt(sl.Values['ITEM']) else GM_ITEM := 1;

        sl.Free;
        ini.Free;
    end;

    procedure save_commands();
    var
        ini : TIniFile;
    begin
        ini := TIniFile.Create(AppPath + 'gm_commands.ini');

        ini.WriteString('GM Commands', 'ALIVE', IntToStr(GM_ALIVE));
        ini.WriteString('GM Commands', 'ITEM', IntToStr(GM_ITEM));

        ini.Free;
    end;

    procedure parse_commands(tc : TChara; str : String);

    begin
        str := Copy(str, Pos(' : ', str) + 4, 256);

        if ( (copy(str, 1, length('alive')) = 'alive') and (check_level(tc.ID, GM_ALIVE)) ) then command_alive(tc);
        if ( (copy(str, 1, length('item')) = 'item') and (check_level(tc.ID, GM_ITEM)) ) then command_item();
    end;

    function check_level(id : Integer; cmd : Integer) : Boolean;
    var
        GM_Access : TGM_Table;
        idx : Integer;
        tGM : TGM_Table;
    begin
        Result := False;
        tGM := GM_Access_DB.Objects[GM_Access_DB.IndexOf(id)] as TGM_Table;

        if (assigned(tGM)) then begin
            if ( (tGM.ID = id) and (tGM.Level >= cmd) ) then Result := True;
        end;
    end;

    procedure command_alive(tc : TChara);
    var
        tm : TMap;
    begin
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

    procedure command_item();
    begin
    end;

end.

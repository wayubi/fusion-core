unit Globals;

interface

uses
    MMSystem, Classes, SysUtils,
    Common,
    Zip, List32;

    function check_attack_lag(tc : TChara) : Boolean;

    procedure message_green(tc : TChara; str : String);
    procedure message_yellow(tc : TChara; str : String);
    procedure message_blue(tc : TChara; str : String);

    procedure backup_txt_database();

implementation

uses
	Main;

    function check_attack_lag(tc : TChara) : Boolean;
    begin
        Result := False;

        if ( (tc.DmgTick + 10000) > timeGetTime() ) then begin
            Result := True;
            message_green(tc, 'You are being attacked. Please try again in 10 seconds.');
        end else
    end;

    procedure message_green(tc : TChara; str : String);
    begin
        WFIFOW(0, $008e);
        WFIFOW(2, length(str) + 5);
        WFIFOS(4, str, length(str) + 1);
        tc.Socket.SendBuf(buf, length(str) + 5);
    end;

    procedure message_yellow(tc : TChara; str : String);
    begin
        WFIFOW(0, $009a);
        WFIFOW(2, length(str) + 5);
        WFIFOS(4, str, length(str) + 1);
        tc.Socket.SendBuf(buf, length(str) + 5);
    end;

    procedure message_blue(tc : TChara; str : String);
    begin
        WFIFOW(0, $009a);
        WFIFOW(2, length(str) + 9);
        WFIFOS(4, 'blue'+str, length(str) + 4);
        tc.Socket.SendBuf(buf, length(str) + 9);
    end;

    procedure backup_txt_database();
    var
	    zfile :TZip;
    	fileslist :TStringList;
	    filename :string;
    begin
	    DateSeparator      := '-';
    	TimeSeparator      := '-';
	    ShortDateFormat    := 'yyyy/mm/dd';
    	LongTimeFormat    := 'hh:mm:ss';

	    filename := datetostr(date) + ' - ' +timetostr(time);

    	CreateDir('backup');
	    zfile := tzip.create(frmMain);
    	zfile.Filename := AppPath + 'backup\' + filename + '.zip';

	    fileslist := tstringlist.Create;
    	fileslist.Add(AppPath + 'chara.txt');
	    fileslist.Add(AppPath + 'gcastle.txt');
    	fileslist.Add(AppPath + 'guild.txt');
	    fileslist.Add(AppPath + 'party.txt');
    	fileslist.Add(AppPath + 'pet.txt');
	    fileslist.Add(AppPath + 'player.txt');

	    zfile.FileSpecList := fileslist;
    	zfile.Add;
	    zfile.Free;

    	fileslist.Free;
    end;

end.
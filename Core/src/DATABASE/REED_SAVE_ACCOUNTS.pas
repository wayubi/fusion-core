unit REED_SAVE_ACCOUNTS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Save_Accounts_Parse(forced : Boolean = False);

    procedure PD_Save_Accounts_Basic(tp : TPlayer; datafile : TStringList);
    procedure PD_Save_Accounts_ActiveChars(tp : TPlayer; datafile : TStringList);
    procedure PD_Save_Accounts_Storage(tp : TPlayer; datafile : TStringList);

implementation

    procedure PD_Save_Accounts_Parse(forced : Boolean = False);
    var
        datafile : TStringList;
        i : Integer;
        tp : TPlayer;
        path : String;
        pfile : String;
    begin
        datafile := TStringList.Create;

        for i := 0 to Player.Count - 1 do begin
            datafile.Clear;
            path := AppPath + 'gamedata\Accounts';

            tp := Player.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            pfile := 'Account.txt';
            PD_Save_Accounts_Basic(tp, datafile);
            reed_savefile(tp.ID, datafile, path, pfile);

            pfile := 'ActiveChars.txt';
            PD_Save_Accounts_ActiveChars(tp, datafile);
            reed_savefile(tp.ID, datafile, path, pfile);

            pfile := 'Storage.txt';
            PD_Save_Accounts_Storage(tp, datafile);
            reed_savefile(tp.ID, datafile, path, pfile);
        end;

        FreeAndNil(datafile);
    end;

    procedure PD_Save_Accounts_Basic(tp : TPlayer; datafile : TStringList);
    begin
        datafile.Add('USERID : ' + IntToStr(tp.ID));
        datafile.Add('USERNAME : ' + tp.Name);
        datafile.Add('PASSWORD : ' + tp.Pass);

        if (tp.Gender = 0) then datafile.Add('SEX : FEMALE')
        else if (tp.Gender = 1) then datafile.Add('SEX : MALE');

        datafile.Add('EMAIL : ' + tp.Mail);

        if (tp.Banned = False) then datafile.Add('BANNED : NO')
        else if (tp.Banned = True) then datafile.Add('BANNED : YES');

        datafile.Add('ACCESSLEVEL : ' + IntToStr(tp.AccessLevel));
    end;

    procedure PD_Save_Accounts_ActiveChars(tp : TPlayer; datafile : TStringList);
    begin
        datafile.Add('SLOT1 : ' + tp.CName[0]);
        datafile.Add('SLOT2 : ' + tp.CName[1]);
        datafile.Add('SLOT3 : ' + tp.CName[2]);
        datafile.Add('SLOT4 : ' + tp.CName[3]);
        datafile.Add('SLOT5 : ' + tp.CName[4]);
        datafile.Add('SLOT6 : ' + tp.CName[5]);
        datafile.Add('SLOT7 : ' + tp.CName[6]);
        datafile.Add('SLOT8 : ' + tp.CName[7]);
        datafile.Add('SLOT9 : ' + tp.CName[8]);
    end;

    procedure PD_Save_Accounts_Storage(tp : TPlayer; datafile : TStringList);
    begin
        compile_inventories(datafile, tp.Kafra.Item)
    end;

end.

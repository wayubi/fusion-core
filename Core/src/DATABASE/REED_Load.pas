unit REED_Load;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Accounts(UID : String = '*');
    procedure PD_Load_Accounts_ActiveCharacters(UID : String = '*');
    procedure PD_Load_Accounts_Storage(UID : String = '*');

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Accounts ----------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Accounts(UID : String = '*');
    var
        path : String;
        pfile : String;
        resultlist : TStringList;
        i : Integer;
        tp : TPlayer;
    begin
        path := AppPath+'gamedata\Accounts\';
        pfile := 'Account.txt';
        resultlist := get_list(path, pfile);

        for i := 0 to resultlist.Count - 1 do begin
            path := path + resultlist[i] + '\' + pfile;

            if (UID = '*') then tp := TPlayer.Create
            else tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

            tp.ID := retrieve_data(0, path, 1);
            tp.Name := retrieve_data(1, path);
            tp.Pass := retrieve_data(2, path);

            if retrieve_data(3, path) = 'MALE' then tp.Gender := 1
            else if retrieve_data(3, path) = 'FEMALE' then tp.Gender := 0;

            tp.Mail := retrieve_data(4, path);

            if retrieve_data(5, path) = 'YES' then tp.Banned := 1
            else if retrieve_data(5, path) = 'NO' then tp.Banned := 0;

            tp.AccessLevel := retrieve_data(6, path, 1);

            if (UID = '*') then begin
                PlayerName.AddObject(tp.Name, tp);
                Player.AddObject(tp.ID, tp);
            end;
        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Active Characters into Accounts ------------------------------------ }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Accounts_ActiveCharacters(UID : String = '*');
    var
        path : String;
        pfile : String;
        resultlist : TStringList;
        i, j : Integer;
        tp : TPlayer;
    begin
        path := AppPath+'gamedata\Accounts\';
        pfile := 'ActiveChars.txt';
        resultlist := get_list(path, pfile);

        for i := 0 to resultlist.Count - 1 do begin
            path := path + resultlist[i] + '\' + pfile;

            if Player.IndexOf(StrToInt(resultlist[i])) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(StrToInt(resultlist[i]))] as TPlayer;

            for j := 0 to 8 do begin
                tp.CName[j] := retrieve_data(j, path);
            end;
        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Active Characters into Accounts ------------------------------------ }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Accounts_Storage(UID : String = '*');
	var
        path : String;
        pfile : String;
        resultlist : TStringList;
        i, j : Integer;
        tp : TPlayer;
    begin
        path := AppPath+'gamedata\Accounts\';
        pfile := 'Storage.txt';
        resultlist := get_list(path, pfile);

        for i := 0 to resultlist.Count - 1 do begin
            path := path + resultlist[i] + '\' + pfile;

            if Player.IndexOf(StrToInt(resultlist[i])) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(StrToInt(resultlist[i]))] as TPlayer;

            retrieve_inventories(path, tp.Kafra.Item);
        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }

end.

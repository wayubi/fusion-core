unit WAC;

interface

uses
    StrUtils, SysUtils,
    Common, PlayerData,
    BRSHttpSrv;

var
    BRSHttpSrv1 : TBRSHttpSrv;

    function parse_wac(URI : String) : String;
    function account_exists(username : String) : Boolean;
    procedure create_account(username : String; password : String; email : String; sex : String);

    procedure create_wac();
    procedure destroy_wac(forced : Boolean = False);

implementation

uses
    Main;

    {
        Result Types:
        -------------
          0 - Display Basic Index Page.
          1 - Account already exists.
          2 - Passwords do not match.
          3 - Email does not contain '@'.
          4 - Password / Username length too short.
          5 - Success. Account created.
          6 - Missing information.
    }

    function parse_wac(URI : String) : String;
    var
        username : String;
        password1 : String;
        password2 : String;
        email : String;
        sex : String;

        result_type : Integer;
    begin
        if (URI = '/index.html') or (URI = '/') then result_type := 0
        else if AnsiContainsStr(URI, 'action=Create+Account') then begin
            username := AnsiMidStr(URI, AnsiPos('USERNAME=', URI) + 9, AnsiPos('&PASSWORD1=', URI) - AnsiPos('USERNAME=', URI) - 9);
            password1 := AnsiMidStr(URI, AnsiPos('PASSWORD1=', URI) + 10, AnsiPos('&PASSWORD2=', URI) - AnsiPos('PASSWORD1=', URI) - 10);
            password2 := AnsiMidStr(URI, AnsiPos('PASSWORD2=', URI) + 10, AnsiPos('&EMAIL=', URI) - AnsiPos('PASSWORD2=', URI) - 10);
            email := AnsiMidStr(URI, AnsiPos('EMAIL=', URI) + 6, AnsiPos('&SEX=', URI) - AnsiPos('EMAIL=', URI) - 6);
            sex := AnsiMidStr(URI, AnsiPos('SEX=', URI) + 4, AnsiPos('&action=', URI) - AnsiPos('SEX=', URI) - 4);

            if (username = '') or (password1 = '') or (password2 = '') or (email = '') or (sex = '') then result_type := 6
            else if account_exists(username) then result_type := 1
            else if (password1 <> password2) then result_type := 2
            else if (not AnsiContainsStr(email, '@')) and (not AnsiContainsStr(email, '%40')) then result_type := 3
            else if (length(username) < 4) or (length(password1) < 4) then result_type := 4

            else begin
                create_account(username, password1, email, sex);
                result_type := 5;
            end;
        end;

        case result_type of
            0: Result := 'WAC/index.html';
            1: Result := 'WAC/account_exists.html';
            2: Result := 'WAC/password_mismatch.html';
            3: Result := 'WAC/check_email.html';
            4: Result := 'WAC/userpass_length.html';
            5: Result := 'WAC/success.html';
            6: Result := 'WAC/missing.html';
        end;
    end;

    function account_exists(username : String) : Boolean;
    var
        tp : TPlayer;
    begin
        if PlayerName.IndexOf(username) = -1 then Result := False
        else Result := True;
    end;

    procedure create_account(username : String; password : String; email : String; sex : String);
    var
        Idx : Integer;
        i : Integer;
        tp : TPlayer;
    begin
        Idx := 100101;
        i := 0;

        for i := 0 to Player.Count - 1 do begin
            tp := Player.Objects[i] as TPlayer;
            if (tp.ID <> i + 100101) and (tp.ID > 100100) then begin
                Idx := i + 100101;
                Break;
            end;
        end;

        if (i = Player.Count) then Idx := 100101 + Player.Count;

        tp := TPlayer.Create;
        tp.ID := Idx;
        tp.Name := username;
        tp.Pass := password;

        if (sex = 'M') then tp.Gender := 1
        else if (sex = 'F') then tp.Gender := 0;

        tp.Mail := '-@-';
        tp.Login := 0;
        PlayerName.AddObject(tp.Name, tp);
        Player.AddObject(tp.ID, tp);

        PD_Save_Accounts(True);
    end;

    procedure create_wac();
    begin
        if (Option_Enable_WAC) then begin
            BRSHttpSrv1 := TBRSHttpSrv.Create(frmMain);
            BRSHttpSrv1.Port := wacport;
            try
                BRSHttpSrv1.Start;
            except
                debugout.Lines.add('WAC was unable to use that port.');
                destroy_wac(true);
            end;
        end;
    end;

    procedure destroy_wac(forced : Boolean = False);
    begin
        if (not (Option_Enable_WAC) and assigned(BRSHttpSrv1)) or (forced and assigned(BRSHttpSrv1))  then begin
            BRSHttpSrv1.Stop;
            BRSHttpSrv1 := nil;
        end;
    end;

end.

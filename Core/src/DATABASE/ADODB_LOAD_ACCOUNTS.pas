unit ADODB_LOAD_ACCOUNTS;

interface

uses
    Common, Classes, SysUtils;

    procedure adodb_load_account(UID : String = '*');

implementation

uses
    Main;

    procedure adodb_load_account(UID : String = '*');
    var
      sqlCommand : string;
      tp : TPlayer;
    begin

      if (UID = '*') then begin
        sqlCommand := 'select account_id, userid, user_pass, email, sex, level, ban_until from login;';
      end else begin
        sqlCommand := 'select account_id, userid, user_pass, email, sex, level, ban_until from login where userid = ''' +UID+ ''';';
      end;

      frmMain.ADODataSet1.CommandText := sqlCommand;
      frmMain.ADODataSet1.Open;

      debugout.Lines.Add('Loading eAthena SQL login table');

      while not frmMain.ADODataSet1.Eof do begin

        if not (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'S') then begin
          tp := TPlayer.Create;

          tp.ID := frmMain.ADODataSet1.FieldByName('account_id').CurValue;
          tp.Name := frmMain.ADODataSet1.FieldByName('userid').CurValue;
          tp.Pass := frmMain.ADODataSet1.FieldByName('user_pass').CurValue;
          tp.Mail := frmMain.ADODataSet1.FieldByName('email').CurValue;
          tp.AccessLevel := frmMain.ADODataSet1.FieldByName('level').CurValue;

          if (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'M') then tp.Gender := 1
          else if (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'F') then tp.Gender := 0;

          tp.Banned := False;
          
          PlayerName.AddObject(tp.Name, tp);
          Player.AddObject(tp.ID, tp);

          //tp := Player.Objects[Player.IndexOf(frmMain.ADODataSet1.FieldByName('account_id').CurValue)] as TPlayer;
          //debugout.Lines.Add('Player '+tp.Name+' was loaded successfully.');
        end;

        frmMain.ADODataSet1.Next;
      end;

    end;
    
end.

unit FusionSQL;

interface

uses
        Windows, MMSystem, Forms, Classes, SysUtils, IniFiles, Common, DBXpress, DB, SqlExpr, StrUtils;

        function MySQL_Query(sqlcmd: String) : Boolean;
        function Load_Accounts(userid: String; AID: cardinal = 0) : Boolean;

implementation

var
        SQLDataSet : TSQLDataSet;
        SQLConnection : TSQLConnection;

{ Makes an SQL Connection - Parses SQL Commands }        
function MySQL_Query(sqlcmd: String) : Boolean;
begin
        Result := False;

        if not assigned(SQLConnection) then begin
                SQLConnection := TSQLConnection.Create(nil);
                SQLConnection.ConnectionName := 'MySQLConnection';
                SQLConnection.DriverName := 'MySQL';
                SQLConnection.GetDriverFunc := 'getSQLDriverMYSQL';
                SQLConnection.KeepConnection := True;
                SQLConnection.LibraryName := 'dbexpmysql.dll';
                SQLConnection.LoginPrompt := False;
                SQLConnection.VendorLib := 'libmysql.dll';
                SQLConnection.Params.Values['HostName'] := DbHost;
                SQLConnection.Params.Values['Database'] := DbName;
                SQLConnection.Params.Values['User_Name'] := DbUser;
                SQLConnection.Params.Values['Password'] := DbPass;
        end;

        if not SQLConnection.Connected then begin
                try
                        SQLConnection.Connected := True;
                except
                        DebugOut.Lines.Add('*** Error on MySQL Connect.');
                        Exit;
                end;
        end;

        if not assigned(SQLDataSet) then begin
                SQLDataSet := TSQLDataSet.Create(nil);
                SQLDataSet.SQLConnection := SQLConnection;
        end;

        if SQLDataSet.Active then SQLConnection.Close;

        SQLDataSet.CommandText := sqlcmd;

        if UpperCase(copy(SQLDataSet.CommandText,1,6)) <> 'SELECT' then begin
                try
                        SQLDataSet.ExecSQL;
		except
                        DebugOut.Lines.Add( Format( '*** Execute SQL Error: %s', [sqlcmd] ) );
                        exit;
                end;
                Result := True;
                Exit;
        end;

        try
                SQLDataSet.Open;
        except
                DebugOut.Lines.Add( Format( '*** Open SQL Data Error: %s', [sqlcmd] ) );
                exit;
        end;
        Result := True;
end;

function Load_Accounts(userid: String; AID: cardinal = 0) : Boolean;
var
        tp : TPlayer;
        i : Integer;
        sl : TStringList;
        query : string;
begin
        Result := False;
        sl := TStringList.Create;
        sl.QuoteChar := '"';
        sl.Delimiter := ',';

        if AID = 0 then begin
                if (PlayerName.IndexOf(userid) <> -1) then begin
                        tp := PlayerName.Objects[PlayerName.IndexOf(userid)] as TPlayer;
                end else begin
                        tp := TPlayer.Create;
                end;
        end

        else begin
                if (assigned(PlayerName)) then begin
                        if (Player.IndexOf(AID) <> -1) then begin
                                Result := True;
                                Exit;
                        end;
                end;
        end;

        query := 'SELECT A.AID, A.ID, A.passwd, A.Gender, A.Mail, A.Banned, A.regDate, S.storeitem, S.money FROM accounts AS A LEFT JOIN storage AS S ON S.AID=A.AID WHERE A.ID = '+''''+userid+''''+' LIMIT 1';
        if MySQL_Query(query) then begin
                SQLDataSet.First;
                if not SQLDataSet.Eof then begin
                        tp.ID := StrToInt(SQLDataSet.FieldValues['AID']);
                        tp.Name := SQLDataSet.FieldValues['ID'];
                        tp.Pass := SQLDataSet.FieldValues['passwd'];
                        tp.Gender := SQLDataSet.FieldValues['Gender'];
                        tp.Mail := SQLDataSet.FieldValues['Mail'];
                        tp.Banned := StrToInt(SQLDataSet.FieldValues['Banned']);
                        tp.ver2 := 9;
                        if (SQLDataSet.FieldValues['storeitem'] <> '') then begin
                                with SQLDataSet do begin
                                        sl.Clear;
                                        sl.DelimitedText := SQLDataSet.FieldValues['storeitem'];

                                        for i := 0 to ((sl.Count div 10) - 1) do begin
                                                tp.Kafra.Item[i+1].ID := strtoint(sl.Strings[0+i*10]);
                                                tp.Kafra.Item[i+1].Amount := strtoint(sl.Strings[1+i*10]);
                                                tp.Kafra.Item[i+1].Equip := strtoint(sl.Strings[2+i*10]);
                                                tp.Kafra.Item[i+1].Identify := strtoint(sl.Strings[3+i*10]);
                                                tp.Kafra.Item[i+1].Refine := strtoint(sl.Strings[4+i*10]);
                                                tp.Kafra.Item[i+1].Attr := strtoint(sl.Strings[5+i*10]);
                                                tp.Kafra.Item[i+1].Card[0] := strtoint(sl.Strings[6+i*10]);
                                                tp.Kafra.Item[i+1].Card[1] := strtoint(sl.Strings[7+i*10]);
                                                tp.Kafra.Item[i+1].Card[2] := strtoint(sl.Strings[8+i*10]);
                                                tp.Kafra.Item[i+1].Card[3] := strtoint(sl.Strings[9+i*10]);
                                                tp.Kafra.Item[i+1].Data := ItemDB.Objects[ItemDB.IndexOf(tp.Kafra.Item[i+1].ID)] as TItemDB;
                                        end;
                                        sl.Free;
                                        CalcInventory(tp.Kafra);
                                end;
                        end;
                end;

                for i := 0 to 8 do begin
                        tp.CID[i] := 0;
                        tp.CName[i] := '';
                        tp.CData[i] := nil;
                end;

                if (AID = 0) then begin
                        if (PlayerName.IndexOf(userid) <> -1) then begin
                        end else begin
                                PlayerName.AddObject(tp.Name, tp);
                                Player.AddObject(tp.ID, tp);
                        end;
                end;

                Result := True;
        end;
end;

end.

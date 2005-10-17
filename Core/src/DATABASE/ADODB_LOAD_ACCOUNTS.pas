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
    begin

        frmMain.ADODataSet1.CommandText := 'select * from login;';
        frmMain.ADODataSet1.Open;

        debugout.Lines.Add('Loading eAthena SQL login table');
        while not frmMain.ADODataSet1.Eof do begin
          debugout.Lines.Add(frmMain.ADODataSet1.Fields[1].CurValue);
          frmMain.ADODataSet1.Next;
        end;

        
       {
       while not frmMain.ADODataSet1.Eof do begin
        debugout.Lines.Add(frmMain.ADODataSet1.Fields[0].CurValue);
        frmMain.ADODataSet1.Next;
       end;
        }

       {
        ADODataSet1.CommandText := 'show databases;';
        ADODataSet1.Open;
        debugout.Lines.Add(ADODataSet1.Fields[0].CurValue);
        }




    end;
    
end.

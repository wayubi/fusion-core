unit REED_LOAD_PARTIES;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Parties_Pre_Parse(UID : String = '*');
    procedure PD_Load_Parties_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);

    procedure PD_Load_Parties_Settings(tpa : TParty; path : String);
    procedure PD_Load_Parties_Members(tpa : TParty; path : String);

    function select_load_party(UID : String; tp : TPlayer; partyid : Cardinal) : TParty;
    function party_is_online(tpa : TParty) : Boolean;

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Parties Pre Parse  ------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Parties_Pre_Parse(UID : String = '*');
    var
        basepath : String;
        pfile : String;
        accountlist : TStringList;
        i : Integer;
        tp : TPlayer;
    begin
        basepath := AppPath + 'gamedata\Accounts\';
        pfile := 'Account.txt';
        accountlist := get_list(basepath, pfile);

        basepath := AppPath + 'gamedata\Parties\';

        for i := 0 to accountlist.Count - 1 do begin
            if Player.IndexOf(reed_convert_type(accountlist[i], 0, -1)) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(reed_convert_type(accountlist[i], 0, -1))] as TPlayer;

            pfile := 'Members.txt';
            PD_Load_Parties_Parse(UID, tp, get_list(basepath, pfile), basepath);

            if (UID <> '*') then Break;
        end;

        FreeAndNil(accountlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Parties Parse  ----------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Parties_Parse(UID : String; tp : TPlayer; resultlist : TStringList; basepath : String);
    var
        i : Integer;
        pfile : String;
        path : String;
        tpa : TParty;
    begin

        for i := 0 to resultlist.Count - 1 do begin

            tpa := select_load_party(UID, tp, reed_convert_type(resultlist[i], 0, -1));
            if not assigned(tpa) then Continue;

            if (UID <> '*') then
                if party_is_online(tpa) then Continue;
            
            pfile := 'Settings.txt';
            path := basepath + resultlist[i] + '\' + pfile;
            PD_Load_Parties_Settings(tpa, path);

            pfile := 'Members.txt';
            path := basepath + resultlist[i] + '\' + pfile;
            PD_Load_Parties_Members(tpa, path);

            NowPartyID := (tpa.ID + 1);

            if (UID = '*') then begin
                PartyNameList.AddObject(tpa.Name, tpa);
                PartyList.AddObject(tpa.ID, tpa);
            end;

        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Parties Settings --------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Parties_Settings(tpa : TParty; path : String);
    begin
        tpa.Name := retrieve_data(0, path);
        tpa.ID := retrieve_data(1, path, 1);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Parties Members ---------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Parties_Members(tpa : TParty; path : String);
    var
        i, j : Integer;
        tc : TChara;
    begin

        for i := 0 to 11 do begin
            tpa.MemberID[i] := 0;
        end;

        for i := 0 to retrieve_length(path) do begin
            j := retrieve_value(path, 0, 0);

            if Chara.IndexOf(j) = -1 then Continue;
            tc := Chara.Objects[Chara.IndexOf(j)] as TChara;

            tpa.MemberID[i] := j;
            tpa.Member[i] := tc;
            tc.PartyName := tpa.Name;
            tc.PartyID := tpa.ID;
        end;

    end;
    { ------------------------------------------------------------------------------------- }

    

    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - Party Supplemental Functions                                                }
    { ------------------------------------------------------------------------------------- }

    
    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - select_load_party                                                           }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To allow party parsing to create or select the proper party for loading.     }
    { Parameters:                                                                           }
    {  - UID : String, Represents the account ID to load.                                   }
    {  - tp : TPlayer, Represents the player data.                                          }
    {  - partyid : Cardinal, Represents the party's ID.                                     }
    { Results:                                                                              }
    {  - Result : TParty, Represents the selected party.                                    }
    { ------------------------------------------------------------------------------------- }
    function select_load_party(UID : String; tp : TPlayer; partyid : Cardinal) : TParty;
    var
        i : Integer;
        tpa : TParty;
    begin

        if (UID <> '*') then begin

            for i := 0 to 8 do begin
                if tp.CName[i] = '' then Continue;

                if (tp.CData[i].PartyID = partyid) then begin
                    if PartyList.IndexOf(partyid) = -1 then Continue;
                    tpa := PartyList.Objects[PartyList.IndexOf(partyid)] as TParty;
                    Break;
                end;
            end;

        end else begin
            tpa := TParty.Create;
        end;

        Result := tpa;
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - party_is_online                                                             }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To see if any party members are online for loading purposes.                 }
    { Parameters:                                                                           }
    {  - tpa : TParty, Represents the party data to check.                                  }
    { Results:                                                                              }
    {  - Result : Boolean, Represents the return value of whether or not onnline.           }
    { ------------------------------------------------------------------------------------- }
    function party_is_online(tpa : TParty) : Boolean;
    var
        i : Integer;
    begin
        Result := False;

        for i := 0 to 11 do begin
            if (tpa.MemberID[i] <> 0) then begin
                if tpa.Member[i].Login <> 0 then begin
                    Result := True;
                    Break;
                end;
            end;
        end;

    end;
    { ------------------------------------------------------------------------------------- }

end.

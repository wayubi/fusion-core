unit REED_LOAD_PETS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Pets_Parse(UID : String = '*');
    procedure PD_Load_Pets(UID : String; resultlist : TStringList; basepath : String; pfile : String);
    procedure PD_Load_Pets_Finalize(tpe : TPet);
    function PD_Load_Pets_Data(tpe : TPet; petitem : TItem) : TItem;

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Pets Parser -------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Pets_Parse(UID : String = '*');
    var
        basepath : String;
        path : String;
        pfile : String;
        resultlist : TStringList;
        resultlist2 : TStringList;
        i, j : Integer;
        tp : TPlayer;
        tc : TChara;
    begin
        basepath := AppPath + 'gamedata\Accounts\';
        pfile := 'Account.txt';
        resultlist := get_list(basepath, pfile);

        for i := 0 to resultlist.Count - 1 do begin
            if Player.IndexOf(reed_convert_type(resultlist[i], 0, -1)) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(reed_convert_type(resultlist[i], 0, -1))] as TPlayer;

            if (UID = '*') then path := basepath + resultlist[i] + '\Pets\'
            else path := basepath + UID + '\Pets\';

            pfile := 'Pet.txt';
            PD_Load_Pets(UID, get_list(path, pfile), path, pfile);

            if (UID <> '*') then Break;
        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Pets --------------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Pets(UID : String; resultlist : TStringList; basepath : String; pfile : String);
    var
        i : Integer;
        path : String;
        tpe : TPet;
    begin
        for i := 0 to resultlist.Count - 1 do begin
            path := basepath + resultlist[i] + '\' + pfile;

            if (UID = '*') then begin
                tpe := TPet.Create;
            end else begin
                if PetList.IndexOf(reed_convert_type(resultlist[i], 0, -1)) = -1 then Continue;
                tpe := PetList.Objects[PetList.IndexOf(reed_convert_type(resultlist[i], 0, -1))] as TPet;
            end;

            tpe.PlayerID := retrieve_data(0, path, 1);
            tpe.CharaID := retrieve_data(1, path, 1);
            tpe.Cart := retrieve_data(2, path, 1);
            tpe.Index := retrieve_data(3, path, 1);
            tpe.Incubated := retrieve_data(4, path, 1);
            tpe.PetID := retrieve_data(5, path, 1);
            tpe.JID := retrieve_data(6, path, 1);
            tpe.Name := retrieve_data(7, path);
            tpe.Renamed := retrieve_data(8, path, 1);
            tpe.LV := retrieve_data(9, path, 1);
            tpe.Relation := retrieve_data(10, path, 1);
            tpe.Fullness := retrieve_data(11, path, 1);
            tpe.Accessory := retrieve_data(12, path, 1);

            if (tpe.Index < 1) or (tpe.Index > 100) then Continue;
            if (tpe.PlayerID = 0) then Continue;

            PD_Load_Pets_Finalize(tpe);

            if (UID = '*') then begin
                PetList.AddObject(tpe.PetID, tpe);
            end;
        end;

        FreeAndNil(resultlist);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Pets Finalize ------------------------------------------------------ }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Pets_Finalize(tpe : TPet);
    var
        i : Integer;
        tp : TPlayer;
        tc : TChara;
    begin

        if tpe.Incubated = 0 then begin
            tp := Player.IndexOfObject(tpe.PlayerID) as TPlayer;
            PD_Load_Pets_Data(tpe, tp.Kafra.Item[tpe.Index]);
        end

        else begin
            tc := Chara.IndexOfObject(tpe.CharaID) as TChara;

            if (tpe.Cart = 0) then PD_Load_Pets_Data(tpe, tc.Item[tpe.Index])
            else PD_Load_Pets_Data(tpe, tc.Cart.Item[tpe.Index])
        end;
        
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Pets Data ---------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    function PD_Load_Pets_Data(tpe : TPet; petitem : TItem) : TItem;
    var
        i, j : Integer;
        tpd : TPetDB;
        tmd : TMobDB;
    begin
        petitem.Attr := tpe.Incubated;
        petitem.Card[0] := $FF00;
        petitem.Card[1] := tpe.PetID;
        petitem.Card[2] := tpe.PetID mod $10000;
        petitem.Card[3] := tpe.PetID div $10000;

        for i := 0 to PetDB.Count - 1 do begin
            tpd := PetDB.Objects[i] as TPetDB;
            if tpd.EggID = petitem.ID then begin
                tpe.JID := tpd.MobID;
                j := MobDB.IndexOf(tpd.MobID);
                if j <> -1 then begin
                    tmd := MobDB.Objects[j] as TMobDB;
                    tpe.LV := tmd.LV;
                end;
                tpe.Data := tpd;
                Break;
            end;
        end;

        if NowPetID <= tpe.PetID then NowPetID := tpe.PetID + 1;

        Result := petitem;
    end;
    { ------------------------------------------------------------------------------------- }

end.


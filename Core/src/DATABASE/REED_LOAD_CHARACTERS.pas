unit REED_LOAD_CHARACTERS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Load_Characters(UID : String = '*');

implementation

    { ------------------------------------------------------------------------------------- }
    { - R.E.E.D - Load Characters --------------------------------------------------------- }
    { ------------------------------------------------------------------------------------- }
    procedure PD_Load_Characters(UID : String = '*');
    var
        path : String;
        pfile : String;
        resultlist : Array[0..1] of TStringList;
        i, j, k : Integer;
        tp : TPlayer;
        tc : TChara;
    begin
        path := AppPath+'gamedata\Accounts\';
        pfile := 'Account.txt';
        resultlist[0] := get_list(path, pfile);

        for i := 0 to resultlist[0].Count - 1 do begin

            if Player.IndexOf(StrToInt(resultlist[0][i])) = -1 then Continue;
            tp := Player.Objects[Player.IndexOf(StrToInt(resultlist[0][i]))] as TPlayer;

            path := path + resultlist[0][i] + '\Characters\';
            pfile := 'Character.txt';
            resultlist[1] := get_list(path, pfile);

            for j := 0 to resultlist[1].Count - 1 do begin
                path := path + resultlist[1][j] + '\' + pfile;

                if (UID = '*') then begin tc := TChara.Create;
                end else begin
                    if Chara.IndexOf(StrToInt(resultlist[1][j])) = -1 then Continue;
                    tc := Chara.Objects[Chara.IndexOf(StrToInt(resultlist[1][j]))] as TChara;

                    if (tc.Name <> tp.CName[0]) and (tc.Name <> tp.CName[1]) and (tc.Name <> tp.CName[2])
                    and (tc.Name <> tp.CName[3]) and (tc.Name <> tp.CName[4]) and (tc.Name <> tp.CName[5])
                    and (tc.Name <> tp.CName[6]) and (tc.Name <> tp.CName[7]) and (tc.Name <> tp.CName[8]) then begin
                        Continue;
                    end;
                end;

                tc.Name := retrieve_data(0, path);
                tc.ID := retrieve_data(1, path, 1);
                tc.CID := retrieve_data(2, path, 1);

                tc.JID := retrieve_data(3, path, 1);
                if (tc.JID > LOWER_JOB_END) then tc.JID := tc.JID - LOWER_JOB_END + UPPER_JOB_BEGIN;

                tc.BaseLV := retrieve_data(4, path, 1);
                tc.BaseEXP := retrieve_data(5, path, 1);
                tc.StatusPoint := retrieve_data(6, path, 1);
                tc.JobLV := retrieve_data(7, path, 1);
                tc.JobEXP := retrieve_data(8, path, 1);
                tc.SkillPoint := retrieve_data(9, path, 1);
                tc.Zeny := retrieve_data(10, path, 1);
                tc.Stat1 := retrieve_data(11, path, 1);
                tc.Stat2 := retrieve_data(12, path, 1);
                tc.Option := retrieve_data(13, path, 1);
                tc.Karma := retrieve_data(14, path, 1);
                tc.Manner := retrieve_data(15, path, 1);
                tc.HP := retrieve_data(16, path, 1);
                tc.SP := retrieve_data(17, path, 1);
                tc.DefaultSpeed := retrieve_data(18, path, 1);
                tc.Hair := retrieve_data(19, path, 1);
                tc._2 := retrieve_data(20, path, 1);
                tc._3 := retrieve_data(21, path, 1);
                tc.Weapon := retrieve_data(22, path, 1);
                tc.Shield := retrieve_data(23, path, 1);
                tc.Head1 := retrieve_data(24, path, 1);
                tc.Head2 := retrieve_data(25, path, 1);
                tc.Head3 := retrieve_data(26, path, 1);
                tc.HairColor := retrieve_data(27, path, 1);
                tc.ClothesColor := retrieve_data(28, path, 1);
                tc.ParamBase[0] := retrieve_data(29, path, 1);
                tc.ParamBase[1] := retrieve_data(30, path, 1);
                tc.ParamBase[2] := retrieve_data(31, path, 1);
                tc.ParamBase[3] := retrieve_data(32, path, 1);
                tc.ParamBase[4] := retrieve_data(33, path, 1);
                tc.ParamBase[5] := retrieve_data(34, path, 1);
                tc.CharaNumber := retrieve_data(35, path, 1);
                tc.Map := retrieve_data(36, path);
                tc.Point.X := retrieve_data(37, path, 1);
                tc.Point.Y := retrieve_data(38, path, 1);
                tc.SaveMap := retrieve_data(39, path);
                tc.SavePoint.X := retrieve_data(40, path, 1);
                tc.SavePoint.Y := retrieve_data(41, path, 1);
                tc.Plag := retrieve_data(42, path, 1);
                tc.PLv := retrieve_data(43, path, 1);
                tc.GuildID := retrieve_data(44, path, 1);

                tc.PData := tp;

                if (UID = '*') then begin
                    CharaName.AddObject(tc.Name, tc);
                    Chara.AddObject(tc.CID, tc);
                end;
                
            end;

            for j := 0 to 8 do begin
                tp.CData[j] := nil;
                if CharaName.IndexOf(tp.CName[j]) = -1 then Continue;
                tp.CData[j] := CharaName.Objects[CharaName.IndexOf(tp.CName[j])] as TChara;
                tp.CData[j].CharaNumber := j;
                tp.CData[j].ID := tp.ID;
                tp.CData[j].Gender := tp.Gender;
            end;
            
        end;

        FreeAndNil(resultlist);
    end;

    { ------------------------------------------------------------------------------------- }

end.

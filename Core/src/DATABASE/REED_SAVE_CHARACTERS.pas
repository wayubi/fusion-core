unit REED_SAVE_CHARACTERS;

interface

uses
    Common, REED_Support,
    Classes, SysUtils;

    procedure PD_Save_Characters_Parse(forced : Boolean = False);

    procedure PD_Save_Characters_Basic(tc : TChara; datafile : TStringList);
    procedure PD_Save_Characters_Memos(tc : TChara; datafile : TStringList);
    procedure PD_Save_Characters_Skills(tc : TChara; datafile : TStringList);
    procedure PD_Save_Characters_Inventory(tc : TChara; datafile : TStringList);

implementation

    procedure PD_Save_Characters_Parse(forced : Boolean = False);
    var
        datafile : TStringList;
        i : Integer;
        tc : TChara;
        tp : TPlayer;
        path : String;
        pfile : String;
    begin
        datafile := TStringList.Create;

        for i := 0 to Chara.Count - 1 do begin
            datafile.Clear;
            tc := Chara.Objects[i] as TChara;
            tp := tc.PData;

            path := AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters';

            if (tp.Login = 0) and (not forced) then Continue;

            pfile := 'Character.txt';
            PD_Save_Characters_Basic(tc, datafile);
            reed_savefile(tc.CID, datafile, path, pfile);

            pfile := 'ActiveMemos.txt';
            PD_Save_Characters_Memos(tc, datafile);
            reed_savefile(tc.CID, datafile, path, pfile);

            pfile := 'Skills.txt';
            PD_Save_Characters_Skills(tc, datafile);
            reed_savefile(tc.CID, datafile, path, pfile);

            pfile := 'Inventory.txt';
            PD_Save_Characters_Inventory(tc, datafile);
            reed_savefile(tc.CID, datafile, path, pfile);
        end;

        FreeAndNil(datafile);
    end;

    procedure PD_Save_Characters_Basic(tc : TChara; datafile : TStringList);
    begin
        datafile.Add('NAM : ' + tc.Name);
        datafile.Add('AID : ' + IntToStr(tc.ID));
        datafile.Add('CID : ' + IntToStr(tc.CID));

        if (tc.JID > UPPER_JOB_BEGIN) then datafile.Add('JID : ' + IntToStr(tc.JID - UPPER_JOB_BEGIN + LOWER_JOB_END))
        else datafile.Add('JID : ' + IntToStr(tc.JID));

        datafile.Add('BLV : ' + IntToStr(tc.BaseLV));
        datafile.Add('BXP : ' + IntToStr(tc.BaseEXP));
        datafile.Add('STP : ' + IntToStr(tc.StatusPoint));
        datafile.Add('JLV : ' + IntToStr(tc.JobLV));
        datafile.Add('JXP : ' + IntToStr(tc.JobEXP));
        datafile.Add('SKP : ' + IntToStr(tc.SkillPoint));
        datafile.Add('ZEN : ' + IntToStr(tc.Zeny));

        datafile.Add('ST1 : ' + IntToStr(tc.Stat1));
        datafile.Add('ST2 : ' + IntToStr(tc.Stat2));
        datafile.Add('OPT : ' + IntToStr(tc.Option and $FFF9));
        datafile.Add('KAR : ' + IntToStr(tc.Karma));
        datafile.Add('MAN : ' + IntToStr(tc.Manner));

        if tc.HP < 0 then tc.HP := 0;
        if tc.SP < 0 then tc.SP := 0;

        datafile.Add('CHP : ' + IntToStr(tc.HP));
        datafile.Add('CSP : ' + IntToStr(tc.SP));
        datafile.Add('SPD : ' + IntToStr(tc.DefaultSpeed));
        datafile.Add('HAR : ' + IntToStr(tc.Hair));
        datafile.Add('C_2 : ' + IntToStr(tc._2));
        datafile.Add('C_3 : ' + IntToStr(tc._3));
        datafile.Add('WPN : ' + IntToStr(tc.Weapon));
        datafile.Add('SHD : ' + IntToStr(tc.Shield));
        datafile.Add('HD1 : ' + IntToStr(tc.Head1));
        datafile.Add('HD2 : ' + IntToStr(tc.Head2));
        datafile.Add('HD3 : ' + IntToStr(tc.Head3));
        datafile.Add('HCR : ' + IntToStr(tc.HairColor));
        datafile.Add('CCR : ' + IntToStr(tc.ClothesColor));

        datafile.Add('STR : ' + IntToStr(tc.ParamBase[0]));
        datafile.Add('AGI : ' + IntToStr(tc.ParamBase[1]));
        datafile.Add('VIT : ' + IntToStr(tc.ParamBase[2]));
        datafile.Add('INT : ' + IntToStr(tc.ParamBase[3]));
        datafile.Add('DEX : ' + IntToStr(tc.ParamBase[4]));
        datafile.Add('LUK : ' + IntToStr(tc.ParamBase[5]));

        datafile.Add('CNR : ' + IntToStr(tc.CharaNumber));

        datafile.Add('MAP : ' + tc.Map);
        datafile.Add('MPX : ' + IntToStr(tc.Point.X));
        datafile.Add('MPY : ' + IntToStr(tc.Point.Y));

        datafile.Add('MSP : ' + tc.SaveMap);
        datafile.Add('MSX : ' + IntToStr(tc.SavePoint.X));
        datafile.Add('MSY : ' + IntToStr(tc.SavePoint.Y));

        datafile.Add('PLG : ' + IntToStr(tc.Plag));
        datafile.Add('PLV : ' + IntToStr(tc.PLv));

        datafile.Add('GID : ' + IntToStr(tc.GuildID));
        datafile.Add('PID : ' + IntToStr(tc.PartyID));
    end;

    procedure PD_Save_Characters_Memos(tc : TChara; datafile : TStringList);
    var
        i : Integer;
    begin
        for i := 0 to 2 do begin
            datafile.Add('M'+IntToStr(i+1)+'N : ' + tc.MemoMap[i]);
            datafile.Add('M'+IntToStr(i+1)+'X : ' + IntToStr(tc.MemoPoint[i].X));
            datafile.Add('M'+IntToStr(i+1)+'Y : ' + IntToStr(tc.MemoPoint[i].Y));
        end;
    end;

    procedure PD_Save_Characters_Skills(tc : TChara; datafile : TStringList);
    var
        i, j : Integer;
        len : Integer;
        str : String;
    begin
        datafile.Add(' SID : LV : NAME');
        datafile.Add('----------------------------------');

        for i := 1 to MAX_SKILL_NUMBER do begin
            str := ' ';

            len := length(IntToStr(i));
            for j := 0 to (3 - len) - 1 do begin
                str := str + ' ';
            end;
            str := str + IntToStr(i);
            str := str + ' : ';

            len := length(IntToStr(tc.Skill[i].Lv));
            for j := 0 to (2 - len) - 1 do begin
                str := str + ' ';
            end;
            str := str + IntToStr(tc.Skill[i].Lv);

            str := str + ' : ' + tc.Skill[i].Data.IDC;
            datafile.Add(str);
        end;
    end;

    procedure PD_Save_Characters_Inventory(tc : TChara; datafile : TStringList);
    begin
        compile_inventories(datafile, tc.Item);
    end;

end.

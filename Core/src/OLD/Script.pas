unit Script;



interface

uses
    {Windows VCL}
    {$IFDEF MSWINDOWS}
	Windows,  MMSystem,
    {$ENDIF}
    {Common}
    Types, SysUtils, Classes,
    {Fusion}
    Common, Globals;

{==============================================================================}
{   Listed Procedures}
    {Function  ScriptValidated(MapName : string; FileName : string; Tick : Cardinal) : Boolean;}
    procedure NPCScript(tc:TChara; value:cardinal = 0; mode:byte = 0);
{==============================================================================}



implementation
{==============================================================================}
{Script Validation to come}
{==============================================================================}

{place Script validation here}

{==============================================================================}
{End of Script Validation }
{==============================================================================}

{==============================================================================}
{NPC Script Commands}
{==============================================================================}
procedure NPCScript(tc:TChara; value:cardinal = 0; mode:byte = 0);
var
    a               : array [0..2] of integer;
    i,j,k,l,m,cnt   :integer;
    str             :string;
    txt2            :TextFile;
    sl              :TStringList;
    p               :pointer;
    len,Tick        :cardinal;
    flag            :boolean;
    tn,tn1          :TNPC;
    td              :TItemDB;
    ts,ts1          :TMob;
    tm,tm1          :TMap;
    tc1             :TChara;
    tg              :TGuild;
    tgc             :TCastle;
    w               :word;
    tr              :NTimer;
    tcr             :TChatRoom;
    mi              :MapTbl;
    tGlobal         :TGlobalVars;


begin
    flag := false;

    if (tc.AMode <> 3) then exit;
    tn := tc.AData;
    //with tn do begin
    if (mode = 0) then begin
        if (tc.Map <> tn.Map) or
        (abs(tc.Point.X - tn.Point.X) > 15) or
        (abs(tc.Point.Y - tn.Point.Y) > 15) then begin
            tc.AMode := 0;
            Exit;
        end;
    end;

    if Map.IndexOf(tn.Map) = -1 then Exit;
    tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
    Tick := timeGetTime();
    cnt := 0;
    while (tc.ScriptStep < tn.ScriptCnt) and (cnt < 100) do begin
        case tn.Script[tc.ScriptStep].ID of
        0: //(nop)
            begin
                Inc(tc.ScriptStep);
            end;
        1: //mes
            begin
                str := tn.Script[tc.ScriptStep].Data1[0];
                i := AnsiPos('$[', str);
                while i <> 0 do begin
                    j := AnsiPos(']', Copy(str, i + 2, 256));
                    if j <= 1 then break;
                    //Variable Substituting
                    if (Copy(str, i + 2, 1) = '$') then
                        str := Copy(str, 1, i - 1) + tc.Flag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256)
                    else if (Copy(str, i + 2, 2) = '\$') then
                        str := Copy(str, 1, i - 1) + ServerFlag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256)
                    else begin
                        k := ConvFlagValue(tc, Copy(str, i + 2, j - 1), true);
                        if k <> -1 then str := Copy(str, 1, i - 1) + IntToStr(k) + Copy(str, i + j + 2, 256)
                        else str := Copy(str, 1, i - 1) + Copy(str, i + j + 2, 256);
                    end;
                    i := AnsiPos('$[', str);
                end;
                str := StringReplace(str, '$codeversion', CodeVersion, [rfReplaceAll]);
                str := StringReplace(str, '$charaname', tc.Name, [rfReplaceAll]);
                str := StringReplace(str, '$guildname', GetGuildName(tn), [rfReplaceAll]);
                str := StringReplace(str, '$guildmaster', GetGuildMName(tn), [rfReplaceAll]);
                str := StringReplace(str, '$edegree', IntToStr(GetGuildEDegree(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$etrigger', IntToStr(GetGuildETrigger(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$ddegree', IntToStr(GetGuildDDegree(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$dtrigger', IntToStr(GetGuildDTrigger(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$$', '$', [rfReplaceAll]);
                i := Length(str);
                WFIFOW(0, $00b4);
                WFIFOW(2, i + 8);
                WFIFOL(4, tn.ID);
                WFIFOS(8, str, i);
                tc.Socket.SendBuf(buf[0], i + 8);
                Inc(tc.ScriptStep);
            end;
        2: //next
            begin
                WFIFOW(0, $00b5);
                WFIFOL(2, tn.ID);
                tc.Socket.SendBuf(buf[0], 6);
                Inc(tc.ScriptStep);
                break;
            end;
        3: //close
            begin
                WFIFOW(0, $00b6);
                WFIFOL(2, tn.ID);
                tc.Socket.SendBuf(buf[0], 6);
                tc.ScriptStep := $FFFF;
                break;
            end;
        4: //menu
            begin
                if value = 0 then begin
                    for i := 0 to tn.Script[tc.ScriptStep].DataCnt - 1 do begin
                        if i = 0 then str := tn.Script[tc.ScriptStep].Data1[i]
                        else str := str + ':' + tn.Script[tc.ScriptStep].Data1[i];
                    end;
                    i := Length(str);
                    WFIFOW(0, $00b7);
                    WFIFOW(2, i + 8);
                    WFIFOL(4, tn.ID);
                    WFIFOS(8, str, i);
                    tc.Socket.SendBuf(buf[0], i + 8);
                    break;
                end else begin
                    if value = $FF then begin
                    //Disable Equipment Lock
                        if tc.EqLock = true then tc.EqLock := false;
                        tc.ScriptStep := $FFFF;
                        break;
                    end;
                    Dec(value);
                    if tn.Script[tc.ScriptStep].DataCnt <= value then begin
                        tc.ScriptStep := $FFFF;
                        break;
                    end;
                    tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[value];
                    value := 0;
                end;
            end;
        5: //goto
            begin
                tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
            end;
        6: //cutin
            begin
                WFIFOW(0, $0145);
                WFIFOS(2, tn.Script[tc.ScriptStep].Data1[0], 16);
                WFIFOB(18, tn.Script[tc.ScriptStep].Data3[0]);
                tc.Socket.SendBuf(buf[0], 19);
                Inc(tc.ScriptStep);
            end;
        7: //store
            begin
                tc.AMode := 4;
                SendCStoreList(tc);
                Inc(tc.ScriptStep);
            end;
        8: //warp
            begin
                SendCLeave(tc, 2);
                tc.tmpMap := tn.Script[tc.ScriptStep].Data1[0];
                tc.Point := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                MapMove(tc.Socket, tc.tmpMap, tc.Point);
                exit;
            end;
        9: //save
            begin
                i := MapInfo.IndexOf(tm.Name);
                if (i <> -1) then begin
                    mi := MapInfo.Objects[i] as MapTbl;
                    if (mi.noSave = False) then begin
                        tc.SaveMap := tn.Script[tc.ScriptStep].Data1[0];
                        tc.SavePoint := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                    end;
                end;
				Inc(tc.ScriptStep);
			end;
        10: //heal
            begin
                Inc(tc.HP, tn.Script[tc.ScriptStep].Data3[0]);
                if tc.HP > tc.MAXHP then tc.HP := tc.MAXHP;
                Inc(tc.SP, tn.Script[tc.ScriptStep].Data3[1]);
                if tc.SP > tc.MAXSP then tc.SP := tc.MAXSP;
                WFIFOW( 0, $011a);
                WFIFOW( 2, 28);
                WFIFOW( 4, tn.Script[tc.ScriptStep].Data3[0]);
                WFIFOL( 6, tc.ID);
                WFIFOL(10, tn.ID);
                WFIFOB(14, 1);
                SendBCmd(tc.MData, tn.Point, 15);
					{ commented out SP heal packets?
					WFIFOW( 0, $013d);
					WFIFOW( 2, $0007);
					WFIFOW( 4, tn.Script[tc.ScriptStep].Data3[1]);
					tc.Socket.SendBuf(buf, 6);
					}
                SendCStat1(tc, 0, 5, tc.HP);
                SendCStat1(tc, 0, 7, tc.SP);

                Inc(tc.ScriptStep);
            end;
        11: //set
            begin
                str := tn.Script[tc.ScriptStep].Data1[0];
                p := nil;
                len := 0;
                if str = 'zeny'             then begin p := @tc.Zeny;       len := 4; end
                //Job is obsolete with jobchange and (base/job)level
                //won't work without relogin
                //else if str = 'job'         then begin p := @tc.JID;        len := 2; end
                //else if str = 'baselevel'   then begin p := @tc.BaseLV;     len := 2; end
                //else if str = 'joblevel'    then begin p := @tc.JobLV;      len := 2; end
                else if str = 'statuspoint' then begin p := @tc.StatusPoint;len := 2; end
                else if str = 'skillpoint'  then begin p := @tc.SkillPoint; len := 2; end
                else if str = 'option'      then begin p := @tc.Option;     len := 4; end
                else if str = 'speed'       then begin p := @tc.Speed;      len := 2; end
                else if str = 'str'         then begin p := @tc.Parambase[0]; len := 2; end
                else if str = 'agi'         then begin p := @tc.Parambase[1]; len := 2; end
                else if str = 'dex'         then begin p := @tc.Parambase[2]; len := 2; end
                else if str = 'vit'         then begin p := @tc.Parambase[3]; len := 2; end
                else if str = 'int'         then begin p := @tc.Parambase[4]; len := 2; end
                else if str = 'luk'         then begin p := @tc.Parambase[5]; len := 2; end;

				if len <> 0 then begin
                    j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                    i := 0;
                    if tn.Script[tc.ScriptStep].Data3[0] <> 0 then CopyMemory(@i, p, len);
                    case tn.Script[tc.ScriptStep].Data3[0] of
                    0,1:	i := i + j;
                    2:		i := i - j;
                    3:		i := i * j;
                    4:		i := i div j;
                    end;
                    if i < 0 then i := 0;
                    if (tn.Script[tc.ScriptStep].Data3[1] <> 0) and
                        (i > tn.Script[tc.ScriptStep].Data3[1]) then
                            i := tn.Script[tc.ScriptStep].Data3[1];
                    CopyMemory(p, @i, len);
                    SendCStat(tc);
                end else begin
                    //convert variables
                    j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                    if (tn.Script[tc.ScriptStep].Data3[0] = 0) then i := 0
                    else i := ConvFlagValue(tc, str)
                end;
                //Math Operators
                case tn.Script[tc.ScriptStep].Data3[0] of
                0,1:  i := i + j;
                2:    i := i - j;
                3:    i := i * j;
                4:    i := i div j;
                end;
                if i < 0 then i := 0;
                if (tn.Script[tc.ScriptStep].Data3[1] <> 0) and
                    (i > tn.Script[tc.ScriptStep].Data3[1]) then
                        i := tn.Script[tc.ScriptStep].Data3[1];
                //Variable check
                if (Copy(str, 1, 1) <> '\') then tc.Flag.Values[str] := IntToStr(i)
                else ServerFlag.Values[str] := IntToStr(i);

                if (str = 'str') or (str = 'agi') or (str = 'dex') or (str = 'vit') or
                (str = 'int') or (str = 'luk') then begin
                    CalcStat(tc);
                    SendCStat(tc);
                end else if (str = 'option') then UpdateOption(tm, tc);


                Inc(tc.ScriptStep);
            end;
        12: //additem
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                td := ItemDB.IndexOfObject(i) as TItemDB;
                if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
                    k := SearchCInventory(tc, i, td.IEquip);
                    if k <> 0 then begin
                        if tc.Item[k].Amount + j > 30000 then j := 30000 - tc.Item[k].Amount;
                        if td.IEquip then j := 1;
                        tc.Item[k].ID := i;
                        tc.Item[k].Amount := tc.Item[k].Amount + j;
                        tc.Item[k].Equip := 0;
                        tc.Item[k].Identify := 1;
                        tc.Item[k].Refine := 0;
                        tc.Item[k].Attr := 0;
                        tc.Item[k].Card[0] := 0;
                        tc.Item[k].Card[1] := 0;
                        tc.Item[k].Card[2] := 0;
                        tc.Item[k].Card[3] := 0;
                        tc.Item[k].Data := td;
                        // Update weight
                        tc.Weight := tc.Weight + cardinal(td.Weight) * cardinal(j);
                        SendCStat1(tc, 0, $0018, tc.Weight);
                        SendCGetItem(tc, k, j);
                    end;
                end else begin
                    WFIFOW( 0, $00a0);
                    WFIFOB(22, 2);
                    tc.Socket.SendBuf(buf, 23);
                end;
                Inc(tc.ScriptStep);
            end;
        13: //delitem
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                k := SearchCInventory(tc, i, false);
                if k <> 0 then begin
                    if j > tc.Item[k].Amount then j := tc.Item[k].Amount;
                    if tc.Item[k].Equip <> 0 then begin
                        reset_skill_effects(tc);
                        WFIFOW(0, $00ac);
                        WFIFOW(2, k);
                        WFIFOW(4, tc.Item[k].Equip);
                        tc.Item[k].Equip := 0;
                        WFIFOB(6, 1);
                        tc.Socket.SendBuf(buf, 7);
                        remove_equipcard_skills(tc, k);
                        CalcStat(tc);
                        SendCStat(tc);
                    end;
					Dec(tc.Item[k].Amount, j);
					if tc.Item[k].Amount = 0 then tc.Item[k].ID := 0;
					WFIFOW( 0, $00af);
					WFIFOW( 2, k);
					WFIFOW( 4, j);
					tc.Socket.SendBuf(buf, 6);
					// Update weight
					tc.Weight := tc.Weight - tc.Item[k].Data.Weight * cardinal(j);
                    SendCStat1(tc, 0, $0018, tc.Weight);
                end;
                Inc(tc.ScriptStep);
            end;
        14: //checkitem
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                k := SearchCInventory(tc, i, false);
                if (k <> 0) and (tc.Item[k].Amount >= j) then //begin
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-checkitem: %d %d = 1', [i, j]));
                    tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0]
                else
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-checkitem: %d %d = 0', [i, j]));
                    tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
            end;
        15: //check
            begin
                str := tn.Script[tc.ScriptStep].Data1[0];
                if str = 'zeny' then i := tc.Zeny
                else if str = 'job' then begin
                    i := tc.JID;
                    if (i > UPPER_JOB_BEGIN) then i := i - UPPER_JOB_BEGIN + LOWER_JOB_END;
                end
                else if str = 'baselevel' then i := tc.BaseLV
                else if str = 'joblevel' then i := tc.JobLV
                else if str = 'statuspoint' then i := tc.StatusPoint
                else if str = 'skillpoint' then i := tc.SkillPoint
                else if str = 'option' then i := tc.Option
                else if str = 'speed' then i := tc.Speed
                else if str = 'gender' then i := tc.Gender
                else if str = 'hcolor' then i := tc.HairColor
                else if str = 'guildid' then i := GetGuildID(tn)
                else if str = 'guildkafra' then i := GetGuildKafra(tn)
                else if str = 'ismyguild' then i := CheckGuildID(tn, tc)
                else if str = 'ismymaster' then i := CheckGuildMaster(tn, tc)
                else if str = 'etrigger' then i := GetGuildETrigger(tn)
                else if str = 'dtrigger' then i := GetGuildDTrigger(tn)
                else if str = 'accesslevel' then i := tc.PData.AccessLevel

                else i := ConvFlagValue(tc, str);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);

                case tn.Script[tc.ScriptStep].Data3[2] of
                0: flag := boolean(i >= j);
                1: flag := boolean(i <= j);
                2: flag := boolean(i  = j);
                3: flag := boolean(i <> j);
                4: flag := boolean(i >  j);
                5: flag := boolean(i <  j);
                    else begin
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: invalid formula "%s"', [tn.Script[tc.ScriptStep].Data1[2]]));
                        tc.ScriptStep := $FFFF;
                        break;
                    end;
                end;
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: %s %s(%d) %s = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data3[2], tn.Script[tc.ScriptStep].Data1[1], byte(flag)]));
                if flag then tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0]
                else tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];

            end;
        16: //checkadditem
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                td := ItemDB.IndexOfObject(i) as TItemDB;
                if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
                    k := SearchCInventory(tc, i, td.IEquip);
                    if k <> 0 then tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0]
                    else tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
                end else tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
            end;
        17: //jobchange
            begin
                //Unequipping items for jobchange
                for i := 1 to 100 do begin
                    if tc.Item[i].Equip = 32768 then begin
                        tc.Item[i].Equip := 0;
                        WFIFOW(0, $013c);
                        WFIFOW(2, 0);
                        tc.Socket.SendBuf(buf, 4);
                    end else if tc.Item[i].Equip <> 0 then begin
                        reset_skill_effects(tc);
                        WFIFOW(0, $00ac);
                        WFIFOW(2, i);
                        WFIFOW(4, tc.Item[i].Equip);
                        tc.Item[i].Equip := 0;
                        WFIFOB(6, 1);
                        tc.Socket.SendBuf(buf, 7);
                        remove_equipcard_skills(tc, i);
                    end;
                end;
                //Taking off options
                if (tc.Option <> 0) then begin
                    tc.Option := 0;
                    {UpdateOption(tm, tc);}
                    WFIFOW(0, $0119);
                    WFIFOL(2, tc.ID);
                    WFIFOW(6, 0);
                    WFIFOW(8, 0);
                    WFIFOW(10, tc.Option);
                    WFIFOB(12, 0);
                    SendBCmd(tc.MData, tc.Point, 13);
                end;

                // Colus, 20040304: Adding job offset for upper classes
                j := tn.Script[tc.ScriptStep].Data3[0];
                if (j > LOWER_JOB_END) then begin
                    j := j - LOWER_JOB_END + UPPER_JOB_BEGIN; // 24 - 23 + 4000 = 4001, remort novice
                    tc.ClothesColor := 1; // Use 'default' upper job clothes color
                end else tc.ClothesColor := 0; // Default color for regular jobs

                if (j > LOWER_JOB_END) then begin
                    j := j - LOWER_JOB_END + UPPER_JOB_BEGIN; // 24 - 23 + 4000 = 4001, remort novice
                    if (DisableAdv2ndDye) and (j > 4007) then
                        tc.ClothesColor := 0
                    else tc.ClothesColor := 1; // This is the default clothes palette color for upper classes
                end else tc.ClothesColor := 0;


                tc.JID := j;
                tc.JobEXP := 0;
                tc.JobLV := 1;
                SendCStat1(tc, 0, $0037, tc.JobLV);
                CalcStat(tc);
                tc.SkillPoint := 0;
                CalcStat(tc);
                SendCStat(tc, true);
                SendCSkillList(tc);
                // Colus, 20040304: New view packet for jobchange
                UpdateLook(tc.MData, tc, 0, tc.JID);
                UpdateLook(tm, tc, 7, tc.ClothesColor, 0, true);
                Inc(tc.ScriptStep);
            end;
        18: //viewpoint
            begin
                WFIFOW( 0, $0144);
                WFIFOL( 2, tn.ID);
                WFIFOL( 6, tn.Script[tc.ScriptStep].Data3[0]);
                WFIFOL(10, tn.Script[tc.ScriptStep].Data3[1]);
                WFIFOL(14, tn.Script[tc.ScriptStep].Data3[2]);
                WFIFOB(18, tn.Script[tc.ScriptStep].Data3[3]);
                WFIFOL(19, tn.Script[tc.ScriptStep].Data3[4]);
                tc.Socket.SendBuf(buf, 23);
                Inc(tc.ScriptStep);
            end;
        19: //input
            begin
                if value = 0 then begin
                    WFIFOW( 0, $0142);
                    WFIFOL( 2, tn.ID);
                    tc.Socket.SendBuf(buf, 6);
                    break;
                end else begin
                    if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then
                        tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value - 1)
                    else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value - 1);
                end;
                Inc(tc.ScriptStep);
            end;
        20: //random
            begin
                if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then
                    tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(Random(tn.Script[tc.ScriptStep].Data3[0]))
                else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(Random(tn.Script[tc.ScriptStep].Data3[0]));

				Inc(tc.ScriptStep);
			end;
        21: //option
            begin
                if tn.Script[tc.ScriptStep].Data3[1] = 1 then begin
                    case tn.Script[tc.ScriptStep].Data3[0] of
                    0:
                        begin
                            if (tc.Option <> 8) then begin
                                tc.Option := (tc.Option and $F877) or $0008;
                                SendCart(tc);
                            end;
                        end;
                    1: tc.Option := tc.Option or $0010; //����
                    2: tc.Option := tc.Option or $0020; //�؂�
                    3: tc.Option := (tc.Option and $F877) or $0008; //�J�[�g1
                    4: tc.Option := (tc.Option and $F877) or $0080; //�J�[�g2
                    5: tc.Option := (tc.Option and $F877) or $0100; //�J�[�g3
                    6: tc.Option := (tc.Option and $F877) or $0200; //�J�[�g4
                    7: tc.Option := (tc.Option and $F877) or $0400; //�J�[�g5
                    end;
                end else begin
                    case tn.Script[tc.ScriptStep].Data3[0] of
                    0: tc.Option := tc.Option and $F877; //�J�[�g�S����  F847=�S����
                    1: tc.Option := tc.Option and $FFEF; //����
                    2: tc.Option := tc.Option and $FFDF; //�؂�
                    end;
                end;
                //UpdateOption(tm, tc);?
				CalcStat(tc);
				WFIFOW(0, $0119);
				WFIFOL(2, tc.ID);
				WFIFOW(6, 0);
				WFIFOW(8, 0);
				WFIFOW(10, tc.Option);
				WFIFOB(12, 0);
				SendBCmd(tc.MData, tc.Point, 13);
				Inc(tc.ScriptStep);
            end;
        22: //speed
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
                //speed limit set
                if (i >= 25) and (i <= 1000) then begin
                    tc.Speed := i;
                    tc.DefaultSpeed := i;
                    CalcStat(tc);
                    SendCStat1(tc, 0, 0, tc.Speed);
                end;
                Inc(tc.ScriptStep);
            end;
        23: //die
            begin
                CalcStat(tc);
                tc.HP := 0;
                tc.Sit := 1;
                SendCStat1(tc, 0, 5, tc.HP);
                WFIFOW(0, $0080);
                WFIFOL(2, tc.ID);
                WFIFOB(6, 1);
                tc.Socket.SendBuf(buf, 7);
                Inc(tc.ScriptStep);
            end;
        24: //ccolor
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
                if (i >= 0) then begin
                    CalcStat(tc);
                    tc.ClothesColor := i;
                    UpdateLook(tc.MData, tc, 7, i, 0, true);
                end;
                Inc(tc.ScriptStep);
            end;
        25: //refine		refine[itemID][fail][+val]
            begin
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
                if (j >= 0) and (j <= 10) then begin
                    for i := 1 to 100 do begin
                        if (tc.Item[i].ID <> 0) and
                        (tc.Item[i].Amount <> 0) and
                        tc.Item[i].Data.IEquip and
                        (tc.Item[i].Equip <> 0) and
                        (tc.Item[i].Card[0] <> $00ff) then begin
                            tc.Item[i].Refine := byte(l);
                            WFIFOW(0, $0188);
                            WFIFOW(2, k);
                            WFIFOW(4, i);
                            WFIFOW(6, word(l));
                            tc.Socket.SendBuf(buf, 8);
                        end;
                    end;
                    CalcStat(tc);
                    WFIFOW(0, $019b);
                    WFIFOL(2, tc.ID);
                    WFIFOL(6, 3);
                    SendBCmd(tc.MData, tc.Point, 10, tc);
                    SendCStat(tc);
                end;
                Inc(tc.ScriptStep);
            end;
        26: //getitemamount
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
				k := SearchCInventory(tc, i, false);
                if k <> 0 then
                    tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Item[k].Amount)
                else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := '0';
                Inc(tc.ScriptStep);
            end;
        27: //getskilllevel //S144 addstart
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
                    if i = 0 then tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
                    else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Skill[i].Lv);
                end else begin
                    if i = 0 then ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
                    else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Skill[i].Lv);
                end;
                Inc(tc.ScriptStep);
            end;
        28: //setskilllevel
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                    if i <> 0 then begin
                        l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
						if ((0 <= l) and (l <= 10)) then tc.Skill[i].Lv := l;
						SendCSKillList(tc);
					end;
                Inc(tc.ScriptStep);
                end; //S144 addend

        29: //refinery
            begin
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                case j of
                1:  l := $100; //Head
                2:  l := $10;  //Body
                3:  l := $20;  //Left Hand
                4:  l := $2;   //Right Hand
                5:  l := $4;   //Robe
                6:  l := $40;  //Foot
                7:  l := $8;   //Acc1
                8:  l := $80;  //Acc2
                9:  l := $200; //Head2
                10: l := $1;   //Head
                else l := 0;
                end;
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
                if (j < 0) or (j > 10) then j := 0;
                if l <> 0 then begin
                    for i := 1 to 100 do begin
                        if (tc.Item[i].ID <> 0) and
                        (tc.Item[i].Amount <> 0) and
                        tc.Item[i].Data.IEquip and
                        ((tc.Item[i].Equip and l) = l) and
                        (tc.Item[i].Refine < 10) then begin
                            reset_skill_effects(tc);
                            WFIFOW(0, $00ac);
                            WFIFOW(2, i);
                            WFIFOW(4, tc.Item[i].Equip);
                            WFIFOB(6, 1);
                            tc.Socket.SendBuf(buf, 7);
                            remove_equipcard_skills(tc, i);
                            //Refine sucess
                            if k = 0 then begin
                                tc.Item[i].Refine := j;
                                WFIFOW(0, $0188);
                                WFIFOW(2, 0);
                                WFIFOW(4, i);
                                WFIFOW(6, tc.Item[i].Refine);
                                tc.Socket.SendBuf(buf, 8);
                                WFIFOW(0, $00aa);
                                WFIFOW(2, i);
                                WFIFOW(4, tc.Item[i].Equip);
                                WFIFOB(6, 1);
                                tc.Socket.SendBuf(buf, 7);
                            //Refine failure
                            end else begin
                                tc.Item[i].Refine := 0;
                                tc.Item[i].Equip := 0;
                                WFIFOW(0, $0188);
                                WFIFOW(2, 1);
                                WFIFOW(4, i);
                                WFIFOW(6, word(tc.Item[i].Refine));
                                tc.Socket.SendBuf(buf, 8);
                                //loose the weapon
                                if k = 1 then begin
                                    Dec(tc.Item[i].Amount, 1);
                                    if tc.Item[i].Amount = 0 then tc.Item[i].ID := 0;
                                    WFIFOW( 0, $00af);
                                    WFIFOW( 2, i);
                                    WFIFOW( 4, 1);
                                    tc.Socket.SendBuf(buf, 6);
                                    tc.Weight := tc.Weight - tc.Item[i].Data.Weight * cardinal(1);
                                    SendCStat1(tc, 0, $0018, tc.Weight);
                                end;
                            end;
                        end;
                    end;
                    CalcStat(tc);
                    WFIFOW(0, $019b);
                    WFIFOL(2, tc.CID);
                    if k = 0 then WFIFOL(6, 3) else WFIFOL(6, 2);
                    SendBCmd(tc.MData, tc.Point, 10, tc);
                    SendCStat(tc);
                end;
                Inc(tc.ScriptStep);
            end;
        30: //equipmenu  --->Thanks goes to Melz -- for fixing the translation!! <---
            begin
                if value = 0 then begin
                    tn.Script[tc.ScriptStep].Data2[0] := '[Head - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[1] := '[Body - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[2] := '[Left Hand - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[3] := '[Right Hand - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[4] := '[Robe - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[5] := '[Foot - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[6] := '[Accessory1 - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[7] := '[Accessory2 - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[8] := '[Head2 - Not Equipped]';
                    tn.Script[tc.ScriptStep].Data2[9] := '[Head3 - Not Equipped]';
                    for i := 1 to 100 do begin
                        if (tc.Item[i].ID <> 0) and
                        (tc.Item[i].Amount <> 0) and
                        (tc.Item[i].Equip <> 0) then begin
                            if tc.Item[i].Refine > 0 then str := '(+' + IntToStr(tc.Item[i].Refine) + ')'
                            else str := '';
                            str := tc.Item[i].Data.JName + str;
                            case tc.Item[i].Equip of
                            $1: tn.Script[tc.ScriptStep].Data2[9] := str; //�����i
                            $2: tn.Script[tc.ScriptStep].Data2[3] := str; //�E��
                            $4: tn.Script[tc.ScriptStep].Data2[4] := str; //��
                            $8: tn.Script[tc.ScriptStep].Data2[6] := str; //�A�N�Z1
                            $10: tn.Script[tc.ScriptStep].Data2[1] := str; //�Z
                            $20: tn.Script[tc.ScriptStep].Data2[2] := str; //����
                            $22: //���蕐��
                                begin
                                    tn.Script[tc.ScriptStep].Data2[2] := str;
                                    tn.Script[tc.ScriptStep].Data2[3] := str;
                                end;
                            $40: tn.Script[tc.ScriptStep].Data2[5] := str; //�C
                            $80: tn.Script[tc.ScriptStep].Data2[7] := str; //�A�N�Z2
                            $100: tn.Script[tc.ScriptStep].Data2[0] := str; //����i
                            $200: tn.Script[tc.ScriptStep].Data2[8] := str; //�����i
                            $201: //�������i
                                begin
                                    tn.Script[tc.ScriptStep].Data2[8] := str;
                                    tn.Script[tc.ScriptStep].Data2[9] := str;
                                end;
                            $300: //���㒆�i
                                begin
                                    tn.Script[tc.ScriptStep].Data2[0] := str;
                                    tn.Script[tc.ScriptStep].Data2[8] := str;
                                end;
                            $301: //���㒆���i
                                begin
                                    tn.Script[tc.ScriptStep].Data2[0] := str;
                                    tn.Script[tc.ScriptStep].Data2[8] := str;
                                    tn.Script[tc.ScriptStep].Data2[9] := str;
                                end;
                            end;
                        end;
                    end;
                    for i := 0 to 9 do begin
                        if i = 0 then str := tn.Script[tc.ScriptStep].Data2[i]
                        else str := str + ':' + tn.Script[tc.ScriptStep].Data2[i];
                    end;
                    i := Length(str);
                    WFIFOW(0, $00b7);
                    WFIFOW(2, i + 8);
                    WFIFOL(4, tn.ID);
                    WFIFOS(8, str, i);
                    tc.Socket.SendBuf(buf[0], i + 8);
                    break;
                end else begin
                    if value = $FF then begin
                        //Disable EquipLock
                        if tc.EqLock = true then tc.EqLock := false;
                        tc.ScriptStep := $FFFF;
                        break;
                    end;
                    if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then
                        tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value)
                    else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value);
                    case value of
                    1:  l := $100; //����i
                    2:  l := $10;  //�Z
                    3:  l := $20;  //����
                    4:  l := $2;   //�E��
                    5:  l := $4;   //��
                    6:  l := $40;  //�C
                    7:  l := $8;   //�A�N�Z1
                    8:  l := $80;  //�A�N�Z2
                    9:  l := $200; //����i
                    10: l := $1;   //�����i
                    else l := 0;
                    end;
                    if l <> 0 then begin
                        k := 0;
                        j := 99;
                        for i := 1 to 100 do begin
                            if (tc.Item[i].ID <> 0) and
                            (tc.Item[i].Amount <> 0) and
                            tc.Item[i].Data.IEquip and
                            ((tc.Item[i].Equip and l) = l) then begin
                                if tc.Item[i].Data.IType = 4 then j := tc.Item[i].Data.wLV
                                else j := 0;
                                k := i;
                                break;
                            end;
                        end;
                        if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) <> '\') then
                            tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(j)
                        else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(j);
                        if (Copy(tn.Script[tc.ScriptStep].Data1[2], 1, 1) <> '\') then begin
                            if k <> 0 then tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[2]] := IntToStr(tc.Item[i].Refine)
                            else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[2]] := '0';
                        end else begin
                            if k <> 0 then ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[2]] := IntToStr(tc.Item[i].Refine)
                            else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[2]] := '0';
                        end;
                    end;
                    value := 0;
                end;
                Inc(tc.ScriptStep);
            end;
        31: //lockitem
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
                if i = 0 then tc.EqLock := false
                else if i = 1 then tc.EqLock := true;
                Inc(tc.ScriptStep);
            end;
        32: //hcolor
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
                if (i >= 0) then begin
                    tc.HairColor := i;
                    UpdateLook(tc.MData, tc, 6, i, 0, true);
                end;
                Inc(tc.ScriptStep);
            end;
        33: //callmob
            begin
                ts := TMob.Create;
                with ts do begin
                    Map := tn.Script[tc.ScriptStep].Data1[0];
                    Point.X := tn.Script[tc.ScriptStep].Data3[0];
                    Point.Y := tn.Script[tc.ScriptStep].Data3[1];
                    if (Point.X = 0) and (Point.Y = 0) then begin
                        j := 0;
                        repeat
                            Point.X := Random(tm.Size.X - 2) + 1;
                            Point.Y := Random(tm.Size.Y - 2) + 1;
                            Inc(j);
                        until (tm.gat[Point.X, Point.Y] and 1 <> 0) or (j = 100);
                    end;
                    if (j = 100) then continue;
                    Name := tn.Script[tc.ScriptStep].Data1[1];
                    JID := tn.Script[tc.ScriptStep].Data3[2];
                    Data := MobDB.IndexOfObject(ts.JID) as TMobDB;
                    ID := NowMobID;
                    Inc(NowMobID);
                    if (tn.Script[tc.ScriptStep].Data2[0] = '') then Event := 0
                    else Event := StrToInt(tn.Script[tc.ScriptStep].Data2[0]);
                    Dir := Random(8);
                    HP := Data.HP;
                    Speed := Data.Speed;
                    SpawnDelay1 := $7FFFFFFF;
                    SpawnDelay2 := 0;
                    SpawnType := 0;
                    SpawnTick := 0;
                    isLooting := False;
                    for j:= 1 to 10 do begin
                        Item[j].ID := 0;
                        Item[j].Amount := 0;
                        Item[j].Equip := 0;
                        Item[j].Identify := 0;
                        Item[j].Refine := 0;
                        Item[j].Attr := 0;
                        Item[j].Card[0] := 0;
                        Item[j].Card[1] := 0;
                        Item[j].Card[2] := 0;
                        Item[j].Card[3] := 0;
                    end;
                    if (tn.Script[tc.ScriptStep].Data3[3] = 0) then begin
                        if Data.isDontMove then MoveWait := 4294967295
                        else MoveWait := Tick + 5000 + Cardinal(Random(10000));
                        isActive := ts.Data.isActive;
                    end else begin
                        MoveWait := timeGetTime();
                        isActive := true;
                    end;
                    ATarget := 0;
                    ATKPer := 100;
                    DEFPer := 100;
                    DmgTick := 0;
                    Element := Data.Element;
                    for j := 0 to 31 do begin
                        EXPDist[j].CData := nil;
                        EXPDist[j].Dmg := 0;
                    end;
                    if Data.MEXP <> 0 then begin
                        for j := 0 to 31 do begin
                            MVPDist[j].CData := nil;
                            MVPDist[j].Dmg := 0;
                        end;
                        MVPDist[0].Dmg := Data.HP * 30 div 100; //FA��30%���Z
                    end;
                    isSummon := True;
                    tm.Mob.AddObject(ID, ts);
                    tm.Block[Point.X div 8][Point.Y div 8].Mob.AddObject(ID, ts);
                    ZeroMemory(@buf[0], 41);
                    WFIFOW( 0, $007c);
                    WFIFOL( 2, ID);
                    WFIFOW( 6, Speed);
                    WFIFOW( 8, Stat1);
                    WFIFOW(10, Stat2);
                    WFIFOW(20, JID);
                    WFIFOM1(36, Point, Dir);
                    SendBCmd(tm,Point,41,nil,true);
                    Inc(tc.ScriptStep);
                end;
            end;
        34: //broadcast
            begin
                l := tn.Script[tc.ScriptStep].Data3[0];
                str := tn.Script[tc.ScriptStep].Data1[0] + chr(0);
                i := AnsiPos('$[', str);
                while i <> 0 do begin
                    j := AnsiPos(']', Copy(str, i + 2, 256));
                    if j <= 1 then break;
                    //grabbing variables
                    if (Copy(str, i + 2, 1) = '$') then
                        str := Copy(str, 1, i - 1) + tc.Flag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256)
                    else if (Copy(str, i + 2, 2) = '\$') then
                        str := Copy(str, 1, i - 1) + ServerFlag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256)
                    else begin
                        k := ConvFlagValue(tc, Copy(str, i + 2, j - 1), true);
                        if k <> -1 then str := Copy(str, 1, i - 1) + IntToStr(k) + Copy(str, i + j + 2, 256)
                        else str := Copy(str, 1, i - 1) + Copy(str, i + j + 2, 256);
                    end;
                    i := AnsiPos('$[', str);
                end;
                //predetermined variable string replacement
                str := StringReplace(str, '$codeversion', CodeVersion, [rfReplaceAll]);
                str := StringReplace(str, '$charaname', tc.Name, [rfReplaceAll]);
                str := StringReplace(str, '$guildname', GetGuildName(tn), [rfReplaceAll]);
                str := StringReplace(str, '$guildmaster', GetGuildMName(tn), [rfReplaceAll]);
                str := StringReplace(str, '$edegree', IntToStr(GetGuildEDegree(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$etrigger', IntToStr(GetGuildETrigger(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$ddegree', IntToStr(GetGuildDDegree(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$dtrigger', IntToStr(GetGuildDTrigger(tn)), [rfReplaceAll]);
                str := StringReplace(str, '$$', '$', [rfReplaceAll]);
                str := StringReplace(str, '\\', '\', [rfReplaceAll]);
                //optional tags (first set is for map only, second set for global)
                if ((l = 0) or (l = 200)) then str := tn.Name + ' : ' + str; // Null (0): displays npc name with it
                if ((l = 100) or (l = 300)) then str := 'blue' + str;        //  Blue String Broadcast
                if ((l = 20) or (l = 220)) then str := tc.Name + ' : ' + str; // displays characters name with it
                if ((l = 30) or (l = 230)) then str := 'blue' + tc.Name + ' : ' +str; //displays character name and in blue
                if ((l = 40) or (l = 240)) then str := 'blue' + tn.Name + ' : ' +str; //displays npc name and in blue
                w := Length(str) + 4;
                WFIFOW(0, $009a);
                WFIFOW(2, w);
                WFIFOS(4, str, w - 4);
                if ((l < 101) or (l > 300)) then begin
                    //MAP broadcasting
                    tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
                    for i := 0 to tm.CList.Count - 1 do begin
                        tc1 := tm.CList.Objects[i] as TChara;
                        if tc1.Login = 2 then tc1.Socket.SendBuf(buf, w);
                    end;
                end else begin
                    //Global Broadcasting
                    for i := 0 to CharaName.Count - 1 do begin
                        tc1 := CharaName.Objects[i] as TChara;
                        if tc1.Login = 2 then tc1.Socket.SendBuf(buf, w);
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        35: //npctimer
            begin
                i := tn.Script[tc.ScriptStep].Data3[0];
                j := tm.TimerAct.IndexOf(tn.ID);
                if (i = 0) then begin
                    //OFF
                    if (j <> -1) then begin
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was deleted / Remaining Timer(%d)', [tn.ID,tm.TimerAct.Count-1]));
                        tm.TimerAct.Delete(tm.TimerAct.IndexOf(tn.ID));
                    end;
                end else if (i = 1) then begin
                    //ON
                    if (j = -1) then begin
                        j := tm.TimerDef.IndexOf(tn.ID);
                        if (j <> -1) then begin
                            tr := tm.TimerDef.Objects[j] as NTimer;
                            tr.Tick := timeGetTime();
                            for k := 0 to tr.Cnt - 1 do begin
                                tr.Done[k] := 0;
                            end;
                            tm.TimerAct.AddObject(tn.ID, tr);
                            //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was started / Starting Timer(%d)', [tn.ID,tm.TimerAct.Count]));
                        end;
                    end else begin
                        //Restart
                        tr := tm.TimerAct.Objects[j] as NTimer;
                        tr.Tick := timeGetTime();
                        for k := 0 to tr.Cnt - 1 do tr.Done[k] := 0;
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was re-started / Starting Timer(%d)', [tn.ID,tm.TimerAct.Count]));
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        36: //addnpctimer
            begin
                i := -1;
                for k := 0 to tm.NPC.Count - 1 do begin
                    tn1 := tm.NPC.Objects[k] as TNPC;
                    if (tn1.Name = tn.Script[tc.ScriptStep].Data1[0]) then begin
                        i := 0;
                        break;
                    end;
                end;
                if (i <> -1) then begin
                    i := tn.Script[tc.ScriptStep].Data3[0];
                    j := tm.TimerAct.IndexOf(tn1.ID);
                    if (j <> -1) then begin
                        tr := tm.TimerAct.Objects[j] as NTimer;
                        if (i > 0) then tr.Tick := tr.Tick - cardinal(i)
                        else tr.Tick := tr.Tick + cardinal(abs(i));
                        if (tr.Tick > Tick) then tr.Tick := Tick;
                        for k := 0 to tr.Cnt - 1 do begin
                            if (i < 0) and (tr.Tick + cardinal(tr.Idx[k]) > Tick) then begin
                                //�ߋ��̃C�x���g�𖢎��s�ɂ���
                                tr.Done[k] := 0;
                            end else if (i > 0) and (tr.Tick + cardinal(tr.Idx[k]) < Tick) then begin
                                //�����̃C�x���g�����s�ςɂ���
                                tr.Done[k] := 1;
                            end;
                        end;
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was added (%d)ms', [tn.ID,i]));
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        37: //return
            begin
                tc.ScriptStep := $FFFF;
                break;
            end;
        38: //warpallpc
            begin
                if (tn.Script[tc.ScriptStep].Data3[2] = 0) then begin
                    //Warp Characters on same map as NPC
                    tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
                    while (tm.CList.Count > 0) do begin
                        tc1 := tm.CList.Objects[0] as TChara;
                        if tc1.Login = 2 then begin
                            SendCLeave(tc1, 2);
                            tc1.tmpMap := tn.Script[tc.ScriptStep].Data1[0];
                            tc1.Point := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                            MapMove(tc1.Socket, tc1.tmpMap, tc1.Point);
                        end;
                    end;
                end else if (tn.Script[tc.ScriptStep].Data3[2] = 1) then begin
                    //Warp all characters on the server
                    for j := 0 to CharaName.Count - 1 do begin
                        tc1 := CharaName.Objects[j] as TChara;
                        if tc1.Login = 2 then begin
                            SendCLeave(tc1, 2);
                            tc1.tmpMap := tn.Script[tc.ScriptStep].Data1[0];
                            tc1.Point := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                            MapMove(tc1.Socket, tc1.tmpMap, tc1.Point);
                        end;
                    end;
                end else begin
                    //Warp all in NPC chatroom
                    if (tn.ChatRoomID <> 0) then begin
                        i := ChatRoomList.IndexOf(tn.ChatRoomID);
                        tcr := ChatRoomList.Objects[i] as TChatRoom;
                        if (tcr.Users < 2) then continue;
                        while (tcr.Users > 1) do begin
                            tc1 := CharaPID.IndexOfObject(tcr.MemberID[1]) as TChara;
                            if tc1.Login = 2 then begin
                                SendCLeave(tc1, 2);
                                tc1.tmpMap := tn.Script[tc.ScriptStep].Data1[0];
                                tc1.Point := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                                MapMove(tc1.Socket, tc1.tmpMap, tc1.Point);
                            end;
                        end;
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        39: //waitingroom
            begin
                if (tn.ChatRoomID = 0) then begin
                    tcr := TChatRoom.Create;
                    tcr.Title := tn.Script[tc.ScriptStep].Data1[0];
                    tcr.Limit := tn.Script[tc.ScriptStep].Data3[0];
                    tcr.Pub := 1;
                    tcr.MemberID[0] := tn.ID; //�I�[�i�[:0
                    tcr.MemberCID[0] := tn.JID;
                    tcr.MemberName[0] := tn.Name;
                    ChatMaxID := ChatMaxID + 1;
                    tcr.ID := ChatMaxID;
                    tcr.Users := 1;
                    tcr.NPCowner := 1;
                    tn.ChatRoomID := tcr.ID;
                    ChatRoomList.AddObject(tcr.ID, tcr);
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('ChatRoomTitle = %s : OwnerID = %d : OwnerName = %s', [tcr.Title, tcr.MemberID[0], tcr.MemberName[0]]));
                    //���ӂɃp�P���M
                    w := Length(tcr.Title);
                    WFIFOW(0, $00d7);
                    WFIFOW(2, w + 17);
                    WFIFOL(4, tcr.MemberID[0]);
                    WFIFOL(8, tcr.ID);
                    WFIFOW(12, tcr.Limit);
                    WFIFOW(14, tcr.Users);
                    WFIFOB(16, tcr.Pub);
                    WFIFOS(17, tcr.Title, w);
                    SendBCmd(tm, tn.Point, w + 17, nil);
                end;
                break;
            end;
        40: //enablenpc
            begin
                if Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0]) = -1 then
                    MapLoad(tn.Script[tc.ScriptStep].Data1[0]);
                tm1 := Map.Objects[Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0])] as TMap;
                if (tn.Script[tc.ScriptStep].Data3[0] = 1) then begin
                    //enable
                    i := -1;
                    for k := 0 to tm1.NPC.Count - 1 do begin
                        tn1 := tm1.NPC.Objects[k] as TNPC;
                        if (tn1.Name = tn.Script[tc.ScriptStep].Data1[1]) then begin
                            i := 0;
                            break;
                        end;
                    end;
                    if (tn1.ScriptInitS <> -1) then begin
                        //OnInit���x�������s
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('OnInit Event(%d)', [tn1.ID]));
                        tc1 := TChara.Create;
                        tc1.TalkNPCID := tn1.ID;
                        tc1.ScriptStep := tn1.ScriptInitS;
                        tc1.AMode := 3;
                        tc1.AData := tn1;
                        tc1.Login := 0;
                        NPCScript(tc1,0,1);
                        tn.ScriptInitD := true;
                        tc1.Free;
                    end;
                    if (i = 0) and (tn1.Enable = false) then begin
                        tn1.Enable := true;
                        for j := tn1.Point.Y div 8 - 2 to tn1.Point.Y div 8 + 2 do begin
                            for i := tn1.Point.X div 8 - 2 to tn1.Point.X div 8 + 2 do begin
                                for k := 0 to tm1.Block[i][j].CList.Count - 1 do begin
                                    tc1 := tm1.Block[i][j].Clist.Objects[k] as TChara;
                                    if (abs(tc1.Point.X - tn1.Point.X) < 16) and
                                    (abs(tc1.Point.Y - tn1.Point.Y) < 16) then
                                        SendNData(tc1.Socket, tn1, tc1.ver2, tc1);
                                end;
                            end;
                        end;
                    end;
                end else begin
                    //disable
                    i := -1;
                    for k := 0 to tm1.NPC.Count - 1 do begin
                        tn1 := tm1.NPC.Objects[k] as TNPC;
                        if (tn1.Name = tn.Script[tc.ScriptStep].Data1[1]) then begin
                            i := 0;
                            break;
                        end;
                    end;
                    if (i = 0) and (tn1.Enable = true) then begin
                        tn1.Enable := false;
                        l := tm.TimerAct.IndexOf(tn1.ID);
                        if (l <> -1) then begin
                            //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was deleted / Remaining Timer(%d)', [tn.ID,tm.TimerAct.Count-1]));
                            tm.TimerAct.Delete(tm.TimerAct.IndexOf(tn1.ID));
                        end;
                        for j := tn1.Point.Y div 8 - 2 to tn1.Point.Y div 8 + 2 do begin
                            for i := tn1.Point.X div 8 - 2 to tn1.Point.X div 8 + 2 do begin
                                for k := 0 to tm1.Block[i][j].CList.Count - 1 do begin
                                    tc1 := tm1.Block[i][j].Clist.Objects[k] as TChara;
                                    if (abs(tc1.Point.X - tn1.Point.X) < 16) and
                                    (abs(tc1.Point.Y - tn1.Point.Y) < 16) then begin
                                        WFIFOW(0, $0080);
                                        WFIFOL(2, tn1.ID);
                                        WFIFOB(6, 0);
                                        tc1.Socket.SendBuf(buf, 7);
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        41: //resetmymob
            begin
                if Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0]) <> -1 then begin
                    tm1 := Map.Objects[Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0])] as TMap;
                    for i := tm1.Mob.Count -1 downto 0 do begin
                        ts := tm1.Mob.Objects[i] as TMob;
                        if (ts.isSummon = true) then begin
                            if (tm1.CList.Count > 0) then begin
                                WFIFOW( 0, $0080);
                                WFIFOL( 2, ts.ID);
                                WFIFOB( 6, 1);
                                SendBCmd(tm1, ts.Point, 7);
                            end;
                            j := tm1.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.IndexOf(ts.ID);
                            if (j <> -1) then tm1.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.Delete(j);
                            j := tm1.Mob.IndexOf(ts.ID);
                            if (j <> -1) then tm1.Mob.Delete(j);
                        end;
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        42: //getmapusers
            begin
                if Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0]) <> -1 then begin
                    tm1 := Map.Objects[Map.IndexOf(tn.Script[tc.ScriptStep].Data1[0])] as TMap;
                    if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) <> '\') then
                        tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tm1.CList.Count)
                    else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tm1.CList.Count);
                end;
                Inc(tc.ScriptStep);
            end;
        43: //setstr
            begin
                j := tn.Script[tc.ScriptStep].Data3[0];
                str := '';
                //Flags
                if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) = '\') then
                    str := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]]
                else begin
                    i := -1;
                    if (tc.Login = 2) then i := tc.Flag.IndexOfName(tn.Script[tc.ScriptStep].Data1[1]);
                    if (i <> -1) then str := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]]
                    else str := tn.Script[tc.ScriptStep].Data1[1];
                end;
                //and more flags
                if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) = '\') then begin
                    //Server flags
                    if (j = 0) then ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := str
                    else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] + str;
                end else if (tc.Login = 2) then begin
                    //Character flags
                    if (j = 0) then tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := str
                    else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] + str;
                end;
                Inc(tc.ScriptStep);
            end;
        45: //resetstat
            begin
                for i := 0 to 5 do tc.ParamBase[i] := 1;
                tc.StatusPoint := 48;
                for i := 1 to tc.BaseLV - 1 do tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
                CalcStat(tc);
                SendCStat(tc);
                SendCStat1(tc, 0, $0009, tc.StatusPoint);
                Inc(tc.ScriptStep);
            end;
        57: //resetbonusstat
            begin
                for i := 0 to 5 do tc.ParamBase[i] := 1;
                tc.StatusPoint := 48;
                for i := 1 to tc.BaseLV + tc.BaseLV div 2 - 1 do
                    tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
                CalcStat(tc);
                SendCStat(tc);
                SendCStat1(tc, 0, $0009, tc.StatusPoint);
                Inc(tc.ScriptStep);
            end;
        46: //resetskill
            begin
                j := 0;
                for i := 2 to MAX_SKILL_NUMBER do begin
                    j := j + tc.Skill[i].Lv;
                    if not tc.Skill[i].Card then tc.Skill[i].Lv := 0;
                end;
                if tc.JID <> 0 then tc.skillpoint := j;
                SendCSkillList(tc);
                CalcStat(tc);
                SendCStat(tc);
                SendCStat1(tc, 0, $000c, tc.SkillPoint);
                Inc(tc.ScriptStep);
            end;
        47: //hstyle
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
                if (i >= 0) then begin
                    j := tc.HairColor;
                    tc.Hair := i;
                    UpdateLook(tc.MData, tc, 1, i, 0, true);
                    UpdateLook(tc.MData, tc, 6, j, 0, true);
                end;
                Inc(tc.ScriptStep);
            end;
        48: //guildreg
            begin
                tn.Reg := tn.Script[tc.ScriptStep].Data1[0];
                // Colus, 20040130: Setting the agit here too.  No need for getagit.
                tn.Agit := tn.Script[tc.ScriptStep].Data1[0];
                Inc(tc.ScriptStep);
            end;
        49: //getgskilllevel //S144 addstart
            begin
                j := GuildList.IndexOf(tc.GuildID);
                if (j <> -1) then begin
                    tg := GuildList.Objects[j] as TGuild;
                    //i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                    i := StrToInt(tn.Script[tc.ScriptStep].Data1[0]);
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[0]);
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[1]);
                    if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
                        if i = 0 then tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
						else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tg.GSkill[i].Lv);
                    end else begin
                        if i = 0 then ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
                        else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tg.GSkill[i].Lv);
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        50: //getguardstatus //S144 addstart
            begin
                j := CastleList.IndexOf(tn.Reg);
                if (j <> -1) then begin
                    tgc := CastleList.Objects[j] as TCastle;
                    i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                    //i := StrToInt(tn.Script[tc.ScriptStep].Data1[0]);
                    //i := i - 1;
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(tgc.GuardStatus[i]));
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[0]);
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[1]);
                    if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
                        if i = 0 then tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
                        else tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tgc.GuardStatus[i]);
                    end else begin
                        if i = 0 then ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0'
                        else ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tgc.GuardStatus[i]);
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        52: //setguardstatus
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                j := StrToInt(tn.Script[tc.ScriptStep].Data1[1]);
                k := CastleList.IndexOf(tn.Reg);
                if (k <> -1) then begin
                    tgc := CastleList.Objects[k] as TCastle;
                    if (i >= 1) or (i <= 8) then begin
                        if (j = 0) or (j = 1) then tgc.GuardStatus[i] := 1;
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        51: //setguildkafra
            begin
                i := StrToInt(tn.Script[tc.ScriptStep].Data1[0]);
                if (i = 0) or (i = 1) then begin
                    SetGuildKafra(tn,i);
                    EnableGuildKafra(tn.Map,'Kafra Service',i);
                end;
                Inc(tc.ScriptStep);
            end;
        53: //callguard
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                if (i >= 1) or (i <= 8) then begin
                    CallGuildGuard(tn,i);
                    end;
                Inc(tc.ScriptStep);
            end;
        54: //callmymob
            begin
                str := UpperCase(tn.Script[tc.ScriptStep].Data1[0]);
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
                l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[3]);
                m := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[4]);
                SpawnNPCMob(tn,str,j,k,l,m);
                Inc(tc.ScriptStep);
            end;
        55: //resetguild
            begin
                l := CastleList.IndexOf(tn.Reg);
                if (l <> - 1) then CastleList.Delete(l);
                Inc(tc.ScriptStep);
            end;
        56: //guilddinvest
            begin
                GuildDInvest(tn);
                Inc(tc.ScriptStep);
            end;
        {Colus, 20040110: Added (empty so far) guild territory commands}
        58: begin end;//getagit
        59: begin end;//getguild
        60: //agitregist
            begin
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Agit now %s', [tn.Script[tc.ScriptStep].Data1[0]]));
                tn.Agit := tn.Script[tc.ScriptStep].Data1[0];
                Inc(tc.ScriptStep);
            end;
        61: begin end;//Movenpc
        63: //Remove Equipment
            begin
                for  j := 1 to 100 do begin
                    if tc.Item[j].Equip = 32768 then begin
                        tc.Item[j].Equip := 0;
                        WFIFOW(0, $013c);
                        WFIFOW(2, 0);
                        tc.Socket.SendBuf(buf, 4);
                    end else if tc.Item[j].Equip <> 0 then begin
                        reset_skill_effects(tc);
                        WFIFOW(0, $00ac);
                        WFIFOW(2, j);
                        WFIFOW(4, tc.Item[j].Equip);
                        tc.Item[j].Equip := 0;
                        WFIFOB(6, 1);
                        tc.Socket.SendBuf(buf, 7);
                        remove_equipcard_skills(tc, j);
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        64: //BaseReset
            begin
                for i := 0 to 5 do tc.ParamBase[i] := 1;
                tc.BaseLV := 1;
                tc.BaseEXP := 0;
                CalcStat(tc);
                SendCStat(tc);
                SendCStat1(tc, 0, $000b, tc.BaseLV);
                SendCStat1(tc, 0, $0009, tc.StatusPoint);
                SendCStat1(tc, 1, $0001, tc.BaseEXP);
                Inc(tc.ScriptStep);
            end;
        65: //Global Variable ->   global [variable name] = [value];
            begin
                tGlobal := TGlobalVars.Create;
                sl := TStringList.Create;
                str := tn.Script[tc.ScriptStep].Data1[0];
                p := nil;
                len := 0;
                //Get the Data from the script
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                if (tn.Script[tc.ScriptStep].Data3[0] = 0) then i := 0
                else i := ConvFlagValue(tc, str);
                //Different Math cases
                case tn.Script[tc.ScriptStep].Data3[0] of
                0,1:  i := i + j;
                2:    i := i - j;
                3:    i := i * j;
                4:    i := i div j;
                end;
                //Prevent i from being negative
                if i < 0 then i := 0;
                if (tn.Script[tc.ScriptStep].Data3[1] <> 0) and
                (i > tn.Script[tc.ScriptStep].Data3[1]) then
                    i := tn.Script[tc.ScriptStep].Data3[1];
                {Write the Vaules}
                tGlobal.Variable := str;
                tGlobal.Value := i;
                if GlobalVars.IndexOf(str) = - 1 then
                    GlobalVars.AddObject(tGlobal.Variable, tGlobal)
                else begin
                    tGlobal := GlobalVars.Objects[GlobalVars.IndexOf(str)] as TGlobalVars;
                    tGlobal.Variable := str;
                    tGlobal.Value := i;
                end;

                AssignFile(txt2, 'Global_Vars.txt');
                Rewrite(txt2);
                Writeln(txt2, '// Variable, Value');
                for i := 0 to GlobalVars.Count - 1 do begin
                    tGlobal := GlobalVars.Objects[i] as TGlobalVars;
                    sl.Clear;
                    sl.Add( tGlobal.Variable );
                    sl.Add( IntToStr( tGlobal.Value ) );
                    Writeln(txt2, sl.DelimitedText);
                end;
                sl.Free;
                Inc(tc.ScriptStep);
                CloseFile(txt2);
            end;
        66: // gcheck - Global Variable Check
            begin
                flag := false;
                str := tn.Script[tc.ScriptStep].Data1[0];
                tGlobal := GlobalVars.Objects[GlobalVars.Indexof(str)] as TGlobalVars;
                i := tGlobal.Value;
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                case tn.Script[tc.ScriptStep].Data3[2] of
                0: flag := boolean(i >= j);
                1: flag := boolean(i <= j);
                2: flag := boolean(i  = j);
                3: flag := boolean(i <> j);
                4: flag := boolean(i >  j);
                5: flag := boolean(i <  j);
                    else begin
                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: invalid formula "%s"', [tn.Script[tc.ScriptStep].Data1[2]]));
                        tc.ScriptStep := $FFFF;
                        break;
                    end;
                end;
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: %s %s(%d) %s = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data3[2], tn.Script[tc.ScriptStep].Data1[1], byte(flag)]));
                if flag then tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0]
                else tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
            end;
        67: {Event MOB}
            //Syntax
            // eventmob [JID],[Name],[X Position],[YPosition],[Perfect Drop ID(0 = None)]
            begin
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                str := UpperCase(tn.Script[tc.ScriptStep].Data1[1]);
                k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
                l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[3]);
                m := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[4]);
                SpawnEventMob(tn,j,str,k,l,m);
                Inc(tc.ScriptStep);
            end;
        44: //checkstr
            begin
                j := tn.Script[tc.ScriptStep].Data3[2];
                str := '';
                //Global var check
                if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) = '\') then
                    str := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]]
                else begin
                    i := -1;
                    if (tc.Login = 2) then i := tc.Flag.IndexOfName(tn.Script[tc.ScriptStep].Data1[1]);
                    if (i <> -1) then str := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]]
                    else str := tn.Script[tc.ScriptStep].Data1[1];
                end;

                flag := false;
                //another global var check
                if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) = '\') then begin
                    if (ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] = str) then
                        flag := true;
                end else if (tc.Login = 2) then begin
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('str-check: %s', [tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]]]));
                    if (tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] = str) then
                    flag := true;
                end;
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('str-check: %s %s %s(%s) = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data1[1], str, byte(flag)]));
                if ((j = 0) and (flag = true)) or ((j = 1) and (flag = false)) then
                    tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0]
                else tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
            end;
        68: // addskillpoints
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                tc.SkillPoint := tc.SkillPoint + i;
                SendCSkillList(tc);
                Inc(tc.ScriptStep);
            end;
        69: // addstatpoints
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                tc.StatusPoint := tc.StatusPoint + i;
                SendCStat(tc);
                Inc(tc.ScriptStep);
            end;
        70: // emotion <emotion #>;
            begin
                i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                tm := tc.MData;
                WFIFOW(0, $00c0);
                WFIFOL(2, tn.ID);
                WFIFOB(6, i);
                SendBCmd(tm, tn.Point, 7);
                Inc(tc.ScriptStep);
            end;
        71: //donpcevent <npcname>,<event>;
            begin
                i := -1;
                for k := 0 to tm.NPC.Count - 1 do begin
                    tn1 := tm.NPC.Objects[k] as TNPC;
                    if (tn1.Name = tn.Script[tc.ScriptStep].Data1[0]) then begin
                        i := 0;
                        break;
                    end;
                end;
                if (tn1.ScriptInitS <> -1) then begin
                    //OnInit���x�������s
                    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('OnInit Event(%d)', [tn1.ID]));
                    tc1 := TChara.Create;
                    tc1.TalkNPCID := tn1.ID;
                    tc1.ScriptStep := tn1.ScriptInitS;
                    tc1.AMode := 3;
                    tc1.AData := tn1;
                    tc1.Login := 0;
                    NPCScript(tc1,0,1);
                    tn.ScriptInitD := true;
                    tc1.Free;
                end;
                if i = 0 then begin
                    //DebugOut.Lines.Add('Need to call the NPC ' + tn1.Name + ' and goto label ' + tn.Script[tc.ScriptStep].Data1[1]);
                    //tc.ScriptStep := tn1.Script[tc.ScriptStep].Data3[0];
                end;
                Inc(tc.ScriptStep);
            end;
        72: //percentheal <percentheal HPpercent,SPpercent;>
            begin
                Inc(tc.HP, tn.Script[tc.ScriptStep].Data3[0]);
                //Healing
                j := tc.MAXHP * tn.Script[tc.ScriptStep].Data3[0] div 100;
                tc.HP := tc.HP + j;
                if tc.HP > tc.MAXHP then tc.HP := tc.MAXHP;
                //SP Increasing
                Inc(tc.SP, tn.Script[tc.ScriptStep].Data3[1]);
                i := tc.MAXSP * tn.Script[tc.ScriptStep].Data3[1] div 100;
                tc.SP := tc.SP + i;
                if tc.SP > tc.MAXSP then tc.SP := tc.MAXSP;
                WFIFOW( 0, $011a);
                WFIFOW( 2, 28);
                WFIFOW( 4, j);
                WFIFOL( 6, tc.ID);
                WFIFOL(10, tn.ID);
                WFIFOB(14, 1);
                SendBCmd(tc.MData, tn.Point, 15);
					{old sp packets
					WFIFOW( 0, $013d);
					WFIFOW( 2, $0007);
					WFIFOW( 4, tn.Script[tc.ScriptStep].Data3[1]);
					tc.Socket.SendBuf(buf, 6);
					}
                SendCStat1(tc, 0, 5, tc.HP);
                SendCStat1(tc, 0, 7, tc.SP);
                Inc(tc.ScriptStep);
            end;
        73: //percentdamage <percentdamage hp,sp;>
            begin
                //Basic Damage
                j := tc.MAXHP * tn.Script[tc.ScriptStep].Data3[0] div 100; //Calculate the damage
                if tc.HP - j > 0 then tc.HP := tc.HP - j
                else tc.HP := 0; //Safe
                //Check if it will kill the character
                if (tc.HP = 0) then begin
                    tc.HP := 0;
                    tc.Sit := 1;
                    SendCStat1(tc, 0, 5, tc.HP);
                    WFIFOW(0, $0080);
                    WFIFOL(2, tc.ID);
                    WFIFOB(6, 1);
                    tc.Socket.SendBuf(buf, 7);
                end else begin
                    //Damage Packet Process
                    WFIFOW( 0, $008a);
                    WFIFOL( 2, tc.ID);
                    WFIFOL( 6, tc.ID);
                    WFIFOL(10, timeGetTime());
                    WFIFOL(14, tc.aMotion);
                    WFIFOL(18, tc.dMotion);
                    WFIFOW(22, j);
                    WFIFOW(24, 1);
                    WFIFOB(26, 0);
                    WFIFOW(27, 0);
                    SendBCmd(tm, tc.Point, 29);
                    end;
                //SP Decreasing
                i := tc.MAXSP * tn.Script[tc.ScriptStep].Data3[1] div 100;
                if tc.SP - i > 0 then tc.SP := tc.SP - i
                else tc.SP := 0;
                //Update Your HP and SP
                SendCStat1(tc, 0, 5, tc.HP);
                SendCStat1(tc, 0, 7, tc.SP);
                Inc(tc.ScriptStep);
            end;
        74: //checkpoint
            begin
                i := MapInfo.IndexOf(tm.Name);
                if (i <> -1) then begin
                    mi := MapInfo.Objects[i] as MapTbl;
                    if (mi.noSave <> true) then begin
                        tc.CheckpointMap := tn.Script[tc.ScriptStep].Data1[0];
                        tc.Checkpoint := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        75: //inputstr (not working)
				begin{
					if value = 0 then begin
						WFIFOW( 0, $01d4);
						WFIFOL( 2, tn.ID);
						tc.Socket.SendBuf(buf, 6);
						break;
					end else begin
						if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := value;
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := value;
						end;

						Inc(tc.ScriptStep);
					end;
				}end;
        76: //areawarp <areawarp x1,y1,x2,y2,dest_map,dest_x,dest_y;>
            //checks for characters on map of npc, between x/y range and warps.
            begin
                i := tn.Script[tc.ScriptStep].Data3[0]; //x1
                j := tn.Script[tc.ScriptStep].Data3[1]; //y1
                k := tn.Script[tc.ScriptStep].Data3[2]; //x2
                l := tn.Script[tc.ScriptStep].Data3[3]; //y2
                tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
                for cnt := 0 to tm.CList.Count - 1 do begin
                    tc1 := tm.CList.Objects[cnt] as TChara;
                    if tc1.Login = 2 then begin
                        if (tc1.Point.X >= i) and
                        (tc1.Point.X <= k) and
                        (tc1.Point.Y >= j) and
                        (tc1.Point.Y <= l) then begin
                            SendCLeave(tc1, 2);
                            tc1.tmpMap := tn.Script[tc.ScriptStep].Data1[0];
                            tc1.Point := Point(tn.Script[tc.ScriptStep].Data3[4],tn.Script[tc.ScriptStep].Data3[5]);
                            MapMove(tc1.Socket, tc1.tmpMap, tc1.Point);
                        end;
                    end;
                end;
                Inc(tc.ScriptStep);
            end;
        77: //cardremoval
            begin
                j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
                k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
                case j of
                1:  l := $100; //Head
                2:  l := $10;  //Body
                3:  l := $20;  //Left Hand
                4:  l := $2;   //Right Hand
                5:  l := $4;   //Robe
                6:  l := $40;  //Foot
                7:  l := $8;   //Acc1
                8:  l := $80;  //Acc2
                9:  l := $200; //Head2
                10: l := $1;   //Head
                else l := 0;
				end;
                if l <> 0 then begin
                    for i := 1 to 100 do begin
                        if (tc.Item[i].ID <> 0) and
                        (tc.Item[i].Amount <> 0) and
                        tc.Item[i].Data.IEquip and
                        ((tc.Item[i].Equip and l) = l) and
                        (tc.Item[i].Refine < 10) then begin
                            //Unattaching from inventory?
                            reset_skill_effects(tc);
                            //packet crap here for doing that
                            tc.Socket.SendBuf(buf, 7);
                            remove_equipcard_skills(tc, i);
                            //Complete fail
                            if k = 0 then begin
                                tc.Item[i].Refine := 0;
                                tc.Item[i].Equip := 0;

                                Dec(tc.Item[i].Amount, 1);
                                if tc.Item[i].Amount = 0 then tc.Item[i].ID := 0;
                                //More Packets i can't do
                                //Update weight
                                tc.Weight := tc.Weight - tc.Item[i].Data.Weight * cardinal(1);
                                SendCStat1(tc, 0, $0018, tc.Weight);
                            end else begin
                                if ((k = 1) or (k = 2)) then begin //both keep weapon, 2 is for card and weap
                                    for m := 0 to 3 do begin
                                        if ((tc.Item[i].Card[m] > 4000) and
                                        (tc.Item[i].Card[m] < 5001)) then
                                            a[m] := tc.Item[i].Card[m]
                                        else a[m] := 0;
                                        tc.Item[i].Card[m] := 0;
                                        //OMG more packets here
                                        end;
                                end else if (k >= 2) then begin //2 is for both and anything else possible.
                                    td := ItemDB.IndexOfObject(i) as TItemDB;
                                    if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
                                        for m := 0 to 2 do begin
                                            if a[m] <> 0 then begin
                                                cnt := SearchCInventory(tc, a[m], td.IEquip);
                                                if cnt <> 0 then begin
                                                    tc.Item[cnt].ID := a[m];
                                                    tc.Item[cnt].Amount := tc.Item[cnt].Amount + 1;
                                                    tc.Item[cnt].Equip := 0;
                                                    tc.Item[cnt].Identify := 1;
                                                    tc.Item[cnt].Refine := 0;
                                                    tc.Item[cnt].Attr := 0;
                                                    tc.Item[cnt].Card[0] := 0;
                                                    tc.Item[cnt].Card[1] := 0;
                                                    tc.Item[cnt].Card[2] := 0;
                                                    tc.Item[cnt].Card[3] := 0;
                                                    tc.Item[cnt].Data := td;
                                                    // Update weight
                                                    tc.Weight := tc.Weight + cardinal(td.Weight) * cardinal(j);
                                                    SendCStat1(tc, 0, $0018, tc.Weight);
                                                    SendCGetItem(tc, cnt, 1);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    CalcStat(tc);
					//more packets i believe
                end;
                Inc(tc.ScriptStep);
            end;
        78://gstore -> opens guild storage
            begin
                if GuildList.IndexOf(tc.GuildID) = -1 then Exit;
                tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;
                tg.Storage.Count := open_storage(tc, tg.Storage.Item);
                tc.guild_storage := True;
                Inc(tc.ScriptStep);
            end;
        //add commands before this


        //end case of
        end;
        Inc(cnt);
    end;
    if cnt >= 100 then begin  //no idea why this is here.
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'script error!!! : infinity loop founded');
		end;
    if (tc.ScriptStep >= tn.ScriptCnt) or (cnt >= 100) then	tc.AMode := 0;
end;
{==============================================================================}
{End of NPC Script Commands}
{==============================================================================}

end.

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

//==============================================================================
// �֐���`
		procedure NPCScript(tc:TChara; value:cardinal = 0; mode:byte = 0);
//==============================================================================










implementation
//==============================================================================
procedure NPCScript(tc:TChara; value:cardinal = 0; mode:byte = 0);
var
	i,j,k,l :integer;
  m       :integer;
	cnt     :integer;
	str     :string;
  txt2    :TextFile;
  sl      :TStringList;
	p       :pointer;
	len     :cardinal;
	flag    :boolean;
	tn      :TNPC;
	td      :TItemDB;
{NPC�C�x���g�ǉ�}
	ts      :TMob;
	ts1     :TMob;
	tm      :TMap;
	tm1     :TMap;
	tn1     :TNPC;
	tc1     :TChara;
  tg      :TGuild;
  tgc     :TCastle;
	w       :word;
	Tick    :cardinal;
	tr      :NTimer;
	tcr     :TChatRoom;
	mi      :MapTbl;
  tGlobal :TGlobalVars;
{NPC�C�x���g�ǉ��R�R�܂�}
begin
	flag := false;

	if (tc.AMode <> 3) then exit;
	tn := tc.AData;
	//with tn do begin
		//�����`�F�b�N
{NPC�C�x���g�ǉ�}
		if (mode = 0) then begin
			if (tc.Map <> tn.Map) or (abs(tc.Point.X - tn.Point.X) > 15) or (abs(tc.Point.Y - tn.Point.Y) > 15) then begin
				tc.AMode := 0;
				exit;
			end;
		end;

        if Map.IndexOf(tn.Map) = -1 then Exit;
		tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
		Tick := timeGetTime();
{NPC�C�x���g�ǉ��R�R�܂�}
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
{NPC�C�x���g�ǉ�}
						if (Copy(str, i + 2, 1) = '$') then begin
							str := Copy(str, 1, i - 1) + tc.Flag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256);
						end else if (Copy(str, i + 2, 2) = '\$') then begin
							str := Copy(str, 1, i - 1) + ServerFlag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256);
						end else begin
							k := ConvFlagValue(tc, Copy(str, i + 2, j - 1), true);
							if k <> -1 then begin
								str := Copy(str, 1, i - 1) + IntToStr(k) + Copy(str, i + j + 2, 256);
							end else begin
								str := Copy(str, 1, i - 1) + Copy(str, i + j + 2, 256);
							end;
						end;
{NPC�C�x���g�ǉ��R�R�܂�}
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
							if i = 0 then
								str := tn.Script[tc.ScriptStep].Data1[i]
							else
								str := str + ':' + tn.Script[tc.ScriptStep].Data1[i];
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
{���BNPC�@�\�ǉ�}
              //EqLock����
							if tc.EqLock = true then tc.EqLock := false;
{���BNPC�@�\�ǉ��R�R�܂�}
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
{NPC�C�x���g�ǉ�}
					i := MapInfo.IndexOf(tm.Name);
					if (i <> -1) then begin
						mi := MapInfo.Objects[i] as MapTbl;
						if (mi.noSave <> true) then begin
							tc.SaveMap := tn.Script[tc.ScriptStep].Data1[0];
							tc.SavePoint := Point(tn.Script[tc.ScriptStep].Data3[0],tn.Script[tc.ScriptStep].Data3[1]);
						end;
					end;
{NPC�C�x���g�ǉ��R�R�܂�}
					Inc(tc.ScriptStep);
				end;
			10: //heal
				begin
					Inc(tc.HP, tn.Script[tc.ScriptStep].Data3[0]);
					if tc.HP > tc.MAXHP then tc.HP := tc.MAXHP;
					Inc(tc.SP, tn.Script[tc.ScriptStep].Data3[1]);
					if tc.SP > tc.MAXSP then tc.SP := tc.MAXSP;
					//�p�P���M
					WFIFOW( 0, $011a);
					WFIFOW( 2, 28);
					WFIFOW( 4, tn.Script[tc.ScriptStep].Data3[0]);
					WFIFOL( 6, tc.ID);
					WFIFOL(10, tn.ID);
					WFIFOB(14, 1);
					SendBCmd(tc.MData, tn.Point, 15);
					{
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
							 if str = 'zeny'        then begin p := @tc.Zeny;        len := 4; end
					else if str = 'job'         then begin p := @tc.JID;         len := 2; end
					else if str = 'baselevel'   then begin p := @tc.BaseLV;      len := 2; end
					else if str = 'joblevel'    then begin p := @tc.JobLV;       len := 2; end
					else if str = 'statuspoint' then begin p := @tc.StatusPoint; len := 2; end
					else if str = 'skillpoint'  then begin p := @tc.SkillPoint;  len := 2; end
					else if str = 'option'      then begin p := @tc.Option;      len := 4; end
					else if str = 'speed'       then begin p := @tc.Speed;       len := 2; end;
					if len <> 0 then begin
						//���ӂ̓p�����[�^
{NPC�C�x���g�ǉ�}
						j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
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
								(i > tn.Script[tc.ScriptStep].Data3[1]) then i := tn.Script[tc.ScriptStep].Data3[1];
						CopyMemory(p, @i, len);
						SendCStat(tc);
					end else begin
						//���ӂ̓t���O
{NPC�C�x���g�ǉ�}
						j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
						if (tn.Script[tc.ScriptStep].Data3[0] = 0) then begin
							i := 0;
						end else begin
							i := ConvFlagValue(tc, str);
						end;
{NPC�C�x���g�ǉ��R�R�܂�}
						case tn.Script[tc.ScriptStep].Data3[0] of
						0,1:  i := i + j;
						2:    i := i - j;
						3:    i := i * j;
						4:    i := i div j;
						end;
						if i < 0 then i := 0;
						if (tn.Script[tc.ScriptStep].Data3[1] <> 0) and
							 (i > tn.Script[tc.ScriptStep].Data3[1]) then i := tn.Script[tc.ScriptStep].Data3[1];
{NPC�C�x���g�ǉ�}
						if (Copy(str, 1, 1) <> '\') then begin
							tc.Flag.Values[str] := IntToStr(i);
						end else begin
							ServerFlag.Values[str] := IntToStr(i);
						end;
{NPC�C�x���g�ǉ��R�R�܂�}
					end;
					Inc(tc.ScriptStep);
				end;
			12: //additem
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
					td := ItemDB.IndexOfObject(i) as TItemDB;
					if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
						k := SearchCInventory(tc, i, td.IEquip);
						if k <> 0 then begin
							if tc.Item[k].Amount + j > 30000 then j := 30000 - tc.Item[k].Amount;
							if td.IEquip then j := 1;
							//�A�C�e���ǉ�
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

							//�A�C�e���Q�b�g�ʒm
							SendCGetItem(tc, k, j);
						end;
					end else begin
						//�d�ʃI�[�o�[
						WFIFOW( 0, $00a0);
						WFIFOB(22, 2);
						tc.Socket.SendBuf(buf, 23);
					end;
					Inc(tc.ScriptStep);
				end;
			13: //delitem
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
					k := SearchCInventory(tc, i, false);
					if k <> 0 then begin
						if j > tc.Item[k].Amount then j := tc.Item[k].Amount;
						//�������Ȃ瑕������
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
						//�A�C�e��������
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
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
					k := SearchCInventory(tc, i, false);
					if (k <> 0) and (tc.Item[k].Amount >= j) then begin
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-checkitem: %d %d = 1', [i, j]));
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
					end else begin
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-checkitem: %d %d = 0', [i, j]));
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
					end;
				end;
			15: //check
				begin
					str := tn.Script[tc.ScriptStep].Data1[0];
							 if str = 'zeny'        then begin i := tc.Zeny;        end
					else if str = 'job'         then begin
            i := tc.JID;
            if (i > UPPER_JOB_BEGIN) then i := i - UPPER_JOB_BEGIN + LOWER_JOB_END;
          end
					else if str = 'baselevel'   then begin i := tc.BaseLV;      end
					else if str = 'joblevel'    then begin i := tc.JobLV;       end
					else if str = 'statuspoint' then begin i := tc.StatusPoint; end
					else if str = 'skillpoint'  then begin i := tc.SkillPoint;  end
					else if str = 'option'      then begin i := tc.Option;      end
					else if str = 'speed'       then begin i := tc.Speed;       end
					else if str = 'gender'      then begin i := tc.Gender;      end
{���F�ύX�ǉ�}
					else if str = 'hcolor'      then begin i := tc.HairColor;   end
                                        else if str = 'guildid'     then begin i := GetGuildID(tn);   end
                                        else if str = 'guildkafra'  then begin i := GetGuildKafra(tn);   end
                                        else if str = 'ismyguild'   then begin i := CheckGuildID(tn, tc);   end
                                        else if str = 'ismymaster'   then begin i := CheckGuildMaster(tn, tc);   end
                                        else if str = 'etrigger'   then begin i := GetGuildETrigger(tn);   end
                                        else if str = 'dtrigger'   then begin i := GetGuildDTrigger(tn);   end
{���F�ύX�ǉ��R�R�܂�}
					else begin
{NPC�C�x���g�ǉ��R�R�܂�}
						i := ConvFlagValue(tc, str);
					end;
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
					case tn.Script[tc.ScriptStep].Data3[2] of
					0: flag := boolean(i >= j);
					1: flag := boolean(i <= j);
					2: flag := boolean(i  = j);
					3: flag := boolean(i <> j);
					4: flag := boolean(i >  j);
					5: flag := boolean(i <  j);
					else
						begin
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: invalid formula "%s"', [tn.Script[tc.ScriptStep].Data1[2]]));
							tc.ScriptStep := $FFFF;
							break;
						end;
					end;
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: %s %s(%d) %s = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data3[2], tn.Script[tc.ScriptStep].Data1[1], byte(flag)]));
					if flag then begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
					end else begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
					end;
				end;
			16: //checkadditem
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
					td := ItemDB.IndexOfObject(i) as TItemDB;
					if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
						k := SearchCInventory(tc, i, td.IEquip);
						if k <> 0 then begin
							tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
						end else begin
							//�A�C�e����ސ��I�[�o�[
							tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
						end;
					end else begin
						//�d�ʃI�[�o�[
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
					end;
				end;
			17: //jobchange
				begin
                                   {�o�O��657}
                                        //��������
					for i := 1 to 100 do begin
					        if tc.Item[i].Equip = 32768 then
                                                begin
					                tc.Item[i].Equip := 0;
					                WFIFOW(0, $013c);
				                	WFIFOW(2, 0);
					                tc.Socket.SendBuf(buf, 4);
					        end else
                                                if tc.Item[i].Equip <> 0 then
                                                begin
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

                    if (tc.Option <> 0) then begin
                        tc.Option := 0;
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
          end else begin
            tc.ClothesColor := 0; // Default color for regular jobs
          end;
          tc.JID := j;
					tc.JobEXP := 0;

					tc.JobLV := 1;
					SendCStat1(tc, 0, $0037, tc.JobLV);
					CalcStat(tc);
					tc.SkillPoint := 0;
                                        //�X�e�[�^�X�Čv�Z
					CalcStat(tc);
					SendCStat(tc, true);
					SendCSkillList(tc);
          // Colus, 20040304: New view packet for jobchange
          UpdateLook(tc.MData, tc, 0, tc.JID);

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
						//�t���O�Z�b�g
{NPC�C�x���g�ǉ�}
						if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value - 1);
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value - 1);
						end;
{NPC�C�x���g�ǉ��R�R�܂�}
						Inc(tc.ScriptStep);
					end;
				end;
			20: //random
				begin
{NPC�C�x���g�ǉ�}
					if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
						tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(Random(tn.Script[tc.ScriptStep].Data3[0]));
					end else begin
						ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(Random(tn.Script[tc.ScriptStep].Data3[0]));
					end;
{NPC�C�x���g�ǉ��R�R�܂�}
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
                                                    end; //�J�[�g1
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

					CalcStat(tc);

					//�����ڕύX
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
					//�p�P���M
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
{NPC�C�x���g�ǉ��R�R�܂�}
					//�X�s�[�h�ύX
					if (i >= 25) and (i <= 1000) then begin
						tc.Speed := i;
						tc.DefaultSpeed := i;
 
						CalcStat(tc);
						SendCStat1(tc, 0, 0, tc.Speed);
 
						Inc(tc.ScriptStep);
					end;
				end;
			23: //die
				begin
					//�p�P���M
					//�v���[���[����
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
					//�p�P���M
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
{NPC�C�x���g�ǉ��R�R�܂�}
					//�F�ύX
					if (i >= 0) then begin
						CalcStat(tc);
						tc.ClothesColor := i;
            UpdateLook(tc.MData, tc, 7, i, 0, true);
					end;
					Inc(tc.ScriptStep);
				end;
			25: //refine		refine[itemID][fail][+val]
				begin
{NPC�C�x���g�ǉ�}
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
					l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
{NPC�C�x���g�ǉ��R�R�܂�}
					//���B
					if (j >= 0) and (j <= 10) then begin
						for i := 1 to 100 do begin
							if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount <> 0) and tc.Item[i].Data.IEquip and
								 (tc.Item[i].Equip <> 0) and (tc.Item[i].Card[0] <> $00ff) then begin
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
						//�p�P���M
						SendBCmd(tc.MData, tc.Point, 10, tc);
						SendCStat(tc);
					end;
					Inc(tc.ScriptStep);
				end;
			26: //getitemamount
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
{NPC�C�x���g�ǉ��R�R�܂�}
					k := SearchCInventory(tc, i, false);
					if k <> 0 then begin
						tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Item[k].Amount);
					end else begin
						tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := '0';
					end;
					Inc(tc.ScriptStep);
				end;
{�ǉ�:�X�N���v�g144}
			27: //getskilllevel //S144 addstart
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
						if i = 0 then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Skill[i].Lv);
						end;
					end else begin
						if i = 0 then begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tc.Skill[i].Lv);
						end;
					end;
{NPC�C�x���g�ǉ��R�R�܂�}
					Inc(tc.ScriptStep);
				end;
			28: //setskilllevel
				begin
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					if i <> 0 then begin
						l := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
						if ((0 <= l) and (l <= 10)) then tc.Skill[i].Lv := l;
						SendCSKillList(tc);
					end;
					Inc(tc.ScriptStep);
				end; //S144 addend
{�ǉ�:�X�N���v�g144�R�R�܂�}
{���BNPC�@�\�ǉ�}
			29: //refinery <-- Turned a few jap comments to what they should mean [Tsusai]
				begin
{NPC�C�x���g�ǉ�}
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
					k := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
{NPC�C�x���g�ǉ��R�R�܂�}
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
{NPC�C�x���g�ǉ�}
					j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[2]);
{NPC�C�x���g�ǉ��R�R�܂�}
					if (j < 0) or (j > 10) then j := 0;
					if l <> 0 then begin
						for i := 1 to 100 do begin
							if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount <> 0) and tc.Item[i].Data.IEquip and
								 ((tc.Item[i].Equip and l) = l) and (tc.Item[i].Refine < 10) then begin
								//��������
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
									//�G�t�F�N�g
									WFIFOW(0, $0188);
									WFIFOW(2, 0);
									WFIFOW(4, i);
									WFIFOW(6, tc.Item[i].Refine);
									tc.Socket.SendBuf(buf, 8);
									//�đ���
									WFIFOW(0, $00aa);
									WFIFOW(2, i);
									WFIFOW(4, tc.Item[i].Equip);
									WFIFOB(6, 1);
									tc.Socket.SendBuf(buf, 7);
								//Refine failure, kiss weapon goodbye
								end else begin
									tc.Item[i].Refine := 0;
									tc.Item[i].Equip := 0;
									//�G�t�F�N�g
									WFIFOW(0, $0188);
									WFIFOW(2, 1);
									WFIFOW(4, i);
									WFIFOW(6, word(tc.Item[i].Refine));
									tc.Socket.SendBuf(buf, 8);
									if k = 1 then begin
										//�A�C�e������
										Dec(tc.Item[i].Amount, 1);
										if tc.Item[i].Amount = 0 then tc.Item[i].ID := 0;
										WFIFOW( 0, $00af);
										WFIFOW( 2, i);
										WFIFOW( 4, 1);
										tc.Socket.SendBuf(buf, 6);
										//�d�ʕύX
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
						//�p�P���M
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
	  					if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount <> 0) and (tc.Item[i].Equip <> 0) then begin
                if tc.Item[i].Refine > 0 then str := '(+' + IntToStr(tc.Item[i].Refine) + ')'
                  else str := '';
                str := tc.Item[i].Data.JName + str;
                case tc.Item[i].Equip of
									$1: //�����i
										tn.Script[tc.ScriptStep].Data2[9] := str;
									$2: //�E��
										tn.Script[tc.ScriptStep].Data2[3] := str;
									$4: //��
										tn.Script[tc.ScriptStep].Data2[4] := str;
									$8: //�A�N�Z1
										tn.Script[tc.ScriptStep].Data2[6] := str;
									$10: //�Z
										tn.Script[tc.ScriptStep].Data2[1] := str;
                  $20: //����
										tn.Script[tc.ScriptStep].Data2[2] := str;
									$22: //���蕐��
										begin
											tn.Script[tc.ScriptStep].Data2[2] := str;
											tn.Script[tc.ScriptStep].Data2[3] := str;
										end;
									$40: //�C
										tn.Script[tc.ScriptStep].Data2[5] := str;
									$80: //�A�N�Z2
										tn.Script[tc.ScriptStep].Data2[7] := str;
									$100: //����i
										tn.Script[tc.ScriptStep].Data2[0] := str;
									$200: //�����i
										tn.Script[tc.ScriptStep].Data2[8] := str;
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
							if i = 0 then
								str := tn.Script[tc.ScriptStep].Data2[i]
							else
								str := str + ':' + tn.Script[tc.ScriptStep].Data2[i];
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
              //EqLock����
              if tc.EqLock = true then tc.EqLock := false;
							tc.ScriptStep := $FFFF;
							break;
						end;
{NPC�C�x���g�ǉ�}
						if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value);
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := IntToStr(value);
						end;
{NPC�C�x���g�ǉ��R�R�܂�}
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
	    					if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount <> 0) and tc.Item[i].Data.IEquip and
  		  					 ((tc.Item[i].Equip and l) = l) then begin
                  if tc.Item[i].Data.IType = 4 then begin
                    j := tc.Item[i].Data.wLV;
                  end else begin
                    j := 0;
                  end;
                  k := i;
                  break;
                end;
              end;
{NPC�C�x���g�ǉ�}
							if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) <> '\') then begin
								tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(j);
							end else begin
								ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(j);
							end;
							if (Copy(tn.Script[tc.ScriptStep].Data1[2], 1, 1) <> '\') then begin
								if k <> 0 then
									tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[2]] := IntToStr(tc.Item[i].Refine)
								else
									tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[2]] := '0';
							end else begin
								if k <> 0 then
									ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[2]] := IntToStr(tc.Item[i].Refine)
								else
									ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[2]] := '0';
							end;
{NPC�C�x���g�ǉ��R�R�܂�}
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
{NPC�C�x���g�ǉ�}
					i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0], true);
{NPC�C�x���g�ǉ��R�R�܂�}
					if (i >= 0) then begin
						tc.HairColor := i;
            UpdateLook(tc.MData, tc, 6, i, 0, true);
					end;
					Inc(tc.ScriptStep);
				end;
{���F�ύX�ǉ��R�R�܂�}
{NPC�C�x���g�ǉ�}
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
						//�C�x���g�ݒ�
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
							if Data.isDontMove then
								MoveWait := 4294967295
							else
								MoveWait := Tick + 5000 + Cardinal(Random(10000));
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

						//���͂ɑ��M
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
						if (Copy(str, i + 2, 1) = '$') then begin
							str := Copy(str, 1, i - 1) + tc.Flag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256);
						end else if (Copy(str, i + 2, 2) = '\$') then begin
							str := Copy(str, 1, i - 1) + ServerFlag.Values[Copy(str, i + 2, j - 1)]  + Copy(str, i + j + 2, 256);
						end else begin
							k := ConvFlagValue(tc, Copy(str, i + 2, j - 1), true);
							if k <> -1 then begin
								str := Copy(str, 1, i - 1) + IntToStr(k) + Copy(str, i + j + 2, 256);
							end else begin
								str := Copy(str, 1, i - 1) + Copy(str, i + j + 2, 256);
							end;
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
					str := StringReplace(str, '\\', '\', [rfReplaceAll]);
					if ((l mod 100) div 10 = 0) then str := tn.Name + ' : ' + str;
					if (l div 100 = 1) then str := 'blue' + str;
					w := Length(str) + 4;
					WFIFOW(0, $009a);
					WFIFOW(2, w);
					WFIFOS(4, str, w - 4);

					if (l mod 10 = 0) then begin
						//�J�����gMAP�̃L�����ɑ��M
						tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
						for i := 0 to tm.CList.Count - 1 do begin
							tc1 := tm.CList.Objects[i] as TChara;
							if tc1.Login = 2 then tc1.Socket.SendBuf(buf, w);
						end;
					end else begin
						//�S���[���h�̃L�����ɑ��M
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
						//�^�C�}�[OFF
						if (j <> -1) then begin
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('NPC Timer(%d) was deleted / Remaining Timer(%d)', [tn.ID,tm.TimerAct.Count-1]));
							tm.TimerAct.Delete(tm.TimerAct.IndexOf(tn.ID));
						end;
					end else if (i = 1) then begin
						//�^�C�}�[ON
						if (j = -1) then begin
							//�V�K�X�^�[�g
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
							//�ăX�^�[�g
							tr := tm.TimerAct.Objects[j] as NTimer;
							tr.Tick := timeGetTime();
							for k := 0 to tr.Cnt - 1 do begin
								tr.Done[k] := 0;
							end;
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
						//�J�����gMAP�̃L������]��
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
						//�S���[���h�̃L������]��
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
						//NPC�`���b�g���[�����̃L������]��
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
										if (abs(tc1.Point.X - tn1.Point.X) < 16) and (abs(tc1.Point.Y - tn1.Point.Y) < 16) then begin
											SendNData(tc1.Socket, tn1, tc1.ver2, tc1);
										end;
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
										if (abs(tc1.Point.X - tn1.Point.X) < 16) and (abs(tc1.Point.Y - tn1.Point.Y) < 16) then begin
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
						if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) <> '\') then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tm1.CList.Count);
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tm1.CList.Count);
						end;
					end;
					Inc(tc.ScriptStep);
				end;
			43: //setstr
				begin
					j := tn.Script[tc.ScriptStep].Data3[0];
					str := '';
					//�E�Ӄt���O�`�F�b�N
					if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) = '\') then begin
						//�T�[�o���L�t���O
						str := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]];
					end else begin
						i := -1;
						if (tc.Login = 2) then begin
							i := tc.Flag.IndexOfName(tn.Script[tc.ScriptStep].Data1[1]);
						end;
						if (i <> -1) then begin
							//�L�����N�^�[�t���O
							str := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]];
						end else begin
							//������
							str := tn.Script[tc.ScriptStep].Data1[1];
						end;
					end;

					//���Ӄt���O�`�F�b�N
					if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) = '\') then begin
						//�T�[�o���L�t���O
						if (j = 0) then begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := str;
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] + str;
						end;
					end else if (tc.Login = 2) then begin
						//�L�����N�^�[�t���O
						if (j = 0) then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := str;
						end else begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] + str;
						end;
					end;
					Inc(tc.ScriptStep);
				end;
      45: //resetstat
				begin
          for i := 0 to 5 do begin
						tc.ParamBase[i] := 1;
					end;
					tc.StatusPoint := 48;
					for i := 1 to tc.BaseLV - 1 do begin
						tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
				  end;
					CalcStat(tc);
          SendCStat(tc);
          SendCStat1(tc, 0, $0009, tc.StatusPoint);
					Inc(tc.ScriptStep);
				end;
          57: //resetbonusstat
				begin
          for i := 0 to 5 do begin
						tc.ParamBase[i] := 1;
					end;
					tc.StatusPoint := 48;
					for i := 1 to tc.BaseLV + tc.BaseLV div 2 - 1 do begin
						tc.StatusPoint := tc.StatusPoint + i div 5 + 3;
				  end;
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
          if not tc.Skill[i].Card then
          tc.Skill[i].Lv := 0;
					end;

					if tc.JID = 0 then begin
                                        end
                                        else begin
                                                tc.skillpoint := j;
                                        end;

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
{NPC�C�x���g�ǉ�}
          j := GuildList.IndexOf(tc.GuildID);
          if (j <> -1) then begin
          tg := GuildList.Objects[j] as TGuild;
					//i := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[0]);
          i := StrToInt(tn.Script[tc.ScriptStep].Data1[0]);
          //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[0]);
          //debugout.lines.add('[' + TimeToStr(Now) + '] ' + tn.Script[tc.ScriptStep].Data1[1]);
					if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) <> '\') then begin
						if i = 0 then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tg.GSkill[i].Lv);
						end;
					end else begin
						if i = 0 then begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tg.GSkill[i].Lv);
						end;
					end;
          end;
{NPC�C�x���g�ǉ��R�R�܂�}
					Inc(tc.ScriptStep);
				end;
      50: //getguardstatus //S144 addstart
				begin
{NPC�C�x���g�ǉ�}
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
						if i = 0 then begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tgc.GuardStatus[i]);
						end;
					end else begin
						if i = 0 then begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] := '0';
						end else begin
							ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]] := IntToStr(tgc.GuardStatus[i]);
						end;
					end;
          end;
{NPC�C�x���g�ǉ��R�R�܂�}
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
					if (j = 0) or (j = 1) then begin
          //i := i - 1;
          tgc.GuardStatus[i] := 1;
					end;
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
        if (l <> - 1) then begin
        CastleList.Delete(l);
        end;
        Inc(tc.ScriptStep);
        end;
       56: //guilddinvest
        begin
          GuildDInvest(tn);
          Inc(tc.ScriptStep);
        end;


    	{Colus, 20040110: Added (empty so far) guild territory commands}
      58: //getagit
        begin

        end;
      59: //getguild
        begin
        end;
      60: //agitregist
        begin
          //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Agit now %s', [tn.Script[tc.ScriptStep].Data1[0]]));
          tn.Agit := tn.Script[tc.ScriptStep].Data1[0];
					Inc(tc.ScriptStep);        
        end;

        {61: //Movenpc
                begin

                end;}
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
          for i := 0 to 5 do begin
            tc.ParamBase[i] := 1;
          end;
          tc.BaseLV := 1;
          tc.BaseEXP := 0;
          CalcStat(tc);
          SendCStat(tc);
          SendCStat1(tc, 0, $000b, tc.BaseLV);
          SendCStat1(tc, 0, $0009, tc.StatusPoint);
          SendCStat1(tc, 1, $0001, tc.BaseEXP);
          Inc(tc.ScriptStep);
        end;
      65: //Global Variable
        {Syntax:
          global [variable name] = [value];
        }
        begin
          tGlobal := TGlobalVars.Create;
          sl := TStringList.Create;
					str := tn.Script[tc.ScriptStep].Data1[0];
					p := nil;
					len := 0;

					//Get the Data from the script
          j := ConvFlagValue(tc, tn.Script[tc.ScriptStep].Data1[1]);
          if (tn.Script[tc.ScriptStep].Data3[0] = 0) then begin
            i := 0;
          end else begin
            i := ConvFlagValue(tc, str);
          end;

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
            (i > tn.Script[tc.ScriptStep].Data3[1]) then i := tn.Script[tc.ScriptStep].Data3[1];
          {Write the Vaules}
						{if (Copy(str, 1, 1) <> '\') then begin
							tc.Flag.Values[str] := IntToStr(i);
						end else begin
							ServerFlag.Values[str] := IntToStr(i);
						end;}
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
{NPC�C�x���g�ǉ��R�R�܂�}
					case tn.Script[tc.ScriptStep].Data3[2] of
					0: flag := boolean(i >= j);
					1: flag := boolean(i <= j);
					2: flag := boolean(i  = j);
					3: flag := boolean(i <> j);
					4: flag := boolean(i >  j);
					5: flag := boolean(i <  j);
					else
						begin
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: invalid formula "%s"', [tn.Script[tc.ScriptStep].Data1[2]]));
							tc.ScriptStep := $FFFF;
							break;
						end;
					end;
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('s-check: %s %s(%d) %s = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data3[2], tn.Script[tc.ScriptStep].Data1[1], byte(flag)]));
					if flag then begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
					end else begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
					end;
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
					//�E�Ӄt���O�`�F�b�N
					if (Copy(tn.Script[tc.ScriptStep].Data1[1], 1, 1) = '\') then begin
						//�T�[�o���L�t���O
						str := ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[1]];
					end else begin
						i := -1;
						if (tc.Login = 2) then begin
							i := tc.Flag.IndexOfName(tn.Script[tc.ScriptStep].Data1[1]);
						end;
						if (i <> -1) then begin
							//�L�����N�^�[�t���O
							str := tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[1]];
						end else begin
							//������
							str := tn.Script[tc.ScriptStep].Data1[1];
						end;
					end;

					flag := false;
					//���Ӄt���O�`�F�b�N
					if (Copy(tn.Script[tc.ScriptStep].Data1[0], 1, 1) = '\') then begin
						//�T�[�o���L�t���O
						if (ServerFlag.Values[tn.Script[tc.ScriptStep].Data1[0]] = str) then begin
							flag := true;
						end;
					end else if (tc.Login = 2) then begin
						//�L�����N�^�[�t���O
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('str-check: %s', [tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]]]));
						if (tc.Flag.Values[tn.Script[tc.ScriptStep].Data1[0]] = str) then begin
							flag := true;
						end;
					end;

					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('str-check: %s %s %s(%s) = %d', [tn.Script[tc.ScriptStep].Data1[0], tn.Script[tc.ScriptStep].Data1[2], tn.Script[tc.ScriptStep].Data1[1], str, byte(flag)]));
					if ((j = 0) and (flag = true)) or ((j = 1) and (flag = false)) then begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[0];
					end else begin
						tc.ScriptStep := tn.Script[tc.ScriptStep].Data3[1];
					end;
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
    70:   {NPC Emotions}
    // emotion <emotion #>;
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
                DebugOut.Lines.Add('Need to call the NPC ' + tn1.Name + ' and goto label ' + tn.Script[tc.ScriptStep].Data1[1]);
                //tc.ScriptStep := tn1.Script[tc.ScriptStep].Data3[0];
            end;

            Inc(tc.ScriptStep);
        end;
        72: //percentheal
        {   usage: percentheal HPpercent,SPpercent;
            the percent of healing is based upon total HP and SP }
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
					//�p�P���M
					WFIFOW( 0, $011a);
					WFIFOW( 2, 28);
					WFIFOW( 4, j);
					WFIFOL( 6, tc.ID);
					WFIFOL(10, tn.ID);
					WFIFOB(14, 1);
					SendBCmd(tc.MData, tn.Point, 15);
					{
					WFIFOW( 0, $013d);
					WFIFOW( 2, $0007);
					WFIFOW( 4, tn.Script[tc.ScriptStep].Data3[1]);
					tc.Socket.SendBuf(buf, 6);
					}
					SendCStat1(tc, 0, 5, tc.HP);
					SendCStat1(tc, 0, 7, tc.SP);

					Inc(tc.ScriptStep);
				end;

        73: {Percent Damage by Tsusai}
            //Usage: percentdamage HPpercent,SPpercent;
            // the percent of damage is based upon total HP and SP }
            begin
                //Basic Damage
                j := tc.MAXHP * tn.Script[tc.ScriptStep].Data3[0] div 100; //Calculate the damage
                if tc.HP - j > 0 then
                tc.HP := tc.HP - j
                else tc.HP := 0; //Safe

                //Check if it will kill the character
                if (tc.HP = 0) then begin
                    tc.HP := 0;
                    tc.Sit := 1;
                    SendCStat1(tc, 0, 5, tc.HP);
                    WFIFOW(0, $0080);
                    WFIFOL(2, tc.ID);
                    WFIFOB(6, 1);
                    tc.Socket.SendBuf(buf, 7); //You didn't finish your packet process
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
                if tc.SP - i > 0 then
                    tc.SP := tc.SP - i
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

			end;
    Inc(cnt);
		end;
		if cnt >= 100 then begin
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'script error!!! : infinity loop founded');
		end;
		if (tc.ScriptStep >= tn.ScriptCnt) or (cnt >= 100) then begin
			//�X�N���v�g�I��
			tc.AMode := 0;
		end;
	//end;
end;
//==============================================================================
end.

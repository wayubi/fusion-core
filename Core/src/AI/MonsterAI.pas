unit MonsterAI;

interface

uses
	Windows, StdCtrls, MMSystem, Classes, SysUtils, ScktComp, List32, Common, Path;

        procedure CalcAI(tm:TMap; ts:TMob; Tick:Cardinal);
        procedure MobSpawn(tm:TMap; ts:TMob; Tick:cardinal);
        procedure MobSkillCalc(tm:TMap;ts:TMob;Tick:cardinal);
        procedure MobSkillChance(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
        procedure MobSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);

        procedure MobSkillDamageCalc(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);

var

dmg           :array[0..7] of integer;


implementation


//------------------------------------------------------------------------------
{Monster's AI}
procedure CalcAI(tm:TMap; ts:TMob; Tick:Cardinal);
var
	j,i1,j1,k1:integer;
	tc1:TChara;
	ts2:TMob;
	tn:TNPC;
	sl:TStringList;
begin
	sl := TStringList.Create;
	with ts do begin
                //MobSkillCalc(tm,ts,Tick);

		if (ts.Stat1 <> 0) and (Data.Range1 > 0) then begin
			pcnt := 0;
			Exit;
		end;

                if (isLeader) and ( (MonsterMob) or ((isSummon) and (SummonMonsterMob)) )then begin
                        if (SlaveCount = 0) and (Random(1000) <= 10) then begin
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, 196);
                                WFIFOW( 4, 1);
                                WFIFOL( 6, ID);
                                WFIFOL(10, ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, ts.Point, 15);
                                MobSpawn(tm,ts,Tick);
                        end;
                end;

		if (ATarget = 0) then begin

			if isActive then begin
			
				sl.Clear;
				for j1 := Point.Y div 8 - 3 to Point.Y div 8 + 3 do begin
					for i1 := Point.X div 8 - 3 to Point.X div 8 + 3 do begin
						for k1 := 0 to tm.Block[i1][j1].CList.Count - 1 do begin
							tc1 := tm.Block[i1][j1].CList.Objects[k1] as TChara;
							if (tc1.HP > 0) and (tc1.Hidden = false) and (tc1.Paradise = false) and ((ts.isGuardian <> tc1.GUildID) or (ts.isGuardian = 0)) and (abs(ts.Point.X - tc1.Point.X) <= 10) and (abs(ts.Point.Y - tc1.Point.Y) <= 10) then begin  //edited by The Harbinger -- darkWeiss Version

                                                                if (tc1.Sit <> 1) or (tc1.Option < 64) then begin
								        sl.AddObject(IntToStr(tc1.ID), tc1);
                                                                end;
							end;
						end;
					end;
				end;

				if sl.Count <> 0 then begin

					j := Random(sl.Count);
					ATarget := StrToInt(sl.Strings[j]);
					ARangeFlag := false;
					AData := sl.Objects[j];
					ATick := Tick;
					ARangeFlag := false;
					Exit;
				end;
			end;

			if (not isLooting) and Data.isLoot then begin

				sl.Clear;

				for j1 := Point.Y div 8 - 3 to Point.Y div 8 + 3 do begin
					for i1 := Point.X div 8 - 3 to Point.X div 8 + 3 do begin
						for k1 := 0 to tm.Block[i1][j1].NPC.Count - 1 do begin
							tn := tm.Block[i1][j1].NPC.Objects[k1] as TNPC;
							if tn.CType <> 3 then Continue;
							if (abs(tn.Point.X - Point.X) <= 10) and (abs(tn.Point.Y - Point.Y) <= 10) then begin

								sl.AddObject(IntToStr(tn.ID), tn);
							end;
						end;
					end;
				end;

				if sl.Count <> 0 then begin
					j := Random(sl.Count);
					tn := sl.Objects[j] as TNPC;
					j := SearchPath2(path, tm, Point.X, Point.Y, tn.Point.X, tn.Point.Y);
					if (j <> 0) then begin
						isLooting := True;
						ATarget := tn.ID;
						ATick := Tick;

						pcnt := j;
						ppos := 0;
						MoveTick := Tick;
						tgtPoint := tn.Point;
						
					end;

					Exit;
				end;
			end;

		end else begin
                        if (isLeader) and (isLooting = false) then begin
				for j1 := Point.Y div 8 - 3 to Point.Y div 8 + 3 do begin
					for i1 := Point.X div 8 - 3 to Point.X div 8 + 3 do begin
						for k1 := 0 to tm.Block[i1][j1].Mob.Count - 1 do begin
                                                        if (tm.Block[i1][j1].Mob.Objects[k1] is TMob) then begin
							        ts2 := tm.Block[i1][j1].Mob.Objects[k1] as TMob;
                                                                if (ts2 <> nil) or (ts2 <> ts) then begin
							                if ts2.LeaderID <> ts.ID then continue;
							                if (abs(ts.Point.X - ts2.Point.X) <= 10) and (abs(ts.Point.Y - ts2.Point.Y) <= 10) then begin
								                if ts2.ATarget = 0 then begin
									        ts2.ATarget := ts.ATarget;
									        ts2.ARangeFlag := false;
									        ts2.AData := ts.AData;
									        ts2.ATick := Tick;
									        ts2.ARangeFlag := false;
								        end;
							        end;
                                                        end;
                                                end;
                                        end;
                                end;
                        end;
                end;

                if Data.isLink and (not isLooting) then begin
                        for j1 := Point.Y div 8 - 3 to Point.Y div 8 + 3 do begin
                                for i1 := Point.X div 8 - 3 to Point.X div 8 + 3 do begin
                                        for k1 := 0 to tm.Block[i1][j1].Mob.Count - 1 do begin
                                                ts2 := tm.Block[i1][j1].Mob.Objects[k1] as TMob;
                                                if (ts2 <> nil) or (ts2 <> ts) then begin
							if ts2.JID <> ts.JID then continue;
							if (abs(ts.Point.X - ts2.Point.X) <= 10) and (abs(ts.Point.Y - ts2.Point.Y) <= 10) then begin
								if ts2.ATarget = 0 then begin
									ts2.ATarget := ts.ATarget;
									ts2.ARangeFlag := false;
									ts2.AData := ts.AData;
									ts2.ATick := Tick;
									ts2.ARangeFlag := false;
								end;
							end;
                                                end;
						end;
					end;
				end;
			end;
		end;

	sl.Free;
	end;
end;

//------------------------------------------------------------------------------

{Spawn Monster}
procedure MobSpawn(tm:TMap; ts:TMob; Tick:cardinal);
var
	i, j, k, l, h, m, ii   :integer;
	tc                     :TChara;
  ts1                    :TMob;
  tss                    :TSlaveDB;

begin

if (MonsterMob = true) then begin
        k := SlaveDBName.IndexOf(ts.Data.Name);
        if (k <> -1) then begin
                ts.isLeader := true;
                tss := SlaveDBName.Objects[k] as TSlaveDB;
                if ts.Data.Name = tss.Name then begin

                        h := tss.TotalSlaves;
                        ts.SlaveCount := h;

                        repeat
                                for i := 0 to 4 do begin
                                        if (tss.Slaves[i] <> -1) and (h <> 0) then begin
                                                ts1 := TMob.Create;
					        ts1.Data := MobDBName.Objects[tss.Slaves[i]] as TMobDB;
					        ts1.ID := NowMobID;
					        Inc(NowMobID);
					        ts1.Name := ts1.Data.JName;
					        ts1.JID := ts1.Data.ID;
                                                ts1.LeaderID := ts.ID;
                                                ts1.Data.isLink := false;
					        ts1.Map := ts.Map;
                                                ts1.Point.X := ts.Point.X;
					        ts1.Point.Y := ts.Point.Y;
					        ts1.Dir := ts.Dir;
					        ts1.HP := ts1.Data.HP;
                                                if ts.Data.Speed < ts1.Data.Speed then begin
					                ts1.Speed := ts.Data.Speed;
                                                end else begin
                                                        ts1.Speed := ts1.Data.Speed;
                                                end;

					        ts1.SpawnDelay1 := $7FFFFFFF;
					        ts1.SpawnDelay2 := 0;
					        ts1.SpawnType := 0;
					        ts1.SpawnTick := 0;
                                                if ts1.Data.isDontMove then
						        ts1.MoveWait := $FFFFFFFF
					        else
                                                        ts1.MoveWait := timeGetTime();
					        ts1.ATarget := 0;
					        ts1.ATKPer := 100;
					        ts1.DEFPer := 100;
					        ts1.DmgTick := 0;
                                                ts1.Element := ts1.Data.Element;
                                                ts1.isActive := false;

					        for j := 0 to 31 do begin
						        ts1.EXPDist[j].CData := nil;
						        ts1.EXPDist[j].Dmg := 0;
				        	end;

					        if ts1.Data.MEXP <> 0 then begin
						        for j := 0 to 31 do begin
							        ts1.MVPDist[j].CData := nil;
							        ts1.MVPDist[j].Dmg := 0;
						        end;
						        ts1.MVPDist[0].Dmg := ts1.Data.HP * 30 div 100; //FA��30%���Z
					        end;

					        ts1.isSummon := true;
                                                ts1.isSlave := true;
                                                tm.Mob.AddObject(ts1.ID, ts1);
					        tm.Block[ts1.Point.X div 8][ts1.Point.Y div 8].Mob.AddObject(ts1.ID, ts1);

                                                for j := ts1.Point.Y div 8 - 2 to ts1.Point.Y div 8 + 2 do begin
		                                        for m := ts1.Point.X div 8 - 2 to ts1.Point.X div 8 + 2 do begin

			                                        for k := 0 to tm.Block[m][j].CList.Count - 1 do begin
				                                        tc := tm.Block[m][j].CList.Objects[k] as TChara;
				                                        if tc = nil then continue;
                                                                        if (abs(ts1.Point.X - tc.Point.X) < 16) and (abs(ts1.Point.Y - tc.Point.Y) < 16) then begin
					                                        SendMData(tc.Socket, ts1);
                                                                                SendBCmd(tm,ts1.Point,41,tc,False);
				                                        end;
                                                                end;
		                                        end;
	                                        end;
                                                h := h - 1;
                                        end;
                                end;
                        until (h <= 0);

                        end;
                end;
        end;

end;
//------------------------------------------------------------------------------
procedure MobSkillCalc(tm:TMap;ts:TMob;Tick:cardinal);

var
        tsAI :TMobAIDB;
        skillSlot :integer;

begin
    for skillSlot := 0 to 10 do begin
        tsAI := MobAIDB.Objects[skillSlot] as TMobAIDB;
        if tsAI.ID = ts.Data.ID then MobSkillChance(tm, ts, tsAI, Tick);
    end;
end;
//------------------------------------------------------------------------------

procedure MobSkillChance(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);

var
        tc:TChara;


begin
        if tsAI.Skill[0] <> 0 then begin
                if tsAI.PercentChance[0] > Random(100) then begin
                        DebugOut.Lines.Add('Success');
                        MobSkills(tm, ts, tsAI, Tick);
                end else DebugOut.Lines.Add('Fail');;
        end;
end;

//------------------------------------------------------------------------------

procedure MobSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
var
tc  :TChara;
begin
        tc := ts.AData;
        case tsAI.Skill[0] of
                28:     {Heal}
                begin
                        dmg[0] := (ts.Data.LV + 10);
                        ts.HP := ts.HP + dmg[0];
                        if ts.HP > ts.Data.HP then ts.HP := ts.Data.HP;

                        WFIFOW( 0, $011a);
                        WFIFOW( 2, tsAI.Skill[0]);
                        WFIFOW( 4, dmg[0]);
                        WFIFOL( 6, ts.ID);
                        WFIFOL(10, ts.ID);
                        WFIFOB(14, 1);
                        SendBCmd(tm, ts.Point, 15);
                end;
                57:     {Brandish Spear}
                begin
                        MobSkillDamageCalc(tm, tc, ts, tsAI, Tick);
                        if dmg[0] < 0 then dmg[0] := 0;
                        dmg[0] := dmg[0] * tc.Skill[57].Data.Data1[tsAI.SkillLV[0]] div 100;
                        tc.HP := tc.HP - dmg[0];
                end;
        end;
        WFIFOW( 0, $011a);
        WFIFOW( 2, tsAI.Skill[0]);
        WFIFOW( 4, dmg[0]);
        WFIFOL( 6, tc.ID);
        WFIFOL(10, ts.ID);
        WFIFOB(14, 1);
        SendBCmd(tm, tc.Point, 15);

end;

//------------------------------------------------------------------------------

procedure MobSkillDamageCalc(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
        var
	i,j,k     :integer;
	miss      :boolean;
	crit      :boolean;
	avoid     :boolean; //���S���
	i1,j1,k1  :integer;
	xy        :TPoint;
	ts1       :TMob;
	tn        :TNPC;
begin
	if tc.TargetedTick <> Tick then begin
		if DisableFleeDown then begin
			tc.TargetedFix := 10;
			tc.TargetedTick := Tick;
		end else begin
			i := 0;
			xy := tc.Point;
			for j1 := xy.Y div 8 - 2 to xy.Y div 8 + 2 do begin
				for i1 := xy.X div 8 - 2 to xy.X div 8 + 2 do begin
					for k1 := 0 to tm.Block[i1][j1].Mob.Count - 1 do begin
            if (tm.Block[i1][j1].Mob.Objects[k1] is TMob) then begin
						ts1 := tm.Block[i1][j1].Mob.Objects[k1] as TMob;
						if (tc.ID = ts1.ATarget) and (abs(ts1.Point.X - tc.Point.X) <= ts1.Data.Range1) and
							 (abs(ts1.Point.Y - tc.Point.Y) <= ts1.Data.Range1) then Inc(i);
					end;
				end;
			end;
			end;
			//DebugOut.Lines.Add('Targeted: ' + inttostr(i));
			if i > 12 then i := 12;
			if i < 2 then i := 2;
			tc.TargetedFix := 12 - i;
			tc.TargetedTick := Tick;
		end;
	end;

	with ts.Data do begin
                //MobSkillCalc(tm,ts,Tick);

		i := HIT - (tc.FLEE1 * tc.TargetedFix div 10) + 80;
		i := i - tc.FLEE2;
		if i < 5 then i := 5
		else if i > 95 then i := 95;

		dmg[6] := i;
		//crit := boolean((SkillPer = 0) and (Random(100) < Critical));
		crit := false;
		//avoid := boolean((SkillPer = 0) and (Random(100) < tc.Lucky));
		miss := boolean((Random(100) >= i) and (not crit));

                //Shield Reflect
                {if ((miss = False) and (tc.Skill[252].Tick > Tick)) then begin
                                tc.MSkill := 252;
                                dmg[0] := (dmg[0] * tc.Skill[252].Effect1) div 100;
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, tc.MSkill);
                                WFIFOW( 4, tc.MUseLV);
                                WFIFOL( 6, tc.ID);
                                WFIFOL(10, tc.ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, tc.Point, 15);
                                WFIFOW( 0, $008a);
                                WFIFOL( 2, tc.ID);
                                WFIFOL( 6, ts.ID);
                                WFIFOL(10, timeGetTime());
                                WFIFOL(14, tc.aMotion);
                                WFIFOL(18, ts.Data.dMotion);
                                WFIFOW(22, dmg[0]); //�_���[�W
                                WFIFOW(24, 1); //������
                                WFIFOB(26, 0); //0=�P�U�� 8=���� 10=�N���e�B�J��
                                WFIFOW(27, 0); //�t��
                                SendBCmd(tm, ts.Point, 29);
                                SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], 1, 6);
                                if not DamageProcess1(tm, tc, ts, dmg[0], Tick) then
                                StatCalc1(tc, ts, Tick);
                                dmg[0] := 0;
                                dmg[5] := 11;
                end;

                if tc.AnolianReflect then begin
                      dmg[0] := (dmg[0] * 10) div 100;
                      if not DamageProcess1(tm, tc, ts, dmg[0], Tick) then
                      StatCalc1(tc, ts, Tick);
                      dmg[0] := 0;
                      dmg[5] := 11;
                end;

                //Poison React
                if ((miss = False) and (tc.Skill[139].Tick > Tick) and (ts.Data.Element = 25)) then begin
                                DamageCalc1(tm, tc, ts, Tick, 0, 0, 0, 20);
                                tc.MSkill := 139;
                                dmg[0] := (dmg[0] * tc.Skill[139].Effect1) div 100;
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, tc.MSkill);
                                WFIFOW( 4, tc.MUseLV);
                                WFIFOL( 6, tc.ID);
                                WFIFOL(10, tc.ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, tc.Point, 15);
                                WFIFOW( 0, $008a);
                                WFIFOL( 2, tc.ID);
                                WFIFOL( 6, ts.ID);
                                WFIFOL(10, timeGetTime());
                                WFIFOL(14, tc.aMotion);
                                WFIFOL(18, ts.Data.dMotion);
                                WFIFOW(22, dmg[0]); //�_���[�W
                                WFIFOW(24, 1); //������
                                WFIFOB(26, 0); //0=�P�U�� 8=���� 10=�N���e�B�J��
                                WFIFOW(27, 0); //�t��
                                SendBCmd(tm, ts.Point, 29);
                                SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], 1, 6);
                                if not DamageProcess1(tm, tc, ts, dmg[0], Tick) then
                                StatCalc1(tc, ts, Tick);
                                dmg[0] := 0;
                                dmg[5] := 11;
                end; }

                //From mWeiss

		i1 := 0;
		while (i1 >= 0) and (i1 < tm.Block[tc.Point.X div 8][tc.Point.Y div 8].NPC.Count) do begin
			tn := tm.Block[tc.Point.X div 8][tc.Point.Y div 8].NPC.Objects[i1] as TNPC;
			if tn = nil then begin
				Inc(i1);
				continue;
			end;
			if (tc.Point.X = tn.Point.X) and (tc.Point.Y = tn.Point.Y) then begin
				case tn.JID of
				$7e: //�Z�C�t�e�B�E�H�[��
					begin
						miss := true;
						if not avoid then Dec(tn.Count);
						if tn.Count = 0 then begin
							DelSkillUnit(tm, tn);
							Dec(i1);
						end;
						//DebugOut.Lines.Add('Safety Wall OK >>' + IntToStr(tn.Count));
						dmg[6] := 0;
					end;
				$85: //�j���[�}
					begin
						if ts.Data.Range1 >= 4 then miss := true;
						//DebugOut.Lines.Add('Pneuma OK');
						dmg[6] := 0;
					end;
				end;
			end;
			Inc(i1);
		end;

		if crit then dmg[5] := 10 else dmg[5] := 0; //�N���e�B�J���`�F�b�N
		//VIT�{�[�i�X�Ƃ��v�Z
		j := ((tc.Param[2] div 2) + (tc.Param[2] * 3 div 10));
		k := ((tc.Param[2] div 2) + (tc.Param[2] * tc.Param[2] div 150 - 1));
		if j > k then k := j;
		if tc.Skill[33].Tick > Tick then begin //�G���W�F���X
			k := k * tc.Skill[33].Effect1 div 100;
		end;

		dmg[1] := ATK1 + Random(ATK2 - ATK1 + 1);
		if (ts.Stat2 and 1) = 1 then dmg[1] := dmg[1] * 75 div 100;
		//�I�[�g_�o�[�T�[�N
		if (tc.Skill[146].Lv <> 0) and (tc.HP * 100 / tc.MAXHP <= 25) then dmg[0] := (dmg[1] * (100 - (tc.DEF1 * word(tc.Skill[6].Data.Data2[10]) div 100)) div 100 - k) * ts.ATKPer div 100
		else dmg[0] := (dmg[1] * (100 - tc.DEF1) div 100 - k) * ts.ATKPer div 100;
		if Race = 1 then dmg[0] := dmg[0] - tc.DEF3; //DP
		if dmg[0] < 0 then dmg[0] := 1;

		//if SkillPer <> 0 then dmg[0] := dmg[0] * SkillPer div 100; //Skill%
		//dmg[0] := dmg[0] * ElementTable[AElement][ts.Data.Element] div 100; //���������␳

		//�J�[�h�␳
		dmg[0] := dmg[0] * (100 - tc.DamageFixR[1][ts.Data.Race] )div 100;
		//dmg[0] := dmg[0] * tc.DEFFixE[ts.Data.Element mod 20] div 100;

                {//Auto Gaurd
                if ((miss = False) and (tc.Skill[249].Tick > Tick)) then begin
                        miss := boolean(Random(100) <= tc.Skill[249].Effect1);
                        if (miss = True) then begin
                                tc.MSkill := 249;
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, tc.MSkill);
                                WFIFOW( 4, tc.MUseLV);
                                WFIFOL( 6, tc.ID);
                                WFIFOL(10, tc.ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, tc.Point, 15);
                                SendCSkillAtk1(tm, tc, ts, Tick, 0, 1, 6);
                                tc.MTick := Tick + 3000;
                        end;
                end; }

                //Dragonology
                if (tc.Skill[284].Lv <> 0) and (ts.Data.Race = 9) then begin
                        dmg[0] := (dmg[0] - dmg[0] * tc.Skill[284].Data.Data1[tc.Skill[284].Lv]) div 100;
                end;

                //Providence
                if (tc.Skill[256].Tick > Tick) and ((ts.Data.Race = 1) or (ts.Data.Race = 6) or (ts.Data.Race = 8)) then begin
                        i := (dmg[0] * tc.Skill[256].Data.Data2[tc.Skill[256].Lv]) div 100;
                        dmg[0] := dmg[0] - i;
                end;

                {if tc.Skill[61].Tick > Tick then begin //AC
                        tc.AMode := 8;
                        tc.ATarget := ts.ID;
                        DamageCalc1(tm, tc, ts, Tick, 0, 0, 0, 20);
                        if dmg[0] < 0 then dmg[0] := 0; //�����U���ł̉񕜂͖�����
                        //�p�P���M
                        WFIFOW( 0, $008a);
                        WFIFOL( 2, tc.ID);
                        WFIFOL( 6, tc.ATarget);
                        WFIFOL(10, timeGetTime());
                        WFIFOL(14, tc.aMotion);
                        WFIFOL(18, ts.Data.dMotion);
                        WFIFOW(22, dmg[0]); //�_���[�W
                        WFIFOW(24, 1); //������
                        WFIFOB(26, 0); //0=�P�U�� 8=���� 10=�N���e�B�J��
                        WFIFOW(27, 0); //�t��
                        SendBCmd(tm, ts.Point, 29);
                        DamageProcess1(tm, tc, ts, dmg[0], Tick);
                        StatCalc1(tc, ts, Tick);
                        tc.Skill[61].Tick := Tick;
                        tc.AMode := 0;
                        dmg[0] := 0;
                        dmg[5] := 11;
                end else if avoid then begin
                        dmg[0] := 0;
			dmg[5] := 11;
		end else if not miss then begin
			//�U������
			if dmg[0] <> 0 then begin
				if tc.Skill[157].Tick > Tick then begin //�G�l���M�[�R�[�g
					if (tc.SP * 100 / tc.MAXSP) < 1 then tc.SP := 0;
				   	if tc.SP > 0 then begin
						i := 1;
						if (tc.SP * 100 / tc.MAXSP) > 20 then i := 2;
						if (tc.SP * 100 / tc.MAXSP) > 40 then i := 3;
						if (tc.SP * 100 / tc.MAXSP) > 60 then i := 4;
						if (tc.SP * 100 / tc.MAXSP) > 80 then i := 5;
						dmg[0] := dmg[0] - ((dmg[0] * i * 6) div 100);
						tc.SP := tc.SP - (tc.MAXSP * (i + 1) * 5) div 1000;
                                        end;
                                end else if (tc.Skill[257].Tick > Tick) then begin //Defender
                                                i := (dmg[0] * tc.Skill[257].Data.Data2[tc.Skill[257].Lv]) div 100;
                                                dmg[0] := dmg[0] - i;
                                                tc.MSkill := 257;
                                                WFIFOW( 0, $011a);
						WFIFOW( 2, tc.MSkill);
						WFIFOW( 4, tc.MUseLV);
						WFIFOL( 6, tc.ID);
						WFIFOL(10, ID);
						WFIFOB(14, 1);
                                end else begin
                                tc.Skill[257].Tick := Tick;
                                tc.Skill[157].Tick := Tick;
                                SendCStat1(tc, 0, 7, tc.SP);
				end;
				tc.MMode := 0;
				tc.MTick := Tick;
				tc.MTarget := 0;
				tc.MPoint.X := 0;
				tc.MPoint.Y := 0;
                        end;
		end else begin
			//�U���~�X
			dmg[0] := 0;
		end;}
		//�����Ő��̂�������ʂ�����(������)

		dmg[4] := 1;
	end;
	//DebugOut.Lines.Add(Format('REV %d%% %d(%d-%d)', [dmg[6], dmg[0], dmg[1], dmg[2]]));
end;


end.


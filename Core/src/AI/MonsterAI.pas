unit MonsterAI;

interface

uses
	Windows, StdCtrls, MMSystem, Classes, SysUtils, ScktComp, List32, Common, Path;

        procedure CalcAI(tm:TMap; ts:TMob; Tick:Cardinal);
        procedure MobSpawn(tm:TMap; ts:TMob; Tick:cardinal);
        procedure MobSkillCalc(tm:TMap;ts:TMob;Tick:cardinal);
        procedure MobSkillChance(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
        procedure MobSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);
        procedure MobFieldSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);
        procedure MobStatSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);
        procedure MobSkillDamageCalc(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
        procedure SendMSkillAttack(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; k:integer; i:integer);

        function MonsterNPCAction(tm:TMap;tn:TNPC;Tick:cardinal) : Integer;
        function DamageProcess2(tm:TMap; tc:TChara; tc1:TChara; Dmg:integer; Tick:cardinal; isBreak:Boolean = True) : Boolean;  {Monster Attacking Player}
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
                MobSkillCalc(tm,ts,Tick);

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
						        ts1.MVPDist[0].Dmg := ts1.Data.HP * 30 div 100; //FAに30%加算
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
        k    :integer;

begin
        k := MobAIDB.IndexOf(ts.Data.ID);
        if (ts.Data.ID <> 0) and (k <> -1) then begin
    //for skillSlot := 0 to 10 do begin
                tsAI := MobAIDB.Objects[k] as TMobAIDB;
                MobSkillChance(tm, ts, tsAI, Tick);
        end;
    //end;
end;
//------------------------------------------------------------------------------

procedure MobSkillChance(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);

var
        //tc:TChara;
        i   :integer;
        j   :integer;

begin
        for j := 0 to 3 do begin
                i := Random(3);
                if tsAI.Skill[i] <> 0 then begin
                        if tsAI.PercentChance[i] > Random(200) then begin
                                //DebugOut.Lines.Add('Success');
                                MobSkills(tm, ts, tsAI, Tick, i);
                                MobFieldSkills(tm, ts, tsAI, Tick, i);
                                MobStatSkills(tm, ts, tsAI, Tick, i);
                                //Break;
                        end;
                        //end else DebugOut.Lines.Add('Fail');
                end;
        end;
end;

//------------------------------------------------------------------------------

procedure MobSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);
var
        tc  :TChara;
        //i   :integer;
begin

        //for i := 0 to 3 do begin
        tc := ts.AData;
        case tsAI.Skill[i] of
                28:     {Heal}
                begin
                        dmg[0] := (ts.Data.LV + 10);
                        ts.HP := ts.HP + dmg[0];
                        if ts.HP > ts.Data.HP then ts.HP := ts.Data.HP;

                        WFIFOW( 0, $011a);
                        WFIFOW( 2, tsAI.Skill[i]);
                        WFIFOW( 4, dmg[0]);
                        WFIFOL( 6, ts.ID);
                        WFIFOL(10, ts.ID);
                        WFIFOB(14, 1);
                        SendBCmd(tm, ts.Point, 15);
                end;
                46:     {Double Strafe}
                begin
                        MobSkillDamageCalc(tm, tc, ts, tsAI, Tick);
                        if dmg[0] < 0 then dmg[0] := 0;
                        dmg[0] := dmg[0] * 2;
                        tc.HP := tc.HP - dmg[0];
                        SendMSkillAttack(tm, tc, ts, tsAI, Tick, 2, i);
                end;
                57:     {Brandish Spear}
                begin
                        MobSkillDamageCalc(tm, tc, ts, tsAI, Tick);
                        if dmg[0] < 0 then dmg[0] := 0;
                        dmg[0] := dmg[0] * tc.Skill[57].Data.Data1[tsAI.SkillLV[i]] div 100;
                        tc.HP := tc.HP - dmg[0];
                        SendMSkillAttack(tm, tc, ts, tsAI, Tick, 1, i);
                end;
        end;

        //end;

end;

//------------------------------------------------------------------------------

procedure MobFieldSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);
var
        tl  :TSkillDB;
        sl  :TStringList;
        tc  :TChara;
        j   :integer;
        AttackData :TChara;
        xy  :TPoint;
	bb  :array of byte;
        tn  :TNPC;

begin

        //for i := 0 to 3 do begin
                tc := ts.AData;
                case tsAI.Skill[i] of
                        83:     {Meteor}
                        begin
                                AttackData := ts.AData;

                                xy.X := AttackData.Point.X;
                                xy.Y := AttackData.Point.Y;

                                //Place the Effect
                                tn := SetSkillUnit(tm, ts.ID, xy, Tick, $88, 0, 3000);

                                tn.MSkill := tsAI.Skill[i];
                                tn.MUseLV := tsAI.SkillLV[i];

                                for j := 1 to tc.Skill[83].Data.Data2[tsAI.SkillLV[i]] do begin;
                                        WFIFOW( 0, $0117);
                                        WFIFOW( 2, tsAI.Skill[i]);
                                        WFIFOL( 4, ts.ID);
                                        WFIFOW( 8, tsAI.SkillLV[i]);
                                        WFIFOW(10, (AttackData.Point.X - 4 + Random(12)));
                                        WFIFOW(12, (AttackData.Point.Y - 4 + Random(12)));
                                        WFIFOL(14, 1);
                                        SendBCmd(tm, xy, 18);
                                end;

                        end;
                end;
        //end;
end;
//------------------------------------------------------------------------------
procedure MobStatSkills(tm:TMap; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; i:integer);

var
ProcessType     :Byte;

begin
with ts do begin
        ProcessType := 0;
        case tsAI.Skill[i] of
                114:    {Power Maximize}
                begin
                        ProcessType := 1;
                end;
        end;

        case ProcessType of
                0:  //Skill Used on Oneself Like Hiding
                        begin
                                //Packet Process
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, tsAI.Skill[i]);
                                WFIFOW( 4, dmg[0]);
                                WFIFOL( 6, ts.ID);
                                WFIFOL(10, ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, ts.Point, 15);
                        end;
                1:  //Skills Like Power Maximize
                        begin
                                WFIFOW( 0, $011a);
                                WFIFOW( 2, tsAI.Skill[i]);
                                WFIFOW( 4, tsAI.SkillLv[i]);
                                WFIFOL( 6, ts.ID);
                                WFIFOL(10, ts.ID);
                                WFIFOB(14, 1);
                                SendBCmd(tm, ts.Point, 15);

                                {if (tc1.MSkill = 51) then begin

                                        if tc1.Option = 6 then begin
                                                tc1.Skill[MSkill].Tick := Tick;
	    					tc1.Option := tc1.Optionkeep;
                                                SkillTick := tc1.Skill[MSkill].Tick;
                                                SkillTickID := MSkill;
                                                tc1.SP := tc1.SP + 10;
                                                tc1.Hidden := false;
                                                if tc1.SP > tc1.MAXSP then tc1.SP := tc1.MAXSP;

                                        end else begin
                                                // Required to place Hide on a timer.
                                                tc1.Skill[MSkill].Tick := Tick + cardinal(tl.Data1[MUseLV]) * 1000;

    						if SkillTick > tc1.Skill[MSkill].Tick then begin
							    SkillTick := tc1.Skill[MSkill].Tick;
							    SkillTickID := MSkill;
    						end;

                                                tc1.Optionkeep := tc1.Option;
                                                tc1.Option := 6;
                                                tc1.Hidden := true;

                                        end;

                                        CalcStat(tc1, Tick);

                                        WFIFOW(0, $0119);
    					WFIFOL(2, tc1.ID);
    					WFIFOW(6, tc1.Stat1);
    					WFIFOW(8, tc1.Stat2);
    					WFIFOW(10, tc1.Option);
    					WFIFOB(12, 0);
    					SendBCmd(tm, tc1.Point, 13);

                                        // Colus, 20031228: Tunnel Drive speed update
                                        if (tc1.Skill[213].Lv <> 0) then begin
    						WFIFOW(0, $00b0);
    						WFIFOW(2, $0000);
    						WFIFOL(4, tc1.Speed);
    						tc1.Socket.SendBuf(buf, 8);
                                        end;

                                end;

                                if (tc1.MSkill = 143) then begin
                                        if tc1.Sit = 1 then begin
						tc1.Sit := 3;
                                                SkillTick := tc1.Skill[MSkill].Tick;
                                                SkillTickID := MSkill;
                                                tc1.SP := tc1.SP + 5;
                                                if tc1.SP > tc1.MAXSP then tc1.SP := tc1.MAXSP;
                                                CalcStat(tc1, Tick);
                                        end else begin
                                                tc1.Sit := 1;
                                        end;
                                end;}

                                if (tsAI.Skill[i] = 114) then begin
                                        DebugOut.Lines.Add('Monster Casts Power Maximize');
                                        {if tc1.Option = 32 then begin
						//tc1.Option := tc1.Optionkeep;
                                                SkillTick := tc1.Skill[MSkill].Tick;
                                                SkillTickID := MSkill;
                                                //CalcMonsterStat(ts, Tick);
                                        end else begin
                                                tc1.Optionkeep := tc1.Option;
                                                tc1.Option := 32;
                                        end; }
                                end;

                        end;
                end;
        end;
end;

//------------------------------------------------------------------------------

procedure MobSkillDamageCalc(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal);
        var
	i,j,k     :integer;
	miss      :boolean;
	crit      :boolean;
	avoid     :boolean; //完全回避
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
                                WFIFOW(22, dmg[0]); //ダメージ
                                WFIFOW(24, 1); //分割数
                                WFIFOB(26, 0); //0=単攻撃 8=複数 10=クリティカル
                                WFIFOW(27, 0); //逆手
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
                                WFIFOW(22, dmg[0]); //ダメージ
                                WFIFOW(24, 1); //分割数
                                WFIFOB(26, 0); //0=単攻撃 8=複数 10=クリティカル
                                WFIFOW(27, 0); //逆手
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
				$7e: //セイフティウォール
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
				$85: //ニューマ
					begin
						if ts.Data.Range1 >= 4 then miss := true;
						//DebugOut.Lines.Add('Pneuma OK');
						dmg[6] := 0;
					end;
				end;
			end;
			Inc(i1);
		end;

		if crit then dmg[5] := 10 else dmg[5] := 0; //クリティカルチェック
		//VITボーナスとか計算
		j := ((tc.Param[2] div 2) + (tc.Param[2] * 3 div 10));
		k := ((tc.Param[2] div 2) + (tc.Param[2] * tc.Param[2] div 150 - 1));
		if j > k then k := j;
		if tc.Skill[33].Tick > Tick then begin //エンジェラス
			k := k * tc.Skill[33].Effect1 div 100;
		end;

		dmg[1] := ATK1 + Random(ATK2 - ATK1 + 1);
		if (ts.Stat2 and 1) = 1 then dmg[1] := dmg[1] * 75 div 100;
		//オート_バーサーク
		if (tc.Skill[146].Lv <> 0) and (tc.HP * 100 / tc.MAXHP <= 25) then dmg[0] := (dmg[1] * (100 - (tc.DEF1 * word(tc.Skill[6].Data.Data2[10]) div 100)) div 100 - k) * ts.ATKPer div 100
		else dmg[0] := (dmg[1] * (100 - tc.DEF1) div 100 - k) * ts.ATKPer div 100;
		if Race = 1 then dmg[0] := dmg[0] - tc.DEF3; //DP
		if dmg[0] < 0 then dmg[0] := 1;

		//if SkillPer <> 0 then dmg[0] := dmg[0] * SkillPer div 100; //Skill%
		//dmg[0] := dmg[0] * ElementTable[AElement][ts.Data.Element] div 100; //属性相性補正

		//カード補正
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
                        if dmg[0] < 0 then dmg[0] := 0; //属性攻撃での回復は未実装
                        //パケ送信
                        WFIFOW( 0, $008a);
                        WFIFOL( 2, tc.ID);
                        WFIFOL( 6, tc.ATarget);
                        WFIFOL(10, timeGetTime());
                        WFIFOL(14, tc.aMotion);
                        WFIFOL(18, ts.Data.dMotion);
                        WFIFOW(22, dmg[0]); //ダメージ
                        WFIFOW(24, 1); //分割数
                        WFIFOB(26, 0); //0=単攻撃 8=複数 10=クリティカル
                        WFIFOW(27, 0); //逆手
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
			//攻撃命中
			if dmg[0] <> 0 then begin
				if tc.Skill[157].Tick > Tick then begin //エネルギーコート
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
			//攻撃ミス
			dmg[0] := 0;
		end;}
		//ここで星のかけら効果を入れる(未実装)

		dmg[4] := 1;
	end;
	//DebugOut.Lines.Add(Format('REV %d%% %d(%d-%d)', [dmg[6], dmg[0], dmg[1], dmg[2]]));
end;

//------------------------------------------------------------------------------
procedure SendMSkillAttack(tm:TMap; tc:TChara; ts:TMob; tsAI:TMobAIDB; Tick:cardinal; k:integer; i:integer);

begin
        WFIFOW( 0, $01de);
	WFIFOW( 2, tsAI.Skill[i]);
	WFIFOL( 4, ts.ID);
	WFIFOL( 8, tc.ID);
	WFIFOL(12, Tick);
	//WFIFOL(16, tc.aMotion);
	//WFIFOL(20, ts.Data.dMotion);
        WFIFOL(16, ts.Data.dMotion);
	WFIFOL(20, tc.aMotion);
	WFIFOL(24, dmg[0]);
	WFIFOW(28, tsAI.SkillLV[i]);
	WFIFOW(30, k);
        WFIFOB(32, 6);
	//else               WFIFOB(32, 8);
	//if ts.Stat1 = 5 then dmg := dmg * 2; //レックス_エーテルナ
	SendBCmd(tm, tc.Point, 33);
end;
//------------------------------------------------------------------------------
function MonsterNPCAction(tm:TMap; tn:TNPC; Tick:cardinal) : Integer;

var
	k,m,c,c1: Integer;
	i,j:Integer;
	i1,j1,k1:integer;
	i2,j2,k2:integer;
        p1,p2:integer;
	tc1:TChara;
        ts:TMob;
	ts1:TMob;
        tc2:TChara;
	tl	:TSkillDB;
	xy:TPoint;
        b:integer;
	bb:array of byte;
	sl:TStringList;
        sl2:TStringList;
	flag:Boolean;
        mi :MapTbl;
        tsAI :TMobAIDB;

begin
        mi := MapInfo.Objects[MapInfo.IndexOf(tm.Name)] as MapTbl;
	k := 0;
	if (tn.CType = 3) and (tn.Tick <= Tick) then begin
                if tn.JID  = $F1 then begin
                        WFIFOW(0, $00a1);
		        WFIFOL(2, 1118);
		        SendBCmd(tm, tn.Point, 6);
                        with tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC do
			        Delete(IndexOf(1118));
                        tn.Free;
                end;
		//アイテム撤去
		WFIFOW(0, $00a1);
		WFIFOL(2, tn.ID);
		SendBCmd(tm, tn.Point, 6);
		//アイテム削除
		tm.NPC.Delete(tm.NPC.IndexOf(tn.ID));
		with tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC do
			Delete(IndexOf(tn.ID));
			tn.Free;
	end else if (tn.CType = 4) then begin //スキル効能地
		if tn.Tick <= Tick then begin
			case tn.JID of
                                141:
                                        begin
						DelSkillUnit(tm, tn);
						Dec(k);
                        			tm.gat[tn.Point.X][tn.Point.Y] := 0;
                    			end;
				$81://ポータル発動前->発動後
					begin
						tn.JID := $80;
						WFIFOW(0, $00c3);
						WFIFOL(2, tn.ID);
						WFIFOB(6, 0);
						WFIFOB(7, tn.JID);
						SendBCmd(tm, tn.Point, 8);
						tn.Tick := Tick + 20000;
					end;
				$8F://ブラスト発動前
					begin
						tn.JID := $74;
						WFIFOW(0, $00c3);
						WFIFOL(2, tn.ID);
						WFIFOB(6, 0);
						WFIFOB(7, tn.JID);
						SendBCmd(tm, tn.Point, 8);
						tn.Tick := Tick + 2000;
					end;
				else
					begin
						//スキル効能地撤去
						DelSkillUnit(tm, tn);
						Dec(k);
					end;
			end;
		end else begin
			//スキル効能地効果 Chara踏み型
			c := 0;
			while (c >= 0) and (c < tm.Block[tn.Point.X div 8][tn.Point.Y div 8].CList.Count) do begin
				tc1 := tm.Block[tn.Point.X div 8][tn.Point.Y div 8].CList.Objects[c] as TChara;
				Inc(c);
				if tc1 = nil then continue;
				if (tc1.pcnt = 0) and (tc1.Point.X = tn.Point.X) and (tc1.Point.Y = tn.Point.Y) then begin
					case tn.JID of
						$80: //ポータル発動後
							begin
                                                                {チャットルーム機能追加}
								if (tc1.ChatRoomID <> 0) then continue;
                                                                {チャットルーム機能追加ココまで}
								SendCLeave(tc1, 0);
								tc1.tmpMap := tn.WarpMap;
								tc1.Point := tn.WarpPoint;
								MapMove(tc1.Socket, tn.WarpMap, tn.WarpPoint);
								Dec(tn.Count);
								if tn.Count = 0 then begin //ここの処理がうまくいくかどうか謎
									DelSkillUnit(tm, tn);
									Dec(k);
									c := -1;
									continue;
								end else begin
									Dec(c);
								end;
							end;
					end;
				end;
			end;

			ts := tn.MData;
			tl := SkillDB.IndexOfObject(tn.MSkill) as TSkillDB;
			if tl <> nil then begin
				m := tl.Range2;
			end else begin
				m := 0;
			end;

                        sl2 := TStringList.Create;
                        for p1 := (tn.Point.Y - m) div 8 to (tn.Point.Y + m) div 8 do begin
				for i1 := (tn.Point.X - m) div 8 to (tn.Point.X + m) div 8 do begin
					for c1 := 0 to tm.Block[i1][p1].Clist.Count -1 do begin
                                                if (tm.Block[i1][p1].Clist.Objects[c1] is TChara) then begin
						tc2 := tm.Block[i1][p1].CList.Objects[c1] as TChara;
						if tc2 = nil then Continue;
						if (abs(tc2.Point.X - tn.Point.X) <= m) and (abs(tc2.Point.Y - tn.Point.Y) <= m) then
							sl2.AddObject(IntToStr(tc2.ID),tc2);
						if (tc2.Point.X = tn.Point.X) and (tc2.Point.Y = tn.Point.Y) then
							flag := True;
					end;
				end;
			end;
			end;
                        if sl2.Count <> 0 then begin
                                for c1 := 0 to sl2.Count - 1 do begin
                                        tc2 := sl2.Objects[c1] as TChara;
                                        case tn.JID of

                                                $74://ブラストマイン発動
							begin
								dmg[0] := (tc1.Param[4] + 75) * (100 + tc1.Param[3]) div 100;
								dmg[0] := dmg[0] * tn.Count;
								if dmg[0] < 0 then dmg[0] := 0; //魔法攻撃での回復は未実装
								tn.Tick := Tick;
								WFIFOW( 0, $01de);
								WFIFOW( 2, $74);
								WFIFOL( 4, tn.ID);
								WFIFOL( 8, tc2.ID);
								WFIFOL(12, Tick);
								WFIFOL(16, tc1.aMotion);
								WFIFOL(20, tc2.dMotion);
								WFIFOL(24, dmg[0]);
								WFIFOW(28, tn.Count);
								WFIFOW(30, 1);
								WFIFOB(32, 5);
								SendBCmd(tm, tn.Point, 33);
								DamageProcess2(tm, tc1, tc2, dmg[0], tick);
							end;

						$86: //LoV
							begin
								if (tn.Tick + 1000 * tn.Count) < (Tick + 3000) then begin
									//dmg[0] := tc1.MATK1 + Random(tc1.MATK2 - tc1.MATK1 + 1) * tc1.MATKFix div 100 * tl.Data1[tn.MUseLV] div 100;
									//dmg[0] := dmg[0] * (100 - tc2.MDEF1 + tc2.MDEF2) div 100; //MDEF%
									//dmg[0] := dmg[0] - tc2.Param[3]; //MDEF-
									if dmg[0] < 1 then dmg[0] := 1;
									dmg[0] := dmg[0] * tl.Data2[tn.MUseLV];
									if dmg[0] < 0 then dmg[0] := 0; //魔法攻撃での回復は未実装
									WFIFOW( 0, $01de);
									WFIFOW( 2, 85);
									WFIFOL( 4, tn.ID);
									WFIFOL( 8, tc2.ID);
									WFIFOL(12, Tick);
									WFIFOL(16, tc1.aMotion);
									WFIFOL(20, tc2.dMotion);
									WFIFOL(24, dmg[0]);
									WFIFOW(28, tn.MUseLV);
									WFIFOW(30, tl.Data2[tn.MUseLV]);
									WFIFOB(32, 8);
									SendBCmd(tm, tn.Point, 33);
									DamageProcess2(tm,tc1,tc2,dmg[0],tick);
									if c1 = (sl2.Count -1) then begin
										Inc(tn.Count);	//Countを発動発数とSkillLVに使用
										if tn.Count = 3 then tn.Tick := Tick
									end;
								end;
							end;
						$87: //FP
							begin
								//DebugOut.Lines.Add('Hit') ;
								{if not flag then Break;} //踏んでない
								tn.Tick := Tick;
								dmg[0] := (tc1.MATK1 + Random(tc1.MATK2 - tc1.MATK1 + 1)) * tc1.MATKFix div 500 + 50;
								if dmg[0] < 51 then dmg[0] := 51;
								dmg[0] := dmg[0] * tl.Data2[tn.Count];
								if dmg[0] < 0 then dmg[0] := 0; //魔法攻撃での回復は未実装
								//無理やりエフェクトを出してみる
								{SetSkillUnit(tm,tc1.ID,tn.Point,Tick,$88,0,4000);}

								WFIFOW( 0, $01de);
								WFIFOW( 2, tn.JID);
								WFIFOL( 4, tn.ID);
								WFIFOL( 8, tc2.ID);
								WFIFOL(12, Tick);
								WFIFOL(16, tc1.aMotion);
								WFIFOL(20, tc2.dMotion);
								WFIFOL(24, dmg[0]);
								WFIFOW(28, tn.Count);
								WFIFOW(30, tl.Data2[tn.Count]);
								WFIFOB(32, 8);
								SendBCmd(tm, tn.Point, 33);
								DamageProcess2(tm,tc1,tc2,dmg[0],Tick);
							end;

                                                $88: //Meteor
							begin
								if (tn.Tick + 1000 * tn.Count) < (Tick + 3000) then begin
									//dmg[0] := tc1.MATK1 + Random(tc1.MATK2 - tc1.MATK1 + 1) * tc1.MATKFix div 100 * tl.Data1[tn.MUseLV] div 100;
									//dmg[0] := dmg[0] * (100 - tc2.MDEF1 + tc2.MDEF2) div 100; //MDEF%
									//dmg[0] := dmg[0] - tc2.Param[3]; //MDEF-
                                                                        MobSkillDamageCalc(tm, tc2, tn.MData, tsAI, Tick);
									if dmg[0] < 1 then dmg[0] := 1;
									dmg[0] := dmg[0] * tl.Data2[tn.MUseLV];
									if dmg[0] < 0 then dmg[0] := 0; //魔法攻撃での回復は未実装
									WFIFOW( 0, $01de);
									WFIFOW( 2, 83);
									WFIFOL( 4, tn.ID);
									WFIFOL( 8, tc2.ID);
									WFIFOL(12, Tick);
									WFIFOL(16, tc1.aMotion);
									WFIFOL(20, tc2.dMotion);
									WFIFOL(24, dmg[0]);
									WFIFOW(28, tn.MUseLV);
									WFIFOW(30, tl.Data2[tn.MUseLV]);
									WFIFOB(32, 8);
                                                                        SendBCmd(tm, tn.Point, 33);
									DamageProcess2(tm,tc1,tc2,dmg[0],tick);
									if c1 = (sl2.Count -1) then begin
										Inc(tn.Count);	//Countを発動発数とSkillLVに使用
										if tn.Count = 3 then tn.Tick := Tick
									end;
								end;
                                                        end;
                                                end;
                                        end;
                                end;
                        end;
                end;
        end;


function DamageProcess2(tm:TMap; tc:TChara; tc1:TChara; Dmg:integer; Tick:cardinal; isBreak:Boolean = True) : Boolean;  {Monster Attacking Player}
var
        {Random Variables}
	i :integer;
        w :Cardinal;
begin
	if tc1.HP < Dmg then Dmg := tc1.HP;  //Damage Greater than Player's Life

  if Dmg = 0 then begin  //Miss, no damage
		Result := False;
		Exit;
	end else begin
    // AlexKreuz: Hidden character unhides when they
    // get hit.
    if tc1.Skill[51].Tick > Tick then begin
      tc1.Skill[51].Tick := Tick;
      tc1.SkillTick := Tick;
    end;
  end;

	if (tc1.Stat1 <> 0) then tc1.BodyTick := Tick + tc.aMotion;

	WFIFOW(0, $0088);
	WFIFOL(2, tc1.ID);
	WFIFOW(6, tc1.Point.X);
	WFIFOW(8, tc1.Point.Y);
	SendBCmd(tm, tc1.Point, 10);

	tc1.HP := tc1.HP - Dmg;
        SendCStat1(tc1, 0, 5, tc1.HP);
	//for i := 0 to 31 do begin
		//if (ts.EXPDist[i].CData = nil) or (ts.EXPDist[i].CData = tc) then begin
			//ts.EXPDist[i].CData := tc;
			//Inc(ts.EXPDist[i].Dmg, Dmg);
			//break;
		//end;
	//end;
	//if ts.Data.MEXP <> 0 then begin
		//for i := 0 to 31 do begin
			//if (ts.MVPDist[i].CData = nil) or (ts.MVPDist[i].CData = tc) then begin
				//ts.MVPDist[i].CData := tc;
				//Inc(ts.MVPDist[i].Dmg, Dmg);
				//break;
			//end;
		//end;
	//end;

	if tc1.HP > 0 then begin
		if EnableMonsterKnockBack then begin
			tc1.pcnt := 0;
			if tc1.ATarget = 0 then begin
				w := Tick + tc1.dMotion + tc.aMotion;
				tc1.ATick := Tick + tc1.dMotion + tc.aMotion;
			end else begin
				w := Tick + tc1.dMotion div 2;
			end;
			if w > tc1.DmgTick then tc1.DmgTick := w;
		end else begin
			if tc1.ATarget = 0 then tc1.ATick := Tick;
			if tc1.ATarget <> tc.ID then
				tc1.pcnt := 0
			else if tc1.pcnt <> 0 then begin
				//DebugOut.Lines.Add('Character Knockback!');
				//SendMMove(tc.Socket, ts, ts.Point, ts.tgtPoint,tc.ver2);
				SendBCmd(tm, tc1.Point, 58, tc,True);
			end;
			tc1.DmgTick := 0;
		end;
		//ts.ATarget := tc.ID;
		//ts.AData := tc;
		//ts.isLooting := False;

		Result := False;
	end else begin
                tc1.Sit := 1;
                tc1.HP := 0;
                SendCStat1(tc1, 0, 5, tc1.HP);
                WFIFOW(0, $0080);
                WFIFOL(2, tc1.ID);
                WFIFOB(6, 1);
                tc1.Socket.SendBuf(buf, 7);
                WFIFOW( 0, $0080);
                WFIFOL( 2, tc1.ID);
                WFIFOB( 6, 1);
                 SendBCmd(tm, tc1.Point, 7);
		Result := True;
	end;
end;

end.


unit Player_Skills;

interface

uses
	IniFiles, Classes, SysUtils, Common, List32, MMSystem, Math, Path, Windows;

var
	SKILL_TYPE : Byte;
    {
    	1: Process Effect
        2: Process Skill Attack
    }

    procedure parse_skills(tc : TChara; Tick : Cardinal; passive : boolean = false);

    procedure process_effect(tc : TChara; success : Integer);
    procedure process_skill_attack(tc : TChara; j : Integer; Tick : Cardinal);
    procedure process_skill_splash_attack(tc : TChara; j : Integer; Tick : Cardinal);

    procedure use_sp(tc : TChara; SkillID : word; LV : byte);

    function skill_sword_mastery(tc : TChara) : Integer;
	function skill_two_handed_sword_mastery(tc : TChara) : Integer;
    function skill_hp_recovery(tc : TChara; Tick : Cardinal) : Integer;
    function skill_bash(tc : TChara; Tick : Cardinal) : Integer;
	function skill_provoke(tc : TChara) : Integer;
    function skill_magnum_break(tc : TChara; Tick : Cardinal) : Integer;

    function skill_double_strafe(tc : TChara; Tick : Cardinal) : Integer;

implementation

uses
	Main, Skills;

	procedure parse_skills(tc : TChara; Tick : Cardinal; passive : boolean = false);
    var
    	success : Integer;
    begin
    	SKILL_TYPE := 0;

        if (tc.HP <= 0) then passive := False;

        {
        	tc.Skill[x].LV must be used for effect skills that have no target.
            tc.MSkill must be used for active skills that have a target.
            tc.Skill[x].LV must be used for passive skills. Also, passive must be true.
        }

        { 2} if (tc.Skill[2].Lv <> 0) then success := skill_sword_mastery(tc);
		{ 3} if (tc.Skill[3].Lv <> 0) then success := skill_two_handed_sword_mastery(tc);
        { 4} if (tc.Skill[4].Lv <> 0) and (passive) then success := skill_hp_recovery(tc, Tick);
        { 5} if (tc.MSkill = 5) then success := skill_bash(tc, Tick);
        { 6} if (tc.MSkill = 6) then success := skill_provoke(tc);
        { 7} if (tc.MSkill = 7) then success := skill_magnum_break(tc, Tick);
        {46} if (tc.MSkill = 46) then success := skill_double_strafe(tc, Tick);

        {
	        Process_Effect Success Codes:
    	    -1 : Success
        	0 : Skill Failed
	        1 : Not enough SP
    	    2 : Not enough HP
	        3 : No memo
    	    4 : In cast delay
	        5 : Not enough money
    	    6 : Weapon is not usable with the skill
	        7 : No red gemstone
    	    8 : No blue gemstone
	        9 : No yellow gemstone
        }

        case SKILL_TYPE of
        	1: process_effect(tc, success);
            2: process_skill_attack(tc, success, Tick);
            3: process_skill_splash_attack(tc, success, Tick);
        end;

        if ( (SKILL_TYPE = 1) and (success = -1) ) or (SKILL_TYPE = 2) or (SKILL_TYPE = 3) then begin
        	use_sp(tc, tc.MSkill, tc.MUseLV);
        end;

        SKILL_TYPE := 0;
	end;

	procedure process_effect(tc : TChara; success : Integer);
    var
    	tm : TMap;
        tc1 : TChara;
        ts : TMob;
    begin
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;

        if (success = -1) then begin
	    	WFIFOW( 0, $011a);
		    WFIFOW( 2, tc.MSkill);
    		WFIFOW( 4, tc.MUseLV);
		    WFIFOL( 6, tc.MTarget);
	    	WFIFOL(10, tc.ID);
		    WFIFOB(14, 1);
        end else begin
        	WFIFOW( 0, $0110);
        	WFIFOW( 2, tc.MSkill);
        	WFIFOW( 4, 0);
        	WFIFOW( 6, 0);
        	WFIFOB( 8, 0);
        	WFIFOB( 9, success);
        end;

        if tc.MTargetType = 0 then begin
            ts := tc.AData;
            if (ts.HP <= 0) and (success = -1) then begin
            	SKILL_TYPE := 0;
                Exit;
            end;
            
        	SendBCmd(tm, ts.Point, 15);
        end else begin
            tc1 := tc.AData;
            if (ts.HP <= 0) and (success = -1) then begin
            	SKILL_TYPE := 0;
            	Exit;
            end;
            
	        SendBCmd(tm, tc1.Point, 15);
        end;
    end;

    procedure process_skill_attack(tc : TChara; j : Integer; Tick : Cardinal);
    var
    	ts : TMob;
        tc1 : TChara;
        tm : TMap;
        tl : TSkillDB;
    begin

        { Placed here to prevent attacking self }
        if tc.AData = tc then Exit;

    	if dmg[0] < 0 then dmg[0] := 0;
		if tc.MTargetType = 0 then begin
			ts := tc.AData;
            if ts.HP <= 0 then begin
            	SKILL_TYPE := 0;
                Exit;
            end;

			SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], j);
			if not frmMain.DamageProcess1(tm, tc, ts, dmg[0], Tick) then frmMain.StatCalc1(tc, ts, Tick);
		end else begin
			tc1 := tc.AData;
            if tc1.HP <= 0 then begin
            	SKILL_TYPE := 0;
            	Exit;
            end;

			SendCSkillAtk2(tm, tc, tc1, Tick, dmg[0], j);
			if not frmMain.DamageProcess2(tm, tc, tc1, dmg[0], Tick) then frmMain.StatCalc2(tc, tc1, Tick);
		end;
    end;

    procedure process_skill_splash_attack(tc : TChara; j : Integer; Tick : Cardinal);
    var
    	j1, i1, k1 : Integer;
        tm : TMap;
        tl : TSkillDB;
        xy : TPoint;
        tx, ts : TMob;
        tc1 : TChara;
        sl : TStringList;
        mi : MapTbl;
    begin
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        mi := MapInfo.Objects[MapInfo.IndexOf(tm.Name)] as MapTbl;
        tl := tc.Skill[tc.MSkill].Data;

        sl := TStringList.Create;
        tc1 := tc.AData;
        xy := tc1.Point;

        for j1 := (xy.Y - tl.Range2) div 8 to (xy.Y + tl.Range2) div 8 do begin
        	for i1 := (xy.X - tl.Range2) div 8 to (xy.X + tl.Range2) div 8 do begin
            	for k1 := 0 to tm.Block[i1][j1].Mob.Count - 1 do begin
                	ts := tm.Block[i1][j1].Mob.Objects[k1] as TMob;
                    if (abs(ts.Point.X - xy.X) <= tl.Range2) and (abs(ts.Point.Y - xy.Y) <= tl.Range2) then sl.AddObject(IntToStr(ts.ID),ts);
                end;

            	for k1 := 0 to tm.Block[i1][j1].CList.Count - 1 do begin
                	if ((tm.Block[i1][j1].CList.Objects[k1] is TChara) = false) then Continue;
                    tc1 := tm.Block[i1][j1].CList.Objects[k1] as TChara;
                    if (tc = tc1) or ((mi.PvPG = true) and (tc.GuildID = tc1.GuildID) and (tc.GuildID <> 0)) then Continue;
                    if (abs(tc1.Point.X - xy.X) <= tl.Range2) and (abs(tc1.Point.Y - xy.Y) <= tl.Range2) then sl.AddObject(IntToStr(tc1.ID),tc1);
                end;
            end;
        end;

        if dmg[0] < 0 then dmg[0] := 0;
        if sl.Count <> 0 then begin
        	for k1 := 0 to sl.Count - 1 do begin
            	if (tm.CList.IndexOf(StrToInt(sl.Strings[k1])) <> -1) then begin
                	tc1 := sl.Objects[k1] as TChara;
            		if tc1.HP <= 0 then begin
        		    	SKILL_TYPE := 0;
    		            Exit;
		            end;
                    
                    if dmg[0] <0 then dmg[0] := 0;
                    frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, tl.Data1[tc.MUseLV]);
					SendCSkillAtk2(tm, tc, tc1, Tick, dmg[0], j);
					if not frmMain.DamageProcess2(tm, tc, tc1, dmg[0], Tick) then frmMain.StatCalc2(tc, tc1, Tick);
                end else begin
                	ts := sl.Objects[k1] as TMob;
            		if ts.HP <= 0 then begin
        		    	SKILL_TYPE := 0;
    		            Exit;
		            end;

                    frmMain.DamageCalc1(tm, tc, ts, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, tl.Data1[tc.MUseLV]);
                    if dmg[0] <0 then dmg[0] := 0;
                    SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], j);
					if not frmMain.DamageProcess1(tm, tc, ts, dmg[0], Tick) then frmMain.StatCalc1(tc, ts, Tick);
                end;
            end;
        end;

        sl.Free;
    end;

    procedure use_sp(tc : TChara; SkillID : word; LV : byte);
    begin
    	tc.SPAmount := 0;

        if SkillID = 0 then Exit;
        if tc.SP < tc.Skill[SkillID].Data.SP[LV] then Exit;

        tc.SPAmount := tc.Skill[SkillID].Data.SP[LV];

        if tc.LessSP then tc.SPAmount := tc.SPAmount * 70 div 100;
        if tc.NoJamstone then tc.SPAmount := tc.SPAmount * 125 div 100;
        if tc.SPRedAmount > 0 then tc.SPAmount := tc.SPAmount - (tc.Skill[SkillID].Data.SP[LV] * tc.SPRedAmount div 100);

        if (tc.Autocastactive) then begin
        	tc.SPAmount := tc.SPAmount * 2 div 3;
            tc.Autocastactive := False;
        end;

        // Golen Thief Bug Card (Alex: Should cards be processed here?)
        if tc.NoTarget then tc.SPAmount := tc.SPAmount * 2;

        tc.SP := tc.SP - tc.SPAmount;

        SendCStat1(tc, 0, 7, tc.SP);
        tc.MMode  := 0;
        tc.MSkill := 0;
        tc.MUseLv := 0;
    end;
    

    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: Sword Mastery ---------------------- }
    { - Skill ID Name: SM_SWORD ------------------------ }
    { - Skill ID: 2 ------------------------------------ }
    { -------------------------------------------------- }
    function skill_sword_mastery(tc : TChara) : Integer;
    begin
    	if ( (tc.WeaponType[0] = 1) or (tc.WeaponType[0] = 2) ) then begin
        	tc.ATK[0][4] := tc.Skill[2].Data.Data1[tc.Skill[2].Lv];
		end;
    end;


    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: Two-Handed Sword Mastery ----------- }
    { - Skill ID Name: SM_TWOHAND ---------------------- }
    { - Skill ID: 3 ------------------------------------ }
    { -------------------------------------------------- }
    function skill_two_handed_sword_mastery(tc : TChara) : Integer;
    begin
    	if (tc.WeaponType[0] = 3) then begin
        	tc.ATK[0][4] := tc.Skill[3].Data.Data1[tc.Skill[3].Lv];
		end;
    end;


    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: HP Recovery ------------------------ }
    { - Skill ID Name: SM_RECOVERY --------------------- }
    { - Skill ID: 4 ------------------------------------ }
    { -------------------------------------------------- }
    function skill_hp_recovery(tc : TChara; Tick : Cardinal) : Integer;
    var
    	j : Integer;
    begin
    	if (tc.HPRTick + 10000 <= Tick) and (tc.Sit <> 1) and (tc.Option and 6 = 0) then begin
        	if tc.HP <> tc.MAXHP then begin
            	j := (5 + tc.MAXHP div 500) * tc.Skill[4].Lv;
                if tc.HP + j > tc.MAXHP then j := tc.MAXHP - tc.HP;
                tc.HP := tc.HP + j;
                WFIFOW(0, $013d);
                WFIFOW(2, $0005);
                WFIFOW(4, j);
                tc.Socket.SendBuf(buf, 6);
                SendCStat1(tc, 0, 5, tc.HP);
            end;
            tc.HPRTick := Tick;
        end;
    end;
    
    
    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: Bash ------------------------------- }
    { - Skill ID Name: SM_BASH ------------------------- }
    { - Skill ID: 5 ------------------------------------ }
    { -------------------------------------------------- }
    function skill_bash(tc : TChara; Tick : Cardinal) : Integer;
    var
    	ts : TMob;
        tc1 : TChara;
        tm : TMap;
        tl : TSkillDB;
    begin
    	SKILL_TYPE := 2;

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tl := tc.Skill[tc.MSkill].Data;

		if tc.MTargetType = 0 then begin
			ts := tc.AData;
			frmMain.DamageCalc1(tm, tc, ts, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, tl.Data2[tc.MUseLV]);

	        if (tc.Skill[145].Lv <> 0) and (tc.MSkill = 5) and (tc.MUseLV > 5) then begin
    			if Random(1000) < tc.Skill[145].Data.Data1[tc.MUseLV] * 10 then begin
        	    	if (ts.Stat1 <> 3) then begin
    	            	ts.nStat := 3;
	                    ts.BodyTick := Tick + tc.aMotion;
                	end else begin
            	    	ts.BodyTick := ts.BodyTick + 30000;
        	        end;
    	        end;
	        end;
		end else begin
			tc1 := tc.AData;
			frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, tl.Data2[tc.MUseLV]);
		end;

        Result := 1;
    end;


    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: Provoke ---------------------------- }
    { - Skill ID Name: SM_PROVOKE ---------------------- }
    { - Skill ID: 6 ------------------------------------ }
    { -------------------------------------------------- }
	function skill_provoke(tc : TChara) : Integer;
    var
    	ts : TMob;
        tc1 : TChara;
        tm : TMap;
        tl : TSkillDB;
        rand : Integer;
        k, r : Integer;
        rx, ry : Integer;
    begin
    	SKILL_TYPE := 1;
    	Result := -1;
        
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tl := tc.Skill[tc.MSkill].Data;

        rand := Random(100);
        if ( (tc.Skill[tc.MSkill].Lv * 3 + 50) >= rand ) then begin
        	{ Provoke Successful. % chance checked. } 
	        if tc.MTargetType = 0 then begin
    			ts := tc.AData;

	    		if ( (ts.Data.Race <> 1) and (ts.Data.MEXP = 0) ) then begin
    	        	{ PvM: Provoke Succcessful. No Undead or MVP. }
        			ts.ATKPer := word(tl.Data1[tc.MUseLV]);
        			ts.DEFPer := word(tl.Data2[tc.MUseLV]);
					ts.ATarget := tc.ID;
					ts.ARangeFlag := false;
					ts.AData := tc;
			    end else begin
            		{ PvM: Provoke Failed. Wrong Race/Type. }
					Result := 0;
	    		end;
    	    end else begin
        		{ PvP: Provoke Successful }
	    		tc1 := tc.AData;

                if (tc1.Sit <> 1) then begin

	                k := 0;
    	            r := 0;
        	        while ( (k = 0) and (r < 100) ) do begin
            	    	Randomize;
	                    rx := randomrange(-tc1.Range,tc1.Range) + tc.Point.X;
	                    Randomize;
    	                ry := randomrange(-tc1.Range,tc1.Range) + tc.Point.Y;
        	            k := Path_Finding(tc1.path, tm, tc1.Point.X, tc1.Point.Y, rx, ry, 1);
            	        inc(r);
	                end;

	                if ( (rx = tc.Point.X) and (ry = tc.Point.y) ) then k := 0;

    	            if ( (k <> 0) ) then begin
        	        	tc1.NextFlag := true;
            	        tc1.nextpoint.X := rx;
                	    tc1.nextpoint.Y := ry;
                    	tc1.tgtPoint := tc1.NextPoint;
	                end;

    	            WFIFOW( 0, $0139);
        	        WFIFOL( 2, tc.ID);
            	    WFIFOW( 6, tc.Point.X);
                	WFIFOW( 8, tc.Point.Y);
	                WFIFOW(10, tc1.Point.X);
	                WFIFOW(12, tc1.Point.Y);
    	            WFIFOW(14, tc1.Range);
        	        tc1.Socket.SendBuf(buf, 16);

	                tc1.MTargetType := 1;
    	            tc1.AMode := 2;
    		        tc1.ATarget := tc.ID;
        		    tc1.AData := tc;

	                if tc1.ATick + tc1.ADelay - 200 < timeGetTime() then
    	            tc1.ATick := timeGetTime() - tc1.ADelay + 200;

    				tc1.DamageFixS[1] := word(tl.Data1[tc.MUseLV]);
    				tc1.DEF1 := word(tl.Data2[tc.MUseLV]) * tc1.DEF1 div 100;
	            end else begin
        			{ Provoke failed. Target Dead. }
		            Result := 0;
                end;
            end;
        end else begin
        	{ Provoke failed. % chance too low. }
            Result := 0;
        end;
    end;


    { -------------------------------------------------- }
    { - Job: Swordsman --------------------------------- }
    { - Job ID: 1 -------------------------------------- }
    { - Skill Name: Magnum Break ----------------------- }
    { - Skill ID Name: SM_MAGNUM ----------------------- }
    { - Skill ID: 7 ------------------------------------ }
    { -------------------------------------------------- }
    function skill_magnum_break(tc : TChara; Tick : Cardinal) : Integer;
    begin
    	SKILL_TYPE := 3;
        Result := 1;
    end;


    { -------------------------------------------------- }
    { - Job: Archer ------------------------------------ }
    { - Job ID: 3 -------------------------------------- }
    { - Skill Name: Double Strafe ---------------------- }
    { - Skill ID Name: AC_DOUBLE ----------------------- }
    { - Skill ID: 46 ----------------------------------- }
    { -------------------------------------------------- }
    function skill_double_strafe(tc : TChara; Tick : Cardinal) : Integer;
    var
    	ts : TMob;
        tc1 : TChara;
        tm : TMap;
        tl : TSkillDB;
    begin
    	SKILL_TYPE := 2;

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tl := tc.Skill[tc.MSkill].Data;

        if (tc.Weapon = 11) then begin
        	if tc.MTargetType = 0 then begin
                ts := tc.AData;
                frmMain.DamageCalc1(tm, tc, ts, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, 0);
            end else begin
                tc1 := tc.AData;
                frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, 0);
            end;

            dmg[0] := dmg[0] * 2;
            Result := 2;
        end else begin
        	SKILL_TYPE := 1;
        	Result := 6;
        end;
    end;

end.

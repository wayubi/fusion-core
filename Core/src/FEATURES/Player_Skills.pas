unit Player_Skills;

interface

uses
	IniFiles, Classes, SysUtils, Common, List32, MMSystem;

var
	SKILL_TYPE : Byte;
    {
    	1: Process Effect
        2: Process Skill Attack
    }

    procedure parse_skills(tc : TChara; Tick : Cardinal);

    procedure process_effect(tc : TChara; success : Integer);
    procedure process_skill_attack(tc : TChara; j : Integer; Tick : Cardinal);

    function skill_sword_mastery(tc : TChara) : Integer;
	function skill_two_handed_sword_mastery(tc : TChara) : Integer;
    function skill_bash(tc : TChara; Tick : Cardinal) : Integer;
	function skill_provoke(tc : TChara) : Integer;
    function skill_double_strafe(tc : TChara; Tick : Cardinal) : Integer;

implementation

uses
	Main;

	procedure parse_skills(tc : TChara; Tick : Cardinal);
    var
    	success : Integer;
    begin
    	SKILL_TYPE := 0;

        { 2} if (tc.Skill[2].Lv <> 0) then success := skill_sword_mastery(tc);
		{ 3} if (tc.Skill[3].Lv <> 0) then success := skill_two_handed_sword_mastery(tc);
        { 5} if (tc.MSkill = 5) then success := skill_bash(tc, Tick);
        { 6} if (tc.MSkill = 6) then success := skill_provoke(tc);
        {46} if (tc.MSkill = 46) then success := skill_double_strafe(tc, Tick);

        {
	        Success Codes:
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
        	SendBCmd(tm, ts.Point, 15);
        end else begin
            tc1 := tc.AData;
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
    	if dmg[0] < 0 then dmg[0] := 0;
		if tc.MTargetType = 0 then begin
			ts := tc.AData;
			SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], j);
			if not frmMain.DamageProcess1(tm, tc, ts, dmg[0], Tick) then frmMain.StatCalc1(tc, ts, Tick);
		end else begin
			tc1 := tc.AData;
			SendCSkillAtk2(tm, tc, tc1, Tick, dmg[0], j);
			if not frmMain.DamageProcess2(tm, tc, tc1, dmg[0], Tick) then frmMain.StatCalc2(tc, tc1, Tick);
		end;
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
		end else begin
			tc1 := tc.AData;
			frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, tl.Data2[tc.MUseLV]);
		end;

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
    	        tc1.ATarget := tc.ID;
        	    tc1.AData := tc;
                tc1.AMode := 2;

                tc1.NextPoint := tc.Point;
                tc1.NextFlag := True;

                { Alex: Now I just need to get tc1 to attack tc }

    			tc1.DamageFixS[1] := word(tl.Data1[tc.MUseLV]);
    			tc1.DEF1 := word(tl.Data2[tc.MUseLV]) * tc1.DEF1 div 100;
            end;
        end else begin
        	{ Provoke failed. % chance too low. }
            Result := 0;
        end;
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

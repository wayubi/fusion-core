unit Player_Skills;

interface

uses
	IniFiles, Classes, SysUtils, Common, List32, MMSystem;

    procedure parse_skills(tc : TChara; Tick : Cardinal);
    procedure process_effect(tc : TChara; success : Integer);

	function skill_provoke(tc : TChara) : Integer;
    function skill_double_strafe(tc : TChara; Tick : Cardinal) : Integer;

implementation

uses
	Main;

	procedure parse_skills(tc : TChara; Tick : Cardinal);
    var
    	success : Integer;
    begin
    	case tc.MSkill of
        	6: success := skill_provoke(tc);
            46: success := skill_double_strafe(tc, Tick);
        end;

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

        process_effect(tc, success);
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
        	ts := TMob.Create;
            ts := tc.AData;
        	SendBCmd(tm, ts.Point, 15);
        end else begin
        	tc1 := TChara.Create;
            tc1 := tc.AData;
	        SendBCmd(tm, tc1.Point, 15);
        end;
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
    	Result := -1;
        
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tl := tc.Skill[tc.MSkill].Data;

        rand := Random(100);
        if ( (tc.Skill[tc.MSkill].Lv * 3 + 50) >= rand ) then begin
        	{ Provoke Successful. % chance checked. } 
	        if tc.MTargetType = 0 then begin
    	    	ts := TMob.Create;
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
        		tc1 := TChara.Create;
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
            Result := 1;
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
        j : Integer;
    begin
    	Result := -1;

        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tl := tc.Skill[tc.MSkill].Data;

        if (tc.Weapon = 11) then begin
        	if tc.MTargetType = 0 then begin
            	ts := TMob.Create;
                ts := tc.AData;
                frmMain.DamageCalc1(tm, tc, ts, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, 0);
            end else begin
            	tc1 := TChara.Create;
                tc1 := tc.AData;
                frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[tc.MUseLV], tl.Element, 0);
            end;

            dmg[0] := dmg[0] * 2;
            j := 2;

            if dmg[0] < 0 then dmg[0] := 0;
            if tc.MTargetType = 0 then begin
            	SendCSkillAtk1(tm, tc, ts, Tick, dmg[0], j);
            	if not frmMain.DamageProcess1(tm, tc, ts, dmg[0], Tick) then frmMain.StatCalc1(tc, ts, Tick);
            end else begin
            	SendCSkillAtk2(tm, tc, tc1, Tick, dmg[0], j);
                if not frmMain.DamageProcess2(tm, tc, tc1, dmg[0], Tick) then frmMain.StatCalc2(tc, tc1, Tick);
            end;
        end else begin
        	Result := 6;
        end;
    end;

end.

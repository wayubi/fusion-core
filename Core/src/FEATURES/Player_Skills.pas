unit Player_Skills;

interface

uses
	IniFiles, Classes, SysUtils, Common, List32, MMSystem;

    procedure parse_skills(tc : TChara);
    procedure process_effect(tc : TChara; success : Integer);

	function skill_provoke(tc : TChara) : Word;

implementation

	procedure parse_skills(tc : TChara);
    var
    	success : Word;
    begin
    	case tc.MSkill of
        	6: success := skill_provoke(tc);
        end;

        process_effect(tc, success);
    end;

	procedure process_effect(tc : TChara; success : Integer);
    var
    	tm : TMap;
        tc1 : TChara;
        ts : TMob;
    begin
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;

    	WFIFOW( 0, $011a);
	    WFIFOW( 2, tc.MSkill);
    	WFIFOW( 4, tc.MUseLV);
	    WFIFOL( 6, tc.MTarget);
    	WFIFOL(10, tc.ID);
	    WFIFOB(14, success);

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

	function skill_provoke(tc : TChara) : Word;
    var
    	ts : TMob;
        tc1 : TChara;
        tm : TMap;
        tl : TSkillDB;
    begin
    	Result := 1;
        
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
        tL := tc.Skill[tc.MSkill].Data;

        if tc.MTargetType = 0 then begin
        	ts := TMob.Create;
    		ts := tc.AData;

    		if ts.Data.Race <> 1 then begin
        		ts.ATKPer := word(tl.Data1[tc.MUseLV]);
        		ts.DEFPer := word(tl.Data2[tc.MUseLV]);
		    end else begin
				Result := 0;
    		end;
        end else begin
        	tc1 := TChara.Create;
    		tc1 := tc.AData;
            { Alex: A lot of these PVP calculations are a complete mess. Fusion looks
            awesome on PVM, but try PVP and you'll see a totally different story.
            I don't even know why Provoke is calculating damage, but obviously these
            need to be double checked one by one. }
    		//frmMain.DamageCalc3(tm, tc, tc1, Tick, 0, tl.Data1[MUseLV], tl.Element, tl.Data2[MUseLV]);
    		tc1.DamageFixS[1] := word(tl.Data1[tc.MUseLV]); // ATK Increase upon the medium size to ease the pain.
    		tc1.DEF1 := word(tl.Data2[tc.MUseLV]) * tc1.DEF1 div 100;
        end;

    end;

end.
 
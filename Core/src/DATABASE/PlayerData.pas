unit PlayerData;

interface

uses
    {Windows VCL}
    {$IFDEF MSWINDOWS}
    Windows, MMSystem, Forms,
    {$ENDIF}
    {Kylix/Delphi CLX}
    {$IFDEF LINUX}
    Qt, QForms, Types,
    {$ENDIF}
    {Shared}
    Classes, SysUtils, IniFiles,
    {Fusion}
    Common, REED_Support,
    REED_LOAD_ACCOUNTS,
    REED_LOAD_CHARACTERS,
    REED_LOAD_PETS,
    REED_LOAD_PARTIES,
    REED_LOAD_GUILDS,
    REED_LOAD_CASTLES,
    REED_SAVE_ACCOUNTS,
    REED_SAVE_CHARACTERS,
    REED_SAVE_PETS;

    { Parsers }
    procedure PD_PlayerData_Load(UID : String = '*');
    procedure PD_PlayerData_Save(forced : Boolean = False);
    procedure PD_PlayerData_Delete(UID : String);

    { Create Basic Structure }
    procedure PD_Create_Structure();

    { Account Data - Basic Data }
    procedure PD_Delete_Accounts(tp : TPlayer);


    { Character Data - Basic Data }
    procedure PD_Delete_Characters(tc : TChara);


    { Party Data - Member Data }
    procedure PD_Save_Parties_Members(forced : Boolean = False);


    { Guild Data - Basic Data }
    procedure PD_Save_Guilds(forced : Boolean = False);
    procedure PD_Delete_Guilds(tg : TGuild);

    { Guild Data - Member Data }
    procedure PD_Save_Guilds_Members(forced : Boolean = False);

    { Guild Data - Position Data }
    procedure PD_Save_Guilds_Positions(forced : Boolean = False);

    { Guild Data - Skills Data }
    procedure PD_Save_Guilds_Skills(forced : Boolean = False);

    { Guild Data - Ban List Data }
    procedure PD_Save_Guilds_BanList(forced : Boolean = False);

    { Guild Data - Diplomacy Data }
    procedure PD_Save_Guilds_Diplomacy(forced : Boolean = False);

    procedure PD_Save_Guilds_Storage(forced : Boolean = False);


    { Castle Data - Basic Data }
    procedure PD_Save_Castles(forced : Boolean = False);


implementation

uses
	Game_Master, GlobalLists, Zip, TrimStr, Database;


    { -------------------------------------------------------------------------------- }
    { -- Parsers --------------------------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_PlayerData_Load(UID : String = '*');
    var
        tp : TPlayer;
    begin
        PD_Create_Structure();

        if UID <> '*' then begin
            if PlayerName.IndexOf(UID) = -1 then Exit;
            tp := PlayerName.Objects[PlayerName.IndexOf(UID)] as TPlayer;
            UID := IntToStr(tp.ID);
        end;

        if UID = '*' then debugout.Lines.add('­ Accounts ­');
    	PD_Load_Accounts(UID);
        PD_Load_Accounts_ActiveCharacters(UID);
        PD_Load_Accounts_Storage(UID);

        if UID = '*' then debugout.Lines.add('­ Characters ­');
        PD_Load_Characters_Parse(UID);

        if UID = '*' then debugout.Lines.add('­ Pets ­');
        PD_Load_Pets_Parse(UID);

        if UID = '*' then debugout.Lines.add('­ Parties ­');
        PD_Load_Parties_Pre_Parse(UID);

        if UID = '*' then debugout.Lines.add('­ Guilds ­');
        PD_Load_Guilds_Pre_Parse(UID);

        if UID = '*' then debugout.Lines.add('­ Castles ­');
        PD_Load_Castles_Pre_Parse(UID);
    end;

    procedure PD_PlayerData_Save(forced : Boolean = False);
    begin
        PD_Create_Structure();

        if (forced) then debugout.lines.add('Initiating Comprehensive Save .. Please Wait.');

        PD_Save_Accounts_Parse(forced);
        PD_Save_Characters_Parse(forced);
        PD_Save_Pets_Parse(forced);


        PD_Save_Parties_Members(forced);

        PD_Save_Guilds(forced);
        PD_Save_Guilds_Members(forced);
		PD_Save_Guilds_Positions(forced);
        PD_Save_Guilds_Skills(forced);
        PD_Save_Guilds_BanList(forced);
        PD_Save_Guilds_Diplomacy(forced);
        PD_Save_Guilds_Storage(forced);

        PD_Save_Castles(forced);

        if (forced) then debugout.lines.add('Comprehensive Save Completed.');
    end;

    procedure PD_PlayerData_Delete(UID : String);
    var
        tp : TPlayer;
    begin
        if PlayerName.IndexOf(UID) = -1 then Exit;
        tp := PlayerName.Objects[PlayerName.IndexOf(UID)] as TPlayer;

        //PD_Delete_Characters(tc : TChara);
        PD_Delete_Accounts(tp);
    end;


    { -------------------------------------------------------------------------------- }
    { -- Create Structure ------------------------------------------------------------ }
    { -------------------------------------------------------------------------------- }
    procedure PD_Create_Structure();
    begin
        CreateDir(AppPath + 'gamedata');
        CreateDir(AppPath + 'gamedata\Accounts');
        CreateDir(AppPath + 'gamedata\Parties');
        CreateDir(AppPath + 'gamedata\Guilds');
        CreateDir(AppPath + 'gamedata\Castles');
    end;


    { -------------------------------------------------------------------------------- }
    { -- Account Data - Basic Data --------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Delete_Accounts(tp : TPlayer);
    var
        deldir : String;
        searchResult : Array[0..3] of TSearchRec;
    begin
        deldir := AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\';
        SetCurrentDir(deldir);

        { -- Delete Account Files -- }
        if FindFirst('*', faAnyFile, searchResult[0]) = 0 then repeat
            try
                DeleteFile(deldir + searchResult[0].Name);
            except
                DebugOut.Lines.Add('Account could not be deleted.');
            end;
        until FindNext(searchResult[0]) <> 0;
        FindClose(searchResult[0]);
        { -- Delete Account Files -- }

        deldir := AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\';
        SetCurrentDir(deldir);
        if FindFirst('*', faDirectory, searchResult[0]) = 0 then repeat

            if (searchResult[0].Name = '.') or (searchResult[0].Name = '..') then Continue;

            { -- Delete Character Files -- }
            SetCurrentDir(deldir + searchResult[0].Name + '\');
            if FindFirst('*', faAnyFile, searchResult[1]) = 0 then repeat
                try
                    DeleteFile(deldir + searchResult[0].Name + '\' + searchResult[1].Name);
                except
                    DebugOut.Lines.Add('Character data could not be deleted.');
                end;
            until FindNext(searchResult[1]) <> 0;
            FindClose(searchResult[1]);
            { -- Delete Character Files -- }

            { -- Delete Character Pet Files -- }
            SetCurrentDir(deldir + searchResult[0].Name + '\Pets\');
            if FindFirst('*', faAnyFile, searchResult[1]) = 0 then repeat
                try
                    DeleteFile(deldir + searchResult[0].Name + '\Pets\' + searchResult[1].Name);
                except
                    DebugOut.Lines.Add('Pet data could not be deleted.');
                end;
            until FindNext(searchResult[1]) <> 0;
            FindClose(searchResult[1]);
            { -- Delete Character Pet Files -- }

            { -- Delete Character / Pet Directory -- }
            SetCurrentDir(AppPath);
            if FileExists(deldir + searchResult[0].Name + '\Pets') then
                RmDir(deldir + searchResult[0].Name + '\Pets');
            if FileExists(deldir + searchResult[0].Name) then
                RmDir(deldir + searchResult[0].Name);
            { -- Delete Character / Pet Directory -- }

        until FindNext(searchResult[0]) <> 0;
        FindClose(searchResult[0]);

        { -- Delete Account / Characters Directory -- }
        if FileExists(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\') then
            RmDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\');
        if FileExists(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID)) then
            RmDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));
        { -- Delete Account / Characters Directory -- }

        DataSave();
    end;




    { -------------------------------------------------------------------------------- }
    { -- Character Data - Basic Data ------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Delete_Characters(tc : TChara);
    var
        tp : TPlayer;
        deldir : String;
    begin
        tp := tc.PData;

        deldir := AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\';
        if FileExists(deldir+'ActiveMemos.txt') then DeleteFile(deldir+'ActiveMemos.txt');
        if FileExists(deldir+'Cart.txt') then DeleteFile(deldir+'Cart.txt');
        if FileExists(deldir+'Character.txt') then DeleteFile(deldir+'Character.txt');
        if FileExists(deldir+'Inventory.txt') then DeleteFile(deldir+'Inventory.txt');
        if FileExists(deldir+'Skills.txt') then DeleteFile(deldir+'Skills.txt');
        if FileExists(deldir+'Variables.txt') then DeleteFile(deldir+'Variables.txt');

        deldir := AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\';
        SetCurrentDir(deldir);
        RmDir(deldir + IntToStr(tc.CID));

        DataSave();
    end;


    { -------------------------------------------------------------------------------- }
    { -- Party Data - Member Data ---------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Parties_Members(forced : Boolean = False);
    var
    	datafile : TStringList;
        tpa : TParty;
    	i, j : Integer;
        str : String;
        saveflag : Boolean;

        searchResult : TSearchRec;
    begin
        if FindFirst(AppPath + 'gamedata\Parties\*', faDirectory, searchResult) = 0 then repeat
            if (searchResult.Name = '.') or (searchResult.Name = '..') then Continue;

            {trashparty := True;
            for i := 0 to PartyNameList.Count - 1 do begin
                tpa := PartyNameList.Objects[i] as TParty;
                if tpa.Name = searchResult.Name then begin
                    trashparty := False;
                end;
            end;

            if trashparty then begin
                //debugout.lines.add(tpa.Name + ' deleted');
                DeleteFile(AppPath + 'gamedata\Parties\' + searchResult.Name + '\Members.txt');
                RmDir(AppPath + 'gamedata\Parties\' + searchResult.Name);
            end;}

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to PartyNameList.Count - 1 do begin
			tpa := PartyNameList.Objects[i] as TParty;

            for j := 0 to 11 do begin
                if not assigned(tpa.Member[j]) then tpa.MemberID[j] := 0;
            	if tpa.MemberID[j] = 0 then Break;

                if (tpa.Member[j].Login <> 0) or (forced) then begin
                	saveflag := True;
                    Break;
                end;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' CID    : NAME');
            datafile.Add('-------------------------------------------------');

            for j := 0 to 11 do begin
            	if tpa.MemberID[j] = 0 then Continue;
                if not assigned(tpa.Member[j]) then Continue;
                if tpa.Member[j].PartyName <> tpa.Name then Continue;                

            	str := ' ';
                str := str + IntToStr(tpa.MemberID[j]);
                str := str + ' : ';
                str := str + tpa.Member[j].Name;

            	datafile.Add(str);
			end;

            CreateDir(AppPath + 'gamedata\Parties');
            CreateDir(AppPath + 'gamedata\Parties\' + IntToStr(tpa.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Parties\' + IntToStr(tpa.ID) + '\Members.txt');
                //debugout.Lines.Add(tpa.Name + ' party members data saved.');
            except
                DebugOut.Lines.Add('Parties members data could not be saved.');
            end;

            datafile.Clear;
            datafile.Add('NAM : ' + tpa.Name);
            datafile.Add('PID : ' + IntToStr(tpa.ID));
            datafile.SaveToFile(AppPath + 'gamedata\Parties\' + IntToStr(tpa.ID) + '\Settings.txt');

        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Basic Data ----------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
    	i, j : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[j]) then Continue;                
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

            datafile.Clear;
            datafile.Add('NAM : ' + tg.Name);
            datafile.Add('GID : ' + IntToStr(tg.ID));
            datafile.Add('GLV : ' + IntToStr(tg.LV));
            datafile.Add('EXP : ' + IntToStr(tg.EXP));
            datafile.Add('SKP : ' + IntToStr(tg.GSkillPoint));
            datafile.Add('NT1 : ' + tg.Notice[0]);
            datafile.Add('NT2 : ' + tg.Notice[1]);
            datafile.Add('AGT : ' + tg.Agit);
            datafile.Add('EMB : ' + IntToStr(tg.Emblem));
            datafile.Add('PSN : ' + IntToStr(tg.Present));
            datafile.Add('DFV : ' + IntToStr(tg.DisposFV));
            datafile.Add('DRW : ' + IntToStr(tg.DisposRW));

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Guild.txt');
                //debugout.Lines.Add(tg.Name + ' guild data saved.');
            except
                DebugOut.Lines.Add('Guild data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;

    procedure PD_Delete_Guilds(tg : TGuild);
    var
        deldir : String;
    begin
        deldir := AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\';
        if FileExists(deldir+'BanList.txt') then DeleteFile(deldir+'BanList.txt');
        if FileExists(deldir+'Diplomacy.txt') then DeleteFile(deldir+'Diplomacy.txt');
        if FileExists(deldir+'Guild.txt') then DeleteFile(deldir+'Guild.txt');
        if FileExists(deldir+'Members.txt') then DeleteFile(deldir+'Members.txt');
        if FileExists(deldir+'Positions.txt') then DeleteFile(deldir+'Positions.txt');
        if FileExists(deldir+'Skills.txt') then DeleteFile(deldir+'Skills.txt');

        deldir := AppPath + 'gamedata\Guilds\';
        SetCurrentDir(deldir);
        RmDir(deldir + IntToStr(tg.ID));

        DataSave();
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Member Data ---------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds_Members(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
        masterflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[j]) then Continue;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' CID    : PO : EXP        ');
            datafile.Add('--------------------------');

            masterflag := True;
            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Continue;
                if not assigned(tg.Member[j]) then Continue;
                if tg.Member[j].GuildID <> tg.ID then Continue;

                str := ' ';
                str := str + IntToStr(tg.MemberID[j]);
                str := str + ' : ';

                if masterflag then begin
                    tg.MemberPOS[j] := 0;
                    masterflag := False;
                end;

                len := length(IntToStr(tg.MemberPOS[j]));
                for k := 0 to (2 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tg.MemberPOS[j]);
                str := str + ' : ';

                len := length(IntToStr(tg.MemberEXP[j]));
                for k := 0 to (10 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tg.MemberEXP[j]);

            	datafile.Add(str);
			end;

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Members.txt');
                //debugout.Lines.Add(tg.Name + ' guild member data saved.');
            except
                DebugOut.Lines.Add('Guild member data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Position Data -------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds_Positions(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[i]) then Break;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' ID : I : P : XP : NAME');
            datafile.Add('----------------------------------------------------------');

            for j := 0 to 19 do begin
                str := ' ';

                len := length(IntToStr(j+1));
                for k := 0 to (2 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(j+1);
                str := str + ' : ';

                if (tg.PosInvite[j]) then str := str + 'Y' else str := str + 'N';
                str := str + ' : ';

                if (tg.PosPunish[j]) then str := str + 'Y' else str := str + 'N';
                str := str + ' : ';

                len := length(IntToStr(tg.PosEXP[j]));
                for k := 0 to (2 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tg.PosEXP[j]);
                str := str + ' : ';

                str := str + tg.PosName[j];

                datafile.Add(str);
            end;

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Positions.txt');
                //debugout.Lines.Add(tg.Name + ' guild positions data saved.');
            except
                DebugOut.Lines.Add('Guild positions data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Skills Data ---------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds_Skills(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[i]) then Break;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' SK ID : LV : SKILL NAME');
            datafile.Add('-------------------------------');

            for j := 10000 to 10004 do begin
            	if tg.GSkill[j].LV = 0 then Continue;

                str := ' ';
                str := str + IntToStr(j);
                str := str + ' : ';

                len := length(IntToStr(tg.GSkill[j].LV));
                for k := 0 to (2 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tg.GSkill[j].LV);
                str := str + ' : ';

                str := str + tg.GSkill[j].Data.IDC;

                datafile.Add(str);
            end;

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Skills.txt');
                //debugout.Lines.Add(tg.Name + ' guild skill data saved.');
            except
                DebugOut.Lines.Add('Guild skill data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Ban List Data -------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds_BanList(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
        tgb : TGBan;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[i]) then Break;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' CHARACTER NAME          : ACCOUNT NAME            : BAN REASON');
            datafile.Add('------------------------------------------------------------------------------------------------------');

            for j := 0 to tg.GuildBanList.Count - 1 do begin
            	tgb := tg.GuildBanList.Objects[j] as TGBan;

                if (tgb = nil) then Continue;

                str := ' ';

                str := str + tgb.Name;
                len := length(tgb.Name);
                for k := 0 to (23 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + ' : ';

                str := str + tgb.AccName;
                len := length(tgb.AccName);
                for k := 0 to (23 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + ' : ';

                str := str + tgb.Reason;

                datafile.Add(str);
            end;

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\BanList.txt');
                //debugout.Lines.Add(tg.Name + ' guild banlist data saved.');
            except
                DebugOut.Lines.Add('Guild banlist data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Guild Data - Diplomacy Data ------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Guilds_Diplomacy(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
        tgl : TGRel;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[i]) then Break;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

        	datafile.Clear;
            datafile.Add(' GID    : T : GUILD NAME');
            datafile.Add('-----------------------------------------------------');

            for j := 0 to tg.RelAlliance.Count - 1 do begin
            	tgl := tg.RelAlliance.Objects[j] as TGRel;

                if (tgl = nil) then Continue;

                str := ' ';

                len := length(IntToStr(tgl.ID));
                for k := 0 to (6 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tgl.ID);
                str := str + ' : ';

                str := str + 'A';
                str := str + ' : ';

                str := str + tgl.GuildName;

                datafile.Add(str);
            end;

            for j := 0 to tg.RelHostility.Count - 1 do begin
            	tgl := tg.RelHostility.Objects[j] as TGRel;

                if (tgl = nil) then Continue;

                str := ' ';

                len := length(IntToStr(tgl.ID));
                for k := 0 to (6 - len) - 1 do begin
                	str := str + ' ';
                end;
                str := str + IntToStr(tgl.ID);
                str := str + ' : ';

                str := str + 'H';
                str := str + ' : ';

                str := str + tgl.GuildName;

                datafile.Add(str);
            end;

            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Diplomacy.txt');
                //debugout.Lines.Add(tg.Name + ' guild diplomacy data saved.');
            except
                DebugOut.Lines.Add('Guild diplomacy data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;



    procedure PD_Save_Guilds_Storage(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
        tgl : TGRel;
    	i, j, k : Integer;
        str : String;
        len : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

    	for i := 0 to GuildList.Count - 1 do begin
        	tg := GuildList.Objects[i] as TGuild;

            if (tg = nil) then Continue;
            if tg.RegUsers = 0 then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if not assigned(tg.Member[i]) then Break;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

            datafile.Clear;
            datafile.Add('    ID :   AMT : EQP : I :  R : A : CARD1 : CARD2 : CARD3 : CARD4 : NAME');
            datafile.Add('---------------------------------------------------------------------------------------------------------');



            for j := 1 to 100 do begin
    	        if tg.Storage.Item[j].ID <> 0 then begin
	            	str := ' ';

					len := length(IntToStr(tg.Storage.Item[j].ID));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tg.Storage.Item[j].ID);
	                str := str + ' : ';

	                len := length(IntToStr(tg.Storage.Item[j].Amount));
                	for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tg.Storage.Item[j].Amount);
	                str := str + ' : ';

	                len := length(IntToStr(tg.Storage.Item[j].Equip));
                	for k := 0 to (3 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
            	    str := str + IntToStr(tg.Storage.Item[j].Equip);
        	        str := str + ' : ';

    	            str := str + IntToStr(tg.Storage.Item[j].Identify);
	                str := str + ' : ';

            	    len := length(IntToStr(tg.Storage.Item[j].Refine));
        	        for k := 0 to (2 - len) - 1 do begin
    	            	str := str + ' ';
	                end;
            	    str := str + IntToStr(tg.Storage.Item[j].Refine);
        	        str := str + ' : ';
    	            str := str + IntToStr(tg.Storage.Item[j].Attr);
	                str := str + ' : ';

    	            len := length(IntToStr(tg.Storage.Item[j].Card[0]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tg.Storage.Item[j].Card[0]);
	                str := str + ' : ';

    	            len := length(IntToStr(tg.Storage.Item[j].Card[1]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tg.Storage.Item[j].Card[1]);
	                str := str + ' : ';

    	            len := length(IntToStr(tg.Storage.Item[j].Card[2]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tg.Storage.Item[j].Card[2]);
	                str := str + ' : ';

        	        len := length(IntToStr(tg.Storage.Item[j].Card[3]));
    	            for k := 0 to (5 - len) - 1 do begin
	                	str := str + ' ';
                	end;
            	    str := str + IntToStr(tg.Storage.Item[j].Card[3]);
        	        str := str + ' : ';

                    str := str + tg.Storage.Item[j].Data.Name;

    	            datafile.Add(str);
	            end;
            end;



            CreateDir(AppPath + 'gamedata\Guilds');
            CreateDir(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID));

            try
                datafile.SaveToFile(AppPath + 'gamedata\Guilds\' + IntToStr(tg.ID) + '\Storage.txt');
                //debugout.Lines.Add(tg.Name + ' guild diplomacy data saved.');
            except
                DebugOut.Lines.Add('Guild storage data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;




    { -------------------------------------------------------------------------------- }
    { -- Castle Data - Basic Data ---------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Castles(forced : Boolean = False);
    var
    	datafile : TStringList;
        tg : TGuild;
        tgc : TCastle;
    	i, j : Integer;
        saveflag : Boolean;
    begin
    	saveflag := False;
    	datafile := TStringList.Create;

        for i := 0 to CastleList.Count - 1 do begin
            tgc := CastleList.Objects[i] as TCastle;

            if GuildList.IndexOf(tgc.GID) = -1 then Continue;
            tg := GuildList.Objects[GuildList.IndexOf(tgc.GID)] as TGuild;

            if (tg = nil) then Continue;

            for j := 0 to tg.RegUsers - 1 do begin
            	if tg.MemberID[j] = 0 then Break;
                if tg.Member[j] = nil then Continue;
                if (tg.Member[j].Login <> 0) or (forced) then saveflag := True;
                Break;
            end;

            if not saveflag then Continue;

            datafile.Clear;
            datafile.Add('MAP : ' + tgc.Name);
            datafile.Add('GID : ' + IntToStr(tgc.GID));
            datafile.Add('GNM : ' + tgc.GName);
            datafile.Add('GMA : ' + tgc.GMName);
            datafile.Add('GKA : ' + IntToStr(tgc.GKafra));
            datafile.Add('EDE : ' + IntToStr(tgc.EDegree));
            datafile.Add('ETR : ' + IntToStr(tgc.ETrigger));
            datafile.Add('DDE : ' + IntToStr(tgc.DDegree));
            datafile.Add('DTR : ' + IntToStr(tgc.DTrigger));
            datafile.Add('GS1 : ' + IntToStr(tgc.GuardStatus[0]));
            datafile.Add('GS2 : ' + IntToStr(tgc.GuardStatus[1]));
            datafile.Add('GS3 : ' + IntToStr(tgc.GuardStatus[2]));
            datafile.Add('GS4 : ' + IntToStr(tgc.GuardStatus[3]));
            datafile.Add('GS5 : ' + IntToStr(tgc.GuardStatus[4]));
            datafile.Add('GS6 : ' + IntToStr(tgc.GuardStatus[5]));
            datafile.Add('GS7 : ' + IntToStr(tgc.GuardStatus[6]));
            datafile.Add('GS8 : ' + IntToStr(tgc.GuardStatus[7]));

            CreateDir(AppPath + 'gamedata\Castles');
            CreateDir(AppPath + 'gamedata\Castles\' + tgc.Name);

            try
                datafile.SaveToFile(AppPath + 'gamedata\Castles\' + tgc.Name + '\Castle.txt');
                //debugout.Lines.Add(tgc.Name + ' castle data saved.');
            except
                DebugOut.Lines.Add('Castle data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;

end.


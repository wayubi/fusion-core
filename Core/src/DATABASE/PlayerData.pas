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
    REED_LOAD_GUILDS;

    { Parsers }
    procedure PD_PlayerData_Load(UID : String = '*');
    procedure PD_PlayerData_Save(forced : Boolean = False);
    procedure PD_PlayerData_Delete(UID : String);

    { Create Basic Structure }
    procedure PD_Create_Structure();

    { Account Data - Basic Data }
    procedure PD_Save_Accounts(forced : Boolean = False);
    procedure PD_Delete_Accounts(tp : TPlayer);

    { Account Data - Active Characters }
    procedure PD_Save_Accounts_ActiveCharacters(forced : Boolean = False);

    { Account Data - Storage }
    procedure PD_Save_Accounts_Storage(forced : Boolean = False);


    { Character Data - Basic Data }
    procedure PD_Save_Characters(forced : Boolean = False);
    procedure PD_Delete_Characters(tc : TChara);

    { Character Data - Memo Data }
    procedure PD_Save_Characters_Memos(forced : Boolean = False);

    { Character Data - Skill Data }
    procedure PD_Save_Characters_Skills(forced : Boolean = False);

    { Character Data - Inventory Data }
    procedure PD_Save_Characters_Inventory(forced : Boolean = False);

    { Character Data - Cart Data }
    procedure PD_Save_Characters_Cart(forced : Boolean = False);

    { Character Data - Variables Data }
    procedure PD_Save_Characters_Variables(forced : Boolean = False);

    { Character Data - Pets Data }
    procedure PD_Save_Characters_Pets(forced : Boolean = False);


    { Party Data - Member Data }
    procedure PD_Save_Parties_Members(forced : Boolean = False);


    { Guild Data - Basic Data }
    procedure PD_Save_Guilds(forced : Boolean = False);
    procedure PD_Delete_Guilds(tg : TGuild);

    { Guild Data - Member Data }
    procedure PD_Save_Guilds_Members(forced : Boolean = False);

    { Guild Data - Position Data }
    procedure PD_Load_Guilds_Positions(UID : String = '*');
    procedure PD_Save_Guilds_Positions(forced : Boolean = False);

    { Guild Data - Skills Data }
    procedure PD_Load_Guilds_Skills(UID : String = '*');
    procedure PD_Save_Guilds_Skills(forced : Boolean = False);

    { Guild Data - Ban List Data }
    procedure PD_Load_Guilds_BanList(UID : String = '*');
    procedure PD_Save_Guilds_BanList(forced : Boolean = False);

    { Guild Data - Diplomacy Data }
    procedure PD_Load_Guilds_Diplomacy(UID : String = '*');
    procedure PD_Save_Guilds_Diplomacy(forced : Boolean = False);


    { Castle Data - Basic Data }
    procedure PD_Load_Castles(UID : String = '*');
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


        PD_Load_Guilds_Positions(UID);
        PD_Load_Guilds_Skills(UID);
        PD_Load_Guilds_BanList(UID);
        PD_Load_Guilds_Diplomacy(UID);

        if UID = '*' then debugout.Lines.add('­ Castles ­');
        PD_Load_Castles(UID);
    end;

    procedure PD_PlayerData_Save(forced : Boolean = False);
    begin
        PD_Create_Structure();

        if (forced) then debugout.lines.add('Initiating Comprehensive Save .. Please Wait.');

    	PD_Save_Accounts(forced);
        PD_Save_Accounts_ActiveCharacters(forced);
        PD_Save_Accounts_Storage(forced);

        PD_Save_Characters(forced);
        PD_Save_Characters_Memos(forced);
        PD_Save_Characters_Skills(forced);
        PD_Save_Characters_Inventory(forced);
        PD_Save_Characters_Cart(forced);
        PD_Save_Characters_Variables(forced);
        PD_Save_Characters_Pets(forced);

        PD_Save_Parties_Members(forced);

        PD_Save_Guilds(forced);
        PD_Save_Guilds_Members(forced);
		PD_Save_Guilds_Positions(forced);
        PD_Save_Guilds_Skills(forced);
        PD_Save_Guilds_BanList(forced);
        PD_Save_Guilds_Diplomacy(forced);

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
    procedure PD_Save_Accounts(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        i : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
        	datafile.Clear;

			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            datafile.Add('USERID : ' + IntToStr(tp.ID));
            datafile.Add('USERNAME : ' + tp.Name);
            datafile.Add('PASSWORD : ' + tp.Pass);

            if (tp.Gender = 0) then datafile.Add('SEX : FEMALE')
            else if (tp.Gender = 1) then datafile.Add('SEX : MALE');

            datafile.Add('EMAIL : ' + tp.Mail);

            if (tp.Banned = 0) then datafile.Add('BANNED : NO')
            else if (tp.Banned = 1) then datafile.Add('BANNED : YES');

            datafile.Add('ACCESSLEVEL : ' + IntToStr(tp.AccessLevel));

            CreateDir(AppPath + 'gamedata\Accounts');
            CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));

            try
	            datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Account.txt');
                //debugout.Lines.Add(tp.Name + ' account data saved.');
            except
                DebugOut.Lines.Add('Account data could not be saved.');
        	end;
        end;

        datafile.Clear;
        datafile.Free;
    end;

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
    { -- Account Data - Active Characters -------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Accounts_ActiveCharacters(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        i : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
        	datafile.Clear;

			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            datafile.Add('SLOT1 : ' + tp.CName[0]);
            datafile.Add('SLOT2 : ' + tp.CName[1]);
            datafile.Add('SLOT3 : ' + tp.CName[2]);
            datafile.Add('SLOT4 : ' + tp.CName[3]);
            datafile.Add('SLOT5 : ' + tp.CName[4]);
            datafile.Add('SLOT6 : ' + tp.CName[5]);
            datafile.Add('SLOT7 : ' + tp.CName[6]);
            datafile.Add('SLOT8 : ' + tp.CName[7]);
            datafile.Add('SLOT9 : ' + tp.CName[8]);

            CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));

            try
	            datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\ActiveChars.txt');
                //debugout.Lines.Add(tp.Name + ' account active character data saved.');
        	except
                DebugOut.Lines.Add('Account active character data could not be saved.');
        	end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Account Data - Storage ------------------------------------------------------ }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Accounts_Storage(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
    	i, j, k : Integer;
        str : String;
        len : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
        	datafile.Clear;

			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            datafile.Add('    ID :   AMT : EQP : I :  R : A : CARD1 : CARD2 : CARD3 : CARD4 : NAME');
            datafile.Add('---------------------------------------------------------------------------------------------------------');

            for j := 1 to 100 do begin
    	        if tp.Kafra.Item[j].ID <> 0 then begin
	            	str := ' ';

					len := length(IntToStr(tp.Kafra.Item[j].ID));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tp.Kafra.Item[j].ID);
	                str := str + ' : ';

	                len := length(IntToStr(tp.Kafra.Item[j].Amount));
                	for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tp.Kafra.Item[j].Amount);
	                str := str + ' : ';

	                len := length(IntToStr(tp.Kafra.Item[j].Equip));
                	for k := 0 to (3 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
            	    str := str + IntToStr(tp.Kafra.Item[j].Equip);
        	        str := str + ' : ';

    	            str := str + IntToStr(tp.Kafra.Item[j].Identify);
	                str := str + ' : ';

            	    len := length(IntToStr(tp.Kafra.Item[j].Refine));
        	        for k := 0 to (2 - len) - 1 do begin
    	            	str := str + ' ';
	                end;
            	    str := str + IntToStr(tp.Kafra.Item[j].Refine);
        	        str := str + ' : ';
    	            str := str + IntToStr(tp.Kafra.Item[j].Attr);
	                str := str + ' : ';

    	            len := length(IntToStr(tp.Kafra.Item[j].Card[0]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tp.Kafra.Item[j].Card[0]);
	                str := str + ' : ';

    	            len := length(IntToStr(tp.Kafra.Item[j].Card[1]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tp.Kafra.Item[j].Card[1]);
	                str := str + ' : ';

    	            len := length(IntToStr(tp.Kafra.Item[j].Card[2]));
	                for k := 0 to (5 - len) - 1 do begin
            	    	str := str + ' ';
        	        end;
    	            str := str + IntToStr(tp.Kafra.Item[j].Card[2]);
	                str := str + ' : ';

        	        len := length(IntToStr(tp.Kafra.Item[j].Card[3]));
    	            for k := 0 to (5 - len) - 1 do begin
	                	str := str + ' ';
                	end;
            	    str := str + IntToStr(tp.Kafra.Item[j].Card[3]);
        	        str := str + ' : ';

                    str := str + tp.Kafra.Item[j].Data.Name;

    	            datafile.Add(str);
	            end;
            end;

            CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));

            try
	            datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Storage.txt');
                //debugout.Lines.Add(tp.Name + ' account storage data saved.');
            except
            	DebugOut.Lines.Add('Account storage data could not be saved.');
            end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Basic Data ------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then Continue;

                if tc.CID < 100001 then tc.CID := tc.CID + 100001;
                if tc.CID >= NowCharaID then NowCharaID := tc.CID + 1;

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

                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\Character.txt');
                	//debugout.Lines.Add(tp.Name + ' character data saved.');
            	except
            		DebugOut.Lines.Add('Character data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;

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
    { -- Character Data - Memo Data -------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Memos(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j, k : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then Continue;

                for k := 0 to 2 do begin
                	datafile.Add('M'+IntToStr(k+1)+'N : ' + tc.MemoMap[k]);
                    datafile.Add('M'+IntToStr(k+1)+'X : ' + IntToStr(tc.MemoPoint[k].X));
                    datafile.Add('M'+IntToStr(k+1)+'Y : ' + IntToStr(tc.MemoPoint[k].Y));
				end;

                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\ActiveMemos.txt');
                	//debugout.Lines.Add(tp.Name + ' character memo data saved.');
            	except
            		DebugOut.Lines.Add('Character memo data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Skills Data ------------------------------------------------ }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Skills(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j, k, l : Integer;
        str : String;
        len : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then continue;

                datafile.Add(' SID : LV : NAME');
                datafile.Add('----------------------------------');

                for k := 1 to MAX_SKILL_NUMBER do begin
	            	try
    	            	if (tc.Skill[k].Lv <> 0) and (not tc.Skill[k].Card) then begin

        	            	str := ' ';

                	    	len := length(IntToStr(k));
	            		    for l := 0 to (3 - len) - 1 do begin
            		    		str := str + ' ';
	        		        end;
    			            str := str + IntToStr(k);
			                str := str + ' : ';

	                        len := length(IntToStr(tc.Skill[k].Lv));
		            	    for l := 0 to (2 - len) - 1 do begin
        	    		    	str := str + ' ';
        			        end;
    		    	        str := str + IntToStr(tc.Skill[k].Lv);

	                        str := str + ' : ' + tc.Skill[k].Data.IDC;

        	                datafile.Add(str);
						end;
                	except
	                	//debugout.lines.add(tc.name + ' skill ' + inttostr(j) + ' failure.');
    	            end;
                end;

                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\Skills.txt');
                	//debugout.Lines.Add(tp.Name + ' character skills data saved.');
            	except
            		DebugOut.Lines.Add('Character skills data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Inventory Data --------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Inventory(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j, k, l : Integer;
        str : String;
        len : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then continue;


                datafile.Add('    ID :   AMT : EQP : I :  R : A : CARD1 : CARD2 : CARD3 : CARD4 : NAME');
                datafile.Add('---------------------------------------------------------------------------------------------------------');

                for k := 1 to 100 do begin
        	        if tc.Item[k].ID <> 0 then begin
    	            	str := ' ';
    
    					len := length(IntToStr(tc.Item[k].ID));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Item[k].ID);
    	                str := str + ' : ';

    	                len := length(IntToStr(tc.Item[k].Amount));
                    	for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Item[k].Amount);
    	                str := str + ' : ';

	        	        len := length(IntToStr(tc.Item[k].Equip));
        	        	for l := 0 to (3 - len) - 1 do begin
    	        	    	str := str + ' ';
	        	        end;
                	    str := str + IntToStr(tc.Item[k].Equip);
            	        str := str + ' : ';

        	            str := str + IntToStr(tc.Item[k].Identify);
    	                str := str + ' : ';
    
                	    len := length(IntToStr(tc.Item[k].Refine));
            	        for l := 0 to (2 - len) - 1 do begin
        	            	str := str + ' ';
    	                end;
                	    str := str + IntToStr(tc.Item[k].Refine);
            	        str := str + ' : ';
        	            str := str + IntToStr(tc.Item[k].Attr);
    	                str := str + ' : ';
    
        	            len := length(IntToStr(tc.Item[k].Card[0]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Item[k].Card[0]);
    	                str := str + ' : ';
    
        	            len := length(IntToStr(tc.Item[k].Card[1]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Item[k].Card[1]);
    	                str := str + ' : ';

        	            len := length(IntToStr(tc.Item[k].Card[2]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Item[k].Card[2]);
    	                str := str + ' : ';
    
            	        len := length(IntToStr(tc.Item[k].Card[3]));
        	            for l := 0 to (5 - len) - 1 do begin
    	                	str := str + ' ';
                    	end;
                	    str := str + IntToStr(tc.Item[k].Card[3]);
            	        str := str + ' : ';
    
                        str := str + tc.Item[k].Data.Name;
    
        	            datafile.Add(str);
    	            end;
                end;


                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\Inventory.txt');
                	//debugout.Lines.Add(tp.Name + ' character inventory data saved.');
            	except
            		DebugOut.Lines.Add('Character inventory data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Cart Data -------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Cart(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j, k, l : Integer;
        str : String;
        len : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then continue;


                datafile.Add('    ID :   AMT : EQP : I :  R : A : CARD1 : CARD2 : CARD3 : CARD4 : NAME');
                datafile.Add('---------------------------------------------------------------------------------------------------------');

                for k := 1 to 100 do begin
        	        if tc.Cart.Item[k].ID <> 0 then begin
    	            	str := ' ';

    					len := length(IntToStr(tc.Cart.Item[k].ID));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Cart.Item[k].ID);
    	                str := str + ' : ';

    	                len := length(IntToStr(tc.Cart.Item[k].Amount));
                    	for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Cart.Item[k].Amount);
    	                str := str + ' : ';

	        	        len := length(IntToStr(tc.Cart.Item[k].Equip));
        	        	for l := 0 to (3 - len) - 1 do begin
    	        	    	str := str + ' ';
	        	        end;
                	    str := str + IntToStr(tc.Cart.Item[k].Equip);
            	        str := str + ' : ';

        	            str := str + IntToStr(tc.Cart.Item[k].Identify);
    	                str := str + ' : ';
    
                	    len := length(IntToStr(tc.Cart.Item[k].Refine));
            	        for l := 0 to (2 - len) - 1 do begin
        	            	str := str + ' ';
    	                end;
                	    str := str + IntToStr(tc.Cart.Item[k].Refine);
            	        str := str + ' : ';
        	            str := str + IntToStr(tc.Cart.Item[k].Attr);
    	                str := str + ' : ';
    
        	            len := length(IntToStr(tc.Cart.Item[k].Card[0]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Cart.Item[k].Card[0]);
    	                str := str + ' : ';

        	            len := length(IntToStr(tc.Cart.Item[k].Card[1]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Cart.Item[k].Card[1]);
    	                str := str + ' : ';
    
        	            len := length(IntToStr(tc.Cart.Item[k].Card[2]));
    	                for l := 0 to (5 - len) - 1 do begin
                	    	str := str + ' ';
            	        end;
        	            str := str + IntToStr(tc.Cart.Item[k].Card[2]);
    	                str := str + ' : ';
    
            	        len := length(IntToStr(tc.Cart.Item[k].Card[3]));
        	            for l := 0 to (5 - len) - 1 do begin
    	                	str := str + ' ';
                    	end;
                	    str := str + IntToStr(tc.Cart.Item[k].Card[3]);
            	        str := str + ' : ';

                        str := str + tc.Cart.Item[k].Data.Name;
    
        	            datafile.Add(str);
    	            end;
                end;


                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\Cart.txt');
                	//debugout.Lines.Add(tp.Name + ' character cart data saved.');
            	except
            		DebugOut.Lines.Add('Character cart data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Variables Data --------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Variables(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tc : TChara;
    	i, j, k : Integer;
    begin
    	datafile := TStringList.Create;

    	for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 0 to 8 do begin
            	datafile.Clear;
                tc := tp.CData[j];

                if (tc = nil) then continue;

                for k := 0 to tc.Flag.Count - 1 do begin
                	if ((Copy(tc.Flag.Names[k], 1, 1) <> '@') and (Copy(tc.Flag.Names[k], 1, 2) <> '$@'))
                    and ((tc.Flag.Values[tc.Flag.Names[k]] <> '0') and (tc.Flag.Values[tc.Flag.Names[k]] <> '')) then begin
                    	datafile.Add(tc.Flag.Strings[k]);
                    end;
                end;

                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters');
                CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID));

                try
	            	datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Characters\' + IntToStr(tc.CID) + '\Variables.txt');
                	//debugout.Lines.Add(tp.Name + ' character variables data saved.');
            	except
            		DebugOut.Lines.Add('Character variables data could not be saved.');
            	end;

			end;
        end;

        datafile.Clear;
        datafile.Free;
    end;


    { -------------------------------------------------------------------------------- }
    { -- Character Data - Pets Data -------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Save_Characters_Pets(forced : Boolean = False);
    var
    	datafile : TStringList;
        tp : TPlayer;
        tpe : TPet;
        tc : TChara;
    	i, j, k, l : Integer;
    begin

    	datafile := TStringList.Create;

        for i := 0 to PetList.Count - 1 do begin
            tpe := PetList.Objects[i] as TPet;
            tpe.Saved := 0;
        end;

        for i := 0 to PlayerName.Count - 1 do begin
            tp := PlayerName.Objects[i] as TPlayer;

            if (tp.Login = 0) and (not forced) then Continue;

            for j := 1 to 100 do begin
                if (tp.Kafra.Item[j].ID <> 0) and (tp.Kafra.Item[j].Amount > 0) and (tp.Kafra.Item[j].Card[0] = $FF00) then begin
                    for k := 0 to PetList.Count - 1 do begin
                        tpe := PetList.IndexOfObject(k) as TPet;

                        if tp.Kafra.Item[j].Card[1] <> tpe.PetID then Continue;
                        if tpe.PlayerID <> tp.ID then Continue;
                        if tpe.Saved <> 0 then Continue;

                        tpe.Incubated := 0;
                        tpe.CharaID := 0;
                        tpe.Index := 0;

                        datafile.Clear;
                        datafile.Add('AID : ' + IntToStr(tpe.PlayerID));
                        datafile.Add('CID : ' + IntToStr(tpe.CharaID));
                        datafile.Add('CRT : ' + IntToStr(tpe.Cart));
                        datafile.Add('IDX : ' + IntToStr(tpe.Index));
                        datafile.Add('INC : ' + IntToStr(tpe.Incubated));
                        datafile.Add('PID : ' + IntToStr(tpe.PetID));
                        datafile.Add('JID : ' + IntToStr(tpe.JID));
                        datafile.Add('NAM : ' + tpe.Name);
                        datafile.Add('REN : ' + IntToStr(tpe.Renamed));
                        datafile.Add('PLV : ' + IntToStr(tpe.LV));
                        datafile.Add('REL : ' + IntToStr(tpe.Relation));
                        datafile.Add('FUL : ' + IntToStr(tpe.Fullness));
                        datafile.Add('ACC : ' + IntToStr(tpe.Accessory));

                        CreateDir(AppPath + 'gamedata\Accounts');
                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));
                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets');
                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets\' + IntToStr(tpe.PetID));

                        datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets\' + IntToStr(tpe.PetID) + '\Pet.txt');

                        tpe.Saved := 1;
                    end;
                end;
            end;

            for l := 0 to 8 do begin
                tc := tp.CData[l];

                if (tc = nil) then Continue;

	            for j := 1 to 100 do begin
	                if (tc.Item[j].ID <> 0) and (tc.Item[j].Amount > 0) and (tc.Item[j].Card[0] = $FF00) then begin
	                    for k := 0 to PetList.Count - 1 do begin
	                        tpe := PetList.IndexOfObject(k) as TPet;
	
	                        if tc.Item[j].Card[1] <> tpe.PetID then Continue;
	                        if tpe.CharaID <> tc.CID then Continue;
	                        if tpe.Saved <> 0 then Continue;

	                        datafile.Clear;
	                        datafile.Add('AID : ' + IntToStr(tpe.PlayerID));
	                        datafile.Add('CID : ' + IntToStr(tpe.CharaID));
	                        datafile.Add('CRT : ' + IntToStr(tpe.Cart));
	                        datafile.Add('IDX : ' + IntToStr(tpe.Index));
	                        datafile.Add('INC : ' + IntToStr(tpe.Incubated));
	                        datafile.Add('PID : ' + IntToStr(tpe.PetID));
	                        datafile.Add('JID : ' + IntToStr(tpe.JID));
	                        datafile.Add('NAM : ' + tpe.Name);
	                        datafile.Add('REN : ' + IntToStr(tpe.Renamed));
	                        datafile.Add('PLV : ' + IntToStr(tpe.LV));
	                        datafile.Add('REL : ' + IntToStr(tpe.Relation));
	                        datafile.Add('FUL : ' + IntToStr(tpe.Fullness));
	                        datafile.Add('ACC : ' + IntToStr(tpe.Accessory));

	                        CreateDir(AppPath + 'gamedata\Accounts');
	                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID));
	                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets');
	                        CreateDir(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets\' + IntToStr(tpe.PetID));

	                        datafile.SaveToFile(AppPath + 'gamedata\Accounts\' + IntToStr(tp.ID) + '\Pets\' + IntToStr(tpe.PetID) + '\Pet.txt');

	                        tpe.Saved := 1;
	                    end;
	                end;
	            end;
            end;

        end;

        datafile.Clear;
        datafile.Free;
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
    procedure PD_Load_Guilds_Positions(UID : String = '*');
    var
    	searchResult : TSearchRec;
        datafile : TStringList;
        sl : TStringList;
        tp : TPlayer;
        tg : TGuild;
        i : Integer;
        saveflag : Boolean;
    begin
    	SetCurrentDir(AppPath+'gamedata\Guilds');
        datafile := TStringList.Create;
        sl := TStringList.Create;

    	if FindFirst('*', faDirectory, searchResult) = 0 then repeat
        	if FileExists(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Positions.txt') then begin

            	try
                    saveflag := False;
                    tg := nil;
                	datafile.LoadFromFile(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Positions.txt');

                    sl.delimiter := ':';

                    if (UID <> '*') then begin

                    	if Player.IndexOf(StrToInt(UID)) = -1 then Continue;
                        tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

                        for i := 0 to 8 do begin
    	                    if tp.CName[i] = '' then Continue;
                            if tp.CData[i] = nil then Continue;

                            if tp.CData[i].GuildName <> searchResult.Name then Continue
                            else tg := GuildList.Objects[GuildList.IndexOf(tp.CData[i].GuildID)] as TGuild;

                            if assigned(tg) then Break;
                        end;

                        if tg = nil then Continue;

                    end else begin
                        for i := 0 to GuildList.Count - 1 do begin
                            tg := GuildList.Objects[i] as TGuild;
                            if tg.ID = StrToInt(searchResult.Name) then Break;
                        end;
                    end;

                    if not assigned(tg) then Continue;

                    for i := 0 to datafile.Count - 3 do begin
                    	if tg.MemberID[i] <> 0 then begin
                            if not assigned(tg.Member[i]) then Break;
                         	if tg.Member[i].Login <> 0 then begin
                            	saveflag := True;
                                Break;
                            end;
                        end;
                    end;

                    if saveflag then Continue;

                    for i := 0 to 19 do begin
                    	sl.delimiter := ':';
                        sl.delimitedtext  := space_in(datafile[i+2]);

                    	tg.PosName[i] := trim(space_out(sl.Strings[4]));

                        if (trim(space_out(sl.Strings[1])) = 'Y') then tg.PosInvite[i] := True
                        else if (trim(space_out(sl.Strings[1])) = 'Y') then tg.PosInvite[i] := False;

                        if (trim(space_out(sl.Strings[1])) = 'Y') then tg.PosPunish[i] := True
                        else if (trim(space_out(sl.Strings[1])) = 'Y') then tg.PosPunish[i] := False;

                        tg.PosEXP[i] := StrToInt(trim(space_out(sl.Strings[3])));
                    end;

                    //debugout.Lines.Add(tg.Name + ' guild position data loaded.');
                except
                	DebugOut.Lines.Add('Guild position data could not be loaded.');
                end;
            end;

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        sl.Free;
        datafile.Clear;
        datafile.Free;
    end;

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
    procedure PD_Load_Guilds_Skills(UID : String = '*');
    var
    	searchResult : TSearchRec;
        datafile : TStringList;
        sl : TStringList;
        tp : TPlayer;
        tg : TGuild;
        i, j : Integer;
        saveflag : Boolean;
    begin
    	SetCurrentDir(AppPath+'gamedata\Guilds');
        datafile := TStringList.Create;
        sl := TStringList.Create;

    	if FindFirst('*', faDirectory, searchResult) = 0 then repeat
        	if FileExists(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Skills.txt') then begin

            	try
                    saveflag := False;
                    tg := nil;
                	datafile.LoadFromFile(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Skills.txt');
                    sl.delimiter := ':';

                    if (UID <> '*') then begin

                    	if Player.IndexOf(StrToInt(UID)) = -1 then Continue;
                        tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

                        for i := 0 to 8 do begin
    	                    if tp.CName[i] = '' then Continue;
                            if tp.CData[i] = nil then Continue;

                            if tp.CData[i].GuildName <> searchResult.Name then Continue
                            else tg := GuildList.Objects[GuildList.IndexOf(tp.CData[i].GuildID)] as TGuild;

                            if assigned(tg) then Break;
                        end;

                        if tg = nil then Continue;

                    end else begin
                        for i := 0 to GuildList.Count - 1 do begin
                            tg := GuildList.Objects[i] as TGuild;
                            if tg.ID = StrToInt(searchResult.Name) then Break;
                        end;
                    end;

                    if not assigned(tg) then Continue;

                    for i := 0 to datafile.Count - 3 do begin
                        if not assigned(tg.Member[i]) then tg.MemberID[i] := 0;
                    	if tg.MemberID[i] <> 0 then begin
                        	if tg.Member[i].Login <> 0 then begin
                            	saveflag := True;
                                Break;
                            end;
                        end;
                    end;

                    if saveflag then Continue;

                    for i := 10000 to 10004 do begin
                        if GSkillDB.IndexOf(i) <> -1 then begin
                        	tg.GSkill[i].Data := GSkillDB.IndexOfObject(i) as TSkillDB;
                        end;
                    end;

                    for i := 0 to datafile.Count - 3 do begin
                    	sl.delimiter := ':';
                        sl.delimitedtext := datafile[i+2];

                    	if GSkillDB.IndexOf(StrToInt(sl.Strings[0])) <> -1 then begin
                        	j := StrToInt(sl.Strings[0]);
                            tg.GSkill[j].Lv := StrToInt(sl.Strings[1]);
                            tg.GSkill[j].Card := False;
                        end;
                    end;

                    tg.MaxUsers := 16;
                    if (tg.GSkill[10004].Lv > 0) then begin
                        tg.MaxUsers := tg.MaxUsers + tg.GSkill[10004].Data.Data1[tg.GSkill[10004].Lv];
                    end;

                    //debugout.Lines.Add(tg.Name + ' guild skill data loaded.');
                except
                	DebugOut.Lines.Add('Guild skill data could not be loaded.');
                end;
            end;

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        sl.Free;
        datafile.Clear;
        datafile.Free;
    end;

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
    procedure PD_Load_Guilds_BanList(UID : String = '*');
    var
    	searchResult : TSearchRec;
        datafile : TStringList;
        sl : TStringList;
        tp : TPlayer;
        tg : TGuild;
        tgb : TGBan;
        i : Integer;
        saveflag : Boolean;
    begin
    	SetCurrentDir(AppPath+'gamedata\Guilds');
        datafile := TStringList.Create;
        sl := TStringList.Create;

    	if FindFirst('*', faDirectory, searchResult) = 0 then repeat
        	if FileExists(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\BanList.txt') then begin

            	try
                    saveflag := False;
                    tg := nil;
                	datafile.LoadFromFile(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\BanList.txt');
                    sl.delimiter := ':';

                    if (UID <> '*') then begin

                    	if Player.IndexOf(StrToInt(UID)) = -1 then Continue;
                        tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

                        for i := 0 to 8 do begin
    	                    if tp.CName[i] = '' then Continue;
                            if tp.CData[i] = nil then Continue;

                            if tp.CData[i].GuildName <> searchResult.Name then Continue
                            else tg := GuildList.Objects[GuildList.IndexOf(tp.CData[i].GuildID)] as TGuild;

                            if assigned(tg) then Break;
                        end;

                        if tg = nil then Continue;

                    end else begin
                        for i := 0 to GuildList.Count - 1 do begin
                            tg := GuildList.Objects[i] as TGuild;
                            if tg.ID = StrToInt(searchResult.Name) then Break;
                        end;
                    end;

                    if not assigned(tg) then Continue;

                    for i := 0 to datafile.Count - 3 do begin
                        if not assigned(tg.Member[i]) then tg.MemberID[i] := 0;
                    	if tg.MemberID[i] <> 0 then begin
                        	if tg.Member[i].Login <> 0 then begin
                            	saveflag := True;
                                Break;
                            end;
                        end;
                    end;

                    if saveflag then Continue;

                    for i := 0 to tg.GuildBanList.Count - 1 do begin
                        tgb := tg.GuildBanList.Objects[0] as TGBan;
                        tg.GuildBanList.Delete(0);
                        tgb.Free;
                    end;

                    for i := 0 to datafile.Count - 3 do begin
                    	sl.delimiter := ':';

                        sl.delimitedtext  := space_in(datafile[i+2]);

                        tgb := TGBan.Create;
                        tgb.Name := trim(space_out(sl.Strings[0]));
                        tgb.AccName := trim(space_out(sl.Strings[1]));
                        tgb.Reason := trim(space_out(sl.Strings[2]));

                        tg.GuildBanList.AddObject(tgb.Name, tgb);
                    end;

                    //debugout.Lines.Add(tg.Name + ' guild ban data loaded.');
                except
                	DebugOut.Lines.Add('Guild ban data could not be loaded.');
                end;
            end;

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        sl.Free;
        datafile.Clear;
        datafile.Free;
    end;


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
    procedure PD_Load_Guilds_Diplomacy(UID : String = '*');
    var
    	searchResult : TSearchRec;
        datafile : TStringList;
        sl : TStringList;
        tp : TPlayer;
        tg : TGuild;
        tgl : TGRel;
        i : Integer;
        saveflag : Boolean;
    begin
    	SetCurrentDir(AppPath+'gamedata\Guilds');
        datafile := TStringList.Create;
        sl := TStringList.Create;

    	if FindFirst('*', faDirectory, searchResult) = 0 then repeat
        	if FileExists(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Diplomacy.txt') then begin

            	try
                    saveflag := False;
                    tg := nil;
                	datafile.LoadFromFile(AppPath + 'gamedata\Guilds\' + searchResult.Name + '\Diplomacy.txt');
                    sl.delimiter := ':';

                    if (UID <> '*') then begin

                    	if Player.IndexOf(StrToInt(UID)) = -1 then Continue;
                        tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

                        for i := 0 to 8 do begin
    	                    if tp.CName[i] = '' then Continue;
                            if tp.CData[i] = nil then Continue;

                            if tp.CData[i].GuildName <> searchResult.Name then Continue
                            else tg := GuildList.Objects[GuildList.IndexOf(tp.CData[i].GuildID)] as TGuild;

                            if assigned(tg) then Break;
                        end;

                        if tg = nil then Continue;

                    end else begin
                        for i := 0 to GuildList.Count - 1 do begin
                            tg := GuildList.Objects[i] as TGuild;
                            if tg.ID = StrToInt(searchResult.Name) then Break;
                        end;
                    end;

                    if not assigned(tg) then Continue;

                    for i := 0 to datafile.Count - 3 do begin
                    	if tg.MemberID[i] <> 0 then begin
                        	if tg.Member[i].Login <> 0 then begin
                            	saveflag := True;
                                Break;
                            end;
                        end;
                    end;

                    if saveflag then Continue;

                    for i := 0 to tg.RelAlliance.Count - 1 do begin
                        tgl := tg.RelAlliance.Objects[i] as TGRel;
                        tg.RelAlliance.Delete(i);
                        tgl.Free;
                    end;

                    for i := 0 to tg.RelHostility.Count - 1 do begin
                        tgl := tg.RelHostility.Objects[i] as TGRel;
                        tg.RelHostility.Delete(i);
                        tgl.Free;
                    end;

                    for i := 0 to datafile.Count - 3 do begin
                    	sl.delimiter := ':';
                        sl.delimitedtext := datafile[i+2];

                        tgl := TGRel.Create;

                        tgl.ID := StrToInt(sl.Strings[0]);
                        tgl.GuildName := sl.Strings[2];

                        if (sl.Strings[1] = 'A') then
                            tg.RelAlliance.AddObject(tgl.GuildName, tgl)
                        else if (sl.Strings[1] = 'H') then
                            tg.RelHostility.AddObject(tgl.GuildName, tgl)
                        else
                            Continue;
                    end;

                    //debugout.Lines.Add(tg.Name + ' guild diplomacy data loaded.');
                except
                	DebugOut.Lines.Add('Guild diplomacy data could not be loaded.');
                end;
            end;

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        sl.Free;
        datafile.Clear;
        datafile.Free;
    end;

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


    { -------------------------------------------------------------------------------- }
    { -- Castle Data - Basic Data ---------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
    procedure PD_Load_Castles(UID : String = '*');
    var
    	searchResult : TSearchRec;
        datafile : TStringList;
        sl : TStringList;
        tp : TPlayer;
        tg : TGuild;
        tgc : TCastle;
        i : Integer;
        saveflag : Boolean;
    begin
    	SetCurrentDir(AppPath+'gamedata\Castles');
        datafile := TStringList.Create;
        sl := TStringList.Create;
        saveflag := False;

    	if FindFirst('*', faDirectory, searchResult) = 0 then repeat
        	if FileExists(AppPath + 'gamedata\Castles\' + searchResult.Name + '\Castle.txt') then begin

            	try
                	datafile.LoadFromFile(AppPath + 'gamedata\Castles\' + searchResult.Name + '\Castle.txt');
                    sl.delimiter := ':';

                    tg := nil;
                    tgc := nil;

                    if (UID <> '*') then begin

                    	if Player.IndexOf(StrToInt(UID)) = -1 then Continue;
                        tp := Player.Objects[Player.IndexOf(StrToInt(UID))] as TPlayer;

                        for i := 0 to 8 do begin
    	                    if tp.CName[i] = '' then Continue;

                            if tp.CData[i] = nil then Continue;

                            sl.DelimitedText := datafile[1];
                            if (tp.CData[i].GuildID = StrToint(sl.Strings[1])) then begin
                            	if GuildList.IndexOf(tp.CData[i].GuildID) = -1 then Continue;
                                tg := GuildList.Objects[GuildList.IndexOf(tp.CData[i].GuildID)] as TGuild;
                                tgc := CastleList.Objects[CastleList.IndexOf(searchResult.Name)] as TCastle;
                                Break;
                            end;
                        end;

                        if tg = nil then Continue;
                        if tgc = nil then Continue;

                	end else begin
                        tgc := TCastle.Create;
                    end;

                    if assigned(tg) then begin
                        for i := 0 to tg.RegUsers - 1 do begin
                            if not assigned(tg.Member[i]) then tg.MemberID[i] := 0;
                        	if tg.MemberID[i] <> 0 then begin
                            	if tg.Member[i].Login <> 0 then begin
                                	saveflag := True;
                                    Break;
                                end;
                            end;
                        end;
                    end;

                    if saveflag then Continue;

                    tgc.Name := ( Copy(datafile[0], Pos(' : ', datafile[0]) + 3, length(datafile[0]) - Pos(' : ', datafile[0]) + 3) );
                    tgc.GID := StrToInt( Copy(datafile[1], Pos(' : ', datafile[1]) + 3, length(datafile[1]) - Pos(' : ', datafile[1]) + 3) );
                    tgc.GName := ( Copy(datafile[2], Pos(' : ', datafile[2]) + 3, length(datafile[2]) - Pos(' : ', datafile[2]) + 3) );
                    tgc.GMName := ( Copy(datafile[3], Pos(' : ', datafile[3]) + 3, length(datafile[3]) - Pos(' : ', datafile[3]) + 3) );
                    tgc.GKafra := StrToInt( Copy(datafile[4], Pos(' : ', datafile[4]) + 3, length(datafile[4]) - Pos(' : ', datafile[4]) + 3) );
                    tgc.EDegree := StrToInt( Copy(datafile[5], Pos(' : ', datafile[5]) + 3, length(datafile[5]) - Pos(' : ', datafile[5]) + 3) );
                    tgc.ETrigger := StrToInt( Copy(datafile[6], Pos(' : ', datafile[6]) + 3, length(datafile[6]) - Pos(' : ', datafile[6]) + 3) );
                    tgc.DDegree := StrToInt( Copy(datafile[7], Pos(' : ', datafile[7]) + 3, length(datafile[7]) - Pos(' : ', datafile[7]) + 3) );
                    tgc.DTrigger := StrToInt( Copy(datafile[8], Pos(' : ', datafile[8]) + 3, length(datafile[8]) - Pos(' : ', datafile[8]) + 3) );
                    tgc.GuardStatus[0] := StrToInt( Copy(datafile[9], Pos(' : ', datafile[9]) + 3, length(datafile[9]) - Pos(' : ', datafile[9]) + 3) );
                    tgc.GuardStatus[1] := StrToInt( Copy(datafile[10], Pos(' : ', datafile[10]) + 3, length(datafile[10]) - Pos(' : ', datafile[10]) + 3) );
                    tgc.GuardStatus[2] := StrToInt( Copy(datafile[11], Pos(' : ', datafile[11]) + 3, length(datafile[11]) - Pos(' : ', datafile[11]) + 3) );
                    tgc.GuardStatus[3] := StrToInt( Copy(datafile[12], Pos(' : ', datafile[12]) + 3, length(datafile[12]) - Pos(' : ', datafile[12]) + 3) );
                    tgc.GuardStatus[4] := StrToInt( Copy(datafile[13], Pos(' : ', datafile[13]) + 3, length(datafile[13]) - Pos(' : ', datafile[13]) + 3) );
                    tgc.GuardStatus[5] := StrToInt( Copy(datafile[14], Pos(' : ', datafile[14]) + 3, length(datafile[14]) - Pos(' : ', datafile[14]) + 3) );
                    tgc.GuardStatus[6] := StrToInt( Copy(datafile[15], Pos(' : ', datafile[15]) + 3, length(datafile[15]) - Pos(' : ', datafile[15]) + 3) );
                    tgc.GuardStatus[7] := StrToInt( Copy(datafile[16], Pos(' : ', datafile[16]) + 3, length(datafile[16]) - Pos(' : ', datafile[16]) + 3) );

                    if (UID = '*') then
                        CastleList.AddObject(tgc.Name, tgc);

                    //debugout.Lines.Add(tgc.Name + ' castle data loaded.');
                except
                	DebugOut.Lines.Add('Castle data could not be loaded.');
                end;
            end;

        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        sl.Free;
        datafile.Clear;
        datafile.Free;
    end;

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


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
    REED_SAVE_PETS,
    REED_SAVE_PARTIES,
    REED_SAVE_GUILDS;

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


    { Guild Data - Basic Data }
    procedure PD_Delete_Guilds(tg : TGuild);


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
        PD_Save_Parties_Parse(forced);
        PD_Save_Guilds_Parse(forced);

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
    { -- Guild Data - Basic Data ----------------------------------------------------- }
    { -------------------------------------------------------------------------------- }
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


unit JCon;

interface

uses
	SysUtils, WinSock,
	Common, Database, WeissINI;

	procedure JCon_Accounts_Load();
    procedure JCon_Accounts_Populate();
    procedure JCon_Accounts_Clear();
    procedure JCon_Accounts_Save();
    procedure JCon_Accounts_Delete();

    procedure JCon_INI_Server_Load();
    procedure JCon_INI_Server_Save();

    procedure JCon_INI_Game_Load();
    procedure JCon_INI_Game_Save();

implementation

uses
	Main;

	procedure JCon_Accounts_Load();
    var
		i : Integer;
    	AccountItem : TPlayer;
	begin

		frmMain.ListBox1.Clear;

		for i := 0 to (PlayerName.Count - 1) do begin
			AccountItem := PlayerName.Objects[i] as TPlayer;
	        frmMain.listbox1.Items.AddObject(PlayerName.Strings[i], AccountItem);
    	    frmMain.listbox1.Sorted := True;
	    end;
    end;


    procedure JCon_Accounts_Populate();
	var
    	AccountItem : TPlayer;
	begin
    	if (frmMain.listbox1.ItemIndex = -1) then Exit;

		AccountItem := frmMain.listbox1.Items.Objects[frmMain.listbox1.ItemIndex] as TPlayer;
	    frmMain.Edit2.Text := IntToStr(AccountItem.ID);
    	frmMain.Edit3.Text := AccountItem.Name;
	    frmMain.Edit4.Text := AccountItem.Pass;
        frmMain.ComboBox15.ItemIndex := AccountItem.Gender;
	    frmMain.Edit6.Text := AccountItem.Mail;
        frmMain.ComboBox18.ItemIndex := AccountItem.Banned;
	    frmMain.Edit8.Text := AccountItem.CName[0];
    	frmMain.Edit9.Text := AccountItem.CName[1];
	    frmMain.Edit10.Text := AccountItem.CName[2];
    	frmMain.Edit11.Text := AccountItem.CName[3];
	    frmMain.Edit12.Text := AccountItem.CName[4];
    	frmMain.Edit13.Text := AccountItem.CName[5];
	    frmMain.Edit14.Text := AccountItem.CName[6];
    	frmMain.Edit15.Text := AccountItem.CName[7];
	    frmMain.Edit16.Text := AccountItem.CName[8];
    end;


    procedure JCon_Accounts_Clear();
    begin
	    frmMain.Edit2.Clear;
    	frmMain.Edit3.Clear;
	    frmMain.Edit4.Clear;
    	frmMain.ComboBox15.Text := '';
	    frmMain.Edit6.Clear;
    	frmMain.ComboBox18.Text := '';
	    frmMain.Edit8.Clear;
    	frmMain.Edit9.Clear;
	    frmMain.Edit10.Clear;
    	frmMain.Edit11.Clear;
	    frmMain.Edit12.Clear;
    	frmMain.Edit13.Clear;
	    frmMain.Edit14.Clear;
    	frmMain.Edit15.Clear;
	    frmMain.Edit16.Clear;
    end;


    procedure JCon_Accounts_Save();
	var
	    AccountItem, tp2 : TPlayer;
    	tc : TChara;
	    i, Idx : Integer;
	begin
    	if (frmMain.Edit3.Text = '') then begin
        	Exit;
        end else if PlayerName.IndexOf(frmMain.Edit3.Text) <> -1 then begin
			AccountItem := PlayerName.Objects[PlayerName.IndexOf(frmMain.Edit3.Text)] as TPlayer;

	    	for i := 0 to 8 do begin
    	    	tc := AccountItem.CData[i];
        	    if assigned(tc) then begin
	        	    if assigned(tc.Socket) then begin
    	        		tc.Socket.Close;
	                    tc.Socket := nil;
    	            end;
        	    end;
	        end;

		    AccountItem.ID := StrToInt(frmMain.Edit2.Text);
        	AccountItem.Name := frmMain.Edit3.Text;
	        AccountItem.Pass := frmMain.Edit4.Text;
    	    AccountItem.Gender := frmMain.ComboBox15.ItemIndex;
        	AccountItem.Mail := frmMain.Edit6.Text;
	        AccountItem.Banned := frmMain.ComboBox18.ItemIndex;
		    DataSave();
        end else begin

        	for i := 0 to PlayerName.Count - 1 do begin
            	tp2 := PlayerName.Objects[i] as TPlayer;
                if (tp2.ID <> i + 100101) then begin
                	Idx := i + 100101;
                    Break;
                end;
            end;

            if (i = PlayerName.Count) then Idx := 100101 + PlayerName.Count;

    		AccountItem := TPlayer.Create;
	    	AccountItem.ID := Idx;
	        AccountItem.Name := frmMain.Edit3.Text;
    	    AccountItem.Pass := frmMain.Edit4.Text;
        	AccountItem.Gender := frmMain.ComboBox15.ItemIndex;
	        AccountItem.Mail := frmMain.Edit6.Text;
    		PlayerName.InsertObject(i, AccountItem.Name, AccountItem);
    		Player.AddObject(AccountItem.ID, AccountItem);
	        DataSave();
    	    frmMain.Button3.Click;
        end;

        JCon_Accounts_Load();
    end;

    procedure JCon_Accounts_Delete();
    begin
    	if (frmMain.Edit3.Text = '') then begin
        	Exit;
        end else begin
        	PlayerName.Delete(PlayerName.IndexOf(frmMain.Edit3.Text));
        end;

        JCon_Accounts_Load();
        frmMain.Button3.Click;
    end;


    procedure JCon_INI_Server_Load();
    begin
		frmMain.Edit17.Text := inet_ntoa(in_addr(ServerIP));
		frmMain.Edit18.Text := ServerName;
	    frmMain.Edit19.Text := IntToStr(DefaultNPCID);
    	frmMain.Edit20.Text := IntToStr(sv1port);
    	frmMain.Edit21.Text := IntToStr(sv2port);
	    frmMain.Edit22.Text := IntToStr(sv3port);

        frmMain.ComboBox1.ItemIndex := abs(StrToInt(BoolToStr(UseSQL)));
        frmMain.Edit24.Text := DBHost;
        frmMain.Edit23.Text := DBUser;
        frmMain.Edit25.Text := DBPass;
        frmMain.Edit26.Text := DBName;

        frmMain.ComboBox2.ItemIndex := abs(StrToInt(BoolToStr(AutoStart)));
        frmMain.Edit29.Text := IntToStr(Option_MaxUsers);
        frmMain.ComboBox3.ItemIndex := abs(StrToInt(BoolToStr(Option_Username_MF)));

        frmMain.Edit31.Text := IntToStr(Option_AutoSave div 60);
        frmMain.Edit30.Text := IntToStr(Option_AutoBackup div 60);
        frmMain.ComboBox4.ItemIndex := abs(StrToInt(BoolToStr(Option_GM_Logs)));

        frmMain.ComboBox5.ItemIndex := abs(StrToInt(BoolToStr(ShowDebugErrors)));
        frmMain.ComboBox6.ItemIndex := abs(StrToInt(BoolToStr(WarpDebugFlag)));
        frmMain.ComboBox7.ItemIndex := abs(StrToInt(BoolToStr(Timer)));

        frmMain.ComboBox8.ItemIndex := Priority;
        frmMain.ComboBox17.ItemIndex := abs(StrToInt(BoolToStr(EnableLowerClassDyes)));
    end;


    procedure JCon_INI_Server_Save();
    var
		i : Integer;
	begin
		ServerIP := cardinal(inet_addr(PChar(frmMain.Edit17.Text)));
		ServerName := frmMain.Edit18.Text;
    	DefaultNPCID := StrToInt(frmMain.Edit19.Text);

		if (frmMain.Edit20.Text <> frmMain.Edit21.Text) and (frmMain.Edit20.Text <> frmMain.Edit22.Text) and (frmMain.Edit21.Text <> frmMain.Edit22.Text) then begin
		    sv1port := StrToInt(frmMain.Edit20.Text);
    		sv2port := StrToInt(frmMain.Edit21.Text);
		    sv3port := StrToInt(frmMain.Edit22.Text);
    	end;

	    if (frmMain.sv1.port <> sv1port) or (frmMain.sv2.port <> sv2port) or (frmMain.sv3.port <> sv3port) then begin

		    for i := 0 to frmMain.sv1.Socket.ActiveConnections - 1 do
    			frmMain.sv1.Socket.Disconnect(i);
		    for i := 0 to frmMain.sv2.Socket.ActiveConnections - 1 do
    			frmMain.sv2.Socket.Disconnect(i);
	    	for i := 0 to frmMain.sv3.Socket.ActiveConnections - 1 do
    			frmMain.sv3.Socket.Disconnect(i);

		    frmMain.sv1.Active := False;
    		frmMain.sv2.Active := False;
	    	frmMain.sv3.Active := False;

		    frmMain.sv1.port := sv1port;
		    frmMain.sv2.port := sv2port;
	    	frmMain.sv3.port := sv3port;

		    frmMain.sv1.Active := True;
    		frmMain.sv2.Active := True;
	    	frmMain.sv3.Active := True;
	    end;

        UseSQL := StrToBool(IntToStr(abs(frmMain.ComboBox1.ItemIndex)));
        DBHost := frmMain.Edit24.Text;
        DBUser := frmMain.Edit23.Text;
        DBPass := frmMain.Edit25.Text;
        DBName := frmMain.Edit26.Text;

        AutoStart := StrToBool(IntToStr(abs(frmMain.ComboBox2.ItemIndex)));
        Option_MaxUsers := StrToInt(frmMain.Edit29.Text);
        Option_Username_MF := StrToBool(IntToStr(abs(frmMain.ComboBox3.ItemIndex)));

        Option_AutoSave := 60 * StrToInt(frmMain.Edit31.Text);
        Option_AutoBackup := 60 * StrToInt(frmMain.Edit30.Text);
        Option_GM_Logs := StrToBool(IntToStr(abs(frmMain.ComboBox4.ItemIndex)));

        ShowDebugErrors := StrToBool(IntToStr(abs(frmMain.ComboBox5.ItemIndex)));
        WarpDebugFlag := StrToBool(IntToStr(abs(frmMain.ComboBox6.ItemIndex)));
        Timer := StrToBool(IntToStr(abs(frmMain.ComboBox7.ItemIndex)));

        Priority := frmMain.ComboBox8.ItemIndex;
        frmMain.PriorityUpdate(Priority);
        EnableLowerClassDyes := StrToBool(IntToStr(abs(frmMain.ComboBox17.ItemIndex)));

		weiss_ini_save();
    end;

    procedure JCon_INI_Game_Load();
    begin
    	frmMain.Edit42.Text := IntToStr(BaseExpMultiplier);
        frmMain.Edit37.Text := IntToStr(JobExpMultiplier);
        frmMain.Edit38.Text := IntToStr(ItemDropMultiplier);

        frmMain.Edit39.Text := IntToStr(StealMultiplier);
        frmMain.Edit40.Text := IntToStr(Option_Pet_Capture_Rate);

        frmMain.ComboBox16.ItemIndex := abs(StrToInt(BoolToStr(DisableLevelLimit)));
        frmMain.ComboBox9.ItemIndex := abs(StrToInt(BoolToStr(DisableEquipLimit)));
        frmMain.ComboBox10.ItemIndex := abs(StrToInt(BoolToStr(EnablePetSkills)));
        frmMain.ComboBox11.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP)));
        frmMain.ComboBox12.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP_Steal)));
        frmMain.ComboBox13.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP_XPLoss)));

        frmMain.Edit35.Text := IntToStr(DefaultZeny);
        frmMain.Edit43.Text := IntToStr(DefaultItem1);
        frmMain.Edit44.Text := IntToStr(DefaultItem2);
        frmMain.Edit27.Text := DefaultMap;
        frmMain.Edit28.Text := IntToStr(DefaultPoint_X);
        frmMain.Edit45.Text := IntToStr(DefaultPoint_Y);

        frmMain.Edit32.Text := IntToStr(DeathBaseLoss);
        frmMain.Edit33.Text := IntToStr(DeathJobLoss);
        frmMain.Edit34.Text := IntToStr(Option_PartyShare_Level);
        frmMain.ComboBox14.ItemIndex := abs(StrToInt(BoolToStr(DisableSkillLimit)));

    end;

    procedure JCon_INI_Game_Save();
    begin
        BaseExpMultiplier := StrToInt(frmMain.Edit42.Text);
        JobExpMultiplier := StrToInt(frmMain.Edit37.Text);
        ItemDropMultiplier := StrToInt(frmMain.Edit38.Text);

        StealMultiplier := StrToInt(frmMain.Edit39.Text);
        Option_Pet_Capture_Rate := StrToInt(frmMain.Edit40.Text);

        DisableLevelLimit := StrToBool(IntToStr(abs(frmMain.ComboBox16.ItemIndex)));
        DisableEquipLimit := StrToBool(IntToStr(abs(frmMain.ComboBox9.ItemIndex)));
        EnablePetSkills := StrToBool(IntToStr(abs(frmMain.ComboBox10.ItemIndex)));
        Option_PVP := StrToBool(IntToStr(abs(frmMain.ComboBox11.ItemIndex)));
        Option_PVP_Steal := StrToBool(IntToStr(abs(frmMain.ComboBox12.ItemIndex)));
        Option_PVP_XPLoss := StrToBool(IntToStr(abs(frmMain.ComboBox13.ItemIndex)));

        DefaultZeny := StrToInt(frmMain.Edit35.Text);
        DefaultItem1 := StrToInt(frmMain.Edit43.Text);
        DefaultItem2 := StrToInt(frmMain.Edit44.Text);
        DefaultMap := frmMain.Edit27.Text;
        DefaultPoint_X := StrToInt(frmMain.Edit28.Text);
        DefaultPoint_Y := StrToInt(frmMain.Edit45.Text);

        DeathBaseLoss := StrToInt(frmMain.Edit32.Text);
        DeathJobLoss := StrToInt(frmMain.Edit33.Text);
        Option_PartyShare_Level := StrToInt(frmMain.Edit34.Text);
        DisableSkillLimit := StrToBool(IntToStr(abs(frmMain.ComboBox14.ItemIndex)));

		weiss_ini_save();
    end;

end.

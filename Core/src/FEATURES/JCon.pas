unit JCon;

interface

uses
    {$IFDEF MSWINDOWS}
	WinSock,
    {$ENDIF}
    {Shared}
    SysUtils,
    {Fusion}
	Common, Database, WeissINI, Globals, Game_Master, PlayerData;

	procedure JCon_Accounts_Load();
    procedure JCon_Accounts_Populate();
    procedure JCon_Accounts_Clear();
    procedure JCon_Accounts_Save();
    procedure JCon_Accounts_Delete();
    procedure JCon_Accounts_Chara_Delete(str : String);

    procedure JCon_INI_Server_Load();
    procedure JCon_INI_Server_Save();

    procedure JCon_INI_Game_Load();
    procedure JCon_INI_Game_Save();
    //procedure JCon_Character_Save();

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
        frmMain.ComboBox15.ItemIndex := -1;
        frmMain.ComboBox15.ItemIndex := AccountItem.Gender;
	    frmMain.Edit6.Text := AccountItem.Mail;
        frmMain.ComboBox18.ItemIndex := -1;
        frmMain.ComboBox18.ItemIndex := AccountItem.Banned;

        if AccountItem.CName[0] <> '' then frmMain.Button7.Caption := AccountItem.CName[0]
        else frmMain.Button7.Caption := '';
        if AccountItem.CName[1] <> '' then frmMain.Button8.Caption := AccountItem.CName[1]
        else frmMain.Button8.Caption := '';
        if AccountItem.CName[2] <> '' then frmMain.Button9.Caption := AccountItem.CName[2]
        else frmMain.Button9.Caption := '';
        if AccountItem.CName[3] <> '' then frmMain.Button10.Caption := AccountItem.CName[3]
        else frmMain.Button10.Caption := '';
        if AccountItem.CName[4] <> '' then frmMain.Button11.Caption := AccountItem.CName[4]
        else frmMain.Button11.Caption := '';
        if AccountItem.CName[5] <> '' then frmMain.Button12.Caption := AccountItem.CName[5]
        else frmMain.Button12.Caption := '';
        if AccountItem.CName[6] <> '' then frmMain.Button13.Caption := AccountItem.CName[6]
        else frmMain.Button13.Caption := '';
        if AccountItem.CName[7] <> '' then frmMain.Button14.Caption := AccountItem.CName[7]
        else frmMain.Button14.Caption := '';
        if AccountItem.CName[8] <> '' then frmMain.Button15.Caption := AccountItem.CName[8]
        else frmMain.Button15.Caption := '';
    end;


    procedure JCon_Accounts_Clear();
    begin
	    frmMain.Edit2.Clear;
    	frmMain.Edit3.Clear;
	    frmMain.Edit4.Clear;
    	frmMain.ComboBox15.Text := '';
	    frmMain.Edit6.Clear;
    	frmMain.ComboBox18.Text := '';
        frmMain.Button7.Caption := '';
        frmMain.Button8.Caption := '';
        frmMain.Button9.Caption := '';
        frmMain.Button10.Caption := '';
        frmMain.Button11.Caption := '';
        frmMain.Button12.Caption := '';
        frmMain.Button13.Caption := '';
        frmMain.Button14.Caption := '';
        frmMain.Button15.Caption := '';
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
    	        		if tc.Login <> 0 then tc.Socket.Close;
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
		    DataSave(True);
        end else begin

            Idx := 100101;
            i := 0;

        	for i := 0 to Player.Count - 1 do begin
            	tp2 := Player.Objects[i] as TPlayer;
                if (tp2.ID <> i + 100101) and (tp2.ID > 100100) then begin
                	Idx := i + 100101;
                    Break;
                end;
            end;

            if (i = Player.Count) then Idx := 100101 + Player.Count;

    		AccountItem := TPlayer.Create;
	    	AccountItem.ID := Idx;
	        AccountItem.Name := frmMain.Edit3.Text;
    	    AccountItem.Pass := frmMain.Edit4.Text;
        	AccountItem.Gender := frmMain.ComboBox15.ItemIndex;
	        AccountItem.Mail := frmMain.Edit6.Text;
    		PlayerName.AddObject(AccountItem.Name, AccountItem);
    		Player.AddObject(AccountItem.ID, AccountItem);
            PD_Save_Accounts(True);

    	    frmMain.Button3.Click;
        end;

        JCon_Accounts_Load();
    end;

    procedure JCon_Accounts_Delete();
    var
    	tp : TPlayer;
        i, k : Integer;
    begin

    	for k := 0 to frmMain.ListBox1.Count - 1 do begin
        	if frmMain.ListBox1.Selected[k] then begin

            	tp := frmMain.listbox1.Items.Objects[k] as TPlayer;

                if (assigned(tp)) then begin
		            for i := 0 to 8 do begin
        		    	if assigned(tp.CData[i]) then begin

                        	if assigned(tp.CData[i].Socket) then begin
                        		if tp.CData[i].Login <> 0 then tp.CData[i].Socket.Close;
			                    tp.CData[i].Socket := nil;
    			            end;

                		    leave_party(tp.CData[i]);
		                    leave_guild(tp.CData[i]);

        	    	        //I'm leaving pets out for now. They're whacked
		    	    	    //for j := 0 to PetList.Count - 1 do begin
		        		    //	if PetList.IndexOf(j) <> -1 then begin
				            //    	tpe := PetList.IndexOfObject(j) as TPet;
        		        	//	    if (tpe.CharaID = tp.CData[i].ID) or (tpe.PlayerID = tp.ID) then PetList.Delete(j);
        				    //    end;
		        		    //end;

                            if (CharaName.IndexOf(tp.CData[i].Name) <> -1) then begin
			                    CharaName.Delete(CharaName.IndexOf(tp.CData[i].Name));
    			                Chara.Delete(Chara.IndexOf(tp.CData[i].CID));
                            end;
        		        end;
            		end;

		            if (IDTableDB.IndexOf(tp.ID) <> -1) then begin
        		    	IDTableDB.Delete(IDTableDB.IndexOf(tp.ID));
		            end;

	    	        if (GM_Access_DB.IndexOf(tp.ID) <> -1) then begin
    		        	GM_Access_DB.Delete(GM_Access_DB.IndexOf(tp.ID));
	        	    end;

                    PD_PlayerData_Delete(tp.Name);
                    if PlayerName.IndexOf(tp.Name) <> -1 then
    		        	PlayerName.Delete(PlayerName.IndexOf(tp.Name));
                    if Player.IndexOf(tp.ID) <> -1 then
    		            Player.Delete(Player.IndexOf(tp.ID));
		        end;
            end;
        end;

        JCon_Accounts_Clear();
        JCon_Accounts_Load();

    end;

    procedure JCon_Accounts_Chara_Delete(str : String);
    var
    	tc : TChara;
        tp : TPlayer;
        i : Integer;
    begin
        if (Charaname.IndexOf(str) = -1) then Exit;
    	tc := charaname.objects[charaname.indexof(str)] as TChara;

        tp := Player.Objects[Player.IndexOf(tc.ID)] as TPlayer;
        if (not assigned(tp)) then Exit;

        for i := 0 to 8 do begin
        	if (tp.CName[i] = tc.Name) then begin
            	tp.CName[i] := '';
                tp.CData[i] := nil;

                case i of
                	0: frmMain.Button7.Caption := '';
                    1: frmMain.Button8.Caption := '';
                    2: frmMain.Button9.Caption := '';
                    3: frmMain.Button10.Caption := '';
                    4: frmMain.Button11.Caption := '';
                    5: frmMain.Button12.Caption := '';
                    6: frmMain.Button13.Caption := '';
                    7: frmMain.Button14.Caption := '';
                    8: frmMain.Button15.Caption := '';
                end;

                Break;
            end;
        end;

        if assigned(tc.Socket) then begin
            if tc.Login <> 0 then begin
            	tc.Socket.Close;
            	tc.Socket := nil;
            end;
        end;

    	leave_party(tc);
        leave_guild(tc);

        { I'm leaving pets out for now. They're whacked }
        {for j := 0 to PetList.Count - 1 do begin
        	if PetList.IndexOf(j) <> -1 then begin
            	tpe := PetList.IndexOfObject(j) as TPet;
                if (tpe.CharaID = tp.CData[i].ID) or (tpe.PlayerID = tp.ID) then PetList.Delete(j);
            end;
        end;}

        if CharaName.IndexOf(tc.Name) <> -1 then
            CharaName.Delete(CharaName.IndexOf(tc.Name));
        if Chara.IndexOf(tc.CID) <> -1 then
            Chara.Delete(Chara.IndexOf(tc.CID));

        DataSave(True);
    end;


    procedure JCon_INI_Server_Load();
    begin
		frmMain.Edit17.Text := WAN_IP;
		frmMain.Edit18.Text := ServerName;
	    frmMain.Edit19.Text := IntToStr(DefaultNPCID);
    	frmMain.Edit20.Text := IntToStr(sv1port);
    	frmMain.Edit21.Text := IntToStr(sv2port);
	    frmMain.Edit22.Text := IntToStr(sv3port);
        frmMain.Edit5.Text := IntToStr(wacport);

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
        WAN_IP := frmMain.Edit17.Text;
		WAN_ADDR := cardinal(inet_addr(PChar(WAN_IP)));
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

        if (frmMain.Edit5.Text <> frmMain.Edit20.Text) and (frmMain.Edit5.Text <> frmMain.Edit21.Text) and (frmMain.Edit5.Text <> frmMain.Edit22.Text) then wacport := StrToInt(frmMain.Edit5.Text);

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
    	try frmMain.Edit42.Text := IntToStr(BaseExpMultiplier); except end;
        try frmMain.Edit37.Text := IntToStr(JobExpMultiplier); except end;
        try frmMain.Edit38.Text := IntToStr(ItemDropMultiplier); except end;

        try frmMain.Edit39.Text := IntToStr(StealMultiplier); except end;
        try frmMain.Edit40.Text := IntToStr(Option_Pet_Capture_Rate); except end;

        try frmMain.ComboBox16.ItemIndex := abs(StrToInt(BoolToStr(DisableLevelLimit))); except end;
        try frmMain.ComboBox9.ItemIndex := abs(StrToInt(BoolToStr(DisableEquipLimit))); except end;
        try frmMain.ComboBox10.ItemIndex := abs(StrToInt(BoolToStr(EnablePetSkills))); except end;
        try frmMain.ComboBox11.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP))); except end;
        try frmMain.ComboBox12.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP_Steal))); except end;
        try frmMain.ComboBox13.ItemIndex := abs(StrToInt(BoolToStr(Option_PVP_XPLoss))); except end;

        try frmMain.Edit35.Text := IntToStr(DefaultZeny); except end;
        try frmMain.Edit43.Text := IntToStr(DefaultItem1); except end;
        try frmMain.Edit44.Text := IntToStr(DefaultItem2); except end;
        try frmMain.Edit27.Text := DefaultMap; except end;
        try frmMain.Edit28.Text := IntToStr(DefaultPoint_X); except end;
        try frmMain.Edit45.Text := IntToStr(DefaultPoint_Y); except end;

        try frmMain.Edit32.Text := IntToStr(DeathBaseLoss); except end;
        try frmMain.Edit33.Text := IntToStr(DeathJobLoss); except end;
        try frmMain.Edit34.Text := IntToStr(Option_PartyShare_Level); except end;
        try frmMain.ComboBox14.ItemIndex := abs(StrToInt(BoolToStr(DisableSkillLimit))); except end;

    end;

    procedure JCon_INI_Game_Save();
    begin
        try BaseExpMultiplier := StrToInt(frmMain.Edit42.Text); except end;
        try JobExpMultiplier := StrToInt(frmMain.Edit37.Text); except end;
        try ItemDropMultiplier := StrToInt(frmMain.Edit38.Text); except end;

        try StealMultiplier := StrToInt(frmMain.Edit39.Text); except end;
        try Option_Pet_Capture_Rate := StrToInt(frmMain.Edit40.Text); except end;

        try DisableLevelLimit := StrToBool(IntToStr(abs(frmMain.ComboBox16.ItemIndex))); except end;
        try DisableEquipLimit := StrToBool(IntToStr(abs(frmMain.ComboBox9.ItemIndex))); except end;
        try EnablePetSkills := StrToBool(IntToStr(abs(frmMain.ComboBox10.ItemIndex))); except end;
        try Option_PVP := StrToBool(IntToStr(abs(frmMain.ComboBox11.ItemIndex))); except end;
        try Option_PVP_Steal := StrToBool(IntToStr(abs(frmMain.ComboBox12.ItemIndex))); except end;
        try Option_PVP_XPLoss := StrToBool(IntToStr(abs(frmMain.ComboBox13.ItemIndex))); except end;

        try DefaultZeny := StrToInt(frmMain.Edit35.Text); except end;
        try DefaultItem1 := StrToInt(frmMain.Edit43.Text); except end;
        try DefaultItem2 := StrToInt(frmMain.Edit44.Text); except end;
        try DefaultMap := frmMain.Edit27.Text; except end;
        try DefaultPoint_X := StrToInt(frmMain.Edit28.Text); except end;
        try DefaultPoint_Y := StrToInt(frmMain.Edit45.Text); except end;

        try DeathBaseLoss := StrToInt(frmMain.Edit32.Text); except end;
        try DeathJobLoss := StrToInt(frmMain.Edit33.Text); except end;
        try Option_PartyShare_Level := StrToInt(frmMain.Edit34.Text); except end;
        try DisableSkillLimit := StrToBool(IntToStr(abs(frmMain.ComboBox14.ItemIndex))); except end;

		weiss_ini_save();
    end;

{    procedure JCon_Character_Save();
    var
        tc : TChara;
    begin
        tc.Name := frmMain.Edit7.Text;
        tc.ID := StrToInt(frmMain.Edit8.Text);
        tc.CID := StrToInt(frmMain.Edit9.Text);
        tc.JID := StrToInt(frmMain.Edit10.Text);
        tc.BaseLV := StrToInt(frmMain.Edit14.Text);
        tc.BaseEXP := StrToInt(frmMain.Edit15.Text);
        tc.StatusPoint := StrToInt(frmMain.Edit11.Text);
        tc.JobLV := StrToInt(frmMain.Edit12.Text);
        tc.JobEXP := StrToInt(frmMain.Edit13.Text);
        tc.SkillPoint := StrToInt(frmMain.Edit16.Text);
        tc.Zeny := StrToInt(frmMain.Edit36.Text);
        tc.Stat1 := StrToInt(frmMain.Edit55.Text);
        tc.Stat2 := StrToInt(frmMain.Edit56.Text);
        tc.Option := StrToInt(frmMain.Edit54.Text);

        if StrToInt(frmMain.Edit58.Text) > tc.MAXHP then begin
            tc.HP := tc.MAXHP;
            frmMain.Edit58.Text := IntToStr(tc.MAXHP);
        end else
            tc.HP := StrToInt(frmMain.Edit58.Text);
        if StrToInt(frmMain.Edit53.Text) > tc.MAXSP then begin
            tc.SP := tc.MAXSP;
            frmMain.Edit53.Text := IntToStr(tc.MAXSP);
        end else
            tc.SP := StrToInt(frmMain.Edit53.Text);

        tc.Speed := StrToInt(frmMain.Edit41.Text);
        tc.Hair := StrToInt(frmMain.Edit46.Text);
        tc.HairColor := StrToInt(frmMain.Edit47.Text);
        tc.ClothesColor := StrToInt(frmMain.Edit48.Text);
        tc.ParamBase[0] := StrToInt(frmMain.Edit67.Text);
        tc.ParamBase[1] := StrToInt(frmMain.Edit66.Text);
        tc.ParamBase[2] := StrToInt(frmMain.Edit65.Text);
        tc.ParamBase[3] := StrToInt(frmMain.Edit63.Text);
        tc.ParamBase[4] := StrToInt(frmMain.Edit63.Text);
        tc.ParamBase[5] := StrToInt(frmMain.Edit61.Text);
        tc.Map := frmMain.Edit52.Text;
        tc.Point.X := StrToInt(frmMain.Edit57.Text);
        tc.Point.Y := StrToInt(frmMain.Edit59.Text);
        tc.SaveMap := frmMain.Edit49.Text;
        tc.SavePoint.X := StrToInt(frmMain.Edit50.Text);
        tc.SavePoint.X := StrToInt(frmMain.Edit51.Text);
    end;
}
end.

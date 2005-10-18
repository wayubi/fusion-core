unit ADODB_LOAD_ACCOUNTS;

interface

uses
    Windows, Forms, Common, Classes, SysUtils;

    procedure adodb_load_account(UID : String = '*');

    function adodb_load_login(UID : String = '*') : Integer;
    procedure adodb_load_char(UID : String = '*');

implementation

uses
    Main;

    procedure adodb_load_account(UID : String = '*');
    begin



      SetPriorityClass(GetCurrentProcess(), $4000);
      debugout.Lines.Add('Loading eAthena SQL login table');
      adodb_load_login(UID);
      debugout.Lines.Add('Loading eAthena SQL char table');
      adodb_load_char(UID);
      SetPriorityClass(GetCurrentProcess(), $20);

    end;

    // -------------------------------------------------------------------------
    // Loads data from SQL login table
    // -------------------------------------------------------------------------
    function adodb_load_login(UID : String = '*') : Integer;
    var
      sql : String;
      tp : TPlayer;
    begin

      // -----------------------------------------------------------------------
      // If UID = *, load all login, else load login where userid = UID
      // -----------------------------------------------------------------------
      if (UID = '*') then begin
        sql := 'select `login`.account_id, `login`.userid, `login`.user_pass, `login`.email, `login`.sex, `login`.level, `login`.ban_until from `login`;';
      end else begin
        sql := 'select `login`.account_id, `login`.userid, `login`.user_pass, `login`.email, `login`.sex, `login`.level, `login`.ban_until from `login` where `login`.userid = ''' +UID+ ''';';
      end;

      // -----------------------------------------------------------------------
      // Set and execute SQL
      // -----------------------------------------------------------------------
      frmMain.ADODataSet1.CommandText := sql;
      frmMain.ADODataSet1.Open;

      // -----------------------------------------------------------------------
      // Loop through results and assign data to variables
      // -----------------------------------------------------------------------
      while not frmMain.ADODataSet1.Eof do begin

        if not (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'S') then begin
          tp := TPlayer.Create;

          tp.ID := frmMain.ADODataSet1.FieldByName('account_id').CurValue;
          tp.Name := frmMain.ADODataSet1.FieldByName('userid').CurValue;
          tp.Pass := frmMain.ADODataSet1.FieldByName('user_pass').CurValue;
          tp.Mail := frmMain.ADODataSet1.FieldByName('email').CurValue;
          tp.AccessLevel := frmMain.ADODataSet1.FieldByName('level').CurValue;

          if (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'M') then tp.Gender := 1
          else if (frmMain.ADODataSet1.FieldByName('sex').CurValue = 'F') then tp.Gender := 0;

          tp.Banned := False;

          PlayerName.AddObject(tp.Name, tp);
          Player.AddObject(tp.ID, tp);

          //tp := Player.Objects[Player.IndexOf(frmMain.ADODataSet1.FieldByName('account_id').CurValue)] as TPlayer;
          //debugout.Lines.Add(tp.Name);
        end;
        
        frmMain.ADODataSet1.Next;
      end;

      frmMain.ADODataSet1.Close;

      Result := tp.ID;
    end;

    // -------------------------------------------------------------------------
    // Loads data from SQL char table
    // -------------------------------------------------------------------------
    procedure adodb_load_char(UID : String = '*');
    var
      sql : String;
      tc : TChara;
    begin

      // -----------------------------------------------------------------------
      // If UID = *, load all login, else load login where userid = UID
      // -----------------------------------------------------------------------
      if (UID = '*') then begin
        //sql := 'select `char`.char_id, `char`.account_id, `char`.char_num, `char`.name, `char`.class, `char`.base_level, `char`.job_level, `char`.base_exp, `char`.job_exp, `char`.zeny, `char`.str, `char`.agi, `char`.vit, `char`.int, `char`.dex, `char`.luk, `char`.hp, `char`.sp, `char`.status_point, `char`.skill_point, `char`.option, `char`.karma, `char`.manner, `char`.party_id, `char`.guild_id, `char`.pet_id, `char`.hair, `char`.hair_color, `char`.clothes_color, `char`.weapon, `char`.shield, `char`.head_top, `char`.head_mid, `char`.head_bottom, `char`.last_map, `char`.last_x, `char`.last_y, `char`.save_map, `char`.save_x, `char`.save_y from `char`;';
        sql := 'select `char`.* from `char`;';
      end else begin
        //sql := 'select `login`.account_id, `login`.userid, `login`.user_pass, `login`.email, `login`.sex, `login`.level, `login`.ban_until from `login` where `login`.userid = ''' +UID+ ''';';
      end;

      // -----------------------------------------------------------------------
      // Set and execute SQL
      // -----------------------------------------------------------------------
      frmMain.ADODataSet1.CommandText := sql;
      frmMain.ADODataSet1.Open;

      // -----------------------------------------------------------------------
      // Loop through results and assign data to variables
      // -----------------------------------------------------------------------
      while not frmMain.ADODataSet1.Eof do begin

        tc := TChara.Create;

        tc.CID := frmMain.ADODataSet1.FieldByName('char_id').CurValue;
        tc.ID := frmMain.ADODataSet1.FieldByName('account_id').CurValue;
        tc.CharaNumber := frmMain.ADODataSet1.FieldByName('char_num').CurValue;
        tc.Name := frmMain.ADODataSet1.FieldByName('name').CurValue;

        tc.JID := frmMain.ADODataSet1.FieldByName('class').CurValue;
        if (tc.JID > LOWER_JOB_END) then tc.JID := tc.JID - LOWER_JOB_END + UPPER_JOB_BEGIN;

        tc.BaseLV := frmMain.ADODataSet1.FieldByName('base_level').CurValue;
        tc.JobLV := frmMain.ADODataSet1.FieldByName('job_level').CurValue;
        tc.BaseEXP := frmMain.ADODataSet1.FieldByName('base_exp').CurValue;
        tc.JobEXP := frmMain.ADODataSet1.FieldByName('job_exp').CurValue;
        tc.Zeny := frmMain.ADODataSet1.FieldByName('zeny').CurValue;

        tc.ParamBase[0] := frmMain.ADODataSet1.FieldByName('str').CurValue;
        tc.ParamBase[1] := frmMain.ADODataSet1.FieldByName('agi').CurValue;
        tc.ParamBase[2] := frmMain.ADODataSet1.FieldByName('vit').CurValue;
        tc.ParamBase[3] := frmMain.ADODataSet1.FieldByName('int').CurValue;
        tc.ParamBase[4] := frmMain.ADODataSet1.FieldByName('dex').CurValue;
        tc.ParamBase[5] := frmMain.ADODataSet1.FieldByName('luk').CurValue;

        tc.HP := frmMain.ADODataSet1.FieldByName('hp').CurValue;
        tc.SP := frmMain.ADODataSet1.FieldByName('sp').CurValue;
        tc.StatusPoint := frmMain.ADODataSet1.FieldByName('status_point').CurValue;
        tc.SkillPoint := frmMain.ADODataSet1.FieldByName('skill_point').CurValue;
        tc.Option := frmMain.ADODataSet1.FieldByName('option').CurValue;
        tc.Karma := frmMain.ADODataSet1.FieldByName('karma').CurValue;
        tc.Manner := frmMain.ADODataSet1.FieldByName('manner').CurValue;

        tc.PartyID := frmMain.ADODataSet1.FieldByName('party_id').CurValue;
        tc.GuildID := frmMain.ADODataSet1.FieldByName('guild_id').CurValue;
        //tc.PetID := frmMain.ADODataSet1.FieldByName('pet_id').CurValue;

        tc.Hair := frmMain.ADODataSet1.FieldByName('hair').CurValue;
        tc.HairColor := frmMain.ADODataSet1.FieldByName('hair_color').CurValue;
        tc.ClothesColor := frmMain.ADODataSet1.FieldByName('clothes_color').CurValue;
        tc.Weapon := frmMain.ADODataSet1.FieldByName('weapon').CurValue;
        tc.Shield := frmMain.ADODataSet1.FieldByName('shield').CurValue;
        tc.Head1 := frmMain.ADODataSet1.FieldByName('head_top').CurValue;
        tc.Head2 := frmMain.ADODataSet1.FieldByName('head_mid').CurValue;
        tc.Head3 := frmMain.ADODataSet1.FieldByName('head_bottom').CurValue;

        tc.Map := frmMain.ADODataSet1.FieldByName('last_map').CurValue;
        tc.Point.X := frmMain.ADODataSet1.FieldByName('last_x').CurValue;
        tc.Point.Y := frmMain.ADODataSet1.FieldByName('last_y').CurValue;
        tc.SaveMap := frmMain.ADODataSet1.FieldByName('save_map').CurValue;
        tc.SavePoint.X := frmMain.ADODataSet1.FieldByName('save_x').CurValue;
        tc.SavePoint.Y := frmMain.ADODataSet1.FieldByName('save_y').CurValue;

        { Unmapped ---
        tc.Stat1 := retrieve_data(11, datafile, path, 1);
        tc.Stat2 := retrieve_data(12, datafile, path, 1);
        tc.DefaultSpeed := retrieve_data(18, datafile, path, 1);
        tc._2 := retrieve_data(20, datafile, path, 1);
        tc._3 := retrieve_data(21, datafile, path, 1);
        tc.Plag := retrieve_data(42, datafile, path, 1);
        tc.PLv := retrieve_data(43, datafile, path, 1);
        }

        CharaName.AddObject(tc.Name, tc);
        Chara.AddObject(tc.CID, tc);

        //tc := Chara.Objects[Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue)] as TChara;
        //debugout.Lines.Add(tc.Name);

        frmMain.ADODataSet1.Next;
      end;

      frmMain.ADODataSet1.Close;
      
    end;

    
end.

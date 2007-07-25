unit ADODB_LOAD_ACCOUNTS;

interface

uses
    Windows, Forms, Common, Classes, SysUtils;

    procedure adodb_load_account(UID : String = '*');

    // Loads login table.  Returns account_id
    function adodb_load_login(UID : String = '*') : Integer;
    procedure adodb_load_storage(account_id : Integer = 0);

    // Loads char table.
    procedure adodb_load_char(account_id : Integer = 0);
    procedure adodb_load_memo(account_id : Integer = 0);
    procedure adodb_load_skill(account_id : Integer = 0);
    procedure adodb_load_inventory(account_id : Integer = 0);
    procedure adodb_load_cart(account_id : Integer = 0);

implementation

uses
    Main;

    procedure adodb_load_account(UID : String = '*');
    var
      account_id : Integer;
      char_id : Integer;
    begin

      SetPriorityClass(GetCurrentProcess(), $4000);

      account_id := adodb_load_login(UID);
      adodb_load_char(account_id);

      // Load these only when a user logs in.
      adodb_load_storage(account_id);
      //adodb_load_memo(account_id);
      //adodb_load_skill(account_id);
      //adodb_load_inventory(account_id);
      //adodb_load_cart(account_id);

      SetPriorityClass(GetCurrentProcess(), $20);

    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL login table
    // -------------------------------------------------------------------------
    function adodb_load_login(UID : String = '*') : Integer;
    var
      sql : String;
      tp : TPlayer;
      sl : TStringList;
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
        end;
        
        frmMain.ADODataSet1.Next;
      end;

      frmMain.ADODataSet1.Close;

      if (UID = '*') then Result := 0
      else Result := tp.ID;
    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL storage table
    // -------------------------------------------------------------------------
    procedure adodb_load_storage(account_id : Integer = 0);
    var
      sql : String;
      tp : TPlayer;
      loopCounter : Integer;
      Item : TItem;
    begin

      // Initialize Variables
      Item := TItem.Create;

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `storage`.* from `storage`;';
      end else begin
        sql := 'select `storage`.* from `storage` where `storage`.account_id = '''+IntToStr(account_id)+''';';
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

        if Player.IndexOf(frmMain.ADODataSet1.FieldByName('account_id').CurValue) = -1 then begin
          frmMain.ADODataSet1.Next;
          Continue;

        end else begin
          tp := Player.Objects[Player.IndexOf(frmMain.ADODataSet1.FieldByName('account_id').CurValue)] as TPlayer;

          if ItemDB.IndexOf(frmMain.ADODataSet1.FieldByName('nameid').CurValue) = -1 then begin
            frmMain.ADODataSet1.Next;
            Continue;

          end else begin
            Item.ID := frmMain.ADODataSet1.FieldByName('nameid').CurValue;
            Item.Amount := frmMain.ADODataSet1.FieldByName('amount').CurValue;
            Item.Equip := frmMain.ADODataSet1.FieldByName('equip').CurValue;
            Item.Identify := frmMain.ADODataSet1.FieldByName('identify').CurValue;
            Item.Refine := frmMain.ADODataSet1.FieldByName('refine').CurValue;
            Item.Attr := frmMain.ADODataSet1.FieldByName('attribute').CurValue;
            Item.Card[0] := frmMain.ADODataSet1.FieldByName('card0').CurValue;
            Item.Card[1] := frmMain.ADODataSet1.FieldByName('card1').CurValue;
            Item.Card[2] := frmMain.ADODataSet1.FieldByName('card2').CurValue;
            Item.Card[3] := frmMain.ADODataSet1.FieldByName('card3').CurValue;
            Item.Data := ItemDB.Objects[ItemDB.IndexOf(Item.ID)] as TItemDB;

            tp.AddStorageItem(tp, Item);
            Item.ZeroItem;

            frmMain.ADODataSet1.Next;
            
          end;

        end;
  
      end;

      frmMain.ADODataSet1.Close;
      
    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL char table
    // -------------------------------------------------------------------------
    procedure adodb_load_char(account_id : Integer = 0);
    var
      sql : String;
      tc : TChara;
      loopCounter : Integer;
    begin

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `char`.* from `char`;';
      end else begin
        sql := 'select `char`.* from `char` where `char`.account_id = '''+IntToStr(account_id)+'''';
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


        // ---------------------------------------------------------------------
        // Loop through and reset all the assigned skills
        // ---------------------------------------------------------------------
        //for loopCounter := 0 to MAX_SKILL_NUMBER do begin
        //  if SkillDB.IndexOf(loopCounter) <> -1 then begin
        //    tc.Skill[loopCounter].Data := SkillDB.IndexOfObject(loopCounter) as TSkillDB;
        //    tc.Skill[loopCounter].Lv := 0;
        //  end;
        //end;
        
        //if (tc.Plag <> 0) then tc.Skill[tc.Plag].Plag := True;

        // ---------------------------------------------------------------------
        // Loop through and reset the inventory
        // ---------------------------------------------------------------------
        //for loopCounter := 0 to 99 do begin
        //  tc.Item[loopCounter].ZeroItem;
        //end;


        CharaName.AddObject(tc.Name, tc);
        Chara.AddObject(tc.CID, tc);

        frmMain.ADODataSet1.Next;
      end;

      frmMain.ADODataSet1.Close;
      
    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL memo table
    // -------------------------------------------------------------------------
    procedure adodb_load_memo(account_id : Integer = 0);
    var
      sql : String;
      tc : TChara;
      loopCounter : Integer;
    begin

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `memo`.* from `memo`;';
      end else begin
        sql := 'select `memo`.*, `char`.account_id from `memo` inner join `char` on `memo`.char_id = `char`.char_id where `char`.account_id = '''+IntToStr(account_id)+''';';
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

        if Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue) = -1 then Continue;
        tc := Chara.Objects[Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue)] as TChara;

        for loopCounter := 0 to 2 do begin
          if (tc.MemoMap[loopCounter] = '') then begin
            tc.MemoMap[loopCounter] := frmMain.ADODataSet1.FieldByName('map').CurValue;
            tc.MemoPoint[loopCounter].X := frmMain.ADODataSet1.FieldByName('x').CurValue;
            tc.MemoPoint[loopCounter].Y := frmMain.ADODataSet1.FieldByName('y').CurValue;
          end;
        end;

        frmMain.ADODataSet1.Next;
      end;

      frmMain.ADODataSet1.Close;
      
    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL skill table
    // -------------------------------------------------------------------------
    procedure adodb_load_skill(account_id : Integer = 0);
    var
      sql : String;
      tc : TChara;
      loopCounter : Integer;
    begin

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `skill`.* from `skill`;';
      end else begin
        sql := 'select `skill`.*, `char`.account_id from `skill` inner join `char` on `skill`.char_id = `char`.char_id where `char`.account_id = '''+IntToStr(account_id)+''';';
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

        if Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue) = -1 then begin
          frmMain.ADODataSet1.Next;
          Continue;
          
        end else begin
          tc := Chara.Objects[Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue)] as TChara;

          if (SkillDB.IndexOf(frmMain.ADODataSet1.FieldByName('id').CurValue) <> -1) then begin
            tc.Skill[StrToInt(frmMain.ADODataSet1.FieldByName('id').CurValue)].Lv := frmMain.ADODataSet1.FieldByName('lv').CurValue;
            tc.Skill[StrToInt(frmMain.ADODataSet1.FieldByName('id').CurValue)].Card := False;
            tc.Skill[StrToInt(frmMain.ADODataSet1.FieldByName('id').CurValue)].Plag := False;
          end;

          frmMain.ADODataSet1.Next;
        end;
  
      end;
      
      frmMain.ADODataSet1.Close;
      
    end;

    
    // -------------------------------------------------------------------------
    // Loads data from SQL inventory table
    // -------------------------------------------------------------------------
    procedure adodb_load_inventory(account_id : Integer = 0);
    var
      sql : String;
      tc : TChara;
      loopCounter : Integer;
      Item : TItem;
    begin

      // Initialize Variables
      Item := TItem.Create;

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `inventory`.* from `inventory` where char_id = 150003;';
      end else begin
        sql := 'select `inventory`.*, `char`.account_id from `inventory` inner join `char` on `inventory`.char_id = `char`.char_id where `char`.account_id = '''+IntToStr(account_id)+''';';
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

        if Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue) = -1 then begin
          frmMain.ADODataSet1.Next;
          Continue;

        end else begin
          tc := Chara.Objects[Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue)] as TChara;

          if ItemDB.IndexOf(frmMain.ADODataSet1.FieldByName('nameid').CurValue) = -1 then begin
            frmMain.ADODataSet1.Next;
            Continue;

          end else begin
            Item.ID := frmMain.ADODataSet1.FieldByName('nameid').CurValue;
            Item.Amount := frmMain.ADODataSet1.FieldByName('amount').CurValue;
            Item.Equip := frmMain.ADODataSet1.FieldByName('equip').CurValue;
            Item.Identify := frmMain.ADODataSet1.FieldByName('identify').CurValue;
            Item.Refine := frmMain.ADODataSet1.FieldByName('refine').CurValue;
            Item.Attr := frmMain.ADODataSet1.FieldByName('attribute').CurValue;
            Item.Card[0] := frmMain.ADODataSet1.FieldByName('card0').CurValue;
            Item.Card[1] := frmMain.ADODataSet1.FieldByName('card1').CurValue;
            Item.Card[2] := frmMain.ADODataSet1.FieldByName('card2').CurValue;
            Item.Card[3] := frmMain.ADODataSet1.FieldByName('card3').CurValue;
            Item.Data := ItemDB.Objects[ItemDB.IndexOf(Item.ID)] as TItemDB;

            tc.AddInventoryItem(tc, Item);
            Item.ZeroItem;

            frmMain.ADODataSet1.Next;
            
          end;

        end;
  
      end;

      frmMain.ADODataSet1.Close;
      
    end;


    // -------------------------------------------------------------------------
    // Loads data from SQL cart_inventory table
    // -------------------------------------------------------------------------
    procedure adodb_load_cart(account_id : Integer = 0);
    var
      sql : String;
      tc : TChara;
      loopCounter : Integer;
      Item : TItem;
    begin

      // Initialize Variables
      Item := TItem.Create;

      // -----------------------------------------------------------------------
      // If account_id = 0, load all login, else load login where account_id
      // -----------------------------------------------------------------------
      if (account_id = 0) then begin
        sql := 'select `cart_inventory`.* from `cart_inventory`;';
      end else begin
        sql := 'select `cart_inventory`.*, `char`.account_id from `cart_inventory` inner join `char` on `cart_inventory`.char_id = `char`.char_id where `char`.account_id = '''+IntToStr(account_id)+''';';
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

        if Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue) = -1 then begin
          frmMain.ADODataSet1.Next;
          Continue;

        end else begin
          tc := Chara.Objects[Chara.IndexOf(frmMain.ADODataSet1.FieldByName('char_id').CurValue)] as TChara;

          if ItemDB.IndexOf(frmMain.ADODataSet1.FieldByName('nameid').CurValue) = -1 then begin
            frmMain.ADODataSet1.Next;
            Continue;

          end else begin
            Item.ID := frmMain.ADODataSet1.FieldByName('nameid').CurValue;
            Item.Amount := frmMain.ADODataSet1.FieldByName('amount').CurValue;
            Item.Equip := frmMain.ADODataSet1.FieldByName('equip').CurValue;
            Item.Identify := frmMain.ADODataSet1.FieldByName('identify').CurValue;
            Item.Refine := frmMain.ADODataSet1.FieldByName('refine').CurValue;
            Item.Attr := frmMain.ADODataSet1.FieldByName('attribute').CurValue;
            Item.Card[0] := frmMain.ADODataSet1.FieldByName('card0').CurValue;
            Item.Card[1] := frmMain.ADODataSet1.FieldByName('card1').CurValue;
            Item.Card[2] := frmMain.ADODataSet1.FieldByName('card2').CurValue;
            Item.Card[3] := frmMain.ADODataSet1.FieldByName('card3').CurValue;
            Item.Data := ItemDB.Objects[ItemDB.IndexOf(Item.ID)] as TItemDB;

            tc.AddCartItem(tc, Item);
            Item.ZeroItem;

            frmMain.ADODataSet1.Next;
            
          end;

        end;
  
      end;

      frmMain.ADODataSet1.Close;
      
    end;


    
end.

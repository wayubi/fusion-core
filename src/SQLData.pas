{MySQL数据资料读取  --Michen}
unit SQLData;



interface

uses
	Windows, MMSystem, Forms, Classes, SysUtils, IniFiles, Common, DBXpress, DB, SqlExpr, StrUtils;

//==============================================================================
// 过程&函数
    function  HexToInt(Hex : string) : Cardinal; 
    function  ExecuteSqlCmd(sqlcmd: String) : Boolean;
		procedure SQLDataLoad();
		procedure SQLDataSave();
		function  GetPlayerData(userid: String) : Boolean; {取得帐号资料}
		function  GetCharaData(AID: cardinal) : Boolean; {取得帐号的人物资料}
		function  GetPetData(AID: cardinal) : Boolean; {取得帐号的宠物资料}
		function  GetCharaGuildData(GID: cardinal) : Boolean; {取得人物的工会资料}
		function  DeleteChar(GID: cardinal) : Boolean; {从数据库删除人物}
		function  DeleteGuildMember(GID: cardinal; mtype: Integer; tgb: TGBan; GDID: cardinal) : Boolean; {从数据库删除工会成员}
		function  DeleteParty(Name: string) : Boolean; {从数据库删除组队}
		function  DeleteGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean; {删除同盟、敌对工会资料}
		function  DeleteGuildInfo(GDID: cardinal) : Boolean; {删除工会资料}
		function  CheckUserExist(userid: String) : Boolean; {检查人物是否存在}
		function  GetNowLoginID() : cardinal; {取得当前的帐号ID编号}
		function  GetNowCharaID() : cardinal; {取得当前的人物ID编号}
		function  GetNowPetID() : cardinal; {取得当前的宠物ID编号}
		function  SavePetData(tpe : Tpet; PIndex: Integer; place: Integer) : Boolean; {保存宠物资料}
		function  SaveGuildMPosition(GDID: cardinal; PosName: string; PosInvite: boolean; PosPunish: boolean; PosEXP: byte; Grade: Integer) : Boolean; {保存工会头衔资料}
		function  SaveGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean; {保存同盟、敌对工会资料}
//==============================================================================

implementation

var
  SQLDataSet    :TSQLDataSet;
  SQLConnection :TSQLConnection;

//------------------------------------------------------------------------------
// 十六进制转十进制
//------------------------------------------------------------------------------
function HexToInt(Hex : string) : Cardinal; 
const
  cHex = '0123456789ABCDEF'; 
var
  mult,i,loop : integer; 
begin 
  result := 0; 
  mult := 1; 
  for loop := length(Hex) downto 1 do begin 
    i := pos(Hex[loop],cHex)-1; 
    if (i < 0) then i := 0; 
    inc(result,(i*mult)); 
  mult := mult * 16; 
  end; 
end;

//------------------------------------------------------------------------------
// 执行数据库查询
//------------------------------------------------------------------------------
function  ExecuteSqlCmd(sqlcmd: String) : Boolean;
begin
  Result := False;

  {初始化数据库}
	if not assigned(SQLConnection) then
	begin
    SQLConnection := TSQLConnection.Create(nil);
    SQLConnection.ConnectionName := 'MySQLConnection';
    SQLConnection.DriverName := 'MySQL';
    SQLConnection.GetDriverFunc := 'getSQLDriverMYSQL';
    SQLConnection.KeepConnection := True;
    SQLConnection.LibraryName := 'dbexpmysql.dll';
    SQLConnection.LoginPrompt := False;
    SQLConnection.VendorLib := 'libmysql.dll';
    SQLConnection.Params.Values['HostName'] := DbHost;
    SQLConnection.Params.Values['Database'] := DbName;
    SQLConnection.Params.Values['User_Name'] := DbUser;
    SQLConnection.Params.Values['Password'] := DbPass;
	end;

  {连接数据库}
	if not SQLConnection.Connected then
	begin
    try
      SQLConnection.Connected := True;
		except		
		  DebugOut.Lines.Add('*** Error on MySQL Connect.');
      Exit;
		end;
	end;

  if not assigned(SQLDataSet) then
	begin
	  SQLDataSet := TSQLDataSet.Create(nil);
    SQLDataSet.SQLConnection := SQLConnection;
	end;

  if SQLDataSet.Active then
    SQLConnection.Close;

  SQLDataSet.CommandText := sqlcmd;
	if UpperCase(copy(SQLDataSet.CommandText,1,6)) <> 'SELECT' then
  begin
	  try
      SQLDataSet.ExecSQL;
		except
		  DebugOut.Lines.Add( Format( '*** Execute SQL Error: %s', [sqlcmd] ) );
			exit;
		end;
		Result := True;
		Exit;
  end;
	try
	  SQLDataSet.Open;
	except
		DebugOut.Lines.Add( Format( '*** Open SQL Data Error: %s', [sqlcmd] ) );
		exit;
	end;
	DebugOut.Lines.Add(sqlcmd);
	Result := True;
end;

//------------------------------------------------------------------------------
// 读取全部的玩家资料
//------------------------------------------------------------------------------
procedure SQLDataLoad();
var
	i,j,k :integer;
	i1  :integer;
	sl  :TStringList;
	tpa	:TParty;
  tgc :TCastle;
	tg  :TGuild;
	tgb :TGBan;
	tgl :TGRel;
	txt :TextFile;
	str :string;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

	if not FileExists(AppPath + 'status.txt') then begin
		AssignFile(txt, AppPath + 'status.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.StatusData.0x0002');
		Writeln(txt, '0');
		CloseFile(txt);
	end else begin
		DebugOut.Lines.Add('Server Flag loading...');
		Application.ProcessMessages;
		AssignFile(txt, AppPath + 'status.txt');
		Reset(txt);
		Readln(txt, str);
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		j := StrToInt(sl.Strings[0]);
		for i := 1 to j do ServerFlag.Add('\' + sl.Strings[i]);
		CloseFile(txt);
		DebugOut.Lines.Add(Format('*** Total %d Server Flag loaded.', [ServerFlag.Count]));
		Application.ProcessMessages;
	end;

  {读取工会城资料}
	DebugOut.Lines.Add('Castle data loading from SQL...');
	Application.ProcessMessages;

	if ExecuteSqlCmd('SELECT * FROM gcastle') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tgc := TCastle.Create;
      with tgc do begin
			  Name     := SQLDataSet.FieldValues['Name'];
        GID      := StrToInt(SQLDataSet.FieldValues['GDID']);
        GName    := SQLDataSet.FieldValues['GName'];
        GMName   := SQLDataSet.FieldValues['GMName'];
        GKafra   := StrToInt(SQLDataSet.FieldValues['GKafra']);
        EDegree  := StrToInt(SQLDataSet.FieldValues['EDegree']);
        ETrigger := StrToInt(SQLDataSet.FieldValues['ETrigger']);
        DDegree  := StrToInt(SQLDataSet.FieldValues['DDegree']);
        DTrigger := StrToInt(SQLDataSet.FieldValues['DTrigger']);
        GuardStatus[0] := StrToInt(SQLDataSet.FieldValues['GuardStatus0']);
        GuardStatus[1] := StrToInt(SQLDataSet.FieldValues['GuardStatus1']);
        GuardStatus[2] := StrToInt(SQLDataSet.FieldValues['GuardStatus2']);
        GuardStatus[3] := StrToInt(SQLDataSet.FieldValues['GuardStatus3']);
        GuardStatus[4] := StrToInt(SQLDataSet.FieldValues['GuardStatus4']);
        GuardStatus[5] := StrToInt(SQLDataSet.FieldValues['GuardStatus5']);
        GuardStatus[6] := StrToInt(SQLDataSet.FieldValues['GuardStatus6']);
        GuardStatus[7] := StrToInt(SQLDataSet.FieldValues['GuardStatus7']);
      end;

      CastleList.AddObject(tgc.Name, tgc);
	    SQLDataSet.Next;
	  end;
	end else begin
	  DebugOut.Lines.Add('Castle data loading error...');
		Exit;
	end;
	DebugOut.Lines.Add(Format('*** Total %d Castle(s) data loaded.', [CastleList.Count]));
	Application.ProcessMessages;

  {读取组队资料}
	DebugOut.Lines.Add('Party data loading from SQL...');
	Application.ProcessMessages;

	if ExecuteSqlCmd('SELECT * FROM party') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tpa := TParty.Create;
      with tpa do begin
			  Name     := SQLDataSet.FieldValues['Name'];
        EXPShare      := StrToInt(SQLDataSet.FieldValues['EXPShare']);
        ITEMShare    := StrToInt(SQLDataSet.FieldValues['ITEMShare']);
        MemberID[0]   := StrToInt(SQLDataSet.FieldValues['MemberID0']);
        MemberID[1]   := StrToInt(SQLDataSet.FieldValues['MemberID1']);
        MemberID[2]   := StrToInt(SQLDataSet.FieldValues['MemberID2']);
        MemberID[3]   := StrToInt(SQLDataSet.FieldValues['MemberID3']);
        MemberID[4]   := StrToInt(SQLDataSet.FieldValues['MemberID4']);
        MemberID[5]   := StrToInt(SQLDataSet.FieldValues['MemberID5']);
        MemberID[6]   := StrToInt(SQLDataSet.FieldValues['MemberID6']);
        MemberID[7]   := StrToInt(SQLDataSet.FieldValues['MemberID7']);
        MemberID[8]   := StrToInt(SQLDataSet.FieldValues['MemberID8']);
        MemberID[9]   := StrToInt(SQLDataSet.FieldValues['MemberID9']);
        MemberID[10]   := StrToInt(SQLDataSet.FieldValues['MemberID10']);
        MemberID[11]   := StrToInt(SQLDataSet.FieldValues['MemberID11']);
      end;

      PartyNameList.AddObject(tpa.Name, tpa);
			DebugOut.Lines.Add(Format('Add Party Name : %s.', [tpa.Name]));
	    SQLDataSet.Next;
	  end;
	end else begin
	  DebugOut.Lines.Add('Party data loading error...');
		Exit;
	end;

	DebugOut.Lines.Add(Format('*** Total %d Party(s) data loaded.', [PartyNameList.Count]));
	Application.ProcessMessages;

  {读取工会资料}
	DebugOut.Lines.Add('Guild data loading from SQL...');
	Application.ProcessMessages;

  if ExecuteSqlCmd('SELECT * FROM guildinfo') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tg := TGuild.Create;
      with tg do begin
			  ID := StrToInt(SQLDataSet.FieldValues['GDID']);
			  if (ID > NowGuildID) then NowGuildID := ID;
			  Name := SQLDataSet.FieldValues['Name'];
			  LV := StrToInt(SQLDataSet.FieldValues['LV']);
			  EXP := StrToInt(SQLDataSet.FieldValues['EXP']);
			  GSkillPoint := StrToInt(SQLDataSet.FieldValues['GSkillPoint']);
			  Notice[0] := SQLDataSet.FieldValues['Subject'];
			  Notice[1] := SQLDataSet.FieldValues['Notice'];
			  Agit := SQLDataSet.FieldValues['Agit'];
			  Emblem := StrToInt(SQLDataSet.FieldValues['Emblem']);
			  Present := StrToInt(SQLDataSet.FieldValues['Present']);
			  DisposFV := StrToInt(SQLDataSet.FieldValues['DisposFV']);
			  DisposRW := StrToInt(SQLDataSet.FieldValues['DisposRW']);
				
			  for i := 10000 to 10004 do
				begin
			  	if GSkillDB.IndexOf(i) <> -1 then
					begin
			  		GSkill[i].Data := GSkillDB.IndexOfObject(i) as TSkillDB;
			  	end;
			  end;

				{读取工会技能}
				j := Round(Length(SQLDataSet.FieldValues['skill']) div 8);
			  for i := 1 to j do
				begin
				  k := (i-1)*8 + 1;
				  if GSkillDB.IndexOf(HexToInt(MidStr(SQLDataSet.FieldValues['skill'], k, 4))) <> -1 then
					begin
					  i1 := HexToInt(MidStr(SQLDataSet.FieldValues['skill'], k, 4));
					  GSkill[i1].Lv := HexToInt(MidStr(SQLDataSet.FieldValues['skill'], k+4, 4));
					  GSkill[i1].Card := false;
				  end;
			  end;
      end;

      GuildList.AddObject(tg.ID, tg);
	    SQLDataSet.Next;
	  end;
	end else begin
	  DebugOut.Lines.Add('Guild data loading error...');
		Exit;
	end;

	Application.ProcessMessages;

  {循环所有工会，读取工会成员等资料}
  for i := 0 to GuildList.Count - 1 do
	begin
		tg := GuildList.Objects[i] as TGuild;
		with tg do
		begin
		  {读取工会成员资料}
		  if ExecuteSqlCmd(Format('SELECT * FROM guildMinfo WHERE GDID=''%d'' LIMIT 36', [ID])) then
			begin
			  j := 0;
			  while not SQLDataSet.Eof do
				begin
				  if j > 35 then continue;
				  MemberID[j]  := StrToInt(SQLDataSet.FieldValues['GID']);
				  MemberPos[j] := StrToInt(SQLDataSet.FieldValues['PositionID']);
				  MemberEXP[j] := StrToInt(SQLDataSet.FieldValues['MemberExp']);
					if (MemberID[j] <> 0) then Inc(RegUsers, 1);
					INC(j);
					SQLDataSet.Next;
				end;
      end;

			Application.ProcessMessages;

			{读取工会称号资料}
			if ExecuteSqlCmd(Format('SELECT * FROM guildMPosition WHERE GDID=''%d'' LIMIT 20', [ID])) then
			begin
			  j := 0;
				while not SQLDataSet.Eof do
				begin
					PosName[j]   := SQLDataSet.FieldValues['PosName'];
				  PosInvite[j] := StrToBool(SQLDataSet.FieldValues['PosInvite']);
				  PosPunish[j] := StrToBool(SQLDataSet.FieldValues['PosPunish']);
				  PosEXP[j]    := StrToInt(SQLDataSet.FieldValues['PosEXP']);
					INC(j);
					SQLDataSet.Next;
				end;
			end;

			Application.ProcessMessages;

			{读取工会开除成员记录}
			if ExecuteSqlCmd(Format('SELECT * FROM guildBanishInfo WHERE GDID=''%d''', [ID])) then
			begin
			  while not SQLDataSet.Eof do
				begin
          tgb := TGBan.Create;
				  tgb.Name    := SQLDataSet.FieldValues['MemberName'];
				  tgb.AccName := SQLDataSet.FieldValues['MemberAccount'];
				  tgb.Reason  := SQLDataSet.FieldValues['Reason'];
				  GuildBanList.AddObject(tgb.Name, tgb);
					SQLDataSet.Next;
				end;
			end;

			Application.ProcessMessages;

			{读取同盟、敌对工会}
			if ExecuteSqlCmd(Format('SELECT * FROM guildAllyInfo WHERE GDID=''%d''', [ID])) then
			begin
			  while not SQLDataSet.Eof do
				begin
          tgl := TGRel.Create;
				  tgl.ID        := SQLDataSet.FieldValues['GDID'];
				  tgl.GuildName := SQLDataSet.FieldValues['GuildName'];
					if SQLDataSet.FieldValues['Relation'] = 1 then
				    RelAlliance.AddObject(tgl.GuildName, tgl)  // 同盟工会
					else
					  RelHostility.AddObject(tgl.GuildName, tgl); // 敌对工会
					SQLDataSet.Next;
				end;
			end;

			MaxUsers := 16;
			if (GSkill[10004].Lv > 0) then begin
				MaxUsers := MaxUsers + GSkill[10004].Data.Data1[GSkill[10004].Lv];
			end;
			NextEXP := GExpTable[LV];
		end;
	end;

	DebugOut.Lines.Add(Format('*** Total %d Guild(s) data loaded.', [GuildList.Count]));
	Application.ProcessMessages;

	sl.Free;
end;


//------------------------------------------------------------------------------
// 保存内存中的数据
//------------------------------------------------------------------------------
procedure SQLDataSave();
var
  bindata : String;
	i,j,k :integer;
	tp  :TPlayer;
	tc  :TChara;
	tpa	:TParty;
  tgc :TCastle;
  tpe :TPet;
	tg  :TGuild;
	tgb :TGBan;
	tgl :TGRel;
	sl  :TStringList;
	txt :TextFile;
	cnt :integer;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '''';
	sl.Delimiter := ',';
  {保存帐号和仓库资料}
  if PlayerName.Count <> 0 then
  begin
    for i := 0 to PlayerName.Count - 1 do
    begin
		  bindata := '';
      tp := PlayerName.Objects[i] as TPlayer;
      with tp do
      begin
			  if not ExecuteSqlCmd(Format('REPLACE INTO login (AID,ID,passwd,Gender,Mail,GMMode) VALUES (''%d'',''%s'',''%s'',''%d'',''%s'',''%d'')', [ID, Name, Pass, Gender, Mail, GMMode])) then begin
          DebugOut.Lines.Add('*** Save Player Account data error.');
				end;

				for j := 1 to 100 do begin
				  if Kafra.Item[j].ID <> 0 then begin
					  bindata := bindata + IntToHex(Kafra.Item[j].ID,4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Amount,4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Equip,4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Identify,2);
					  bindata := bindata + IntToHex(Kafra.Item[j].Refine,2);
					  bindata := bindata + IntToHex(Kafra.Item[j].Attr,2);
					  bindata := bindata + IntToHex(Kafra.Item[j].Card[0],4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Card[1],4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Card[2],4);
					  bindata := bindata + IntToHex(Kafra.Item[j].Card[3],4);
					end;
				end;
		    if not ExecuteSqlCmd(Format('REPLACE INTO storeitem (AID,storeitem) VALUES (''%d'',''%s'')', [ID, bindata])) then begin
				  DebugOut.Lines.Add('*** Save Player Kafra data error.');
				end;
      end;
    end;
  end;

	Application.ProcessMessages;

	{保存人物资料}
	if CharaName.Count <> 0 then begin
	  for i := 0 to CharaName.Count - 1 do begin
		  sl.Clear;
		  tc := CharaName.Objects[i] as TChara;
			with tc do begin
				sl.Add(IntToStr(CID));
				sl.Add('"' + Name + '"');
				sl.Add(IntToStr(JID));
				sl.Add(IntToStr(BaseLV));
				sl.Add(IntToStr(BaseEXP));
				sl.Add(IntToStr(StatusPoint));
				sl.Add(IntToStr(JobLV));
				sl.Add(IntToStr(JobEXP));
				sl.Add(IntToStr(SkillPoint));
				sl.Add(IntToStr(Zeny));
				sl.Add(IntToStr(Stat1));
				sl.Add(IntToStr(Stat2));
        if Option = 4 then begin
          sl.Add('0');
        end else begin
          sl.Add(IntToStr(Option));
        end;
				sl.Add(IntToStr(Karma));
				sl.Add(IntToStr(Manner));
				sl.Add(IntToStr(HP));
				sl.Add(IntToStr(SP));
				sl.Add(IntToStr(DefaultSpeed));
				sl.Add(IntToStr(Hair));
				sl.Add(IntToStr(_2));
				sl.Add(IntToStr(_3));
				sl.Add(IntToStr(Weapon));
				sl.Add(IntToStr(Shield));
				sl.Add(IntToStr(Head1));
				sl.Add(IntToStr(Head2));
				sl.Add(IntToStr(Head3));
				sl.Add(IntToStr(HairColor));
				sl.Add(IntToStr(ClothesColor));
				for j := 0 to 5 do
					sl.Add(IntToStr(ParamBase[j]));
				sl.Add(IntToStr(CharaNumber));
				sl.Add('"' + Map + '"');
				sl.Add(IntToStr(Point.X));
				sl.Add(IntToStr(Point.Y));
				sl.Add('"' + SaveMap + '"');
				sl.Add(IntToStr(SavePoint.X));
				sl.Add(IntToStr(SavePoint.Y));
        sl.Add(IntToStr(Plag));
        sl.Add(IntToStr(PLv));
        sl.Add(IntToStr(ID));
				bindata := '';
				bindata := 'GID,Name,JID,BaseLV,BaseEXP,StatusPoint,JobLV,JobEXP,SkillPoint,Zeny,Stat1,Stat2,Options,Karma,Manner,HP,SP,DefaultSpeed,Hair,_2,_3,Weapon,Shield,Head1,Head2,Head3,HairColor,';
				bindata := bindata + 'ClothesColor,STR,AGI,VIT,INTS,DEX,LUK,CharaNumber,Map,X,Y,SaveMap,SX,SY,Plag,PLv,AID';

		    if not ExecuteSqlCmd(Format('REPLACE INTO Characters (%s) VALUES (%s)', [bindata, sl.DelimitedText])) then begin
				  DebugOut.Lines.Add('*** Save Character data error.');
				end;

				{保存技能资料}
				bindata := '';
				for j := 1 to 336 do begin
				  if Skill[j].Lv <> 0 then begin
					  bindata := bindata + IntToHex(j, 4);
					  bindata := bindata + IntToHex(Skill[j].Lv, 4);
				  end;
			  end;
		    if not ExecuteSqlCmd(Format('REPLACE INTO skills (GID,skillInfo) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
				  DebugOut.Lines.Add('*** Save Character Skill data error.');
				end;

				{保存人物身上物品资料}
				bindata := '';
			  for j := 1 to 100 do begin
				  if Item[j].ID <> 0 then begin
					  bindata := bindata + IntToHex(Item[j].ID, 4);
					  bindata := bindata + IntToHex(Item[j].Amount, 4);
					  bindata := bindata + IntToHex(Item[j].Equip, 4);
					  bindata := bindata + IntToHex(Item[j].Identify, 2);
					  bindata := bindata + IntToHex(Item[j].Refine, 2);
					  bindata := bindata + IntToHex(Item[j].Attr, 2);
					  bindata := bindata + IntToHex(Item[j].Card[0], 4);
					  bindata := bindata + IntToHex(Item[j].Card[1], 4);
					  bindata := bindata + IntToHex(Item[j].Card[2], 4);
					  bindata := bindata + IntToHex(Item[j].Card[3], 4);
				  end;
			  end;
		    if not ExecuteSqlCmd(Format('REPLACE INTO item (GID,equipItem) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
				  DebugOut.Lines.Add('*** Save Character Item data error.');
				end;

				{保存人物手推车中物品的资料}
				bindata := '';
			  for j := 1 to 100 do begin
		  		if Cart.Item[j].ID <> 0 then begin
					  bindata := bindata + IntToHex(Cart.Item[j].ID, 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Amount, 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Equip, 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Identify, 2);
					  bindata := bindata + IntToHex(Cart.Item[j].Refine, 2);
					  bindata := bindata + IntToHex(Cart.Item[j].Attr, 2);
					  bindata := bindata + IntToHex(Cart.Item[j].Card[0], 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Card[1], 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Card[2], 4);
					  bindata := bindata + IntToHex(Cart.Item[j].Card[3], 4);
		  		end;
		  	end;
		    if not ExecuteSqlCmd(Format('REPLACE INTO cartItem (GID,cartitem) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
				  DebugOut.Lines.Add('*** Save Character CartItem data error.');
				end;

				{保存人物MEMO记录点资料}
				if not ExecuteSqlCmd(Format('REPLACE INTO warpInfo (GID,mapName0,xPos0,yPos0,mapName1,xPos1,yPos1,mapName2,xPos2,yPos2) VALUES (''%d'',''%s'',''%d'',''%d'',''%s'',''%d'',''%d'',''%s'',''%d'',''%d'')', [CID, MemoMap[0], MemoPoint[0].X, MemoPoint[0].Y, MemoMap[1], MemoPoint[1].X, MemoPoint[1].Y, MemoMap[2], MemoPoint[2].X, MemoPoint[2].Y])) then begin
				  DebugOut.Lines.Add('*** Save Character CartItem data error.');
				end;
			end;
		end;
	end;

	Application.ProcessMessages;

	AssignFile(txt, AppPath + 'status.txt');
	Rewrite(txt);
	Writeln(txt, '##Weiss.StatusData.0x0002');
	sl.Clear;
	sl.Add('0');
	cnt := 0;
	for j := 0 to ServerFlag.Count - 1 do begin
		if (Copy(ServerFlag[j], 1, 1) = '\') then begin
			ServerFlag[j] := Copy(ServerFlag[j], 2, Length(ServerFlag[j]) - 1);
			if ((Copy(ServerFlag[j], 1, 1) <> '@') and (Copy(ServerFlag[j], 1, 2) <> '$@'))
			and ((ServerFlag.Values[ServerFlag.Names[j]] <> '') and (ServerFlag.Values[ServerFlag.Names[j]] <> '0')) then begin
				sl.Add(ServerFlag[j]);
				Inc(cnt);
			end;
		end;
	end;
	sl.Strings[0] := IntToStr(cnt);
	writeln(txt, sl.DelimitedText);
	CloseFile(txt);

	Application.ProcessMessages;

  {保存工会城堡资料  --用Name作为唯一索引，可能会有问题}
  if CastleList.Count <> 0 then
	begin
	  for i := 0 to CastleList.Count - 1 do
    begin
		  sl.Clear;
      tgc := CastleList.Objects[i] as TCastle;
      with tgc do
      begin
			  sl.Add('"' + Name + '"');
			  sl.Add(IntToStr(GID));
        sl.Add('"' + GName + '"');
        sl.Add('"' + GMName + '"');
        sl.Add(IntToStr(GKafra));
        sl.Add(IntToStr(EDegree));
        sl.Add(IntToStr(ETrigger));
        sl.Add(IntToStr(DDegree));
        sl.Add(IntToStr(DTrigger));
        for j := 0 to 7 do begin
          sl.Add(IntToStr(GuardStatus[j]));
        end;
				if not ExecuteSqlCmd(Format('REPLACE INTO gcastle (Name,GDID,GName,GMName,GKafra,EDegree,ETrigger,DDegree,DTrigger,GuardStatus0,GuardStatus1,GuardStatus2,GuardStatus3,GuardStatus4,GuardStatus5,GuardStatus6,GuardStatus7) VALUES (%s)', [sl.DelimitedText])) then
				begin
				  DebugOut.Lines.Add('*** Save Castle data error.');
				end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{保存组队资料 --需要优化下}
  if PartyNameList.Count <> 0 then
	begin
	  for i := 0 to PartyNameList.Count - 1 do
    begin
		  sl.Clear;
      tpa := PartyNameList.Objects[i] as TParty;
      with tpa do
      begin
			  sl.Add(IntToStr(i + 1));
        sl.Add('"' + Name + '"');
        sl.Add(IntToStr(EXPShare));
        sl.Add(IntToStr(ITEMShare));
			  for j := 0 to 11 do begin
				  sl.Add(IntToStr(MemberID[j]));
			  end;
			  if not ExecuteSqlCmd(Format('REPLACE INTO party (GRID,Name,EXPShare,ITEMShare,MemberID0,MemberID1,MemberID2,MemberID3,MemberID4,MemberID5,MemberID6,MemberID7,MemberID8,MemberID9,MemberID10,MemberID11) VALUES (%s)', [sl.DelimitedText])) then
				begin
				  DebugOut.Lines.Add('*** Save Party data error.');
				end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{保存工会资料}
  if GuildList.Count <> 0 then
	begin
	  for i := 0 to GuildList.Count - 1 do
    begin
      tg := GuildList.Objects[i] as TGuild;
      with tg do
      begin
			  {保存工会基本资料，解散工会时需要删除相应的记录}
				bindata := '';
				for j := 10000 to 10004 do
				begin
				  if GSkill[j].Lv <> 0 then
					begin
					  bindata := bindata + IntToHex(j, 4);
					  bindata := bindata + IntToHex(GSkill[j].Lv, 4);
				  end;
			  end;
			  if not ExecuteSqlCmd(Format('REPLACE INTO guildinfo (GDID,Name,LV,EXP,GSkillPoint,Subject,Notice,Agit,Emblem,present,DisposFV,DisposRW,skill) VALUES (''%d'',''%s'',''%d'',''%d'',''%d'',''%s'',''%s'',''%s'',''%d'',''%d'',''%d'',''%d'',''%s'')', [ID, Name, LV, EXP, GSkillPoint, Notice[0], Notice[1], Agit, Emblem, present, DisposFV, DisposRW, bindata])) then
				begin
				  DebugOut.Lines.Add('*** Save Guild data error.');
				end;

				{保存工会成员资料}
			  for j := 0 to 35 do begin
				  if MemberID[j] <> 0 then
					begin
					  if not ExecuteSqlCmd(Format('REPLACE INTO guildMinfo (GDID,GID,MemberExp,PositionID) VALUES (''%d'',''%d'',''%d'',''%d'')', [ID, MemberID[j], MemberEXP[j], MemberPos[j]])) then
				    begin
				      DebugOut.Lines.Add('*** Save Guild Member data error.');
				    end;
					end;
			  end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{保存宠物资料}

  {保存仓库里的宠物}
  for i := 0 to Player.Count - 1 do begin
    tp := Player.Objects[i] as TPlayer;
    for j := 1 to 100 do begin
      with tp.Kafra.Item[j] do begin
        if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
          k := Card[2] + Card[3] * $10000;
          if PetList.IndexOf( k ) <> -1 then begin
            tpe := PetList.IndexOfObject( k ) as TPet;
						SavePetData(tpe, j, 2);
		      end;
        end;
      end;
    end;
  end;

	Application.ProcessMessages;

	{保存人物身上的宠物 --删除人物需要删除相应记录}
  for i := 0 to Chara.Count - 1 do begin
    tc := Chara.Objects[i] as TChara;
    for j := 1 to 100 do begin
      with tc.Item[j] do begin
        if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
          k := Card[2] + Card[3] * $10000;
          if PetList.IndexOf( k ) <> -1 then begin
            tpe := PetList.IndexOfObject( k ) as TPet;
						SavePetData(tpe, j, 1);
	        end;
        end;
      end;
    end;
		{保存手推车里的宠物 删除人物时需要删除相应记录}
    for j := 1 to 100 do begin
      with tc.Cart.Item[j] do begin
        if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
          k := Card[2] + Card[3] * $10000;
          if PetList.IndexOf( k ) <> -1 then begin
            tpe := PetList.IndexOfObject( k ) as TPet;
						SavePetData(tpe, j, 3);
          end;
        end;
      end;
    end;
  end;
	sl.Free;
end;

//------------------------------------------------------------------------------
// 取得帐号资料
//------------------------------------------------------------------------------
function GetPlayerData(userid : String) : Boolean;
var
  tp  :TPlayer;
	i,j,k : Integer;
begin
  Result := False;

	if assigned(PlayerName) then
	begin
	  if PlayerName.IndexOf(userid) <> -1 then
		begin
		  Result := True;
		  Exit;
		end;
	end;

  DebugOut.Lines.Add(format('Load User Data From MySQL: %s', [userid]));

  if not ExecuteSqlCmd(format('SELECT L.AID,L.ID,L.passwd,L.Gender,L.Mail,L.GMMode,I.storeitem,I.money FROM login AS L LEFT JOIN storeitem AS I ON I.AID=L.AID WHERE ID=''%s'' LIMIT 1', [userid])) then begin
    DebugOut.Lines.Add(format('Load User Data From MySQL Error: %s', [userid]));
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then // 没有数据返回
    exit;

  tp := TPlayer.Create;
  with tp do begin
    ID := StrToInt(SQLDataSet.FieldValues['AID']);
    Name := SQLDataSet.FieldValues['ID'];
    Pass := SQLDataSet.FieldValues['passwd'];
    Gender := SQLDataSet.FieldValues['Gender'];
    Mail := SQLDataSet.FieldValues['Mail'];
    GMMode := SQLDataSet.FieldValues['GMMode'];
		ver2 := 9;

		if SQLDataSet.FieldValues['storeitem'] <> '' then
		begin
		  with SQLDataSet do
			begin
			  j := Integer(Length(FieldValues['storeitem']) div 34);
		    for i := 1 to j do begin
				  k := (i-1)*34 + 1;
					if ItemDB.IndexOf(HexToInt(MidStr(FieldValues['storeitem'], k, 4))) <> -1 then
					begin
			      Kafra.Item[i].ID := HexToInt(MidStr(FieldValues['storeitem'], k, 4));
			      Kafra.Item[i].Amount := HexToInt(MidStr(FieldValues['storeitem'], k+4, 4));
			      Kafra.Item[i].Equip := HexToInt(MidStr(FieldValues['storeitem'], k+8, 4));
			      Kafra.Item[i].Identify := HexToInt(MidStr(FieldValues['storeitem'], k+12, 2));
			      Kafra.Item[i].Refine := HexToInt(MidStr(FieldValues['storeitem'], k+14, 2));
			      Kafra.Item[i].Attr := HexToInt(MidStr(FieldValues['storeitem'], k+16, 2));
			      Kafra.Item[i].Card[0] := HexToInt(MidStr(FieldValues['storeitem'], k+18, 4));
			      Kafra.Item[i].Card[1] := HexToInt(MidStr(FieldValues['storeitem'], k+22, 4));
			      Kafra.Item[i].Card[2] := HexToInt(MidStr(FieldValues['storeitem'], k+26, 4));
			      Kafra.Item[i].Card[3] := HexToInt(MidStr(FieldValues['storeitem'], k+30, 4));
			      Kafra.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(Kafra.Item[i].ID)] as TItemDB;
//					  DebugOut.Lines.Add(format('Kafra Data: ID(%d), Amount(%d), Equip(%d), Identify(%d), Refine(%d), Attr(%d), Card[0](%d), Card[1](%d), Card[2](%d), Card[3](%d)', [Kafra.Item[i].ID, Kafra.Item[i].Amount, Kafra.Item[i].Equip, Kafra.Item[i].Identify, Kafra.Item[i].Refine, Kafra.Item[i].Attr, Kafra.Item[i].Card[0], Kafra.Item[i].Card[1], Kafra.Item[i].Card[2], Kafra.Item[i].Card[3]]));
					end;
				end;
				CalcInventory(Kafra);
			end;
		end;
  end;

  for j:= 0 to 8 do begin
		tp.CName[j] := '';
		tp.CData[j] := nil;
	end;

  PlayerName.AddObject(tp.Name, tp);
  Player.AddObject(tp.ID, tp);

	Result := True;
end;

//------------------------------------------------------------------------------
// 取得帐号的人物资料
//------------------------------------------------------------------------------
function GetCharaData(AID: cardinal) : Boolean;
var
  i,j,k,tmp  : Integer;
	tc : TChara;
	ta : TMapList;
	tp  :TPlayer;
	tpa :TParty;
begin
  Result := False;

	DebugOut.Lines.Add(format('Load Character Data From MySQL: AccountID = %d', [AID]));

	if ExecuteSqlCmd('SELECT C.*, M.*, S.skillInfo, I.equipItem, T.cartitem FROM Characters AS C ' + format('LEFT JOIN warpInfo AS M ON (C.GID=M.GID) LEFT JOIN skills AS S ON (C.GID=S.GID) LEFT JOIN item AS I ON (I.GID=C.GID) LEFT JOIN cartItem AS T ON (T.GID=C.GID) WHERE C.AID=''%d''', [AID])) then
	begin
	  while not SQLDataSet.Eof do
    begin
      tc := TChara.Create;
      with tc do begin
				CID           := StrToInt(SQLDataSet.FieldValues['GID']);
				Name          :=          SQLDataSet.FieldValues['Name'];
				
				if assigned(CharaName) then {如果该人物已经读入，就不用再读了}
				begin
					if CharaName.IndexOf(Name) <> -1 then
					begin
					  SQLDataSet.Next;
						continue;
					end;
				end;

				JID           := StrToInt(SQLDataSet.FieldValues['JID']);
				BaseLV        := StrToInt(SQLDataSet.FieldValues['BaseLV']);
				BaseEXP       := StrToInt(SQLDataSet.FieldValues['BaseEXP']);
				StatusPoint   := StrToInt(SQLDataSet.FieldValues['StatusPoint']);
				JobLV         := StrToInt(SQLDataSet.FieldValues['JobLV']);
				JobEXP        := StrToInt(SQLDataSet.FieldValues['JobEXP']);
				SkillPoint    := StrToInt(SQLDataSet.FieldValues['SkillPoint']);
				Zeny          := StrToInt(SQLDataSet.FieldValues['Zeny']);
				Stat1         := StrToInt(SQLDataSet.FieldValues['Stat1']);
				Stat2         := StrToInt(SQLDataSet.FieldValues['Stat2']);
				Option        := StrToInt(SQLDataSet.FieldValues['Options']);
        if Option = 4 then Option := 0;
				Karma         := StrToInt(SQLDataSet.FieldValues['Karma']);
				Manner        := StrToInt(SQLDataSet.FieldValues['Manner']);
				HP            := StrToInt(SQLDataSet.FieldValues['HP']);
				SP            := StrToInt(SQLDataSet.FieldValues['SP']);
				DefaultSpeed  := StrToInt(SQLDataSet.FieldValues['DefaultSpeed']);
				Hair          := StrToInt(SQLDataSet.FieldValues['Hair']);
				_2            := StrToInt(SQLDataSet.FieldValues['_2']);
				_3            := StrToInt(SQLDataSet.FieldValues['_3']);
				Weapon        := StrToInt(SQLDataSet.FieldValues['Weapon']);
				Shield        := StrToInt(SQLDataSet.FieldValues['Shield']);
				Head1         := StrToInt(SQLDataSet.FieldValues['Head1']);
				Head2         := StrToInt(SQLDataSet.FieldValues['Head2']);
				Head3         := StrToInt(SQLDataSet.FieldValues['Head3']);
				HairColor     := StrToInt(SQLDataSet.FieldValues['HairColor']);
				ClothesColor  := StrToInt(SQLDataSet.FieldValues['ClothesColor']);
		    ParamBase[0]  := StrToInt(SQLDataSet.FieldValues['STR']);
		    ParamBase[1]  := StrToInt(SQLDataSet.FieldValues['AGI']);
		    ParamBase[2]  := StrToInt(SQLDataSet.FieldValues['VIT']);
		    ParamBase[3]  := StrToInt(SQLDataSet.FieldValues['INTS']);
		    ParamBase[4]  := StrToInt(SQLDataSet.FieldValues['DEX']);
		    ParamBase[5]  := StrToInt(SQLDataSet.FieldValues['LUK']);
		    CharaNumber   := StrToInt(SQLDataSet.FieldValues['CharaNumber']);
		    Map           := SQLDataSet.FieldValues['Map'];
		    Point.X       := StrToInt(SQLDataSet.FieldValues['X']);
		    Point.Y       := StrToInt(SQLDataSet.FieldValues['Y']);
		    SaveMap       := SQLDataSet.FieldValues['SaveMap'];
		    SavePoint.X   := StrToInt(SQLDataSet.FieldValues['SX']);
		    SavePoint.Y   := StrToInt(SQLDataSet.FieldValues['SY']);
		    Plag          := StrToInt(SQLDataSet.FieldValues['Plag']);
		    PLv           := StrToInt(SQLDataSet.FieldValues['PLv']);
		    ID            := StrToInt(SQLDataSet.FieldValues['AID']);

				{读取MEMO记录点资料}
				for i := 0 to 2 do begin
					MemoMap[i]     := SQLDataSet.FieldValues['mapName' + IntToStr(i)];
					MemoPoint[i].X := StrToInt(SQLDataSet.FieldValues['xPos' + IntToStr(i)]);
					MemoPoint[i].Y := StrToInt(SQLDataSet.FieldValues['yPos' + IntToStr(i)]);
					{检查MEMO记录点地图是否有效}
					if (MemoMap[i] <> '') and (MapList.IndexOf(MemoMap[i]) = -1) then begin
						DebugOut.Lines.Add(Format('%s : Invalid MemoMap%d "%s"', [Name, i, MemoMap[i]]));
						MemoMap[i] := '';
						MemoPoint[i].X := 0;
						MemoPoint[i].Y := 0;
					end else if MemoMap[i] <> '' then begin
						{检查MEMO记录点地图坐标是否有效}
						ta := MapList.Objects[MapList.IndexOf(MemoMap[i])] as TMapList;
						if (MemoPoint[i].X < 0) or (MemoPoint[i].X >= ta.Size.X) or
							 (MemoPoint[i].Y < 0) or (MemoPoint[i].Y >= ta.Size.Y) then begin
							DebugOut.Lines.Add(Format('%s : Invalid MemoMap%d Point "%s"[%dx%d] (%d,%d)', [Name, i, MemoMap[i], ta.Size.X, ta.Size.Y, MemoPoint[i].X, MemoPoint[i].Y]));
							MemoMap[i] := '';
							MemoPoint[i].X := 0;
							MemoPoint[i].Y := 0;
						end;
					end;
				end;

				if CID < 100001 then CID := CID + 100001;

				{检查地图是否存在}
				if MapList.IndexOf(Map) = -1 then begin
				  DebugOut.Lines.Add(Format('%s : Invalid Map "%s"', [Name, Map]));
				  Map := 'prontera';
				  Point.X := 158;
				  Point.Y := 189;
			  end;
				{检查地图坐标是否有效}
				ta := MapList.Objects[MapList.IndexOf(Map)] as TMapList;
				if (Point.X < 0) or (Point.X >= ta.Size.X) or (Point.Y < 0) or (Point.Y >= ta.Size.Y) then begin
					DebugOut.Lines.Add(Format('%s : Invalid Map Point "%s"[%dx%d] (%d,%d)',[Name, Map, ta.Size.X, ta.Size.Y, Point.X, Point.Y]));
					Map := 'prontera';
					Point.X := 158;
					Point.Y := 189;
				end;
				{检查人物记录点地图是否有效}
				if MapList.IndexOf(SaveMap) = -1 then begin
					DebugOut.Lines.Add(Format('%s : Invalid SaveMap "%s"', [Name, SaveMap]));
					SaveMap := 'prontera';
					SavePoint.X := 158;
					SavePoint.Y := 189;
				end;
				{检查人物记录点地图坐标是否有效}
				ta := MapList.Objects[MapList.IndexOf(SaveMap)] as TMapList;
				if (SavePoint.X < 0) or (SavePoint.X >= ta.Size.X) or (SavePoint.Y < 0) or (SavePoint.Y >= ta.Size.Y) then begin
					DebugOut.Lines.Add(Format('%s : Invalid SaveMap Point "%s"[%dx%d] (%d,%d)', [Name, SaveMap, ta.Size.X, ta.Size.Y, SavePoint.X, SavePoint.Y]));
					SaveMap := 'prontera';
					SavePoint.X := 158;
					SavePoint.Y := 189;
				end;
        {读入所有技能资料，不知道干嘛要这么做。。。}
        for i := 0 to 336 do begin
			    if SkillDB.IndexOf(i) <> -1 then begin
				    Skill[i].Data := SkillDB.IndexOfObject(i) as TSkillDB;
			   end;
		    end;
        if (Plag <> 0) then begin
          Skill[tc.Plag].Plag := true;
        end;
				{读取人物技能等级}
				j := Integer(Length(SQLDataSet.FieldValues['skillInfo']) div 8);
			  for i := 1 to j do begin
				  k := (i-1)*8 + 1;
					tmp := HexToInt(MidStr(SQLDataSet.FieldValues['skillInfo'], k, 4));
					if SkillDB.IndexOf(tmp) <> -1 then
					begin
					  Skill[tmp].Lv   := HexToInt(MidStr(SQLDataSet.FieldValues['skillInfo'], k+4, 4));
            Skill[tmp].Card := false;
						Skill[tmp].Plag := false;
					end;
				end;
				{读取人物身上物品}
				j := Integer(Length(SQLDataSet.FieldValues['equipItem']) div 34);
			  for i := 1 to j do begin
				  k := (i-1)*34 + 1;
					if ItemDB.IndexOf(HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k, 4))) <> -1 then
					begin
				    Item[i].ID := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k, 4));
				    Item[i].Amount := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+4, 4));
				    Item[i].Equip := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+8, 4));
				    Item[i].Identify := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+12, 2));
				    Item[i].Refine := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+14, 2));
				    Item[i].Attr := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+16, 2));
				    Item[i].Card[0] := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+18, 4));
				    Item[i].Card[1] := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+22, 4));
				    Item[i].Card[2] := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+26, 4));
				    Item[i].Card[3] := HexToInt(MidStr(SQLDataSet.FieldValues['equipItem'], k+30, 4));
				    Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(Item[i].ID)] as TItemDB;
					end;
				end;
				{读取人物手推车里的物品}
				j := Integer(Length(SQLDataSet.FieldValues['cartitem']) div 34);
			  for i := 1 to j do begin
				  k := (i-1)*34 + 1;
					if ItemDB.IndexOf(HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k, 4))) <> -1 then
					begin
				    Cart.Item[i].ID := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k, 4));
				    Cart.Item[i].Amount := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+4, 4));
				    Cart.Item[i].Equip := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+8, 4));
				    Cart.Item[i].Identify := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+12, 2));
				    Cart.Item[i].Refine := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+14, 2));
				    Cart.Item[i].Attr := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+16, 2));
				    Cart.Item[i].Card[0] := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+18, 4));
				    Cart.Item[i].Card[1] := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+22, 4));
				    Cart.Item[i].Card[2] := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+26, 4));
				    Cart.Item[i].Card[3] := HexToInt(MidStr(SQLDataSet.FieldValues['cartitem'], k+30, 4));
				    Cart.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(Cart.Item[i].ID)] as TItemDB;
					end;
				end;
      end;
			
			{读取人物组队资料}
			for i := 0 to PartyNameList.Count - 1 do begin
				tpa := PartyNameList.Objects[i] as TParty;
				for j := 0 to 11 do begin
					if (tpa.MemberID[j] <> 0) AND (tpa.MemberID[j] = tc.CID) then begin
					  tc.PartyName := tpa.Name;
						tpa.Member[j] := tc;
					end;
				end;
			end;

			tp := Player.Objects[Player.IndexOf(AID)] as TPlayer;
			tp.CName[tc.CharaNumber] := tc.Name;
			tp.CData[tc.CharaNumber] := tc;
			tp.CData[tc.CharaNumber].CharaNumber := tc.CharaNumber;
			tp.CData[tc.CharaNumber].ID := tp.ID;
			tp.CData[tc.CharaNumber].Gender := tp.Gender;

			CharaName.AddObject(tc.Name, tc);
		  Chara.AddObject(tc.CID, tc);
	    SQLDataSet.Next;
	  end;
	end else begin
	  DebugOut.Lines.Add(format('Get Character data from MySQL Error: %d', [AID]));
		Exit;
	end;

	{读取宠物资料}
	GetPetData(AID);
	{读取人物工会资料}
	tp := Player.Objects[Player.IndexOf(AID)] as TPlayer;
	for j := 0 to 8 do begin
    if tp.CName[j] <> '' then begin
			k := CharaName.IndexOf(tp.CName[j]);
			if k <> -1 then begin
				tc := CharaName.Objects[k] as TChara;
				GetCharaGuildData(tc.CID);
			end;
		end;
	end;
end;

//------------------------------------------------------------------------------
// 从数据库删除人物
//------------------------------------------------------------------------------
function DeleteChar(GID: cardinal) : Boolean;
begin
  Result := False;

	DebugOut.Lines.Add(format('Delete Character data from MySQL: %d', [GID]));

  {删除人物资料}
	if not ExecuteSqlCmd(format('DELETE FROM Characters WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {删除人物技能资料}
	if not ExecuteSqlCmd(format('DELETE FROM skills WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character skill data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {删除人物物品资料}
	if not ExecuteSqlCmd(format('DELETE FROM item WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character item data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {删除人物手推车资料}
	if not ExecuteSqlCmd(format('DELETE FROM cartItem WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character cartItem data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {删除人物所在工会成员资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildMinfo WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete guildMinfo data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {删除人物MEMO记录点资料}
	if not ExecuteSqlCmd(format('DELETE FROM warpInfo WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete warpInfo data from MySQL Error: %d', [GID]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 检查人物是否存在
//------------------------------------------------------------------------------
function  CheckUserExist(userid: String) : Boolean;
begin
  Result := False;

  if not ExecuteSqlCmd(format('SELECT count(GID) as count FROM Characters WHERE Name=''%s'' LIMIT 1', [userid])) then begin
    DebugOut.Lines.Add(format('Get character data from MySQL Error: %s', [userid]));
		Exit;
	end;
	if SQLDataSet.FieldValues['count'] = 0 then
	  Exit;

	Result := True;
end;

//------------------------------------------------------------------------------
// 取得帐号的宠物资料
//------------------------------------------------------------------------------
function  GetPetData(AID: cardinal) : Boolean;
var
  i   : Integer;
  tpe : TPet;
	tp  : TPlayer;
	tc  : TChara;
begin
  Result := False;

	DebugOut.Lines.Add(format('Load Character''s Pet Data From MySQL: PlayerID = %d', [AID]));

	if ExecuteSqlCmd(Format('SELECT * FROM pet WHERE PlayerID=''%d''', [AID])) then begin
	  while not SQLDataSet.Eof do
    begin
      i := PetDB.IndexOf( StrToInt( SQLDataSet.FieldValues['JID'] ) );
		  if i <> -1 then begin
        tpe := TPet.Create;
        with tpe do begin
          PlayerID    := StrToInt( SQLDataSet.FieldValues['PlayerID'] );
          CharaID     := StrToInt( SQLDataSet.FieldValues['CharaID'] );
          Cart        := StrToInt( SQLDataSet.FieldValues['Cart'] );
          Index       := StrToInt( SQLDataSet.FieldValues['PIndex'] );
          Incubated   := StrToInt( SQLDataSet.FieldValues['Incubated'] );
          PetID       := StrToInt( SQLDataSet.FieldValues['PID'] );
          JID         := StrToInt( SQLDataSet.FieldValues['JID'] );
          Name        :=           SQLDataSet.FieldValues['Name'];
          Renamed     := StrToInt( SQLDataSet.FieldValues['Renamed'] );
          LV          := StrToInt( SQLDataSet.FieldValues['LV'] );
					Relation    := StrToInt( SQLDataSet.FieldValues['Relation'] );
          Fullness    := StrToInt( SQLDataSet.FieldValues['Fullness'] );
          Accessory   := StrToInt( SQLDataSet.FieldValues['Accessory'] );

          Data        := PetDB.Objects[i] as TPetDB;
        end;
        PetList.AddObject( tpe.PetID, tpe );

        {把宠物资料对应到人物、帐号上}
			  if tpe.PlayerID <> 0 then begin
				  if tpe.CharaID = 0 then begin  // 在仓库里
            tp := Player.IndexofObject( tpe.PlayerID ) as TPlayer;
						with tp.Kafra.Item[ tpe.Index ] do begin
							Attr    := 0;
							Card[0] := $FF00;
							Card[2] := tpe.PetID mod $10000;
							Card[3] := tpe.PetID div $10000;
						end;
					end else begin
						tc := Chara.IndexOfObject( tpe.CharaID ) as TChara;
						if tpe.Cart = 0 then begin  // 在身上
							with tc.Item[ tpe.Index ] do begin
								Attr    := tpe.Incubated;
								Card[0] := $FF00;
								Card[2] := tpe.PetID mod $10000;
								Card[3] := tpe.PetID div $10000;
							end;
						end else begin  // 在手推车里
							with tc.Cart.Item[ tpe.Index ] do begin
								Attr    := 0;
								Card[0] := $FF00;
								Card[2] := tpe.PetID mod $10000;
								Card[3] := tpe.PetID div $10000;
							end;
						end;
					end;
		  	end;
      end;

			SQLDataSet.Next;
		end;
	end else begin
	  DebugOut.Lines.Add('Pet data loading error...');
		Exit;
	end;
end;

//------------------------------------------------------------------------------
// 取得当前的帐号ID编号
//------------------------------------------------------------------------------
function  GetNowLoginID() : cardinal;
begin
  Result := 100101;
	if not ExecuteSqlCmd('SELECT AID FROM login ORDER BY AID DESC LIMIT 1') then begin
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then exit;

	Result := StrToInt( SQLDataSet.FieldValues['AID'] ) + 1;
end;
//------------------------------------------------------------------------------
// 取得当前的人物ID编号
//------------------------------------------------------------------------------
function  GetNowCharaID() : cardinal;
begin
  Result := 100001;
	if not ExecuteSqlCmd('SELECT GID FROM Characters ORDER BY GID DESC LIMIT 1') then begin
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then exit;

	Result := StrToInt( SQLDataSet.FieldValues['GID'] ) + 1;
end;
//------------------------------------------------------------------------------
// 取得当前的宠物ID编号
//------------------------------------------------------------------------------
function  GetNowPetID() : cardinal;
begin
  Result := 1;
	if not ExecuteSqlCmd('SELECT PID FROM pet ORDER BY PID DESC LIMIT 1') then begin
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then exit;

	Result := StrToInt( SQLDataSet.FieldValues['PID'] ) + 1;
end;

//------------------------------------------------------------------------------
// 保存宠物资料(place是指宠物存放的地点，1是身上，2是仓库，3是手推车)
//------------------------------------------------------------------------------
function  SavePetData(tpe : Tpet; PIndex: Integer; place: Integer) : Boolean;
var
  CharaID   : cardinal;
	Cart      : byte;
	Incubated : byte;
begin
  Result := False;

  case place of
	  1: begin
			Cart      := 0;
		  CharaID   := tpe.CharaID;
		  Incubated := tpe.Incubated;
		end;
		2: begin
		  Cart      := 0;
		  CharaID   := 0;
		  Incubated := 0;
		end;
		3: begin
			Cart      := 1;
		  CharaID   := tpe.CharaID;
		  Incubated := 0;
		end;
    else begin
	  Exit;
	  end;
	end;

  if not ExecuteSqlCmd(Format('REPLACE INTO pet (PID,PlayerID,CharaID,Cart,PIndex,Incubated,JID,Name,Renamed,LV,Relation,Fullness,Accessory) VALUES (''%d'',''%d'',''%d'',''%d'',''%d'',''%d'',''%d'',''%s'',''%d'',''%d'',''%d'',''%d'',''%d'')', [tpe.PetID, tpe.PlayerID, CharaID, Cart, PIndex, Incubated, tpe.JID, tpe.Name, tpe.Renamed, tpe.LV, tpe.Relation, tpe.Fullness, tpe.Accessory])) then
  begin
    DebugOut.Lines.Add('*** Save Pet data error.');
		Exit;
  end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 保存工会头衔资料
//------------------------------------------------------------------------------
function  SaveGuildMPosition(GDID: cardinal; PosName: string; PosInvite: boolean; PosPunish: boolean; PosEXP: byte; Grade: Integer) : Boolean;
begin
  Result := False;

  {删除旧资料}
	ExecuteSqlCmd(Format('DELETE FROM guildMPosition WHERE GDID=''%d'' AND Grade=''%d'' LIMIT 1', [GDID, Grade]));
  if not ExecuteSqlCmd(Format('INSERT INTO guildMPosition (GDID,Grade,PosName,PosInvite,PosPunish,PosEXP) VALUES (''%d'',''%d'',''%s'',''%s'',''%s'',''%d'')', [GDID, Grade, PosName, BoolToStr(PosInvite), BoolToStr(PosPunish), PosEXP])) then
	begin
	  DebugOut.Lines.Add('*** Save Guild Position data error.');
	  Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 取得人物的工会资料
//------------------------------------------------------------------------------
function  GetCharaGuildData(GID: cardinal) : Boolean;
var
  j  : Integer;
  tc : TChara;
	tg : TGuild;
begin
  Result := False;
	
	if not ExecuteSqlCmd(Format('SELECT GDID FROM guildMinfo WHERE GID=''%d'' LIMIT 1', [GID])) then begin
		Exit;
	end;
  SQLDataSet.First;

	tc := Chara.Objects[Chara.IndexOf(GID)] as TChara;
  if SQLDataSet.Eof then begin
	  tc.GuildID := 0;
		tc.GuildName := '';
		tc.ClassName := '';
		tc.GuildPos := 0;
	  exit;
	end;

  tg := GuildList.Objects[GuildList.IndexOf(SQLDataSet.FieldValues['GDID'])] as TGuild;
	with tg do begin
		for j := 0 to 35 do begin
			if MemberID[j] = tc.CID then begin
				tc.GuildName := Name;
				tc.GuildID := ID;
				tc.ClassName := PosName[MemberPos[j]];
				tc.GuildPos := j;
				Member[j] := tc;
				if (j = 0) then MasterName := tc.Name;
				SLV := SLV + tc.BaseLV;
			end;
		end;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 从数据库删除工会成员(mtype=1为退会，mtype=2为开除)
//------------------------------------------------------------------------------
function  DeleteGuildMember(GID: cardinal; mtype: Integer; tgb: TGBan; GDID: cardinal) : Boolean;
begin
  Result := False;
	
	if mtype = 2 then begin
	  if not ExecuteSqlCmd(format('INSERT INTO guildBanishInfo (GDID,MemberName,MemberAccount,Reason) VALUES (''%d'',''%s'',''%s'',''%s'')', [GDID, tgb.Name, tgb.AccName, tgb.Reason])) then begin
      DebugOut.Lines.Add(format('INSERT guildBanishInfo data to MySQL Error: %d', [GID]));
//		  Exit;
	  end;
	end;

	if not ExecuteSqlCmd(format('DELETE FROM guildMinfo WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete guildMinfo data from MySQL Error: %d', [GID]));
		Exit;
	end;

  Result := True;;
end;

//------------------------------------------------------------------------------
// 从数据库删除组队
//------------------------------------------------------------------------------
function  DeleteParty(Name: string) : Boolean;
begin
  Result := False;
	
	if not ExecuteSqlCmd(format('DELETE FROM party WHERE Name=''%s'' LIMIT 1', [Name])) then begin
    DebugOut.Lines.Add(format('Delete party data from MySQL Error: %s', [Name]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 保存同盟、敌对工会资料(mtype=1同盟，mtype=2敌对)
//------------------------------------------------------------------------------
function  SaveGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean;
begin
  Result := False;

  if not ExecuteSqlCmd(Format('INSERT INTO guildAllyInfo (GDID,GuildName,Relation) VALUES (''%d'',''%s'',''%d'')', [GDID, GuildName, mtype])) then
	begin
	  DebugOut.Lines.Add('*** Save Guild AllyInfo data error.');
		exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 删除同盟、敌对工会资料(mtype=1同盟，mtype=2敌对)
//------------------------------------------------------------------------------
function  DeleteGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean;
begin
  Result := False;
	
	if not ExecuteSqlCmd(format('DELETE FROM guildAllyInfo WHERE GDID=''%d'' AND Name=''%s'' AND Relation=''%d'' LIMIT 1', [GDID, GuildName, mtype])) then begin
    DebugOut.Lines.Add(format('Delete guildAllyInfo data from MySQL Error: %s', [GuildName]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// 删除工会资料
//------------------------------------------------------------------------------
function  DeleteGuildInfo(GDID: cardinal) : Boolean;
begin
  Result := False;

	DebugOut.Lines.Add(format('Delete Guild data from MySQL: %d', [GDID]));

  {删除工会资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildinfo WHERE GDID=''%d'' LIMIT 1', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {删除工会成员资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildMinfo WHERE GDID=''%d'' LIMIT 36', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild Member data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {删除工会头衔资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildMPosition WHERE GDID=''%d'' LIMIT 20', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild Position data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {删除工会开除成员记录资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildBanishInfo WHERE GDID=''%d''', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild BanishInfo data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {删除工会同盟、敌对资料}
	if not ExecuteSqlCmd(format('DELETE FROM guildAllyInfo WHERE GDID=''%d''', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild AllyInfo data from MySQL Error: %d', [GDID]));
		Exit;
	end;

	Result := True;
end;

end.
{MySQL�������϶�ȡ  --Michen}
unit SQLData;



interface

uses
	Windows, MMSystem, Forms, Classes, SysUtils, IniFiles, Common, DBXpress, DB, SqlExpr, StrUtils;

//==============================================================================
// ����&����
    function  HexToInt(Hex : string) : Cardinal; 
    function  ExecuteSqlCmd(sqlcmd: String) : Boolean;
		procedure SQLDataLoad();
		procedure SQLDataSave();
		function  GetPlayerData(userid: String; AID: cardinal = 0) : Boolean; {ȡ���ʺ�����}
		function  GetCharaData(GID: cardinal) : Boolean; {ȡ����������}
		function  GetAccCharaData(AID: cardinal) : Boolean; {ȡ���ʺŵ���������}
		function  GetPetData(AID: cardinal) : Boolean; {ȡ���ʺŵĳ�������}
		function  GetCharaGuildData(GID: cardinal) : Boolean; {ȡ������Ĺ�������}
		function  GetCharaPartyGuild(GID: cardinal) : Boolean; {ȡ������Ĺ��ᡢ��ӣ��Լ����г�Ա����}
		function  DeleteChar(GID: cardinal) : Boolean; {�����ݿ�ɾ������}
		function  DeleteGuildMember(GID: cardinal; mtype: Integer; tgb: TGBan; GDID: cardinal) : Boolean; {�����ݿ�ɾ�������Ա}
		function  DeleteParty(Name: string) : Boolean; {�����ݿ�ɾ�����}
		function  DeleteGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean; {ɾ��ͬ�ˡ��жԹ�������}
		function  DeleteGuildInfo(GDID: cardinal) : Boolean; {ɾ����������}
		function  CheckUserExist(userid: String) : Boolean; {��������Ƿ����}
		function  GetNowLoginID() : cardinal; {ȡ�õ�ǰ���ʺ�ID���}
		function  GetNowCharaID() : cardinal; {ȡ�õ�ǰ������ID���}
		function  GetNowPetID() : cardinal; {ȡ�õ�ǰ�ĳ���ID���}
		function  SaveCharaData(tc : TChara) : Boolean; {������������}
		function  SavePetData(tpe : Tpet; PIndex: Integer; place: Integer) : Boolean; {�����������}
		function  SaveGuildMPosition(GDID: cardinal; PosName: string; PosInvite: boolean; PosPunish: boolean; PosEXP: byte; Grade: Integer) : Boolean; {���湤��ͷ������}
		function  SaveGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean; {����ͬ�ˡ��жԹ�������}
		function  addslashes(Strings: String) : String; {���ݿ��ַ�������}
		function  unaddslashes(Strings: String) : String; {���ݿ��ַ�������}
//==============================================================================

implementation

var
  SQLDataSet    :TSQLDataSet;
  SQLConnection :TSQLConnection;

//------------------------------------------------------------------------------
// ʮ������תʮ����
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
// ִ�����ݿ��ѯ
//------------------------------------------------------------------------------
function  ExecuteSqlCmd(sqlcmd: String) : Boolean;
begin
  Result := False;

  {��ʼ�����ݿ�}
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

  {�������ݿ�}
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
//	DebugOut.Lines.Add(sqlcmd);
	Result := True;
end;

//------------------------------------------------------------------------------
// ��ȡȫ�����������
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

  {��ȡ���������}
	DebugOut.Lines.Add('Castle data loading from SQL...');
	Application.ProcessMessages;

	if ExecuteSqlCmd('SELECT * FROM guild_castle') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tgc := TCastle.Create;
      with tgc do begin
			  Name     := unaddslashes(SQLDataSet.FieldValues['Name']);
        GID      := StrToInt(SQLDataSet.FieldValues['GDID']);
        GName    := unaddslashes(SQLDataSet.FieldValues['GName']);
        GMName   := unaddslashes(SQLDataSet.FieldValues['GMName']);
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

  {��ȡ�������}
	DebugOut.Lines.Add('Party data loading from SQL...');
	Application.ProcessMessages;

	if ExecuteSqlCmd('SELECT * FROM party') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tpa := TParty.Create;
      with tpa do begin
			  Name     := unaddslashes(SQLDataSet.FieldValues['Name']);
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

  {��ȡ��������}
	DebugOut.Lines.Add('Guild data loading from SQL...');
	Application.ProcessMessages;

  if ExecuteSqlCmd('SELECT * FROM guild_info') then
	begin
	  while not SQLDataSet.Eof do
    begin
      tg := TGuild.Create;
      with tg do begin
			  ID := StrToInt(SQLDataSet.FieldValues['GDID']);
			  if (ID > NowGuildID) then NowGuildID := ID;
			  Name := unaddslashes(SQLDataSet.FieldValues['Name']);
			  LV := StrToInt(SQLDataSet.FieldValues['LV']);
			  EXP := StrToInt(SQLDataSet.FieldValues['EXP']);
			  GSkillPoint := StrToInt(SQLDataSet.FieldValues['GSkillPoint']);
			  Notice[0] := unaddslashes(SQLDataSet.FieldValues['Subject']);
			  Notice[1] := unaddslashes(SQLDataSet.FieldValues['Notice']);
			  Agit := unaddslashes(SQLDataSet.FieldValues['Agit']);
			  Emblem := StrToInt(SQLDataSet.FieldValues['Emblem']);
			  Present := StrToInt(SQLDataSet.FieldValues['Present']);
			  DisposFV := StrToInt(SQLDataSet.FieldValues['DisposFV']);
			  DisposRW := StrToInt(SQLDataSet.FieldValues['DisposRW']);
				
				for i := 0 to 35 do begin
					MemberID[i] := 0;
					MemberPos[i] := 0;
					MemberEXP[i] := 0;
				end;
			  for i := 10000 to 10004 do
				begin
			  	if GSkillDB.IndexOf(i) <> -1 then
					begin
			  		GSkill[i].Data := GSkillDB.IndexOfObject(i) as TSkillDB;
			  	end;
			  end;

				{��ȡ���Ἴ��}
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

  {ѭ�����й��ᣬ��ȡ�����Ա������}
  for i := 0 to GuildList.Count - 1 do
	begin
		tg := GuildList.Objects[i] as TGuild;
		with tg do
		begin
		  {��ȡ�����Ա����}
		  if ExecuteSqlCmd(Format('SELECT * FROM guild_members WHERE GDID=''%d'' LIMIT 36', [ID])) then
			begin
			  j := 0;
			  while not SQLDataSet.Eof do
				begin
				  if j > 35 then break;
				  MemberID[j]  := StrToInt(SQLDataSet.FieldValues['GID']);
				  MemberPos[j] := StrToInt(SQLDataSet.FieldValues['PositionID']);
				  MemberEXP[j] := StrToInt(SQLDataSet.FieldValues['MemberExp']);
					if (MemberID[j] <> 0) then Inc(RegUsers, 1);
					INC(j);
					SQLDataSet.Next;
				end;
      end;

			Application.ProcessMessages;

			{��ȡ����ƺ�����}
			if ExecuteSqlCmd(Format('SELECT * FROM guild_positions WHERE GDID=''%d'' LIMIT 20', [ID])) then
			begin
			  j := 0;
				while not SQLDataSet.Eof do
				begin
					PosName[j]   := unaddslashes(SQLDataSet.FieldValues['PosName']);
				  PosInvite[j] := StrToBool(SQLDataSet.FieldValues['PosInvite']);
				  PosPunish[j] := StrToBool(SQLDataSet.FieldValues['PosPunish']);
				  PosEXP[j]    := StrToInt(SQLDataSet.FieldValues['PosEXP']);
					INC(j);
					SQLDataSet.Next;
				end;
			end;

			Application.ProcessMessages;

			{��ȡ���Ὺ����Ա��¼}
			if ExecuteSqlCmd(Format('SELECT * FROM guild_banish WHERE GDID=''%d''', [ID])) then
			begin
			  while not SQLDataSet.Eof do
				begin
          tgb := TGBan.Create;
				  tgb.Name    := unaddslashes(SQLDataSet.FieldValues['MemberName']);
				  tgb.AccName := unaddslashes(SQLDataSet.FieldValues['MemberAccount']);
				  tgb.Reason  := unaddslashes(SQLDataSet.FieldValues['Reason']);
				  GuildBanList.AddObject(tgb.Name, tgb);
					SQLDataSet.Next;
				end;
			end;

			Application.ProcessMessages;

			{��ȡͬ�ˡ��жԹ���}
			if ExecuteSqlCmd(Format('SELECT * FROM guild_allies WHERE GDID=''%d''', [ID])) then
			begin
			  while not SQLDataSet.Eof do
				begin
          tgl := TGRel.Create;
				  tgl.ID        := StrToInt(SQLDataSet.FieldValues['GDID']);
				  tgl.GuildName := unaddslashes(SQLDataSet.FieldValues['GuildName']);
					if SQLDataSet.FieldValues['Relation'] = 1 then
				    RelAlliance.AddObject(tgl.GuildName, tgl)  // ͬ�˹���
					else
					  RelHostility.AddObject(tgl.GuildName, tgl); // �жԹ���
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
// �����ڴ��е�����
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
	sl  :TStringList;
	txt :TextFile;
	cnt :integer;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';
  {�����ʺźͲֿ�����}
  if PlayerName.Count <> 0 then
  begin
    for i := 0 to PlayerName.Count - 1 do
    begin
		  bindata := '';
      tp := PlayerName.Objects[i] as TPlayer;
      with tp do
      begin
			  if not ExecuteSqlCmd(Format('REPLACE INTO accounts (AID,ID,passwd,Gender,Mail,Banned) VALUES (''%d'',''%s'',''%s'',''%d'',''%s'',''%d'')', [ID, addslashes(Name), addslashes(Pass), Gender, addslashes(Mail), Banned])) then begin
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
		    if not ExecuteSqlCmd(Format('REPLACE INTO storage (AID,storeitem) VALUES (''%d'',''%s'')', [ID, bindata])) then begin
				  DebugOut.Lines.Add('*** Save Player Kafra data error.');
				end;
      end;
    end;
  end;

	Application.ProcessMessages;

	{������������}
	if CharaName.Count <> 0 then begin
	  for i := 0 to CharaName.Count - 1 do begin
		  tc := CharaName.Objects[i] as TChara;
      SaveCharaData(tc);
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

  {���湤��Ǳ�����  --��Name��ΪΨһ���������ܻ�������}
  if CastleList.Count <> 0 then
	begin
	  for i := 0 to CastleList.Count - 1 do
    begin
      tgc := CastleList.Objects[i] as TCastle;
      with tgc do
      begin
			  bindata := '''' + addslashes(Name) + '''';
			  bindata := bindata + ' ,' + IntToStr(GID);
			  bindata := bindata + ' ,''' + addslashes(GName) + '''';
			  bindata := bindata + ' ,''' + addslashes(GMName) + '''';
			  bindata := bindata + ' ,' + IntToStr(GKafra);
			  bindata := bindata + ' ,' + IntToStr(EDegree);
			  bindata := bindata + ' ,' + IntToStr(ETrigger);
			  bindata := bindata + ' ,' + IntToStr(DDegree);
			  bindata := bindata + ' ,' + IntToStr(DTrigger);
        for j := 0 to 7 do begin
			    bindata := bindata + ' ,' + IntToStr(GuardStatus[j]);
        end;
				if not ExecuteSqlCmd(Format('REPLACE INTO guild_castle (Name,GDID,GName,GMName,GKafra,EDegree,ETrigger,DDegree,DTrigger,GuardStatus0,GuardStatus1,GuardStatus2,GuardStatus3,GuardStatus4,GuardStatus5,GuardStatus6,GuardStatus7) VALUES (%s)', [bindata])) then
				begin
				  DebugOut.Lines.Add('*** Save Castle data error.');
				end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{����������� --��Ҫ�Ż���}
  if PartyNameList.Count <> 0 then
	begin
	  for i := 0 to PartyNameList.Count - 1 do
    begin
      tpa := PartyNameList.Objects[i] as TParty;
      with tpa do
      begin
			  bindata := IntToStr(i + 1);
			  bindata := bindata + ' ,''' + addslashes(Name) + '''';
			  bindata := bindata + ' ,' + IntToStr(EXPShare);
			  bindata := bindata + ' ,' + IntToStr(ITEMShare);
			  for j := 0 to 11 do begin
			    bindata := bindata + ' ,' + IntToStr(MemberID[j]);
			  end;
			  if not ExecuteSqlCmd(Format('REPLACE INTO party (GRID,Name,EXPShare,ITEMShare,MemberID0,MemberID1,MemberID2,MemberID3,MemberID4,MemberID5,MemberID6,MemberID7,MemberID8,MemberID9,MemberID10,MemberID11) VALUES (%s)', [bindata])) then
				begin
				  DebugOut.Lines.Add('*** Save Party data error.');
				end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{���湤������}
  if GuildList.Count <> 0 then
	begin
	  for i := 0 to GuildList.Count - 1 do
    begin
      tg := GuildList.Objects[i] as TGuild;
      with tg do
      begin
			  {���湤��������ϣ���ɢ����ʱ��Ҫɾ����Ӧ�ļ�¼}
				bindata := '';
				for j := 10000 to 10004 do
				begin
				  if GSkill[j].Lv <> 0 then
					begin
					  bindata := bindata + IntToHex(j, 4);
					  bindata := bindata + IntToHex(GSkill[j].Lv, 4);
				  end;
			  end;
			  if not ExecuteSqlCmd(Format('REPLACE INTO guild_info (GDID,Name,LV,EXP,GSkillPoint,Subject,Notice,Agit,Emblem,present,DisposFV,DisposRW,skill) VALUES (''%d'',''%s'',''%d'',''%d'',''%d'',''%s'',''%s'',''%s'',''%d'',''%d'',''%d'',''%d'',''%s'')', [ID, addslashes(Name), LV, EXP, GSkillPoint, addslashes(Notice[0]), addslashes(Notice[1]), addslashes(Agit), Emblem, present, DisposFV, DisposRW, bindata])) then
				begin
				  DebugOut.Lines.Add('*** Save Guild data error.');
				end;

				{���湤���Ա����}
			  for j := 0 to 35 do begin
				  if MemberID[j] <> 0 then
					begin
					  if not ExecuteSqlCmd(Format('REPLACE INTO guild_members (GDID,GID,MemberExp,PositionID) VALUES (''%d'',''%d'',''%d'',''%d'')', [ID, MemberID[j], MemberEXP[j], MemberPos[j]])) then
				    begin
				      DebugOut.Lines.Add('*** Save Guild Member data error.');
				    end;
					end;
			  end;
      end;
    end;
	end;

	Application.ProcessMessages;

	{�����������}

  {����ֿ���ĳ���}
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

	{�����������ϵĳ��� --ɾ��������Ҫɾ����Ӧ��¼}
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
		{�������Ƴ���ĳ��� ɾ������ʱ��Ҫɾ����Ӧ��¼}
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
// ȡ���ʺ�����
//------------------------------------------------------------------------------
function GetPlayerData(userid : String; AID: cardinal = 0) : Boolean;
var
  tp  :TPlayer;
	i,j,k : Integer;
begin
  Result := False;

  {if AID = 0 then begin
		if assigned(PlayerName) then
		begin
			if PlayerName.IndexOf(userid) <> -1 then begin
				Result := True;
				Exit;
			end;
		end;
		DebugOut.Lines.Add(format('Load User Data From MySQL: userid = %s', [userid]));

		if not ExecuteSqlCmd(format('SELECT L.AID,L.ID,L.passwd,L.Gender,L.Mail,L.Banned,I.storeitem,I.money FROM accounts AS L LEFT JOIN storage AS I ON I.AID=L.AID WHERE L.ID=''%s'' LIMIT 1', [addslashes(userid)])) then begin
			DebugOut.Lines.Add(format('Load User Data From MySQL Error: %s', [userid]));
			Exit;
		end
	end else begin
		if assigned(PlayerName) then
		begin
			if Player.IndexOf(AID) <> -1 then begin
				Result := True;
				Exit;
			end;
		end;
		DebugOut.Lines.Add(format('Load User Data From MySQL: AID = %d', [AID]));

		if not ExecuteSqlCmd(format('SELECT L.AID,L.ID,L.passwd,L.Gender,L.Mail,L.Banned,I.storeitem,I.money FROM accounts AS L LEFT JOIN storage AS I ON I.AID=L.AID WHERE L.AID=''%d'' LIMIT 1', [AID])) then begin
			DebugOut.Lines.Add(format('Load User Data From MySQL Error: %d', [AID]));
			Exit;
		end
	end;}

    if AID = 0 then begin
        if PlayerName.IndexOf(userid) <> -1 then begin
            tp := PlayerName.Objects[PlayerName.IndexOf(userid)] as TPlayer;
        end else begin
            tp := TPlayer.Create;
        end;
    end else begin
        if assigned(PlayerName) then begin
			if Player.IndexOf(AID) <> -1 then begin
				Result := True;
				Exit;
			end;
        end;
	end;

	if ExecuteSqlCmd(format('SELECT L.AID,L.ID,L.passwd,L.Gender,L.Mail,L.Banned,I.storeitem,I.money FROM accounts AS L LEFT JOIN storage AS I ON I.AID=L.AID WHERE L.ID=''%s'' LIMIT 1', [addslashes(userid)])) then
	begin
  SQLDataSet.First;
    if not SQLDataSet.Eof then begin


  with tp do begin
    ID := StrToInt(SQLDataSet.FieldValues['AID']);
    Name := unaddslashes(SQLDataSet.FieldValues['ID']);
    Pass := unaddslashes(SQLDataSet.FieldValues['passwd']);
    Gender := StrToInt(SQLDataSet.FieldValues['Gender']);
    Mail := unaddslashes(SQLDataSet.FieldValues['Mail']);
    Banned := StrToInt(SQLDataSet.FieldValues['Banned']);
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
	  tp.CID[j] := 0;
		tp.CName[j] := '';
		tp.CData[j] := nil;
	end;

    if AID = 0 then begin
        if PlayerName.IndexOf(userid) <> -1 then begin

        end else begin
  PlayerName.AddObject(tp.Name, tp);
  Player.AddObject(tp.ID, tp);
        end;
    end;


	Result := True;
end;
    end;
end;

//------------------------------------------------------------------------------
// ȡ����������
//------------------------------------------------------------------------------
function GetCharaData(GID: cardinal) : Boolean;
var
  i,j,k,tmp  : Integer;
	tc : TChara;
	ta : TMapList;
	tp  :TPlayer;
	tpa :TParty;
	sl  :TStringList;
    str :string;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

  Result := False;

	DebugOut.Lines.Add(format('Load Character Data From MySQL: CharaID = %d', [GID]));

	if ExecuteSqlCmd('SELECT C.*, M.*, S.skillInfo, I.equipItem, T.cartitem, V.flagdata FROM characters AS C ' + format('LEFT JOIN warpmemo AS M ON (C.GID=M.GID) LEFT JOIN skills AS S ON (C.GID=S.GID) LEFT JOIN inventory AS I ON (I.GID=C.GID) LEFT JOIN cart AS T ON (T.GID=C.GID) LEFT JOIN character_flags AS T ON (V.GID=C.GID) WHERE C.GID=''%d'' LIMIT 1', [GID])) then
	begin
		SQLDataSet.First;
    if not SQLDataSet.Eof then begin
	  //while not SQLDataSet.Eof do begin

      tc := TChara.Create;
      with tc do begin
				CID           := StrToInt(SQLDataSet.FieldValues['GID']);
				Name          := unaddslashes(SQLDataSet.FieldValues['Name']);
                str := Name;
				
				if assigned(CharaName) then {����������Ѿ����룬�Ͳ����ٶ���}
				begin
					if CharaName.IndexOf(Name) <> -1 then
					begin
                        tc := CharaName.Objects[CharaName.Indexof(str)] as TChara;
					  {Result := True;
						Exit;           }
					  //SQLDataSet.Next;
						//continue;
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
        if (HP < 0) then begin
          HP := 0;
        end;
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
		    Map           := unaddslashes(SQLDataSet.FieldValues['Map']);
		    Point.X       := StrToInt(SQLDataSet.FieldValues['X']);
		    Point.Y       := StrToInt(SQLDataSet.FieldValues['Y']);
		    SaveMap       := unaddslashes(SQLDataSet.FieldValues['SaveMap']);
		    SavePoint.X   := StrToInt(SQLDataSet.FieldValues['SX']);
		    SavePoint.Y   := StrToInt(SQLDataSet.FieldValues['SY']);
		    Plag          := StrToInt(SQLDataSet.FieldValues['Plag']);
		    PLv           := StrToInt(SQLDataSet.FieldValues['PLv']);
				PartyName     := '';
		    ID            := StrToInt(SQLDataSet.FieldValues['AID']);

				{��ȡMEMO��¼������}
				for i := 0 to 2 do begin
					MemoMap[i]     := unaddslashes(SQLDataSet.FieldValues['mapName' + IntToStr(i)]);
					MemoPoint[i].X := StrToInt(SQLDataSet.FieldValues['xPos' + IntToStr(i)]);
					MemoPoint[i].Y := StrToInt(SQLDataSet.FieldValues['yPos' + IntToStr(i)]);
					{���MEMO��¼���ͼ�Ƿ���Ч}
					if (MemoMap[i] <> '') and (MapList.IndexOf(MemoMap[i]) = -1) then begin
						DebugOut.Lines.Add(Format('%s : Invalid MemoMap%d "%s"', [Name, i, MemoMap[i]]));
						MemoMap[i] := '';
						MemoPoint[i].X := 0;
						MemoPoint[i].Y := 0;
					end else if MemoMap[i] <> '' then begin
						{���MEMO��¼���ͼ�����Ƿ���Ч}
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

				{����ͼ�Ƿ����}
				if MapList.IndexOf(Map) = -1 then begin
				  DebugOut.Lines.Add(Format('%s : Invalid Map "%s"', [Name, Map]));
				  Map := 'prontera';
				  Point.X := 158;
				  Point.Y := 189;
			  end;
				{����ͼ�����Ƿ���Ч}
				ta := MapList.Objects[MapList.IndexOf(Map)] as TMapList;
				if (Point.X < 0) or (Point.X >= ta.Size.X) or (Point.Y < 0) or (Point.Y >= ta.Size.Y) then begin
					DebugOut.Lines.Add(Format('%s : Invalid Map Point "%s"[%dx%d] (%d,%d)',[Name, Map, ta.Size.X, ta.Size.Y, Point.X, Point.Y]));
					Map := 'prontera';
					Point.X := 158;
					Point.Y := 189;
				end;
				{��������¼���ͼ�Ƿ���Ч}
				if MapList.IndexOf(SaveMap) = -1 then begin
					DebugOut.Lines.Add(Format('%s : Invalid SaveMap "%s"', [Name, SaveMap]));
					SaveMap := 'prontera';
					SavePoint.X := 158;
					SavePoint.Y := 189;
				end;
				{��������¼���ͼ�����Ƿ���Ч}
				ta := MapList.Objects[MapList.IndexOf(SaveMap)] as TMapList;
				if (SavePoint.X < 0) or (SavePoint.X >= ta.Size.X) or (SavePoint.Y < 0) or (SavePoint.Y >= ta.Size.Y) then begin
					DebugOut.Lines.Add(Format('%s : Invalid SaveMap Point "%s"[%dx%d] (%d,%d)', [Name, SaveMap, ta.Size.X, ta.Size.Y, SavePoint.X, SavePoint.Y]));
					SaveMap := 'prontera';
					SavePoint.X := 158;
					SavePoint.Y := 189;
				end;
        {�������м������ϣ���֪������Ҫ��ô��������}
        for i := 0 to 336 do begin
			    if SkillDB.IndexOf(i) <> -1 then begin
				    Skill[i].Data := SkillDB.IndexOfObject(i) as TSkillDB;
			   end;
		    end;
        if (Plag <> 0) then begin
          Skill[tc.Plag].Plag := true;
        end;
				{��ȡ���＼�ܵȼ�}
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
				{��ȡ����������Ʒ}
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
				{��ȡ�������Ƴ������Ʒ}
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

            sl.DelimitedText := SQLDataSet.FieldValues['flagdata'];
			for i := 0 to (sl.Count - 1) do begin
                tc.Flag.Add(sl.Strings[i]);
            end;

			CharaName.AddObject(tc.Name, tc);
		  Chara.AddObject(tc.CID, tc);

      GetPlayerData('', tc.ID);

      if Player.IndexOf(tc.ID) <> -1 then begin
			  tp := Player.Objects[Player.IndexOf(tc.ID)] as TPlayer;
			  tp.CID[tc.CharaNumber] := tc.CID;
			  tp.CName[tc.CharaNumber] := tc.Name;
			  tp.CData[tc.CharaNumber] := tc;
			  tp.CData[tc.CharaNumber].Gender := tp.Gender;
      end;
			{��ȡ��������}
			GetPetData(tc.ID);
			{��ȡ���﹤������}
			GetCharaGuildData(tc.CID);
			// ��ȡ�����������
			for i := 0 to PartyNameList.Count - 1 do begin
				tpa := PartyNameList.Objects[i] as TParty;
				for j := 0 to 11 do begin
					if (tpa.MemberID[j] <> 0) AND (tpa.MemberID[j] = tc.CID) then begin
						tc.PartyName := tpa.Name;
						tpa.Member[j] := tc;
						break;
					end;
				end;
			end;

//	    SQLDataSet.Next;
	  end;
	end else begin
	  DebugOut.Lines.Add(format('Get Character data from MySQL Error: %d', [GID]));
		Exit;
	end;
end;

//------------------------------------------------------------------------------
// �����ݿ�ɾ������
//------------------------------------------------------------------------------
function DeleteChar(GID: cardinal) : Boolean;
begin
  Result := False;

	DebugOut.Lines.Add(format('Delete Character data from MySQL: %d', [GID]));

  {ɾ����������}
	if not ExecuteSqlCmd(format('DELETE FROM characters WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {ɾ�����＼������}
	if not ExecuteSqlCmd(format('DELETE FROM skills WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character skill data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {ɾ��������Ʒ����}
	if not ExecuteSqlCmd(format('DELETE FROM inventory WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character item data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {ɾ���������Ƴ�����}
	if not ExecuteSqlCmd(format('DELETE FROM cart WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete Character cartItem data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {ɾ���������ڹ����Ա����}
	if not ExecuteSqlCmd(format('DELETE FROM guild_members WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete guildMinfo data from MySQL Error: %d', [GID]));
		Exit;
	end;
  {ɾ������MEMO��¼������}
	if not ExecuteSqlCmd(format('DELETE FROM warpmemo WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete warpInfo data from MySQL Error: %d', [GID]));
		Exit;
	end;

	if not ExecuteSqlCmd(format('DELETE FROM character_flags WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete character_flag data from MySQL Error: %d', [GID]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ��������Ƿ����
//------------------------------------------------------------------------------
function  CheckUserExist(userid: String) : Boolean;
begin
  Result := False;

  if not ExecuteSqlCmd(format('SELECT count(GID) as count FROM characters WHERE Name=''%s'' LIMIT 1', [addslashes(userid)])) then begin
    DebugOut.Lines.Add(format('Get character data from MySQL Error: %s', [userid]));
		Result := True;
		Exit;
	end;
	if SQLDataSet.FieldValues['count'] = 0 then
	  Exit;

	Result := True;
end;

//------------------------------------------------------------------------------
// ȡ���ʺŵĳ�������
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
          Name        := unaddslashes(SQLDataSet.FieldValues['Name']);
          Renamed     := StrToInt( SQLDataSet.FieldValues['Renamed'] );
          LV          := StrToInt( SQLDataSet.FieldValues['LV'] );
					Relation    := StrToInt( SQLDataSet.FieldValues['Relation'] );
          Fullness    := StrToInt( SQLDataSet.FieldValues['Fullness'] );
          Accessory   := StrToInt( SQLDataSet.FieldValues['Accessory'] );

          Data        := PetDB.Objects[i] as TPetDB;
        end;
        PetList.AddObject( tpe.PetID, tpe );

        {�ѳ������϶�Ӧ������ʺ���}
			  if tpe.PlayerID <> 0 then begin
				  if tpe.CharaID = 0 then begin  // �ڲֿ���
					  try
              tp := Player.IndexofObject( tpe.PlayerID ) as TPlayer;
						  with tp.Kafra.Item[ tpe.Index ] do begin
						  	Attr    := 0;
						  	Card[0] := $FF00;
						  	Card[2] := tpe.PetID mod $10000;
						  	Card[3] := tpe.PetID div $10000;
						  end;
						except
						end;
					end else begin
						tc := Chara.IndexOfObject( tpe.CharaID ) as TChara;
						if tpe.Cart = 0 then begin  // ������
						  try
							  with tc.Item[ tpe.Index ] do begin
							  	Attr    := tpe.Incubated;
							  	Card[0] := $FF00;
							  	Card[2] := tpe.PetID mod $10000;
							  	Card[3] := tpe.PetID div $10000;
							  end;
							except
							end;
						end else begin  // �����Ƴ���
						  try
							  with tc.Cart.Item[ tpe.Index ] do begin
						  		Attr    := 0;
						  		Card[0] := $FF00;
						  		Card[2] := tpe.PetID mod $10000;
					  			Card[3] := tpe.PetID div $10000;
								end;
							except
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
// ȡ�õ�ǰ���ʺ�ID���
//------------------------------------------------------------------------------
function  GetNowLoginID() : cardinal;
begin
  Result := 100101;
	if not ExecuteSqlCmd('SELECT AID FROM accounts ORDER BY AID DESC LIMIT 1') then begin
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then exit;

	Result := StrToInt( SQLDataSet.FieldValues['AID'] ) + 1;
end;
//------------------------------------------------------------------------------
// ȡ�õ�ǰ������ID���
//------------------------------------------------------------------------------
function  GetNowCharaID() : cardinal;
begin
  Result := 100001;
	if not ExecuteSqlCmd('SELECT GID FROM characters ORDER BY GID DESC LIMIT 1') then begin
		Exit;
	end;
  SQLDataSet.First;

  if SQLDataSet.Eof then exit;

	Result := StrToInt( SQLDataSet.FieldValues['GID'] ) + 1;
end;
//------------------------------------------------------------------------------
// ȡ�õ�ǰ�ĳ���ID���
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
// �����������(place��ָ�����ŵĵص㣬1�����ϣ�2�ǲֿ⣬3�����Ƴ�)
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

  if not ExecuteSqlCmd(Format('REPLACE INTO pet (PID,PlayerID,CharaID,Cart,PIndex,Incubated,JID,Name,Renamed,LV,Relation,Fullness,Accessory) VALUES (''%d'',''%d'',''%d'',''%d'',''%d'',''%d'',''%d'',''%s'',''%d'',''%d'',''%d'',''%d'',''%d'')', [tpe.PetID, tpe.PlayerID, CharaID, Cart, PIndex, Incubated, tpe.JID, addslashes(tpe.Name), tpe.Renamed, tpe.LV, tpe.Relation, tpe.Fullness, tpe.Accessory])) then
  begin
    DebugOut.Lines.Add('*** Save Pet data error.');
		Exit;
  end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ���湤��ͷ������
//------------------------------------------------------------------------------
function  SaveGuildMPosition(GDID: cardinal; PosName: string; PosInvite: boolean; PosPunish: boolean; PosEXP: byte; Grade: Integer) : Boolean;
begin
  Result := False;

  {ɾ��������}
	ExecuteSqlCmd(Format('DELETE FROM guild_positions WHERE GDID=''%d'' AND Grade=''%d'' LIMIT 1', [GDID, Grade]));
  if not ExecuteSqlCmd(Format('INSERT INTO guild_positions (GDID,Grade,PosName,PosInvite,PosPunish,PosEXP) VALUES (''%d'',''%d'',''%s'',''%s'',''%s'',''%d'')', [GDID, Grade, addslashes(PosName), BoolToStr(PosInvite), BoolToStr(PosPunish), PosEXP])) then
	begin
	  DebugOut.Lines.Add('*** Save Guild Position data error.');
	  Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ȡ������Ĺ�������
//------------------------------------------------------------------------------
function  GetCharaGuildData(GID: cardinal) : Boolean;
var
  j  : Integer;
  tc : TChara;
	tg : TGuild;
begin
  Result := False;
	
	if not ExecuteSqlCmd(Format('SELECT GDID FROM guild_members WHERE GID=''%d'' LIMIT 1', [GID])) then begin
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

  tg := GuildList.Objects[GuildList.IndexOf(StrToInt(SQLDataSet.FieldValues['GDID']))] as TGuild;
	with tg do begin
		for j := 0 to 35 do begin
			if MemberID[j] = tc.CID then begin
				tc.GuildName := Name;
				tc.GuildID := StrToInt(SQLDataSet.FieldValues['GDID']);
				tc.ClassName := PosName[MemberPos[j]];
				tc.GuildPos := j;
				Member[j] := tc;
				if (j = 0) then MasterName := tc.Name;
				SLV := SLV + tc.BaseLV;
				break;
			end;
		end;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// �����ݿ�ɾ�������Ա(mtype=1Ϊ�˻ᣬmtype=2Ϊ����)
//------------------------------------------------------------------------------
function  DeleteGuildMember(GID: cardinal; mtype: Integer; tgb: TGBan; GDID: cardinal) : Boolean;
begin
  Result := False;
	
	if mtype = 2 then begin
	  if not ExecuteSqlCmd(format('INSERT INTO guild_banish (GDID,MemberName,MemberAccount,Reason) VALUES (''%d'',''%s'',''%s'',''%s'')', [GDID, addslashes(tgb.Name), addslashes(tgb.AccName), addslashes(tgb.Reason)])) then begin
      DebugOut.Lines.Add(format('INSERT guild_banish data to MySQL Error: %d', [GID]));
//		  Exit;
	  end;
	end;

	if not ExecuteSqlCmd(format('DELETE FROM guild_members WHERE GID=''%d'' LIMIT 1', [GID])) then begin
    DebugOut.Lines.Add(format('Delete guild_members data from MySQL Error: %d', [GID]));
		Exit;
	end;

  Result := True;;
end;

//------------------------------------------------------------------------------
// �����ݿ�ɾ�����
//------------------------------------------------------------------------------
function  DeleteParty(Name: string) : Boolean;
begin
  Result := False;
	
	if not ExecuteSqlCmd(format('DELETE FROM party WHERE Name=''%s'' LIMIT 1', [addslashes(Name)])) then begin
    DebugOut.Lines.Add(format('Delete party data from MySQL Error: %s', [Name]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ����ͬ�ˡ��жԹ�������(mtype=1ͬ�ˣ�mtype=2�ж�)
//------------------------------------------------------------------------------
function  SaveGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean;
begin
  Result := False;

  if not ExecuteSqlCmd(Format('INSERT INTO guild_allies (GDID,GuildName,Relation) VALUES (''%d'',''%s'',''%d'')', [GDID, addslashes(GuildName), mtype])) then
	begin
	  DebugOut.Lines.Add('*** Save Guild AllyInfo data error.');
		exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ɾ��ͬ�ˡ��жԹ�������(mtype=1ͬ�ˣ�mtype=2�ж�)
//------------------------------------------------------------------------------
function  DeleteGuildAllyInfo(GDID: cardinal; GuildName: String; mtype: Integer) : Boolean;
begin
  Result := False;
	
	if not ExecuteSqlCmd(format('DELETE FROM guild_allies WHERE GDID=''%d'' AND Name=''%s'' AND Relation=''%d'' LIMIT 1', [GDID, addslashes(GuildName), mtype])) then begin
    DebugOut.Lines.Add(format('Delete guild_allies data from MySQL Error: %s', [GuildName]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ɾ����������
//------------------------------------------------------------------------------
function  DeleteGuildInfo(GDID: cardinal) : Boolean;
begin
  Result := False;

	DebugOut.Lines.Add(format('Delete Guild data from MySQL: %d', [GDID]));

  {ɾ����������}
	if not ExecuteSqlCmd(format('DELETE FROM guild_info WHERE GDID=''%d'' LIMIT 1', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {ɾ�������Ա����}
	if not ExecuteSqlCmd(format('DELETE FROM guild_members WHERE GDID=''%d'' LIMIT 36', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild Member data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {ɾ������ͷ������}
	if not ExecuteSqlCmd(format('DELETE FROM guild_positions WHERE GDID=''%d'' LIMIT 20', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild Position data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {ɾ�����Ὺ����Ա��¼����}
	if not ExecuteSqlCmd(format('DELETE FROM guild_banish WHERE GDID=''%d''', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild BanishInfo data from MySQL Error: %d', [GDID]));
		Exit;
	end;
  {ɾ������ͬ�ˡ��ж�����}
	if not ExecuteSqlCmd(format('DELETE FROM guild_allies WHERE GDID=''%d''', [GDID])) then begin
    DebugOut.Lines.Add(format('Delete Guild AllyInfo data from MySQL Error: %d', [GDID]));
		Exit;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ȡ���ʺŵ���������
//------------------------------------------------------------------------------
function  GetAccCharaData(AID: cardinal) : Boolean;
var
  i  : Integer;
	tp : TPlayer;
begin
  Result := False;

  tp := Player.Objects[Player.IndexOf(AID)] as TPlayer;
	if ExecuteSqlCmd(Format('SELECT GID, Name, CharaNumber FROM characters WHERE AID=''%d'' LIMIT 9', [AID])) then
	begin
	  while not SQLDataSet.Eof do
    begin
      tp.CID[StrToInt(SQLDataSet.FieldValues['CharaNumber'])] := StrToInt(SQLDataSet.FieldValues['GID']);
      SQLDataSet.Next;
		end;
	end else begin
	  Exit;
	end;

  for i:= 0 to 8 do begin
	  if tp.CID[i] <> 0 then begin
	    GetCharaData(tp.CID[i]);
		end;
	end;
	Result := True;
end;

//------------------------------------------------------------------------------
// ȡ������Ĺ��ᡢ��ӣ��Լ����г�Ա����
//------------------------------------------------------------------------------
function  GetCharaPartyGuild(GID: cardinal) : Boolean;
var
  i,k : Integer;
	tpa   : TParty;
	tc    : TChara;
	tg    : TGuild;
begin
  Result := False;

  k := Chara.IndexOf(GID);
	if k = -1 then exit;

	tc := Chara.Objects[k] as TChara;
	if tc.PartyName <> '' then begin
  	// ��ȡ�����������Ա������
		k := PartyNameList.IndexOf(tc.PartyName);
		if k <> -1 then begin
			tpa := PartyNameList.Objects[k] as TParty;
			for i := 0 to 11 do begin
				if (tpa.MemberID[i] <> 0) AND (tpa.MemberID[i] <> tc.CID) then begin
					if Chara.IndexOf(tpa.MemberID[i]) <> -1 then begin
						GetCharaData(tpa.MemberID[i]);
					end;
				end;
			end;
	  end;
	end;
	// ��ȡ���﹤������
	if tc.GuildID <> 0 then begin
	  // ��ȡ������������Ա������
		k := GuildList.IndexOf(tc.GuildID);
		if k <> -1 then begin
	    tg := GuildList.Objects[k] as TGuild;
  	  for i := 0 to 35 do begin
		    if (tg.MemberID[i] <> 0) AND (tg.MemberID[i] <> tc.CID) then begin
				  if (Chara.IndexOf(tg.MemberID[i]) = -1) and (tg.MemberID[i] <> 0) then begin
			      GetCharaData(tg.MemberID[i]);
					end;
        end;
			end;
		end;
	end;

	Result := True;
end;

//------------------------------------------------------------------------------
// ������������
//------------------------------------------------------------------------------
function  SaveCharaData(tc : TChara) : Boolean;
var
  bindata : String;
	j :integer;
    sl :TStringList;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';
  Result := False;
	with tc do begin
		bindata := '(GID,Name,JID,BaseLV,BaseEXP,StatusPoint,JobLV,JobEXP,SkillPoint,Zeny,Stat1,Stat2,Options,Karma,Manner,HP,SP,DefaultSpeed,Hair,_2,_3,Weapon,Shield,Head1,Head2,Head3,HairColor,';
		bindata := bindata + 'ClothesColor,STR,AGI,VIT,INTS,DEX,LUK,CharaNumber,Map,X,Y,SaveMap,SX,SY,Plag,PLv,AID) VALUES (';
    bindata := bindata + IntToStr(CID);
    bindata := bindata + ' ,''' + addslashes(Name) + '''';
    bindata := bindata + ' ,' + IntToStr(JID);
    bindata := bindata + ' ,' + IntToStr(BaseLV);
    bindata := bindata + ' ,' + IntToStr(BaseEXP);
    bindata := bindata + ' ,' + IntToStr(StatusPoint);
    bindata := bindata + ' ,' + IntToStr(JobLV);
    bindata := bindata + ' ,' + IntToStr(JobEXP);
    bindata := bindata + ' ,' + IntToStr(SkillPoint);
    bindata := bindata + ' ,' + IntToStr(Zeny);
    bindata := bindata + ' ,' + IntToStr(Stat1);
    bindata := bindata + ' ,' + IntToStr(Stat2);
    if Option = 4 then begin
      bindata := bindata + ' ,0';
    end else begin
      bindata := bindata + ' ,' + IntToStr(Option);
    end;
    bindata := bindata + ' ,' + IntToStr(Karma);
    bindata := bindata + ' ,' + IntToStr(Manner);
    if (HP < 0) then begin
      HP := 0;
    end;
    bindata := bindata + ' ,' + IntToStr(HP);
    bindata := bindata + ' ,' + IntToStr(SP);
    bindata := bindata + ' ,' + IntToStr(DefaultSpeed);
    bindata := bindata + ' ,' + IntToStr(Hair);
    bindata := bindata + ' ,' + IntToStr(_2);
    bindata := bindata + ' ,' + IntToStr(_3);
    bindata := bindata + ' ,' + IntToStr(Weapon);
    bindata := bindata + ' ,' + IntToStr(Shield);
    bindata := bindata + ' ,' + IntToStr(Head1);
    bindata := bindata + ' ,' + IntToStr(Head2);
    bindata := bindata + ' ,' + IntToStr(Head3);
    bindata := bindata + ' ,' + IntToStr(HairColor);
    bindata := bindata + ' ,' + IntToStr(ClothesColor);
		for j := 0 to 5 do
      bindata := bindata + ' ,' + IntToStr(ParamBase[j]);
    bindata := bindata + ' ,' + IntToStr(CharaNumber);
    bindata := bindata + ' ,''' + addslashes(Map) + '''';
    bindata := bindata + ' ,' + IntToStr(Point.X);
    bindata := bindata + ' ,' + IntToStr(Point.Y);
    bindata := bindata + ' ,''' + addslashes(SaveMap) + '''';
    bindata := bindata + ' ,' + IntToStr(SavePoint.X);
    bindata := bindata + ' ,' + IntToStr(SavePoint.Y);
    bindata := bindata + ' ,' + IntToStr(Plag);
    bindata := bindata + ' ,' + IntToStr(PLv);
    bindata := bindata + ' ,' + IntToStr(ID);
    bindata := bindata + ')';
	  if not ExecuteSqlCmd(Format('REPLACE INTO characters %s', [bindata])) then begin
		  DebugOut.Lines.Add('*** Save Character data error.');
			Exit;
		end;

		{���漼������}
		bindata := '';
		for j := 1 to 336 do begin
		  if Skill[j].Lv <> 0 then begin
			  bindata := bindata + IntToHex(j, 4);
			  bindata := bindata + IntToHex(Skill[j].Lv, 4);
		  end;
	  end;
	  if not ExecuteSqlCmd(Format('REPLACE INTO skills (GID,skillInfo) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
		  DebugOut.Lines.Add('*** Save Character Skill data error.');
			Exit;
		end;

		{��������������Ʒ����}
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
	  if not ExecuteSqlCmd(Format('REPLACE INTO inventory (GID,equipItem) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
		  DebugOut.Lines.Add('*** Save Character Item data error.');
			Exit;
		end;

		{�����������Ƴ�����Ʒ������}
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
	  if not ExecuteSqlCmd(Format('REPLACE INTO cart (GID,cartitem) VALUES (''%d'',''%s'')', [CID, bindata])) then begin
		  DebugOut.Lines.Add('*** Save Character CartItem data error.');
			Exit;
		end;

		{��������MEMO��¼������}
		if not ExecuteSqlCmd(Format('REPLACE INTO warpmemo (GID,mapName0,xPos0,yPos0,mapName1,xPos1,yPos1,mapName2,xPos2,yPos2) VALUES (''%d'',''%s'',''%d'',''%d'',''%s'',''%d'',''%d'',''%s'',''%d'',''%d'')', [CID, addslashes(MemoMap[0]), MemoPoint[0].X, MemoPoint[0].Y, addslashes(MemoMap[1]), MemoPoint[1].X, MemoPoint[1].Y, addslashes(MemoMap[2]), MemoPoint[2].X, MemoPoint[2].Y])) then begin
		  DebugOut.Lines.Add('*** Save Character CartItem data error.');
			Exit;
		end;

        sl.Clear;
        for j := 0 to tc.Flag.Count - 1 do begin
            if ((Copy(tc.Flag.Names[j], 1, 1) <> '@') and (Copy(tc.Flag.Names[j], 1, 2) <> '$@')) and ((tc.Flag.Values[tc.Flag.Names[j]] <> '0') and (tc.Flag.Values[tc.Flag.Names[j]] <> '')) then begin
                sl.Add(tc.Flag.Strings[j]);
            end;
        end;

		if not ExecuteSqlCmd(Format('REPLACE INTO character_flags (GID,flagdata) VALUES (''%d'',''%s'')', [CID, sl.DelimitedText])) then begin
		  DebugOut.Lines.Add('*** Save Character Flags data error.');
			Exit;
		end;
	end;
end;

//------------------------------------------------------------------------------
// ���ݿ��ַ�������
//------------------------------------------------------------------------------
function  addslashes(Strings: String) : String;
begin
  Result := Strings;
	Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
	Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
end;

//------------------------------------------------------------------------------
// ���ݿ��ַ�������
//------------------------------------------------------------------------------
function  unaddslashes(Strings: String) : String;
begin
  Result := Strings;
	Result := StringReplace(Result, '\''', '''', [rfReplaceAll]);
	Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
end;


end.
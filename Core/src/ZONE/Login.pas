unit Login;



interface

uses
//Windows, Forms, Classes, SysUtils, Math, ScktComp, Common;
	Windows,Classes, SysUtils, ScktComp, Common, Database, SQLData, FusionSQL;

//==============================================================================
// �֐���`
		procedure sv1PacketProcess(Socket: TCustomWinSocket);
//==============================================================================


//==============================================================================
// �ǉ��֐�
//==============================================================================
// procedure sv1PacketProcessSub(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string);
// �p�X���[�h�m�F�����O�C������ ����
//             
//==============================================================================
// function sv1PacketProcessTo(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string):Boolean;
// ���O�C������Toplayer.txt��ǂݍ��݁A�f�[�^�������player.txt�ɒǉ�����A
// �ċN���͕K�v�Ȃ�
// (GM�A�J�E���g�쐬�p����)
//
//==============================================================================
// function sv1PacketProcessAdd(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string):Boolean;
// ���O�C������addplayer.txt��ǂݍ��݁A�f�[�^�������player.txt�ɒǉ�����A
// �g�����U�N�V����ID�͎����ł�����
// �ċN���͕K�v�Ȃ� 
// (���ʂ̃A�J�E���g�͂������Œǉ�)
//





implementation
//==============================================================================

procedure sv1PacketProcessSub(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string);
var{ChrstphrR - 2004/04/25 - removed unused variables}
	APlayer   : TPlayer;    //reference
	PlayerIdx : Integer;
begin
	if PlayerName.IndexOf(userid) > - 1 then begin
		APlayer := PlayerName.Objects[PlayerName.IndexOf(userid)] as TPlayer;

		PlayerIdx := IDTableDB.IndexOf(APlayer.ID);

		if (PlayerIdx = -1) AND (NowUsers >= Option_MaxUsers) then begin
			ZeroMemory(@buf[0],23);
			WFIFOW( 0, $006a);
			WFIFOB( 2, 7);//Server is full.
			Socket.SendBuf(buf, 23);
		end;

		if (APlayer.Banned = 1) then begin
			ZeroMemory(@buf[0],23);
			WFIFOW( 0, $006a);
			WFIFOB( 2, 4); //Blocked ID, or an ID of a locked account
			Socket.SendBuf(buf, 23);
		end
		else if APlayer.Pass = userpass then begin

			APlayer.IP := Socket.RemoteAddress;
			APlayer.Login := 1;
			APlayer.LoginID1 := Random($7FFFFFFF) + 1;
			if UseSQL then APlayer.LoginID2 := Assign_AccountID()
			else begin
				APlayer.LoginID2 := NowLoginID;
				Inc(NowLoginID);
			end;
			if NowLoginID >= 2000000000 then NowLoginID := 0;

			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'tp.ver2 = '+inttostr(w));
			//tp.ver2 := w;
			APlayer.ver2 := 9;

			WFIFOW( 0, $0069);
			WFIFOW( 2, 79);
			WFIFOL( 4, APlayer.LoginID1);
			WFIFOL( 8, APlayer.ID);
			WFIFOL(12, APlayer.LoginID2);
			WFIFOL(16, 0);
			WFIFOS(20, PChar(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now)), 24);
			WFIFOW(44, 0);
			WFIFOB(46, APlayer.Gender); //sex 0=F 1=M
			WFIFOL(47, ServerIP);
			WFIFOW(51, sv2port);
			WFIFOS(53, ServerName, 20);
			WFIFOW(73, NowUsers);
			WFIFOW(75, 0);
			WFIFOW(77, 0);
			Socket.SendBuf(buf, 79);
		end else begin
			ZeroMemory(@buf[0],23);
			WFIFOW( 0, $006a);
			WFIFOB( 2, 1);//Password Incorrect
			Socket.SendBuf(buf, 23);
		end;
	end else begin
		ZeroMemory(@buf[0],23);
		WFIFOW( 0, $006a);
		WFIFOB( 2, 0);//Unregistered ID
		Socket.SendBuf(buf, 23);
	end;
end;//proc sv1PacketProcessSub()


//�A�J�E���g�ǉ�
// Toplayer.txt�ɏ������񂾃A�J�E���g�f�[�^�����̂܂܎�荞��
//
function sv1PacketProcessTo(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string):Boolean;
var{ChrstphrR - 2004/04/25 - removed unused variables}
	tempList  : TStringList;
	tempList2 : TStringList;
begin
  Result := False;
    //DataSave();
    tempList := TStringList.Create;  
    tempList2 := TStringList.Create;
    if FileExists(AppPath + 'Toplayer.txt') then begin
           tempList.LoadFromFile(AppPath + 'Toplayer.txt');

          if FileExists(AppPath + 'player.txt') then begin
           tempList2.LoadFromFile(AppPath + 'player.txt');

           tempList2.AddStrings(tempList);
           tempList2.SaveToFile(AppPath + 'player.txt');
            tempList.Clear;
            tempList.SaveToFile(AppPath + 'Toplayer.txt');
            Result := True;
          end;
     end;
	{ChrstphrR 2004/04/25 - these TSL's weren't freed up}
	tempList.Free;
	tempList2.Free;
end;//sv1PacketProcessTo()

//�A�J�E���g�ǉ�
// addplayer.txt�ɏ������񂾃A�J�E���g�f�[�^��
// �g�����U�N�V����ID��t�������Ď�荞��
//
// To the account data written in addplayer.txt, Transaction ID is reattached and is taken in.
function sv1PacketProcessAdd(Socket: TCustomWinSocket;w :word;userid:string;userpass  :string):Boolean;
var
	userdata  : string;
	count     : Integer;
	addtxt    : TextFile;
	txt       : TextFile;
	option_mf : string;
	Idx       : Integer;
    tp        : TPlayer;
	//index used for freeing player/playername lists
begin
	Result := False;




		if (Option_Username_MF = True) then begin
			option_mf := copy(userid, length(userid) - 1, 2);
			userid := copy(userid, 0, length(userid) - 2);

            if (option_mf = '_M') then begin
            	tp := TPlayer.Create;
        	    tp.ID := PlayerName.Count + 100101;
    	        tp.Name := userid;
	            tp.Pass := userpass;
            	tp.Gender := 1;
        	    tp.Mail := '-@-';
    	        PlayerName.AddObject(tp.Name, tp);
	            Player.AddObject(tp.ID, tp);
            end else if (option_mf = '_F') then begin
            	tp := TPlayer.Create;
        	    tp.ID := PlayerName.Count + 100101;
    	        tp.Name := userid;
	            tp.Pass := userpass;
            	tp.Gender := 0;
        	    tp.Mail := '-@-';
    	        PlayerName.AddObject(tp.Name, tp);
	            Player.AddObject(tp.ID, tp);
            end;

            if UseSQL then
            	SQLDataSave
            else
	            DataSave;


        end;


	//DataSave;

	sv1PacketProcessTo(Socket,w,userid,userpass);
	AssignFile(addtxt, AppPath + 'addplayer.txt');
	AssignFile(txt, AppPath + 'player.txt');
	if not FileExists(AppPath + 'player.txt') then begin
		Rewrite(txt);
		Writeln(txt, '##Weiss.PlayerData.0x0002');
	end else begin
		Append(txt);
	end;


	if FileExists(AppPath + 'addplayer.txt') then begin
		Reset(addtxt);
		count := 1;

			while not SeekEof(addtxt) do begin
				Readln(addtxt,userdata);
				Writeln(txt, inttostr(100100+PlayerName.Count+count)+','+userdata);
				Writeln(txt, '0');
				inc(count);
			end;

		Flush(txt);  { Verifies that text REALLY was written to the file }
		CloseFile(txt);

		Rewrite(addtxt);
		Flush(addtxt);  { Verifies that text REALLY was written to the file }
		CloseFile(addtxt);


		{ChrstphrR 2004/04/25 - Clear's are unsafe
		for the TPlayer objects, unless you pre-free the Objects[]
		... and even so, I'm worried about the safety of rebuilding this
		list on the fly. -- A safer solution would be to...
		- Add the player's account into the runtime Lists,
		Player, PlayerName
		- Make a safe routine to write the new accounts, or, if not,
		the whole list to txtfile or SQL, as the case may be.}

		for Idx := Player.Count-1 downto 0 do
			if Assigned(Player.Objects[Idx]) then
				(Player.Objects[Idx] AS TPlayer).Free;
		Player.Clear;
		PlayerName.Clear;

		//CharaName.Clear;
		//Chara.Clear;
		//PartyNameList.Clear;
{��{���ǉ�}
		//SummonMobList.Clear;//ChrstphrR - safe 2004/04/26
		//SummonIOBList.Clear;//Safe 2004/04/26
		//SummonIOVList.Clear;//Safe 2004/04/26
		//SummonICAList.Clear;//Safe 2004/04/26
		//SummonIGBList.Clear;//Safe 2004/04/26
{��{���ǉ��R�R�܂�}
{NPC�C�x���g�ǉ�}
		//ServerFlag.Clear;
		//MapInfo.Clear;
{NPC�C�x���g�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
		//GuildList.Clear;
{�M���h�@�\�ǉ��R�R�܂�}
		//PetList.Clear;
		//DataLoad();


		if (option_mf = 'S') then begin
            Load_Accounts(userid);
            sv1PacketProcessSub(Socket,w,userid,userpass);
        end else begin
            PlayerDataLoad;
		if PlayerName.IndexOf(userid) = -1 then Exit;
		sv1PacketProcessSub(Socket,w,userid,userpass);
        end;
			Result := True;
	end;
end;
//==============================================================================
// ���O�C���T�[�o�[�p�P�b�g����
procedure sv1PacketProcess(Socket: TCustomWinSocket);
var{ChrstphrR - 2004/04/25 - removed unused variables}
	w         :word;
	l         :longword;
	len       :integer;
	userid    :string;
    userid2   :string;
    option_mf :string;
	userpass  :string;
begin
	{ChrstphrR - 2004/04/28 - brought back the Len variable, out of concern
	it may be causing the Unable-to-connect to the Login Server Eliotsan's users
	had observed -- notes from the helpfile seem to back this :P

	Call ReceiveLength to determine the amount of information to read over
	the socket connection in response to an asynchronous read notification.

	Note: ReceiveLength is not guaranteed to be accurate
	for streaming socket connections.

	From ReceiveBuf notes...
	Note:	While the ReceiveLength method can return an estimate of the size of
	buffer required to retrieve information from the socket, the number of bytes
	it returns is not necessarily accurate.
	}
	len := Socket.ReceiveLength;
	if len >= 55 then begin
		Socket.ReceiveBuf(buf, len);
		if (buf[0] = $64) and (buf[1] = $0) then begin
			RFIFOL(2, l);
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'ver1 ' + IntToStr(l));
			RFIFOW(54, w);
			userid := RFIFOS(6, 24);
			userpass := RFIFOS(30, 24);

			debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'User: ' + userid + ' - Pass: ' + userpass);
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'ver1 = ' + IntToStr(l) + ':ver2 = ' + IntToStr(w));
			if UseSQL then Load_Accounts(userid);

		userid2 := userid;
		if (Option_Username_MF = True) then begin
			option_mf := copy(userid, length(userid) - 1, 2);
            if (option_mf = '_M') or (option_mf = '_F') then
				userid := copy(userid, 0, length(userid) - 2);
        end;


				if PlayerName.IndexOf(userid) > -1 then begin
					//DebugOut.Lines.Add ('User Exists');
					//DebugOut.Lines.Add ('ID: '+inttostr(id));
					sv1PacketProcessSub(Socket,w,userid,userpass);
				end else begin
					//DebugOut.Lines.Add ('New User');
					if not sv1PacketProcessAdd(Socket,w,userid2,userpass) then begin
						ZeroMemory(@buf[0],23);
						WFIFOW( 0, $006a);
						WFIFOB( 2, 0);//Unregistered ID
						Socket.SendBuf(buf, 23);
					end;
				end;
		end;//if buf[0]&buf[1]
	end;//if SRL>=55...
end;//sv1PacketProcess()
//==============================================================================


end.

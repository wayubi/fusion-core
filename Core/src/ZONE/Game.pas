unit Game;



interface

uses
    {Windows VCL}
    {$IFDEF MSWINDOWS}
	Windows, MMSystem, ScktComp, Forms,
    {$ENDIF}
    {Kylix/Delphi CLX}
    {$IFDEF LINUX}
    Qt, Types, QForms,
    {$ENDIF}
    {Shared}
    Classes, Math, SysUtils, StrUtils,
    {Fusion}
    Path, Script, Common, Zip, SQLData, FusionSQL, Game_Master, Globals, Database, PlayerData, ISCS,
    REED_SAVE_PARTIES;

//==============================================================================
// �֐���`
		procedure sv3PacketProcess(Socket: TCustomWinSocket);
//==============================================================================


implementation

//==============================================================================


(*-----------------------------------------------------------------------------*
// �Q�[���T�[�o�[�p�P�b�g����

???
Appears to have a large portion of the game logic intermixed with a
case statement that processes incoming messages from the server.

CRW - 2004/04/07
- Applied consistant formatting to PART of this 7300 line long routine so it's
  now sane to look at.
- Separated variables, one per line, no exceptions.
- Started Translation of the SJIS code from the original coder(s) in the form:
  <original> ' Lit. "'<Edited_Babelfish_Translation_Here>'"'

  I hope this helps a wee bit. :P

*-----------------------------------------------------------------------------*)
Procedure sv3PacketProcess(Socket: TCustomWinSocket);
Var
	i     : Integer;
  h     : Integer;
	j     : Integer;
	k     : Integer;
	ii    : Integer;
	cmd   : Word;
	w     : Word;
	w1    : Word;
	w2    : Word;
  w3    : Word;
{�ǉ�}
	wjob  : Int64;
{�ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
	m1      : Word;//��ɐ��������A�C�e����ID�Ƃ��ė��p
	m       : Array[0..2] of Word;//��ɐ����A�C�e���ɕs����鑮���΁A���̂������ID�Ƃ��ė��p
	e,e2    : Word;//��ɐ���������A�C�e����Inventory���������ɗ��p
	anvil   : Word;//���~�ɂ���ďオ�鐬����
{�A�C�e�������ǉ��R�R�܂�}
	id1       : Cardinal;
  id2       : Cardinal;

	L         : Cardinal; //was lowercase "l"
	L2        : Cardinal; //was lowercase "l2" (close to 1 or I in the wrong font)
	weight    : Cardinal;
  c         : Cardinal;
	b         : Byte;
  b1        : Byte;
	Len       : Integer;

	Str       : String;
  Str2      : String;
	AccountID : String;
	CharaID   : String;
	NpcID     : String;

	tp  : TPlayer;
	tc  : TChara;
	tc1 : TChara;
	tm  : TMap;
	tn  : TNPC;
	ts  : TMob;
  ts1 : TMob;
  tss : TSlaveDB;
  ma  : TMArrowDB;
	ti  : TItem;
	tk  : TSkill;
	tl  : TSkillDB;
	td  : TItemDB;

{�A�C�e�������ǉ�}
	tma : TMaterialDB;
{�A�C�e�������ǉ��R�R�܂�}
{�p�[�e�B�[�@�\�ǉ�}
	tpa : TParty;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�`���b�g���[���@�\�ǉ�}
	tcr : TChatRoom;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
	tv  : TVender;
{�I�X�X�L���ǉ��R�R�܂�}
{����@�\�ǉ�}
	tdl : TDealings;
  twp : TWarpDatabase;
{����@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
  tpd : TPetDB;
  tmd : TMobDB;
  tpe :TPet;

  i1  : Integer;
  j1  : Integer;
  k1  : Integer;
{�L���[�y�b�g�����܂�}
{NPC�C�x���g�ǉ�}
	mi  : MapTbl;
{NPC�C�x���g�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
	tg    : TGuild;
	tg1   : TGuild;
	tgb   : TGBan;
	tgl   : TGRel;
	tp1   : TPlayer;
{�M���h�@�\�ǉ��R�R�܂�}
	ta  : TMapList;
	xy  : TPoint;
  s   : String;
	SL  : TStringList;
	ww      : array of array of Word; //CRW This is dynamic 2-dim array??
	tmpbuf  : array of Byte;

  afm_compressed  : TZip;
  afm             : Textfile;
  letter          : Char;
  MapName         : String;
  dat             : TMemoryStream;
  h2              :array[0..3] of Single; //CRW What is this for??
  maptype         : Integer;

Begin(* Proc sv3PacketProcess() *)

  j := 0;
  tcr := nil;
	while Socket.ReceiveLength >= 2 do
  begin
		//len := Socket.ReceiveLength;
		Socket.ReceiveBuf(buf[0], 2);
		RFIFOW(0, cmd);
		//if cmd = $00c8 then
		//	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '!');
		tc := Socket.Data;
		if (cmd > MAX_PACKET_NUMBER) then begin
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '�s���ȃp�P�b�g' + IntToStr(Socket.ReceiveLength) + '�o�C�g��j�����܂���');
			SetLength(tmpbuf, Socket.ReceiveLength);
			Socket.ReceiveBuf(tmpbuf[0], Socket.ReceiveLength);
			Continue;
		end;
		Assert((cmd > 0) AND (cmd <= MAX_PACKET_NUMBER), 'Packet Type: index error ' + IntToStr(cmd));
		if PacketLength[cmd] = -1 then begin
			Socket.ReceiveBuf(buf[2], 2);
			RFIFOW(2, w);
			Socket.ReceiveBuf(buf[4], w - 4);
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d CMD %.4x len:%d plen:%d', [tc.ID, cmd, w, len]));
		end else begin
			Socket.ReceiveBuf(buf[2], PacketLength[cmd] - 2);
			//if cmd <> $0072 then begin
			//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d CMD %.4x', [tc.ID, cmd]));
			//end;
		end;
    //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Command:' + IntToStr(cmd));

		case cmd of
		//--------------------------------------------------------------------------
		$0072: //�Q�[���I�ڑ��v��    Lit. "Game socket connection requested"
			begin
				RFIFOL( 2, L);
				accountid := IntToStr(L);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d CMD %.4x', [l, cmd]));
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '		AccountID = ' + IntToHex(l, 4));
				RFIFOL( 6, l2);
				charaid := IntToStr(l2);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '		CharaID = ' + IntToHex(l, 4));
				RFIFOL(10, id1);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '		LoginID1 = ' + IntToHex(id1, 4));
				//RFIFOL(14, id2);
				if (Player.IndexOf(L) <> -1) and (Chara.IndexOf(L2) <> -1) then begin
					tp := Player.IndexOfObject(L) as TPlayer;
					tc := Chara.IndexOfObject(L2) as TChara;

					//if tc.IP = Socket.RemoteAddress then begin
					if (tp.LoginID1 = id1) and (tp.LoginID1 <> 0) then begin
						tc.ver2 := tp.ver2;
						//tp.LoginID1 := 0;
						tc.Login := 1;
						//tc.ID := tp.ID;
						//tc.Gender := tp.Gender;
						tc.PData := tp;
						if CharaPID.IndexOf(tc.ID) = -1 then CharaPID.AddObject(tc.ID, tc);
						tc.Socket := Socket;
						Socket.Data := tc;
						WFIFOL(0, $00000000);
						Socket.SendBuf(buf, 4);

						WFIFOW(0, $0073);
						WFIFOL(2, timeGetTime());
						WFIFOM1(6, tc.Point);
						WFIFOW(9, $0505);
						Socket.SendBuf(buf, 11);

						//�O�񃏁[�v�Ɏ��s���ė������Ƃ��̕�������
						if tc.tmpMap <> '' then begin
							tc.Map := tc.tmpMap;
							tc.tmpMap := '';
						end;

						//�}�b�v���[�h
						if Map.IndexOf(tc.Map) = -1 then begin
							MapLoad(tc.Map);
						end;
{�M���h�@�\�ǉ�}
						j := GuildList.IndexOf(tc.GuildID);
						if (j <> -1) then begin
							tg := GuildList.Objects[j] as TGuild;
							//�����o�[�ɒʒm
							WFIFOW( 0, $016d);
							WFIFOL( 2, tc.ID);
							WFIFOL( 6, tc.CID);
							WFIFOL(10, 1);
							SendGuildMCmd(tc, 14, true);
							//�M���h���
							SendGLoginInfo(tg, tc);
						end;

					//CRW -- Broadcasts Welcome Message to all Users.
					if (Option_WelcomeMsg) then begin
						str2 := 'blueWelcome, '+tc.Name+', to the '+ServerName+' Ragnarok Online Server - Powered by Fusion Server Technology';
						//CRW -- why is "w" 200 -- should it not be SizeOf(str2) ??
                        w := length(str2) + 4;
						//w := 200;
						WFIFOW(0, $009a);
						WFIFOW(2, w);
						WFIFOS(4, str2, w-4);
						for i := 0 to CharaName.Count - 1 do begin
							tc1 := CharaName.Objects[i] as TChara;
							if tc1.Login = 2 then begin
								tc1.Socket.SendBuf(buf, w);
							end;
						end;
						tc.Socket.SendBuf(buf, w);
					end;//if (Option.WelcomeMsg)

					if (Option_MOTD) then begin
						//Read each line of the MOTD, send all but blank lines.
						//Only sent to the character joining.
						SendMOTD(tc);
					end;//if (Option_MOTD)

{�M���h�@�\�ǉ��R�R�܂�}
					end else begin
						WFIFOW(0, $0074); //�����Ă邩�ȁH
						WFIFOB(2, 0);
						Socket.SendBuf(buf, 3);
					end;
				end;
			end;//$0072
		//--------------------------------------------------------------------------
		$007d: // Map loading completed (display the map to user)
			begin
				if tc.tmpMap <> '' then begin
					tc.Map := tc.tmpMap;
					tc.tmpMap := '';
				end;
        if Map.IndexOf(tc.Map) <> - 1 then begin
				tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
				while tm.Mode < 2 do
					Application.ProcessMessages;

				tc.MData := tm;
				if CharaPID.IndexOf(tc.ID) = -1 then CharaPID.AddObject(tc.ID, tc);
        if MapInfo.IndexOf(tm.Name) <> -1 then begin
        mi := MapInfo.Objects[MapInfo.IndexOf(tm.Name)] as MapTbl;

				// Add this character to the charlist for this map
				tm.CList.AddObject(tc.ID, tc);
				tm.Block[tc.Point.X div 8][tc.Point.Y div 8].CList.AddObject(tc.ID, tc);

        // Colus, 20040409: Gave the option to enable lower class dyes.
        // This should be removed when Gravity reenables them.
        { Alex: moved up here to prevent the flicker of changing colors }
        UpdateLook(tm, tc, 7, tc.ClothesColor, 0, true);

        {Tsusai: Reapply Status options like blind and silence.
        These things have to carry over upon map change.  Thanks Trihan!}
        UpdateOption(tm,tc);

        //Grace Time
        if mi.PvPG = true then begin
          tc.GraceTick := timeGetTime() + 15000;
        end else begin
          tc.GraceTick := timeGetTime() + 5000;
        end;

				// If dead, recover status/HP as necessary
				if tc.Sit = 1 then tc.Sit := 3;
				if tc.HP = 0 then begin
          if tc.JID = 0 then begin
            tc.HP := tc.MAXHP div 2;
            if tc.FullRecover then begin
              tc.HP := tc.MAXHP;
              tc.SP := tc.MAXSP;
            end;
          end else begin
            if tc.FullRecover then begin
              tc.HP := tc.MAXHP;
              tc.SP := tc.MAXSP;
            end else begin
              tc.HP := 1;
            end;
          end;
        end;

        // Reset vending/chat/trade/deal status
				tc.VenderID := 0;
				tc.ChatRoomID := 0;
				tc.DealingID := 0;
				tc.PreDealID := 0;

				//�u���b�N����
				for j := tc.Point.Y div 8 - 2 to tc.Point.Y div 8 + 2 do begin
					for i := tc.Point.X div 8 - 2 to tc.Point.X div 8 + 2 do begin
						// Notify about nearby NPCs
						for k := 0 to tm.Block[i][j].NPC.Count - 1 do begin
							tn := tm.Block[i][j].NPC.Objects[k] as TNPC;
							if (abs(tc.Point.X - tn.Point.X) < 16) and (abs(tc.Point.Y - tn.Point.Y) < 16) then begin

                //SendNData(Socket, tn, tc.ver2);
								if (tn.Enable = true) then begin
									SendNData(Socket, tn,tc.ver2, tc);
									if (tn.ScriptInitS <> -1) and (tn.ScriptInitD = false) then begin
										//OnInit processing
										//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('OnInit Event(%d)', [tn.ID]));
										tc1 := TChara.Create;
										tc1.TalkNPCID := tn.ID;
										tc1.ScriptStep := tn.ScriptInitS;
										tc1.AMode := 3;
										tc1.AData := tn;
										tc1.Login := 0;
										NPCScript(tc1,0,1);
										tn.ScriptInitD := true;
										tc1.Free;
									end;
									if (tn.ChatRoomID <> 0) then begin
										// Show NPC chatrooms
										ii := ChatRoomList.IndexOf(tn.ChatRoomID);
										if (ii <> -1) then begin
											tcr := ChatRoomList.Objects[ii] as TChatRoom;
											if (tn.ID = tcr.MemberID[0]) then begin
												w := Length(tcr.Title);
												WFIFOW(0, $00d7);
												WFIFOW(2, w + 17);
												WFIFOL(4, tcr.MemberID[0]);
												WFIFOL(8, tcr.ID);
												WFIFOW(12, tcr.Limit);
												WFIFOW(14, tcr.Users);
												WFIFOB(16, tcr.Pub);
												WFIFOS(17, tcr.Title, w);
												if tc.Socket <> nil then begin
													tc.Socket.SendBuf(buf, w + 17);
												end;
											end;
										end;
									end;
								end;
							end;
						end;
						// Notify nearby players about you (and you about them)
						for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
							tc1 := tm.Block[i][j].CList.Objects[k] as TChara;
							if (tc <> tc1) and (abs(tc.Point.X - tc1.Point.X) < 16) and (abs(tc.Point.Y - tc1.Point.Y) < 16) then begin
								SendCData(tc, tc1);
								SendCData(tc1, tc);
								// Remove any chats or vends you may have had displayed (after death, perhaps...)
								ChatRoomDisp(tc.Socket, tc1);
								VenderDisp(tc.Socket, tc1);
							end;
						end;
						// Update about mobs in your range of vision
						for k := 0 to tm.Block[i][j].Mob.Count - 1 do begin
							ts := tm.Block[i][j].Mob.Objects[k] as TMob;
							if (abs(tc.Point.X - ts.Point.X) < 16) and (abs(tc.Point.Y - ts.Point.Y) < 16) then begin
								SendMData(Socket, ts);
							end;
						end;
					end;
				end;

				// Update skill list
				SendCSkillList(tc);

				// Update character stats
				CalcStat(tc);
				SendCStat(tc, true);

				// Update inventory data
				WFIFOW(0, $00a3);
				j := 0;
				for i := 1 to 100 do begin
					if (tc.Item[i].ID <> 0) and (not tc.Item[i].Data.IEquip) then begin
						WFIFOW( 4 +j*10, i);
						WFIFOW( 6 +j*10, tc.Item[i].Data.ID);
						WFIFOB( 8 +j*10, tc.Item[i].Data.IType);
						WFIFOB( 9 +j*10, tc.Item[i].Identify);
						WFIFOW(10 +j*10, tc.Item[i].Amount);
						if tc.Item[i].Data.IType = 10 then
							WFIFOW(12 +j*10, 32768)
						else
							WFIFOW(12 +j*10, 0);
						Inc(j);
					end;
				end;
				WFIFOW(2, 4+j*10);
				Socket.SendBuf(buf, 4+j*10);
				// Update equipment data
				WFIFOW(0, $00a4);
				j := 0;
				for i := 1 to 100 do begin
					if (tc.Item[i].ID <> 0) and tc.Item[i].Data.IEquip then begin
						WFIFOW( 4 +j*20, i);
						WFIFOW( 6 +j*20, tc.Item[i].Data.ID);
						WFIFOB( 8 +j*20, tc.Item[i].Data.IType);
						WFIFOB( 9 +j*20, tc.Item[i].Identify);
						with tc.Item[i].Data do begin
							if (tc.JID = 12) and (IType = 4) and (Loc = 2) and
								 ((View = 1) or (View = 2) or (View = 6)) then
								WFIFOW(10 +j*20, 34)
							else
								WFIFOW(10 +j*20, Loc);
						end;
						WFIFOW(12 +j*20, tc.Item[i].Equip);
						WFIFOB(14 +j*20, tc.Item[i].Attr);
						WFIFOB(15 +j*20, tc.Item[i].Refine);
						WFIFOW(16 +j*20, tc.Item[i].Card[0]);
						WFIFOW(18 +j*20, tc.Item[i].Card[1]);
						WFIFOW(20 +j*20, tc.Item[i].Card[2]);
						WFIFOW(22 +j*20, tc.Item[i].Card[3]);
						Inc(j);
					end;
				end;
				WFIFOW(2, 4+j*20);
				Socket.SendBuf(buf, 4+j*20);
				// Update arrow equipment status
				j := 0;
				for i := 1 to 100 do begin
					if (tc.Item[i].ID <> 0) and (tc.Item[i].Equip = 32768) then begin
						j := i;
						break;
					end;
				end;
				WFIFOW(0, $013c);
				WFIFOW(2, j);
				Socket.SendBuf(buf, 4);

        // Transmit cart data
				// Colus, 20040123: Other carts weren't getting checked.
				w3 := tc.Option and $0788;
				if (w3 <> 0) then begin
					SendCart(tc);
				end;

        // Reset regen/recovery ticks and combat status
				tc.HPTick := timeGetTime();
				tc.SPTick := timeGetTime();
				tc.HPRTick := timeGetTime() - 500;
				tc.SPRTick := timeGetTime();
				tc.Sit := 3;
				tc.AMode := 0;
				tc.DmgTick := 0;

        // Set login data and send party info
				tc.Login := 2;
				SendPartyList(tc);

        // Find and show your active pet
        j := 0;
        for i := 1 to 100 do begin
          if ( tc.Item[i].ID <> 0 ) and ( tc.Item[i].Amount > 0 ) and
          ( tc.Item[i].Card[0] = $FF00 ) and ( tc.Item[i].Attr <> 0 ) then begin
            j := i;
            break;
          end;
        end;

        if j > 0 then begin
          i := PetList.IndexOf( tc.Item[j].Card[2] + tc.Item[j].Card[3] * $10000 );
          if i <> -1 then begin
            SendPetRelocation(tm, tc, i);
          end;
        end;


        // Get and display the guild news
				j := GuildList.IndexOf(tc.GuildID);
				if (j <> -1) then begin
					tg := GuildList.Objects[j] as TGuild;
					WFIFOW( 0, $016f);
					WFIFOS( 2, tg.Notice[0], 60);
					WFIFOS(62, tg.Notice[1], 120);
					Socket.SendBuf(buf, 182);
				end;

        // Is this map PvP?  Then set that mode and ladder status.
        if (mi.PvP = true) then begin
        if tc.CheckpointMap <> tc.Map then tc.PvPPoints := 5;
        CalcPvPRank(tm);
        end;

        // Is this map GvG?  Then set that mode.
        if (mi.PvPG = true) then begin
          for j := 0 to tm.CList.Count - 1 do begin
            tc1 := tm.CList.Objects[j] as TChara;
            WFIFOW( 0, $0199);
            WFIFOW( 2, 3);
            tc1.Socket.SendBuf(buf, 4);
          end;
        end;

        // Is this map PvP Nightmare and have PvP?  If PvPN is on and no PvP, kill PvPN
        if ((mi.PvPN = true) and (mi.PvP = false)) then mi.PvPN := false;


        // Colus, 20040118: Update Spirit Spheres for monks
        if (tc.spiritSpheres > 0) then UpdateSpiritSpheres(tm, tc, tc.spiritSpheres);

        {if (mi.noDay = true) {or (tc.noDay = true) then begin
          WFIFOW(0, $0119);
          WFIFOL(2, tc1.ID);
          WFIFOW(6, 00);
          WFIFOW(8, 16);
          WFIFOW(10, 00);
          WFIFOB(12, 0); // attack animation
          Socket.SendBuf(buf, 13)
        end;}




        end;
        end;

			end;//$007d
		//--------------------------------------------------------------------------
		$007e: //tick
			begin
				WFIFOW(0, $007f);
				WFIFOL(2, timeGetTime());
				Socket.SendBuf(buf, 6);
			end;
		//--------------------------------------------------------------------------
		$0085: //�ړ��v�� (�����Ă�Ƃ���`���b�g�Ȃǂł͈ړ��ł��Ȃ��悤�ɂ��邱��)
			begin
{�`���b�g���[���@�\�ǉ�} {Lit. "Chat room functional addition"}
        if tc.Sit = 1 then continue;

				if tc.ChatRoomID <> 0 then continue; //�`���b�g���̈ړ��֎~
{�`���b�g���[���@�\�ǉ��R�R�܂�} {Lit. "To Chat room functional additional coconut}
{�I�X�X�L���ǉ�} {Lit. "Street stall skill addition"}
				if tc.VenderID <> 0 then continue; //�I�X���̈ړ��֎~  Lit. "Movement prohibition in street stall"
{�I�X�X�L���ǉ��R�R�܂�} {Lit. "To street stall skill additional coconut"}
				RFIFOM1(2, xy);
				tc.NextFlag := true;
				tc.NextPoint := xy;
{�p�[�e�B�[�@�\�ǉ�} {Lit. "Party functional addition"}
				//����}�b�v��PTM�ɏ��݂�m�点��  Lit. "It informs about location inside PTM the identical map"
				if tc.PartyName <> '' then begin
					WFIFOW( 0, $0107);
					WFIFOL( 2, tc.ID);
					WFIFOW( 6, tc.NextPoint.X);
					WFIFOW( 8, tc.NextPoint.Y);
					SendPCmd(tc,10,true,true);
				end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�} {Lit. "To party functional additional coconut"}
			end;
		//--------------------------------------------------------------------------
		$0089: //�U���A����
			begin
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(tc.ID));
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(tc.AMode));
				if (tc.AMode > 2) and (tc.Skill[278].Lv = 0) then continue;
				if (tc.MMode <> 0) and (tc.Skill[278].Lv = 0) then continue;

                tc.Delay := 0;
                tc.Skill[272].Tick := 0;

				RFIFOB(6, b);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Inside Attack Command');
				if (b = 0) or (b = 7) then begin
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(b));
					//�U��
					RFIFOL(2, l);
					tm := tc.MData;

        { Alex: reverting to 007d requires a weapon sprite fix. }
    	if (tc.Shield <> 0) then begin
        	UpdateLook(tc.MData, tc, 2, tc.WeaponSprite[0], tc.Shield);
		end else begin
			UpdateLook(tc.MData, tc, 2, tc.WeaponSprite[0], tc.WeaponSprite[1]);
		end;

          //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(l));
          ////////////////////////////////////
					//�����X�^�[�^NPC�i�U�����悤�Ƃ���ƊJ�n�j
          if tm.NPC.IndexOf(l) <> -1 then begin
            tn := tm.NPC.IndexOfObject(l) as TNPC;
						//�����`�F�b�N
            if (tc.Map <> tn.Map) OR (abs(tc.Point.X - tn.Point.X) > 15) OR
               (abs(tc.Point.Y - tn.Point.Y) > 15) then begin
              Continue;
						end;
						case tn.CType of
							1:	//shop
								begin
									WFIFOW(0, $00c4);
									WFIFOL(2, l);
									Socket.SendBuf(buf, 6);
								end;
							2:	//script
								begin
									tc.TalkNPCID := tn.ID;
									tc.ScriptStep := 0;
									tc.AMode := 3;
									// Option Reset
									// Colus, 20040204: WHY?  You will lose your peco/falcon when
									// talking/shopping...you want to unhide, perhaps, but not
									// completely reset your options.
									if (tc.Option and 6 <> 0) then begin
										tc.Option := tc.Option and $FFF9;
										//�����ڕύX  Lit. "The eye modification which you saw"
										UpdateOption(tm, tc);
									end;
									tc.AData := tn;
									NPCScript(tc);
								end;
							{ 4: // Skillunit
								begin
									if (tn.JID = $8d) then begin
										if tc.pcnt <> 0 then xy := tc.tgtPoint else xy := tc.Point;
										if (abs(xy.X - tn.Point.X) > tc.Range) or (abs(xy.Y - tn.Point.Y) > tc.Range) then begin
										//��������������
										WFIFOW( 0, $0139);
										WFIFOL( 2, tn.ID);
										WFIFOW( 6, tn.Point.X);
										WFIFOW( 8, tn.Point.Y);
										WFIFOW(10, tc.Point.X);
										WFIFOW(12, tc.Point.Y);
										WFIFOW(14, tc.Range); //�˒�
										Socket.SendBuf(buf, 16);
									end else begin
										//�U���\
										if b = 7 then tc.AMode := 2 else tc.AMode := 1;
										tc.ATarget := tn.ID;
										tc.AData := tn;
										if tc.ATick + tc.ADelay - 200 < timeGetTime() then
											tc.ATick := timeGetTime() - tc.ADelay + 200;
									end;//if (tn.JID) else
								end;//case-4
								end;}
						end;//case tn.CType
					end;//if tm.NPC.IndexOf(l)
					//�����X�^�[�^NPC�@�����܂�
					////////////////////////////////////
					if tm.Mob.IndexOf(l) <> -1 then begin
						//�΃����X�^�[
						ts := tm.Mob.IndexOfObject(l) as TMob;
						if tc.pcnt <> 0 then xy := tc.tgtPoint else xy := tc.Point;
						if (abs(xy.X - ts.Point.X) > tc.Range) or (abs(xy.Y - ts.Point.Y) > tc.Range) then begin
							//��������������
							WFIFOW( 0, $0139);
							WFIFOL( 2, ts.ID);
							WFIFOW( 6, ts.Point.X);
							WFIFOW( 8, ts.Point.Y);
							WFIFOW(10, tc.Point.X);
							WFIFOW(12, tc.Point.Y);
							WFIFOW(14, tc.Range); //�˒�
							Socket.SendBuf(buf, 16);
						end else begin
							//�U���\
							if b = 7 then tc.AMode := 2 else tc.AMode := 1;
							tc.ATarget := ts.ID;
							tc.AData := ts;
							if tc.ATick + (tc.ADelay - 200) < timeGetTime() then
								tc.ATick := timeGetTime() - tc.ADelay + 200;
						end;
					end else begin
						//�����X�^�[�łȂ�
					end;

					if tm.CList.IndexOf(l) <> -1 then begin
						tc1 := tm.CList.IndexOfObject(l) as TChara;
						if tc.pcnt <> 0 then xy := tc.tgtPoint else xy := tc.Point;
						if (abs(xy.X - tc1.Point.X) > tc.Range) or (abs(xy.Y - tc1.Point.Y) > tc.Range) then begin
							//��������������
							WFIFOW( 0, $0139);
							WFIFOL( 2, tc1.ID);
							WFIFOW( 6, tc1.Point.X);
							WFIFOW( 8, tc1.Point.Y);
							WFIFOW(10, tc.Point.X);
							WFIFOW(12, tc.Point.Y);
							WFIFOW(14, tc.Range); //�˒�
							Socket.SendBuf(buf, 16);
						end else begin
							//�U���\
							if b = 7 then tc.AMode := 2 else tc.AMode := 1;
							tc.ATarget := tc1.ID;
							tc.AData := tc1;
							if tc.ATick + (tc.ADelay - 200) < timeGetTime() then
								tc.ATick := timeGetTime() - tc.ADelay + 200;
						end;
					end;//if tm.CList.IndexOf(l)

				end else if (b = 2) or (b = 3) then begin
					if (tc.Skill[1].Lv >= 3) then begin
						//����
						tc.Sit := b;
						tm := tc.MData;
						WFIFOW(0, $008a);
						WFIFOL(2, tc.ID);
						WFIFOB(26, b);

						SendBCmd(tm, tc.Point, 29);
					end else begin
						w := tc.MSkill;
						tc.MSkill := 1;
						SendSkillError(tc, 0, 2);
						tc.MSkill := w;
					end;//if-else
				end;
			end;//$0089
		//--------------------------------------------------------------------------
		$008c: { Text is received from client. Check for GM commands. }
			begin
				RFIFOW(2, w);
				str := RFIFOS(4, w - 4);

                // ALBGM - Accesss Level Based GM System. Finally, nice and clean.
                if (Pos(' : ', str) <> 0) and ( (Copy(str, Pos(' : ', str) + 3, 1) = '#') or (Copy(str, Pos(' : ', str) + 3, 1) = '@') )then begin
                    str2 := str;
                    parse_commands (tc, str2);
                    str := '';
                end;
                // ALBGM - Accesss Level Based GM System. Finally, nice and clean.

                if (tc.ISCS) then begin
                    iscs_console_send(AnsiRightStr(str, length(str) - AnsiPos(' : ', str) - length(' : ') + 1 ), tc );                    
                end

                else if (length(str) > 0) then begin
                	tm := tc.MData;

					WFIFOW(0, $008e);
	                WFIFOW(2, w);
    	            WFIFOS(4, str, w - 4);
        	        Socket.SendBuf(buf, w);

	                WFIFOW(0, $008d);
    	            WFIFOW(2, w + 4);
        	        WFIFOL(4, tc.ID);
            	    WFIFOS(8, str, w - 4);

	                if (tc.ChatRoomID <> 0) then begin
    	            	SendCrCmd(tc, w + 4, true);
        	        end else begin
            	    	SendNCrCmd(tm, tc.Point, w + 4, tc, true, true);
                	end;
                end;
            end;

		//--------------------------------------------------------------------------
		$0090: //NPC�ɘb��������
			begin
				if tc.AMode <> 0 then continue;
				tm := tc.MData;
				RFIFOL(2, l);
				if tm.NPC.IndexOf(l) <> -1 then begin
					tn := tm.NPC.IndexOfObject(l) as TNPC;
					//�����`�F�b�N
					if (tc.Map <> tn.Map) or (abs(tc.Point.X - tn.Point.X) > 15) or (abs(tc.Point.Y - tn.Point.Y) > 15) then begin
						continue;
					end;
					case tn.CType of
					1:	//shop
						begin
							WFIFOW(0, $00c4);
							WFIFOL(2, l);
							Socket.SendBuf(buf, 6);
						end;
					2:	//script
						begin
							tc.TalkNPCID := tn.ID;
							tc.ScriptStep := 0;
							tc.AMode := 3;
							tc.AData := tn;
							NPCScript(tc);
						end;
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$0094: //�w��ID�̃L�����ANPC�̖��O��v��
   
			begin
      tm := tc.MData;
				RFIFOL(2, l);
				//accountid := IntToStr(l);
				if CharaPID.IndexOf(l) <> -1 then begin
					tc := CharaPID.IndexOfObject(l) as TChara;
{�M���h�@�\�ǉ�}
					if (tc.GuildID = 0) then begin
						WFIFOW(0, $0095);
						WFIFOL( 2, l);
						WFIFOS( 6, tc.Name, 24);
						Socket.SendBuf(buf, 30);
					end else begin
						WFIFOW(0, $0195);
						WFIFOL( 2, l);
						WFIFOS( 6, tc.Name, 24);
						WFIFOS(30, tc.PartyName, 24);
						WFIFOS(54, tc.GuildName, 24);
						WFIFOS(78, tc.ClassName, 24);
						Socket.SendBuf(buf, 102);
					end;
{�M���h�@�\�ǉ��R�R�܂�}
				end else if tm.Mob.IndexOf(l) <> -1 then begin
					ts := tm.Mob.IndexOfObject(l) as TMob;
					WFIFOW(0, $0095);
					WFIFOL( 2, l);
					WFIFOS( 6, ts.Name, 24);
					Socket.SendBuf(buf, 30);
				end else if tm.NPC.IndexOf(l) <> -1 then begin
					tn := tm.NPC.IndexOfObject(l) as TNPC;
					WFIFOW( 0, $0095);
					WFIFOL( 2, l);
					WFIFOS( 6, tn.Name, 24);
					Socket.SendBuf(buf, 30);
				end;
			end;
		//--------------------------------------------------------------------------
		$0096: //wis���M
			begin
				RFIFOW(2, w);
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(w));
				str := RFIFOS(4, 24);
				i := CharaName.IndexOf(str);
				if i = -1 then begin
					//�w�肳�ꂽ���O�̃L���������Ȃ�
					WFIFOW( 0, $0098);
					WFIFOB( 2, 1);
					Socket.SendBuf(buf, 3);
					continue;
				end;
				tc1 := CharaName.Objects[i] as TChara;
				if tc1.Login <> 2 then begin
					//���肪���O�C�����Ă��Ȃ�
					WFIFOW( 0, $0098);
					WFIFOB( 2, 1);
					Socket.SendBuf(buf, 3);
					continue;
				end;
				//wis���M
				WFIFOW( 0, $0097);
				WFIFOS( 4, tc.Name, 24);
				tc1.Socket.SendBuf(buf, w);
				WFIFOW( 0, $0098);
				WFIFOB( 2, 0);
				Socket.SendBuf(buf, 3);
			end;
		//--------------------------------------------------------------------------
		$0099: // GM BROADCASTS
			begin
            	RFIFOW(2, w);
                str := RFIFOS(4, w - 4);
                parse_commands (tc, '/B'+str);
            end;
		//--------------------------------------------------------------------------
		$009b: //�����ύX
			begin
				tm := tc.MData;

				RFIFOW(2, tc.HeadDir);
				RFIFOB(4, tc.Dir);

				WFIFOW(0, $009c);
				WFIFOL(2, tc.ID);
				WFIFOW(6, tc.HeadDir);
				WFIFOB(8, tc.Dir);

				//�u���b�N����
				SendBCmd(tm, tc.Point, 9, tc);
			end;
		//--------------------------------------------------------------------------
		$009f: //�A�C�e�����E��
			begin
				RFIFOL(2, l);
				PickUpItem(tc,l);
			end;
		//--------------------------------------------------------------------------
		$00a2: //�A�C�e���h���b�v
			begin
				tm := tc.MData;
				RFIFOW(2, w1);
				RFIFOW(4, w2);
				if (tc.Item[w1].ID <> 0) and (tc.Item[w1].Amount >= w2) then begin
					tn := TNPC.Create;
					tn.ID := NowItemID;
					Inc(NowItemID);
					tn.Name := 'item';
					tn.JID := tc.Item[w1].ID;
					tn.Map := tc.Map;
					tn.Point.X := tc.Point.X - 1 + Random(3);
					tn.Point.Y := tc.Point.Y - 1 + Random(3);
					tn.CType := 3;
          tn.Enable := true;
					tn.Item := TItem.Create;
					tn.Item.ID := tc.Item[w1].ID;
					tn.Item.Amount := w2;
					tn.Item.Identify := tc.Item[w1].Identify;
					tn.Item.Refine := tc.Item[w1].Refine;
					tn.Item.Attr := tc.Item[w1].Attr;
					tn.Item.Card[0] := tc.Item[w1].Card[0];
					tn.Item.Card[1] := tc.Item[w1].Card[1];
					tn.Item.Card[2] := tc.Item[w1].Card[2];
					tn.Item.Card[3] := tc.Item[w1].Card[3];
					tn.Item.Data := tc.Item[w1].Data;
					tn.SubX := Random(8);
					tn.SubY := Random(8);
					tn.Tick := timeGetTime() + 60000;
					tm.NPC.AddObject(tn.ID, tn);
					tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);
					//�A�C�e��������
					WFIFOW( 0, $00af);
					WFIFOW( 2, w1);
					WFIFOW( 4, w2);
					Socket.SendBuf(buf, 6);

					tc.Item[w1].Amount := tc.Item[w1].Amount - w2;
					if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
					tc.Weight := tc.Weight - tc.Item[w1].Data.Weight * w2;
					//Update weight
          SendCStat1(tc, 0, $0018, tc.Weight);

					//����ɒʒm
					WFIFOW( 0, $009e);
					WFIFOL( 2, tn.ID);
					WFIFOW( 6, tn.JID);
					WFIFOB( 8, tn.Item.Identify);
					WFIFOW( 9, tn.Point.X);
					WFIFOW(11, tn.Point.Y);
					WFIFOB(13, tn.SubX);
					WFIFOB(14, tn.SubY);
					WFIFOW(15, tn.Item.Amount);
					SendBCmd(tm, tn.Point, 17);
				end;
			end;
		//--------------------------------------------------------------------------
		$00a7: //Item Use
			begin

                tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;

{�`���b�g���[���@�\�ǉ�}
				//�������̃A�C�e���g�p����
				if (tc.ChatRoomID <> 0) then continue;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
				//�I�X���̃A�C�e���g�p����
{�A�W�g�@�\�ǉ�}
				i := MapInfo.IndexOf(tc.Map);
				if (i <> -1) then begin
					mi := MapInfo.Objects[i] as MapTbl;
				end else begin
					mi := MapTbl.Create;
				end;
				if mi.noItem then continue;
{�A�W�g�@�\�ǉ��R�R�܂�}
				if (tc.VenderID <> 0) then continue;

        //if (tc.Sit <> 1) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
				RFIFOW(2, w);
				RFIFOL(4, l);
				if (l = tc.ID) and (w >= 1) and (w <= 100) then begin
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'UsedItem:' + IntToStr(w));
					td := tc.Item[w].Data;
					b := 0;
                                        if tc.item[w].Amount <= 0 then exit;
          if tc.BaseLV < td.eLV then exit;
                                    case td.IType of
          			10: // Arrows (added care cuase its a mess sorry)
                    	begin
							if tc.Item[w1].Data.IType = 10 then begin
								//arrow equip
								WFIFOW(0, $013c);
								WFIFOW(2, 0);
								Socket.SendBuf(buf, 4);
                            end;
                        end;
					0: //Recovery item
						begin
                                                        {Concentration Potion, Awakening Potion, Beserk Potion}
                                                        if (td.ID = 645) then SendItemSkill(tc, 291, 1);
                                                        if (td.ID = 656) then SendItemSkill(tc, 291, 2);
                                                        if (td.ID = 657) then SendItemSkill(tc, 291, 3);

							if tc.Item[w].Amount > 0 then begin
                                                                if td.ID = 607 then begin  {Yggasberry}
                                                                        tc.HP := tc.MAXHP;
                                                                        tc.SP := tc.MAXSP;
                                                                        SendCStat1(tc, 0, 5, tc.HP);
                                                                        SendCStat1(tc, 0, 7, tc.SP);
                                                                end else if td.ID = 608 then begin      {Seed of Yggassdril}
                                                                        tc.HP := tc.HP + (tc.MAXHP div 2);
                                                                        tc.SP := tc.SP + (tc.MAXSP div 2);
                                                                        if tc.HP > tc.MAXHP then tc.HP := tc.MAXHP;
                                                                        if tc.SP > tc.MAXSP then tc.SP := tc.MAXSP;
                                                                        SendCStat1(tc, 0, 5, tc.HP);
                                                                        SendCStat1(tc, 0, 7, tc.SP);
                                                                end;

                                                                if td.Effect = 1 then begin
                                                                        tc.isPoisoned := False;
                                                                        tc.PoisonTick := timeGetTime();
                                                                        tc.Stat2 := 0;
                                                                        UpdateStatus(tm, tc, timeGetTime);
                                                                end;

								if td.HP2 <> 0 then begin
                                                                        if tc.Skill[227].Lv <> 0 then begin
                                                                                tc.HP := tc.HP + ((td.HP1 + Random(td.HP2 - td.HP1 + 1)) * (100 + tc.Param[2]) div 100) * tc.Skill[227].Data.Data1[tc.Skill[227].Lv] div 100;  //Learning Potion
                                                                        end else begin
                                                                                // Added HP Recovery skill's power to the recovery calc
                                                                                if (tc.Skill[4].Lv <> 0) then begin
                                                                                  tc.HP := tc.HP + (td.HP1 + Random(td.HP2 - td.HP1 + 1)) * (100 + tc.Param[2]) div 100 * (100 + (tc.Skill[4].Lv * 10)) div 100;
                                                                                end else begin
                                                                                  tc.HP := tc.HP + (td.HP1 + Random(td.HP2 - td.HP1 + 1)) * (100 + tc.Param[2]) div 100;
                                                                                end;
                                                                        end;
									//030316�ǉ� Cardinal
									if tc.HP > tc.MAXHP then tc.HP := tc.MAXHP;
									SendCStat1(tc, 0, 5, tc.HP);
								end;
								if td.SP2 <> 0 then begin
									tc.SP := tc.SP + (td.SP1 + Random(td.SP2 - td.SP1 + 1)) * (100 + tc.Param[3]) div 100;

									//030316�ǉ� Cardinal
									if tc.SP > tc.MAXSP then tc.SP := tc.MAXSP;
									SendCStat1(tc, 0, 7, tc.SP);
                                                                        end;
   // Tumy
   Dec(tc.Item[w].Amount);
   if tc.Item[w].Amount = 0 then tc.Item[w].ID := 0; 
   tc.Weight := tc.Weight - td.Weight; 

   // {Alex: Reduce Number of Items}
   WFIFOW( 0, $00af); 
   WFIFOW( 2, w);
   WFIFOW( 4, 1);
                     Socket.SendBuf(buf, 6);

   // {Alex: Update Weight Display}
   SendCStat1(tc, 0, $0018, tc.Weight);

   // {Alex: Displays Effect}
   WFIFOW( 0, $01c8);
   WFIFOW( 2, w);
   WFIFOW( 4, td.ID);
   WFIFOL( 6, l);
   WFIFOW( 10, tc.Item[w].Amount);
   WFIFOB( 12, 1);
   //Socket.SendBuf(buf, 13);
   SendBCmd(tm, tc.Point, 13);

                     b := 1;
                     // Tumy
							end;
						end;
					2: //�g�p�A�C�e��
						begin
							case td.Effect of
                                                                0:
                                                                begin

                                                                        UseUsableItem(tc, w);

                                                                        { Worn out scroll }
                                                                        if (td.ID = 618) then begin
                                                                        	tc.BaseEXP := tc.BaseEXP + Round(tc.BaseNextEXP div 100);
                                                                            SendCStat1(tc, 1, $0001, tc.BaseEXP);
                                                                        end;

                                                                        {Yggasdril Leaf}
                                                                        if (td.ID = 610) then begin
                                                                                SendItemSkill(tc, 54, 1);
                                                                        end;

                                                        end;
							1: //�g�勾
								begin
									WFIFOW(0, $0177);
									j := 4;
									for i := 1 to 100 do begin
										if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount > 0) and
											 (tc.Item[i].Identify = 0) then begin
											WFIFOW(j, i);
											j := j + 2;
										end;
									end;
									if j <> 4 then begin //���Ӓ�A�C�e��������ꍇ
										WFIFOW(2, j);
										Socket.SendBuf(buf, j);
										tc.UseItemID := w;
										b := 1;
									end;
								end;
							2: // Fly Wings - Rewritten by AlexKreuz
								begin
                  if ((tc.item[w].Amount <= 0) or (tc.Sit = 1) or (tc.Option and 6 <> 0)) then exit;
									i := MapInfo.IndexOf(tc.Map);
									j := -1;
									if (i <> -1) then begin
										mi := MapInfo.Objects[i] as MapTbl;
										if (mi.noTele = true) then j := 0;
									end;
									if (j <> 0) then begin

                                        tm := tc.MData;

                                        j := 0;

									        repeat
										        xy.X := Random(tm.Size.X - 2) + 1;
										        xy.Y := Random(tm.Size.Y - 2) + 1;
										        Inc(j);
									        until ( ((tm.gat[xy.X, xy.Y] <> 1) and (tm.gat[xy.X, xy.Y] <> 5)) or (j = 100) );

									        if j <> 100 then begin
										        UseUsableItem(tc, w);
										        b := 1;
                                                SendCLeave(tc, 3);
										        tc.Point := xy;
                                                MapMove(Socket, tc.Map, tc.Point);
									        end;
                                                                        end;
                                                                end;
							3: //���̉H
								begin

{NPC�C�x���g�ǉ�}                                                       if tc.item[w].Amount <= 0 then exit;
									i := MapInfo.IndexOf(tc.Map);
									j := -1;
									if (i <> -1) then begin
										mi := MapInfo.Objects[i] as MapTbl;
										if (mi.noTele = true) then j := 0;
									end;
									if (j <> 0) then begin
{NPC�C�x���g�ǉ��R�R�܂�}
									UseUsableItem(tc, w);

									b := 1;
									SendCLeave(tc, 0);
									tc.Map := tc.SaveMap;
									tc.Point := tc.SavePoint;
									MapMove(Socket, tc.Map, tc.Point);
{NPC�C�x���g�ǉ�}
									end;
{NPC�C�x���g�ǉ��R�R�܂�}
								end;

{��{���ǉ�}
							10, 201: //Dead Branch
								begin
									if not mi.noBranch then begin
										UseUsableItem(tc, w);

										//Use MobList or MobListMVP
										if (SummonMobList.Count > 0) then begin
											tm := tc.MData;
											ts := TMob.Create;
											if td.Effect = 10 then begin
												{ChrstphrR - 2004/04/20 - design change}
												// L = ID of
												L := SummonMobList.RandomChoice;
												str := (MobDB.Objects[MobDB.IndexOf(L)] AS TMobDB).Name;
												//Fill Mob Data.
												ts.Data := MobDBName.Objects[MobDBName.IndexOf(str)] as TMobDB;
												ts.ID := NowMobID;
												Inc(NowMobID);
											end else begin //MVP list
												{ChrstphrR - Fixed in format of other Summon???Lists}
												if SummonMobListMVP.Count > 0 then begin
													L := Random(SummonMobListMVP.Count);
													str := SummonMobListMVP[L];
													//Fill Mob Data.
													ts.Data := MobDBName.Objects[MobDBName.IndexOf(str)] as TMobDB;
													ts.ID := NowMobID;
													Inc(NowMobID);
												end;
											end;

											if (SummonMonsterName = true) then begin
												ts.Name := ts.Data.JName;
											end else begin
												ts.Name := 'Summon Monster';
											end;

											if (SummonMonsterAgo = true) then begin
												ts.isActive := true;
											end else begin
												ts.isActive := ts.Data.isActive;
											end;

											ts.JID := ts.Data.ID;
											ts.Map := tc.Map;

											j := 0;
											repeat
												ts.Point.X := tc.Point.X + Random(11) - 5;
												ts.Point.Y := tc.Point.Y + Random(11) - 5;
												Inc(j);
											until ( ((tm.gat[ts.Point.X, ts.Point.Y] <> 1) and (tm.gat[ts.Point.X, ts.Point.Y] <> 5))  or (j = 10) );
											if (j = 10) then begin
												ts.Point.X := tc.Point.X;
												ts.Point.Y := tc.Point.Y;
											end;

											ts.Dir := Random(8);
											ts.HP := ts.Data.HP;
											ts.Speed := ts.Data.Speed;

											ts.SpawnDelay1 := $7FFFFFFF;
											ts.SpawnDelay2 := 0;

											ts.SpawnType := 0;
											ts.SpawnTick := 0;
											ts.MoveWait := timeGetTime();
											ts.ATarget := 0;
											ts.ATKPer := 100;
											ts.DEFPer := 100;
											ts.DmgTick := 0;
											ts.isActive := true;

											ts.Element := ts.Data.Element;

											for j := 0 to 31 do begin
												ts.EXPDist[j].CData := nil;
												ts.EXPDist[j].Dmg := 0;
											end;
											if ts.Data.MEXP <> 0 then begin
												for j := 0 to 31 do begin
													ts.MVPDist[j].CData := nil;
													ts.MVPDist[j].Dmg := 0;
												end;
												ts.MVPDist[0].Dmg := ts.Data.HP * 30 div 100; //FA��30%���Z
											end;

											// Link monster to Map it's now on.
											tm.Mob.AddObject(ts.ID, ts); //Owned here.
											tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.AddObject(ts.ID, ts);

											ts.isSummon := True;
											ts.EmperiumID := 0;

											SendMData(tc.Socket, ts);
											//���͂ɑ��M
											SendBCmd(tm,ts.Point,41,tc,False);
											b := 1;
										end;
									end;
								end;
							11,12,13,14: //���A�����A�J�[�h���A�v����
								begin
									UseUsableItem(tc, w);

									str := '';
									case td.Effect of
									11: //��
										begin
											if (SummonIOBList.Count > 0) then begin
												str := SummonIOBList[Random(SummonIOBList.Count)];
											end;
										end;
									12: //����
										begin
											if (SummonIOVList.Count > 0) then begin
												str := SummonIOVList[Random(SummonIOVList.Count)];
											end;
										end;
									13: //�J�[�h��
										begin
											if (SummonICAList.Count > 0) then begin
												str := SummonICAList[Random(SummonICAList.Count)];
											end;
										end;
									14: //�v����
										begin
											if (SummonIGBList.Count > 0) then begin
												str := SummonIGBList[Random(SummonIGBList.Count)];
											end;
										end;
									200:  //New --- Old Weapon Box�
										begin
											if (SummonIOWBList.Count > 0) then begin
												str := SummonIOWBList[Random(SummonIOWBList.Count)];
											end;
										end;
									end;


									if (str <> '') then begin
										i := 0;
										td := ItemDBName.Objects[ItemDBName.IndexOf(str)] as TItemDB;
										if tc.MaxWeight >= tc.Weight + cardinal(td.Weight) * cardinal(j) then begin
											k := SearchCInventory(tc, td.ID, td.IEquip);
											if (k <> 0) then begin
												if tc.Item[k].Amount < 30000 then begin
													//�A�C�e���ǉ�
													tc.Item[k].ID := td.ID;
													tc.Item[k].Amount := tc.Item[k].Amount + 1;
													tc.Item[k].Equip := 0;
													tc.Item[k].Identify := 1;
													tc.Item[k].Refine := 0;
													tc.Item[k].Attr := 0;
													tc.Item[k].Card[0] := 0;
													tc.Item[k].Card[1] := 0;
													tc.Item[k].Card[2] := 0;
													tc.Item[k].Card[3] := 0;
													tc.Item[k].Data := td;
													//�d�ʒǉ�
													tc.Weight := tc.Weight + cardinal(td.Weight);
													SendCStat1(tc, 0, $0018, tc.Weight);
													//�A�C�e���Q�b�g�ʒm
													SendCGetItem(tc, k, 1);
													b := 1;
												end;
											end else begin
												i := 1;
											end;
										end else begin
											i := 2;
										end;
										if (i <> 0) then begin
											//�擾���s
											WFIFOW( 0, $00a0);
											WFIFOB(22, i);
											Socket.SendBuf(buf, 23);
											b := 1;
										end;
									end;
								end;
                                                        15:
                                                                begin
									UseUsableItem(tc, w);

                                                                        if tc.Item[w].ID = 645 then begin
                                                                        tc.ASpeed := tc.ASpeed + 6;
                                                                        end;
                                                                        if tc.Item[w].ID = 656 then tc.ASpeed := tc.ASpeed + 8;
                                                                        if tc.Item[w].ID = 657 then tc.ASpeed := tc.ASpeed + 10;

                                                                end;

							100: // Forging items (mini-furnace, hammers)
								begin
                  // Colus, 20040214:
                  // Save the ID of the item you're using first.
                  // If it's the last one, UseUsableItem will make its ID 0.
                  w3 := tc.Item[w].ID;

									UseUsableItem(tc, w);
                                                                        
									b := 1;

									//�A�C�e�����X�g���M
									j := 4;

									for w1 := 0 to MaterialDB.Count-1 do begin
										e2 := 0;//e2�𐻑��\���̃t���O�Ƃ��Ďg��
										tma := MaterialDB.Objects[w1] as TMaterialDB;

										case tma.RequireSkill of

										0,94,95,96://���̂�����A�e�푮���΂̏ꍇ�͎g�p�A�C�e�����n�z�F���`�F�b�N
											begin

												for w2 := 0 to 2 do begin
													if (tma.ItemLV > tc.Skill[tma.RequireSkill].Lv) or (w3 <> 612) then begin
														e2 := 1;
														continue;
													end;
													if tma.MaterialID[w2] = 0 then continue;
													e := SearchCInventory(tc, tma.MaterialID[w2], false);
													if (e = 0) or (tc.Item[e].Amount < tma.MaterialAmount[w2]) then begin
														e2 := 1;
													end;
												end;

												if (e2 <> 1) then begin

													WFIFOW(j, tma.ID);
													WFIFOW(j+2, 12);
													WFIFOL(j+4, tc.ID);
													j := j+8;

												end;
											end;
										98,99,100,101,102,103,104://����̏ꍇ�͎g�p�A�C�e�������x���ɉ��������Ƃ��`�F�b�N
											begin

												for w2 := 0 to 2 do begin

													if (tma.ItemLV > tc.Skill[tma.RequireSkill].Lv) or (w3 = 612) or ((tma.ItemLV > 1) and (w3 = 613)) or ((tma.ItemLV = 3) and (w3 = 614)) then begin
														e2 := 1;
														continue;
													end;

													if tma.MaterialID[w2] = 0 then continue;

													e := SearchCInventory(tc, tma.MaterialID[w2], false);

													if (e = 0) or (tc.Item[e].Amount < tma.MaterialAmount[w2]) then begin
													e2 := 1;
													end;
												end;

												if (e2 <> 1) then begin

													WFIFOW(j, tma.ID);
													WFIFOW(j+2, 12);
													WFIFOL(j+4, tc.ID);
													j := j+8;

												end;
											end;
										end;

									end;

									WFIFOW(0, $018d);
									WFIFOW(2, j);
									Socket.SendBuf(buf, j);
								end;

                                                                                120: // �e�C�~���O�A�C�e��
                                                                                        begin
                                                                                                tc.UseItemID := tc.Item[w].Data.ID;


Dec(tc.Item[w].Amount);
if tc.Item[w].Amount = 0 then tc.Item[w].ID := 0;
tc.Weight := tc.Weight - tc.Item[w].Data.Weight;

//Update weight
SendCStat1(tc, 0, $0018, tc.Weight);

// �A�C�e���g�p�p�P�b�g�𑗐M
WFIFOW( 0, $00a8);
WFIFOW( 2, w);
WFIFOW( 4, tc.Item[w].Amount);
WFIFOB( 6, 1);
{���BNPC�@�\�ǉ�}
//�������b�N�`�F�b�N
if tc.EqLock = true then continue;
{���BNPC�@�\�ǉ��R�R�܂�}
Socket.SendBuf(buf, 7);

//�A�C�e��������
WFIFOW( 0, $00af);
WFIFOW( 2, w);
WFIFOW( 4, 1);
//Socket.SendBuf(buf,6);

b := 1;

// �����X�^�[�I���p�P���M
WFIFOW( 0, $019e );
Socket.SendBuf( buf, 2 );
end;
                                                        121: // Pet Incubator
                                                                begin
                                                                        if ( tc.PetData = nil ) and ( tc.PetNPC = nil ) then begin

                                                                                WFIFOW(0, $01a6);
									        j := 4;
									        for i := 1 to 100 do begin
										        if ( tc.Item[i].ID <> 0 ) and (tc.Item[i].Amount > 0) and
                                                                                        ( tc.Item[i].Data.IType = 4 ) and ( tc.Item[i].Data.Loc = 0 ) and
                                                                                        ( tc.Item[i].Data.Effect = 122 ) then begin
     											        WFIFOW(j, i);
											        j := j + 2;
										        end;
									        end;
									        if j <> 4 then begin //When there is an egg
										        WFIFOW(2, j);
										        Socket.SendBuf(buf, j);
                                                                                        tc.UseItemID := w;
                                                                                        b := 1;
                                                                                end;
                                                                        end;
                                                                end;

{�L���[�y�b�g�����܂�}
							end;
						end;
					end;
					if b = 0 then begin
						WFIFOW( 0, $00a8);
						WFIFOW( 2, w);
						WFIFOW( 4, 0);
						WFIFOB( 6, 0);
						Socket.SendBuf(buf, 7);
					end;
				end;
			end;
		//--------------------------------------------------------------------------
{���BNPC�@�\�ǉ�}
				//�������b�N�`�F�b�N
{���BNPC�@�\�ǉ��R�R�܂�}
		$00a9: // Equip an item.
			begin
				if tc.EqLock = true then continue;
				RFIFOW(2, w1);
				RFIFOW(4, w2);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Index:%d EquipType:%d', [w1, w2]));
{�C��}
				// Colus, 20040304: Upper classes able to equip things now?
				i := tc.JID;
				if (i > UPPER_JOB_BEGIN) then i := i - UPPER_JOB_BEGIN + LOWER_JOB_END;
				// wjob := 1 shl tc.JID;
				wjob := Int64(1) shl i;
{�C���R�R�܂�}
				if (not DisableEquipLimit) and
					 ((tc.Item[w1].Identify = 0) or (tc.BaseLV < tc.Item[w1].Data.eLV) or
						((tc.Item[w1].Data.Gender <> 2) and (tc.Gender <> tc.Item[w1].Data.Gender)) or
						((tc.Item[w1].Data.Job and wjob) = 0)) then begin
					//���Ӓ�A�C�e���͑����ł��Ȃ�
					WFIFOW(0, $00aa);
					WFIFOW(2, w1);
					WFIFOW(4, 0);
					WFIFOB(6, 0);
					Socket.SendBuf(buf, 7);
					continue;
				end;

				if tc.Item[w1].Data.Loc = $88 then begin
					//�A�N�Z�T���p����
					w := $88;
					j := 0;
					for i := 1 to 100 do begin //�����ӏ��������Ă邩�`�F�b�N
						if (tc.Item[i].ID <> 0) and tc.Item[i].Data.IEquip then begin
							if (tc.Item[i].Equip = $8)	then begin w := (w and $80);				 end;
							if (tc.Item[i].Equip = $80) then begin w := (w and $8);	j := i; end;
						end;
					end;
					if w = 0 then begin //When both 'buried' RHS is removed
                    	reset_skill_effects(tc);
						WFIFOW(0, $00ac);//Remove Equipment
						WFIFOW(2, j);
						WFIFOW(4, tc.Item[j].Equip);
						tc.Item[j].Equip := 0;
						WFIFOB(6, 1);//Successful Remove.
						Socket.SendBuf(buf, 7);
                        remove_equipcard_skills(tc, j);
						w := $80;
					end;
					if w = $88 then w := $8; //���������Ă�Ƃ��͍���
					tc.Item[w1].Equip := w;

					WFIFOW(0, $00aa);
					WFIFOW(2, w1);
					WFIFOW(4, w);
					WFIFOB(6, 1);
					Socket.SendBuf(buf, 7);
				end else if (tc.Item[w1].Data.Loc = $2) and ((tc.JID = 12) or (tc.JID = 4013)) then begin

                { Alex: Let's try this .. For some reason a SIN only returns $2 and not $22.
                  So instead we'll check for the Jobs and not weapon location. }
                //and (w2 = $22) 

					//�A�T�V���񓁗��p����
					w := $22;
					j := 0;
					for i := 1 to 100 do begin //�����ӏ��������Ă邩�`�F�b�N
						if (tc.Item[i].ID <> 0) and tc.Item[i].Data.IEquip then begin
							if (tc.Item[i].Equip = $2)  then begin w := (w and $20);         end;
							if (tc.Item[i].Equip = $20) then begin w := (w and $2);  j := i; end;
							if (tc.Item[i].Equip = $22) then begin w := 0;           j := i; end;
						end;
					end;
					if w = 0 then begin //�������܂��Ă�Ƃ��͉E�����邢�̓J�^�[�����͂���
                    	reset_skill_effects(tc);
						WFIFOW(0, $00ac);
						WFIFOW(2, j);
						WFIFOW(4, tc.Item[j].Equip);
						tc.Item[j].Equip := 0;
						WFIFOB(6, 1);
						Socket.SendBuf(buf, 7);
                        remove_equipcard_skills(tc, j);
						w := $20;
					end;
					if w = $22 then w := $2; //���������Ă�Ƃ��͍���
					tc.Item[w1].Equip := w;

					WFIFOW(0, $00aa);
					WFIFOW(2, w1);
					WFIFOW(4, w);
					WFIFOB(6, 1);
					Socket.SendBuf(buf, 7);
{�L���[�y�b�g}
					// �y�b�g�A�N�Z�T��
					end else if tc.Item[w1].Data.Effect = 123 then begin

						if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin

							tpe := tc.PetData;
							tn := tc.PetNPC;

							if tc.Item[w1].Data.ID = tpe.Data.AcceID then begin

								// �A�C�e������
								Dec(tc.Item[w1].Amount);
								if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
								tc.Weight := tc.Weight - tc.Item[w1].Data.Weight;

									//�A�C�e��������
									WFIFOW( 0, $00af);
									WFIFOW( 2, w1);
									WFIFOW( 4, 1);
									Socket.SendBuf( buf, 6 );

									//Update weight
									SendCStat1(tc, 0, $0018, tc.Weight);

									if ( tpe.Accessory <> 0 ) and ( ItemDB.IndexOf( tpe.Accessory ) <> -1 ) then begin
										td := ItemDB.IndexOfObject( tpe.Accessory ) as TItemDB;

										if tc.MaxWeight >= tc.Weight + td.Weight then begin
											j := SearchCInventory(tc, td.ID, td.IEquip );
											if j <> 0 then begin
												//�A�C�e���ǉ�
												tc.Item[j].ID := td.ID;
												tc.Item[j].Amount := tc.Item[j].Amount + 1;
												tc.Item[j].Equip := 0;
												tc.Item[j].Identify := 1;
												tc.Item[j].Refine := 0;
												tc.Item[j].Attr := 0;
												tc.Item[j].Card[0] := 0;
												tc.Item[j].Card[1] := 0;
												tc.Item[j].Card[2] := 0;
												tc.Item[j].Card[3] := 0;

												tc.Item[j].Data := td;
												//�A�C�e���Q�b�g�ʒm
												SendCGetItem(tc, j, 1);

												//�d�ʒǉ�
												tc.Weight := tc.Weight + td.Weight;
												SendCStat1(tc, 0, $0018, tc.Weight);
											end else begin
												//����ȏ���ĂȂ�
												WFIFOW( 0, $00a0);
												WFIFOB(22, 1);
												Socket.SendBuf(buf, 23);
											end;
										end else begin
											//�d�ʃI�[�o�[
											WFIFOW( 0, $00a0);
											WFIFOB(22, 2);
											Socket.SendBuf(buf, 23);
										end;
									end;

									tm := tc.MData;
									tpe.Accessory := tc.Item[w1].Data.ID;
									WFIFOW( 0, $01a4 );
									WFIFOB( 2, 3 );
									WFIFOL( 3, tn.ID );
									WFIFOL( 7, tpe.Accessory );

									SendBCmd( tm, tn.Point, 11 );
								end else begin
									WFIFOW(0, $00aa);
									WFIFOW(2, w1);
									WFIFOW(4, 0);
									WFIFOB(6, 0);
									Socket.SendBuf(buf, 7);
								end;
							end else begin
								WFIFOW(0, $00aa);
								WFIFOW(2, w1);
								WFIFOW(4, 0);
								WFIFOB(6, 0);
								Socket.SendBuf(buf, 7);
							end;
{�L���[�y�b�g�����܂�}
						end else begin
							if tc.Item[w1].Data.IType = 10 then begin
							//arrow equip
							WFIFOW(0, $013c);
							WFIFOW(2, 0);
							Socket.SendBuf(buf, 4);
						end;
					for i := 1 to 100 do begin
						if (tc.Item[i].ID <> 0) and (tc.Item[i].Data.IEquip or (tc.Item[i].Data.IType = 10)) then begin
							if (tc.Item[i].Equip and tc.Item[w1].Data.Loc) <> 0 then begin
								//�����ӏ��d���ɂ�葕������
                                reset_skill_effects(tc);
								WFIFOW(0, $00ac);
								WFIFOW(2, i);
								WFIFOW(4, tc.Item[i].Equip);
								tc.Item[i].Equip := 0;
								WFIFOB(6, 1);
								Socket.SendBuf(buf, 7);
                                remove_equipcard_skills(tc, i);
							end;
						end;
					end;
					tc.Item[w1].Equip := tc.Item[w1].Data.Loc;

					if tc.Item[w1].Data.IType = 10 then begin
						WFIFOW(0, $013b);
						WFIFOW(2, 3);
						Socket.SendBuf(buf, 4);
						WFIFOW(0, $013c);
						WFIFOW(2, w1);
						Socket.SendBuf(buf, 4);
					end else begin
						//equip wep
						//if (tc.Item[w1].Data.IType <> 0) then begin
						//WFIFOW(0, $013b);
						//WFIFOW(2, 3);
						//Socket.SendBuf(buf, 4);
						//end;
						WFIFOW(0, $00aa);
						WFIFOW(2, w1);
						WFIFOW(4, tc.Item[w1].Data.Loc);
						WFIFOB(6, 1);
						Socket.SendBuf(buf, 7);
					end;
				end;

				CalcStat(tc);
				SendCSkillList(tc);

				// Recalculate stats with sprite update
				SendCStat(tc, true);
			end;
		//--------------------------------------------------------------------------
		$00ab: //�A�C�e����������
			begin
{���BNPC�@�\�ǉ�}
				//�������b�N�`�F�b�N
				if tc.EqLock = true then continue;
{���BNPC�@�\�ǉ��R�R�܂�}
				RFIFOW(2, w);
        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + IntToStr(tc.Item[w].Equip));
				if tc.Item[w].Equip = 32768 then begin
					tc.Item[w].Equip := 0;
					WFIFOW(0, $013c);
					WFIFOW(2, 0);
					Socket.SendBuf(buf, 4);

                                // Tumy
				end else begin
                				reset_skill_effects(tc);
                               WFIFOW(0, $00ac);
                               WFIFOW(2, w);
                               WFIFOW(4, tc.Item[w].Equip);
                               tc.Item[w].Equip := 0;
                               WFIFOB(6, 1);
                               Socket.SendBuf(buf, 7);
                               remove_equipcard_skills(tc, w);
                            end;

            CalcStat(tc);
            SendCSkillList(tc);
            SendCStat(tc, true);
            // Tumy

			end;
		//--------------------------------------------------------------------------
		$00b2: // Character Select or Return to Save.
			begin
				RFIFOB(2, b);
				case b of
				0:
					begin
						if tc.Sit <> 1 then continue;
						SendCLeave(tc, 0);
						tc.Map := tc.SaveMap;
						tc.Point := tc.SavePoint;
						MapMove(Socket, tc.Map, tc.Point);
					end;
				1:
					begin
                    	if not check_attack_lag(tc) then begin

                        iscs_console_disconnect(tc);
                        //DataSave();

						SendCLeave(Socket.Data, 2);

						WFIFOW(0, $00b3);
						WFIFOB(2, 1);
						Socket.SendBuf(buf, 3);
                        end;
					end;
				end;

                tc.guild_storage := False;

			end;
		//--------------------------------------------------------------------------
		$00b8: //NPC��b�őI������I������
			begin
				RFIFOL(2, l);
				if tc.TalkNPCID <> l then continue;
				RFIFOB(6, b);
				NPCScript(tc, b);
			end;
		//--------------------------------------------------------------------------
		$00b9: //NPC��b��NEXT��I������
			begin
				RFIFOL(2, l);
				if tc.TalkNPCID <> l then continue;
				NPCScript(tc);
			end;
		//--------------------------------------------------------------------------
		$00bb: //�X�e�[�^�X�A�b�v�v��
			begin
				RFIFOW(2, w);
				RFIFOB(4, b);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + '	amount = ' + IntToStr(b));
				w := w - 13;
				if (tc.ParamBase[w] < 100) and (tc.StatusPoint >= tc.ParamUp[w]) then begin
					Inc(tc.ParamBase[w]);
					b := tc.ParamBase[w];
          b1 := tc.ParamUp[w];  // Save temp value to compare later
					Dec(tc.StatusPoint, tc.ParamUp[w]);
				end else begin
					b := 0;
				end;
				WFIFOW(0, $00bc);
				WFIFOW(2, 13 + w);
				if b <> 0 then begin
					WFIFOB(4, 0);
					WFIFOB(5, b);
					Socket.SendBuf(buf, 6);
                                                  
					SendCStat(tc);
					CalcStat(tc);

          {Colus, 20030113: Update points-to-level up display if needed}
          if (tc.ParamUp[w] > b1) then begin
            WFIFOW(0, $00be);
            WFIFOW(2, 32 + w);
            WFIFOB(4, tc.ParamUp[w]);
            Socket.SendBuf(buf, 5);
          end;
				end else begin
					WFIFOB(4, 1);
					WFIFOB(5, tc.ParamBase[w]);//�C���ӏ�
					Socket.SendBuf(buf, 6);
				end;

			end;
		//--------------------------------------------------------------------------
		$00bf: // Display an emotion.
			begin
				tm := tc.MData;

				RFIFOB(2, b);
				if (tc.Skill[1].Lv < 2) and (not DisableSkillLimit) then begin
          w := tc.MSkill;
          // This is for a basic skill.
          tc.MSkill := 1;
          SendSkillError(tc, 0, 1);
          tc.MSkill := w;
        end else begin
  				WFIFOW(0, $00c0);
  				WFIFOL(2, tc.ID);
  				WFIFOB(6, b);
          SendBCmd(tm, tc.Point, 7);
        end;

			end;
		//--------------------------------------------------------------------------
		$00c1: //login�l���₢���킹
			begin
				WFIFOW(0, $00c2);
				WFIFOL(2, NowUsers);
				Socket.SendBuf(buf, 6);
			end;
		//--------------------------------------------------------------------------
		$00c5: //shop buy/sell�I��
			begin
				tm := tc.MData;
				RFIFOL(2, l);
				RFIFOB(6, b);
				if tm.NPC.IndexOf(l) <> -1 then begin
					tn := tm.NPC.IndexOfObject(l) as TNPC;
					if tn.CType = 1 then begin
						tc.TalkNPCID := l;
						case b of
						0: //buy
							begin
								WFIFOW(0, $00c6);
								WFIFOW(2, 4 + Length(tn.ShopItem) * 11);
								for i := 0 to Length(tn.ShopItem) - 1 do begin
									WFIFOL( 4 +i*11, tn.ShopItem[i].Price);
									if tc.Skill[37].Lv <> 0 then begin
                                        if (tn.ShopItem[i].Price) < 100 then begin
                                            l := ( ( tn.ShopItem[i].Price * cardinal(tc.Skill[37].Data.Data1[tc.Skill[37].Lv]) ) div 100 );
                                        end else begin
                                            l := ( ( tn.ShopItem[i].Price div 100 ) * cardinal(tc.Skill[37].Data.Data1[tc.Skill[37].Lv]) );
                                        end;
										if l = 0 then	l := 1;
                                                                        end else if tc.Skill[224].Lv <> 0 then begin
                                        if (tn.ShopItem[i].Price) < 100 then begin
                                            l := ( ( tn.ShopItem[i].Price * cardinal(tc.Skill[224].Data.Data1[tc.Skill[224].Lv]) ) div 100 );
                                        end else begin
                                            l := ( ( tn.ShopItem[i].Price div 100 ) * cardinal(tc.Skill[224].Data.Data1[tc.Skill[224].Lv]) );
                                        end;
										if l = 0 then	l := 1;
									end else begin
										l := tn.ShopItem[i].Price;
									end;
									WFIFOL( 8 +i*11, l);
									WFIFOB(12 +i*11, tn.ShopItem[i].Data.IType);
									WFIFOW(13 +i*11, tn.ShopItem[i].ID);
								end;
								Socket.SendBuf(buf, 4 + Length(tn.ShopItem) * 11);
							end;
						1: //sell
							begin
								WFIFOW(0, $00c7);
								w := 0;
								for i := 1 to 100 do begin
									if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount > 0) and (tc.Item[i].Equip = 0) then begin
										WFIFOW( 4+ w*10, i);
										WFIFOL( 6+ w*10, tc.Item[i].Data.Price div 2);
										if tc.Skill[38].Lv <> 0 then begin
											l := tc.Item[i].Data.Price div 2 * cardinal(tc.Skill[38].Data.Data1[tc.Skill[38].Lv]) div 100;
										end else begin
											l := tc.Item[i].Data.Price div 2;
										end;
										WFIFOL(10+ w*10, l);
										Inc(w);
									end;
								end;
								WFIFOW(2, 4 + w * 10);
								Socket.SendBuf(buf, 4 + w * 10);
							end;
						end;
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$00c8: // Send Request to Buy Item from NPC Shop
			begin
				tm := tc.MData;
				tn := tm.NPC.IndexOfObject(tc.TalkNPCID) as TNPC;
				if (tn.Map <> tc.Map) or (abs(tn.Point.X - tc.Point.X) > 15)
															or (abs(tn.Point.Y - tc.Point.Y) > 15) then begin
					// Can't buy from NPCs on other maps/too far away
					continue;
				end;
				RFIFOW(2, w);
				l := 0;
				weight := 0;
				k := -1;
				SetLength(ww, ((w - 4) div 4), 2);
        i1 := 0; // This is the count of actual items being bought
				for i := 0 to ((w - 4) div 4) - 1 do begin
					RFIFOW(4 + i*4, w1);
					RFIFOW(6 + i*4, w2);
          if (w1 = 0) or (w2 = 0) then continue;
					ww[i][0] := w1;
					ww[i][1] := w2;
					k := -1;
					for j := 0 to Length(tn.ShopItem) - 1 do begin
						if tn.ShopItem[j].ID = w2 then begin
							k := j;
							if tc.Skill[37].Lv <> 0 then begin
								l := l + (tn.ShopItem[j].Price * cardinal(tc.Skill[37].Data.Data1[tc.Skill[37].Lv]) div 100) * w1;
							end else if tc.Skill[224].Lv <> 0 then begin
								l := l + (tn.ShopItem[j].Price * cardinal(tc.Skill[224].Data.Data1[tc.Skill[224].Lv]) div 100) * w1;
							end else begin
								l := l + tn.ShopItem[j].Price * w1;
							end;
							weight := weight + cardinal(tn.ShopItem[j].Data.Weight) * cardinal(w1);
              Inc(i1);
							break;
						end;
					end;
					if k = -1 then break;
				end;

        // Was anything actually bought?
        if (i1 = 0) then continue;
        
				if tc.Zeny < l then begin
					// Insufficient Zeny message
					WFIFOW(0, $00ca);
					WFIFOB(2, 1);
					Socket.SendBuf(buf, 3);
					{// Overweight message (should not be sent here, and isn't?)
					WFIFOW(0, $00ca);
					WFIFOB(2, 2);	//1=Not enough zeny, 2=Overweight, 3=Maximum item capacity reached?
					Socket.SendBuf(buf, 3);}
				end else if k <> -1 then begin
					for k := 0 to ((w - 4) div 4) - 1 do begin
						td := nil;
						for j := 0 to Length(tn.ShopItem) - 1 do begin
							if tn.ShopItem[j].ID = ww[k][1] then begin
								td := tn.ShopItem[j].Data;
								if tc.Skill[37].Lv <> 0 then begin
									l := (tn.ShopItem[j].Price * cardinal(tc.Skill[37].Data.Data1[tc.Skill[37].Lv]) div 100);
								end else if tc.Skill[224].Lv <> 0 then begin
									l := (tn.ShopItem[j].Price * cardinal(tc.Skill[224].Data.Data1[tc.Skill[224].Lv]) div 100);
								end else begin
									l := tn.ShopItem[j].Price;
								end;
								if l = 0 then l := 1;
								l := l * ww[k][0];
								break;
							end;
						end;

						if td = nil then continue;

            // AlexKreuz - 12/19/2003.
            // Added to prevent overweight NPC purchases.
            if (cardinal(td.Weight * ww[k][0]) > tc.MaxWeight - tc.Weight) then begin
					    WFIFOW(0, $00ca); // "You are over the weight limit"
					    WFIFOB(2, 2);
					    Socket.SendBuf(buf, 3);
            end

            else begin
  						j := SearchCInventory(tc, ww[k][1], td.IEquip);
  						if j <> 0 then begin
  							// Give each bought item to the character
	  						tc.Item[j].ID := ww[k][1];
		  					tc.Item[j].Amount := tc.Item[j].Amount + ww[k][0];
			  				tc.Item[j].Equip := 0;
				  			tc.Item[j].Identify := 1;
					  		tc.Item[j].Refine := 0;
  							tc.Item[j].Attr := 0;
	  						tc.Item[j].Card[0] := 0;
		  					tc.Item[j].Card[1] := 0;
			  				tc.Item[j].Card[2] := 0;
				  			tc.Item[j].Card[3] := 0;
					  		tc.Item[j].Data := td;

  							tc.Weight := tc.Weight + td.Weight * ww[k][0];
	  						tc.Zeny := tc.Zeny - l;
		  					SendCGetItem(tc, j, ww[k][0]);

      					// Update weight
      			 		SendCStat1(tc, 0, $0018, tc.Weight);
      					// Update zeny
      					SendCStat1(tc, 1, $0014, tc.Zeny);
      					// Send buy success message
      					WFIFOW(0, $00ca);
      					WFIFOB(2, 0);
      					Socket.SendBuf(buf, 3);
  						end else begin
                // This says something about no further processing (process time: not yet)?
  							//����ȏ���ĂȂ�(���̏����F��)
	  					end;
            end;
					end;
				end else begin
          // 'A cheating situation: Trying to buy from a nonexistent shop?'
					//�s���ȏ����i�X�ɂȂ����̂𔃂����Ƃ����j
					WFIFOW(0, $00ca);
					WFIFOB(2, 3);  // 'You have reached the maximum capacity' message?
					Socket.SendBuf(buf, 3);
				end;
			end;
		//--------------------------------------------------------------------------
		$00c9: //NPC�̂��X�ɔ���
			begin
				tm := tc.MData;
				tn := tm.NPC.IndexOfObject(tc.TalkNPCID) as TNPC;
				if (tn.Map <> tc.Map) or (abs(tn.Point.X - tc.Point.X) > 15)
															or (abs(tn.Point.Y - tc.Point.Y) > 15) then begin
					//���E�̊O��NPC�ɂ͔���Ȃ�
					continue;
				end;
				RFIFOW(2, w);
				for i := 1 to (w - 4) div 4 do begin
					RFIFOW(0+i*4, w1);
					RFIFOW(2+i*4, w2);
					if (tc.Item[w1].ID <> 0) and (tc.Item[w1].Amount >= w2) and (tc.Item[w1].Equip = 0) then begin
						td := tc.Item[w1].Data;
						if tc.Skill[38].Lv <> 0 then begin
							l := (td.Price div 2 * cardinal(tc.Skill[38].Data.Data1[tc.Skill[38].Lv]) div 100) * w2;
						end else begin
							l := td.Price div 2 * w2;
						end;
						tc.Weight := tc.Weight - td.Weight * w2;
						tc.Zeny := tc.Zeny + l;
						//�A�C�e��������
						WFIFOW( 0, $00af);
						WFIFOW( 2, w1);
						WFIFOW( 4, w2);
						Socket.SendBuf(buf, 6);
						Dec(tc.Item[w1].Amount, w2);
						if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
					end;
				end;
				//Update weight
        SendCStat1(tc, 0, $0018, tc.Weight);
				//Update zeny
        SendCStat1(tc, 1, $0014, tc.Zeny);
				//������ł��܂���
				WFIFOW(0, $00cb);
				WFIFOB(2, 0);
				Socket.SendBuf(buf, 3);
			end;
		//--------------------------------------------------------------------------
{�`���b�g���[���@�\�ǉ�}
		$00d5: //�`���b�g���[���쐬
			begin
				if (tc.Skill[1].Lv < 4) and (not DisableSkillLimit) then begin
					i := 1;
          w := tc.MSkill;
          tc.MSkill := 1;
          SendSkillError(tc, 0, 3);
          tc.MSkill := w;
          continue;
				end else if (tc.VenderID <> 0) then begin
					i := 1;
				end else begin
					tcr := TChatRoom.Create;
					RFIFOW(2, w);
					tcr.Title := RFIFOS(15, w - 15);
					RFIFOW(4, tcr.Limit);
					RFIFOB(6, tcr.Pub);
					tcr.Pass := RFIFOS(7, 8);

					tcr.MemberID[0] := tc.ID; //�I�[�i�[:0
					tcr.MemberCID[0] := tc.CID;
					tcr.MemberName[0] := tc.Name;
					ChatMaxID := ChatMaxID + 1;
					tcr.ID := ChatMaxID;
					tcr.Users := 1;

					tc.ChatRoomID := tcr.ID;
					ChatRoomList.AddObject(tcr.ID, tcr);
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('ChatRoomTitle = %s : OwnerID = %d : OwnerName = %s', [tcr.Title, tcr.MemberID[0], tcr.MemberName[0]]));
					i := 0;
        end;

        //�`���b�g���[���쐬���ۉ���
				WFIFOW( 0, $00d6);
				WFIFOB( 2, i);         // 0:���� 1:���s
				Socket.SendBuf(buf, 3);

        if i = 0 then begin
					//���ӂɃp�P���M
                                        if tcr = nil then exit;
					w := Length(tcr.Title);
					WFIFOW(0, $00d7);
					WFIFOW(2, w + 17);
					WFIFOL(4, tcr.MemberID[0]);
					WFIFOL(8, tcr.ID);
					WFIFOW(12, tcr.Limit);
					WFIFOW(14, tcr.Users);
					WFIFOB(16, tcr.Pub);
					WFIFOS(17, tcr.Title, w);
					SendNCrCmd(tc.MData, tc.Point, w + 17, tc, true);
				end;
			end;
		//--------------------------------------------------------------------------
		$00d9: //�`���b�g�Q��
			begin
				if (tc.ChatRoomID <> 0) then continue;
				RFIFOL(2, l);
				str := RFIFOS(6, 8);
				i := ChatRoomList.IndexOf(l);
				if (i <> -1) then begin
					tcr := ChatRoomList.Objects[i] as TChatRoom;
					k := -1;
					if (tcr.Pub = 0) and (tcr.Pass <> str) then begin
						//�p�X���[�h�ԈႢ
						k := 1;
					end else if (tcr.Users >= tcr.Limit) then begin
						//�l������
						k := 0;
					end else begin
						//Kick�`�F�b�N
						j := tcr.KickList.IndexOf(tc.CID);
						if (j <> -1) then begin
							k := 2;
						end;
					end;
					if k <> -1 then begin
						WFIFOW( 0, $00da);
						WFIFOB( 2, k);
						Socket.SendBuf(buf, 3);
						continue;
					end;

					//�V�����o�[�̃f�[�^�ǉ�
					tcr.MemberID[tcr.Users] := tc.ID;
					tcr.MemberCID[tcr.Users] := tc.CID;
					tcr.MemberName[tcr.Users] := tc.Name;
					tcr.Users := tcr.Users + 1;
					tc.ChatRoomID := tcr.ID;

					//���[���������o�[�ɐV�K�Q���Ғʒm
					WFIFOW( 0, $00dc);
					WFIFOW( 2, tcr.Users);
					WFIFOS( 4, tc.Name, 24);
					SendCrCmd(tc, 28);

					//���[�����̊��������o�[���X�g
					WFIFOW( 0, $00db);
					w := 8 + tcr.Users * 28;
					WFIFOW( 2, w);
					WFIFOL( 4, tcr.ID);
					for j := 0 to tcr.Users -1 do begin
						WFIFOL( 8+j*28, j);
						WFIFOS( 12+j*28, tcr.MemberName[j], 24);
					end;
					Socket.SendBuf(buf, w);

					//�`���b�g�X�e�[�^�X�ύX�����͂ɒʒm
					w := Length(tcr.Title);
					WFIFOW(0, $00d7);
					WFIFOW(2, w + 17);
					WFIFOL(4, tcr.MemberID[0]);
					WFIFOL(8, tcr.ID);
					WFIFOW(12, tcr.Limit);
					WFIFOW(14, tcr.Users);
					WFIFOB(16, tcr.Pub);
					WFIFOS(17, tcr.Title, w);
					SendNCrCmd(tc.MData, tc.Point, w + 17, tc, true);
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Join = %s / RoomTitle = %s / Users = %d', [tc.Name, tcr.Title, tcr.Users]));
{NPC�C�x���g�ǉ�}
					if (tcr.NPCowner <> 0) and (tcr.Limit = tcr.Users) then begin
						tc1 := TChara.Create;
						tm := tc.MData;
						tn := tm.NPC.IndexOfObject(tcr.MemberID[0]) as TNPC;
						tc1.TalkNPCID := tn.ID;
						for j := 0 to tn.ScriptCnt - 1 do begin
							k := -1;
							if (tn.Script[j].ID = 39) then begin
								k := tn.Script[j].Data3[1];
								break;
							end;
						end;
						if (k <> -1) then begin
							tc1.ScriptStep := k;
							tc1.AMode := 3;
							tc1.AData := tn;
							tc1.Login := 0;
							NPCScript(tc1,0,1);
						end;
						tc1.Free;
					end;
{NPC�C�x���g�ǉ��R�R�܂�}
				end;
			end;
		//--------------------------------------------------------------------------
		$00de: //�`���b�g���[���̃X�e�[�^�X�ύX
			begin
				i := ChatRoomList.IndexOf(tc.ChatRoomID);
				if (i <> -1) then begin
					tcr := ChatRoomList.Objects[i] as TChatRoom;
					if (tc.ID = tcr.MemberID[0]) then begin
						RFIFOW(2, w);
						tcr.Title := RFIFOS(15, w - 15);
						RFIFOW(4, tcr.Limit);
						RFIFOB(6, tcr.Pub);
						tcr.Pass := RFIFOS(7, 8);

						//�X�e�[�^�X�ύX�p�P���M
						w := Length(tcr.Title);
						WFIFOW(0, $00df);
						WFIFOW(2, w + 17);
						WFIFOL(4, tcr.MemberID[0]);
						WFIFOL(8, tcr.ID);
						WFIFOW(12, tcr.Limit);
						WFIFOW(14, tcr.Users);
						WFIFOB(16, tcr.Pub);
						WFIFOS(17, tcr.Title, w);
						SendCrCmd(tc, w + 17);
						WFIFOW(0, $00d7);
						SendNCrCmd(tc.MData, tc.Point, w + 17, tc, true);
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$00e0: //�`���b�g���[���̃I�[�i�[�ύX
			begin
				str := RFIFOS(6, 24);
				i := ChatRoomList.IndexOf(tc.ChatRoomID);
				if (i <> -1) then begin
					//�����o�[����
					tcr := ChatRoomList.Objects[i] as TChatRoom;
					if (tc.ID = tcr.MemberID[0]) then begin
						j := -1;
						for i := 1 to 19 do begin;
							if str = tcr.MemberName[i] then begin
								j := i;
								break;
							end;
						end;

						if (j <> -1) then begin
							//�I�[�i�[�ύX
							tcr.MemberID[0] := tcr.MemberID[j];
							tcr.MemberID[j] := tc.ID;
							tcr.MemberCID[0] := tcr.MemberCID[j];
							tcr.MemberCID[j] := tc.CID;
							tcr.MemberName[j] := tc.Name;
							tcr.MemberName[0] := str;

							//�����o�[�ɕύX�ʒm
							WFIFOW( 0, $00e1);
							WFIFOL( 2, j);
							WFIFOS( 6, tcr.MemberName[j], 24);
							SendCrCmd(tc, 30);
							WFIFOW( 0, $00e1);
							WFIFOL( 2, 0);
							WFIFOS( 6, tcr.MemberName[0], 24);
							SendCrCmd(tc, 30);

							//�I�[�i�[�ύX�`���b�g����
							WFIFOW( 0, $00d8);
							WFIFOL( 2, tcr.ID);
							SendNCrCmd(tc.MData, tc.Point, 6, tc, true);

							//���ӂɃI�[�i�[�ύX�ʒm
							w := Length(tcr.Title);
							WFIFOW(0, $00d7);
							WFIFOW(2, w + 17);
							WFIFOL(4, tcr.MemberID[0]);
							WFIFOL(8, tcr.ID);
							WFIFOW(12, tcr.Limit);
							WFIFOW(14, tcr.Users);
							WFIFOB(16, tcr.Pub);
							WFIFOS(17, tcr.Title, w);
							SendNCrCmd(tc.MData, tc.Point, w + 17, tc, true);
						end;
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$00e2: //�����o�[kick
			begin
				str := RFIFOS(2, 24);
				i := ChatRoomList.IndexOf(tc.ChatRoomID);
				if (i <> -1) then begin
					//�����o�[����
					tcr := ChatRoomList.Objects[i] as TChatRoom;
					if (tc.ID = tcr.MemberID[0]) then begin
						j := -1;
						for i := 1 to 19 do begin;
							if str = tcr.MemberName[i] then begin
								j := i;
								break;
							end;
						end;

						if (j <> -1) then begin
							tc1 := Chara.IndexOfObject(tcr.MemberCID[j]) as TChara;
							if (tc1 <> nil) then begin
								//�����o�[�폜
								ChatRoomExit(tc1);
							end;
							//Kick���X�g�ɒǉ�
							tcr.KickList.Add(tc1.CID);
						end;
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$00e3: //�`���b�g���[������
			begin
				ChatRoomExit(tc);
			end;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{����@�\�ǉ�}
		//--------------------------------------------------------------------------
		$00e4: //����v��
			begin
        // Can you even do it?
				if (tc.Skill[1].Lv = 0) and (not DisableSkillLimit) then begin
          w := tc.MSkill;
          tc.MSkill := 1;
          SendSkillError(tc, 0, 0);
          tc.MSkill := w;
          continue;
        end;

				RFIFOL(2, l);
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				b := 0;

				if (tc1 = nil) then begin
					b := 1; // Invalid player.
				end else if (tc1.Map <> tc.Map) or (abs(tc1.Point.X - tc.Point.X) > 5)
					or (abs(tc1.Point.Y - tc.Point.Y) > 5) then begin
					b := 0; // Too far away.
				end else if (tc1.DealingID <> 0) or (tc1.PreDealID <> 0) then begin
					b := 2; // Already in another trade.
        end else if (tc1.Skill[1].Lv = 0) and (not DisableSkillLimit) then begin
          b := 4; // Failed (due to no basic skills!)
				end else begin
					tc.PreDealID := tc1.ID;
					tc1.PreDealID := tc.ID;
					//����v���ʒm
					WFIFOW(0, $00e5);
					WFIFOS(2, tc.Name, 24);
					tc1.Socket.SendBuf(buf, 26);
					continue;
				end;
				//����v���G���[
				WFIFOW(0, $00e7);
				WFIFOB(2, b);
				Socket.SendBuf(buf, 3);
			end;
		//--------------------------------------------------------------------------
		$00e6: //����v������
			begin
				RFIFOB(2, b);
				tc1 := CharaPID.IndexOfObject(tc.PreDealID) as TChara;
				if (tc1 = nil) then begin
					//����L�����s����
					tc.PreDealID := 0;
					WFIFOW(0, $00e7);
					WFIFOB(2, 1);
					Socket.SendBuf(buf, 3);
				end else if (b = 3) or (b = 4) then begin
					//�v���ԓ�(3=yes,4=no)
					tc.PreDealID := 0;
					tc1.PreDealID := 0;
					WFIFOW(0, $00e7);
					WFIFOB(2, b);
					Socket.SendBuf(buf, 3);
					tc1.Socket.SendBuf(buf, 3);
					//���ݑq�ɍ쐬
					if (b = 3) then begin
						tdl := TDealings.Create;
						DealMaxID := DealMaxID + 1;
						tdl.ID := DealMaxID;
						tc.DealingID := tdl.ID;
						tc1.DealingID := tdl.ID;
						tdl.UserID[0] := tc1.ID;
						tdl.USerID[1] := tc.ID;
						DealingList.AddObject(tdl.ID, tdl);
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('StartDealing ID = %d : Char1 = %S : Char2 = %s', [tdl.ID, tc1.Name, tc.Name]));
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$00e8: //�A�C�e���ǉ�
			begin
				if (tc.DealingID = 0) then continue;
				i := DealingList.IndexOf(tc.DealingID);
				if (i = -1) then continue;
				tdl:= DealingList.Objects[i] as TDealings;
				if (tdl.UserID[0] = tc.ID) then begin
					w1 := 0;
					w2 := 1;
				end else begin
					w1 := 1;
					w2 := 0;
				end;
				if (tdl.Mode[w1] <> 0) then continue;//����OK��
				tc1 := CharaPID.IndexOfObject(tdl.UserID[w2]) as TChara;
				if (tc1 = nil) then continue;

				RFIFOW(2, w);
				RFIFOL(4, l);
				if (w <> 0) then begin
					//�A�C�e���`�F�b�N
					if (tc.Item[w].ID <> 0) and (tc.Item[w].Amount >= l) then begin
						td := tc.Item[w].Data;
						if (cardinal(td.Weight * l) > tc1.MaxWeight - tc1.Weight) then begin
							//������d�ʃI�[�o�[//100��ވȏ�`�F�b�N����
							WFIFOW( 0, $00ea);
							WFIFOW( 2, w);
							WFIFOB( 4, 1);
							Socket.SendBuf(buf, 5);
						end else begin
							//���ݑq�ɂɃA�C�e���ǉ�
							tdl.ItemIdx[w1][tdl.Cnt[w1]] := w;
							tdl.Amount[w1][tdl.Cnt[w1]] := l;
							tdl.Cnt[w1] := tdl.Cnt[w1] + 1;
							//�A�C�e���񎦐����p�P
							WFIFOW( 0, $00ea);
							WFIFOW( 2, w);
							WFIFOB( 4, 0);
							Socket.SendBuf(buf, 5);
							//������ɃA�C�e���񎦃p�P
							WFIFOW( 0, $00e9);
							WFIFOL( 2, l);
							WFIFOW( 6, td.ID);
							WFIFOB( 8, tc.Item[w].Identify);
							WFIFOB( 9, tc.Item[w].Attr);
							WFIFOB(10, tc.Item[w].Refine);
							WFIFOW(11, tc.Item[w].Card[0]);
							WFIFOW(13, tc.Item[w].Card[1]);
							WFIFOW(15, tc.Item[w].Card[2]);
							WFIFOW(17, tc.Item[w].Card[3]);
							tc1.Socket.SendBuf(buf, 19);
						end;
					end;
				end else begin
					//�[�j�[�`�F�b�N
					if (tc.Zeny < l) then l := tc.Zeny;
					//���ݑq�ɂɃ[�j�[�ǉ�
					tdl.Zeny[w1] := l;
					//�A�C�e���񎦐����p�P
					WFIFOW( 0, $00ea);
					WFIFOW( 2, 0);
					WFIFOB( 4, 0);
					Socket.SendBuf(buf, 5);
					//�[�j�[�񎦃p�P
					ZeroMemory(@buf[0], 19);
					WFIFOW( 0, $00e9);
					WFIFOL( 2, l);
					WFIFOB( 8, 1);
					tc1.Socket.SendBuf(buf, 19);
				end;
			end;
		//--------------------------------------------------------------------------
		$00eb: //�A�C�e���ǉ�����
			begin
				if (tc.DealingID = 0) then continue;
				i := DealingList.IndexOf(tc.DealingID);
				if (i = -1) then continue;
				tdl:= DealingList.Objects[i] as TDealings;
				if (tdl.UserID[0] = tc.ID) then begin
					w1 := 0;
					w2 := 1;
				end else begin
					w1 := 1;
					w2 := 0;
				end;
				tc1 := CharaPID.IndexOfObject(tdl.UserID[w2]) as TChara;
				if (tc1 = nil) then continue;

				tdl.Mode[w1] := 1;
				//�ǉ������p�P
				WFIFOW(0, $00ec);
				WFIFOB(2, 0);
				Socket.SendBuf(buf, 3);
				WFIFOW(0, $00ec);
				WFIFOB(2, 1);
				tc1.Socket.SendBuf(buf, 3);
			end;
		//--------------------------------------------------------------------------
		$00ed: //����L�����Z��
			begin
				CancelDealings(tc);
			end;
		//--------------------------------------------------------------------------
		$00ef: //�������
			begin
				if (tc.DealingID = 0) then continue;
				i := DealingList.IndexOf(tc.DealingID);
				if (i = -1) then continue;
				tdl:= DealingList.Objects[i] as TDealings;
				if (tdl.UserID[0] = tc.ID) then begin
					w1 := 0;
					w2 := 1;
				end else begin
					w1 := 1;
					w2 := 0;
				end;
				if (tdl.Mode[w1] = 0) then begin
					continue;//OK����
				end else if (tdl.Mode[w1] = 1) then begin
					tdl.Mode[w1] := 2;
				end;
				if (tdl.Mode[w1] <> 2) or (tdl.Mode[w2] <> 2) then continue;//���Ҋ����҂�
				tc1 := CharaPID.IndexOfObject(tdl.UserID[w2]) as TChara;
				if (tc1 = nil) then continue;

				//�L�����P�A�C�e������
				if (tdl.Cnt[w1] > 0) then begin
					for i := 0 to tdl.Cnt[w1] - 1 do begin
						w := tdl.ItemIdx[w1][i];
						if (tc.Item[w].ID <> 0) and (tc.Item[w].Amount > 0) then begin
							td := tc.Item[w].Data;
							//����ɃA�C�e���ǉ�
							j := SearchCInventory(tc1, td.ID, td.IEquip);
							with tc.Item[w] do begin
								tc1.Item[j].ID := ID;
								tc1.Item[j].Amount := tc1.Item[j].Amount + tdl.Amount[w1][i];
								tc1.Item[j].Equip := Equip;
								tc1.Item[j].Identify := Identify;
								tc1.Item[j].Refine := Refine;
								tc1.Item[j].Attr := Attr;
								tc1.Item[j].Card[0] := Card[0];
								tc1.Item[j].Card[1] := Card[1];
								tc1.Item[j].Card[2] := Card[2];
								tc1.Item[j].Card[3] := Card[3];
								tc1.Item[j].Data := td;
							end;
							SendCGetItem(tc1, j, tdl.Amount[w1][i]);
							//����̏d�ʕύX
							tc1.Weight := tc1.Weight + cardinal(td.Weight * tdl.Amount[w1][i]);
							//�����̃A�C�e���폜
							Dec(tc.Item[w].Amount, tdl.Amount[w1][i]);
							if (tc.Item[w].Amount = 0) then tc.Item[w].ID := 0;
							//�����̏d�ʕύX
							tc.Weight := tc.Weight - cardinal(td.Weight * tdl.Amount[w1][i]);
						end;
					end;
				end;

				//�L�����Q�A�C�e������
				if (tdl.Cnt[w2] > 0) then begin
					for i := 0 to tdl.Cnt[w2] - 1 do begin
						w := tdl.ItemIdx[w2][i];
						if (tc1.Item[w].ID <> 0) and (tc1.Item[w].Amount > 0) then begin
							td := tc1.Item[w].Data;
							//����ɃA�C�e���ǉ�
							j := SearchCInventory(tc, td.ID, td.IEquip);
							with tc1.Item[w] do begin
								tc.Item[j].ID := ID;
								tc.Item[j].Amount := tc.Item[j].Amount + tdl.Amount[w2][i];
								tc.Item[j].Equip := Equip;
								tc.Item[j].Identify := Identify;
								tc.Item[j].Refine := Refine;
								tc.Item[j].Attr := Attr;
								tc.Item[j].Card[0] := Card[0];
								tc.Item[j].Card[1] := Card[1];
								tc.Item[j].Card[2] := Card[2];
								tc.Item[j].Card[3] := Card[3];
								tc.Item[j].Data := td;
							end;
							SendCGetItem(tc, j, tdl.Amount[w2][i]);
							//����̏d�ʕύX
							tc.Weight := tc.Weight + cardinal(td.Weight * tdl.Amount[w2][i]);
							//�����̃A�C�e���폜
							Dec(tc1.Item[w].Amount, tdl.Amount[w2][i]);
							if (tc1.Item[w].Amount = 0) then tc1.Item[w].ID := 0;
							//�����̏d�ʕύX
							tc1.Weight := tc1.Weight - cardinal(td.Weight * tdl.Amount[w2][i]);
						end;
					end;
				end;

				if (tdl.Zeny[w1] <> 0) or (tdl.Zeny[w2] <> 0) then begin
          // Update zeny for trade partners
					tc.Zeny := tc.Zeny - tdl.Zeny[w1] + tdl.Zeny[w2];
          SendCStat1(tc, 1, $0014, tc.Zeny);

					tc1.Zeny := tc1.Zeny - tdl.Zeny[w2] + tdl.Zeny[w1];
          SendCStat1(tc1, 1, $0014, tc1.Zeny);
				end;

        // Update players' weights
        SendCStat1(tc, 0, $0018, tc.Weight);
        SendCStat1(tc1, 0, $0018, tc1.Weight);

				//��������p�P
				WFIFOW(0, $00f0);
				WFIFOB(2, 0);
				tc.Socket.SendBuf(buf, 3);
				tc1.Socket.SendBuf(buf, 3);

				tc.DealingID := 0;
				tc1.DealingID := 0;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Dealings(%d) was completed / Remaining Dealings(%d)', [tdl.ID,DealingList.Count-1]));
				DealingList.Delete(DealingList.IndexOf(tdl.ID));
				tdl.Free;
			end;
{����@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		$00f3: // Add Item to Storage
			begin

				RFIFOW(2, w1);
				RFIFOL(4, l);

                if (l > 30000) then l := 30000;
				w2 := l;

                if (tc.Item[w1].ID = 0) or (tc.Item[w1].Amount < w2) then Continue;

                if tc.guild_storage then begin
                    if GuildList.IndexOf(tc.GuildID) = -1 then Continue;
                    tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;

                    i := addto_storage(tc, tg.Storage.Item, tg.Storage.Count, w1, w2);

                    if (i = -1) then Exit
                    else tg.Storage.Count := i;

                    Inc(tg.Storage.Weight, (tc.Item[w1].Data.Weight * w2));
                end else begin
                    tp := tc.PData;

                    i := addto_storage(tc, tp.Kafra.Item, tp.Kafra.Count, w1, w2);

                    if (i = -1) then Exit
                    else tp.Kafra.Count := i;

                    Inc(tp.Kafra.Weight, (tc.Item[w1].Data.Weight * w2));
				end;

				tc.Weight := tc.Weight - tc.Item[w1].Data.Weight * w2;
				SendCStat1(tc, 0, $0018, tc.Weight);

			end;
		//--------------------------------------------------------------------------
		$00f5: // Remove item from storage
			begin

				RFIFOW(2, w1);
				RFIFOL(4, l);

				if l > 30000 then l := 30000;
				w2 := l;

                if (tc.guild_storage) then begin
                    if GuildList.IndexOf(tc.GuildID) = -1 then Continue;
                    tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;
                    weight := tg.Storage.Item[w1].Data.Weight * w2;
                    //Dec(tg.Storage.Weight, weight);
                end else begin
                    tp := tc.PData;
                    weight := tp.Kafra.Item[w1].Data.Weight * w2;
                    Dec(tp.Kafra.Weight, weight);
				end;

				if longint(tc.MaxWeight) - longint(tc.Weight) < weight then begin
					WFIFOW(0, $00ca);
					WFIFOB(2, 3);
                    tc.Socket.SendBuf(buf, 3);
				end

                else begin
                    if (tc.guild_storage) then begin
                        if GuildList.IndexOf(tc.GuildID) = -1 then Continue;
                        tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;
                        takefrom_storage(tc, tg.Storage.Item, tg.Storage.Count, l, w1-1, w2);
                    end else begin
                        tp := tc.PData;
                        takefrom_storage(tc, tp.Kafra.Item, tp.Kafra.Count, l, w1-1, w2);
                    end;
                end;

			end;
		//--------------------------------------------------------------------------
		$00f7: // Close storage
			begin
				tc.AMode := 0;
				WFIFOW( 0, $00f8);
				Socket.SendBuf(buf, 2);

                tc.guild_storage := False;
			end;
		//--------------------------------------------------------------------------
		$00f9: // Request to organize a party - NOTE, 01e8 is updated version
			begin
				str := RFIFOS(2, 24);
				if (tc.Skill[1].Lv < 7) and (not DisableSkillLimit) then begin
          { Mitch: Fix (Bug #394) }
          // Colus, 20040218: Are you kidding me?  Why would you use a GLOBAL
          // BROADCAST to give the party fail message?
          {str := 'You must be at least Basic Skill Level 7 to create a party!';
          w := Length(str) + 4;
          WFIFOW (0, $009a);
          WFIFOW (2, w);
          WFIFOS (4, str, w - 4);
          tc.socket.sendbuf(buf, w); }
          w := tc.MSkill;
          // This is for a basic skill.
          tc.MSkill := 1;
          SendSkillError(tc, 0, 4);
          tc.MSkill := w;
				end else begin
					if tc.PartyName <> '' then begin
						i := 2;
					end else if (str = '') or (PartyNameList.IndexOf(str) <> -1) then begin
						i := 1;
					end else begin
						//�p�[�e�B�[�����d�����Ă͂����Ȃ�
						tpa := TParty.Create;
						tpa.ID := NowPartyID;
						Inc(NowPartyID);
						tpa.Name := str;
						tpa.EXPShare := False;
						tpa.ITEMShare := True;
						tpa.MemberID[0] := tc.CID; //���[�_:0
						tpa.Member[0] := tc;
						if tc.JID = 19 then begin
							tpa.PartyBard[0] := tc;
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Bard Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
						end else if tc.JID = 20 then begin
							tpa.PartyDancer[0] := tc;
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Dancer Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
						end;
						tc.PartyName := tpa.Name;
                        tc.PartyID := tpa.ID;
						PartyNameList.AddObject(tpa.Name, tpa);
                        PartyList.AddObject(tpa.ID, tpa);
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('PartyName %s : from %d to %d : ID = %d : Name = %s', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
						SendPartyList(tc);
						i := 0;
					end;

					//�p�[�e�B�[�쐬���ۉ���
					WFIFOW( 0, $00fa);
					WFIFOB( 2, i);         // 1:�����` 2:���Ɂ`
					Socket.SendBuf(buf, 3);
				end;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('PartyNameList.Count = %d', [PartyNameList.Count]));

			end;

		//--------------------------------------------------------------------------
		$00fc: //�p�[�e�B�[���U
			begin
				RFIFOL(2, l);
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				if (tc1.PartyName = '') and ((tc1.Skill[1].Lv >= 5) or DisableSkillLimit) then begin
					WFIFOW( 0, $00fe);
					WFIFOL( 2, tc.ID);
					WFIFOS( 6, tc.PartyName, 24);
					tc1.Socket.SendBuf(buf, 30);
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Party (%s) Join Request From %s To %s', [tc.PartyName,tc.Name,tc1.Name]));
				end else begin
					WFIFOW( 0, $00fd);
					WFIFOS( 2, tc1.Name, 24);
          if (tc1.Skill[1].Lv < 5) and (not DisableSkillLimit) then
  					WFIFOB(26, 1)
          else
            WFIFOB(26, 0);
					tc.Socket.SendBuf(buf, 27);
				end;
			end;
		//--------------------------------------------------------------------------
		$00ff: //�p�[�e�B�[���U�ԓ�
			begin
				RFIFOL(2, l);
				RFIFOL(6, l2);
				j := -1;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('tc.ID = %d : l = %d', [tc.CID,l]));
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('tc.ID = %d / tc1.ID = %d / l = %d', [tc.CID,tc1.CID,l]));
				if (l2 = 0) then begin
					WFIFOW( 0, $00fd);
					WFIFOS( 2, tc.Name, 24);
					WFIFOB( 26, 1);
					tc1.Socket.SendBuf(buf, 27);
				end else begin
					tpa := PartyNameList.Objects[PartyNameList.IndexOf(tc1.PartyName)] as TParty;
					for i := 0 to 11 do begin
						if (tpa.MemberID[i] = 0) and (tpa.Member[i] = nil) then begin
							tpa.MemberID[i] := tc.CID;
							tpa.Member[i] := tc;
                                                        if tc.JID = 19 then begin
                                                                tpa.PartyBard[0] := tc;
                                                                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Bard Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
                                                        end else if tc.JID = 20 then begin
                                                                tpa.PartyDancer[0] := tc;
                                                                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Dancer Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
                                                        end;
							tc.PartyName := tpa.Name;
                            tc.PartyID := tpa.ID;
							if (tc.BaseLV < tpa.MinLV) then tpa.MinLV := tc.BaseLV;
							if (tc.BaseLV > tpa.MaxLV) then tpa.MaxLV := tc.BaseLV;
							j := i;
							break
						end;
					end;
					if (j <> -1) then begin
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('PartyName = %s / tc.ID = %d / tc1.ID = %d / slot = %d', [tpa.Name,tc.ID,tc1.ID,j]));
						SendPartyList(tc);
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$0100: //�p�[�e�B�[�E��
			begin
            	leave_party(tc);
                PD_Save_Parties_Parse(True);
			end;
		//--------------------------------------------------------------------------
		$0102: //�p�[�e�B�[�ݒ�ύX
			begin

				RFIFOW(2, w1);
				RFIFOW(4, w2);
				if (PartyNameList.IndexOf(tc.PartyName) <> -1) then begin
					tpa := PartyNameList.Objects[PartyNameList.IndexOf(tc.PartyName)] as TParty;

					//�����\���x���̐ݒ�͂����Bini�Őݒ�ł����ق����֗����ȁH
					if (tpa.MaxLV - tpa.MinLV > Option_PartyShare_Level) then begin
						w1 := 2;
					end else begin
						tpa.EXPShare := WordBool(w1);
					end;

					tpa.ITEMShare := WordBool(w2);

					WFIFOW( 0, $0101);
					WFIFOW( 2, w1);
					WFIFOW( 6, w2);
					SendPCmd(tc,6);

					if (w1 = 2) then begin
						WFIFOW(0, $0101);
						WFIFOW(2, Word(tpa.EXPShare));
						WFIFOW(4, Word(tpa.ITEMShare));
						SendPCmd(tc, 6);
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$0103: //�p�[�e�B�[����
			begin
				RFIFOL(2, l);
				if CharaPID.IndexOf(l) <> -1 then begin
					tc1 := CharaPID.IndexOfObject(l) as TChara;
					if (PartyNameList.IndexOf(tc1.PartyName) <> -1) then begin
						tpa := PartyNameList.Objects[PartyNameList.IndexOf(tc1.PartyName)] as TParty;

						WFIFOW( 0, $0105);
						WFIFOL( 2, tc1.CID);
						WFIFOS( 6, tc1.Name , 24);
						WFIFOB( 30, 1);
						SendPCmd(tc1,31);

						tc1.PartyName := '';
                        tc1.PartyID := 0;

						j := -1;
						for i := 0 to 11 do begin;
							if tc1.CID = tpa.MemberID[i] then begin
							j := i;
							break;
							end;
						end;

						for i := j to 10 do begin
							tpa.MemberID[i] := tpa.MemberID[i+1];
							tpa.Member[i] := tpa.Member[i+1];
						end;
							tpa.MemberID[11] := 0;
							tpa.Member[11] := nil;

						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s Leaves %s', [tc.Name,tpa.Name]));

						if (tpa.MemberID[0] = 0) then begin
						  if UseSQL then DeleteParty(tpa.Name);
							PartyNameList.Delete(PartyNameList.IndexOf(tpa.Name));
                            PartyList.Delete(PartyList.IndexOf(tpa.ID));
							//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('party(%s) was deleted (%d)', [tpa.Name,PartyNameList.Count]));
							tpa.Free;
						end else begin
							SendPartyList(tpa.Member[0]);
						end;
					end;
				end;
                PD_Save_Parties_Parse(True);
			end;
		//--------------------------------------------------------------------------
		$0108: //�p�[�e�B�[�`���b�g
			begin
				RFIFOW(2, w);
				str := RFIFOS(4, w - 4);
				if (PartyNameList.IndexOf(tc.PartyName) <> -1) then begin
					WFIFOW( 0, $0109);
					WFIFOW( 2, w + 4);
					WFIFOL( 4, tc.ID);
					WFIFOS( 8, str , w - 4);
					SendPCmd(tc,w + 4);
				end;
			end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		$0112: //�X�L�����x���A�b�v�v��
			begin
				RFIFOW(2, w);
{�M���h�@�\�ǉ�}
				if (w >= 10000) then begin
					//�M���h�X�L��
					j := GuildList.IndexOf(tc.GuildID);
					if (j <> -1) then begin
						tg := GuildList.Objects[j] as TGuild;
						with tg do begin
							if (GSkill[w].Lv < GSkill[w].Data.MasterLV) and (GSkillPoint > 0)
							and (tc.Name = MasterName) then begin
								GSkill[w].Lv	:= GSkill[w].Lv + 1;
								GSkillPoint	:= GSkillPoint - 1;
								if (w = 10004) then begin
									MaxUsers := 16 + GSkill[w].Data.Data1[GSkill[w].Lv];
									SendGuildInfo(tc, 0, true);
								end;
								SendGuildInfo(tc, 3, true);
							end;
						end;
					end;
				end else begin
{�M���h�@�\�ǉ��R�R�܂�}
					if (tc.Skill[w].Lv < tc.Skill[w].Data.MasterLV) and (tc.SkillPoint > 0) then begin
						tc.Skill[w].Lv	:= tc.Skill[w].Lv + 1;
						tc.SkillPoint	:= tc.SkillPoint - 1;

						WFIFOW(0, $010e);
						WFIFOW(2, w);
						WFIFOW(4, tc.Skill[w].Lv);
						WFIFOW(6, tc.Skill[w].Data.SP[tc.Skill[w].Lv]);
						WFIFOW(8, tc.Skill[w].Data.Range);
						if (tc.Skill[w].Lv < tc.Skill[w].Data.MasterLV) and (tc.SkillPoint > 0) then b := 1 else b := 0;
						WFIFOB(10, b);
						Socket.SendBuf(buf,11);
						SendCSkillList(tc);

						CalcStat(tc);
						SendCStat(tc);
					end else begin
						//���s
						WFIFOW(0, $010e);
						WFIFOW(2, w);
						WFIFOW(4, tc.Skill[w].Lv);
						WFIFOW(6, tc.Skill[w].Data.SP[tc.Skill[w].Lv]);
						WFIFOW(8, tc.Skill[w].Data.Range);
						if (tc.Skill[w].Lv < tc.Skill[w].Data.MasterLV) and (tc.SkillPoint > 0) then b := 1 else b := 0;
						WFIFOB(10, b);
						Socket.SendBuf(buf,11);
					end;
{�M���h�@�\�ǉ�}
				end;
{�M���h�@�\�ǉ��R�R�܂�}
			end;
		//--------------------------------------------------------------------------
		$0113: //�^�[�Q�b�g�w��or�u�������X�L��
			begin
            	// OK, you have to know what you're trying to cast first.  Is it
                // Cast Cancel?

                RFIFOW(4, w);
                //if ((tc.MMode <> 0) and (tc.MSkill <> 275)) then continue;   // <- Leave that in!
                //if ((tc.MMode = 0) and (tc.MTick > timeGetTime())) or (tc.MSkill = 277) then Continue;

                if (((tc.MMode <> 0) and (w <> 275)) or ((tc.MMode = 0) and ((tc.MTick > timeGetTime()) or (w = 275))) ) then continue;
                {�`���b�g���[���@�\�ǉ�}

                //�������̃X�L���g�p����
                if (tc.ChatRoomID <> 0) then continue;
                {�`���b�g���[���@�\�ǉ��R�R�܂�}
                {�I�X�X�L���ǉ�}

                //�I�X���̃X�L���g�p����
				if (tc.VenderID <> 0) then continue;
                {�I�X�X�L���ǉ��R�R�܂�}

                // Now we need to save the previous spell off somewhere to pick it up
                // when we actually perform the Cast Cancel effect.
                if (w = 275) then begin
                	tc.Skill[275].Effect1 := tc.MSkill;
                    tc.Skill[275].EffectLV := tc.MUseLV;
                end;

                RFIFOW(2, tc.MUseLV);
                tc.MSkill := w; // We already read this above... RFIFOW(4, tc.MSkill);
                RFIFOL(6, tc.MTarget);
                tc.MPoint.X := 0;
                tc.MPoint.Y := 0;

                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Use Skill:' + IntToStr(tc.MSkill));
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Use Level:' + IntToStr(tc.MUseLV));
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Target:' + IntToStr(tc.MTarget));
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Mode:' + IntToStr(tc.MMode));
                //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Use Item:' + IntToStr(tc.UseItemID));

              if (tc.Sit = 1) and (tc.MSkill = 143) then begin
				tc.SkillTick := tc.Skill[143].Tick;
				tc.SkillTickID := 143;
                tc.Sit := 3;
                exit;
              end else begin
                if (tc.Sit <> 1) or (tc.MSkill = 143) then begin
                	if (tc.MSkill = 0) or (tc.MSkill > MAX_SKILL_NUMBER) then continue;
                    {NPC�C�x���g�ǉ�}

                    i := MapInfo.IndexOf(tc.Map);
                    j := -1;
                    if (i <> -1) then begin
                    	mi := MapInfo.Objects[i] as MapTbl;
                        if ((mi.noTele = true) or (mi.noPortal = true) or (tc.Option and 6 <> 0)) then j := 0;
                    end;

                    if (tc.MSkill = 26) and (j = 0) then continue;
                    {�A�W�g�@�\�ǉ��R�R�܂�}
                    {Colus, 20040116: This whole section seems redundant...
                    RFIFOW(2, tc.MUseLV);
                    RFIFOW(4, tc.MSkill);
                    RFIFOL(6, tc.MTarget);
                    tc.MPoint.X := 0;
                    tc.MPoint.Y := 0;

                    if (tc.MSkill = 0) or (tc.MSkill > 336) then continue;
                    // Japanese comment: 'Begin agit consideration'

                    if (tc.MSkill = 26) and mi.noPortal then continue;
                    // Japanese comment: 'Agit consideration ends here.'  We rolled this into the above checks. }

                    {�C��}
                    if (tc.ver2 = 9) and (tc.MUseLV > 30) then tc.MUseLV := tc.MUseLV - 30;

                    if ((tc.Skill[tc.MSkill].Lv >= tc.MUseLV) and (tc.MUseLV > 0)) then begin
						tk := tc.Skill[tc.MSkill];
                        tl := tc.Skill[tc.MSkill].Data;

                        k := UseTargetSkill(tc,timeGetTime());
                        if k <> 0 then SendSkillError(tc,k);
                    end else if (tc.ItemSkill) then begin
                    	tk := tc.Skill[tc.MSkill];
                        tl := tc.Skill[tc.MSkill].Data;
                        k := UseTargetSkill(tc,timeGetTime());
                        if k <> 0 then SendSkillError(tc,k);
                    end;
                end;
            end;
            end;
		//--------------------------------------------------------------------------
		$0116: //�ꏊ�w��X�L��
			begin
				if tc.MMode <> 0 then continue;
        if (tc.MMode = 0) and (tc.MTick > timeGetTime()) then Continue;
{�`���b�g���[���@�\�ǉ�}
				//�������̃X�L���g�p����
				if (tc.ChatRoomID <> 0) then continue;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
				//�I�X���̃X�L���g�p����
				if (tc.VenderID <> 0) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
{�A�W�g�@�\�ǉ�}
				i := MapInfo.IndexOf(tc.Map);
				if (i <> -1) then begin
					mi := MapInfo.Objects[i] as MapTbl;
				end else begin
					mi := MapTbl.Create;
				end;
				if mi.noSkill then continue;
{�A�W�g�@�\�ǉ��R�R�܂�}

				RFIFOW(2, tc.MUseLV);
				RFIFOW(4, tc.MSkill);
				RFIFOW(6, tc.MPoint.X);
				RFIFOW(8, tc.MPoint.Y);
				tc.MTarget := 0;

				if (tc.MSkill = 0) or (tc.MSkill > MAX_SKILL_NUMBER) then continue;
{�A�W�g�@�\�ǉ�}
				if ((tc.MSkill = 27) and (mi.noTele or (tc.Option and 6 <> 0))) then continue;
{�A�W�g�@�\�ǉ��R�R�܂�}
{�C��}	if (tc.ver2 = 9) and (tc.MUseLV > 30) then tc.MUseLV := tc.MUseLV - 30;
				if (tc.Skill[tc.MSkill].Lv >= tc.MUseLV) and (tc.MUseLV > 0) then begin
					tk := tc.Skill[tc.MSkill];
					tl := tc.Skill[tc.MSkill].Data;
					k := UseFieldSkill(tc,timeGetTime());
					if k <> 0 then SendSkillError(tc,k);
				end;
			end;
		//--------------------------------------------------------------------------
		$0118: //�U���L�����Z��
			begin
				if (tc.AMode = 1) or (tc.AMode = 2) then tc.AMode := 0;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d AMode = %d', [tc.ID, tc.AMode]));
			end;
		//--------------------------------------------------------------------------
		$011b: //�e���|or�|�[�^���ꏊ�I��
			begin
        if (tc.Sit <> 1) then begin
				tm := tc.MData;
				RFIFOW(2, w);
				if (w <> 26) and (w <> 27) then continue;
				str := RFIFOS(4, 16);

				if tc.SP < tc.Skill[w].Data.SP[tc.Skill[w].Lv] then begin
					//SP�s��
					WFIFOW( 0, $0110);
					WFIFOW( 2, 26);
					WFIFOW( 4, 0);
					WFIFOW( 6, 0);
					WFIFOB( 8, 0);
					WFIFOB( 9, 1);
					Socket.SendBuf(buf, 10);
					continue;
				end;
				if tc.Weight * 100 div tc.MaxWeight >= 90 then begin
					//�d�ʃI�[�o�[
					WFIFOW(0, $013b);
					WFIFOW(2, 2);
					Socket.SendBuf(buf, 4);
					continue;
				end;
				if (w = 26) then begin //�e���|�[�g
					if (tc.Skill[26].Lv >= 1) and (str = 'Random') then begin //�����_�����[�v
						//���W�ړ�
						j := 0;
						repeat
							xy.X := Random(tm.Size.X - 2) + 1; //��ʒ[�̌��Ԃɂ͔�΂Ȃ��悤��
							xy.Y := Random(tm.Size.Y - 2) + 1;
							Inc(j);
						until ( ((tm.gat[xy.X, xy.Y] <> 1) and (tm.gat[xy.X, xy.Y] <> 5)) or (j = 100) );
						if j = 100 then begin
							//��ׂȂ��Ƃ������Ƃ͂Ȃ��Ǝv�����ǈꉞ�A�t�F�C���Z�[�t
							WFIFOW( 0, $0110);
							WFIFOW( 2, 26);
							WFIFOW( 4, 0);
							WFIFOW( 6, 0);
							WFIFOB( 8, 0);
							WFIFOB( 9, 0);
							Socket.SendBuf(buf, 10);
							continue;
						end;
						//�}�b�v�ړ�
						DecSP(tc, 26, tc.Skill[26].Lv);
                                                    tc.MMode := 0;
						SendCLeave(tc, 3);
						tc.Point := xy;
						MapMove(Socket, tc.Map, tc.Point);
					end else if (tc.Skill[26].Lv = 2) and (ChangeFileExt(str, '') = tc.SaveMap) then begin //�Z�[�u�ꏊ�֋A��
						DecSP(tc, 26, 2);
            tc.MMode := 0;
						SendCLeave(tc, 0);
						tc.Map := tc.SaveMap;
						tc.Point := tc.SavePoint;
						MapMove(Socket, tc.Map, tc.Point);
					end;
				end else begin //���[�v�|�[�^��
					j := -1;
					if ChangeFileExt(str, '') = tc.SaveMap then begin
						xy := tc.SavePoint;
						j := 3;
					end else begin
						for i := 0 to tc.Skill[27].Data.Data1[tc.Skill[27].Lv] - 1 do begin
							if ChangeFileExt(str, '') = tc.MemoMap[i] then begin
								xy := tc.MemoPoint[i];
								j := i;
								break;
							end;
						end;
					end;
					if j = -1 then continue; //�s���p�P�b�g
					//���[�v�����[�v���Ȃ����ǂ����`�F�b�N
					if (tc.Map = ChangeFileExt(str, '')) and (tc.MPoint.X = xy.X) and (tc.MPoint.Y = xy.Y) then begin
						WFIFOW( 0, $0110);
						WFIFOW( 2, 27);
						WFIFOW( 4, 0);
						WFIFOW( 6, 0);
						WFIFOB( 8, 0);
						WFIFOB( 9, 3); //�ꉞ�Amemo�����G���[�𑗂�
						Socket.SendBuf(buf, 10);
						continue;
					end;
					if tc.Skill[27].Data.UseItem <> 0 then begin
						//�A�C�e���`�F�b�N&����(��)
					end;

            j := SearchCInventory(tc, 717, false);
						if ((j <> 0) and (tc.Item[j].Amount >= 1)) or (tc.NoJamstone = True) then begin

              if tc.NoJamstone = False then UseItem(tc, j);

              tn := SetSkillUnit(tm, tc.ID, Point(tc.MPoint.X, tc.MPoint.Y), timeGetTime(), $81,
  	  				tc.Skill[27].Data.Data2[tc.Skill[27].Lv], 2000);
    					tn.WarpMap := ChangeFileExt(str, '');
    					tn.WarpPoint := xy;
  	  				DecSP(tc, 27, tc.Skill[27].Lv);
              tc.MMode := 0;
              tc.MPoint.X := 0;
              tc.MPoint.Y := 0;
  					end else begin
              SendSkillError(tc, 8); //No Blue Gemstone
							tc.MMode := 0;
							tc.MPoint.X := 0;
							tc.MPoint.Y := 0;
							Exit;
						end;

				end;
        end;
			end;
		//--------------------------------------------------------------------------
		$011d: //�|�[�^������
			begin
				if tc.Skill[27].Lv < 2 then begin //�����s�\
					WFIFOW(0, $011e);
					WFIFOB(2, 1);
					Socket.SendBuf(buf, 3);
					continue;
				end;
				tm := tc.MData;
{NPC�C�x���g�ǉ�}
				i := MapInfo.IndexOf(tc.Map);
				j := -1;
				if (i <> -1) then begin
					mi := MapInfo.Objects[i] as MapTbl;
					if (mi.noMemo = true) then j := 0;
				end;
				if (j = 0) then begin //�����s�\
					WFIFOW(0, $0189);
					WFIFOW(2, 1);
					Socket.SendBuf(buf, 4);
					continue;
				end;
{NPC�C�x���g�ǉ��R�R�܂�}
				if (tm.gat[tc.Point.X][tc.Point.Y] = 1) or (tm.gat[tc.Point.X][tc.Point.Y] = 5) then begin //�ړ��s�\�ꏊ�̓����s��
					WFIFOW(0, $0189);
					WFIFOW(2, 1);
					Socket.SendBuf(buf, 4);
					continue;
				end;
				j := -1;
				k := tc.Skill[27].Data.Data1[tc.Skill[27].Lv];
				for i := 0 to k - 1 do begin
					if tc.MemoMap[i] = tc.Map then begin
						j := i;
						break;
					end;
				end;
				if j = -1 then begin
					for i := 0 to k - 1 do begin
						if tc.MemoMap[i] = '' then begin
							j := i;
							tc.MemoMap[i] := tc.Map;
							tc.MemoPoint[i] := tc.Point;
							break;
						end;
					end;
					if j <> -1 then begin
						//��������
						WFIFOW(0, $011e);
						WFIFOB(2, 0);
						Socket.SendBuf(buf, 3);
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Memo %d: %s (%d,%d)', [i, tc.Map, tc.Point.X, tc.Point.Y]));
						continue;
					end;
					j := 0;
				end;
				for i := j + 1 to k - 1 do begin
					tc.MemoMap[i-1] := tc.MemoMap[i];
					tc.MemoPoint[i-1] := tc.MemoPoint[i];
				end;
				tc.MemoMap[k-1] := '';
				tc.MemoPoint[k-1] := Point(0,0);
				for i := 0 to k - 1 do begin
					if tc.MemoMap[i] = '' then begin
						tc.MemoMap[i] := tc.Map;
						tc.MemoPoint[i] := tc.Point;
						break;
					end;
				end;
				//��������
				WFIFOW(0, $011e);
				WFIFOB(2, 0);
				Socket.SendBuf(buf, 3);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Memo %d: %s (%d,%d)', [i, tc.Map, tc.Point.X, tc.Point.Y]));
				continue;
			end;
		//--------------------------------------------------------------------------
{�J�[�g�@�\�ǉ�}
		$0126: //Inventory����J�[�g�ɃA�C�e��������
			begin
{�I�X�X�L���ǉ�}
				if(tc.VenderID <> 0) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
				RFIFOW(2, w1);//inventory���ł̃A�C�e��ID
				RFIFOL(4, l);//�ړ��������
				if l > 30000 then l := 30000;//�����30000�ł���
				w2 := l;

				//�w��A�C�e���������Ă��Ȃ��A�v�����ꂽ�ȏ�̌����������Ă��Ȃ���Ώ������甲����(�s���p�P�b�g�΍�)
				if (tc.Item[w1].ID = 0) or (tc.Item[w1].Amount < w2) then begin
					continue;
				end;

				//�J�[�g��������
				j := SearchInventory(tc.Cart, tc.Item[w1].ID, tc.Item[w1].Data.IEquip);

				//j = 0�̂Ƃ��͍ő��ސ��I�[�o�[�̂͂��Ȃ̂ŃG���[���b�Z�[�W�𑗂菈�����甲����(�p�P�b�g�Ɏ��g����)
				if j = 0 then begin
					WFIFOW(0, $00ca);
					WFIFOB(2, 3);//2=�d�ʃI�[�o�[ 3=�A�C�e���ő��ސ��I�[�o�[
					Socket.SendBuf(buf, 3);
					continue;
				end;

				k := GetItemStore(tc.Cart,tc.Item[w1],w2);
				if k = 2 then begin
					//�d�ʃI�[�o�[�̃p�P�b�g�𑗂�A�������甲����
					WFIFOW(0, $012c);
					WFIFOB(2, 0);
					Socket.SendBuf(buf, 3);
					continue;
				end;
				//�ΏۃA�C�e���̌��������ƍ��킹��30000�𒴂���Ȃ珈�����甲����(�{���̏����͕s��)
				if k <> 0 then begin
						continue;
				end;

				//�J�[�g�ɒǉ����ꂽ�A�C�e����\������p�P�b�g�𑗐M����
				WFIFOW( 0, $0124);
				WFIFOW( 2, j);
				WFIFOL( 4, l);
				WFIFOW( 8, tc.Cart.Item[j].ID);
				WFIFOB(10, tc.Cart.Item[j].Identify);
				WFIFOB(11, tc.Cart.Item[j].Attr);
				WFIFOB(12, tc.Cart.Item[j].Refine);
				WFIFOW(13, tc.Cart.Item[j].Card[0]);
				WFIFOW(15, tc.Cart.Item[j].Card[1]);
				WFIFOW(17, tc.Cart.Item[j].Card[2]);
				WFIFOW(19, tc.Cart.Item[j].Card[3]);
				Socket.SendBuf(buf, 21);

				//�v���C���[�[��Inventory���̃A�C�e��������
				Dec(tc.Item[w1].Amount, w2);
				if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
				WFIFOW( 0, $00af);
				WFIFOW( 2, w1);
				WFIFOW( 4, w2);
				Socket.SendBuf(buf, 6);

				//�v���C���[�̏d�ʕύX
				tc.Weight := tc.Weight - tc.Item[w1].Data.Weight * w2;
				SendCStat1(tc, 0, $0018, tc.Weight);

				//�J�[�g�d�ʁA�e�ʃf�[�^�̑��M
				//0121 <num>.w <num limit>.w <weight>.l <weight limit>l
				WFIFOW(0, $0121);
				WFIFOW(2, tc.Cart.Count);
				WFIFOW(4, 100);
				WFIFOL(6, tc.Cart.Weight);
				WFIFOL(10, tc.Cart.MaxWeight);
				Socket.SendBuf(buf, 14);
			end;
{�J�[�g�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
{�J�[�g�@�\�ǉ�}
		$0127: //�J�[�g����Inventory�ɃA�C�e�����o��
			begin
{�I�X�X�L���ǉ�}
				if(tc.VenderID <> 0) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
				RFIFOW(2, w1);//inventory���ł̃A�C�e��ID
				RFIFOL(4, l);//�ړ��������
				if l > 30000 then l := 30000;//�����30000�ł���
				w2 := l;

				weight := tc.Cart.item[w1].Data.Weight * w2;//�J�[�g������o���A�C�e���̏d��

				//�d�ʃI�[�o�[�̏ꍇ�̓G���[���b�Z�[�W�𑗂��ď����𔲂���

                                if longint(tc.MaxWeight) - longint(tc.Weight) < longint(weight) then begin // AlexKreuz: Integer Overflow Protection
					WFIFOW(0, $012c);
					WFIFOB(2, 0);
					Socket.SendBuf(buf, 3);
                                end

                                // AlexKreuz: User Overweight - Merchant Cart Protection
                                else begin

					//�w��A�C�e���������Ă��Ȃ��A�������甲����(�s���p�P�b�g�΍�)
					if (tc.Cart.item[w1].ID = 0) then begin
						continue;
					end;

					//Inventory������
					j := SearchCInventory(tc, tc.Cart.item[w1].ID, tc.Cart.item[w1].Data.IEquip);
	
					//j = 0�̂Ƃ��͍ő��ސ��I�[�o�[�̂͂��Ȃ̂ŃG���[���b�Z�[�W�𑗂菈�����甲����
					if j = 0 then begin
						WFIFOW(0, $00ca);
						WFIFOB(2, 3);//2=�d�ʃI�[�o�[ 3=�A�C�e���ő��ސ��I�[�o�[
						Socket.SendBuf(buf, 3);
						continue;
					end;
	
					//�ΏۃA�C�e���̌��������ƍ��킹��30000�𒴂���Ȃ珈�����甲����(�{���̏����͕s��)
					if tc.Item[j].Amount + w2 > 30000 then begin
						continue;
					end;
	
					//�J�[�g����Inventory�ɃA�C�e���ǉ�
					tc.Item[j].ID := tc.Cart.item[w1].ID;
					Inc(tc.Item[j].Amount, w2);
					tc.Item[j].Equip := 0;
					tc.Item[j].Identify := tc.Cart.item[w1].Identify;
					tc.Item[j].Refine := tc.Cart.item[w1].Refine;
					tc.Item[j].Attr := tc.Cart.item[w1].Attr;
					tc.Item[j].Card[0] := tc.Cart.item[w1].Card[0];
					tc.Item[j].Card[1] := tc.Cart.item[w1].Card[1];
					tc.Item[j].Card[2] := tc.Cart.item[w1].Card[2];
					tc.Item[j].Card[3] := tc.Cart.item[w1].Card[3];
					tc.Item[j].Data := tc.Cart.item[w1].Data;
	
					//�A�C�e���擾�\��
					SendCGetItem(tc, j, w2);
	
					//�J�[�g���̃A�C�e��������
					Dec(tc.Cart.item[w1].Amount, w2);
	
					//�J�[�g�̏d�ʕύX
					tc.Cart.Weight := tc.Cart.Weight - weight;
	
					//��������0�ɂȂ�����ID 0�ɂ��ăJ�[�g���A�C�e����ސ������炷
					if tc.Cart.item[w1].Amount = 0 then begin
						tc.Cart.item[w1].ID := 0;
						Dec(tc.Cart.Count);
					end;
	
					//�J�[�g���̑ΏۃA�C�e���̏������\���ύX
					WFIFOW( 0, $0125);
					WFIFOW( 2, w1);
					WFIFOL( 4, l);
					Socket.SendBuf(buf, 8);

					//�J�[�g�d�ʁA�e�ʃf�[�^�̑��M
					WFIFOW(0, $0121);
					WFIFOW(2, tc.Cart.Count);
					WFIFOW(4, 100);
					WFIFOL(6, tc.Cart.Weight);
					WFIFOL(10, tc.Cart.MaxWeight);
					Socket.SendBuf(buf, 14);
	
					//�v���C���[�̏d�ʕύX
					tc.Weight := tc.Weight + weight;
					SendCStat1(tc, 0, $0018, tc.Weight);
                                end;
			end;
{�J�[�g�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
{�J�[�g�@�\�ǉ�}
		$0128: //�q�ɂ���J�[�g�փA�C�e���ړ�
			begin
{�I�X�X�L���ǉ�}
				if(tc.VenderID <> 0) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
				tp := tc.PData;

				RFIFOW(2, w1);//�q�ɓ��ł̑ΏۃA�C�e��ID
				RFIFOL(4, l);//�ړ��������

				if tp.Kafra.Item[w1].ID = 0 then Continue;
				if tp.Kafra.Item[w1].Amount < l then
					l := tp.Kafra.Item[w1].Amount;
				j := SearchInventory(tc.Cart, tp.Kafra.Item[w1].ID, tp.Kafra.Item[w1].Data.IEquip);

				//tp.Kafra.Weight := 80000;
				k := MoveItem(tc.Cart,tp.Kafra,w1,l);
				if k = -1 then Continue;
				if k = 2 then begin
					//�d�ʃI�[�o�[�̃p�P�b�g�𑗂�A�������甲����
					WFIFOW(0, $012c);
					WFIFOB(2, 0);
					Socket.SendBuf(buf, 3);
					continue;
				end else if k = 3 then begin
					WFIFOW(0, $00ca);
					WFIFOB(2, 3);	//1=����������Ȃ� 2=�d�ʃI�[�o�[ 3=�A�C�e���ő��ސ��I�[�o�[
					Socket.SendBuf(buf, 3);
					continue;
				end;

			//�q�ɓ��̑ΏۃA�C�e���̌��ύX
				WFIFOW( 0, $00f6);
				WFIFOW( 2, w1);
				WFIFOL( 4, l);
				Socket.SendBuf(buf, 8);

				//�q�ɃA�C�e�����ύX
				WFIFOW(0, $00f2);
				WFIFOW(2, tp.Kafra.Count);
				WFIFOW(4, 100);
				tc.Socket.SendBuf(buf, 6);

				//�J�[�g�ɒǉ����ꂽ�A�C�e���̕\��
				WFIFOW( 0, $0124);
				WFIFOW( 2, j);
				WFIFOL( 4, l);
				WFIFOW( 8, tc.Cart.item[j].ID);
				WFIFOB(10, tc.Cart.item[j].Identify);
				WFIFOB(11, tc.Cart.item[j].Attr);
				WFIFOB(12, tc.Cart.item[j].Refine);
				WFIFOW(13, tc.Cart.item[j].Card[0]);
				WFIFOW(15, tc.Cart.item[j].Card[1]);
				WFIFOW(17, tc.Cart.item[j].Card[2]);
				WFIFOW(19, tc.Cart.item[j].Card[3]);
				Socket.SendBuf(buf, 21);

				//�J�[�g�d�ʁA�e�ʃf�[�^�̑��M
				WFIFOW(0, $0121);
				WFIFOW(2, tc.Cart.Count);
				WFIFOW(4, 100);
				WFIFOL(6, tc.Cart.Weight);
				WFIFOL(10, tc.Cart.MaxWeight);
				Socket.SendBuf(buf, 14);

			end;
{�J�[�g�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
{�J�[�g�@�\�ǉ�}
		$0129: //�J�[�g����q�ɂփA�C�e���ړ�
			begin
{�I�X�X�L���ǉ�}
				if(tc.VenderID <> 0) then continue;
{�I�X�X�L���ǉ��R�R�܂�}
				tp := tc.PData;

				RFIFOW(2, w1);//�J�[�g���ł̑ΏۃA�C�e��ID
				RFIFOL(4, l);//�ړ��������

				if tc.Cart.Item[w1].ID = 0 then Continue;
				if tc.Cart.Item[w1].Amount < l then
					l := tc.Cart.Item[w1].Amount;
				j := SearchInventory(tp.Kafra, tc.Cart.Item[w1].ID, tc.Cart.Item[w1].Data.IEquip);

				k := MoveItem(tp.Kafra,tc.Cart,w1,l);
				if k = -1 then Continue
				else if k = 3 then begin
					WFIFOW(0, $00ca);
					WFIFOB(2, 3);	//1=����������Ȃ� 2=�d�ʃI�[�o�[ 3=�A�C�e���ő��ސ��I�[�o�[
					Socket.SendBuf(buf, 3);
					continue;
				end;

				//�J�[�g���̑ΏۃA�C�e���̏������\���ύX
				WFIFOW( 0, $0125);
				WFIFOW( 2, w1);
				WFIFOL( 4, l);
				Socket.SendBuf(buf, 8);

				//�J�[�g�d�ʁA�e�ʃf�[�^�̑��M
				WFIFOW(0, $0121);
				WFIFOW(2, tc.Cart.Count);
				WFIFOW(4, 100);
				WFIFOL(6, tc.Cart.Weight);
				WFIFOL(10, tc.Cart.MaxWeight);
				Socket.SendBuf(buf, 14);

				//�q�ɒǉ��A�C�e���̕\��
				WFIFOW( 0, $00f4);
				WFIFOW( 2, j);
				WFIFOL( 4, l);
				WFIFOW( 8, tp.Kafra.Item[j].ID);
				WFIFOB(10, tp.Kafra.Item[j].Identify);
				WFIFOB(11, tp.Kafra.Item[j].Attr);
				WFIFOB(12, tp.Kafra.Item[j].Refine);
				WFIFOW(13, tp.Kafra.Item[j].Card[0]);
				WFIFOW(15, tp.Kafra.Item[j].Card[1]);
				WFIFOW(17, tp.Kafra.Item[j].Card[2]);
				WFIFOW(19, tp.Kafra.Item[j].Card[3]);
				Socket.SendBuf(buf, 21);

				//�q�ɃA�C�e�����ύX
				WFIFOW(0, $00f2);
				WFIFOW(2, tp.Kafra.Count);
				WFIFOW(4, 100);
				tc.Socket.SendBuf(buf, 6);
			end;
{�J�[�g�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		$012a: // Remove peco/cart/falcon options (clicked 'off').
			begin
				tc.Option := tc.Option and $F847;
        UpdateOption(tm, tc);
			end;
		//--------------------------------------------------------------------------
{�I�X�X�L���ǉ�}
		$012e: //�I�X��
			begin
				VenderExit(tc);
			end;
		//--------------------------------------------------------------------------
		$0130: //�I�X�A�C�e�����X�g
			begin
				RFIFOL(2, l);
				i := VenderList.IndexOf(l);
				if (i <> -1) then begin
					tv := VenderList.Objects[i] as TVender;
					tc1 := Chara.IndexOfObject(tv.CID) as TChara;
					if (tc1 <> nil) then begin
						w := 8 + tv.Cnt * 22;
						WFIFOW( 0, $0133);
						WFIFOW( 2, w);
						WFIFOL( 4, tv.ID);
						k := 0;
						for j := 0 to tv.MaxCnt - 1 do begin
							if (tv.Idx[j] <> 0) then begin
								td := tc1.Cart.Item[tv.Idx[j]].Data;
								WFIFOL( 8+k*22, tv.Price[j]);
								WFIFOW(12+k*22, tv.Amount[j]);
								WFIFOW(14+k*22, tv.Idx[j]);
								WFIFOB(16+k*22, td.IType);
								WFIFOW(17+k*22, tc1.Cart.Item[tv.Idx[j]].ID);
								WFIFOB(19+k*22, tc1.Cart.Item[tv.Idx[j]].Identify);
								WFIFOB(20+k*22, tc1.Cart.Item[tv.Idx[j]].Attr);
								WFIFOB(21+k*22, tc1.Cart.Item[tv.Idx[j]].Refine);
								WFIFOW(22+k*22, tc1.Cart.Item[tv.Idx[j]].Card[0]);
								WFIFOW(24+k*22, tc1.Cart.Item[tv.Idx[j]].Card[1]);
								WFIFOW(26+k*22, tc1.Cart.Item[tv.Idx[j]].Card[2]);
								WFIFOW(28+k*22, tc1.Cart.Item[tv.Idx[j]].Card[3]);
								k := k + 1;
							end;
						end;
						if (k <> 0) then Socket.SendBuf(buf, w);
					end;
				end;
			end;
		//--------------------------------------------------------------------------
		$0134: //�I�X�A�C�e���w��
			begin
				RFIFOW(2, w);
				if (w - 8 < 4) then continue;
				RFIFOL(4, l);
				i := VenderList.IndexOf(l);
				if (i = -1) then continue;
				tv := VenderList.Objects[i] as TVender;
				if (tv = nil) then continue;
				tc1 := Chara.IndexOfObject(tv.CID) as TChara;
				if (tc1 = nil) then continue;
				if (tc1.Map <> tc.Map) or (abs(tc1.Point.X - tc.Point.X) > 15)
					or (abs(tc1.Point.Y - tc.Point.Y) > 15) then continue;

				//�A�C�e���i�[
				SetLength(ww, ((w - 8) div 4), 2);
				for i := 0 to (w - 8) div 4 - 1 do begin
					RFIFOW( 8+i*4, ww[i][0]);
					RFIFOW(10+i*4, ww[i][1]);
				end;

				//�w�����C��
				b := 0;
				for i := 0 to (w - 8) div 4 - 1 do begin
					w1 := ww[i][0];
					w2 := ww[i][1];
					k := -1;
					for j := 0 to tv.MaxCnt - 1 do begin
						if (tv.Idx[j] = w2) then begin
							if (tv.Amount[j] < w1) then begin
								w1 := tv.Amount[j];
								if (w1 = 0) then b := 3;
							end;
							k := j;
							break;
						end;
					end;

					//�w���\���`�F�b�N
					td := tc1.Cart.Item[w2].Data;
					j := SearchCInventory(tc, td.ID, td.IEquip);
					if (tc.Zeny < tv.Price[w2] * w1) then begin
						b := 1;//�������s��
					end else if (tc.MaxWeight - tc.Weight < tv.Weight[w2] * w1) then begin
						b := 2;//�d�ʃI�[�o�[
					end else if (j = 0) then begin
						b := 2;//��ރI�[�o�[
					end else if (k = -1) then begin
						b := 3;//�C���f�b�N�X�s��
					end;
					if (b <> 0) then begin
						break;
					end;

					//---�I�X������---
					//�J�[�g�̐��ʕύXPart1
					Dec(tc1.Cart.Item[w2].Amount, w1);
					//�J�[�g�̏d�ʕύX
					tc1.Cart.Weight := tc1.Cart.Weight - tv.Weight[k] * w1;
					// Update zeny
					tc1.Zeny := tc1.Zeny + tv.Price[k] * w1;
          SendCStat1(tc1, 1, $0014, tc1.Zeny);
					//�I�X���X�g�̐��ʕύX
					Dec(tv.Amount[k], w1);
					//�̔��񍐃p�P
					WFIFOW(0, $0137);
					WFIFOW(2, w2);
					WFIFOW(4, w1);
					tc1.Socket.SendBuf(buf, 6);

					//---�w��������---
					// Update zeny
					tc.Zeny := tc.Zeny - tv.Price[k] * w1;
          SendCStat1(tc, 1, $0014, tc.Zeny);
					//�A�C�e���ǉ�
					with tc1.Cart.Item[w2] do begin
						tc.Item[j].ID := ID;
						tc.Item[j].Amount := tc.Item[j].Amount + w1;
						tc.Item[j].Equip := Equip;
						tc.Item[j].Identify := Identify;
						tc.Item[j].Refine := Refine;
						tc.Item[j].Attr := Attr;
						tc.Item[j].Card[0] := Card[0];
						tc.Item[j].Card[1] := Card[1];
						tc.Item[j].Card[2] := Card[2];
						tc.Item[j].Card[3] := Card[3];
						tc.Item[j].Data := td;
					end;
					SendCGetItem(tc, j, w1);
					//�d�ʍX�V
					tc.Weight := tc.Weight + tv.Weight[k] * w1;
					SendCStat1(tc, 0, $0018, tc.Weight);

					//---�ۗ���������---
					//�J�[�g�̐��ʕύXPart2
					if (tc1.Cart.Item[w2].Amount = 0) then begin
						tc1.Cart.Item[w2].ID := 0;
						Dec(tc1.Cart.Count);
					end;
					//����؂ꏈ��
					if (tv.Amount[k] = 0) then begin
						tv.Idx[k] := 0;
						tv.Price[k] := 0;
						tv.Weight[k] := 0;
						tv.Cnt := tv.Cnt - 1;
					end;
				end;

				if (b <> 0) then begin
					//�w���G���[
					WFIFOW(0, $0135);
					WFIFOW(2, w2);
					WFIFOW(4, w1);
					WFIFOB(6, b);
					Socket.SendBuf(buf, 7);
				end else begin
					if tv.Cnt = 0 then begin
						//��������
						tc1.VenderID := 0;
						//�J�[�g�̏d�ʍX�V�p�P
						WFIFOW(0, $0121);
						WFIFOW(2, tc1.Cart.Count);
						WFIFOW(4, 100);
						WFIFOL(6, tc1.Cart.Weight);
						WFIFOL(10, tc1.Cart.MaxWeight);
						tc.Socket.SendBuf(buf, 14);
						//�Ŕ��������͂ɒʒm
						WFIFOW(0, $0132);
						WFIFOL(2, tv.ID);
						SendBCmd(tc1.MData, tc1.Point, 6, tc1);
						//�I�X���X�g�폜
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Vender(%s) was close / Remaining Vender(%d)', [tv.Title,VenderList.Count-1]));
						VenderList.Delete(VenderList.IndexOf(tv.ID));
						tv.Free;
					end;
				end;
			end;
{�I�X�X�L���ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		$013f: // GM SUMMONS
			begin
				str := RFIFOS(2, 24);
				RFIFOW(2, w);
				parse_commands (tc, '/S'+str);
			end;
		//--------------------------------------------------------------------------
		$0143: //NPC��b��InputNumber����
			begin
				RFIFOL(2, l);
				if tc.TalkNPCID <> l then continue;
				RFIFOL(6, l);
				NPCScript(tc, l + 1);
			end;
		//--------------------------------------------------------------------------
		$0146: //NPC��b��CLOSE��I������
			begin
				//RFIFOL(2, l);
				//if tc.TalkNPCID <> l then continue;
				tc.AMode := 0;
			end;
{�M���h�@�\�ǉ�}
		$014d: //�M���h���\���J�n
			begin
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				WFIFOW( 0, $014e);
				if (tg.MasterName = tc.Name) then begin
					WFIFOL( 2, $d7); //�M���h�}�X�^�[
				end else begin
					WFIFOL( 2, $57); //���
				end;
				Socket.SendBuf(buf, 6);
			end;
		//--------------------------------------------------------------------------
		$014f: //�M���h�\���^�u
			begin
				RFIFOL(2, l);
				SendGuildInfo(tc, l);
			end;
		//--------------------------------------------------------------------------
		$0151: //�G���u�����v��
			begin
				RFIFOL(2, l);
				j := GuildList.IndexOf(l);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.Emblem = 0) then continue;
				w := LoadEmblem(tg);
				if (w = 0) then continue;
				Socket.SendBuf(buf, w);
			end;
		//--------------------------------------------------------------------------
		$0153: //�G���u�����ύX
			begin
				RFIFOW(2, w);
				if (w <= 4) then continue;
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.MasterName = tc.Name) then begin
					if (tg.Emblem > 0) then begin
						//���݂̃G���u�������폜
						str := AppPath + 'emblem\' + IntToStr(tg.ID) + '_' + IntToStr(tg.Emblem) + '.emb';
						if FileExists(str) then DeleteFile(str);
					end;

					//�G���u�����X�V
					Inc(tg.Emblem);
					SaveEmblem(tg, w - 4);
				end;
			end;
		//--------------------------------------------------------------------------
		$0155: //�M���h�����ύX
			begin
				RFIFOW( 2, w);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.MasterName = tc.Name) then begin
					for i := 0 to (w - 4) div 12 - 1 do begin
						RFIFOL(i * 12 + 8, l);
						RFIFOL(i * 12 + 12, l2);
						if (l2 >= 20) then continue;
						tc1 := Chara.IndexOfObject(l) as TChara;
						if (tc1 = nil) then continue;
						if (tc1.Name <> tg.MasterName) and (l2 <> 0) then begin
							tg.MemberPos[tc1.GuildPos] := l2;
							tc1.ClassName := tg.PosName[l2];
						end;
					end;
					//�ύX�ʒm
					WFIFOW( 0, $0156);
					SendGuildMCmd(tc, w);
				end;
			end;
		//--------------------------------------------------------------------------
		$0159: //�M���h�E��
			begin
            	leave_guild(tc);
			end;
		//--------------------------------------------------------------------------
		$015b: //�M���h�Ǖ�
			begin
				ban_guild(tc);
			end;
		//--------------------------------------------------------------------------
		$015d: //�M���h���U
			begin
				str := RFIFOS(2, 24);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.Name = str) and (tg.RegUsers = 1) and (tg.MasterName = tc.Name) then begin
					//�ʒm
					WFIFOW( 0, $016c);
					WFIFOL( 2, 0);
					WFIFOL( 6, 0);
					WFIFOL(10, 0);
					WFIFOB(14, 0);
					WFIFOL(15, 0);
					WFIFOS(19, tg.Name, 24);
					Socket.SendBuf(buf, 43);
					WFIFOW( 0, $015e);
					WFIFOL( 2, 0);
					Socket.SendBuf(buf, 6);

					//�M���h�폜����
                    tg.Member[0] := nil;
                    tg.MemberID[0] := 0;

                    PD_Save_Guilds_Members(true);
					if UseSQL then DeleteGuildInfo(tc.GuildID);
					GuildList.Delete(GuildList.IndexOf(tc.GuildID));

					tc.GuildID := 0;
					tc.GuildName := '';
					tc.ClassName := '';
					tc.GuildPos := 0;
				end;
			end;
		//--------------------------------------------------------------------------
		$0161: //�E�ʏ��ύX
			begin
				RFIFOW( 2, w);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.MasterName = tc.Name) then begin
					for i := 0 to (w - 4) div 40 - 1 do begin
						RFIFOL(i * 40 + 4, l);
						RFIFOL(i * 40 + 8, l2);
						if (l2 div 16 = 1) then tg.PosInvite[l] := true else tg.PosInvite[l] := false;
						if (l2 mod 16 = 1) then tg.PosPunish[l] := true else tg.PosPunish[l] := false;
						RFIFOL(i * 40 + 16, l2);
						if (l2 > 50) then begin
							l2 := 50;//50����1�ł͂Ȃ�50�ɐݒ�
							WFIFOL(i * 40 + 8, l2);
						end;
						tg.PosEXP[l] := l2;
						tg.PosName[l] := RFIFOS(i * 40 + 20, 24);
						if UseSQL then SaveGuildMPosition(tg.ID, tg.PosName[l], tg.PosInvite[l], tg.PosPunish[l], tg.PosEXP[l], l);
					end;
					//�ύX�ʒm
					WFIFOW( 0, $0174);
					SendGuildMCmd(tc, w, false);
				end;
			end;
		//--------------------------------------------------------------------------
		$0165: //�M���h�쐬
			begin
				RFIFOL(2, l);
				str := RFIFOS(6, 24);
				if (str = '') then continue;
        SendGuildInfo(tc,1,true,false);        
				//�G���y���E���`�F�b�N
				w := 0;
				i := 0;
				for j := 1 to 100 do begin
					if (tc.Item[j].ID = 714) then begin
						w := j;
						break;
					end;
				end;
				if (w = 0) then begin
					//�A�C�e���s��
					i := 3;;
				end else if (tc.GuildID <> 0) then begin
					//���ɑ��M���h�ɉ�����
					i := 1;
				end else begin
					for j := 0 to GuildList.Count - 1 do begin
						tg := GuildList.Objects[j] as TGuild;
						if (tg.Name = str) then begin
							//�����M���h����
							i := 2;
							break;
						end;
					end;
				end;
				if (i <> 0) then begin
					//�쐬�G���[
					WFIFOW( 0, $0167);
					WFIFOB( 2, i);
					Socket.SendBuf(buf, 3);
					continue;
				end;

				//�A�C�e������
				Dec(tc.Item[w].Amount);
				if tc.Item[w].Amount = 0 then tc.Item[w].ID := 0;
				tc.Weight := tc.Weight - tc.Item[w].Data.Weight;
				WFIFOW( 0, $00af);
				WFIFOW( 2, w);
				WFIFOW( 4, 1);
				Socket.SendBuf(buf, 6);
				// Update weight
				SendCStat1(tc, 0, $0018, tc.Weight);

				//�M���h�쐬
				tg := TGuild.Create;
				NowGuildID := NowGuildID + 1;
				with tg do begin
					ID := NowGuildID;
					Name := str;
					LV := 1;
					EXP := 0;
          tg.NextEXP := GExpTable[tg.LV];
					MasterName := tc.Name;
					RegUsers := 1;
					MaxUsers := 16;
					SLV := tc.BaseLV;
					MemberID[0] := tc.CID;
					Member[0] := tc;
					for j := 0 to 19 do begin
						if (j = 0) then begin
							PosName[j] := 'Master';
							PosInvite[j] := true;
							PosPunish[j] := true;
						end else begin
							PosName[j] := 'Position ' + IntToStr(j + 1);
							PosInvite[j] := false;
							PosPunish[j] := false;
						end;
						PosEXP[j] := 0;
						if UseSQL then SaveGuildMPosition(ID, PosName[j], PosInvite[j], PosPunish[j], PosEXP[j], j);
					end;
					for j := 10000 to 10004 do begin
						if GSkillDB.IndexOf(j) <> -1 then begin
							GSkill[j].Data := GSkillDB.IndexOfObject(j) as TSkillDB;
						end;
					end;
					tc.GuildName := Name;
					tc.GuildID := ID;
					tc.ClassName := PosName[0];
				end;
				GuildList.AddObject(tg.ID, tg);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('GuildName %s : ID = %d : Name = %s', [tg.Name, tg.MemberID[0], tg.Member[0].Name]));

				//�쐬��������
				WFIFOW( 0, $0167);
				WFIFOB( 2, 0);
				Socket.SendBuf(buf, 3);

        WFIFOW( 0, $016d);
        WFIFOL( 2, tc.ID);
        WFIFOL( 6, tc.CID);
        WFIFOL(10, 1);
        SendGuildMCmd(tc, 14);

        SendGLoginInfo(tg, tc);


        

				//�M���h��񑗐M
				
			end;
		//--------------------------------------------------------------------------
		$0168: //�M���h���U
			begin
				if (tc.GuildInv <> 0) then continue;//���Ɋ��U��(�I�L�������Ή�)
				RFIFOL( 2, l);
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.GuildBanList.IndexOf(tc1.Name) <> -1) then continue;
				if (tc1.GuildID = 0) then begin
					if (tg.RegUsers < tg.MaxUsers) then begin
						tc.GuildInv := tc1.CID;
						WFIFOW( 0, $016a);
						WFIFOL( 2, tc.GuildID);
						WFIFOS( 6, tc.GuildName, 24);
						tc1.Socket.SendBuf(buf, 30);
					end else begin
						WFIFOW( 0, $0169);
						WFIFOB( 2, 3);
						Socket.SendBuf(buf, 3);
					end;
				end else begin
					WFIFOW( 0, $0169);
					WFIFOB( 2, 0);
					Socket.SendBuf(buf, 3);
				end;
			end;
		//--------------------------------------------------------------------------
		$016b: //�M���h���U����
			begin
      //debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Guild Invite');

RFIFOL(2, l);
RFIFOL(6, l2);
j := GuildList.IndexOf(l);
if (j <> -1) then begin
tg := GuildList.Objects[j] as TGuild;
				tc1 := nil;
				for i := 0 to 35 do begin
					if (tg.Member[i].GuildInv = tc.CID) then begin
						tc1 := tg.Member[i];
						break;
					end;
				end;
				tg.Member[tc1.GuildPos].GuildInv := 0;
				if (tc1 = nil) or (l2 > 1) then continue;
if (l2 = 1) then begin
with tg do begin
k := RegUsers;
if (k < MaxUsers) and (MemberID[k] = 0) then begin	
MemberID[k] := tc.CID;
Member[k] := tc;
MemberPos[k] := 19;
MemberEXP[k] := 0;
SLV := SLV + tc.BaseLV;
RegUsers := RegUsers + 1;
tc.GuildID := ID;
tc.GuildName := Name;
tc.GuildPos := k;
tc.ClassName := PosName[19];
WFIFOW( 0, $0169);
WFIFOB( 2, 2);
tc.Socket.SendBuf(buf, 3);
//tc1.Socket.SendBuf(buf, 3);

//WFIFOW( 0, $016d);
//WFIFOL( 2, tc.ID);
//WFIFOL( 6, tc.CID);
//WFIFOL(10, 1);
//SendGuildMCmd(tc, 14, true);

SendGLoginInfo(tg, tc);
end;
end;
end else begin
//WFIFOW( 0, $0169);
//WFIFOB( 2, 1);
//tc1.Socket.SendBuf(buf, 3);
end;
end;
//end;
			end;
		//--------------------------------------------------------------------------
		$016e: //�M���h���m�ݒ�
			begin
				RFIFOL(2, l);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.ID = l) and (tg.MasterName = tc.Name) then begin
					tg.Notice[0] := RFIFOS(6, 60);
					tg.Notice[1] := RFIFOS(66, 120);
					WFIFOW( 0, $016f);
					WFIFOS( 2, tg.Notice[0], 60);
					WFIFOS(62, tg.Notice[1], 120);
					SendGuildMCmd(tc, 182);
				end;
			end;
		//--------------------------------------------------------------------------
		$0170: //�M���h�����v��
			begin
				RFIFOL( 2, l);
				RFIFOL(10, l2);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				if (tg.MasterName <> tc.Name) then continue;
				j := GuildList.IndexOf(tc1.GuildID);
				if (j = -1) then continue;
				tg1 := GuildList.Objects[j] as TGuild;

				//�������`�F�b�N
				k := -1;
				if (tg.RelAlliance.IndexOf(tg1.Name) <> -1) then k := 0
				else if (tg.RelAlliance.Count >= 3) then k := 4
				else if (tg1.RelAlliance.Count >= 3) then k := 3;

				//���M
				if (k <> -1) then begin
					WFIFOW( 0, $0173);
					WFIFOB( 2, k);
					Socket.SendBuf(buf, 3);
				end else begin
					WFIFOW( 0, $0171);
					WFIFOL( 2, tc.CID);
					WFIFOS( 6, tg.Name, 24);
					tc1.Socket.SendBuf(buf, 30);
				end;
			end;
		//--------------------------------------------------------------------------
		$0172: //�M���h�����v������
			begin
				RFIFOL( 2, l);
				RFIFOL( 6, l2);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				tc1 := Chara.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				if (tg.MasterName <> tc.Name) then continue;
				j := GuildList.IndexOf(tc1.GuildID);
				if (j = -1) then continue;
				tg1 := GuildList.Objects[j] as TGuild;

				//�����̃M���h�̓������`�F�b�N
				k := -1;
				if (tg.RelAlliance.IndexOf(tg1.Name) <> -1) then k := 0
				else if (tg.RelAlliance.Count >= 3) then k := 4
				else if (tg1.RelAlliance.Count >= 3) then k := 3;

				if (l2 = 0) then begin
					//����
					k := 1;
				end else if (k = -1) then begin
					//����
					if (tg1.RelHostility.IndexOf(tg.Name) <> -1) then KillGuildRelation(tg1, tg, tc1, tc, 1);
					tgl := TGRel.Create;
					tgl.ID := tg1.ID;
					tgl.GuildName := tg1.Name;
					tg.RelAlliance.AddObject(tgl.GuildName, tgl);
					if UseSQL then SaveGuildAllyInfo(tgl.ID, tgl.GuildName, 1);
					tgl := TGRel.Create;
					tgl.ID := tg.ID;
					tgl.GuildName := tg.Name;
					tg1.RelAlliance.AddObject(tgl.GuildName, tgl);
					if UseSQL then SaveGuildAllyInfo(tgl.ID, tgl.GuildName, 1);
					k := 2;
				end;

				//���M
				WFIFOW( 0, $0173);
				WFIFOB( 2, k);
				Socket.SendBuf(buf, 3);
				tc1.Socket.SendBuf(buf, 3);

				if (k = 2) then begin
					WFIFOW( 0, $0185);
					WFIFOL( 2, 0);
					WFIFOL( 6, tg1.ID);
					WFIFOS(10, tg1.Name, 24);
					SendGuildMCmd(tc, 34);
					WFIFOL( 6, tg.ID);
					WFIFOS(10, tg.Name, 24);
					SendGuildMCmd(tc1, 34);
				end;
			end;
{�M���h�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		//--------------------------------------------------------------------------
		$0178: //�A�C�e���Ӓ�
			begin
				RFIFOW(2, w);
				if (w < 1) or (w > 100) or (tc.Item[w].Identify = 1) then begin
					WFIFOW(0, $0179);
					WFIFOW(2, w);
					WFIFOB(4, 1);
					Socket.SendBuf(buf, 5);
					continue;
				end;

				tc.Item[w].Identify := 1;
				WFIFOW(0, $0179);
				WFIFOW(2, w);
				WFIFOB(4, 0);
				Socket.SendBuf(buf, 5);

				w := tc.UseItemID;
				tc.UseItemID := 0;
        if (w <> 0) then begin
				Dec(tc.Item[w].Amount);
				WFIFOW( 0, $00a8);
				WFIFOW( 2, w);
				WFIFOW( 4, tc.Item[w].Amount);
				WFIFOB( 6, 1);
				Socket.SendBuf(buf, 7);


				//030316�ǉ� Cardinal
				if tc.Item[w].Amount <= 0 then tc.Item[w].ID := 0;
				tc.Weight := tc.Weight - tc.Item[w].Data.Weight;
				//�A�C�e��������
				WFIFOW( 0, $00af);
				WFIFOW( 2, w);
				WFIFOW( 4, 1);
				// Update weight
				SendCStat1(tc, 0, $0018, tc.Weight);
        end;
			end;
		//--------------------------------------------------------------------------
		$017a: //�J�[�hW�N���b�N
			begin
				RFIFOW(2, w);
				if (w = 0) or (w > 100) or (tc.Item[w].ID = 0) or
					 (tc.Item[w].Amount = 0) or (tc.Item[w].Data.IType <> 6) then continue;
				td := tc.Item[w].Data;

				j := 4;
				for i := 1 to 100 do begin
					if (tc.Item[i].ID <> 0) and (tc.Item[i].Amount > 0) and (tc.Item[i].Data.IEquip) and
						 (tc.Item[i].Data.Slot > 0) and (tc.Item[i].Card[tc.Item[i].Data.Slot - 1] = 0) and
						 (tc.Item[i].Equip = 0) then begin // �X���b�g�������Ă��ăX���b�g�̍Ōオ���܂��ĂȂ����
						if td.Loc = 0 then begin
							//����
							if tc.Item[i].Data.IType = 4 then begin
								WFIFOW(j, i);
								j := j + 2;
							end;
						end else begin
							//�h��
							if (tc.Item[i].Data.IType = 5) and ((tc.Item[i].Data.Loc and td.Loc) <> 0) then begin
								WFIFOW(j, i);
								j := j + 2;
							end;
						end;
					end;
				end;

				if j <> 4 then begin //�}���\�ȃA�C�e��������ꍇ
					WFIFOW(0, $017b);
					WFIFOW(2, j);
					Socket.SendBuf(buf, j);
				end;
			end;
		//--------------------------------------------------------------------------
		$017c: //Card insertion

			begin
				RFIFOW(2, w1); //src
				RFIFOW(4, w2); //dest
				if (w1 = 0) or (w1 > 100) or (tc.Item[w1].ID = 0) or (tc.Item[w1].Amount = 0) or
					 (tc.Item[w1].Data.IType <> 6) or
					 (w2 = 0) or (w2 > 100) or (tc.Item[w2].ID = 0) or (tc.Item[w2].Amount = 0) or
					 (not tc.Item[w2].Data.IEquip) or (tc.Item[w2].Data.Slot = 0) or
					 (tc.Item[w2].Card[tc.Item[w2].Data.Slot - 1] <> 0) or
					 (tc.Item[w2].Equip <> 0) then begin //�J�[�h���������ԂłȂ��ꍇ
					WFIFOW(0, $017d);
					WFIFOW(2, w1);
					WFIFOW(4, w2);
					WFIFOB(6, 1);
					Socket.SendBuf(buf, 7);
					continue;
				end;
				ti := tc.Item[w2];
				td := tc.Item[w2].Data;
				if tc.Item[w1].Data.Loc = 0 then begin
					if td.IType <> 4 then continue;
				end else begin
					if (td.IType <> 5) or ((td.Loc and tc.Item[w1].Data.Loc) = 0) then continue;
				end;

				for i := 0 to 3 do begin
					if(ti.Card[i] = 0) then begin
						ti.Card[i] := tc.Item[w1].Data.ID;
						WFIFOW(0, $017d);
						WFIFOW(2, w1);
						WFIFOW(4, w2);
						WFIFOB(6, 0);
						Socket.SendBuf(buf, 7);
						break;
					end;
				end;

				//�J�[�h������
				Dec(tc.Item[w1].Amount);
				WFIFOW( 0, $00a8);
				WFIFOW( 2, w1);
				WFIFOW( 4, tc.Item[w1].Amount);
				WFIFOB( 6, 1);
				Socket.SendBuf(buf, 7);
				//
				if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
				tc.Weight := tc.Weight - tc.Item[w1].Data.Weight;
				//�A�C�e��������
				WFIFOW( 0, $00af);
				WFIFOW( 2, w1);
				WFIFOW( 4, 1);
				// Update weight
				SendCStat1(tc, 0, $0018, tc.Weight);

				//�X���b�g�w�����A�C�e�����ē���
				SendCGetItem(tc, w2, 1);
                                end;
{�M���h�@�\�ǉ�}
		$017e: //�M���h�`���b�g
			begin
				RFIFOW(2, w);
				str := RFIFOS(4, w - 2);
				if (GuildList.IndexOf(tc.GuildID) <> -1) then begin
					WFIFOW(0, $017f);
					WFIFOW(2, w);
					WFIFOS(4, str, w);
					SendGuildMCmd(tc, w);
				end;
			end;
		//--------------------------------------------------------------------------
		$0180: //�M���h�G�ΐݒ�
			begin
				RFIFOL( 2, l);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.MasterName <> tc.Name) then continue;
				tc1 := CharaPID.IndexOfObject(l) as TChara;
				if tc1 = nil then Continue;
				j := GuildList.IndexOf(tc1.GuildID);
				if (j = -1) then continue;
				tg1 := GuildList.Objects[j] as TGuild;

				//�����`�F�b�N
				b := 0;
				if (tg.RelAlliance.IndexOf(tg1.Name) <> -1) then KillGuildRelation(tg, tg1, tc, tc1, 0);
				if (tg.RelHostility.IndexOf(tg1.Name) <> -1) then b := 2
				else if (tg.RelHostility.Count >= 3) then b := 1;

				if (b = 0) then begin
					//�G�Βǉ�
					tgl := TGRel.Create;
					tgl.ID := tg1.ID;
					tgl.GuildName := tg1.Name;
					tg.RelHostility.AddObject(tgl.GuildName, tgl);
					if UseSQL then SaveGuildAllyInfo(tgl.ID, tgl.GuildName, 2);

					//�p�P���M
					WFIFOW( 0, $0185);
					WFIFOL( 2, 1);
					WFIFOL( 6, tg1.ID);
					WFIFOS(10, tg1.Name, 24);
					SendGuildMCmd(tc, 34);
				end;

				//���ۑ��M
				WFIFOW( 0, $0181);
				WFIFOB( 0, b);
				Socket.SendBuf(buf, 3);
			end;
		//--------------------------------------------------------------------------
		$0183: //�����E�G�Ή���
			begin
				RFIFOL( 2, l);
				RFIFOL( 6, l2);
				j := GuildList.IndexOf(tc.GuildID);
				if (j = -1) then continue;
				tg := GuildList.Objects[j] as TGuild;
				if (tg.MasterName <> tc.Name) then continue;
				j := GuildList.IndexOf(l);
				if (j = -1) then continue;
				tg1 := GuildList.Objects[j] as TGuild;
				j := CharaName.IndexOf(tg1.MasterName);
				if (j = -1) then continue;
				tc1 := CharaName.Objects[j] as TChara;

				//����
				KillGuildRelation(tg, tg1, tc, tc1, l2);
			end;
{�M���h�@�\�ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
			//end;
		//--------------------------------------------------------------------------
		$018a: // Quit Game
			begin

                DataSave();

				SendCLeave(Socket.Data, 2);

				WFIFOW(0, $018b);
				WFIFOW(2, 0);
				Socket.SendBuf(buf, 4);
			end;
		//--------------------------------------------------------------------------
{�A�C�e�������ǉ�}
		$018e: //�A�C�e������
			begin
				RFIFOW(2, m1);//��肽���A�C�e����ID
				RFIFOW(4, m[0]);//���߂����1
				RFIFOW(6, m[1]);//���߂����2
				RFIFOW(8, m[2]);//���߂����3
				tm := tc.MData;
				w1 := 0;
				w2 := 0;
				anvil := 0;
				i := 1;//�����̐��۔���t���O�Ƃ��Ċ��p

				if MaterialDB.IndexOf(m1) <> -1 then begin
					tma := MaterialDB.IndexOfObject(m1) as TMaterialDB;//�ޗ��f�[�^�̌Ăяo��
					for j := 0 to 2 do begin
						if tma.MaterialID[j] = 0 then continue;
						e := SearchCInventory(tc, tma.MaterialID[j], false);
						if (e <> 0) and (tc.Item[e].Amount >= tma.MaterialAmount[j]) then begin

							//�A�C�e��������
							WFIFOW( 0, $00af);
							WFIFOW( 2, e);
							WFIFOW( 4, tma.MaterialAmount[j]);
			 				Socket.SendBuf(buf, 6);

							tc.Item[e].Amount := tc.Item[e].Amount - tma.MaterialAmount[j];
							if tc.Item[e].Amount = 0 then tc.Item[e].ID := 0;
							tc.Weight := tc.Weight - tc.Item[e].Data.Weight * tma.MaterialAmount[j];

							// Update weight
							SendCStat1(tc, 0, $0018, tc.Weight);

						end else begin

							i := 2;
							continue;

						end;
					end;

					//�ǉ����鑮���΁A���̂�����̏���
					for k := 0 to 2 do begin

						e := SearchCInventory(tc, m[k], false);

						if (e <> 0) and (tc.Item[e].Amount <> 0) then begin

							tc.Item[e].Amount := tc.Item[e].Amount - 1;
							if tc.Item[e].Amount = 0 then tc.Item[e].ID := 0;
							tc.Weight := tc.Weight - tc.Item[e].Data.Weight;

							// Update weight
							SendCStat1(tc, 0, $0018, tc.Weight);

							case m[k] of

								994://�Α�����(������25%�_�E��)
									begin
										w1 := w1 + $0003;
										w2 := w2 + 250;
									end;
								995://��������(������25%�_�E��)
									begin
										w1 := w1 + $0001;
										w2 := w2 + 250;
									end;
								996://��������(������25%�_�E��)
									begin
										w1 := w1 + $0004;
										w2 := w2 + 250;
									end;
								997://�y������(������25%�_�E��)
									begin
										w1 := w1 + $0002;
										w2 := w2 + 250;
									end;
								1000://���̂�����(������15%�_�E��)
									begin
										w1 := w1 + $0500;
										w2 := w2 + 150;
									end;
							end;
						end;
					end;

					//���~�̏����`�F�b�N

					e := SearchCInventory(tc, 987, false);//�I���f�I�R�����~(������3%�A�b�v)
						if (e <> 0) and (tc.Item[e].Amount <> 0) then begin
							anvil := 30;
						end;
					e := SearchCInventory(tc, 988, false);//�������~(������3%�A�b�v)
						if (e <> 0) and (tc.Item[e].Amount <> 0) then begin
							anvil := 50;
						end;
					e := SearchCInventory(tc, 989, false);//�G���y���E�����~(������10%�A�b�v)
						if (e <> 0) and (tc.Item[e].Amount <> 0) then begin
							anvil := 100;
						end;

					if (i <> 2) then begin

						case m1 of
							994,995,996,997://�����ΐ���(��������jobLv * 0.3 + DEX * 0.1 + LUK * 0.1 + �X�L���␳ + 15�Ɖ���)
								begin
									if (Random(1000) < (tc.JobLV * 3.5 + tc.Param[4] + tc.Param[5]) + tc.Skill[96].Data.Data1[tc.Skill[96].Lv] + 150 ) then i := 0;
								end;
							998://�S����(��������jobLv * 0.3 + DEX * 0.1 + LUK * 0.1 + �X�L���␳ + 15 �Ɖ���)
							begin
									if (Random(1000) < (tc.JobLV * 3.5 + tc.Param[4] + tc.Param[5]) + tc.Skill[94].Data.Data1[tc.Skill[94].Lv] + 150) then i := 0;
								end;
							999://�|�S����(��������jobLv * 0.3 + DEX * 0.1 + LUK * 0.1 + �X�L���␳ + 15 �Ɖ���)
								begin
									if (Random(1000) < (tc.JobLV * 3.5 + tc.Param[4] + tc.Param[5]) + tc.Skill[95].Data.Data1[tc.Skill[95].Lv] + 150) then i := 0;
								end;
							1000://���̂����琻��(���Ȃ炸�����Ɖ���)
								begin
									i := 0;
								end;
							else begin//���퐻��(��������jobLv * 0.3 + DEX * 0.1 + LUK * 0.1 + �X�L���␳ + 15 �Ɖ���)
                // Colus, 20040224: Updated calculation for Pharmacy.  Not correct, but closer.
                // Like Steal, the exact formula is not known to anybody yet...
                // Some formulas given:
                //
                // LP�3 + Pha�2 + JobLv�0.3 + Dex�0.1 + Int�0.05 + 10
                // LP�1 + Pha�3 + JobLv�0.2 + Dex�0.1 + Luk�0.1 + 20
                // Pha�4 + JobLv�0.3 + Dex�0.1 + Int�0.05 + 20
                // LP + Pha * 3 + PP + JovLV * 0.5 + LUK * 0.1 + DEX * 0.1 + 5
                // LP + Pha�3 + PP + Job�0.2 + Dex�0.1 + Luk�0.05 + 15

                // Somebody shoot me.  Anyway, I'm going to use this one for now:
                // LP + Pha * 3 + PP + JovLV * 0.5 + LUK * 0.1 + DEX * 0.1 + 5
                // Why?  It's got a lot of trials behind it.  It'll do for now.

                if (tma.RequireSkill = 228) then begin
                  if (Random(1000) < ((tc.Skill[227].Lv * 10) +  // 100
                     (tc.Skill[tma.RequireSkill].Lv * 30) +      // 300
                      (tc.Skill[231].Lv * 10) +                  // 50
                      tc.JobLV * 5 +                             // 250
                      tc.Param[4] + tc.Param[5]) +               // 200
                      5 ) then i := 0;                           // 5 = 905
                end else begin
                  if (Random(1000) < (tc.JobLV * 3 + tc.Param[4] + tc.Param[5]) + (tc.Skill[tma.RequireSkill].Lv * 100) + 150 + (tc.Skill[107].Lv * 10) + anvil - (w2 + (tma.ItemLV -1) * 100)) then i := 0;
                end;
              end;
						end;

					end;

					//�f�o�b�O�p
					//i := 0;

					//�����i�̎擾����
					//�����ŏd�ʂ������邱�Ƃ͂��肦�Ȃ��̂ŏd�ʃ`�F�b�N�͂��Ȃ�
					//���O�̕\���ɂ�Card[2]��Card[3]�ɃL�����N�^�[�ŗL��ID������K�v�����邯��
					//0194�p�P�b�g�̏������������̂��߂Ƃ肠�������u

					if (i = 0) then begin

						td := ItemDB.IndexOfObject(m1) as TItemDB;
						k := SearchCInventory(tc, m1, td.IEquip);

						if k <> 0 then begin

							if tc.Item[k].Amount  >= 30000 then continue;

							if (td.IEquip = false) then begin
								//�z�Ηނ̏ꍇ
								tc.Item[k].ID := m1;
								tc.Item[k].Amount := tc.Item[k].Amount + 1;
								tc.Item[k].Equip := 0;
								tc.Item[k].Identify := 1;
								tc.Item[k].Refine := 0;
								tc.Item[k].Attr := 0;
								tc.Item[k].Card[0] := 0;
								tc.Item[k].Card[1] := 0;
								tc.Item[k].Card[2] := 0;
								tc.Item[k].Card[3] := 0;
								tc.Item[k].Data := td;
							end else begin
								e := tc.CID mod $10000;
								e2 := tc.CID div $10000;
								tc.Item[k].ID := m1;
								tc.Item[k].Amount := tc.Item[k].Amount + 1;
								tc.Item[k].Equip := 0;
								tc.Item[k].Identify := 1;
								tc.Item[k].Refine := 0;
								tc.Item[k].Attr := 0;
								tc.Item[k].Card[0] := $00FF;//��������t���O($00FF�̂Ƃ���������Ɣ���)
								tc.Item[k].Card[1] := w1;//����̓������($0500 * ���̐� + �����ԍ�)
								tc.Item[k].Card[2] := e;//�����ҏ��1
								tc.Item[k].Card[3] := e2;//�����ҏ��2
								tc.Item[k].Data := td;
							end;

							// Update weight
							tc.Weight := tc.Weight + cardinal(td.Weight);
							SendCStat1(tc, 0, $0018, tc.Weight);

							//�A�C�e���Q�b�g�ʒm
							SendCGetItem(tc, k, 1);
						end;
					end;

					//�����G�t�F�N�g�p�P�b�g���M
          // Colus, 20040117: Send results to creator (fixed packet composition)
          // flag = 00 is success of Forging
          // flag = 01 is failure of Forging
          // flag = 02 is success of Pharmacy
          // flag = 03 is failure of Pharmacy
					WFIFOW(0, $018f);
          if (tma.RequireSkill = 228) then begin
            WFIFOW(2, i+2);
          end else begin
					  WFIFOW(2, i);
          end;
          
					WFIFOW(4, m1);
          Socket.SendBuf(buf, 6);

          // ...now send the results to others with $019b.
          // (Nice messed-up types here...)
          // type=2 Refining failure
          // type=3 Refining success
          // type=4 ?
          // type=5 Pharmacy success
          // type=6 Pharmacy failure

          WFIFOW(0, $019b);
          WFIFOL(2, tc.ID);
          if (i = 0) then begin
            if (tma.RequireSkill = 228) then begin
              WFIFOL(6, 5);
            end else begin
              WFIFOL(6, 3);
            end;
          end else begin
            if (tma.RequireSkill = 228) then begin
              WFIFOL(6, 6);
            end else begin
              WFIFOL(6, 2);
            end;
          end;

					SendBCmd(tm, tc.Point, 10);

				end;
			end;

		//--------------------------------------------------------------------------
    $0190: {Graffiti/Talkie Box}
      begin
        RFIFOW(2, w); // Level (always 1)
        RFIFOW(4, w1); // Code: $DC for Graffiti, $7D for Talkie
        RFIFOW(6, w2); // X
        RFIFOW(8, w3); // Y

        s := RFIFOS(10, 80);  // 78 + 2 bytes for length.
        //RFIFOW(88, e);  // This doesn't seem to get read...

        xy.X := w2;
        xy.Y := w3;
        tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;

        if w1 = $DC then begin

           j := SearchCInventory(tc, 716, false);
					 if ((j <> 0) and (tc.Item[j].Amount >= 1)) or (tc.NoJamstone = True) then begin
						 if tc.NoJamstone = False then UseItem(tc, j);
             WFIFOW( 0, $0117);
             WFIFOW( 2, w1);
             WFIFOL( 4, tc.ID);
             WFIFOW( 8, 1);
             WFIFOW(10, xy.X);
             WFIFOW(12, xy.Y);
             WFIFOL(14, timeGetTime());
             SendBCmd(tm, xy, 18);
						 tn := SetSkillUnit(tm, tc.ID, xy, timeGetTime(), $B0, 0, 30000, tc, nil, s);
	      		 tn.MSkill := tc.MSkill;
      		   tn.MUseLV := tc.MUseLV;

					 end else begin
             SendSkillError(tc, 7); //No Red Gemstone
						 //tc.MMode := 4;
						 tc.MPoint.X := 0;
						 tc.MPoint.Y := 0;
						 Exit;
					 end;

          //SetSkillUnit(tm, tc.ID, xy, timeGetTime(), $B0, 0, 30000, tc, nil, s);
        end else begin
           j := SearchCInventory(tc, 1065, false);
					 if ((j <> 0) and (tc.Item[j].Amount >= 1)) then begin
						 UseItem(tc, j);
             WFIFOW( 0, $0117);
             WFIFOW( 2, w1);
             WFIFOL( 4, tc.ID);
             WFIFOW( 8, 1);
             WFIFOW(10, xy.X);
             WFIFOW(12, xy.Y);
             WFIFOL(14, timeGetTime());
             SendBCmd(tm, xy, 18);
						 tn := SetSkillUnit(tm, tc.ID, xy, timeGetTime(), $99, 0, 3000, tc, nil, s);
	      		 tn.MSkill := tc.MSkill;
      		   tn.MUseLV := tc.MUseLV;

					 end else begin
             //SendSkillError(tc, 7); //No Red Gemstone
						 //tc.MMode := 4;
						 tc.MPoint.X := 0;
						 tc.MPoint.Y := 0;
						 Exit;
					 end;
          //SetSkillUnit(tm, tc.ID, xy, timeGetTime(), $99, 0, 30000, tc, nil, s);
        end;
 {
        WFIFOW(0, $01c9);
        WFIFOL(2, 0); // Should be NPC ID of the skillunit...
        WFIFOL(6, tc.ID);
        WFIFOW(10, w2); // Position
        WFIFOW(12, w3);

        if (w1 = $DC) then begin
          WFIFOB(14, $b0);
          WFIFOB(15, 1);  // fail (?)
          WFIFOB(16, 1);  // Message display?
        end else begin
          WFIFOB(14, $99);
          WFIFOB(15, 1);  // fail (?)
          WFIFOB(16, 0);  // Do not display?
        end;

        WFIFOS(17, s, 80); // Write back the message.

        Socket.SendBuf(buf, 97);
 }
      end;
{�A�C�e�������ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
{�A�C�e�������ǉ�}
		$0193: //�w��ID�̃L�����ANPC�̖��O��v��
			begin
				RFIFOL(2, l);
				if Chara.IndexOf(l) <> -1 then begin
					tc := Chara.IndexOfObject(l) as TChara;
						WFIFOW(0, $0194);
						with tc do begin
							WFIFOL( 2, l);
							WFIFOS( 6, Name, 24);
						end;
					Socket.SendBuf(buf, 30);
				end;
			end;
{�A�C�e�������ǉ��R�R�܂�}
		//--------------------------------------------------------------------------
		$0197: //GM Resets
    begin
        RFIFOW(2, w);
        str := IntToStr(w);
        parse_commands(tc, '/R'+str);
    end;
		//--------------------------------------------------------------------------
		$019d: //GM Hide
    begin
        parse_commands(tc, '/H');
    end;
        
		//--------------------------------------------------------------------------
{�L���[�y�b�g}
		$019f: // �y�b�g�e�C�~���O �X���b�g��~
			begin
				if( tc.UseItemID = 0 ) then continue;

				b := 0;
				// l = �����X�^�[ ID
				RFIFOL( 2, l );
				tm := tc.Mdata;
				if tm.Mob.IndexOf( l ) <> -1 then begin
					ts := tm.Mob.IndexOfObject(l) as TMob;

					if PetDB.IndexOf( ts.JID ) <> -1 then begin
						tpd := PetDB.IndexOfObject( ts.JID ) as TPetDB;

						if( tc.UseItemID = tpd.ItemID ) then begin

							// �ߊl���BLUK �Ƃ������߂�Ɗy���������B
							k := tpd.Capture;

							// Pet Capture Multiplier
							k := ((k * Option_Pet_Capture_Rate) div 100);

							//k := 1000;
							if Random(1000) < k then begin

								b := 1;

								// �����X����
								WFIFOW( 0, $0080 );
								WFIFOL( 2, l );
								WFIFOB( 6, 0 );
								SendBCmd( tm, ts.Point, 7 );

								ts.HP := 0;
								ts.pcnt := 0;
								ts.Stat1 :=0;
								ts.Stat2 :=0;
								ts.Element := ts.Data.Element;
								ts.BodyTick := 0;
								for i := 0 to 4 do ts.HealthTick[i] := 0;
								ts.isLooting := False;
								ts.LeaderID := 0;
								ts.SpawnTick := timeGettime();

								i := tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.IndexOf(ts.ID);
								if i = -1 then continue;
								tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.Delete(i);

								//�^�[�Q�b�g����
								for j1 := ts.Point.Y div 8 - 2 to ts.Point.Y div 8 + 2 do begin
									for i1 := ts.Point.X div 8 - 2 to ts.Point.X div 8 + 2 do begin
										for k1 := 0 to tm.Block[i1][j1].CList.Count - 1 do begin
											tc1 := tm.Block[i1][j1].CList.Objects[k1] as TChara;
											if ((tc1.AMode = 1) or (tc1.AMode = 2)) and (tc1.ATarget = ts.ID) then begin
												tc1.AMode := 0;
												tc1.ATarget := 0;
											end;
											if (tc1.MMode <> 0) and (tc1.MTarget = ts.ID) then begin
												tc1.MMode := 0;
												tc1.MTarget := 0;
											end;
										end;
									end;
								end;

								// �o���n���Z�b�g
								for i := 0 to 31 do begin
									ts.EXPDist[i].CData := nil;
									ts.EXPDist[i].Dmg := 0;
								end;

								// MVP �y�b�g�Ȃ�Ă��Ȃ��Ǝv�����ǈꉞ���Z�b�g
								if ts.Data.MEXP <> 0 then begin
									for j := 0 to 31 do begin
										ts.MVPDist[j].CData := nil;
										ts.MVPDist[j].Dmg := 0;
									end;
								end;

								//���҃����X�͏���
								if ts.isSummon then begin
									i := tm.Mob.IndexOf(ts.ID);
									if i <> -1 then begin
										tm.Mob.Delete(i);
										ts.Free;
									end;
								end;

								td := ItemDB.IndexOfObject( tpd.EggID ) as TItemDB;

								// ���l���v���Z�X
								// �d�ʔ���
								if tc.MaxWeight >= tc.Weight + td.Weight then begin
									j := SearchCInventory(tc, td.ID, td.IEquip );
									if j <> 0 then begin
										//�A�C�e���ǉ�

										with tc.Item[j] do begin
											ID := td.ID;
											Amount := tc.Item[j].Amount + 1;
											Equip := 0;
											Identify := 1;
											Refine := 0;
											Attr := 0;
											Card[0] := 0;
											Card[1] := 0;
											Card[2] := 0;
											Card[3] := 0;
											Data := td;
										end;

										// Update weight
										tc.Weight := tc.Weight + td.Weight;
										SendCStat1(tc, 0, $0018, tc.Weight);

										//�A�C�e���Q�b�g�ʒm
										SendCGetItem(tc, j, 1);
									end else begin
										//����ȏ���ĂȂ�
										WFIFOW( 0, $00a0);
										WFIFOB(22, 1);
										Socket.SendBuf(buf, 23);
									end;
								end else begin
									//�d�ʃI�[�o�[
									WFIFOW( 0, $00a0);
									WFIFOB(22, 2);
									Socket.SendBuf(buf, 23);
								end;
							end;
						end;
						tc.UseItemID := 0;
					end;
				end;

				// ���۔���
				WFIFOW( 0, $01a0 );
				WFIFOB( 2, b );
				Socket.SendBuf( buf, 3 );
			end;

		//--------------------------------------------------------------------------
		$01a1: // �y�b�g���j���[
			begin
				RFIFOB( 2, b );
				tm := tc.MData;

				if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin
					tpe := tc.PetData;
					tn := tc.PetNPC;

					case b of
					0: // �y�b�g�X�e�[�^�X�\��
						begin
							WFIFOW( 0, $01a2 );
							WFIFOS( 2, tpe.Name, 24 );
							WFIFOB( 26, tpe.Renamed );
							WFIFOW( 27, tpe.LV );
							WFIFOW( 29, tpe.Fullness );
							WFIFOW( 31, tpe.Relation );
							WFIFOW( 33, tpe.Accessory );
							Socket.SendBuf( buf, 35 );
						end;
					1: // �G�T��������
						begin
							w := 0;
							j := 0;

							for i := 1 to 100 do begin
								if( tc.Item[i].ID = tpe.Data.FoodID ) and ( tc.Item[i].Amount > 0 ) then begin
									w := i;
									break;
								end;
							end;

							if w > 0 then begin

								// �A�C�e������
								Dec(tc.Item[w].Amount);
								if tc.Item[w].Amount = 0 then tc.Item[w].ID := 0;
								tc.Weight := tc.Weight - tc.Item[w].Data.Weight;

								//�A�C�e��������
								WFIFOW( 0, $00af);
								WFIFOW( 2, w);
								WFIFOW( 4, 1);
								Socket.SendBuf( buf, 6 );

								// Update weight
								SendCStat1(tc, 0, $0018, tc.Weight);

								if tpe.Fullness < 26  then tpe.Relation := tpe.Relation + tpe.Data.Hungry
								else if tpe.Fullness >= 76 then  tpe.Relation := tpe.Relation - tpe.Data.Full
								else tpe.Relation := tpe.Relation + ( tpe.Data.Hungry div 2 );

								if tpe.Relation > 1000 then tpe.Relation := 1000
								else if tpe.Relation < 0 then tpe.Relation := 0;

								tpe.Fullness := tpe.Fullness + tpe.Data.Fullness;
								if tpe.Fullness > 100 then tpe.Fullness := 100;

                                                                WFIFOW( 0, $01a4 );
                                                                WFIFOB( 2, 1 );
                                                                WFIFOL( 3, tn.ID );
                                                                WFIFOL( 7, tpe.Relation );
                                                                Socket.SendBuf( buf, 11 );

                                                                WFIFOW( 0, $01a4 );
                                                                WFIFOB( 2, 2 );
                                                                WFIFOL( 3, tn.ID );
                                                                WFIFOL( 7, tpe.Fullness );
                                                                Socket.SendBuf( buf, 11 );

                                                                j := 1;
                                                        end;

                                                        WFIFOW( 0, $01a3 );
                                                        WFIFOB( 2, j );
                                                        WFIFOW( 3, tpe.Data.FoodID );
                                                        Socket.SendBuf( buf, 5 );
                                                end;
												2: // �p�t�H�[�}���X
                                                begin
                                                        // �e���x�������قǁA�����̃A�N�V������������悤�ɂ��Ă݂�
                                                        if tpe.Relation <= 100 then i := 0
                                                        else if tpe.Relation <= 250 then i := 1
                                                        else if tpe.Relation <= 750 then i := 2
                                                        else i := 3;

                                                        WFIFOW( 0, $01a4 );
                                                        WFIFOB( 2, 4 );
                                                        WFIFOL( 3, tn.ID );
                                                        WFIFOL( 7, Random(i) );
                                                        SendBCmd( tm, tn.Point, 11 );
                                                end;
                                                3: // ���ɖ߂�
                                                begin
                                                        for i := 1 to 100 do begin
                                                                if( tc.Item[i].ID <> 0 ) and ( tc.Item[i].Amount > 0 ) and
                                                                ( tc.Item[i].Card[0] = $FF00 ) and ( tc.Item[i].Attr <> 0 ) then begin

                                                                        tc.Item[i].Attr := 0;

                                                                        WFIFOW( 0, $0080 );
                                                                        WFIFOL( 2, tn.ID );
                                                                        WFIFOB( 6, 0 );
                                                                        SendBCmd( tm, tn.Point, 7 );

                                                                        tpe.Incubated := 0;

                                                                        if UseSQL then begin
                                                                          SavePetData(tpe, i, 1);
                                                                        end;
                                                                        //�y�b�g�폜
																		j := tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.IndexOf(tn.ID);
                                                                        if j <> -1 then begin
                                                                                tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.Delete(j);
                                                                        end;

                                                                        j := tm.NPC.IndexOf( tn.ID );
                                                                        if j <> -1 then begin
                                                                                tm.NPC.Delete(j);
                                                                        end;

                                                                        tn.Free;
                                                                        tc.PetData := nil;
                                                                        tc.PetNPC := nil;

                                                                        break;
                                                                end;
                                                        end;

                                                end;
                                                4: // �A�N�Z�T������
                                                begin
                                                        if tpe.Accessory <> 0 then begin

                                                                if ItemDB.IndexOf( tpe.Accessory ) <> -1 then begin
                                                                        td := ItemDB.IndexOfObject( tpe.Accessory ) as TItemDB;

                                                                        // �d�ʔ���
                                                                        if tc.MaxWeight >= tc.Weight + td.Weight then begin
																																								j := SearchCInventory(tc, td.ID, td.IEquip );
                                                                                if j <> 0 then begin
                                                                                        //�A�C�e���ǉ�
                                                                                        tc.Item[j].ID := td.ID;
                                                                                        tc.Item[j].Amount := tc.Item[j].Amount + 1;
                                                                                        tc.Item[j].Equip := 0;
                                                                                        tc.Item[j].Identify := 1;
                                                                                        tc.Item[j].Refine := 0;
                                                                                        tc.Item[j].Attr := 0;
                                                                                        tc.Item[j].Card[0] := 0;
                                                                                        tc.Item[j].Card[1] := 0;
                                                                                        tc.Item[j].Card[2] := 0;
                                                                                        tc.Item[j].Card[3] := 0;

                                                                                        tc.Item[j].Data := td;

                                                                                        //�A�C�e���Q�b�g�ʒm
                                                                                        SendCGetItem(tc, j, 1);

                                                                                        // Update weight
                                                                                        tc.Weight := tc.Weight + td.Weight;
                                                                                        SendCStat1(tc, 0, $0018, tc.Weight);
                                                                                end else begin
                                                                                        //����ȏ���ĂȂ�
                                                                                        WFIFOW( 0, $00a0);
																																												WFIFOB(22, 1);
                                                                                        Socket.SendBuf(buf, 23);
                                                                                end;
                                                                        end else begin
                                                                                //�d�ʃI�[�o�[
                                                                                WFIFOW( 0, $00a0);
                                                                                WFIFOB(22, 2);
                                                                                Socket.SendBuf(buf, 23);
                                                                        end;
                                                                end;
                                                                
                                                                tpe.Accessory := 0;

                                                                WFIFOW( 0, $01a4 );
                                                                WFIFOB( 2, 3 );
                                                                WFIFOL( 3, tn.ID );
                                                                WFIFOL( 7, tpe.Accessory );
                                                                SendBCmd( tm, tn.Point, 11 );

                                                        end;
                                                end;
                                        end;
                                end;
                        end;
                //--------------------------------------------------------------------------
                $01a5: // �y�b�g�̖��O�ύX
                        begin
                                if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin

                                        tpe := tc.PetData;
                                        tn := tc.PetNPC;

                                        str := RFIFOS( 2, 24 );
                                        tn.Name := str;
                                        tpe.Name := str;
                                        tpe.Renamed := 1;

                                        WFIFOW( 0, $0095 );
                                        WFIFOL( 2, tn.ID );
                                        WFIFOS( 6, tn.Name, 24 );
                                        Socket.SendBuf( buf, 30 );
                                end;
                        end;
                //--------------------------------------------------------------------------
                $01a7: // ���z���@�g�p�� ���I��
                        begin
                                // w = ���� index
                                RFIFOW( 2, w );

                                if( tc.Item[tc.UseItemID].Data.Effect = 121 ) and
                                ( tc.Item[w].Data.IType = 4 ) and ( tc.Item[w].Data.Loc = 0 ) and
                                ( tc.Item[w].Data.Effect = 122 ) then begin

				        Dec(tc.Item[tc.UseItemID].Amount);
				        WFIFOW( 0, $00a8);
				        WFIFOW( 2, tc.UseItemID);
								WFIFOW( 4, tc.Item[tc.UseItemID].Amount);
				        WFIFOB( 6, 1);
				        Socket.SendBuf(buf, 7);

				        if tc.Item[tc.UseItemID].Amount = 0 then tc.Item[tc.UseItemID].ID := 0;
				        tc.Weight := tc.Weight - tc.Item[tc.UseItemID].Data.Weight;

				        //�A�C�e��������
				        WFIFOW( 0, $00af);
				        WFIFOW( 2, tc.UseItemID);
				        WFIFOW( 4, 1);

				        //Update weight
				        SendCStat1(tc, 0, $0018, tc.Weight);

                                        tc.UseItemID := 0;

                                        tm := tc.MData;

                                        k := -1;
                                        tpd := PetDB.Objects[0] as TPetDB;
                                        for i := 0 to PetDB.Count - 1 do begin
                                                tpd := PetDB.Objects[i] as TPetDB;
                                                if( tpd.EggID = tc.Item[w].ID ) then begin
                                                        k := tpd.MobID;
																												break;
                                                end;
                                        end;

                                        if ( k <> -1 ) and ( MobDB.IndexOf( k ) <> -1 ) then begin

                                                tmd := MobDB.IndexOfObject( k ) as TMobDB;
                                                tn := TNPC.Create;
                                                tn.ID := NowNPCID;
                                                Inc(NowNPCID);

                                                tpe := nil;

                                                if tc.Item[w].Card[0] = $FF00 then begin
                                                        i := PetList.IndexOf( tc.Item[w].Card[2] + tc.Item[w].Card[3] * $10000 );
                                                        if (i <> -1) then begin
                                                                tpe := PetList.Objects[i] as TPet;
                                                        end;
                                                end;

                                                if tpe = nil then begin
                                                        tpe := TPet.Create;

                                                        tpe.PlayerID := tc.ID;
                                                        tpe.CharaID := tc.CID;
																												if UseSQL then tpe.PetID := GetNowPetID()
                                                        else tpe.PetID := NowPetID;
                                                        tpe.JID := tmd.ID;
                                                        tpe.Name := tmd.JName;
																												tpe.Renamed := 0;
                                                        tpe.LV := tmd.LV;
                                                        tpe.Relation := 250;
                                                        tpe.Fullness := 25;
                                                        tpe.Accessory := 0;
                                                        tpe.Index := w;


                                                        PetList.AddObject( tpe.PetID, tpe );

                                                        tc.Item[w].Card[0] := $FF00;
                                                        tc.Item[w].Card[1] := tpe.PetID;
                                                        tc.Item[w].Card[2] := tpe.PetID mod $10000;
                                                        tc.Item[w].Card[3] := tpe.PetID div $10000;

                                                        if UseSQL then SavePetData(tpe, 0, 1)
																												else Inc( NowPetID );
                                                end;

                                                tpe.MobData := MobDB.IndexOfObject(tpe.JID) as TMobDB;
                                                tn.Name := tpe.Name;
                                                tn.JID := tpe.JID;
                                                tn.Map := tc.Map;

                                                repeat
                                                        tn.Point.X := tc.Point.X + Random(5) - 2;
                                                        tn.Point.Y := tc.Point.Y + Random(5) - 2;
                                                until ( tn.Point.X <> tc.Point.X ) or ( tn.Point.Y <> tc.Point.Y );

                                                tn.Dir := Random(8);
                                                tn.CType := 2;
                                                tn.HungryTick := timeGettime();

																								tpe.Data := tpd;
                                                tpe.Incubated := 1;

                                                tm.NPC.AddObject(tn.ID, tn);
                                                tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);

                                                SendNData(tc.Socket, tn, tc.ver2, tc );
                                                SendBCmd(tm, tn.Point, 41, tc, False);

                                                tc.PetData := tpe;
                                                tc.PetNPC := tn;
                                                tc.Item[w].Attr := 1;

                                                WFIFOW( 0, $01a4 );
                                                WFIFOB( 2, 0 );
                                                WFIFOL( 3, tn.ID );
                                                WFIFOL( 7, 0 );
                                                Socket.SendBuf( buf, 11 );

                                                if tpe.Accessory <> 0 then begin
                                                        WFIFOB( 2, 3 );
                                                        WFIFOL( 7, tpe.Accessory );
                                                        Socket.SendBuf( buf, 11 );
                                                end;

                                                WFIFOB( 2, 5 );
                                                WFIFOL( 7, 20 ); // ��
                                                Socket.SendBuf( buf, 11 );

																								WFIFOW( 0, $01a2 );
                                                WFIFOS( 2, tpe.Name, 24 );
																								WFIFOB( 26, tpe.Renamed );
                                                WFIFOW( 27, tpe.LV );
                                                WFIFOW( 29, tpe.Fullness );
																								WFIFOW( 31, tpe.Relation );
                                                WFIFOW( 33, tpe.Accessory );
                                                Socket.SendBuf( buf, 35 );

                                        end;
                                end;
                        end;
                $01a9: // �G���[�V����
                        begin
                                RFIFOL( 2, l );

                                tm := tc.MData;
                                if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin
                                        tn := tc.PetNPC;

                                        WFIFOW( 0, $01aa );
                                        WFIFOL( 2, tn.ID );
                                        WFIFOL( 6, l );
                                        SendBCmd( tm, tn.Point, 10 );
                                end;
                        end;
{�L���[�y�b�g�����܂�}
		//--------------------------------------------------------------------------
    $01ae:
      begin
              RFIFOW(2, w);
              if (w = 65535) or (w < 1) then continue;

              ma := MArrowDB.IndexOfObject(w) as TMArrowDB;

              for i := 0 to 2 do begin
              if (ma.CID[i] <> 0) then begin
              td := ItemDB.IndexOfObject(ma.CID[i]) as TItemDB;
							if tc.MaxWeight >= tc.Weight + cardinal(td.Weight * ma.CNum[i]) then begin
								k := SearchCInventory(tc, td.ID, td.IEquip);
								if k <> 0 then begin
									if tc.Item[k].Amount < 30000 then begin
									//�A�C�e���ǉ�
									tc.Item[k].ID := td.ID;
                  tc.Item[k].Amount := tc.Item[k].Amount + ma.CNum[i];
                  tc.Item[k].Equip := 0;
                  tc.Item[k].Identify := 1;
                  tc.Item[k].Refine := 0;
                  tc.Item[k].Attr := 0;
                  tc.Item[k].Card[0] := 0;
                  tc.Item[k].Card[1] := 0;
                  tc.Item[k].Card[2] := 0;
                  tc.Item[k].Card[3] := 0;
                  tc.Item[k].Data := td;
									// Update weight
									tc.Weight := tc.Weight + cardinal(td.Weight * ma.CNum[i]);
									SendCStat1(tc, 0, $0018, tc.Weight);

									//�A�C�e���Q�b�g�ʒm
									SendCGetItem(tc, k, ma.CNum[i]);
                end;
								end;
							end else begin
								//�d�ʃI�[�o�[
								WFIFOW( 0, $00a0);
								WFIFOB(22, 2);
								Socket.SendBuf(buf, 23);
							end;
              end;
              end;

                w1 := SearchCInventory(tc,w,false);
                td := tc.Item[w1].Data;
								Dec(tc.Item[w1].Amount);
								WFIFOW( 0, $00a8);
								WFIFOW( 2, w1);
								WFIFOW( 4, tc.Item[w1].Amount);
								WFIFOB( 6, 1);
								Socket.SendBuf(buf, 7);

								if tc.Item[w1].Amount = 0 then tc.Item[w1].ID := 0;
								tc.Weight := tc.Weight - td.Weight;

								WFIFOW( 0, $00af);
								WFIFOW( 2, w1);
								WFIFOW( 4, 1);

								SendCStat1(tc, 0, $0018, tc.Weight);
      end;

		$01af: // Change your cart.
			begin
        tm := tc.MData;
				RFIFOW(2, w);
				case w of
					1: tc.Option := (tc.Option and $F877) or $0008; // Cart 1
					2: tc.Option := (tc.Option and $F877) or $0080; // Cart 2
					3: tc.Option := (tc.Option and $F877) or $0100; // Cart 3
					4: tc.Option := (tc.Option and $F877) or $0200; // Cart 4
					5: tc.Option := (tc.Option and $F877) or $0400; // Cart 5
				end;
				// Send the new option value.
				UpdateOption(tm, tc);

				SendCStat(tc);

			end;
		//--------------------------------------------------------------------------
{�I�X�X�L���ǉ�}
		$01b2: //�I�X�J��
			begin
				{ChrstphrR 2004/05/18 -- no check is made to ensure 1..12 items
				are sent in this packet, with bots sending Shop packets out of
				spec, server crashes can occur with 13 or more items :P~~~
				As crummy as bots are, server crashes are the greater evil.}

				//Occupation and Skill Check - Merchant/BlackSmith/Alchemist
				if (tc.JID <> 5) AND (tc.JID <> 10) AND (tc.JID <> 18) then Continue;
				if (tc.Skill[41].Lv = 0) then Continue;

				//Cancellation Decision
				RFIFOB(84, b);//0= Cancel, 1= Open shop
				if (b = 0) then Continue;

				{ChrstphrR 2004/05/18 - improved error checking for packet length}
				//Check for 2 conditions:
				// A) the Packet Length less header must be divisible by 8
				// B) PL less header div 8 must be a number between 1 and 12
				RFIFOW(2, w);
				if ((w - 85) mod 8 <> 0) AND
				((w - 85) div 8 >= 1) AND ((w - 85) div 8 <= 12) then Continue;
				//--

				TV := TVender.Create;

				//Street stall information settings
				TV.Title := RFIFOS(4, 80);//Title can be up to 79 characters
				for j := 0 to (w - 85) div 8 - 1 do begin
					//ID�`�F�b�N
					RFIFOW(85+j*8, w1);
					if (tc.Cart.Item[w1].ID = 0) then begin
						{ChrstphrR - Exiting early and not cleaning up is BAD
						P.S. - original coders used an exit here because a Continue would
						only skip out of the for loop, not the case branch.}
						TV.Free;
						Exit;//safe 2005/05/18
					end;
					TV.Idx[j] := w1;
					//Check Quantity
					RFIFOW(87+j*8, w2);
					if (w2 > tc.Cart.Item[w1].Amount) then begin
						w2 := tc.Cart.Item[w1].Amount;
					end;
					tv.Amount[j] := w2;
					//Check Price
					RFIFOL(89+j*8, l);//Price
					if (l > 10000000) then l := 10000000;//Upper limit is 10 million
					tv.Price[j] := l;
					//Weight
					td := tc.Cart.Item[w1].Data;
					tv.Weight[j] := td.Weight;
					tv.Cnt := tv.Cnt + 1;
				end;

				tv.ID := tc.ID;
				tv.CID := tc.CID;
				tc.VenderID := tv.ID;
				tv.MaxCnt := tv.Cnt;
				VenderList.AddObject(tv.ID, tv);

				//Delete Item from Cart while vending it.
				for j := 0 to (w - 85) div 8 - 1 do begin
					WFIFOW( 0, $0125);
					WFIFOW( 2, tv.Idx[j]);
					WFIFOL( 4, tv.Amount[j]);
					Socket.SendBuf(buf, 8);
				end;

				//Send reply packet to Character that shop is ready.
				w := 8 + tv.Cnt * 22;
				WFIFOW( 0, $0136);
				WFIFOW( 2, w);
				WFIFOL( 4, tv.CID);
				for j := 0 to tv.Cnt - 1 do begin
					td := tc.Cart.Item[tv.Idx[j]].Data;
					WFIFOL( 8+j*22, tv.Price[j]);
					WFIFOW(12+j*22, tv.Idx[j]);
					WFIFOW(14+j*22, tv.Amount[j]);
					WFIFOB(16+j*22, td.IType);
					WFIFOW(17+j*22, tc.Cart.Item[tv.Idx[j]].ID);
					WFIFOB(19+j*22, tc.Cart.Item[tv.Idx[j]].Identify);
					WFIFOB(20+j*22, tc.Cart.Item[tv.Idx[j]].Attr);
					WFIFOB(21+j*22, tc.Cart.Item[tv.Idx[j]].Refine);
					WFIFOW(22+j*22, tc.Cart.Item[tv.Idx[j]].Card[0]);
					WFIFOW(24+j*22, tc.Cart.Item[tv.Idx[j]].Card[1]);
					WFIFOW(26+j*22, tc.Cart.Item[tv.Idx[j]].Card[2]);
					WFIFOW(28+j*22, tc.Cart.Item[tv.Idx[j]].Card[3]);
				end;
				Socket.SendBuf(buf, w);
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('VenderTitle = %s : OwnerID = %d : OwnerName = %s', [tv.Title, tc.CID, tc.Name]));

				//Notify other characters that this shop is open for business now
				WFIFOW(0, $0131);
				WFIFOL(2, tv.ID);
				WFIFOS(6, tv.Title, 80);
				SendBCmd(tc.MData, tc.Point, 86, tc);
			end;
//--------------------------------------------------------------------------

		$01ce: // Choose AutoCast spell
      begin
        RFIFOL(2, l); // This is the ID of the skill chosen.

        // INFO: This choice is the skill that must be used in autocast.
        // Instead of choosing a random skill when attacking, use this
        // spell to the possible level available.

        tc.Skill[279].Effect1 := l;
      end;
//--------------------------------------------------------------------------
		$01e8: // Request to organize a party - 00f9's updated version
			begin
				str := RFIFOS(2, 24);

        // TODO: These two bytes control item share and loot share.
        RFIFOB(26, b);
        RFIFOB(27, b1);
				if (tc.Skill[1].Lv < 7) and (not DisableSkillLimit) then begin
          w := tc.MSkill;
          // This is for a basic skill.
          tc.MSkill := 1;
          SendSkillError(tc, 0, 4);
          tc.MSkill := w;
				end else begin
					if tc.PartyName <> '' then begin
						i := 2;
					end else if (str = '') or (PartyNameList.IndexOf(str) <> -1) then begin
						i := 1;
					end else begin
						//�p�[�e�B�[�����d�����Ă͂����Ȃ�
						tpa := TParty.Create;

                        tpa.ID := NowPartyID;
                        Inc(NowPartyID);

						tpa.Name := str;
						tpa.EXPShare := False;
						tpa.ITEMShare := True;
						tpa.MemberID[0] := tc.CID; //���[�_:0
						tpa.Member[0] := tc;
                                                if tc.JID = 19 then begin
                                                        tpa.PartyBard[0] := tc;
                                                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Bard Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
                                                end else if tc.JID = 20 then begin
                                                        tpa.PartyDancer[0] := tc;
                                                        //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Dancer Added To Party', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
                                                end;
						tc.PartyName := tpa.Name;
                        tc.PartyID := tpa.ID;
						PartyNameList.AddObject(tpa.Name, tpa);
                        PartyList.AddObject(tpa.ID, tpa);
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('PartyName %s : from %d to %d : ID = %d : Name = %s', [tpa.Name, tpa.MinLV, tpa.MaxLV, tpa.MemberID[0], tpa.Member[0].Name]));
						SendPartyList(tc);
						i := 0;
					end;

					//�p�[�e�B�[�쐬���ۉ���
					WFIFOW( 0, $00fa);
					WFIFOB( 2, i);         // 1:�����` 2:���Ɂ`
					Socket.SendBuf(buf, 3);
				end;
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('PartyNameList.Count = %d', [PartyNameList.Count]));

			end;
{�I�X�X�L���ǉ��R�R�܂�}
		end;
  end;
End;(* Proc sv3PacketProcess()
*-----------------------------------------------------------------------------*)

//==============================================================================
end.

unit GameProcesses;

interface
uses
    {VCL}
    Windows, MMSystem, ScktComp, Forms,
    {Fusion}
    Common, Globals, List32, Script;

    procedure MapConnect(PID: word; Socket: TCustomWinSocket);
    procedure DisplayMap(tc: TChara; Socket : TCustomWinSocket);
    procedure Tick(Socket : TCustomWinSocket);
    procedure CharacterWalk(tc : TChara; Socket : TCustomWinSocket);

implementation

procedure MapConnect(PID: word; Socket: TCustomWinSocket);
    var
        rAID, rCID, id1 : Cardinal;
        tp : TPlayer;
        tc,tc1 : TChara;
        tg : TGuild;
        str : string;
        idx : integer;

    begin
        if PID = $0072 then begin
            RFIFOL(2, rAID);
            RFIFOL(6, rCID);
            RFIFOL(10, id1);
        end else if PID = $00F5 then begin
            //new version
        end;

        if (Player.IndexOf(rAID) <> -1) and (Chara.IndexOf(rCID) <> -1) then begin
            tp := Player.IndexOfObject(rAID) as TPlayer;
            tc := Chara.IndexOfObject(rCID) as TChara;
            if (tp.LoginID1 = id1) and (tp.LoginID1 <> 0) then begin
                tc.ver2 := tp.ver2;
                tc.Login := 1;
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

                if tc.tmpMap <> '' then begin
                    tc.Map := tc.tmpMap;
                    tc.tmpMap := '';
                end;


                if Map.IndexOf(tc.Map) = -1 then MapLoad(tc.Map);

                if GuildList.IndexOf(tc.GuildID) <> -1 then begin
                    tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;
                    WFIFOW( 0, $016d);
					WFIFOL( 2, tc.ID);
					WFIFOL( 6, tc.CID);
					WFIFOL(10, 1);
					SendGuildMCmd(tc, 14, true);
					SendGLoginInfo(tg, tc);
                end;

                //CRW -- Broadcasts Welcome Message to all Users.
                if (Option_WelcomeMsg) then begin
                    str := 'blueWelcome, '+tc.Name+', to the '+ServerName+' Ragnarok Online Server - Powered by Fusion Server Technology';
                    for idx := 0 to CharaName.Count - 1 do begin
                        tc1 := CharaName.Objects[idx] as TChara;
                        if (tc1.Login = 2) then broadcast_handle(tc,tc1,str,false,100);
                    end;
                    broadcast_handle(tc,tc,str,false,100);
                end;

                if (Option_MOTD) then SendMOTD(tc);
                //Read each line of the MOTD, send all but blank lines.
                //Only sent to the character joining.

                tc.OnTouchIDs := TIntList32.Create;

            end else begin
                WFIFOW(0, $0074); //Ç†Ç¡ÇƒÇÈÇ©Ç»ÅH
                WFIFOB(2, 0);
                Socket.SendBuf(buf, 3);
            end;
        end;
    end;

procedure DisplayMap(tc: TChara; Socket : TCustomWinSocket);
    var
        tm : TMap;
        mi : MapTbl;
        i,j,l,k : integer;
        tn : TNPC;
        tc1 : TChara;
        tcr : TChatRoom;
        w : Word;
        ts : TMob;
        tg : TGuild;

    begin
        if tc.tmpMap <> '' then begin
            tc.Map := tc.tmpMap;
            tc.tmpMap := '';
        end;

        if Map.IndexOf(tc.Map) <> - 1 then begin
            tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
            while tm.Mode < 2 do Application.ProcessMessages;
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

                    tc.OnTouchIDs.Clear;

                    //Grace Time
                    if mi.PvPG = true then tc.GraceTick := timeGetTime() + 15000
                    else tc.GraceTick := timeGetTime() + 5000;

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
                            end else tc.HP := 1;
                        end;
                    end;

                    // Reset vending/chat/trade/deal status
                    tc.VenderID := 0;
                    tc.ChatRoomID := 0;
                    tc.DealingID := 0;
                    tc.PreDealID := 0;

                    for j := tc.Point.Y div 8 - 2 to tc.Point.Y div 8 + 2 do begin
                        for i := tc.Point.X div 8 - 2 to tc.Point.X div 8 + 2 do begin
                            //Notify about nearby NPCs
                            for k := 0 to tm.Block[i][j].NPC.Count - 1 do begin
                                tn := tm.Block[i][j].NPC.Objects[k] as TNPC;
                                if (abs(tc.Point.X - tn.Point.X) < 16) and (abs(tc.Point.Y - tn.Point.Y) < 16) then begin
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
                                            //Show NPC chatrooms
                                            if ChatRoomList.IndexOf(tn.ChatRoomID) <> -1 then begin;
                                            tcr := ChatRoomList.Objects[ChatRoomList.IndexOf(tn.ChatRoomID)] as TChatRoom;
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
                                                    if tc.Socket <> nil then tc.Socket.SendBuf(buf, w + 17);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                            //Notify nearby players about you (and you about them)
                            for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
                                tc1 := tm.Block[i][j].CList.Objects[k] as TChara;
                                if (tc <> tc1) and (abs(tc.Point.X - tc1.Point.X) < 16) and (abs(tc.Point.Y - tc1.Point.Y) < 16) then begin
                                    SendCData(tc, tc1);
                                    SendCData(tc1, tc);
                                    //Remove any chats or vends you may have had displayed (after death, perhaps...)
                                    ChatRoomDisp(tc.Socket, tc1);
                                    VenderDisp(tc.Socket, tc1);
                                end;
                            end;
                            //Update about mobs in your range of vision
                            for k := 0 to tm.Block[i][j].Mob.Count - 1 do begin
                                ts := tm.Block[i][j].Mob.Objects[k] as TMob;
                                if (abs(tc.Point.X - ts.Point.X) < 16) and (abs(tc.Point.Y - ts.Point.Y) < 16) then SendMData(Socket, ts);
                            end;
                        end;
                    end;
                    //Update skill list
				    SendCSkillList(tc);
                    //Update character stats
                    CalcStat(tc);
                    SendCStat(tc, true);

                    //Update inventory data
                    WFIFOW(0, $00a3);
                    j := 0;
                    for i := 1 to 100 do begin
                        if (tc.Item[i].ID <> 0) and (not tc.Item[i].Data.IEquip) then begin
                            WFIFOW( 4 +j*10, i);
                            WFIFOW( 6 +j*10, tc.Item[i].Data.ID);
                            WFIFOB( 8 +j*10, tc.Item[i].Data.IType);
                            WFIFOB( 9 +j*10, tc.Item[i].Identify);
                            WFIFOW(10 +j*10, tc.Item[i].Amount);
                            if tc.Item[i].Data.IType = 10 then WFIFOW(12 +j*10, 32768)
                            else WFIFOW(12 +j*10, 0);
                            Inc(j);
                        end;
                    end;
                    WFIFOW(2, 4+j*10);
                    Socket.SendBuf(buf, 4+j*10);
                    //Update equipment data
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
                                else WFIFOW(10 +j*20, Loc);
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

                    //Update arrow equipment status
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
                    w := tc.Option and $0788;
                    if (w <> 0) then SendCart(tc);

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

                    {//Display Your Mercenary
                    if (tc.mercenaryID <> 0) then begin
                        for j := tMerc.Point.Y div 8 - 2 to tMerc.Point.Y div 8 + 2 do begin
                            for i := tMerc.Point.X div 8 - 2 to tMerc.Point.X div 8 + 2 do begin
                                for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
                                    tc := tm.Block[i][j].CList.Objects[k] as TChara;
                                    if tc = nil then continue;
                                    if (abs(tMerc.Point.X - tc.Point.X) < 16) and (abs(tMerc.Point.Y - tc.Point.Y) < 16) then begin
                                        SendMData(tc.Socket, tMerc);
                                        SendBCmd(tm,tMerc.Point,41,tc,False);
                                    end;
                                end;
                            end;
                        end;
                    end;}

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
                        if PetList.IndexOf( tc.Item[j].Card[2] + tc.Item[j].Card[3] * $10000 ) <> -1
                        then SendPetRelocation(tm, tc, i);
                    end;

                    //Get and display the guild news
                    if GuildList.IndexOf(tc.GuildID) <> -1 then begin
                        tg := GuildList.Objects[GuildList.IndexOf(tc.GuildID)] as TGuild;
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
                end;
            end;
        end;

procedure Tick(Socket : TCustomWinSocket);
    begin
        WFIFOW(0, $007f);
        WFIFOL(2, timeGetTime());
        Socket.SendBuf(buf, 6);
    end;

procedure CharacterWalk(tc : TChara; Socket : TCustomWinSocket);
    var xy : TPoint;
    begin
        if (tc.Sit = 1) or (tc.ChatRoomID <> 0) or (tc.VenderID <> 0) then exit;
        RFIFOM1(2, xy);
        tc.NextFlag := true;
        tc.NextPoint := xy;
        if tc.PartyName <> '' then begin
            WFIFOW( 0, $0107);
            WFIFOL( 2, tc.ID);
            WFIFOW( 6, tc.NextPoint.X);
            WFIFOW( 8, tc.NextPoint.Y);
            SendPCmd(tc,10,true,true);
            end;
    end;

end.

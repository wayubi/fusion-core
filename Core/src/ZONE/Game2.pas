unit Game2;

interface
uses GameProcesses, ScktComp, SysUtils, Globals, Dialogs, Common, Classes;

    procedure NEWsv3PacketProcess(Socket: TCustomWinSocket);
    procedure Load_PacketDB;

    type
        TPackets = record
            ID : string;
            Length : integer;
            Command : string;
            ReadPoints : array of integer;
        end;

        PacketArray = record
            Packet : array of TPackets;
        end;
        CodeArray  = array of PacketArray;

    var
        CodeBase : CodeArray;

implementation
//uses Main;

function SearchPacketListing(tc : TChara; Socket : TCustomWinSocket; Ver :integer; pkt : string; plth : integer) :boolean ;
var
    j : integer;
begin
    Result := false;
    for j := 0 to Length(CodeBase[Ver].Packet) - 1 do begin
        if (CodeBase[Ver].Packet[j].ID = pkt) and
        ((CodeBase[Ver].Packet[j].Length = plth) or (CodeBase[Ver].Packet[j].Length = -1) )then begin
            if CodeBase[Ver].Packet[j].Command = 'loadendack' then begin
                DisplayMap(tc,Socket);
                Result := True;
            end else if CodeBase[Ver].Packet[j].Command = 'ticksend' then begin
                Tick(Socket);
                Result := true;
            end else if CodeBase[Ver].Packet[j].Command = 'walktoxy' then begin
                CharacterWalk(CodeBase[Ver].Packet[j].ReadPoints[0],tc,Socket);
                Result := true;
            end else if CodeBase[Ver].Packet[j].Command = 'actionrequest' then begin
                ActionRequest(tc,Socket,CodeBase[Ver].Packet[j].ReadPoints[0],CodeBase[Ver].Packet[j].ReadPoints[1]);
                Result := true;
            end;
        end;
        if Result then break;
    end;
end;

Procedure NEWsv3PacketProcess(Socket: TCustomWinSocket);
var
    lth : integer;
    tc : TChara;
    packetIDnum : word;
    i : integer;
    j : integer;
    found : boolean;
    packet : string;
Begin
    if Socket.ReceiveLength >= 2 then begin
        lth := Socket.ReceiveLength;
        Socket.ReceiveBuf(buf[0], lth);
		RFIFOW(0, packetIDnum);
        packet := '0x' + IntToHex(packetIDnum,4);
		tc := Socket.Data;

        if tc <> nil then debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d CMD %.4x', [tc.ID, packetIDnum]));

        found := false;
        if tc = nil then begin
            for i := (Length(CodeBase) -1) downto 0 do begin

                for j := 0 to Length(CodeBase[i].Packet) - 1 do begin

                    if (CodeBase[i].Packet[j].ID = packet) then begin
                        if (CodeBase[i].Packet[j].Length = lth) then begin
                            if (CodeBase[i].Packet[j].Command = 'wanttoconnection') then begin
                                MapConnect(i, CodeBase[i].Packet[j].ReadPoints[0],
                                    CodeBase[i].Packet[j].ReadPoints[1],
                                    CodeBase[i].Packet[j].ReadPoints[2],Socket);
                                found := true;
                                break;
                            end;
                        end;
                    end;
                end;

                if found then break;
            end;

        if not found then console('IP ' + Socket.RemoteAddress + ' attempted to login with an unknown client');

        end else begin
            if not SearchPacketListing(tc,Socket,tc.clientver,packet,lth) then begin //look for
                if not SearchPacketListing(tc,Socket,0,packet,lth) then Exit;
            end;
        end;
    end;
end;

procedure Load_PacketDB;
    var
        sidx : integer;
        CB : integer;
        PK : integer;
        i : integer;
        packet_db : TStringList;
        sl : TStringList;
        sl2 : TStringList;

    begin
        if FileExists(AppPath + 'database\packet_db.txt') then begin
            packet_db := TStringList.Create;
            sl := TStringList.Create;
            packet_db.LoadFromFile(AppPath + 'database\packet_db.txt'); //load the packet_db file
            CB := 0;
            PK := 0;
            SetLength(CodeBase, CB + 1); //setup the CodeBase for informations
            for sidx := 0 to packet_db.Count - 1 do begin
                if (Copy(packet_db[sidx],1,2) <> '0x') then continue; //we are ignoring comments and other crap

                sl.CommaText := packet_db[sidx];// break up the information by commas

                SetLength(CodeBase[CB].Packet, PK + 1);//Setup the packet array
                //Check for existing packet, if found, start new codebase
                for i := 0 to Length(CodeBase[CB].Packet) - 1 do begin
                    if CodeBase[CB].Packet[i].ID = sl[0] then begin
                        PK := 0; //Preparing for the next CodeBase
                        Inc(CB); //Go to the next codebase
                        SetLength(CodeBase, CB+1); //setup the next codebase
                        SetLength(CodeBase[CB].Packet, PK + 1); //setup the packet record for writing
                        break;
                    end;
                end;

                if (sl.Count >= 2) then begin
                    CodeBase[CB].Packet[PK].ID := sl[0];
                    CodeBase[CB].Packet[PK].Length := StrToInt(sl[1]);//Save the packet length
                end;
                if sl.Count = 4 then begin
                    CodeBase[CB].Packet[PK].Command := sl[2]; //Procedure name to run
                    //Loading all the procedural read packet locations
                    sl2 := TStringList.Create;
                    sl2.Delimiter := ':';
                    sl2.DelimitedText := sl[3];
                    SetLength(CodeBase[CB].Packet[PK].ReadPoints, sl2.Count);
                    for i := 0 to sl2.Count - 1 do CodeBase[CB].Packet[PK].ReadPoints[i] := StrToInt(sl2[i]);

                    sl2.Free;
                end else CodeBase[CB].Packet[PK].Command := 'nocommand';
                Inc(PK);//jump to the next packet record
            end;

            packet_db.Free;
            sl.Free;
        end else begin
            //ShowMessage('Packet_db file not detected, reverting into basic protocal');
            //TestPacketDB := false;
        end;

    end;


end.

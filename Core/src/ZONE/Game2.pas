unit Game2;

interface
uses
    GameProcesses, Common, ScktComp, SysUtils, Globals;

    procedure NEWsv3PacketProcess(Socket: TCustomWinSocket);

implementation

Procedure NEWsv3PacketProcess(Socket: TCustomWinSocket);
var
    length :integer;
    tc : TChara;
    packetID : word;
Begin
    if Socket.ReceiveLength >= 2 then begin
        length := Socket.ReceiveLength;
        Socket.ReceiveBuf(buf[0], length);
		RFIFOW(0, packetID);
		tc := Socket.Data;
        if Option_Packet_Out then debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('3:%.8d CMD %.4x', [tc.ID, packetID]));

        case packetID of
        //Still using case of just to make sure these procedures are working ATM.
        $0072:
            begin
                if (length = 19) or (length >= 19) then MapConnect(packetID, Socket)
                {else console('FAILED')};
                console(IntToStr(length));
            end;

        $007d: DisplayMap(tc,Socket);

		$007e: Tick(Socket);

        $0085: CharacterWalk(tc,Socket);

        end;
    end;
end;


end.

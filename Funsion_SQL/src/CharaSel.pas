unit CharaSel;



interface

uses
//Windows, Forms, Classes, SysUtils, Math, ScktComp, Common;
	Windows, SysUtils, ScktComp, Common, SQLData;

//==============================================================================
// 娭悢掕媊
		procedure sv2PacketProcess(Socket: TCustomWinSocket);
//==============================================================================










implementation
//==============================================================================
// 僉儍儔僙儗僒乕僶乕僷働僢僩張棟
procedure sv2PacketProcess(Socket: TCustomWinSocket);
var
	cmd   :word;
	cnt   :integer;
	i,j,k :integer;
	w     :word;
	l     :cardinal;
	id1   :cardinal;
	id2   :cardinal;
	b     :byte;
	bb    :array[0..5] of byte;
	len   :integer;
	str1  :string;
	tp    :TPlayer;
	tc    :TChara;
        count:integer;
{NPC僀儀儞僩捛壛}
	mi    :MapTbl;
{NPC僀儀儞僩捛壛僐僐傑偱}
begin
	len := Socket.ReceiveLength;
	if len >= 2 then begin
		Socket.ReceiveBuf(buf, len);
		RFIFOW(0, cmd);
		case cmd of
		$0065: //角色XX连接要求
			begin
				RFIFOL( 2, l);
				str1 := IntToStr(l);
				RFIFOL( 6, id1);
				RFIFOL(10, id2);
				if Player.IndexOf(l) <> -1 then begin
					tp := Player.IndexOfObject(l) as TPlayer;
					//if tp.IP = Socket.RemoteAddress then begin
					if (tp.LoginID1 = id1) and (tp.LoginID2 = id2) and (tp.LoginID1 <> 0) then begin
						Socket.Data := tp;
						
						WFIFOL(0, $00000000);
						Socket.SendBuf(buf, 4);

						ZeroMemory(@buf[4], 24);
						WFIFOW(0, $006b);
						cnt := 0;
						if tp.ver2 = 9 then w := 24 else w := 4;
						if tp.ver2 = 9 then j := 5 else j := 3;
						for i := 0 to j - 1 do begin
							if tp.CData[i] <> nil then begin
								ZeroMemory(@buf[w+(cnt*106)], 106);
								tc := tp.CData[i];
								tc.IP := Socket.RemoteAddress;
								tc.tmpMap := '';
								CalcStat(tc);
								for k := 1 to 336 do begin
									tc.Skill[k].Tick := 0;
								end;
								tc.SkillTick := $FFFFFFFF;
								tc.Option := tc.Option and $FFFE;
                                                                if tc.Option = 6 then begin
                                                                        tc.Option := 0;
                                                                        tc.Hidden := false;
                                                                end;
								with tc do begin
									WFIFOL(w+(cnt*106)+  0, CID);
									WFIFOL(w+(cnt*106)+  4, BaseEXP);
									WFIFOL(w+(cnt*106)+  8, Zeny);
									WFIFOL(w+(cnt*106)+ 12, JobEXP);
									WFIFOL(w+(cnt*106)+ 16, JobLV);
									WFIFOL(w+(cnt*106)+ 20, 0);
									WFIFOL(w+(cnt*106)+ 24, 0);
									WFIFOL(w+(cnt*106)+ 28, Option);
									WFIFOL(w+(cnt*106)+ 32, Karma);
									WFIFOL(w+(cnt*106)+ 36, Manner);

									WFIFOW(w+(cnt*106)+ 40, StatusPoint);
									WFIFOW(w+(cnt*106)+ 42, HP);
									WFIFOW(w+(cnt*106)+ 44, MAXHP);
									WFIFOW(w+(cnt*106)+ 46, SP);
									WFIFOW(w+(cnt*106)+ 48, MAXSP);
									WFIFOW(w+(cnt*106)+ 50, Speed);
									WFIFOW(w+(cnt*106)+ 52, JID);
									WFIFOW(w+(cnt*106)+ 54, Hair);
									WFIFOW(w+(cnt*106)+ 56, Weapon);
									WFIFOW(w+(cnt*106)+ 58, BaseLV);
									WFIFOW(w+(cnt*106)+ 60, SkillPoint);
									WFIFOW(w+(cnt*106)+ 62, Head3); //Head
									WFIFOW(w+(cnt*106)+ 64, Shield);
									WFIFOW(w+(cnt*106)+ 66, Head1);
									WFIFOW(w+(cnt*106)+ 68, Head2);
									WFIFOW(w+(cnt*106)+ 70, HairColor);
									WFIFOW(w+(cnt*106)+ 72, ClothesColor);

									WFIFOS(w+(cnt*106)+ 74, Name, 24);

									for k := 0 to 5 do
										WFIFOB(w+(cnt*106)+98+k, ParamBase[k]);
									WFIFOB(w+(cnt*106)+104, CharaNumber);
									WFIFOB(w+(cnt*106)+105, 0);
									Inc(cnt);
								end;
							end;
						end;
						WFIFOW(2, w + cnt * 106);
						Socket.SendBuf(buf, w + cnt * 106);
					end;
				end;
			end;
		$0066: //角色选择要求
			begin
				if Socket.Data = nil then exit;
				tp := Socket.Data;
                                {2重登入检查}
                                    count := 0;
                                    while count < 8 do
                                    begin
                                      if (tp.CData[count] <> nil)and(tp.CData[count].Login <> 0) then
                                      begin
                                        //DebugOut.Lines.Add('2廳儘僌僀儞偝傟傑偟偨丅');
                                        //2廳儘僌僀儞
			        	      WFIFOW( 0, $0081);
			       	              WFIFOB( 2, 08);
			         	      tp.CData[count].Socket.SendBuf(buf, 3);
                                      end;
                                      inc(count);
                                    end;
                                  {2廳儘僌僀儞僠僃僢僋丂偙偙傑偱}

				RFIFOB(2, b);
				if b > 4 then exit;
				if tp.CData[b] <> nil then begin
					tc := tp.CData[b];
{NPC僀儀儞僩捛壛}
					i := MapInfo.IndexOf(tc.Map);
					j := -1;
					if (i <> -1) then begin
						mi := MapInfo.Objects[i] as MapTbl;
						if (mi.noSave = true) then j := 0;
					end;
					if (j = 0) then begin
						tc.Map := tc.SaveMap;
						tc.Point.X := tc.SavePoint.X;
						tc.Point.Y := tc.SavePoint.Y;
					end;
{NPC僀儀儞僩捛壛僐僐傑偱}
					WFIFOW(0, $0071);
					WFIFOL(2, tc.CID);
					WFIFOS(6, tc.Map + '.rsw', 24);
					WFIFOL(22, ServerIP);
					WFIFOW(26, sv3port);
					Socket.SendBuf(buf, 28);
				end;
			end;
		$0067: //人物作成要求
			begin
				if Socket.Data = nil then exit;
				tp := Socket.Data;

				//是否有空格的检查
				RFIFOB(32, b);
				if b > 4 then exit;
				if tp.CData[b] <> nil then begin
					WFIFOW(0, $006e);
					WFIFOB(2, 2);
					Socket.SendBuf(buf, 3);
					exit;
				end;
				//僷儔儊乕僞偵晄惓偑側偄偐僠僃僢僋
				b := 0;
				for i := 0 to 5 do begin
					RFIFOB(i+26, bb[i]);
					if (bb[i] < 1) or (bb[i] > 9) then begin
						WFIFOW(0, $006e);
						WFIFOB(2, 2);
						Socket.SendBuf(buf, 3);
						exit;
					end else begin
						b := b + bb[i];
					end;
				end;
				if b <> 30 then begin
					WFIFOW(0, $006e);
					WFIFOB(2, 2);
					Socket.SendBuf(buf, 3);
					exit;
				end;
				//名字是否已经被使用的检查
				str1 := RFIFOS(2, 24);
				if UseSQL then begin
				  if CheckUserExist(str1) then begin
			  		WFIFOW(0, $006e);
			  		WFIFOB(2, 0);
			  		Socket.SendBuf(buf, 3);
			  		exit;
			  	end;
				end else begin
				  if CharaName.IndexOf(str1) <> -1 then begin
			  		WFIFOW(0, $006e);
			  		WFIFOB(2, 0);
			  		Socket.SendBuf(buf, 3);
			  		exit;
			  	end;
				end;

				//人物数据制作
				tc := TChara.Create;
				with tc do begin
					ID := tp.ID;
					Gender := tp.Gender;
					if UseSQL then CID := GetNowCharaID()
					else begin
					  CID := NowCharaID;
					  Inc(NowCharaID);
					end;
					Name := str1;
					JID := 0;
					BaseLV := 1;
					BaseEXP := 0;
					StatusPoint := 0;
					JobLV := 1;
					JobEXP := 0;
					SkillPoint := 0;
					Zeny := DefaultZeny;
					for i := 0 to 5 do
						ParamBase[i] := bb[i];
					DefaultSpeed := 150;
					RFIFOB(35, b);
					if b > 19 then begin //敮宆偑晄惓
						WFIFOW(0, $006e);
						WFIFOB(2, 2);
						Socket.SendBuf(buf, 3);
						tc.Free;
						exit;
					end;
					Hair := b;
					RFIFOB(33, b);
					if b > 8 then begin //敮偺怓偑晄惓
						WFIFOW(0, $006e);
						WFIFOB(2, 2);
						Socket.SendBuf(buf, 3);
						tc.Free;
						exit;
					end;
					HairColor := b;
					ClothesColor := 0;
					RFIFOB(32, CharaNumber);
					Map := DefaultMap;
					Point.X := DefaultPoint_X;
					Point.Y := DefaultPoint_Y;
					SaveMap := DefaultMap;
					SavePoint.X := DefaultPoint_X;
					SavePoint.Y := DefaultPoint_Y;
					with Item[1] do begin
						ID := DefaultItem1;
						Amount := 1;
						Equip := 2;
						Identify := 1;
						Refine := 0;
						Attr := 0;
						Card[0] := 0;
						Card[1] := 0;
						Card[2] := 0;
						Card[3] := 0;
						Data := ItemDB.IndexOfObject(DefaultItem1) as TItemDB;
					end;
					with Item[2] do begin
						ID := DefaultItem2;
						Amount := 1;
						Equip := 16;
						Identify := 1;
						Refine := 0;
						Attr := 0;
						Card[0] := 0;
						Card[1] := 0;
						Card[2] := 0;
						Card[3] := 0;
						Data := ItemDB.IndexOfObject(DefaultItem2) as TItemDB;
					end;
					for i := 0 to 336 do begin
						if SkillDB.IndexOf(i) <> -1 then begin
							tc.Skill[i].Data := SkillDB.IndexOfObject(i) as TSkillDB;
						end;
					end;
					SkillTick := $FFFFFFFF;
					CalcStat(tc);
					HP := MAXHP;
					SP := MAXSP;
				end;
				CharaName.AddObject(tc.Name, tc);
				Chara.AddObject(tc.CID, tc);
				RFIFOB(32, b);
				tp.CName[b] := tc.Name;
				tp.CData[b] := tc;

				//人物数据传送
				with tc do begin
					WFIFOW(0, $006d);
					WFIFOL(2+	0, CID);
					WFIFOL(2+	4, BaseEXP);
					WFIFOL(2+	8, Zeny);
					WFIFOL(2+ 12, JobEXP);
					WFIFOL(2+ 16, JobLV);
					WFIFOL(2+ 20, 0);
					WFIFOL(2+ 24, 0);
					WFIFOL(2+ 28, Option);
					WFIFOL(2+ 32, Karma);
					WFIFOL(2+ 36, Manner);
					WFIFOW(2+ 40, StatusPoint);
					WFIFOW(2+ 42, HP);
					WFIFOW(2+ 44, MAXHP);
					WFIFOW(2+ 46, SP);
					WFIFOW(2+ 48, MAXSP);
					WFIFOW(2+ 50, Speed);
					WFIFOW(2+ 52, JID);
					WFIFOW(2+ 54, Hair);
					WFIFOW(2+ 56, Weapon);
					WFIFOW(2+ 58, BaseLV);
					WFIFOW(2+ 60, SkillPoint);
					WFIFOW(2+ 62, Head3);
					WFIFOW(2+ 64, Shield);
					WFIFOW(2+ 66, Head1);
					WFIFOW(2+ 68, Head2);
					WFIFOW(2+ 70, HairColor);
					WFIFOW(2+ 72, ClothesColor);
					WFIFOS(2+ 74, Name, 24);
					for i := 0 to 5 do
						WFIFOB(2+98+i, ParamBase[i]);
					WFIFOB(2+104, CharaNumber);
					WFIFOB(2+105, 0);
				end;
				Socket.SendBuf(buf, 108);
			end;
		$0068: //人物删除要求
			begin
				if Socket.Data = nil then exit;
				tp := Socket.Data;

				RFIFOL(2, l);
				str1 := RFIFOS(6, 40);
				if str1 = tp.Mail then begin
					i := Chara.IndexOf(l);
					if (i <> -1) then begin
						//嶍彍丅
						tc := Chara.Objects[i] as TChara;
						for k := 0 to 2 do begin
							if tp.CData[k] = tc then begin
								tp.CName[k] := '';
								tp.CData[k] := nil;
								break;
							end;
						end;
						if UseSQL then
						  DeleteChar(tc.ID);
						CharaName.Delete(i);
						Chara.Delete(i);
						tc.Free;
						WFIFOW(0, $006f);
						Socket.SendBuf(buf, 2);
					end else begin
						//没有发现可以被删除的人物（拒绝删除并返回）
						WFIFOW(0, $0070);
						WFIFOB(2, 1);
						Socket.SendBuf(buf, 3);
					end;
				end else begin
					//E-MAIL地址不对
					WFIFOW(0, $0070);
					WFIFOB(2, 0);
					Socket.SendBuf(buf, 3);
				end;
			end;
		end;
	end;
end;
//==============================================================================
end.


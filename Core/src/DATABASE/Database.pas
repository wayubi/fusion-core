unit Database;



interface

uses
	Windows, MMSystem, Forms, Classes, SysUtils, IniFiles, Common;

//==============================================================================
// �֐���`
		procedure DatabaseLoad(Handle:HWND);
		procedure DataLoad();
    procedure PlayerDataLoad();
		procedure DataSave();
//==============================================================================










implementation
//==============================================================================
// �f�[�^�x�[�X�ǂݍ���
procedure DatabaseLoad(Handle:HWND);
var
	i,j,k,l :integer;
	w		:word;
	xy	:TPoint;
	str :string;
	txt :TextFile;
	sl  :TStringList;
	sl1 :TStringList;
	ta	:TMapList;
	td  :TItemDB;
{�ǉ�}
	wj  :Int64;
{�ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
	tma	:TMaterialDB;
{�A�C�e�������ǉ��R�R�܂�}
{��{���ǉ�}
	tsmn	:TSummon;
  tss   :TSlaveDB;
  tid   :TIDTbl;
  ma    :TMArrowDB;
{��{���ǉ��R�R�܂�}
{�L���[�y�b�g}
        tp      :TPetDB;
{�L���[�y�b�g�����܂�}
{NPC�C�x���g�ǉ�}
	mi  :MapTbl;
{NPC�C�x���g�ǉ��R�R�܂�}
	tb  :TMobDB;
	tl	:TSkillDB;
	sr	:TSearchRec;
	dat :TFileStream;
	jf	:array[0..23] of boolean;
begin
	sl := TStringList.Create;
	sl1 := TStringList.Create;
	//sl.QuoteChar := '"';
	//sl.Delimiter := ',';

	//�e��f�[�^�t�@�C���̑��݂��`�F�b�N
	if not (FileExists(AppPath + 'database\item_db.txt') and
{��{���ǉ��R�R�܂�}
					FileExists(AppPath + 'database\summon_item.txt') and
          //FileExists(AppPath + 'database\summon_slave.txt') and
					FileExists(AppPath + 'database\summon_mob.txt') and
          //FileExists(AppPath + 'database\make_arrow.txt') and
{��{���ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
					FileExists(AppPath + 'database\metalprocess_db.txt') and
{�A�C�e�������ǉ��R�R�܂�}
{�L���[�y�b�g}
          FileExists( AppPath + 'database\pet_db.txt' ) and
{�L���[�y�b�g�����܂�}
					FileExists(AppPath + 'database\mob_db.txt') and
					FileExists(AppPath + 'database\skill_db.txt') and
{�M���h�@�\�ǉ�}
					FileExists(AppPath + 'database\skill_guild_db.txt') and
					FileExists(AppPath + 'database\exp_guild_db.txt') and
{�M���h�@�\�ǉ��R�R�܂�}
					FileExists(AppPath + 'database\exp_db.txt')) then begin
		MessageBox(Handle, 'You have missing files. Go to eWeiss uploader to get them', 'eWeiss', MB_OK or MB_ICONSTOP);
		Application.Terminate;
		exit;
	end;

	//gat�t�@�C���̑��݂��`�F�b�N
	DebugOut.Lines.Add('Map data loading...');
	Application.ProcessMessages;

        if FindFirst(AppPath + 'map\*.map', $27, sr) = 0 then begin
		repeat
			dat := TFileStream.Create(AppPath + 'map\' + sr.Name, fmOpenRead, fmShareDenyWrite);

			SetLength(str, 3);
			dat.Read(str[1], 3);
			if str <> 'MAP' then begin
                                MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
                                Application.Terminate;
                                exit;
			end;

			dat.Read(w, 2);
			dat.Read(xy.X, 4);
			dat.Read(xy.Y, 4);
			dat.Free;
			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;
			//txtDebug.Lines.Add(Format('MapData: %s [%dx%d]', [sr.Name, xy.X, xy.Y]));
			//Application.ProcessMessages;
			ta := TMapList.Create;
			ta.Name := LowerCase(ChangeFileExt(sr.Name, ''));
                        ta.Ext := 'map';
			ta.Size := xy;
			ta.Mode := 0;
			MapList.AddObject(ta.Name, ta);
		until FindNext(sr) <> 0;
		FindClose(sr);
        end;

        if FindFirst(AppPath + 'map\*.dwm', $27, sr) = 0 then begin
		repeat
			dat := TFileStream.Create(AppPath + 'map\' + sr.Name, fmOpenRead, fmShareDenyWrite);

			SetLength(str, 3);
			dat.Read(str[1], 3);
			if str <> 'DWM' then begin
                                MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
                                Application.Terminate;
                                exit;
			end;

			dat.Read(w, 2);
			dat.Read(xy.X, 4);
			dat.Read(xy.Y, 4);
			dat.Free;
			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;
			//txtDebug.Lines.Add(Format('MapData: %s [%dx%d]', [sr.Name, xy.X, xy.Y]));
			//Application.ProcessMessages;
			ta := TMapList.Create;
			ta.Name := LowerCase(ChangeFileExt(sr.Name, ''));
                        ta.Ext := 'dwm';
			ta.Size := xy;
			ta.Mode := 0;
			MapList.AddObject(ta.Name, ta);
		until FindNext(sr) <> 0;
		FindClose(sr);
        end;

        if FindFirst(AppPath + 'map\*.gat', $27, sr) = 0 then begin
		repeat
			dat := TFileStream.Create(AppPath + 'map\' + sr.Name, fmOpenRead, fmShareDenyWrite);

			SetLength(str, 4);
                        dat.Read(str[1], 4);
                        if str <> 'GRAT' then begin
                                MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
                                Application.Terminate;
                                exit;
			end;

			dat.Read(w, 2);
			dat.Read(xy.X, 4);
			dat.Read(xy.Y, 4);
			dat.Free;
			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'eWeiss', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;
			//txtDebug.Lines.Add(Format('MapData: %s [%dx%d]', [sr.Name, xy.X, xy.Y]));
			//Application.ProcessMessages;
			ta := TMapList.Create;
			ta.Name := LowerCase(ChangeFileExt(sr.Name, ''));
                        ta.Ext := 'gat';
			ta.Size := xy;
			ta.Mode := 0;
			MapList.AddObject(ta.Name, ta);
		until FindNext(sr) <> 0;
		FindClose(sr);
	end;
        
	if MapList.IndexOf('prontera') = -1 then begin
		//�Œ���Aprontera.gat���Ȃ��ƋN�����Ȃ�
		MessageBox(Handle, 'prontera map file missing', 'eWeiss', MB_OK or MB_ICONSTOP);
		Application.Terminate;
		exit;
	end;
	DebugOut.Lines.Add(Format('-> Total %d map(s) loaded.', [MapList.Count]));
	Application.ProcessMessages;

	//�A�C�e���f�[�^���[�h
	DebugOut.Lines.Add('Item database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\item_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for i := sl.Count to 43 do
			sl.Add('0');
		for i := 0 to 43 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
		td := TItemDB.Create;
		with td do begin
			ID := StrToInt(sl.Strings[0]);
			Name := sl.Strings[1];
			JName := sl.Strings[2];
			IType := StrToInt(sl.Strings[3]);
			IEquip := ((IType = 4) or (IType = 5));
			Price := StrToInt(sl.Strings[4]);
			Sell := StrToInt(sl.Strings[5]);
			Weight := StrToInt(sl.Strings[6]);
			ATK := StrToInt(sl.Strings[7]);
			MATK := StrToInt(sl.Strings[8]);
			DEF := StrToInt(sl.Strings[9]);
			MDEF := StrToInt(sl.Strings[10]);
			Range := StrToInt(sl.Strings[11]);
			Slot := StrToInt(sl.Strings[12]);
			for i := 0 to 5 do
				Param[i] := StrToInt(sl.Strings[13+i]);
			HIT := StrToInt(sl.Strings[19]);
			FLEE := StrToInt(sl.Strings[20]);
			Crit := StrToInt(sl.Strings[21]);
			Avoid := StrToInt(sl.Strings[22]);
			Cast := StrToInt(sl.Strings[23]);

			Gender := StrToInt(sl.Strings[25]);
			Loc := StrToInt(sl.Strings[26]);
			wLV := StrToInt(sl.Strings[27]);
			eLV := StrToInt(sl.Strings[28]);
			View := StrToInt(sl.Strings[29]);
			Element := StrToInt(sl.Strings[30]);
			Effect := StrToInt(sl.Strings[31]);
                        
{Fix}
			Job := StrToInt64(sl.Strings[24]); 
         if Job <> 0 then begin 
            //Bit recombination 
            for i := 0 to 23 do begin 
               jf[i] := boolean((Job and (1 shl i)) <> 0); 
            end; 
            //             Novice                     swordsman                mage                        archer 
            Job :=       Int64(jf[ 0]) * $0001 + Int64(jf[ 1]) * $0002 + Int64(jf[ 2]) * $0004 + Int64(jf[ 3]) * $0008; 
            //              aco                           merchant                    thief                          knight 
            Job := Job + Int64(jf[ 4]) * $0010 + Int64(jf[ 5]) * $0020 + Int64(jf[ 6]) * $0040 + Int64(jf[ 7]) * $0080; 
            //              priest                          Wizard                       blacksmith                  hunter 
            Job := Job + Int64(jf[10]) * $0100 + Int64(jf[ 8]) * $0200 + Int64(jf[ 11]) * $0400 + Int64(jf[ 9]) * $0800; 
            //          Asassin 
            Job := Job + Int64(jf[12]) * $1000; 
            //�b�� 
            Job := Job or Int64(jf[14]) * $004000;  //Crusader 
            Job := Job or Int64(jf[15]) * $008000;  //Monk 
            Job := Job or Int64(jf[16]) * $010000;  //Sage 
            Job := Job or Int64(jf[17]) * $020000;  //Rouge
            Job := Job or Int64(jf[18]) * $040000;  //Alchemist 
            Job := Job or Int64(jf[19]) * $080000;  //Bard 
            Job := Job or Int64(jf[20]) * $100000;  //Dancer 

            //Crusader Same as a swordsman and knight

            if Boolean(Job and $0002) or Boolean(Job and $0080) then Job := Job or $4000;
            if Boolean(Job and $0001) then Job := Job or $800000;

            //Monk 
            if IType = 5 then begin //Same as aco 
               if Boolean(Job and $0010) or Boolean(Job and $0100) then Job := Job or $8000; 
            end else if IType = 4 then begin //weapons same as aco, knuckle system 
               if Boolean(Job and $0010) then Job := Job or $8000; 
               if View = 12 then Job := Job or $8000; 
            end; 
            //Sage Same attribute as mage 
            if Boolean(Job and $0004) or Boolean(Job and $0200) then Job := Job or $10000; 
               //Possible equiptment 
            if (IType = 4) and (View = 15) then Job := Job or $10000; 
            //Rogue same as hunter. uses bow 
            if Boolean(Job and $0040) then Job := Job or $20000; 
            //Alchemist Same as Blacksmith 
            if Boolean(Job and $0020) or Boolean(Job and $0400) then Job := Job or $40000; 
            //Bard 
            //Dancer 
            if IType = 5 then begin //Same defence equiptment as hunter 
               if Boolean(Job and $0008) or Boolean(Job and $0800) then Job := Job or $180000; 
            end; 
            if IType = 4 then begin 
               if View = 13 then Job := Job or $080000; //Music instrument 
               if View = 14 then Job := Job or $100000; //Whip 
               if View = 11 then begin //Bows equip for both? 
                  if Boolean(Job and $0008) or Boolean(Job and $0800) then Job := Job or $180000; 
                  if Boolean(Job and $0001) then Job := Job or $180000  end;
            end;

			end;
{FIX Stop}
			HP1 := StrToInt(sl.Strings[32]);
			HP2 := StrToInt(sl.Strings[33]);
			SP1 := StrToInt(sl.Strings[34]);
			SP2 := StrToInt(sl.Strings[35]);
			//Rare := StrToBool(sl.Strings[36]);
			//Box := StrToInt(sl.Strings[37]);

			for i := 0 to 9 do begin
				DamageFixR[i] := 0;
				DamageFixE[i] := 0;
			end;
			DamageFixR[StrToInt(sl.Strings[36])] := StrToInt(sl.Strings[37]);
			DamageFixE[StrToInt(sl.Strings[38])] := StrToInt(sl.Strings[39]);
			i := StrToInt(sl.Strings[40]);
			if i <> 0 then begin
				if (i mod 10) = 0 then begin
					SFixPer2[(i div 10)-1] := StrToInt(sl.Strings[41]) div 100;
				end else begin
					SFixPer1[(i mod 10)-1] := StrToInt(sl.Strings[41]) mod 100;
				end;
			end;
			for i := 0 to 336 do AddSkill[i] := 0;
			AddSkill[StrToInt(sl.Strings[42])] := StrToInt(sl.Strings[43]);
				case ID of
				        4115:
                                                begin
					                DrainFix[0] := 3; //�o�O�d�l
					                DrainPer[0] := 15;
                                                end;

				        4082:	DamageFixS[0] := 15; //�e�f�U
				        4092:	DamageFixS[1] := 15; //�X�P���J
				        4126:	DamageFixS[2] := 15; //�~�m�^�E���X

				        4122: //�f�r�A�X
					begin
						DamageFixR[2] := 5;
						DamageFixR[3] := 5;
						DamageFixR[4] := 5;
						DamageFixR[7] := 5;
					end;
                                1131:   {Ice Falchion}
                                        begin
                                                WeaponID := 1131;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 14;
                                                SkillWeapon := true;
                                        end;
                                1133:   {Firebrand}
                                        begin
                                                WeaponID := 1133;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 19;
                                                SkillWeapon := true;
                                        end;
                                1167:   {Schweizersabel}
                                        begin
                                                WeaponID := 1167;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 20;
                                                SkillWeapon := true;
                                        end;
                                1413:   {Gungnir}
                                        begin
                                                GungnirEquipped := true;
                                        end;
                                1468:   {Zephyrus}
                                        begin
                                                WeaponID := 1468;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 21;
                                                SkillWeapon := true;
                                        end;
                                1470:   {Brionic}
                                        begin
                                                WeaponID := 1470;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 13;
                                                SkillWeapon := true;
                                        end;
                                1471:   {Hell Fire}
                                        begin
                                                WeaponID := 1471;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 17;
                                                SkillWeapon := true;
                                        end;
                                1528:   {Grand Cross}
                                        begin
                                                WeaponID := 1528;
                                                WeaponSkillLv := 3;
                                                WeaponSkill := 77;
                                                SkillWeapon := true;
                                        end;

                                1164:   LVL4WeaponASPD := true; {Muramasa}
                                1165:   LVL4WeaponASPD := true; {Masamune}
                                1363:   FastWalk := true;       {Blood Axe}
                                1530:   DoppelgagnerASPD := true;{Mjolnir}
                                1814:   DoppelgagnerASPD := true; {Berserk Knuckle}
                                4047:   GhostArmor := true;     {Ghostring Card}
                                4077:   NoCastInterrupt := true;{Phen Card}
				4147:	SplashAttack := true;   {Baphomet Card}
                                4123:   UnlimitedEndure := true;{Eddgar Card}
                                4128:   NoTarget := true;       {Gold Thief Bug Card}
                                4131:   FastWalk := true;       {Moonlight Card}
                                4132:   NoJamstone := true;     {Mistress Card}
                                4144:   FullRecover := true;    {Osiris Card}
                                4148:   LessSP := true;         {Pharoh Card}
                                4135:   OrcReflect := true;     {Orc Lord Card}
                                4142:   DoppelgagnerASPD := true;{Doppleganger Card}
                                4164:   AnolianReflect := true; {Anolian Card}
                                4146:   MagicReflect := true;   {Maya Card}
                                4137:   PerfectDamage := true;  {Drake Card}

			end;

		end;
		ItemDB.AddObject(td.ID, td);
		ItemDBName.AddObject(td.Name, td);
	end;
        CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d item(s) database loaded.', [ItemDB.Count]));
	Application.ProcessMessages;
{�ǉ�}
	//�A�C�e�������`
	DebugOut.Lines.Add('Special database loading...');
	Application.ProcessMessages;
	if FileExists(AppPath + 'database\special_db.txt') then begin
		AssignFile(txt, AppPath + 'database\special_db.txt');
		Reset(txt);
		Readln(txt, str);
		k := 0;
		while not eof(txt) do begin
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			j := StrToInt(sl[0]);
			if j = 0 then continue;
			i := ItemDB.IndexOf(j);
			if i <> -1 then begin
				td := ItemDB.Objects[i] as TItemDB;
				with td do begin
					for i :=1 to sl.Count - 1 do begin
						//XYZZ
						w := StrToInt(sl.Strings[i]);
						if w > 10000 then begin
							 w := w - 10000;
							 AddSkill[w div 10] := w mod 10 + 1;
						end else begin
							//X = 1:�푰 2:���� 3:�T�C�Y
							case ( w div 1000 ) of
									//�푰 Y = 0:���` 1:�s�� 2:���� 3:�A�� 4:���� 5:���� 6:���� 7:�l�� 8:�V�g 9:����
								1: DamageFixR[( w mod 1000 ) div 100] := w mod 100;
									//���� Y = 0:��, 1:��, 2:�n, 3:��, 4:��, 5:��, 6:��, 7:��, 8:�O, 9:�s��
								2: DamageFixE[( w mod 1000 ) div 100] := w mod 100;
									//�T�C�Y Y = 0:��, 1:��, 2:��
								3: DamageFixS[( w mod 1000 ) div 100] := w mod 100;
									//���1 Y = 01:�Ή� 02:���� 03:�X�^�� 04:���� 05:LexA? 06:�Ή��O�̈ڍs���
								4: SFixPer1[( w mod 1000 ) div 100 -1] := w mod 100;
									//���2 Y = 01:�� 02:�� 03:���� 04:�����H 05:�È�
								5: SFixPer2[( w mod 1000 ) div 100 -1 ] := w mod 100;

								6: begin //HP�z�� XYYZ YY:�z���� Z:�z���m��
										DrainFix[0] := w mod 10;
										DrainPer[0] := ( w mod 1000 ) div 10;
									end;
								7: begin //SP�z�� XYYZ YY:�z���� Z:�z���m��
										DrainFix[1] := w mod 10;
										DrainPer[1] := ( w mod 1000 ) div 10;
									end;
								8: begin	//���̑�
									case ( ( w mod 1000 ) div 100 ) of
										0: SplashAttack := True;
							 			1: NoJamstone := True;
										else //�������Ȃ�
									end;
								end;
								else //�������Ȃ�
							end; // "case ( w div 1000 ) of"
						end;
					end; // "for i :=0 to 3 do"
				end
			end;
			Inc(k);
		end;
		CloseFile(txt);
		DebugOut.Lines.Add(Format('-> Total %d item(s) database change.', [k]));
		Application.ProcessMessages;
	end else begin
		DebugOut.Lines.Add('-> Special database Not Find.');
		Application.ProcessMessages;
	end;
{�ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
	//�A�C�e�������f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('MetalProcess database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\metalprocess_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for i := sl.Count to 8 do
			sl.Add('0');
		for i := 0 to 8 do
			if (i <> 0) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
		tma := TMaterialDB.Create;

		with tma do begin
			ID := StrToInt(sl.Strings[0]);
			ItemLv := StrToInt(sl.Strings[1]);
			RequireSkill := StrToInt(sl.Strings[2]);
			for j := 0 to 2 do begin
				MaterialID[j] := StrToInt(sl.Strings[3+j*2]);
				MaterialAmount[j] := StrToInt(sl.Strings[4+j*2]);
			end;
		end;
		MaterialDB.AddObject(tma.ID, tma);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d metalprocess(s) database loaded.', [MaterialDB.Count]));
	Application.ProcessMessages;
{�A�C�e�������ǉ��R�R�܂�}

	//�����X�^�[�f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('Monster database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\mob_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for i := sl.Count to 54 do
			sl.Add('0');
		for i := 0 to 54 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
		tb := TMobDB.Create;
//ID,Name,JName,LV,HP,SP,EXP,JEXP,Range1,ATK1,ATK2,DEF,MDEF,STR,AGI,VIT,INT,DEX,LUK,
//Range2,Range3,Scale,Race,Element,Mode,Speed,ADelay,aMotion,dMotion,
//Drop1id,Drop1per,Drop2id,Drop2per,Drop3id,Drop3per,Drop4id,Drop4per,
//Drop5id,Drop5per,Drop6id,Drop6per,Drop7id,Drop7per,Drop8id,Drop8per,
//Item1,Item2,MEXP,MVP1id,MVP1per,MVP2id,MVP2per,MVP3id,MVP3per
		with tb do begin
			ID := StrToInt(sl.Strings[0]);
			Name := sl.Strings[1];
			JName := sl.Strings[2];
			LV := StrToInt(sl.Strings[3]);
			HP := StrToInt(sl.Strings[4]);
			SP := StrToInt(sl.Strings[5]);
			EXP := StrToInt(sl.Strings[6]);
			JEXP := StrToInt(sl.Strings[7]);
			Range1 := StrToInt(sl.Strings[8]);
			ATK1 := StrToInt(sl.Strings[9]);
			ATK2 := StrToInt(sl.Strings[10]);
			DEF := StrToInt(sl.Strings[11]);
			MDEF := StrToInt(sl.Strings[12]);
			for j := 0 to 4 do Param[j] := StrToInt(sl.Strings[13+j]);

      LUK := StrToInt(sl.Strings[18]);
			Range2 := StrToInt(sl.Strings[19]);
			Range3 := StrToInt(sl.Strings[20]);
			Scale := StrToInt(sl.Strings[21]);
			Race := StrToInt(sl.Strings[22]);
			Element := StrToInt(sl.Strings[23]);
			Mode := StrToInt(sl.Strings[24]);
			Speed := StrToInt(sl.Strings[25]);
			ADelay := StrToInt(sl.Strings[26]);
			aMotion := StrToInt(sl.Strings[27]);
			dMotion := StrToInt(sl.Strings[28]);

			for j := 0 to 7 do begin
				Drop[j].ID := StrToInt(sl.Strings[29+j*2]);
				Drop[j].Per := StrToInt(sl.Strings[30+j*2]);
				k := ItemDB.IndexOf(Drop[j].ID);
				if k <> -1 then begin
					Drop[j].Data := ItemDB.Objects[k] as TItemDB;
				end else begin
					k := ItemDB.IndexOf(512);
					Drop[j].Data := ItemDB.Objects[k] as TItemDB;
					Drop[j].ID := 512;
					Drop[j].Per := 0;
				end;
			end;
			Item1 := StrToInt(sl.Strings[45]);
			Item2 := StrToInt(sl.Strings[46]);
			MEXP := StrToInt(sl.Strings[47]);
			MEXPPer := StrToInt(sl.Strings[48]);
			for j := 0 to 2 do begin
				MVPItem[j].ID := StrToInt(sl.Strings[49+j*2]);
				MVPItem[j].Per := StrToInt(sl.Strings[50+j*2]);
			end;

			HIT := LV + Param[4];
			FLEE := Lv + Param[2];
			isDontMove := boolean((Mode and 1) = 0);
			isActive := boolean(((Mode and 4) <> 0) and not DisableMonsterActive);
			isLoot := boolean((Mode and 2) <> 0);
			isLink := boolean((Mode and 8) <> 0);


		end;
		MobDB.AddObject(tb.ID, tb);
		MobDBName.AddObject(tb.Name, tb);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d monster(s) database loaded.', [MobDB.Count]));
	Application.ProcessMessages;

{��{���ǉ�}
	//�}�f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('Summon Monster List loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\summon_mob.txt');
	Reset(txt);
	j := 0;
	sl.Clear;
	while not eof(txt) do begin
		Readln(txt, str);
		sl.DelimitedText := str;
		k := StrToInt(sl.Strings[1]);
		if (MobDBName.IndexOf(sl.Strings[0]) <> -1) and (k > 0) then begin
			tsmn := TSummon.Create;
			tsmn.Name := sl.Strings[0];
			for i := 1 to k do begin
				SummonMobList.AddObject(j, tsmn);
				j := j + 1;
			end;
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d Summon Monster List loaded.', [j]));
	Application.ProcessMessages;

	//���f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('Summon Item List loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\summon_item.txt');
	Reset(txt);
	sl.Clear;
	while not eof(txt) do begin
		Readln(txt, str);
		sl.DelimitedText := str;
		k := StrToInt(sl.Strings[2]);
		if (ItemDBName.IndexOf(sl.Strings[0]) = -1) or
			(ItemDBName.IndexOf(sl.Strings[1]) = -1) or (k = 0) then continue;
		tsmn := TSummon.Create;
		tsmn.Name := sl.Strings[1];
		for i := 1 to k do begin
			if (sl.Strings[0] = 'Old_Blue_Box') then begin
				j := SummonIOBList.Count;
				SummonIOBList.AddObject(j, tsmn);
			end else if (sl.Strings[0] = 'Old_Violet_Box') then begin
				j := SummonIOVList.Count;
				SummonIOVList.AddObject(j, tsmn);
			end else if (sl.Strings[0] = 'Old_Card_Album') then begin
				j := SummonICAList.Count;
				SummonICAList.AddObject(j, tsmn);
			end else if (sl.Strings[0] = 'Gift_Box') then begin
				j := SummonIGBList.Count;
				SummonIGBList.AddObject(j, tsmn);
			end;
		end;
	end;
	CloseFile(txt);
	j := SummonIOBList.Count + SummonIOVList.Count + SummonICAList.Count + SummonIGBList.Count;
	DebugOut.Lines.Add(Format('-> Total %d Summon Item List loaded.', [j]));
	Application.ProcessMessages;
{��{���ǉ��R�R�܂�}
{�L���[�y�b�g}
        DebugOut.Lines.Add( 'Pet database loading...' );
        Application.ProcessMessages;
        AssignFile(txt, AppPath + 'database\pet_db.txt' );
        Reset(txt);
        Readln( txt, str );
        while not eof(txt) do begin
                sl.Clear;
                Readln(txt, str);
                sl.DelimitedText := str;

                tp := TPetDB.Create;

                with tp do begin
                        MobID := StrToInt( sl.Strings[0] );
                        ItemID := StrToInt( sl.Strings[1] );
                        EggID := StrToInt( sl.Strings[2] );
                        AcceID := StrToInt( sl.Strings[3] );
                        FoodID := StrToInt( sl.Strings[4] );
                        Fullness := StrToInt( sl.Strings[5] );
                        HungryDelay := StrToInt( sl.Strings[6] );
                        Hungry  := StrToInt( sl.Strings[7] );
                        Full := StrToInt( sl.Strings[8] );
                        Reserved := StrToInt( sl.Strings[9] );
                        Die := StrToInt( sl.Strings[10] );
                        Capture := StrToInt( sl.Strings[11] );
                end;
                PetDB.AddObject( tp.MobID, tp );
        end;
        CloseFile(txt);
        DebugOut.Lines.Add( Format( '-> Total %d pet(s) database loaded.', [PetDB.Count] ) );
        Application.ProcessMessages;
{�L���[�y�b�g�����܂�}
{NPC�C�x���g�ǉ�}
	//mapinfo_db�ǂݍ���
	DebugOut.Lines.Add('Mapinfo database loading...');
	Application.ProcessMessages;
	if FileExists(AppPath + 'database\mapinfo_db.txt') then begin
		AssignFile(txt, AppPath + 'database\mapinfo_db.txt');
		Reset(txt);
		Readln(txt, str);
		k := 0;
		while not eof(txt) do begin
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := LowerCase(str);
			if (sl.Count < 2) then continue;
			sl[0] := ChangeFileExt(sl[0], '');
			if (MapInfo.IndexOf(sl[0]) = -1) then begin
				mi := MapTbl.Create;
				j := 1;
			end else begin
				mi := MapInfo.Objects[MapInfo.IndexOf(sl[0])] as MapTbl;
				j := 0;
			end;
			for i := 1 to sl.Count - 1 do begin
				if (sl[i] = 'nomemo') then mi.noMemo := true
				else if (sl[i] = 'nosave') then mi.noSave := true
				else if (sl[i] = 'noteleport') then mi.noTele := true
{�A�W�g�@�\�ǉ�}
				else if (sl[i] = 'noportal') then mi.noPortal := true
				else if (sl[i] = 'nofly') then mi.noFly := true
				else if (sl[i] = 'nobutterfly') then mi.noBfly := true
				else if (sl[i] = 'nobranch') then mi.noBranch := true
				else if (sl[i] = 'noskill') then mi.noSkill := true
				else if (sl[i] = 'noitem') then mi.noItem := true
				else if (sl[i] = 'agit') then mi.Agit := true
                                else if (sl[i] = 'pvp') then mi.PvP := true
                                else if (sl[i] = 'pvpg') then mi.PvPG := true
                                else if (sl[i] = 'noday') then mi.noday := true;

                                {�A�W�g�@�\�ǉ��R�R�܂�}
			end;
			if (j = 1) then begin
				MapInfo.AddObject(sl[0], mi);
			end;
			Inc(k);
		end;
		CloseFile(txt);
		DebugOut.Lines.Add(Format('-> Total %d MapInfo database loaded.', [k]));
		Application.ProcessMessages;
	end else begin
		DebugOut.Lines.Add('-> Mapinfo database Not Find.');
		Application.ProcessMessages;
	end;
{NPC�C�x���g�ǉ��R�R�܂�}
	//�X�L���f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('Skill database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\skill_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for i := sl.Count to 74 do
			sl.Add('0');
		for i := 0 to 74 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
		tl := TSkillDB.Create;
		with tl do begin
			ID := StrToInt(sl.Strings[0]);
			IDC := sl.Strings[1];
			Name := sl.Strings[2];
			SType := StrToInt(sl.Strings[3]);
			MasterLV := StrToInt(sl.Strings[4]);
			for i := 0 to 9 do
				SP[i+1] := StrToInt(sl.Strings[5+i]);
			HP := StrToInt(sl.Strings[15]);
			UseItem := StrToInt(sl.Strings[16]);
			CastTime1 := StrToInt(sl.Strings[17]);
			CastTime2 := StrToInt(sl.Strings[18]);
			CastTime3 := StrToInt(sl.Strings[19]);
			Range := StrToInt(sl.Strings[20]);
			Element := StrToInt(sl.Strings[21]);
			for i := 0 to 9 do
				Data1[i+1] := StrToInt(sl.Strings[22+i]);
			for i := 0 to 9 do
				Data2[i+1] := StrToInt(sl.Strings[32+i]);
			Range2 := StrToInt(sl.Strings[42]);
			Icon := StrToInt(sl.Strings[43]);
			wj := StrToInt64(sl.Strings[44]);

			for i := 0 to 23 do begin
				Job[i] := boolean((wj and (1 shl i)) <> 0);
			end;

			for i := 0 to 9 do begin
				ReqSkill1[i] := StrToInt(sl.Strings[45+i*2]);
				ReqLV1[i] := StrToInt(sl.Strings[46+i*2]);
			end;
                        for i := 0 to 9 do begin
				ReqSkill2[i] := StrToInt(sl.Strings[55+i*2]);
				ReqLV2[i] := StrToInt(sl.Strings[56+i*2]);
			end;
		end;
		SkillDB.AddObject(tl.ID, tl);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d skill(s) database loaded.', [SkillDB.Count]));
	Application.ProcessMessages;

	//�o���l�e�[�u���ǂݍ���
{�M���h�@�\�ǉ�}
	//�M���h�X�L���f�[�^�x�[�X�ǂݍ���
	DebugOut.Lines.Add('Guild Skill database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\skill_guild_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for i := sl.Count to 74 do
			sl.Add('0');
		for i := 0 to 74 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
		tl := TSkillDB.Create;
		with tl do begin
			ID := StrToInt(sl.Strings[0]);
			IDC := sl.Strings[1];
			Name := sl.Strings[2];
			SType := StrToInt(sl.Strings[3]);
			MasterLV := StrToInt(sl.Strings[4]);
			for i := 0 to 9 do
				SP[i+1] := StrToInt(sl.Strings[5+i]);
			HP := StrToInt(sl.Strings[15]);
			UseItem := StrToInt(sl.Strings[16]);
			CastTime1 := StrToInt(sl.Strings[17]);
			CastTime2 := StrToInt(sl.Strings[18]);
			CastTime3 := StrToInt(sl.Strings[19]);
			Range := StrToInt(sl.Strings[20]);
			Element := StrToInt(sl.Strings[21]);
			for i := 0 to 9 do
				Data1[i+1] := StrToInt(sl.Strings[22+i]);
			for i := 0 to 9 do
				Data2[i+1] := StrToInt(sl.Strings[32+i]);
			Range2 := StrToInt(sl.Strings[42]);
			Icon := StrToInt(sl.Strings[43]);
			wj := StrToInt64(sl.Strings[44]);
			for i := 0 to 23 do begin
				Job[i] := boolean((wj and (1 shl i)) <> 0);
			end;
			for i := 0 to 9 do begin
				ReqSkill1[i] := StrToInt(sl.Strings[45+i*2]);
				ReqLV1[i] := StrToInt(sl.Strings[46+i*2]);
			end;
      for i := 0 to 9 do begin
				ReqSkill2[i] := StrToInt(sl.Strings[55+i*2]);
				ReqLV2[i] := StrToInt(sl.Strings[56+i*2]);
			end;
		end;
		GSkillDB.AddObject(tl.ID, tl);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d guild skill(s) database loaded.', [GSkillDB.Count]));
	Application.ProcessMessages;


  DebugOut.Lines.Add('Slave Summon Mobs List loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\summon_slave.txt');
	Reset(txt);
  Readln(txt, str);
		while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		//for i := sl.Count to 6 do
			//sl.Add('0');
		//for i := 0 to 6 do
			//if (i <> 0) and (sl.Strings[i] = '') then sl.Strings[i] := '0';
    if (sl.Count = 7) then begin
		tss := TSlaveDB.Create;
		with tss do begin
			Name := sl.Strings[0];
      Slaves[0] := MobDBName.IndexOf(sl.Strings[1]);
      Slaves[1] := MobDBName.IndexOf(sl.Strings[2]);
      Slaves[2] := MobDBName.IndexOf(sl.Strings[3]);
      Slaves[3] := MobDBName.IndexOf(sl.Strings[4]);
      Slaves[4] := MobDBName.IndexOf(sl.Strings[5]);
      TotalSlaves := StrToInt(sl.Strings[6]);
    end;
		SlaveDBName.AddObject(tss.Name,tss);
    end;
    end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d Slave Summon Mobs List loaded.', [j]));
	Application.ProcessMessages;

  DebugOut.Lines.Add('Make Arrow List loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\make_arrow.txt');
	Reset(txt);
  Readln(txt, str);
		while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;

    for i := sl.Count to 7 do
			sl.Add('0');
		for i := 0 to 7 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';

		ma := TMArrowDB.Create;
		with ma do begin
			ID := StrToInt(sl.Strings[0]);
      if (sl.Strings[1] <> '') then CID[0] := StrToInt(sl.Strings[1]);
      if (sl.Strings[2] <> '') then CNum[0] := StrToInt(sl.Strings[2]);
      if (sl.Strings[3] <> '') then CID[1] := StrToInt(sl.Strings[3]);
      if (sl.Strings[4] <> '') then CNum[1] := StrToInt(sl.Strings[4]);
      if (sl.Strings[5] <> '') then CID[2] := StrToInt(sl.Strings[5]);
      if (sl.Strings[6] <> '') then CNum[2] := StrToInt(sl.Strings[6]);
    end;
		MArrowDB.AddObject(ma.ID,ma);
    end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d Make Arrow List loaded.', [j]));
	Application.ProcessMessages;


  DebugOut.Lines.Add('ID Table List loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\id_table.txt');
	Reset(txt);
  Readln(txt, str);
		while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;

    for i := sl.Count to 16 do
			sl.Add('0');
		for i := 0 to 16 do
			if (i <> 1) and (i <> 2) and (sl.Strings[i] = '') then sl.Strings[i] := '0';

		tid := TIDTbl.Create;
		with tid do begin
			ID := StrToInt(sl.Strings[0]);
      if (sl.Strings[1] <> '') then BroadCast := StrToInt(sl.Strings[1]);
      if (sl.Strings[2] <> '') then ItemSummon := StrToInt(sl.Strings[2]);
      if (sl.Strings[3] <> '') then MonsterSummon := StrToInt(sl.Strings[3]);
      if (sl.Strings[4] <> '') then ChangeStatSkill := StrToInt(sl.Strings[4]);
      if (sl.Strings[5] <> '') then ChangeOption := StrToInt(sl.Strings[5]);
      if (sl.Strings[6] <> '') then SaveReturn := StrToInt(sl.Strings[6]);
      if (sl.Strings[7] <> '') then ChangeLevel := StrToInt(sl.Strings[7]);
      if (sl.Strings[8] <> '') then Warp := StrToInt(sl.Strings[8]);
      if (sl.Strings[9] <> '') then Whois := StrToInt(sl.Strings[9]);
      if (sl.Strings[10] <> '') then GotoSummonBanish := StrToInt(sl.Strings[10]);
      if (sl.Strings[11] <> '') then KillDieAlive := StrToInt(sl.Strings[11]);
      if (sl.Strings[12] <> '') then ChangeJob := StrToInt(sl.Strings[12]);
      if (sl.Strings[13] <> '') then ChangeColorStyle := StrToInt(sl.Strings[13]);
      if (sl.Strings[14] <> '') then AutoRawUnit := StrToInt(sl.Strings[14]);
      if (sl.Strings[15] <> '') then Refine := StrToInt(sl.Strings[15]);
    end;
		IDTableDB.AddObject(tid.ID,tid);
    end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('-> Total %d ID Table List loaded.', [j]));
	Application.ProcessMessages;



	//�M���h�o���l�e�[�u���ǂݍ���
	DebugOut.Lines.Add('Guild EXP database loading...');
	Application.ProcessMessages;
	for i := 1 to 50 do GExpTable[i] := 1999999999;
	AssignFile(txt, AppPath + 'database\exp_guild_db.txt');
	Reset(txt);
	i := 1;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if sl.Count = 1 then begin
			GExpTable[i] := StrToInt(sl.Strings[0]);
			Inc(i);
			if i > 49 then break;
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> Guild EXP database loaded.');
	Application.ProcessMessages;

	//�G���u�����i�[�f�B���N�g��
	if not DirectoryExists(AppPath + 'emblem') then begin
		if not CreateDir(AppPath + 'emblem') then begin
			MessageBox(Handle, '�G���u�����i�[�f�B���N�g�����쐬�ł��܂���B', 'Weiss', MB_OK or MB_ICONSTOP);
			Application.Terminate;
			exit;
		end;
	end;
{�M���h�@�\�ǉ��R�R�܂�}

	DebugOut.Lines.Add('EXP database loading...');
	Application.ProcessMessages;
	for j := 0 to 3 do ExpTable[j][0] := 1;
	for i := 1 to 255 do begin
		for j := 0 to 3 do ExpTable[j][i] := 999999999;
	end;
	AssignFile(txt, AppPath + 'database\exp_db.txt');
	Reset(txt);
	i := 1;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if sl.Count = 4 then begin
			for j := 0 to 3 do ExpTable[j][i] := StrToInt(sl.Strings[j]);
			Inc(i);
			if i > 255 then break;
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> EXP database loaded.');
	Application.ProcessMessages;
{�C��}
	//�W���u�f�[�^�e�[�u��1�ǂݍ���
	DebugOut.Lines.Add('Job database 1 loading...');
	Application.ProcessMessages;
	for i := 0 to 23 do begin
		WeightTable[i] := 0;
		HPTable[i] := 0;
		SPTable[i] := 1;
		for j := 0 to 16 do WeaponASPDTable[i][j] := 100;
	end;
	AssignFile(txt, AppPath + 'database\job_db1.txt');
	Reset(txt);
	for i := 0 to 23 do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if sl.Count = 20 then begin
			WeightTable[i] := StrToInt(sl.Strings[0]);
			HPTable[i] := StrToInt(sl.Strings[1]);
			SPTable[i] := StrToInt(sl.Strings[2]);
			if SPTable[i] = 0 then SPTable[i] := 1;
			for j := 0 to 16 do WeaponASPDTable[i][j] := StrToInt(sl.Strings[j+3]);
		end else begin
			WeightTable[i] := WeightTable[0];
			HPTable[i] := HPTable[0];
			SPTable[i] := SPTable[0];
			if SPTable[i] = 0 then SPTable[i] := 1;
			for j := 0 to 16 do WeaponASPDTable[i][j] := WeaponASPDTable[0][j];
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> Job database 1 loaded.');
	Application.ProcessMessages;

	//�W���u�f�[�^�e�[�u��2�ǂݍ���
	DebugOut.Lines.Add('Job database 2 loading...');
	Application.ProcessMessages;
	for i := 0 to 23 do begin
		for j := 1 to 255 do JobBonusTable[i][j] := 0;
	end;
	AssignFile(txt, AppPath + 'database\job_db2.txt');
	Reset(txt);
	for i := 0 to 23 do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := 1 to sl.Count do JobBonusTable[i][j] := StrToInt(sl.Strings[j-1]);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> Job database 2 loaded.');
	Application.ProcessMessages;
{�C���R�R�܂�}
	//����_���[�W�C���e�[�u���ǂݍ���
	DebugOut.Lines.Add('Weapon database loading...');
	Application.ProcessMessages;
	for i := 0 to 2 do begin
		for j := 0 to 16 do WeaponTypeTable[i][j] := 100;
	end;
	AssignFile(txt, AppPath + 'database\wp_db.txt');
	Reset(txt);
	for i := 0 to 2 do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := 0 to 16 do WeaponTypeTable[i][j] := StrToInt(sl.Strings[j]);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> Weapon database loaded.');
	Application.ProcessMessages;

	//�����e�[�u���ǂݍ���
	DebugOut.Lines.Add('Element database loading...');
	Application.ProcessMessages;
	for i := 0 to 9 do begin
		for j := 0 to 99 do ElementTable[i][j] := 100;
	end;
	AssignFile(txt, AppPath + 'database\ele_db.txt');
	Reset(txt);
	for i := 0 to 9 do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := sl.Count to 19 do sl.Add('100');
		for j := 0 to 19 do ElementTable[i][j] := StrToInt(sl.Strings[j]);
		//---
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := sl.Count to 19 do sl.Add('100');
		for j := 0 to 19 do ElementTable[i][j+23] := StrToInt(sl.Strings[j]);
		//---
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := sl.Count to 19 do sl.Add('100');
		for j := 0 to 19 do ElementTable[i][j+40] := StrToInt(sl.Strings[j]);
		//---
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := sl.Count to 19 do sl.Add('100');
		for j := 0 to 19 do ElementTable[i][j+60] := StrToInt(sl.Strings[j]);
		//---
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := sl.Count to 19 do sl.Add('100');
		for j := 0 to 19 do ElementTable[i][j+80] := StrToInt(sl.Strings[j]);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add('-> Element database loaded.');
	Application.ProcessMessages;

	//�X�N���v�g�t�@�C���̃��X�g���쐬
	DebugOut.Lines.Add('Making script list...');
	Application.ProcessMessages;
	sl.Clear;
	sl1.Clear;
	sl.Add(AppPath + 'script\');
	sl1.Add(AppPath + 'script\');
	while sl.Count <> 0 do begin
		for i := 0 to sl.Count - 1 do begin
			if FindFirst(sl.Strings[0] + '*', $10, sr) = 0 then begin
				repeat
					if ((sr.Attr and $10) <> 0) and (sr.Name <> '.') and (sr.Name <> '..') then begin
						sl.Add(sl.Strings[0] + sr.Name + '\');
						sl1.Add(sl.Strings[0] + sr.Name + '\');
					end;
				until FindNext(sr) <> 0;
				FindClose(sr);
			end;
			sl.Delete(0);
		end;
	end;
	ScriptList.Clear;
	for i := 0 to sl1.Count - 1 do begin
		if FindFirst(sl1.Strings[i] + '*.txt', $27, sr) = 0 then begin
			repeat
				ScriptList.Add(sl1.Strings[i] + sr.Name);
			until FindNext(sr) <> 0;
			FindClose(sr);
		end;
	end;

	sl.Free;
end;
//------------------------------------------------------------------------------
// �f�[�^�ǂݍ���
procedure PlayerDataLoad();
var
	i,j,k :integer;
	i1  :integer;
	ver :integer;
	str :string;
	txt :TextFile;
	sl  :TStringList;
	ta	:TMapList;
	tp  :TPlayer;
	tc  :TChara;
{�p�[�e�B�[�@�\�ǉ�}
	tpa	:TParty;
  tgc :TCastle;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
				tpe     :TPet;
				tpd     :TPetDB;
				tmd     :TMobDB;
{�L���[�y�b�g�����܂�}
{�M���h�@�\�ǉ�}
	tg  :TGuild;
	tgb :TGBan;
	tgl :TGRel;
{�M���h�@�\�ǉ��R�R�܂�}
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

	//player.txt,chara.txt�`�F�b�N
	if not FileExists(AppPath + 'player.txt') then begin
		AssignFile(txt, AppPath + 'player.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.PlayerData.0x0003');
		Writeln(txt, '100001,test,test,0,-@-,0,,,,,,,,,');
		Writeln(txt, '0');
		Writeln(txt, '100002,test2,test,1,-@-,0,,,,,,,,,');
		Writeln(txt, '0');
		CloseFile(txt);
	end;

  DebugOut.Lines.Add('Player data loading...');
	Application.ProcessMessages;
	ver := 0;
	AssignFile(txt, AppPath + 'player.txt');
	Reset(txt);
	Readln(txt, str);
	if str = '##Weiss.PlayerData.0x0003' then begin
		ver := 3;
	end else if str = '##Weiss.PlayerData.0x0002' then begin
		ver := 2;
	end else if str = '##Weiss.PlayerData.0x0001' then begin
		ver := 1;
	end else begin
		Reset(txt);
	end;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if ver >= 1 then begin
{�C��}
			if (sl.Count = 9) or (sl.Count = 15) then begin
				tp := TPlayer.Create;
				with tp do begin
					ID := StrToInt(sl.Strings[0]);
					Name := sl.Strings[1];
					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					GMMode := StrToInt(sl.Strings[5]);
					CName[0] := sl.Strings[6];
					CName[1] := sl.Strings[7];
					CName[2] := sl.Strings[8];
					if sl.Count = 15 then begin
						CName[3] := sl.Strings[9];
						CName[4] := sl.Strings[10];
						CName[5] := sl.Strings[11];
						CName[6] := sl.Strings[12];
						CName[7] := sl.Strings[13];
						CName[8] := sl.Strings[14];
					end;
				end;
{�C���R�R�܂�}
				if ver >= 2 then begin
					//�A�C�e�����[�h
					sl.Clear;
					Readln(txt, str);
					sl.DelimitedText := str;
					j := StrToInt(sl.Strings[0]);
					for i := 1 to j do begin
						if ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1])) <> -1 then begin
							//tc.Item[i] := TItem.Create;
							tp.Kafra.Item[i].ID := StrToInt(sl.Strings[(i-1)*10+1]);
							tp.Kafra.Item[i].Amount := StrToInt(sl.Strings[(i-1)*10+2]);
							tp.Kafra.Item[i].Equip := StrToInt(sl.Strings[(i-1)*10+3]);
							tp.Kafra.Item[i].Identify := StrToInt(sl.Strings[(i-1)*10+4]);
							tp.Kafra.Item[i].Refine := StrToInt(sl.Strings[(i-1)*10+5]);
							tp.Kafra.Item[i].Attr := StrToInt(sl.Strings[(i-1)*10+6]);
							for k := 0 to 3 do begin
								tp.Kafra.Item[i].Card[k] := StrToInt(sl.Strings[(i-1)*10+7+k]);
							end;
							tp.Kafra.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1]))] as TItemDB;
						end;
					end;
					CalcInventory(tp.Kafra);
				end;
				PlayerName.AddObject(tp.Name, tp);
				Player.AddObject(tp.ID, tp);
			end;
		end else begin
			if sl.Count = 8 then begin
				tp := TPlayer.Create;
				with tp do begin
					ID := StrToInt(sl.Strings[0]);
					Name := sl.Strings[1];
					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					GMMode := 0;
					CName[0] := sl.Strings[5];
					CName[1] := sl.Strings[6];
					CName[2] := sl.Strings[7];
				end;
				PlayerName.AddObject(tp.Name, tp);
				Player.AddObject(tp.ID, tp);
			end;
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d player(s) data loaded.', [PlayerName.Count]));
	Application.ProcessMessages;

  if (PlayerName.Count <= 0) then Exit;

  for i := 0 to PlayerName.Count - 1 do begin
		tp := PlayerName.Objects[i] as TPlayer;
                tp.ver2 := 9;
                if tp.ver2 = 9 then i1 := 8
	        else i1 := 2;

		for j := 0 to i1 do begin
			if tp.CName[j] <> '' then begin
				k := CharaName.IndexOf(tp.CName[j]);
				if k <> -1 then begin
					tp.CData[j] := CharaName.Objects[k] as TChara;
					tp.CData[j].CharaNumber := j;
					tp.CData[j].ID := tp.ID;
					tp.CData[j].Gender := tp.Gender;
				end else begin
					tp.CName[j] := '';
					tp.CData[j] := nil;
				end;
			end;
		end;
	end;

  sl.Free;

  end;
//------------------------------------------------------------------------------
// �f�[�^�ǂݍ���
procedure DataLoad();
var
	i,j,k :integer;
	i1  :integer;
	ver :integer;
	str :string;
	txt :TextFile;
	sl  :TStringList;
	ta	:TMapList;
	tp  :TPlayer;
	tc  :TChara;
{�p�[�e�B�[�@�\�ǉ�}
	tpa	:TParty;
  tgc :TCastle;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
				tpe     :TPet;
				tpd     :TPetDB;
				tmd     :TMobDB;
{�L���[�y�b�g�����܂�}
{�M���h�@�\�ǉ�}
	tg  :TGuild;
	tgb :TGBan;
	tgl :TGRel;
{�M���h�@�\�ǉ��R�R�܂�}
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

	//player.txt,chara.txt�`�F�b�N
	if not FileExists(AppPath + 'player.txt') then begin
		AssignFile(txt, AppPath + 'player.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.PlayerData.0x0003');
		Writeln(txt, '100001,test,test,0,-@-,0,,,,,,,,,');
		Writeln(txt, '0');
		Writeln(txt, '100002,test2,test,1,-@-,0,,,,,,,,,');
		Writeln(txt, '0');
		CloseFile(txt);
	end;
	if not FileExists(AppPath + 'chara.txt') then begin
		AssignFile(txt, AppPath + 'chara.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.CharaData.0x0002');
		CloseFile(txt);
	end;
{�p�[�e�B�[�@�\�ǉ�}
	if not FileExists(AppPath + 'party.txt') then begin
		AssignFile(txt, AppPath + 'party.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.PartyData.0x0002');
		CloseFile(txt);
	end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
	if not FileExists(AppPath + 'pet.txt') then begin
		AssignFile(txt, AppPath + 'pet.txt');
		Rewrite(txt);
                Writeln( txt, '##Weiss.PetData.0x0002' );
		CloseFile(txt);
	end;

  if not FileExists(AppPath + 'gcastle.txt') then begin
		AssignFile(txt, AppPath + 'gcastle.txt');
		Rewrite(txt);
    Writeln( txt, '##Weiss.GCastleData.0x0002' );
		CloseFile(txt);
	end;
{�L���[�y�b�g�����܂�}
{NPC�C�x���g�ǉ�}
	//status.txt�`�F�b�N
	if not FileExists(AppPath + 'status.txt') then begin
		AssignFile(txt, AppPath + 'status.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.StatusData.0x0002');
		Writeln(txt, '0');
		CloseFile(txt);
	end else begin
		//�T�[�o���L�t���O�Ǎ�
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
{NPC�C�x���g�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
	if not FileExists(AppPath + 'guild.txt') then begin
		AssignFile(txt, AppPath + 'guild.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.GuildData.0x0002');
		CloseFile(txt);
	end;
{�M���h�@�\�ǉ��R�R�܂�}
	//�A�J�E���g��񃍁[�h
	DebugOut.Lines.Add('Player data loading...');
	Application.ProcessMessages;
	ver := 0;
	AssignFile(txt, AppPath + 'player.txt');
	Reset(txt);
	Readln(txt, str);
	if str = '##Weiss.PlayerData.0x0003' then begin
		ver := 3;
	end else if str = '##Weiss.PlayerData.0x0002' then begin
		ver := 2;
	end else if str = '##Weiss.PlayerData.0x0001' then begin
		ver := 1;
	end else begin
		Reset(txt);
	end;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if ver >= 1 then begin
{�C��}
			if (sl.Count = 9) or (sl.Count = 15) then begin
				tp := TPlayer.Create;
				with tp do begin
					ID := StrToInt(sl.Strings[0]);
					Name := sl.Strings[1];
					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					GMMode := StrToInt(sl.Strings[5]);
					CName[0] := sl.Strings[6];
					CName[1] := sl.Strings[7];
					CName[2] := sl.Strings[8];
					if sl.Count = 15 then begin
						CName[3] := sl.Strings[9];
						CName[4] := sl.Strings[10];
						CName[5] := sl.Strings[11];
						CName[6] := sl.Strings[12];
						CName[7] := sl.Strings[13];
						CName[8] := sl.Strings[14];
					end;
				end;
{�C���R�R�܂�}
				if ver >= 2 then begin
					//�A�C�e�����[�h
					sl.Clear;
					Readln(txt, str);
					sl.DelimitedText := str;
					j := StrToInt(sl.Strings[0]);
					for i := 1 to j do begin
						if ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1])) <> -1 then begin
							//tc.Item[i] := TItem.Create;
							tp.Kafra.Item[i].ID := StrToInt(sl.Strings[(i-1)*10+1]);
							tp.Kafra.Item[i].Amount := StrToInt(sl.Strings[(i-1)*10+2]);
							tp.Kafra.Item[i].Equip := StrToInt(sl.Strings[(i-1)*10+3]);
							tp.Kafra.Item[i].Identify := StrToInt(sl.Strings[(i-1)*10+4]);
							tp.Kafra.Item[i].Refine := StrToInt(sl.Strings[(i-1)*10+5]);
							tp.Kafra.Item[i].Attr := StrToInt(sl.Strings[(i-1)*10+6]);
							for k := 0 to 3 do begin
								tp.Kafra.Item[i].Card[k] := StrToInt(sl.Strings[(i-1)*10+7+k]);
							end;
							tp.Kafra.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1]))] as TItemDB;
						end;
					end;
					CalcInventory(tp.Kafra);
				end;
				PlayerName.AddObject(tp.Name, tp);
				Player.AddObject(tp.ID, tp);
			end;
		end else begin
			if sl.Count = 8 then begin
				tp := TPlayer.Create;
				with tp do begin
					ID := StrToInt(sl.Strings[0]);
					Name := sl.Strings[1];
					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					GMMode := 0;
					CName[0] := sl.Strings[5];
					CName[1] := sl.Strings[6];
					CName[2] := sl.Strings[7];
				end;
				PlayerName.AddObject(tp.Name, tp);
				Player.AddObject(tp.ID, tp);
			end;
		end;
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d player(s) data loaded.', [PlayerName.Count]));
	Application.ProcessMessages;

	//�L������񃍁[�h
	DebugOut.Lines.Add('Character data loading...');
	Application.ProcessMessages;
	ver := 0;
	AssignFile(txt, AppPath + 'chara.txt');
	Reset(txt);
	Readln(txt, str);
	if str = '##Weiss.CharaData.0x0002' then begin
		ver := 2;
	end else if str = '##Weiss.CharaData.0x0001' then begin
		ver := 1;
	end else begin
		Reset(txt);
	end;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if ver >= 1 then begin
{�p�[�e�B�[�@�\�C��}
			if (sl.Count <> 50) and (sl.Count <> 51) and (sl.Count <> 52) and (sl.Count <> 53) then continue;
{�p�[�e�B�[�@�\�C���R�R�܂�}
		end else begin
			if sl.Count <> 41 then continue;
		end;
		tc := TChara.Create;
		with tc do begin
			CID           := StrToInt(sl.Strings[ 0]);
			Name          :=          sl.Strings[ 1];
			JID           := StrToInt(sl.Strings[ 2]);
			BaseLV        := StrToInt(sl.Strings[ 3]);
			BaseEXP       := StrToInt(sl.Strings[ 4]);
			StatusPoint   := StrToInt(sl.Strings[ 5]);
			JobLV         := StrToInt(sl.Strings[ 6]);
			JobEXP        := StrToInt(sl.Strings[ 7]);
			SkillPoint    := StrToInt(sl.Strings[ 8]);
			Zeny          := StrToInt(sl.Strings[ 9]);
{�C��}
			Stat1         := StrToInt(sl.Strings[10]);
			Stat2         := StrToInt(sl.Strings[11]);
{�C���R�R�܂�}
			Option        := StrToInt(sl.Strings[12]);
			Karma         := StrToInt(sl.Strings[13]);
			Manner        := StrToInt(sl.Strings[14]);

			HP            := StrToInt(sl.Strings[15]);
			SP            := StrToInt(sl.Strings[16]);
			DefaultSpeed  := StrToInt(sl.Strings[17]);
			Hair          := StrToInt(sl.Strings[18]);
			_2            := StrToInt(sl.Strings[19]);
			_3            := StrToInt(sl.Strings[20]);
			Weapon        := StrToInt(sl.Strings[21]);
			Shield        := StrToInt(sl.Strings[22]);
			Head1         := StrToInt(sl.Strings[23]);
			Head2         := StrToInt(sl.Strings[24]);
			Head3         := StrToInt(sl.Strings[25]);
			HairColor     := StrToInt(sl.Strings[26]);
			ClothesColor  := StrToInt(sl.Strings[27]);

			for i := 0 to 5 do
			ParamBase[i] := StrToInt(sl.Strings[28+i]);
			CharaNumber   := StrToInt(sl.Strings[34]);

			Map           :=          sl.Strings[35];
			Point.X       := StrToInt(sl.Strings[36]);
			Point.Y       := StrToInt(sl.Strings[37]);
			SaveMap       :=          sl.Strings[38];
			SavePoint.X   := StrToInt(sl.Strings[39]);
			SavePoint.Y   := StrToInt(sl.Strings[40]);

      if (sl.Count = 52) then begin
      Plag := StrToInt(sl.Strings[50]);
      PLv := StrToInt(sl.Strings[51]);
      end;
      if (sl.Count = 53) then begin
      Plag := StrToInt(sl.Strings[51]);
      PLv := StrToInt(sl.Strings[52]);
      end;

			if ver >= 1 then begin
				for i := 0 to 2 do begin
					MemoMap[i]     :=          sl.Strings[41+i*3];
					MemoPoint[i].X := StrToInt(sl.Strings[42+i*3]);
					MemoPoint[i].Y := StrToInt(sl.Strings[43+i*3]);
				end;
			end else begin
				for i := 0 to 2 do begin
					MemoMap[i]     := '';
					MemoPoint[i].X := 0;
					MemoPoint[i].Y := 0;
				end;
			end;

{�A�C�e�������֌W�ǉ�}
		if CID < 100001 then CID := CID + 100001;
{�A�C�e�������֌W�ǉ�}
			if CID >= NowCharaID then NowCharaID := CID + 1;

			//�}�b�v���݃`�F�b�N
			if MapList.IndexOf(Map) = -1 then begin
				DebugOut.Lines.Add(Format('%s : Invalid Map "%s"', [Name, Map]));
				Map := 'prontera';
				Point.X := 158;
				Point.Y := 189;
			end;
			//���W�`�F�b�N
			ta := MapList.Objects[MapList.IndexOf(Map)] as TMapList;
			if (Point.X < 0) or (Point.X >= ta.Size.X) or (Point.Y < 0) or (Point.Y >= ta.Size.Y) then begin
				DebugOut.Lines.Add(Format('%s : Invalid Map Point "%s"[%dx%d] (%d,%d)',[Name, Map, ta.Size.X, ta.Size.Y, Point.X, Point.Y]));
				Map := 'prontera';
				Point.X := 158;
				Point.Y := 189;
			end;

			//�}�b�v���݃`�F�b�N
			if MapList.IndexOf(SaveMap) = -1 then begin
				DebugOut.Lines.Add(Format('%s : Invalid SaveMap "%s"', [Name, SaveMap]));
				SaveMap := 'prontera';
				SavePoint.X := 158;
				SavePoint.Y := 189;
			end;
			//���W�`�F�b�N
			ta := MapList.Objects[MapList.IndexOf(SaveMap)] as TMapList;
			if (SavePoint.X < 0) or (SavePoint.X >= ta.Size.X) or (SavePoint.Y < 0) or (SavePoint.Y >= ta.Size.Y) then begin
				DebugOut.Lines.Add(Format('%s : Invalid SaveMap Point "%s"[%dx%d] (%d,%d)', [Name, SaveMap, ta.Size.X, ta.Size.Y, SavePoint.X, SavePoint.Y]));
				SaveMap := 'prontera';
				SavePoint.X := 158;
				SavePoint.Y := 189;
			end;

			for i := 0 to 2 do begin
				//�}�b�v���݃`�F�b�N
				if (MemoMap[i] <> '') and (MapList.IndexOf(MemoMap[i]) = -1) then begin
					DebugOut.Lines.Add(Format('%s : Invalid MemoMap%d "%s"', [Name, i, MemoMap[i]]));
					MemoMap[i] := '';
					MemoPoint[i].X := 0;
					MemoPoint[i].Y := 0;
				end else if MemoMap[i] <> '' then begin
					//���W�`�F�b�N
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
		end;
		//�X�L�����[�h
		for i := 0 to 336 do begin
			if SkillDB.IndexOf(i) <> -1 then begin
				tc.Skill[i].Data := SkillDB.IndexOfObject(i) as TSkillDB;
			end;
		end;
    if (tc.Plag <> 0) then begin
    tc.Skill[tc.Plag].Plag := true;
    end;

		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		j := StrToInt(sl.Strings[0]);
		for i := 1 to j do begin
			if SkillDB.IndexOf(StrToInt(sl.Strings[(i-1)*2+1])) <> -1 then begin
				k := StrToInt(sl.Strings[(i-1)*2+1]);
				tc.Skill[k].Lv := StrToInt(sl.Strings[(i-1)*2+2]);
				tc.Skill[k].Card := false;
        tc.Skill[k].Plag := false;
			end;
		end;
		//�A�C�e�����[�h
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		j := StrToInt(sl.Strings[0]);
		for i := 1 to j do begin
			if ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1])) <> -1 then begin
				tc.Item[i].ID := StrToInt(sl.Strings[(i-1)*10+1]);
				tc.Item[i].Amount := StrToInt(sl.Strings[(i-1)*10+2]);
				tc.Item[i].Equip := StrToInt(sl.Strings[(i-1)*10+3]);
				tc.Item[i].Identify := StrToInt(sl.Strings[(i-1)*10+4]);
				tc.Item[i].Refine := StrToInt(sl.Strings[(i-1)*10+5]);
				tc.Item[i].Attr := StrToInt(sl.Strings[(i-1)*10+6]);
				for k := 0 to 3 do begin
					tc.Item[i].Card[k] := StrToInt(sl.Strings[(i-1)*10+7+k]);
				end;
				tc.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1]))] as TItemDB;
			end;
		end;
		if ver >= 2 then begin
			//�J�[�g�A�C�e�����[�h
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			j := StrToInt(sl.Strings[0]);
{�J�[�g�@�\�ǉ�}
			//�J�[�g���̃A�C�e������
			tc.Cart.Count := j;
{�J�[�g�@�\�ǉ��R�R�܂�}			for i := 1 to j do begin
				if ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1])) <> -1 then begin
					tc.Cart.Item[i].ID := StrToInt(sl.Strings[(i-1)*10+1]);
					tc.Cart.Item[i].Amount := StrToInt(sl.Strings[(i-1)*10+2]);
					tc.Cart.Item[i].Equip := StrToInt(sl.Strings[(i-1)*10+3]);
					tc.Cart.Item[i].Identify := StrToInt(sl.Strings[(i-1)*10+4]);
					tc.Cart.Item[i].Refine := StrToInt(sl.Strings[(i-1)*10+5]);
					tc.Cart.Item[i].Attr := StrToInt(sl.Strings[(i-1)*10+6]);
					for k := 0 to 3 do begin
						tc.Cart.Item[i].Card[k] := StrToInt(sl.Strings[(i-1)*10+7+k]);
					end;
					tc.Cart.Item[i].Data := ItemDB.Objects[ItemDB.IndexOf(StrToInt(sl.Strings[(i-1)*10+1]))] as TItemDB;
				end;
			end;
			//�t���O���[�h
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			j := StrToInt(sl.Strings[0]);
			for i := 1 to j do tc.Flag.Add(sl.Strings[i]);
		end;
		CharaName.AddObject(tc.Name, tc);
		Chara.AddObject(tc.CID, tc);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d character(s) data loaded.', [CharaName.Count]));
	Application.ProcessMessages;

	//�L�������&�v���C���[���̃����N
{�C��}
	for i := 0 to PlayerName.Count - 1 do begin
		tp := PlayerName.Objects[i] as TPlayer;
                tp.ver2 := 9;
                if tp.ver2 = 9 then i1 := 8
	        else i1 := 2;

                for j := 0 to i1 do begin
			if tp.CName[j] <> '' then begin
				k := CharaName.IndexOf(tp.CName[j]);
				if k <> -1 then begin
					tp.CData[j] := CharaName.Objects[k] as TChara;
					tp.CData[j].CharaNumber := j;
					tp.CData[j].ID := tp.ID;
					tp.CData[j].Gender := tp.Gender;
				end else begin
					tp.CName[j] := '';
					tp.CData[j] := nil;
				end;
			end;
		end;
	end;
{�C���R�R�܂�}

{�p�[�e�B�[�@�\�ǉ�}
  DebugOut.Lines.Add('Castle data loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'gcastle.txt');
	Reset(txt);
	Readln(txt, str);


	if str = '##Weiss.GCastleData.0x0002' then begin
//		ver := 2;
	end else begin
		Reset(txt);
	end;

	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if sl.Count <> 17 then continue;
		tgc := TCastle.Create;
		with tgc do begin
			Name := sl.Strings[0];
      GID  := StrToInt(sl.Strings[1]);
      GName:= sl.Strings[2];
      GMName:=sl.Strings[3];
      GKafra:=StrToInt(sl.Strings[4]);
      EDegree:=StrToInt(sl.Strings[5]);
      ETrigger:=StrToInt(sl.Strings[6]);
      DDegree:=StrToInt(sl.Strings[7]);
      DTrigger:=StrToInt(sl.Strings[8]);
      for i := 0 to 7 do begin
      GuardStatus[i] := StrToInt(sl.Strings[i+9]);
      end;
		end;
		CastleList.AddObject(tgc.Name, tgc);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d Castle(s) data loaded.', [CastleList.Count]));
	Application.ProcessMessages;


	//�p�[�e�B�[��񃍁[�h
	DebugOut.Lines.Add('Party data loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'party.txt');
	Reset(txt);
	Readln(txt, str);


	if str = '##Weiss.PartyData.0x0002' then begin
//		ver := 2;
	end else begin
		Reset(txt);
	end;

	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if sl.Count <> 13 then continue;
		tpa := TParty.Create;
		with tpa do begin
			Name := sl.Strings[0];
			for i := 0 to 11 do begin
				MemberID[i] := StrToInt(sl.Strings[i+1]);
			end;
			EXPShare := 0;
		end;
		PartyNameList.AddObject(tpa.Name, tpa);
		DebugOut.Lines.Add(Format('Name : %s.', [tpa.Name]));
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d Party(s) data loaded.', [PartyNameList.Count]));
	Application.ProcessMessages;

	//ID�ƃv���C���[���̃����N
	for i := 0 to PartyNameList.Count - 1 do begin
		tpa := PartyNameList.Objects[i] as TParty;
		for j := 0 to 11 do begin
			if tpa.MemberID[j] <> 0 then begin
				k := Chara.IndexOf(tpa.MemberID[j]);
				if k <> -1 then begin
					tc := Chara.Objects[k] as TChara;
					tc.PartyName := tpa.Name; //�p�[�e�B���̓R�R�œ����
					tpa.Member[j] := tc;
				end;
			end;
		end;
	end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}

{�M���h�@�\�ǉ�}
	//�M���h��񃍁[�h
	DebugOut.Lines.Add('Guild data loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'guild.txt');
	Reset(txt);
	Readln(txt, str);

	if str = '##Weiss.GuildData.0x0002' then begin
//		ver := 2;
	end else begin
		Reset(txt);
	end;

	while not eof(txt) do begin
		tg := TGuild.Create;
		with tg do begin
			//��{���
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			if sl.Count <> 12 then continue;
			ID := StrToInt(sl.Strings[0]);
			if (ID > NowGuildID) then NowGuildID := ID;
			Name := sl.Strings[1];
			LV := StrToInt(sl.Strings[2]);
			EXP := StrToInt(sl.Strings[3]);
			GSkillPoint := StrToInt(sl.Strings[4]);
			Notice[0] := sl.Strings[5];
			Notice[1] := sl.Strings[6];
			Agit := sl.Strings[7];
			Emblem := StrToInt(sl.Strings[8]);
			Present := StrToInt(sl.Strings[9]);
			DisposFV := StrToInt(sl.Strings[10]);
			DisposRW := StrToInt(sl.Strings[11]);
			//�����o�[���
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			if sl.Count <> 108 then continue;
			for i := 0 to 35 do begin
				MemberID[i] := StrToInt(sl.Strings[i * 3]);
				MemberPos[i] := StrToInt(sl.Strings[i * 3 + 1]);
				MemberEXP[i] := StrToInt(sl.Strings[i * 3 + 2]);
				if (MemberID[i] <> 0) then Inc(RegUsers, 1);
			end;
			//�E�ʏ��
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			if sl.Count <> 80 then continue;
			for i := 0 to 19 do begin
				PosName[i] := sl.Strings[i * 4];
				PosInvite[i] := (StrToInt(sl.Strings[i * 4 + 1]) = 1);
				PosPunish[i] := (StrToInt(sl.Strings[i * 4 + 2]) = 1);
				PosEXP[i] := StrToInt(sl.Strings[i * 4 + 3]);
			end;
			//�X�L�����
			for i := 10000 to 10004 do begin
				if GSkillDB.IndexOf(i) <> -1 then begin
					GSkill[i].Data := GSkillDB.IndexOfObject(i) as TSkillDB;
				end;
			end;
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			j := StrToInt(sl.Strings[0]);
			for i := 1 to j do begin
				if GSkillDB.IndexOf(StrToInt(sl.Strings[(i-1)*2+1])) <> -1 then begin
					k := StrToInt(sl.Strings[(i-1)*2+1]);
					GSkill[k].Lv := StrToInt(sl.Strings[(i-1)*2+2]);
					GSkill[k].Card := false;
				end;
			end;
			//�Ǖ��҃��X�g�A�����E�G�΃��X�g
			sl.Clear;
			Readln(txt, str);
			sl.DelimitedText := str;
			if sl.Count < 3 then continue;
			k := 3;
			//�Ǖ���
			j := StrToInt(sl.Strings[0]);
			for i := 1 to j do begin
				tgb := TGBan.Create;
				tgb.Name := sl.Strings[k];
				Inc(k);
				tgb.AccName := sl.Strings[k];
				Inc(k);
				tgb.Reason := sl.Strings[k];
				Inc(k);
				GuildBanList.AddObject(tgb.Name, tgb);
			end;
			//����
			j := StrToInt(sl.Strings[1]);
			for i := 1 to j do begin
				tgl := TGRel.Create;
				tgl.ID := StrToInt(sl.Strings[k]);
				Inc(k);
				tgl.GuildName := sl.Strings[k];
				Inc(k);
				RelAlliance.AddObject(tgl.GuildName, tgl);
			end;
			//�G��
			j := StrToInt(sl.Strings[2]);
			for i := 1 to j do begin
				tgl := TGRel.Create;
				tgl.ID := StrToInt(sl.Strings[k]);
				Inc(k);
				tgl.GuildName := sl.Strings[k];
				Inc(k);
				RelHostility.AddObject(tgl.GuildName, tgl);
			end;
			//�⑫���ݒ�
			MaxUsers := 16;
			if (GSkill[10004].Lv > 0) then begin
				MaxUsers := MaxUsers + GSkill[10004].Data.Data1[GSkill[10004].Lv];
			end;
			NextEXP := GExpTable[LV];
		end;
		GuildList.AddObject(tg.ID, tg);
	end;
	CloseFile(txt);
	DebugOut.Lines.Add(Format('*** Total %d Guild(s) data loaded.', [GuildList.Count]));
	Application.ProcessMessages;

	//ID�ƃv���C���[���̃����N
	for i := 0 to GuildList.Count - 1 do begin
		tg := GuildList.Objects[i] as TGuild;
		with tg do begin
			for j := 0 to 35 do begin
				if MemberID[j] <> 0 then begin
					k := Chara.IndexOf(MemberID[j]);
					if k <> -1 then begin
						tc := Chara.Objects[k] as TChara;
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
		end;
	end;
{�M���h�@�\�ǉ��R�R�܂�}

{�L���[�y�b�g}

	DebugOut.Lines.Add('Pet data loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'pet.txt');
	Reset(txt);
	Readln(txt, str);

        ver := 0;
				if str = '##Weiss.PetData.0x0001' then begin
                ver := 1;
        end else if str = '##Weiss.PetData.0x0002' then begin
                ver := 2;
        end else begin
                Reset( txt );
        end;

	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;

                if ver >= 1 then begin
                        tpe := TPet.Create;

                        if ver = 1 then begin
                                if sl.Count <> 11 then continue;

                                with tpe do begin
                                        PlayerID    := StrToInt( sl.Strings[ 0] );
                                        CharaID     := StrToInt( sl.Strings[ 1] );
                                        Cart        := StrToInt( sl.Strings[ 2] );
                                        Index       := StrToInt( sl.Strings[ 3] );
                                        Incubated   := StrToInt( sl.Strings[ 4] );
                                        PetID       := StrToInt( sl.Strings[ 5] );
                                        Name        :=           sl.Strings[ 6];
                                        Renamed     := StrToInt( sl.Strings[ 7] );
																				Relation    := StrToInt( sl.Strings[ 8] );
                                        Fullness    := StrToInt( sl.Strings[ 9] );
                                        Accessory   := StrToInt( sl.Strings[10] );
		end;

                        end else if ver = 2 then begin
                                if sl.Count <> 13 then continue;

                                i := PetDB.IndexOf( StrToInt( sl.Strings[6] ) );
                                if i <> -1 then begin
                                        tpe := TPet.Create;
                                        with tpe do begin
                                                PlayerID    := StrToInt( sl.Strings[ 0] );
                                                CharaID     := StrToInt( sl.Strings[ 1] );
                                                Cart        := StrToInt( sl.Strings[ 2] );
                                                Index       := StrToInt( sl.Strings[ 3] );
                                                Incubated   := StrToInt( sl.Strings[ 4] );
                                                PetID       := StrToInt( sl.Strings[ 5] );
                                                JID         := StrToInt( sl.Strings[ 6] );
                                                Name        :=           sl.Strings[ 7];
                                                Renamed     := StrToInt( sl.Strings[ 8] );
                                                LV          := StrToInt( sl.Strings[ 9] );
																								Relation    := StrToInt( sl.Strings[10] );
                                                Fullness    := StrToInt( sl.Strings[11] );
                                                Accessory   := StrToInt( sl.Strings[12] );

                                                Data        := PetDB.Objects[i] as TPetDB;
                                        end;
                                end;
                        end;

                        PetList.AddObject( tpe.PetID, tpe );
	end;
      end;

	CloseFile(txt);

      for i := 0 to PetList.Count - 1 do begin

                tpe := PetList.Objects[i] as TPet;

                if tpe.PlayerID = 0 then continue;

                if tpe.CharaID = 0 then begin
                        tp := Player.IndexofObject( tpe.PlayerID ) as TPlayer;
                        with tp.Kafra.Item[ tpe.Index ] do begin
                                Attr    := 0;
                                Card[0] := $FF00;
                                Card[2] := tpe.PetID mod $10000;
                                Card[3] := tpe.PetID div $10000;

                                if ver = 1 then begin
                                        for j := 0 to PetDB.Count - 1 do begin
                                                tpd := PetDB.Objects[j] as TPetDB;
                                                if tpd.EggID = ID then begin
                                                        tpe.JID := tpd.MobID;
                                                        k := MobDB.IndexOf( tpd.MobID );
                                                        if k <> -1 then begin
                                                                tmd := MobDB.Objects[k] as TMobDB;
                                                                tpe.LV := tmd.LV;
                                                        end;
                                                        tpe.Data := tpd;
                                                        break;
                                                end;
                                        end;
                                end;
                        end;
                end else begin
                        tc := Chara.IndexOfObject( tpe.CharaID ) as TChara;
                        if tpe.Cart = 0 then begin
                                with tc.Item[ tpe.Index ] do begin
                                        Attr    := tpe.Incubated;
                                        Card[0] := $FF00;
                                        Card[2] := tpe.PetID mod $10000;
                                        Card[3] := tpe.PetID div $10000;

                                        if ver = 1 then begin
                                                for j := 0 to PetDB.Count - 1 do begin
                                                        tpd := PetDB.Objects[j] as TPetDB;
                                                        if tpd.EggID = ID then begin
                                                                tpe.JID := tpd.MobID;
                                                                k := MobDB.IndexOf( tpd.MobID );
                                                                if k <> -1 then begin
                                                                        tmd := MobDB.Objects[k] as TMobDB;
                                                                        tpe.LV := tmd.LV;
                                                                end;
                                                                tpe.Data := tpd;
                                                                break;
                                                        end;
                                                end;
                                        end;
                                end;
                        end else begin
                                with tc.Cart.Item[ tpe.Index ] do begin
                                        Attr    := 0;
                                        Card[0] := $FF00;
                                        Card[2] := tpe.PetID mod $10000;
                                        Card[3] := tpe.PetID div $10000;

                                        if ver = 1 then begin
                                                for j := 0 to PetDB.Count - 1 do begin
                                                        tpd := PetDB.Objects[j] as TPetDB;
                                                        if tpd.EggID = ID then begin
                                                                tpe.JID := tpd.MobID;
                                                                k := MobDB.IndexOf( tpd.MobID );
                                                                if k <> -1 then begin
                                                                        tmd := MobDB.Objects[k] as TMobDB;
                                                                        tpe.LV := tmd.LV;
                                                                end;
                                                                tpe.Data := tpd;
                                                                break;
                                                        end;
                                                end;
                                        end;
                                end;
                        end;
                end;

                if NowPetID <= tpe.PetID then NowPetID := tpe.PetID + 1;
         end;

        DebugOut.Lines.Add( Format( '*** Total %d Pet(s) data loaded.', [PetList.Count] ) );
	Application.ProcessMessages;
{�L���[�y�b�g�����܂�}
	sl.Free;
end;
//------------------------------------------------------------------------------
// �f�[�^�ۑ�
procedure DataSave();
var
	i,j :integer;
	cnt :integer;
	txt :TextFile;
	sl  :TStringList;
	tp  :TPlayer;
	tc  :TChara;
{�p�[�e�B�[�@�\�ǉ�}
	tpa	:TParty;
  tgc :TCastle;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
        tpe :TPet;
        k:integer;
{�L���[�y�b�g�����܂�}
{�M���h�@�\�ǉ�}
	tg  :TGuild;
	tgb :TGBan;
	tgl :TGRel;
{�M���h�@�\�ǉ��R�R�܂�}
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

	if PlayerName.Count <> 0 then begin
		AssignFile(txt, AppPath + 'player.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.PlayerData.0x0003');
		for i := 0 to PlayerName.Count - 1 do begin
			tp := PlayerName.Objects[i] as TPlayer;
			sl.Clear;
			with tp do begin
				sl.Add(IntToStr(ID));
				sl.Add(Name);
				sl.Add(Pass);
				sl.Add(IntToStr(Gender));
				sl.Add(Mail);
				sl.Add(IntToStr(GMMode));
				sl.Add(CName[0]);
				sl.Add(CName[1]);
				sl.Add(CName[2]);
				sl.Add(CName[3]);
				sl.Add(CName[4]);
				sl.Add(CName[5]);
				sl.Add(CName[6]);
				sl.Add(CName[7]);
				sl.Add(CName[8]);
			end;
			writeln(txt, sl.DelimitedText);
			//�A�C�e���f�[�^�ۑ�
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 1 to 100 do begin
				if tp.Kafra.Item[j].ID <> 0 then begin
					sl.Add(IntToStr(tp.Kafra.Item[j].ID));
					sl.Add(IntToStr(tp.Kafra.Item[j].Amount));
					sl.Add(IntToStr(tp.Kafra.Item[j].Equip));
					sl.Add(IntToStr(tp.Kafra.Item[j].Identify));
					sl.Add(IntToStr(tp.Kafra.Item[j].Refine));
					sl.Add(IntToStr(tp.Kafra.Item[j].Attr));
					sl.Add(IntToStr(tp.Kafra.Item[j].Card[0]));
					sl.Add(IntToStr(tp.Kafra.Item[j].Card[1]));
					sl.Add(IntToStr(tp.Kafra.Item[j].Card[2]));
					sl.Add(IntToStr(tp.Kafra.Item[j].Card[3]));
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
		end;
		CloseFile(txt);
	end;

	if CharaName.Count <> 0 then begin
		AssignFile(txt, AppPath + 'chara.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.CharaData.0x0002');
		for i := 0 to CharaName.Count - 1 do begin
			tc := CharaName.Objects[i] as TChara;
			sl.Clear;
			with tc do begin
				sl.Add(IntToStr(CID));
				sl.Add(Name);
				sl.Add(IntToStr(JID));
				sl.Add(IntToStr(BaseLV));
				sl.Add(IntToStr(BaseEXP));
				sl.Add(IntToStr(StatusPoint));
				sl.Add(IntToStr(JobLV));
				sl.Add(IntToStr(JobEXP));
				sl.Add(IntToStr(SkillPoint));
				sl.Add(IntToStr(Zeny));
{�C��}
				sl.Add(IntToStr(Stat1));
				sl.Add(IntToStr(Stat2));
{�C���R�R�܂�}
				sl.Add(IntToStr(Option));
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

				sl.Add(Map);
				sl.Add(IntToStr(Point.X));
				sl.Add(IntToStr(Point.Y));

				sl.Add(SaveMap);
				sl.Add(IntToStr(SavePoint.X));
				sl.Add(IntToStr(SavePoint.Y));
				for j := 0 to 2 do begin
					sl.Add(MemoMap[j]);
					sl.Add(IntToStr(MemoPoint[j].X));
					sl.Add(IntToStr(MemoPoint[j].Y));
				end;
        sl.Add(IntToStr(Plag));
        sl.Add(IntToStr(PLv));
			end;
			writeln(txt, sl.DelimitedText);
			//�X�L���f�[�^�ۑ�
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 1 to 336 do begin
				if tc.Skill[j].Lv <> 0 then begin
					sl.Add(IntToStr(j));
					sl.Add(IntToStr(tc.Skill[j].Lv));
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
			//�A�C�e���f�[�^�ۑ�
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 1 to 100 do begin
				if tc.Item[j].ID <> 0 then begin
					sl.Add(IntToStr(tc.Item[j].ID));
					sl.Add(IntToStr(tc.Item[j].Amount));
					sl.Add(IntToStr(tc.Item[j].Equip));
					sl.Add(IntToStr(tc.Item[j].Identify));
					sl.Add(IntToStr(tc.Item[j].Refine));
					sl.Add(IntToStr(tc.Item[j].Attr));
					sl.Add(IntToStr(tc.Item[j].Card[0]));
					sl.Add(IntToStr(tc.Item[j].Card[1]));
					sl.Add(IntToStr(tc.Item[j].Card[2]));
					sl.Add(IntToStr(tc.Item[j].Card[3]));
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
			//�J�[�g�f�[�^�ۑ�
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 1 to 100 do begin
				if tc.Cart.Item[j].ID <> 0 then begin
					sl.Add(IntToStr(tc.Cart.Item[j].ID));
					sl.Add(IntToStr(tc.Cart.Item[j].Amount));
					sl.Add(IntToStr(tc.Cart.Item[j].Equip));
					sl.Add(IntToStr(tc.Cart.Item[j].Identify));
					sl.Add(IntToStr(tc.Cart.Item[j].Refine));
					sl.Add(IntToStr(tc.Cart.Item[j].Attr));
					sl.Add(IntToStr(tc.Cart.Item[j].Card[0]));
					sl.Add(IntToStr(tc.Cart.Item[j].Card[1]));
					sl.Add(IntToStr(tc.Cart.Item[j].Card[2]));
					sl.Add(IntToStr(tc.Cart.Item[j].Card[3]));
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
			//�t���O�f�[�^�ۑ�
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 0 to tc.Flag.Count - 1 do begin
{NPC�C�x���g�ǉ�}
				if ((Copy(tc.Flag.Names[j], 1, 1) <> '@') and (Copy(tc.Flag.Names[j], 1, 2) <> '$@'))
				and ((tc.Flag.Values[tc.Flag.Names[j]] <> '0') and (tc.Flag.Values[tc.Flag.Names[j]] <> '')) then begin
{NPC�C�x���g�ǉ��R�R�܂�}
					sl.Add(tc.Flag.Strings[j]);
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
		end;
		CloseFile(txt);
	end;

{NPC�C�x���g�ǉ�}
	//�T�[�o���L�t���O�ۑ�
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
{NPC�C�x���g�ǉ��R�R�܂�}

{�p�[�e�B�[�@�\�ǉ�}
  AssignFile(txt, AppPath + 'gcastle.txt');
	Rewrite(txt);
	Writeln(txt, '##Weiss.GCastleData.0x0002');
	for i := 0 to CastleList.Count - 1 do begin
		tgc := CastleList.Objects[i] as TCastle;
		sl.Clear;
		with tgc do begin
			sl.Add(Name);
			sl.Add(IntToStr(GID));
      sl.Add(GName);
      sl.Add(GMName);
      sl.Add(IntToStr(GKafra));
      sl.Add(IntToStr(EDegree));
      sl.Add(IntToStr(ETrigger));
      sl.Add(IntToStr(DDegree));
      sl.Add(IntToStr(DTrigger));
      for j := 0 to 7 do begin
      sl.Add(IntToStr(GuardStatus[j]));
      end;
		end;
		writeln(txt, sl.DelimitedText);
	end;
	CloseFile(txt);


	AssignFile(txt, AppPath + 'party.txt');
	Rewrite(txt);
	Writeln(txt, '##Weiss.PartyData.0x0002');
	for i := 0 to PartyNameList.Count - 1 do begin
		tpa := PartyNameList.Objects[i] as TParty;
		sl.Clear;
		with tpa do begin
			sl.Add(Name);
			for j := 0 to 11 do begin
				sl.Add(IntToStr(MemberID[j]));
			end;
		end;
		writeln(txt, sl.DelimitedText);
	end;
	CloseFile(txt);
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}

{�M���h�@�\�ǉ�}
	AssignFile(txt, AppPath + 'guild.txt');
	Rewrite(txt);
	Writeln(txt, '##Weiss.GuildData.0x0002');
	for i := 0 to GuildList.Count - 1 do begin
		tg := GuildList.Objects[i] as TGuild;
		with tg do begin
			//��{���
			sl.Clear;
			sl.Add(IntToStr(ID));
			sl.Add(Name);
			sl.Add(IntToStr(LV));
			sl.Add(IntToStr(EXP));
			sl.Add(IntToStr(GSkillPoint));
			sl.Add(Notice[0]);
			sl.Add(Notice[1]);
			sl.Add(Agit);
			sl.Add(IntToStr(Emblem));
			sl.Add(IntToStr(Present));
			sl.Add(IntToStr(DisposFV));
			sl.Add(IntToStr(DisposRW));
			writeln(txt, sl.DelimitedText);
			//�����o�[���
			sl.Clear;
			for j := 0 to 35 do begin
				sl.Add(IntToStr(MemberID[j]));
				sl.Add(IntToStr(MemberPos[j]));
				sl.Add(IntToStr(MemberEXP[j]));
			end;
			writeln(txt, sl.DelimitedText);
			//�E�ʏ��
			sl.Clear;
			for j := 0 to 19 do begin
				sl.Add(PosName[j]);
				if (PosInvite[j] = true) then sl.Add('1') else sl.Add('0');
				if (PosPunish[j] = true) then sl.Add('1') else sl.Add('0');
				sl.Add(IntToStr(PosEXP[j]));
			end;
			writeln(txt, sl.DelimitedText);
			//�X�L�����
			sl.Clear;
			sl.Add('0');
			cnt := 0;
			for j := 10000 to 10004 do begin
				if GSkill[j].Lv <> 0 then begin
					sl.Add(IntToStr(j));
					sl.Add(IntToStr(GSkill[j].Lv));
					Inc(cnt);
				end;
			end;
			sl.Strings[0] := IntToStr(cnt);
			writeln(txt, sl.DelimitedText);
			//�Ǖ��҃��X�g�A�����E�G�΃��X�g
			sl.Clear;
			sl.Add(IntToStr(GuildBanList.Count));
			sl.Add(IntToStr(RelAlliance.Count));
			sl.Add(IntToStr(RelHostility.Count));
			for j := 0 to GuildBanList.Count - 1 do begin
				tgb := GuildBanList.Objects[j] as TGBan;
				sl.Add(tgb.Name);
				sl.Add(tgb.AccName);
				sl.Add(tgb.Reason);
			end;
			for j := 0 to RelAlliance.Count - 1 do begin
				tgl := RelAlliance.Objects[j] as TGRel;
				sl.Add(IntToStr(tgl.ID));
				sl.Add(tgl.GuildName);
			end;
			for j := 0 to RelHostility.Count - 1 do begin
				tgl := RelHostility.Objects[j] as TGRel;
				sl.Add(IntToStr(tgl.ID));
				sl.Add(tgl.GuildName);
			end;
			writeln(txt, sl.DelimitedText);
		end;
	end;
	CloseFile(txt);
{�M���h�@�\�ǉ��R�R�܂�}

{�L���[�y�b�g}
	AssignFile(txt, AppPath + 'pet.txt');
	Rewrite(txt);
        Writeln( txt, '##Weiss.PetData.0x0002' );
        for i := 0 to Player.Count - 1 do begin
                tp := Player.Objects[i] as TPlayer;
                for j := 1 to 100 do begin
                        with tp.Kafra.Item[j] do begin
                                if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
                                        k := Card[2] + Card[3] * $10000;
                                        if PetList.IndexOf( k ) <> -1 then begin
                                                tpe := PetList.IndexOfObject( k ) as TPet;
                                                sl.Clear;
                                                sl.Add( IntToStr( tp.ID ) );
                                                sl.Add( '0' ); // CharaID
                                                sl.Add( '0' ); // Cart
                                                sl.Add( IntToStr( j ) ); // Index
                                                sl.Add( '0' ); // Incubated
                                                sl.Add( IntToStr( k ) ); // PetID
                                                sl.Add( IntToStr( tpe.JID ) );
                                                sl.Add( tpe.Name );
                                                sl.Add( IntToStr( tpe.Renamed ) );
                                                sl.Add( IntToStr( tpe.LV ) );
                                                sl.Add( IntToStr( tpe.Relation  ) );
                                                sl.Add( IntToStr( tpe.Fullness  ) );
                                                sl.Add( IntToStr( tpe.Accessory ) );

                                                Writeln( txt, sl.DelimitedText );
		end;
                                end;
                        end;
                end;
        end;
        for i := 0 to Chara.Count - 1 do begin
                tc := Chara.Objects[i] as TChara;
                for j := 1 to 100 do begin
                        with tc.Item[j] do begin
                                if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
                                        k := Card[2] + Card[3] * $10000;
                                        if PetList.IndexOf( k ) <> -1 then begin
                                                tpe := PetList.IndexOfObject( k ) as TPet;
                                                sl.Clear;
                                                sl.Add( IntToStr( tc.ID ) );
                                                sl.Add( IntToStr( tc.CID ) );
                                                sl.Add( '0' ); // Cart
                                                sl.Add( IntToStr( j ) ); // Index
                                                sl.Add( IntToStr( Attr ) );
                                                sl.Add( IntToStr( k ) ); // PetID
                                                sl.Add( IntToStr( tpe.JID ) );
                                                sl.Add( tpe.Name );
                                                sl.Add( IntToStr( tpe.Renamed ) );
                                                sl.Add( IntToStr( tpe.LV ) );
                                                sl.Add( IntToStr( tpe.Relation  ) );
                                                sl.Add( IntToStr( tpe.Fullness  ) );
                                                sl.Add( IntToStr( tpe.Accessory ) );

		writeln(txt, sl.DelimitedText);
	end;
                                end;
                        end;
                end;
                for j := 1 to 100 do begin
                        with tc.Cart.Item[j] do begin
                                if ( ID <> 0 ) and ( Amount > 0 ) and ( Card[0] = $FF00 ) then begin
                                        k := Card[2] + Card[3] * $10000;
                                        if PetList.IndexOf( k ) <> -1 then begin
                                                tpe := PetList.IndexOfObject( k ) as TPet;
                                                sl.Clear;
                                                sl.Add( IntToStr( tc.ID ) );
                                                sl.Add( IntToStr( tc.CID ) );
                                                sl.Add( '1' ); // Cart
                                                sl.Add( IntToStr( j ) ); // Index
                                                sl.Add( '0' ); // Incubated
                                                sl.Add( IntToStr( k ) ); // PetID
                                                sl.Add( IntToStr( tpe.JID ) );
                                                sl.Add( tpe.Name );
                                                sl.Add( IntToStr( tpe.Renamed ) );
                                                sl.Add( IntToStr( tpe.LV ) );
                                                sl.Add( IntToStr( tpe.Relation  ) );
                                                sl.Add( IntToStr( tpe.Fullness  ) );
                                                sl.Add( IntToStr( tpe.Accessory ) );

                                                Writeln( txt, sl.DelimitedText );
                                        end;
                                end;
                        end;
                end;
        end;
	CloseFile(txt);
{�L���[�y�b�g�����܂�}

	sl.Free;
end;
//------------------------------------------------------------------------------

end.

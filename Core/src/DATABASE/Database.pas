unit Database;



interface

uses
    {Windows VCL}
    {$IFDEF MSWINDOWS}
	Windows, MMSystem, Forms, {Replace with QForms soon and place in common}
    {$ENDIF}
    {Common}
    Classes, SysUtils, IniFiles,
    {Fusion}
    Globals;

//==============================================================================
// �֐���`
		procedure DatabaseLoad(Handle:HWND);
		procedure DataLoad();
		procedure DataSave(forced : Boolean = False);
//==============================================================================


	//Files partitioned out of DatabaseLoad
	Function  DataBaseFilesExist : Boolean;
	Procedure LoadSummonLists;
	Procedure LoadPetData;

//==============================================================================
// Alex: This file is a fucking mess ... Stop adding to it !
//==============================================================================
    procedure Load_NonREED();
    procedure DumpMemory();

implementation

uses
	Common, Game_Master, GlobalLists, Zip, PlayerData;


(*-----------------------------------------------------------------------------*
DataBaseFilesExist

Returns a True value if ALL files needed in the Database folder exist,
else returns false.
(Optional DB files are checked for individually)

Called by:
	DatabaseLoad

Pre:
	None.
Post:
	Returns a True or False value

Revisions:
--
2004/05/04 - ChrstphrR - Initial breakout from DatabaseLoad - 11 required files
2004/05/04 - " - Checked again, and Required Files checked now 21

Question:
The following files were not checked for here - are they really just optional?
	special_db.txt
	mapinfo_db.txt

2004/05/29 - AlexKreuz added gm_access.txt to the required list.
*-----------------------------------------------------------------------------*)
Function  DataBaseFilesExist : Boolean;
Begin
	Result := True; // Assume True.

	if NOT (
		FileExists(AppPath + 'database\item_db.txt') AND
		FileExists(AppPath + 'database\summon_item.txt') AND
		FileExists(AppPath + 'database\summon_mob.txt') AND
		FileExists(AppPath + 'database\summon_mobID.txt') AND
		FileExists(AppPath + 'database\metalprocess_db.txt') AND

		FileExists(AppPath + 'database\pet_db.txt' ) AND
		FileExists(AppPath + 'database\mob_db.txt') AND
		FileExists(AppPath + 'database\skill_db.txt') AND
		FileExists(AppPath + 'database\skill_guild_db.txt') AND
		FileExists(AppPath + 'database\exp_guild_db.txt') AND

		FileExists(AppPath + 'database\exp_db.txt') AND
		FileExists(AppPath + 'database\Monster_AI.txt') AND
		FileExists(AppPath + 'database\territory_db.txt') AND
		FileExists(AppPath + 'database\summon_slave.txt') AND
		FileExists(AppPath + 'database\make_arrow.txt') AND

		FileExists(AppPath + 'database\job_db1.txt') AND
		FileExists(AppPath + 'database\job_db2.txt') AND
		FileExists(AppPath + 'database\wp_db.txt') AND
		FileExists(AppPath + 'database\warp_db.txt') AND

		FileExists(AppPath + 'database\ele_db.txt')
	) then begin
		Result := FALSE;
	end;
End;(* Func DataBaseFilesExist (LocalUnitProc)
*-----------------------------------------------------------------------------*)


(*-----------------------------------------------------------------------------*
LoadSummonLists

This is a Local Procedure to Database unit. Must be declared ahead of the
DatabaseLoad procedure.

Loads all Summon* Lists from the proper database files. Broken out to make the
original routine more readable -- each group of files loaded in it's own logical
section.

Called by:
	DatabaseLoad

Pre:
	DataBaseFilesExist returns True (summmon_*.txt files exist)
Post:
	The following lists will have Zero or more entries:
	SummonMobList    (summon_mobID.txt)
	SummonMobListMVP (summon_mob.txt -- currently empty for this list)
	SummonIOBList    (summon_item.txt)
	SummonIOVList    (summon_item.txt)
	SummonICAList    (summon_item.txt)
	SummonIGBList    (summon_item.txt)
	SummonIOWBList   (summon_item.txt)

Revisions:
--
2004/05/04 - ChrstphrR - Initial breakout from DatabaseLoad
2004/05/04 - ChrstphrR - Bug fix #827 - fixed for that, and ALL box summon lists
*-----------------------------------------------------------------------------*)
Procedure LoadSummonLists;
Var
	Idx     : Integer;
	Counter : Integer; //Tallies entries into a list for display when done
	Weight  : Integer; //Weighting number or "chance" item has to be chosen.

	Txt     : TextFile;
	Str     : string;      //Holds each line read
	SL      : TStringList; //Parses Str into text tokens.
Begin
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Summon Monster List loading...');
	{ChrstphrR 2004/04/19 - New SummonMobList code... created and loaded here}

	//Creates and loads data from the file all in one step
	SummonMobList := TSummonMobList.Create(AppPath + 'database\summon_mobID.txt');
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Summon Monster List loaded.', [SummonMobList.Count]));
	{ChrstphrR 2004/04/19 - yes, that's all to see here - the rest is in the
	TSummonMobList code}

	{ChrstphrR 2004/05/23 - cleaned up last of the summon???lists here.
	}
	Application.ProcessMessages;
	AssignFile(Txt, AppPath + 'database\summon_mob.txt');
	Reset(Txt);
	SL := TStringList.Create;
	while not eof(Txt) do begin
		Readln(txt, str);
		SL.Delimiter     := ',';
		SL.DelimitedText := Str;
		if (SL[0] = 'MVP') AND (SL.Count >= 3) then begin
			if (MobDBName.IndexOf(SL[1]) = -1) then begin
				{Warn of invalid container in the line, handle gracefully}
				debugout.lines.add('[' + TimeToStr(Now) + '] ' + 
					'*** summon_item.txt Error handled (1). Please report this Item: ' + str
				);
			end else begin
				Weight := StrToIntDef(SL[2],1);
				for Idx := 1 to Weight do begin
					SummonMobListMVP.Add(SL[1]);
				end;
			end;
		end;
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 
		Format( '-> Total %d Summon MVP Monster List loaded.',
		[SummonMobListMVP.Count] )
	);
	//-- End of SummonMobList / SummonMobListMVP Load


	//Summon Box Lists
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Summon Item List loading...');
	Application.ProcessMessages;
	AssignFile(Txt, AppPath + 'database\summon_item.txt');
	Reset(Txt);
	SL.Clear;
	while not eof(Txt) do begin
		Readln(txt, str);
		SL.DelimitedText := Str;
		if SL.Count < 3 then Continue; //safety check against bad line.

		{ChrstphrR 2004/05/04 - code-side fix for bug #827 -- Checking entries
		in summon_item.txt against ItemDB before adding to list.
		We know that ItemDB is populated about 400 lines ahead, so checking is safe,
		so we're checking the ItemDBName list to make sure the Box items ARE there.}

		{ChrstphrR 2004/05/04 - StrToIntDef ensures that at least, the
		weighting of this choice will be 1, if not defined, or 0 or less.}
		Weight := StrToIntDef(SL[2],1);

		if (ItemDBName.IndexOf(SL[0]) = -1) then begin
			{Warn of invalid container in the line, handle gracefully}
			debugout.lines.add('[' + TimeToStr(Now) + '] ' + 
				'*** summon_item.txt Error handled (1). Please report this Item: ' + str
			);
			Continue;
		end;
		if (ItemDBName.IndexOf(SL[1]) = -1) then begin
			{ChrstphrR - well, the item in the summon_item.txt doesn't exist if we
			branch here, output a message to let the user know, so they can post a
			bug report to get the DB file corrected.}
			debugout.lines.add('[' + TimeToStr(Now) + '] ' + 
				'*** summon_item.txt Error handled (2). Please report this Item: ' + Str
			);
			Continue;
		end;//if ItemDBName Check

		//ChrstphrR -- Poor algorithm choice, will convert "later" to
		//algorithm TSummonMobList uses.
		for Idx := 1 to Weight do begin
			if (SL[0] = 'Old_Blue_Box') then
				SummonIOBList.Add(SL[1])
			else if (SL[0] = 'Old_Violet_Box') then
				SummonIOVList.Add(SL[1])
			else if (SL[0] = 'Old_Card_Album') then
				SummonICAList.Add(SL[1])
			else if (SL[0] = 'Gift_Box') then
				SummonIGBList.Add(SL[1])
			else if (SL[0] = 'Old_Weapon_Box') then
				SummonIOWBList.Add(SL[1]);
		end;

	end;//while
	CloseFile(Txt);
	SL.Free;

	Counter := SummonIOBList.Count + SummonIOVList.Count + SummonICAList.Count +
		SummonIGBList.Count + SummonIOWBList.Count;

	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Summon Item List loaded.', [Counter]));
	Application.ProcessMessages;
End;(* Proc LoadSummonLists
*-----------------------------------------------------------------------------*)


(*-----------------------------------------------------------------------------*
LoadPetData

This is a Local Procedure to Database unit. Must be declared ahead of the
DatabaseLoad procedure.

Loads all Pet Lists from the proper database files. Broken out to make the
original routine more readable -- and to allow future work to safeguard against
bad data in the pet data files, before they're loaded into the internal lists.

Called by:
	DatabaseLoad

Pre:
	DataBaseFilesExist returns True (summmon_*.txt files exist)
Post:
	The following lists will have Zero or more entries:
//	SummonMobList    (summon_mobID.txt)

Revisions:
--
2004/05/26 - ChrstphrR - Initial breakout from DatabaseLoad
2004/05/26 - ChrstphrR - Variable renaming for clarity.
*-----------------------------------------------------------------------------*)
Procedure LoadPetData;
Var
	ID_Idx    : Integer;
	LineCount : Integer;
	PetErrors : Boolean;

	Str       : string; //temp storage for read line.
	Txt       : TextFile;
	PDB       : TPetDB;
	PetDBrow  : TStringList;

Begin
	debugout.lines.add('[' + TimeToStr(Now) + '] ' +  'Pet database loading...' );

	AssignFile(Txt, AppPath + 'database\pet_db.txt' );
	Reset(Txt);
	Readln(Txt, Str);//Read comment line at top of pet_db
	PetDBRow := TStringList.Create;

	PetErrors := FALSE;
	LineCount := 1;

	while NOT eof(Txt) do begin
		PetDBrow.Clear;
		Readln(txt, Str);
		Inc(LineCount);
		PetDBrow.DelimitedText := str;

		//Does the row have 14 entries?
		//Does the first field have an ID number in it? -1 = invalid ID
		if (PetDBrow.Count = 14) then
			ID_Idx := StrToIntDef( PetDBrow[ 0], -1)
		else
			ID_IDx := -2;

		//Look up ID found in PetDB - only procede if there's an entry.
		if MobDB.IndexOf(ID_Idx) > -1 then begin
		//ChrstphrR 2004/05/26 -- No typechecking done here - unsafe.
		// -- no dupe entry checks either - first entry in always used.
			PDB := TPetDB.Create;
			try
				with PDB do begin
					MobID       := StrToInt( PetDBrow[ 0] );
					ItemID      := StrToInt( PetDBrow[ 1] );
					EggID       := StrToInt( PetDBrow[ 2] );
					AcceID      := StrToInt( PetDBrow[ 3] );
					FoodID      := StrToInt( PetDBrow[ 4] );
					Fullness    := StrToInt( PetDBrow[ 5] );
					HungryDelay := StrToInt( PetDBrow[ 6] );
					Hungry      := StrToInt( PetDBrow[ 7] );
					Full        := StrToInt( PetDBrow[ 8] );
					Reserved    := StrToInt( PetDBrow[ 9] );
					Die         := StrToInt( PetDBrow[10] );
					Capture     := StrToInt( PetDBrow[11] );
					// 12th is the Species name - not stored.
					SkillTime   := StrToInt( PetDBrow[13] );
				end;
				PetDB.AddObject( PDB.MobID, PDB );
			except
				on EConvertError do begin
					//No number where a number should be...
					debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format(
						'pet_db.txt Error handled : Incorrect/missing field on line %d : %s', [LineCount, Str]
					) );
					PetErrors := TRUE;
					if Assigned(PDB) then
						PDB.Free;
				end;
			end;//try-e
		end else begin
			// No match for MobID in mobdb, or line wasn't up to 14 parts.
			case ID_Idx of
			-1 : begin
					debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format(
						'pet_db.txt Error handled : Invalid MobID on line %d : %s',
						[LineCount, Str]
					) );
					PetErrors := TRUE;
				end;
			-2 : begin
					debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format(
						'pet_db.txt Error handled : Line %d has less than 14 fields',
						[LineCount]
					) );
					PetErrors := TRUE;
				end;
				else begin
					debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format(
						'pet_db.txt Error handled : Invalid MobID on line %d : %s',
						[LineCount, Str]
					) );
					PetErrors := TRUE;
				end;
			end;//case
		end;
	end;
	CloseFile(txt);

	if PetErrors then begin
		debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format(
			'*** Error(s) in %sdatabase\pet_db.txt found.',
			[AppPath]
		) );
		debugout.lines.add('[' + TimeToStr(Now) + '] ' +  '	This may affect game play. Please repair this file.' );
	end;
	debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format( '-> Total %d pet(s) database loaded.', [PetDB.Count] ) );
	Application.ProcessMessages;

End;(* Proc LoadPetData
*-----------------------------------------------------------------------------*)




//==============================================================================
// �f�[�^�x�[�X�ǂݍ���
procedure DatabaseLoad(Handle:HWND);
var
	i   : Integer;
	j   : Integer;
	k   : Integer;
	l   : Integer;
	w   : Word;
	xy  : TPoint;
	str : string;
	txt : TextFile;
	// Variables for creating the new AI list
	txt2: TextFile;
	str1: string;

	SL  : TStringList;
	SL1 : TStringList;
	ta  : TMapList;
	td  : TItemDB;
{�ǉ�}
	wj  : Int64;
{�ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
	tma : TMaterialDB;
{�A�C�e�������ǉ��R�R�܂�}
{��{���ǉ�}
	tss : TSlaveDB;

	ma  : TMArrowDB;
{��{���ǉ��R�R�܂�}
{�L���[�y�b�g}
	tp  : TPetDB;
{�L���[�y�b�g�����܂�}
{NPC�C�x���g�ǉ�}
	mi  : MapTbl;
{NPC�C�x���g�ǉ��R�R�܂�}

	tb   : TMobDB;
	ts   : TMobDB;
	tsAI    : TMobAIDB;
	tsAI2   : TMobAIDBFusion;
	twp     : TWarpDatabase;
	tGlobal : TGlobalVars;

	tt  : TTerritoryDB;
	tl  : TSkillDB;
	sr  : TSearchRec;
	dat : TFileStream;
	jf  : array[0..MAX_JOB_NUMBER] of Boolean;

	afm_compressed : TZip;
	afm            : Textfile;

begin

	if NOT DataBaseFilesExist then begin
		MessageBox(
			Handle,
			'You have missing files. Go to the Fusion Download Center to get them.',
			'Fusion',
			MB_OK or MB_ICONSTOP
		);
		Application.Terminate;
		Exit;
	end;

	//gat�t�@�C���̑��݂��`�F�b�N
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Map data loading...');
	Application.ProcessMessages;

	if FindFirst(AppPath + 'map\*.af2', $27, sr) = 0 then begin
		repeat
			CreateDir('map\tmpFiles');
			afm_compressed := tzip.create(afm_compressed);
			afm_compressed.Filename := AppPath+'map\'+sr.Name;
			afm_compressed.ExtractPath := AppPath+'map\tmpFiles';
			afm_compressed.Extract;

			sr.Name := StringReplace(sr.Name, '.af2', '.out',
				[rfReplaceAll, rfIgnoreCase]);

			assignfile(afm,AppPath + 'map\tmpFiles\' + sr.Name);
			Reset(afm);

			ReadLn(afm,str);
			if (str <> 'ADVANCED FUSION MAP') then begin
				MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;

			ReadLn(afm,str);
			ReadLn(afm,xy.X,xy.Y);
			CloseFile(afm);

			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;
			//txtDebug.Lines.Add(Format('MapData: %s [%dx%d]', [sr.Name, xy.X, xy.Y]));
			//Application.ProcessMessages;
			ta := TMapList.Create;
			ta.Name := LowerCase(ChangeFileExt(sr.Name, ''));
			ta.Ext := 'af2';
			ta.Size := xy;
			ta.Mode := 0;
			MapList.AddObject(ta.Name, ta);

		until FindNext(sr) <> 0;
		FindClose(sr);
		afm_compressed.Free;
	end;

	if FindFirst(AppPath + 'map\*.afm', $27, sr) = 0 then begin
		repeat

			assignfile(afm,AppPath + 'map\' + sr.Name);
			Reset(afm);

			ReadLn(afm,str);
			if (str <> 'ADVANCED FUSION MAP') then begin
				MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;

			ReadLn(afm,str);
			ReadLn(afm,xy.X,xy.Y);
			CloseFile(afm);

			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;
			//txtDebug.Lines.Add(Format('MapData: %s [%dx%d]', [sr.Name, xy.X, xy.Y]));
			//Application.ProcessMessages;
			ta := TMapList.Create;
			ta.Name := LowerCase(ChangeFileExt(sr.Name, ''));
			ta.Ext := 'afm';
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
				MessageBox(Handle, PChar('Map Format Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
				Application.Terminate;
				exit;
			end;

			dat.Read(w, 2);
			dat.Read(xy.X, 4);
			dat.Read(xy.Y, 4);
			dat.Free;
			if (xy.X < 0) or (xy.X > 511) or (xy.Y < 0) or (xy.Y > 511) then begin
				MessageBox(Handle, PChar('Map Size Error : ' + sr.Name), 'Fusion', MB_OK or MB_ICONSTOP);
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
		MessageBox(Handle, 'prontera map file missing', 'Fusion', MB_OK or MB_ICONSTOP);
		Application.Terminate;
		exit;
	end;
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d map(s) loaded.', [MapList.Count]));
	Application.ProcessMessages;

	{ChrstphrR 2004/05/24 -- Moved so that early exits aren't memory leaks too}
	SL  := TStringList.Create;
	SL1 := TStringList.Create;

	//�A�C�e���f�[�^���[�h
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Item database loading...');
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
						for i := 0 to LOWER_JOB_END do begin
							 jf[i] := boolean((Job and (1 shl i)) <> 0);
							 if (i < (LOWER_JOB_END - 1)) and (jf[i]) then begin
									jf[i + LOWER_JOB_END + 1] := true;
							 end;
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
						Job := Job or Int64(jf[17]) * $020000;  //Rogue
						Job := Job or Int64(jf[18]) * $040000;  //Alchemist
						Job := Job or Int64(jf[19]) * $080000;  //Bard
						Job := Job or Int64(jf[20]) * $100000;  //Dancer

						// $200000: Groom, $400000: Bride...
						Job := Job or Int64(jf[23]) * $800000;  //Super Novice

						//Crusader Same as a swordsman and knight
						if Boolean(Job and $0002) or Boolean(Job and $0080) then Job := Job or $4000;

						// Super Novices get all Novice equipments.
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

            // Colus, 20040304: Kludged method of porting the reqs to upper jobs
            for i := 0 to LOWER_JOB_END do begin
               //if (i < (LOWER_JOB_END - 1)) and (jf[i]) then begin
               if (i < (LOWER_JOB_END - 1)) and (Job and (1 shl i) <> 0) then begin
                  Job := Job or Int64(1) shl (i + LOWER_JOB_END + 1);
               end;
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
			//if ID > 4000 then debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('ID = %d', [ID]));
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
			for i := 0 to MAX_SKILL_NUMBER do AddSkill[i] := 0;
			AddSkill[StrToInt(sl.Strings[42])] := StrToInt(sl.Strings[43]);
			case td.Effect of
			202:  {Monster Knockback}
				begin
					SpecialAttack := 1; {Knockback}
				end;
			203:  {Splash Damage}
				begin
					SplashAttack := true;
				end;
			204:  {Splash + Knockback}
				begin
					SplashAttack := true; {Splash}
					SpecialAttack := 1; {Knockback}
				end;
			205:  {Fatal Blow}
				begin
					SpecialAttack := 2; {Fatal Blow}
				end;
			end;
			case ID of
			4115:
				begin
					DrainFix[0] := 3; // Hunter Fly Card
					DrainPer[0] := 15;
				end;

			4082: DamageFixS[0] := 15; // Desert Wolf Card
			4092: DamageFixS[1] := 15; // Skel Worker Card
			4126: DamageFixS[2] := 15; // Minorous Card

			4125: // Deviace Card (changed from Deviruchi, 5->7% bonus
				begin
					DamageFixR[2] := 7;
					DamageFixR[3] := 7;
					DamageFixR[4] := 7;
					DamageFixR[7] := 7;
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

			{ Oat says this makes you invincible when it shouldn't. Commented out Temporarily. }
			//4047:   GhostArmor := true;     {Ghostring Card}

			4077:   NoCastInterrupt := true;{Phen Card}
			4147:   SplashAttack := true;   {Baphomet Card}
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

			end;//case

		end;
		ItemDB.AddObject(td.ID, td);
		ItemDBName.AddObject(td.Name, td);
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d item(s) database loaded.', [ItemDB.Count]));
	Application.ProcessMessages;
{�ǉ�}
	//�A�C�e�������`
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Special database loading...');
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
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d item(s) database change.', [k]));
		Application.ProcessMessages;
	end else begin
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Special database Not Find.');
		Application.ProcessMessages;
	end;
{�ǉ��R�R�܂�}
{�A�C�e�������ǉ�}
	//�A�C�e�������f�[�^�x�[�X�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'MetalProcess database loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d metalprocess(s) database loaded.', [MaterialDB.Count]));
	Application.ProcessMessages;
{�A�C�e�������ǉ��R�R�܂�}

	//�����X�^�[�f�[�^�x�[�X�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Monster database loading...');
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
			FLEE := LV + Param[1];
			isDontMove := boolean((Mode and 1) = 0);
			isActive := boolean(((Mode and 4) <> 0) and not DisableMonsterActive);
			isLoot := boolean((Mode and 2) <> 0);
			isLink := boolean((Mode and 8) <> 0);


		end;
		MobDB.AddObject(tb.ID, tb);
		MobDBName.AddObject(tb.Name, tb);
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d monster(s) database loaded.', [MobDB.Count]));
	Application.ProcessMessages;

{��{���ǉ�}
	//�}�f�[�^�x�[�X�ǂݍ���
{Colus, 20040130: Since we put the pharmacy entires in the metalprocess we don't
 need this here any more...}
{ChrstphrR - removed TPharmacyDB class and related code entirely, that Colus
 was referring to}

	{Aegis Monster Skills Load}

	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Fusion Monster AI database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\Monster_AI.txt');
	Reset(txt);
	Readln(txt, str);

  {
  AssignFile(txt2, 'Monster_AI.txt');
  Rewrite(txt2);
  Writeln(txt2, 'ID,Name,STATUS,SKILL_ID,SKILL_LV,PERCENT,CASTING_TIME,COOLDOWN_TIME,DISPEL,IF,IfCondition');
  }
  j := 1;
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
    for i := sl.Count to 9 do
			sl.Add('0');
		for i := 0 to 9 do
			if (sl.Strings[i] = '') then sl.Strings[i] := '0';

    tsAI2 := TMobAIDBFusion.Create;
    if (sl.Strings[0] <> '//') and (sl.Strings[0] <> '') then begin
		  with tsAI2 do begin
      
      tsAI2.ID      := StrToInt(sl.Strings[0]);
      tsAI2.Number  := j;
      tsAI2.Name    := sl.Strings[1];
      tsAI2.Status  := sl.Strings[2];
      tsAI2.SkillID := sl.Strings[3];
      tsAI2.SkillLV := StrToInt(sl.Strings[4]);
      tsAI2.Percent := StrToInt(sl.Strings[5]);
      tsAI2.Cast_Time := StrToInt(sl.Strings[6]);
      tsAI2.Cool_Time := StrToInt(sl.Strings[7]);
      if (sl.Strings[7] = 'NO_DISPEL') or (sl.Strings[8] = '0') then begin
        tsAI2.Dispel := sl.Strings[8];
        tsAI2.IfState := sl.Strings[9];
        tsAI2.IfCond := sl.Strings[10];
      end else begin
        tsAI2.Dispel := '0';
        tsAI2.IfState := sl.Strings[8];
        tsAI2.IfCond := sl.Strings[9];
      end;
      j := j + 1;
      //debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%d', [j]));
      //Data Converting
      {
      if MobDBName.IndexOf(tsAI2.Name) <> -1 then begin
        ts := MobDBName.Objects[MobDBName.IndexOf(tsAI2.Name)] as TMobDB;

        str1 := IntToStr(ts.ID) + ',' + str;
        str1 := IntToStr(ts.ID) + ',' + tsAI2.Name + ',' + tsAI2.Status + ',' + tsAI2.SkillID + ',' + IntToStr(tsAI2.SkillLv) + ',' +  IntToStr(tsAI2.Percent) + ',' +  IntToStr(tsAI2.Cast_Time) + ',' +  IntToStr(tsAI2.Cool_Time) + ',' +  tsAI2.Dispel + ',' +  tsAI2.IfState + ',' +  tsAI2.IfCond;
	      Writeln(txt2, str1);
      end else if tsAI2.Name <> '0' then begin
        str1 := 'ID ERROR' + ',' + tsAI2.Name;
	      Writeln(txt2, str1);
      end;}
      MobAIDBFusion.AddObject(tsAI2.Number, tsAI2);

      end;

    end;
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Fusion monster(s) skills loaded.', [MobAIDBFusion.Count]));
	Application.ProcessMessages;

  {Global Variables Load}
  if not FileExists(AppPath + 'Global_Vars.txt') then begin
		AssignFile(txt, AppPath + 'Global_Vars.txt');
		Rewrite(txt);
		Writeln(txt, '// Variable, Value');
		CloseFile(txt);
	end;
  debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Global Variables loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'Global_Vars.txt');
	Reset(txt);
	Readln(txt, str);

	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
    sl.Delimiter := ',';
		sl.DelimitedText := str;

    tGlobal := TGlobalVars.Create;
    if (sl.Strings[0] <> '//') and (sl.Strings[0] <> '') then begin
		  with tGlobal do begin

      tGlobal.Variable   := sl.Strings[0];
      tGlobal.Value   := StrToInt(sl.Strings[1]);

      GlobalVars.AddObject(tGlobal.Variable, tGlobal);
      end;
		end;
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Global Variables loaded.', [GlobalVars.Count]));
	Application.ProcessMessages;


	LoadSummonLists;
{��{���ǉ��R�R�܂�}

{�L���[�y�b�g}
	LoadPetData;
{�L���[�y�b�g�����܂�}

{NPC�C�x���g�ǉ�}
	//mapinfo_db�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Mapinfo database loading...');
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
				else if (sl[i] = 'noday') then mi.noday := true
				else if (sl[i] = 'ctf') then mi.ctf := true
                else if (sl[i] = 'pvpn') then mi.PvPN := true;

				if (Option_PVP = false) then begin
					mi.PvP  := false;
					mi.PvPG := false;
                    mi.PvPN := false;
				end;

				{�A�W�g�@�\�ǉ��R�R�܂�}
			end;
			if (j = 1) then begin
				MapInfo.AddObject(sl[0], mi);
			end;
			Inc(k);
		end;
		CloseFile(txt);
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d MapInfo database loaded.', [k]));
		Application.ProcessMessages;
	end else begin
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Mapinfo database Not Find.');
		Application.ProcessMessages;
	end;
{NPC�C�x���g�ǉ��R�R�܂�}
	//�X�L���f�[�^�x�[�X�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Skill database loading...');
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

			for i := 0 to MAX_JOB_NUMBER do begin
				Job1[i] := Job1[i] or boolean((wj and (Int64(1) shl i)) <> 0);
        if (i < (LOWER_JOB_END - 1)) and (Job1[i]) then begin
          Job1[i + LOWER_JOB_END + 1] := true;
        end;
        //if (Job1[i + LOWER_JOB_END + 1]) then debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Job1[%d] set',[i+LOWER_JOB_END+1]));
			end;
      {for i := 0 to MAX_JOB_NUMBER do begin
        if (Job1[i]) and (ID = 394) then
          debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Skill %d, job %d is set',[tl.ID, i]));
      end;}
			for i := 0 to 4 do begin
				ReqSkill1[i] := StrToInt(sl.Strings[45+i*2]);
				ReqLV1[i] := StrToInt(sl.Strings[46+i*2]);
			end;

			wj := StrToInt64(sl.Strings[55]);
			for i := 0 to MAX_JOB_NUMBER do begin
				Job2[i] := Job2[i] or boolean((wj and (Int64(1) shl i)) <> 0);
        if (i < LOWER_JOB_END - 1) then Job2[i + LOWER_JOB_END + 1] := Job2[i];
			end;
			for i := 0 to 4 do begin
				ReqSkill2[i] := StrToInt(sl.Strings[56+i*2]);
				ReqLV2[i] := StrToInt(sl.Strings[57+i*2]);
			end;
		end;
		SkillDB.AddObject(tl.ID, tl);
    SkillDBName.AddObject(tl.IDC, tl);
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d skill(s) database loaded.', [SkillDB.Count]));
	Application.ProcessMessages;

	//�o���l�e�[�u���ǂݍ���
{�M���h�@�\�ǉ�}
	//�M���h�X�L���f�[�^�x�[�X�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Guild Skill database loading...');
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
			for i := 0 to MAX_JOB_NUMBER do begin
				Job1[i] := boolean((wj and (Int64(1) shl i)) <> 0);
        if (i < LOWER_JOB_END - 1) then Job1[i + LOWER_JOB_END + 1] := Job1[i];
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d guild skill(s) database loaded.', [GSkillDB.Count]));
	Application.ProcessMessages;

  // Colus, 20040130: Adding territory name DB.
  debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Guild Territory database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\territory_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		if (sl.Count = 2) then begin
			tt := TTerritoryDB.Create;
			with tt do begin
				MapName := sl.Strings[0];
				TerritoryName := sl.Strings[1];
			end;
			TerritoryList.AddObject(tt.MapName, tt);
		end;
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d guild territories loaded.', [TerritoryList.Count]));
	Application.ProcessMessages;


	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Slave Summon Mobs List loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Slave Summon Mobs List loaded.', [j]));
	Application.ProcessMessages;

	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Make Arrow List loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Make Arrow List loaded.', [j]));
	Application.ProcessMessages;

	//�M���h�o���l�e�[�u���ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Guild EXP database loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Guild EXP database loaded.');
	Application.ProcessMessages;

	//Check for Emblem directory...
	if not DirectoryExists(AppPath + 'emblem') then begin
		if not CreateDir(AppPath + 'emblem') then begin
			MessageBox(Handle, 'The \emblem directory was not found.', 'Weiss', MB_OK or MB_ICONSTOP);
			Application.Terminate;
			Exit;
		end;
	end;
{�M���h�@�\�ǉ��R�R�܂�}

	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'EXP database loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> EXP database loaded.');
	Application.ProcessMessages;
{�C��}
	//�W���u�f�[�^�e�[�u��1�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Job database 1 loading...');
	Application.ProcessMessages;
	for i := 0 to MAX_JOB_NUMBER do begin
		WeightTable[i] := 0;
		HPTable[i] := 0;
		SPTable[i] := 1;
		for j := 0 to 16 do WeaponASPDTable[i][j] := 100;
	end;
	AssignFile(txt, AppPath + 'database\job_db1.txt');
	Reset(txt);
	for i := 0 to MAX_JOB_NUMBER do begin
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Job database 1 loaded.');
	Application.ProcessMessages;

	//�W���u�f�[�^�e�[�u��2�ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Job database 2 loading...');
	Application.ProcessMessages;
	for i := 0 to MAX_JOB_NUMBER do begin
		for j := 1 to 255 do JobBonusTable[i][j] := 0;
	end;
	AssignFile(txt, AppPath + 'database\job_db2.txt');
	Reset(txt);
	for i := 0 to MAX_JOB_NUMBER do begin
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		for j := 1 to sl.Count do JobBonusTable[i][j] := StrToInt(sl.Strings[j-1]);
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Job database 2 loaded.');
	Application.ProcessMessages;
{�C���R�R�܂�}
	//����_���[�W�C���e�[�u���ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Weapon database loading...');
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Weapon database loaded.');
	Application.ProcessMessages;

	{April 4, 2004: Warp Database - Darkhelmet
		It works like this, a Game Master can define in warp_db.txt what places any user
		can warp to without having to get to a kafra.  I.E. -warp prontera.  This will
		warp the user to prontera with the coordinates the Game Master Defines.  It also
		allows you to set a cost for the warp.  Lastly, a Game Master can define that
		a player needs item X to warp, but the item is not consumed on warp as of yet.
	}
	if WarpEnabled = true then begin
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Warping database loading...');
	Application.ProcessMessages;
	AssignFile(txt, AppPath + 'database\warp_db.txt');
	Reset(txt);
	Readln(txt, str);
	while not eof(txt) do begin
		if (sl.Strings[0] <> '//') then begin
		twp := TWarpDatabase.Create;
		sl.Clear;
		Readln(txt, str);
		sl.DelimitedText := str;
		twp.NAME := sl.Strings[0];
		twp.MAP := sl.Strings[1];
		twp.X := StrToInt(sl.Strings[2]);
		twp.Y := StrToInt(sl.Strings[3]);
		twp.Cost := StrToInt(sl.Strings[4]);
		WarpDatabase.AddObject(twp.NAME, twp);
		end;
	end;
	CloseFile(txt);
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('-> Total %d Warps loaded.', [WarpDatabase.Count]));
	Application.ProcessMessages;
	end;



	//�����e�[�u���ǂݍ���
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Element database loading...');
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
		for j := 0 to 19 do ElementTable[i][j+20] := StrToInt(sl.Strings[j]);
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
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + '-> Element database loaded.');
	Application.ProcessMessages;

	//�X�N���v�g�t�@�C���̃��X�g���쐬
	debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Making script list...');
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
	sl1.Free;
	{ChrstphrR 2004/04/26 - This 2nd TSL was created, used ... not free'd proper.
	}
end;//proc DatabaseLoad()
//------------------------------------------------------------------------------

procedure DataLoad();
var
	i, j : integer;
	txt : TextFile;
    str : String;
	sl  : TStringList;
begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

    if not FileExists(AppPath + 'addplayer.txt') then begin
        AssignFile(txt, AppPath + 'addplayer.txt');
        rewrite(txt);
        closefile(txt);
    end;

	if FileExists(AppPath + 'player.txt')
    or FileExists(AppPath + 'chara.txt')
    or FileExists(AppPath + 'party.txt')
    or FileExists(AppPath + 'pet.txt')
    or FileExists(AppPath + 'gcastle.txt')
    or FileExists(AppPath + 'guild.txt')
    then begin
        debugout.lines.add('Preparing One-Time Data Conversion to R.E.E.D.');
        Load_NonREED();
        debugout.lines.add('Conversion to R.E.E.D Initiated.');
        DataSave(true);
        debugout.lines.add('Conversion to R.E.E.D Completed.');
        DumpMemory();
        debugout.lines.add('Clearing Dynamic Memory.');
    end;

	if FileExists(AppPath + 'player.txt') then
        DeleteFile(AppPath + 'player.txt');

	if FileExists(AppPath + 'chara.txt') then
        DeleteFile(AppPath + 'chara.txt');

	if FileExists(AppPath + 'party.txt') then
        DeleteFile(AppPath + 'party.txt');

	if FileExists(AppPath + 'pet.txt') then
        DeleteFile(AppPath + 'pet.txt');

	if FileExists(AppPath + 'gcastle.txt') then
        DeleteFile(AppPath + 'gcastle.txt');

	if FileExists(AppPath + 'guild.txt') then
        DeleteFile(AppPath + 'guild.txt');

    debugout.lines.add('Loading R.E.E.D Database ... Please wait ...');
    PD_PlayerData_Load();

    { -- Server Flags -- }
	if not FileExists(AppPath + 'status.txt') then begin
		AssignFile(txt, AppPath + 'status.txt');
		Rewrite(txt);
		Writeln(txt, '##Weiss.StatusData.0x0002');
		Writeln(txt, '0');
		CloseFile(txt);
	end else begin
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Server Flag loading...');
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
		debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d Server Flag loaded.', [ServerFlag.Count]));
		Application.ProcessMessages;
							end;
    { -- Server Flags -- }

	Application.ProcessMessages;

	sl.Free;
end;

//------------------------------------------------------------------------------
procedure DataSave(forced : Boolean = False);
var
	j   : Integer;
	cnt : Integer;
	txt : TextFile;
	sl  : TStringList;
begin

	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

    PD_PlayerData_Save(forced);

    { -- Server Flags -- }
    if (ServerFlag.Count <> 0) or (forced) then begin
        AssignFile(txt, AppPath + 'status.txt');
        Rewrite(txt);
        Writeln(txt, '##Weiss.StatusData.0x0002');
        sl.Clear;
        sl.Add('0');
        cnt := 0;
        for j := 0 to ServerFlag.Count - 1 do begin
            if (Copy(ServerFlag[j], 1, 1) = '\') then begin

            { Alex: Ok, crack control again. Putting this line here ensures that any temporary
            variables stop working because the '\' in front is permanently removed. Bad coding. }
            //ServerFlag[j] := Copy(ServerFlag[j], 2, Length(ServerFlag[j]) - 1);

            if ( copy(serverflag[j],2,1) <> '@' )
            and ((ServerFlag.Values[ServerFlag.Names[j]] <> '') and (ServerFlag.Values[ServerFlag.Names[j]] <> '0')) then begin
                sl.Add(Copy(ServerFlag[j], 2, Length(ServerFlag[j]) - 1));
                Inc(cnt);
				end;
			end;
		end;
        sl.Strings[0] := IntToStr(cnt);
        writeln(txt, sl.DelimitedText);
        CloseFile(txt);
	end;
    { -- Server Flags -- }
    

	sl.Free;
end;
//------------------------------------------------------------------------------

procedure Load_NonREED();
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

    redo : Boolean;

begin
	sl := TStringList.Create;
	sl.QuoteChar := '"';
	sl.Delimiter := ',';

	if not FileExists(AppPath + 'addplayer.txt') then begin
		AssignFile(txt, AppPath + 'addplayer.txt');
				rewrite(txt);
				closefile(txt);
		end;

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
		//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Server Flag loading...');
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
		//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d Server Flag loaded.', [ServerFlag.Count]));
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
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Player data loading...');
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

                    Name := remove_badsavechars(Name);

					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					Banned := StrToInt(sl.Strings[5]);
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

                    for i := 0 to 8 do begin
                        CName[i] := remove_badsavechars(CName[i]);
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

                redo := True;
                while (redo) do begin
                    redo := False;
                    for i := 0 to PlayerName.Count - 1 do begin
                        if AnsiLowerCase(tp.Name) = AnsiLowerCase(PlayerName[i]) then begin
                            tp.Name := tp.Name + '_';
                            redo := True;
                        end;
                    end;
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
                    Name := remove_badsavechars(Name);
					Pass := sl.Strings[2];
					Gender := StrToInt(sl.Strings[3]);
					Mail := sl.Strings[4];
					Banned := 0;
					CName[0] := remove_badsavechars(sl.Strings[5]);
					CName[1] := remove_badsavechars(sl.Strings[6]);
					CName[2] := remove_badsavechars(sl.Strings[7]);
				end;

                redo := True;
                while (redo) do begin
                    redo := False;
                    for i := 0 to PlayerName.Count - 1 do begin
                        if AnsiLowerCase(tp.Name) = AnsiLowerCase(PlayerName[i]) then begin
                            tp.Name := tp.Name + '_';
                            redo := True;
                        end;
                    end;
                end;

				PlayerName.AddObject(tp.Name, tp);
				Player.AddObject(tp.ID, tp);
			end;
		end;
	end;
	CloseFile(txt);
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d player(s) data loaded.', [PlayerName.Count]));
	Application.ProcessMessages;

	//�L������񃍁[�h
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Character data loading...');
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
			Name          := remove_badsavechars(sl.Strings[ 1]);
			JID           := StrToInt(sl.Strings[ 2]);
			// Colus, 20040305: JID becomes the 'proper' value.
			if (JID > LOWER_JOB_END) then JID := JID - LOWER_JOB_END + UPPER_JOB_BEGIN;
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

			// AlexKreuz: Added to reset hide status on load.
			if (Option and 6 <> 0) then Option := Option and $FFF9;

			Karma         := StrToInt(sl.Strings[13]);
			Manner        := StrToInt(sl.Strings[14]);

			HP            := StrToInt(sl.Strings[15]);

			if (HP < 0) then begin
				HP := 0;
			end;

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
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid Map "%s"', [Name, Map]));
				Map := 'prontera';
				Point.X := 158;
				Point.Y := 189;
			end;
			//���W�`�F�b�N
			ta := MapList.Objects[MapList.IndexOf(Map)] as TMapList;
			if (Point.X < 0) or (Point.X >= ta.Size.X) or (Point.Y < 0) or (Point.Y >= ta.Size.Y) then begin
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid Map Point "%s"[%dx%d] (%d,%d)',[Name, Map, ta.Size.X, ta.Size.Y, Point.X, Point.Y]));
				Map := 'prontera';
				Point.X := 158;
				Point.Y := 189;
			end;

			//�}�b�v���݃`�F�b�N
			if MapList.IndexOf(SaveMap) = -1 then begin
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid SaveMap "%s"', [Name, SaveMap]));
				SaveMap := 'prontera';
				SavePoint.X := 158;
				SavePoint.Y := 189;
			end;
			//���W�`�F�b�N
			ta := MapList.Objects[MapList.IndexOf(SaveMap)] as TMapList;
			if (SavePoint.X < 0) or (SavePoint.X >= ta.Size.X) or (SavePoint.Y < 0) or (SavePoint.Y >= ta.Size.Y) then begin
				//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid SaveMap Point "%s"[%dx%d] (%d,%d)', [Name, SaveMap, ta.Size.X, ta.Size.Y, SavePoint.X, SavePoint.Y]));
				SaveMap := 'prontera';
				SavePoint.X := 158;
				SavePoint.Y := 189;
			end;

			for i := 0 to 2 do begin
				//�}�b�v���݃`�F�b�N
				if (MemoMap[i] <> '') and (MapList.IndexOf(MemoMap[i]) = -1) then begin
					//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid MemoMap%d "%s"', [Name, i, MemoMap[i]]));
					MemoMap[i] := '';
					MemoPoint[i].X := 0;
					MemoPoint[i].Y := 0;
				end else if MemoMap[i] <> '' then begin
					//���W�`�F�b�N
					ta := MapList.Objects[MapList.IndexOf(MemoMap[i])] as TMapList;
					if (MemoPoint[i].X < 0) or (MemoPoint[i].X >= ta.Size.X) or
						 (MemoPoint[i].Y < 0) or (MemoPoint[i].Y >= ta.Size.Y) then begin
						//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('%s : Invalid MemoMap%d Point "%s"[%dx%d] (%d,%d)', [Name, i, MemoMap[i], ta.Size.X, ta.Size.Y, MemoPoint[i].X, MemoPoint[i].Y]));
						MemoMap[i] := '';
						MemoPoint[i].X := 0;
						MemoPoint[i].Y := 0;
					end;
				end;
			end;
		end;
		//�X�L�����[�h
		for i := 0 to MAX_SKILL_NUMBER do begin
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
{�J�[�g�@�\�ǉ��R�R�܂�}
			for i := 1 to j do begin
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

        redo := True;
        while (redo) do begin
            redo := False;
            for i := 0 to CharaName.Count - 1 do begin
                if AnsiLowerCase(tc.Name) = AnsiLowerCase(CharaName[i]) then begin
                    tc.Name := tc.Name + '_';
                    tp.CName[tc.CharaNumber] := tc.Name;
                    redo := True;
                end;
            end;
        end;

		CharaName.AddObject(tc.Name, tc);
		Chara.AddObject(tc.CID, tc);
	end;
	CloseFile(txt);
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d character(s) data loaded.', [CharaName.Count]));
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
                if k = -1 then begin
                    k := CharaName.IndexOf(tp.CName[j]+'_');
                    tp.CName[j] := tp.CName[j] + '_';
                end;
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
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Castle data loading...');
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
			Name := remove_badsavechars(sl.Strings[0]);
			GID  := StrToInt(sl.Strings[1]);
			GName:= remove_badsavechars(sl.Strings[2]);
			GMName:=remove_badsavechars(sl.Strings[3]);
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
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d Castle(s) data loaded.', [CastleList.Count]));
	Application.ProcessMessages;


	//�p�[�e�B�[��񃍁[�h
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Party data loading...');
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
			Name := remove_badsavechars(sl.Strings[0]);
			for i := 0 to 11 do begin
				MemberID[i] := StrToInt(sl.Strings[i+1]);
			end;
			EXPShare := False;
		end;
		PartyNameList.AddObject(tpa.Name, tpa);
		// debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('Name : %s.', [tpa.Name]));
	end;
	CloseFile(txt);
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d Party(s) data loaded.', [PartyNameList.Count]));
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
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Guild data loading...');
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
			Name := remove_badsavechars(sl.Strings[1]);
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
				tgb.Name := remove_badsavechars(sl.Strings[k]);
				Inc(k);
				tgb.AccName := remove_badsavechars(sl.Strings[k]);
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
				tgl.GuildName := remove_badsavechars(sl.Strings[k]);
				Inc(k);
				RelAlliance.AddObject(tgl.GuildName, tgl);
			end;
			//�G��
			j := StrToInt(sl.Strings[2]);
			for i := 1 to j do begin
				tgl := TGRel.Create;
				tgl.ID := StrToInt(sl.Strings[k]);
				Inc(k);
				tgl.GuildName := remove_badsavechars(sl.Strings[k]);
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
	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + Format('*** Total %d Guild(s) data loaded.', [GuildList.Count]));
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
						tc.GuildName := remove_badsavechars(Name);
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

	//debugout.lines.add('[' + TimeToStr(Now) + '] ' + 'Pet data loading...');
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
				Name        :=           remove_badsavechars(sl.Strings[ 6]);
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
					PlayerID    := StrToInt( SL[ 0] );
					CharaID     := StrToInt( SL[ 1] );
					Cart        := StrToInt( SL[ 2] );
					Index       := StrToInt( SL[ 3] );
					Incubated   := StrToInt( SL[ 4] );
					PetID       := StrToInt( SL[ 5] );
					JID         := StrToInt( SL[ 6] );
					Name        :=           remove_badsavechars(SL[ 7]);
					Renamed     := StrToInt( SL[ 8] );
					LV          := StrToInt( SL[ 9] );
					Relation    := StrToInt( SL[10] );
					Fullness    := StrToInt( SL[11] );
					Accessory   := StrToInt( SL[12] );

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

	//debugout.lines.add('[' + TimeToStr(Now) + '] ' +  Format( '*** Total %d Pet(s) data loaded.', [PetList.Count] ) );
	Application.ProcessMessages;

{�L���[�y�b�g�����܂�}
	sl.Free;

	end;


    procedure DumpMemory();
    var
        i : Integer;
    begin

        for i := 0 to PlayerName.Count - 1 do begin
            PlayerName.Delete(0);
        end;

        for i := 0 to Player.Count - 1 do begin
            Player.Delete(0);
				end;

        for i := 0 to CharaName.Count - 1 do begin
            CharaName.Delete(0);
		end;

        for i := 0 to Chara.Count - 1 do begin
            Chara.Delete(0);
  		end;

        for i := 0 to PetList.Count - 1 do begin
            PetList.Delete(0);
    	end;

    	for i := 0 to PartyNameList.Count - 1 do begin
            PartyNameList.Delete(0);
    	end;

    	for i := 0 to GuildList.Count - 1 do begin
            GuildList.Delete(0);
    			end;

        for i := 0 to CastleList.Count - 1 do begin
            CastleList.Delete(0);
    		end;
    
    							end;


end.

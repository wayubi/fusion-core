unit Common;



interface

uses
//Windows, Forms, Classes, SysUtils, ScktComp;
	Windows, StdCtrls, MMSystem, Classes, SysUtils, ScktComp, List32;

//==============================================================================
// word�^���W�\����(TPoint��cardinal�^���W)
type rPoint = record
	X :word;
	Y :word;
end;
//------------------------------------------------------------------------------
// �q�[�v�\����(�o�H�T���p)
type rHeap = record
	cost1   :word;
	cost2   :word;
	x       :word;
	y       :word;
	mx      :word;
	my      :word;
	dir     :byte;
	path    :array[0..255] of byte;
	pcnt    :byte;
end;
//------------------------------------------------------------------------------
// �o�H�T���p�}�b�v�f�[�^
type rSearchMap = record
	cost    :word;
	path    :array[0..255] of byte;
	pcnt    :byte;
	addr    :byte;
end;
//------------------------------------------------------------------------------
// �A�C�e���f�[�^�x�[�X
type TItemDB = class
	ID        :word;
	Name      :string;
	JName     :string;
	IType     :byte;
	IEquip    :boolean;
	Price     :cardinal;
	Sell      :cardinal;
	Weight    :word;
	ATK       :word;
	MATK      :word;
	DEF       :word;
	MDEF      :word;
	Range     :byte;
	Slot      :byte;
	Param     :array[0..5] of shortint;
	HIT       :smallint;
	FLEE      :smallint;
	Crit      :byte;
	Avoid     :byte;
	Cast      :cardinal;
	Job       :Int64;
	Gender    :byte;
	Loc       :word;
	wLV       :byte;
	eLV       :byte;
	View      :byte;
	Element   :byte;
	Effect    :byte;
	HP1       :word;
	HP2       :word;
	SP1       :word;
	SP2       :word;
	//Rare      :boolean;
	//Box       :byte;
{�ύX}
	DamageFixR :array[0..9] of Word; //�푰
	DamageFixE :array[0..9] of Word; //����
	DamageFixS :array[0..2] of Word; //�T�C�Y
	SFixPer1   :array[0..5] of Word; //��ԂP
	SFixPer2   :array[0..4] of Word; //��ԂQ
	DrainFix   :array[0..1] of Word; //�z����
	DrainPer   :array[0..1] of Word; //�z���m��
	AddSkill   :array[0..336] of Word; //�X�L���ǉ�
	SplashAttack  :boolean;          //�X�v���b�V��
        WeaponSkill   :integer;
        WeaponSkillLV :integer;
        WeaponID      :integer;
	NoJamstone    :boolean;
        
        FastWalk      :boolean;
        NoTarget      :boolean;
        FullRecover   :boolean;
        LessSP        :boolean;
        OrcReflect    :boolean;
        AnolianReflect :boolean;
        UnlimitedEndure :boolean;
        DoppelgagnerASPD :boolean;
        GhostArmor    :boolean;
        NoCastInterrupt :boolean;
        MagicReflect  :boolean;
        SkillWeapon   :boolean;
        GungnirEquipped :boolean;
        LVL4WeaponASPD :boolean;
        PerfectDamage   :boolean;

{�ύX�R�R�܂�}
end;
//------------------------------------------------------------------------------
// �A�C�e���f�[�^
type TItem = class
	ID        :word;
	Amount    :word;
	Equip     :word;
	Identify  :byte;
	Refine    :byte;
	Attr      :byte;
	Card      :array[0..3] of word;
	Data      :TItemDB;
        Stolen    :cardinal;
end;
//------------------------------------------------------------------------------
{�ǉ�}
type TItemList = class
	Zeny      :Cardinal;
	Item      :Array[0..100] of TItem;
	Weight    :Cardinal;
	MaxWeight :Cardinal;
	Count     :Word;

	constructor Create;
	destructor Destroy; override;
end;
{�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�A�C�e�������ǉ�}
// �����f�[�^
type TMaterialDB = class
	ID              :word;//�����A�C�e����ID
	ItemLV          :word;//�����ɕK�v�ȃX�L�����x��(���ƂƂ̑Ή��A���X�g�\������ѐ������v�Z�Ŏg�p)
	RequireSkill    :word;//�����ɕK�v�Ƃ����X�L��(���ƂƂ̑Ή��A���X�g�\������ѐ������v�Z�Ŏg�p)
	MaterialID      :array[0..2] of word;//�����ɕK�v�ȑf�ނ�ID
	MaterialAmount  :array[0..2] of word;//�����ɕK�v�ȑf�ނ̌�
end;
{�A�C�e�������ǉ��R�R�܂�}
//------------------------------------------------------------------------------

// �����X�^�[�h���b�v�A�C�e���\����
type rDropItem = record
	ID    :word;
	Per   :cardinal;
	Data  :TItemDB;
  Stolen:cardinal;
end;
//------------------------------------------------------------------------------
// �����X�^�[�f�[�^�x�[�X
//ID,Name,JName,LV,HP,EXP,JEXP,Range,ATK1,ATK2,DEF1,DEF2,MDEF1,MDEF2,HIT,FLEE,
//Scale,Race,Ele,Mode,Speed,ADelay,aMotion,dMotion,Drop1id,Drop1per,Drop2id,
//Drop2per,Drop3id,Drop3per,Drop4id,Drop4per,Drop5id,Drop5per,Drop6id,Drop6per,
//Drop7id,Drop7per,Drop8id,Drop8per,MEXP,MVP1id,MVP1per,MVP2id,MVP2per,MVP3id,MVP3per
type TMobDB = class
	ID          :word;
	Name        :string;
	JName       :string;
	LV          :byte;
	HP          :cardinal;
	SP          :cardinal; //New
	EXP         :cardinal;
	JEXP        :cardinal;
	Range1      :byte;
	ATK1        :word;
	ATK2        :word;
	DEF         :byte; //New
	MDEF        :byte; //New
        LUK            :byte; //�N���␳�pLUK
	HIT         :integer;
	FLEE        :integer;
	Param       :array[0..5] of byte; //New
	Range2      :byte; //�U���J�n���E
	Range3      :byte; //�ǔ����E

	Scale       :byte;
	Race        :byte;
	Element     :byte;
	Mode        :byte;
	Speed       :word;
	ADelay      :word;
	aMotion     :word;
	dMotion     :word;
	Drop        :array[0..7] of rDropItem;
	Item1       :word; //New
	Item2       :word; //New
	MEXP        :cardinal;
	MEXPPer     :word;
	MVPItem     :array[0..2] of rDropItem;

	isDontMove  :boolean; //Mode &  1 : �ړ�
	isActive    :boolean; //Mode &  4 : �A�N�e�B�u
{�ǉ�}
	isLoot      :boolean; //Mode &  2 : ���[�g
	isLink      :boolean; //Mode &  8 : �����N
{�ǉ��R�R�܂�}
end;
//------------------------------------------------------------------------------
// MNAME,SLAVE_1,SLAVE_2,SLAVE_3,SLAVE_4,SLAVE_5,TOTALNUMSLAVES
type TSlaveDB = class
  Name        :string;
  Slaves      :array[0..4] of integer;
  TotalSlaves :integer;
end;
//------------------------------------------------------------------------------
// ID,BROADCAST,ITEMSUMMON,MONSTERSUMMON,CHANGESTATSKILL,CHANGEOPTION,SAVERETURN,CHANGELEVEL,WARP,WHOIS,GOTOSUMMONBANISH,KILLDIEALIVE,CHANGEJOB,CHANGECOLORSTYLE,AUTORAWUNIT,REFINE
type TIDTbl = class
  ID               :integer;
  BroadCast        :integer;
  ItemSummon       :integer;
  MonsterSummon    :integer;
  ChangeStatSkill  :integer;
  ChangeOption     :integer;
  SaveReturn       :integer;
  ChangeLevel      :integer;
  Warp             :integer;
  Whois            :integer;
  GotoSummonBanish :integer;
  KillDieAlive     :integer;
  ChangeJob        :integer;
  ChangeColorStyle :integer;
  AutoRawUnit      :integer;
  Refine           :integer;
end;
//------------------------------------------------------------------------------
// ID,Create ID,Number Created
type TMArrowDB = class
  ID        :integer;
  CID       :array[0..2] of integer;
  CNum      :array[0..2] of integer;
end;
//------------------------------------------------------------------------------
// �o���l�z���p�J�E���^
type rEXPDist = record
	CData       :Pointer;
	Dmg         :integer;
end;
//------------------------------------------------------------------------------
// �����X�^�[�f�[�^
type TMob = class
	ID          :cardinal;
	Name        :string;
	JID         :word;
	Map         :string;
	Point       :TPoint;
	tgtPoint    :TPoint;
  NextPoint   :TPoint;
	Dir         :byte;
	Point1      :TPoint;
	Point2      :TPoint;
	Speed       :word;
	Stat1       :Byte; //��ԂP
	Stat2       :Byte; //��ԂQ
  nStat       :Cardinal;
	BodyTick    :Cardinal;   //�ω�Tick1
	HealthTick  :Array[0..4] of Cardinal;  //�ω�Tick2
	EffectTick  :Array[0..11] of Cardinal; //��X�L��Tick
	isLooting   :boolean;
	Item        :array[1..10] of TItem;
	HP          :integer;
	SpawnDelay1 :cardinal;
	SpawnDelay2 :cardinal;
	SpawnTick   :cardinal;
	SpawnType   :cardinal;
	ATick       :cardinal;
  NextFlag      :boolean;
	MoveTick    :cardinal;
	MoveWait    :cardinal;
        DeadWait    :cardinal;                  // mf
	DmgTick     :cardinal; //�m�b�N�o�b�N
	ppos        :integer;
	pcnt        :integer;
	path        :array[0..999] of byte; //�L�����̌o�H(�����ŋL�^����Ă܂�)
  AMode       :byte;
	ATarget     :cardinal;
	AData       :Pointer;
	ARangeFlag  :boolean;
  MMode       :byte;
	ATKPer      :word; //�v���{�b�N�Ȃǂɂ��U���͕␳
	DEFPer      :word; //�v���{�b�N�Ȃǂɂ��h��͕␳
	EXPDist     :array[0..31] of rEXPDist; //�o���l�z���p�J�E���^
	MVPDist     :array[0..31] of rEXPDist; //MVP����p�J�E���^
  Slaves      :Array[1..12] of Cardinal;
	Data        :TMobDB;
{�ǉ�}
	Element     :Byte;
	DEF1        :Byte;
	DEF2        :Byte;
	MDEF1       :Byte;
	MDEF2       :Byte;
  SlaveCount  :Byte;
	isSummon    :Boolean;
  isLeader    :boolean;
  isEmperium  :boolean;
  isGuardian  :Cardinal;
  isSlave     :boolean;
	isActive    :boolean; //Mode &  4 : �A�N�e�B�u
	LeaderID    :Cardinal;
  EmperiumID  :Cardinal;
  GID         :Cardinal;
  NPCID       :Cardinal; //��芪���p
{NPC�C�x���g�ǉ�}
	Event       :cardinal;
{NPC�C�x���g�ǉ��R�R�܂�}
	constructor Create;
	destructor Destroy; override;
{�ǉ��R�R�܂�}
end;
//------------------------------------------------------------------------------
{�L���[�y�b�g}
// �y�b�g�f�[�^�x�[�X
type TPetDB = class
	MobID           :word; // �y�b�g�����X�^�[��ID
	ItemID          :word; // �ߊl�A�C�e����ID
	EggID           :word; // ���̃A�C�e��ID
	AcceID          :word; // �A�N�Z�T���̃A�C�e��ID
	FoodID          :word; // �G�T�̃A�C�e��ID
	Fullness        :word; // �a���ɂ�閞���x�㏸
	HungryDelay     :word; // �����x��������(msec/-1)
	Hungry          :word; // �󕠎��a���ɂ��e���x�㏸
	Full            :word; // �������a���ɂ��e���x����
	Reserved        :word; // ??? ���̐e���x�㏸
	Die             :word; // ���S���e���x����
	Capture         :word; // ��{�ߊl��(0.1%�P��)
end;

// �y�b�g�f�[�^
type TPet = class
        PlayerID        :cardinal;
        CharaID         :cardinal;
        Cart            :byte;
        Index           :word;
        Incubated       :byte;
        PetID           :cardinal;
        JID             :word;
        Name            :string;
        Renamed         :byte;
        LV              :word;
				Relation        :integer;
        Fullness        :integer;
        Accessory       :word;
        Data            :TPetDB;
end;
{�L���[�y�b�g�����܂�}
//------------------------------------------------------------------------------
// �X�L���f�[�^�x�[�X
//N,ID,JName,Type,MLV,SP1,2,3,4,5,6,7,8,9,10,HP,Cast,Lv+,AR,Ele,
//Dat1,2,3,4,5,6,7,8,9,10,Dat2,2,3,4,5,6,7,8,9,10,Req1,LV,Req2,LV,Req3,LV
type TSkillDB = class
	ID         :word;
	IDC        :string;
	Name       :string;
	SType      :byte;
	MasterLV   :byte;
	SP         :array[1..10] of word;
	HP         :word;
	UseItem    :word; //����A�C�e�� 715=�c�f���[,716=���b�h,717=�u���[,��ItemID�̒ʂ�
	CastTime1  :integer; //Base
	CastTime2  :integer; //Lv���Ƃ�+
	CastTime3  :integer; //CastTime�����l
	Range      :byte;
	Element    :byte;
	Data1      :array[1..10] of integer;
	Data2      :array[1..10] of integer;
	Range2     :byte;
	Icon       :word;
	Job        :array[0..23] of boolean;
	ReqJID1      :byte;
	ReqSkill1   :array[0..9] of word;
	ReqLV1      :array[0..9] of word;
	ReqJID2      :byte;
	ReqSkill2   :array[0..9] of word;
	ReqLV2      :array[0..9] of word;
end;
//------------------------------------------------------------------------------
// �X�L���f�[�^
type TSkill = class
	Lv          :word;
	Card        :boolean;
        Plag        :boolean;
	//Up        :byte;
	Tick        :cardinal; //���Ԑ����L��̃X�L���̃��~�b�g
	EffectLV    :word;     //���Ԑ����L��̃X�L���̌���LV
	Effect1     :integer;  //���Ԑ����L��̃X�L���̌��ʃf�[�^1
	Data        :TSkillDB;
end;
//------------------------------------------------------------------------------
type TeNPC = class
	ID            :Cardinal;  //ID
	JID           :Word;      //(Chara)�W���u (Mob)�X�v���C�g
	CID           :Cardinal;
	Name          :string;    //���O
	Sit           :Byte;
	Data          :Pointer;
	Data2         :Pointer;

	ASpeed        :Word;
	ADelay        :Word;
	aMotion       :Word;
	dMotion       :Word;
	Speed         :Word;      //�ړ����x[msec/1�}�X]

	Item          :TItemList;

	Stat1         :Word;      //��ԕω�1
	Stat2         :Word;      //��ԕω�2
	Option        :Word;      //�I�v�V����(�J�[�g�A�؂��A��Ȃ�)
	BodyTick      :Cardinal;                //��ԕω�1Tick
	HealthTick    :Array[0..4] of Cardinal;  //��ԕω�2Tick
	Effect        :Array[0..11] of Cardinal; //��ԕω�3Tick
	HPDelay       :Array[0..3] of Cardinal;
	SPDelay       :Array[0..3] of Cardinal;
	HPTick        :Cardinal;
	SPTick        :Cardinal;
	HPRTick       :Cardinal;
	SPRTick       :Cardinal;

	Hair          :Word;      //(Chara)���^
	Weapon        :Word;      //(Chara)����̌�����
	Shield        :Word;      //(Chara)���̌�����
	Head1         :Word;      //(Chara)������-��i�̌�����
	Head2         :Word;      //(Chara)������-���i�̌�����
	Head3         :Word;      //(Chara)������-���i�̌�����
	HairColor     :Word;      //(Chara)���̐F
	ClothesColor  :Word;      //(Chara)���̐F
	HeadDir       :Word;      //(Chara)���̌���
	GuildID       :Word;      //(Chara)�����M���h��ID
	__0           :Word;      //�s��1
	__1           :Word;      //�s��2
	Manner        :Word;      //(Chara)�}�i�[�|�C���g
	Karma         :Word;      //(Chara)�J���}�|�C���g
	__2           :Byte;      //�s��3
	Gender        :Byte;      //(Chara)����

	Map           :string;    //������}�b�v
	Point         :TPoint;    //��������W(������(0,0))
	Dir           :Byte;      //����
	MData         :Pointer;
	tmpMap        :string;
	NextFlag      :boolean;
	NextPoint     :TPoint;

	tgtPoint      :TPoint;    //�ړ��ڕW���W
	ppos          :Integer;   //path���ǂꂾ���i�񂾂�
	pcnt          :Integer;   //path�̌o�H��
	path          :Array[0..255] of byte; //�L�����̌o�H(�����ŋL�^����Ă܂�)
	MoveTick      :Cardinal;  //�Ō��1�}�X�i�񂾂Ƃ���Tick

	BaseLV        :Word;
	JobLV         :Word;
	BaseEXP       :Cardinal;
	JobEXP        :Cardinal;
	HP            :Integer;   //HP
	MAXHP         :Word;      //�ő�HP
	SP            :Integer;   //SP
	MAXSP         :Word;      //�ő�SP
	Param         :Array[0..5] of Byte;
	WeaponType    :Array[0..1] of Word; //�E�荶�肻�ꂼ��̕���̃^�C�v
	WeaponLv      :Array[0..1] of Word; //���ꂼ��̕��탌�x��
	ArmsFix       :Array[0..1] of Word; //�E�荶��C��
	BaseATK       :Word;
	ATK           :Array[0..1] of Word;
	RefineATK     :Array[0..1] of Word;
	SkillATK      :Word;

	Scale         :Byte;
	Race          :Byte;
	Element       :Byte;

	ATarget       :Cardinal;  //�U���Ώۂ�ID
	AData         :Pointer;   //(Chara)�U���Ώۂ�TMob (Mob)�U���Ώۂ�TChara
	ATick         :Cardinal;  //�Ō�ɍU�������Ƃ���Tick
	AMode         :Byte;
	DmgTick       :Cardinal;  //�m�b�N�o�b�N�����������Ƃ���Tick

	MMode         :Byte;
	MSkill        :Word;
	MUseLV        :Word;
	MTarget       :Cardinal;
	MTargetType   :Byte; //AData�̎�ށB0=to Mob, 1=to Player
	MPoint        :rPoint;
	MTick         :Cardinal;
	ESkill        :Array[0..100] of Word;
	ESkillLv      :Array[0..100] of Word;

	DmgFixR       :Array[0..1] of Array[0..9] of Integer; //�푰�␳% 0:�U�� 1:�h��
	DmgFixE       :Array[0..1] of Array[0..9] of Integer; //�����␳% 0:�U�� 1:�h��
	DmgFixS       :Array[0..1] of Array[0..2] of Integer; //�T�C�Y�␳%
	StatePerS1    :Array[0..1] of Array[0..4] of Integer; //�ω��m��%
	StatePerS2    :Array[0..1] of Array[0..4] of Integer;
	DrainFix      :array[0..1] of Integer; //�z����	 0:HP 1:SP
	DrainPer      :array[0..1] of Integer; //�z���m�� 0:HP 1:SP
	DAPer         :Integer; //DA�����m��
	DAFix         :Integer; //DA��������2�����v�U����%
	Arrow         :Word; //�������̖��ID

	MATK          :Integer;
	DEF1          :integer; //�h���%
	DEF3          :Integer; //�f�B���@�C���v���e�N�V����
	MDEF2         :Integer;
	HIT           :Integer;
	FLEE          :Integer;
	Critical      :Word;
	Lucky         :Word;

	Range         :Word;
	ViewRange     :Word;
	WElement      :Array[0..1] of byte; //���푮��

	ATKSplash	    :Boolean; //9�}�X�U��

end;
//------------------------------------------------------------------------------
//�L�����N�^�[�f�[�^
type TChara = class
	//����ϐ�
	ID	          :cardinal;
	Socket        :TCustomWinSocket;
	PData         :Pointer;
	IP            :string;
	Login         :byte; //0=�I�t���C�� 1=���[�h�� 2=�I�����C��

	//chara.txt��胍�[�h�A�Z�[�u����f�[�^
	//1�s��
	CID	          :cardinal;
	Name          :string;
	Gender        :byte;

	JID           :Word;
	BaseLV        :word;
	BaseEXP       :cardinal;
	StatusPoint   :word;
	JobLV         :word;
	JobEXP        :cardinal;
	SkillPoint    :word;
  PLv           :word;
  Plag          :word;
	Zeny          :cardinal;
	Stat1         :cardinal; //��ԂP
	Stat2         :cardinal; //��ԂQ
	Option        :cardinal;
    Optionkeep    :cardinal;
  Hidden        :boolean;
  Paradise      :boolean;
	Karma         :cardinal;
	Manner        :cardinal;

	HP            :integer;
	MAXHP         :word;
	SP            :integer;
	MAXSP         :word;
{�ǉ�}
	MAXHPPer      :Word;
	MAXSPPer      :Word;
{�ǉ��R�R�܂�}
	Speed         :word;
	Hair          :word;
	_2            :word;
	_3            :word;
	Weapon        :word;
	Shield        :word;
	Head1         :word;
	Head2         :word;
	Head3         :word;
	HairColor     :word;
	ClothesColor  :word;

	ParamBase     :array[0..5] of word;
	{
	STR           :byte;
	AGI           :byte;
	VIT           :byte;
	INT           :byte;
	DEX           :byte;
	LUK           :byte;
	}
	CharaNumber   :byte;
	_4            :word;

	Map           :string;
	Point         :TPoint;
	SaveMap       :string;
	SavePoint     :TPoint;
	MemoMap       :array[0..2] of string;
	MemoPoint     :array[0..2] of TPoint;

	//2�s��
	Skill         :array[0..336] of TSkill;

	//3�s��
	Item          :array[1..100] of TItem;
	//4�s��
	Cart          :TItemList;
	//5�s��
	Flag          :TStringList;

	//
	DefaultSpeed  :word;
	EquipJob			:Int64;
	BaseNextEXP   :cardinal;
	JobNextEXP    :cardinal;
	Weight        :cardinal;
	MaxWeight     :cardinal;
	Bonus         :array[0..5] of word;
	Param         :array[0..5] of word;
	ParamUp       :array[0..5] of word;
	WeaponType    :array[0..1] of word; //�E�荶�肻�ꂼ��̕���̃^�C�v
{�ǉ�}
	WeaponLv      :array[0..1] of word; //���ꂼ��̕��탌�x��
{�ǉ��R�R�܂�}
	ArmsFix       :array[0..1] of word; //�E�荶��C��
	ATK           :array[0..1] of array[0..5] of word; //�\���U����
	ATKFix        :array[0..1] of array[0..2] of integer; //�G�T�C�Y�ɂ�镐��␳
{�ύX}
	AttPower      :Word; //�J�[�h���ɂ����Z�U����
	DamageFixR    :array[0..1] of array[0..9] of Integer; //�푰�␳% 0:�U�� 1:�h��
	DamageFixE    :array[0..1] of array[0..9] of Integer; //�����␳% 0:�U�� 1:�h��
	DamageFixS    :array[0..2] of Integer;                //�T�C�Y�␳%
{�ύX�R�R�܂�}
	DAPer         :integer; //DA�����m��
	DAFix         :integer; //DA��������2�����v�U����%
	Arrow         :word; //�������̖��ID
	MATK1         :integer;
	MATK2         :integer;
	MATKFix       :integer;
	DEF1          :integer; //�h���%
	DEF2          :integer; //�h���-
	DEF3          :integer; //�f�B���@�C���v���e�N�V����
	MDEF1         :integer;
	MDEF2         :integer;
	HIT           :integer;
	FLEE1         :integer;
	FLEE2         :integer;
        FLEE3         :integer;
	Critical      :word;
	Lucky         :word;
	ASpeed        :word;
	ADelay        :word;
	aMotion       :word;
	dMotion       :word;
	MCastTimeFix  :byte; //�r�����ԕ␳%
	HPDelay       :array[0..3] of cardinal;
	SPDelay       :array[0..3] of cardinal;
{�ǉ�}
	HPDelayFix    :Integer;
	SPDelayFix    :Integer;
{�ǉ��R�R�܂�}
	Range         :word;
	WElement      :array[0..1] of byte; //���푮��
	HPR           :word; //HP�񕜃X�L���̉񕜒l
	SPR           :word; //SP�񕜃X�L���̉񕜒l
{�ύX}
	DrainFix      :array[0..1] of Integer; //�z����   0:HP 1:SP
	DrainPer      :array[0..1] of Integer; //�z���m�� 0:HP 1:SP
	SplashAttack  :boolean;                //9�}�X�U��
        WeaponSkill   :integer;
        WeaponSkillLv :integer;
        WeaponID      :integer;
	NoJamstone    :boolean;
        NoTrap        :boolean;
        LessSP        :boolean;
        FastWalk      :boolean;
        NoTarget      :boolean;
        FullRecover   :boolean;
        OrcReflect    :boolean;
        AnolianReflect :boolean;
        UnlimitedEndure :boolean;
        DoppelgagnerASPD :boolean;
        GhostArmor    :boolean;
        NoCastInterrupt :boolean;
        MagicReflect  :boolean;
        SkillWeapon   :boolean;
        GungnirEquipped :boolean;
        LVL4WeaponASPD :boolean;
        PerfectDamage   :boolean;

        {Sage Effects}
        SageElementEffect   :boolean;

	//# �X�e�ϗp
	SFixPer1       :array[0..1] of array[0..4] of Integer; //�ω��m��%
	SFixPer2       :array[0..1] of array[0..4] of Integer;
	BodyTick       :Integer;                  //��ԂP�pTick
	HealthTick     :array[0..4] of Integer;   //��ԂQ�pTick
{�ύX�R�R�܂�}
	//�����p�ϐ�
	ver2          :word;

	tmpMap        :string;
	tgtPoint      :TPoint; //�ړ���

	HPTick        :cardinal;
	SPTick        :cardinal;
	HPRTick       :cardinal;
	SPRTick       :cardinal;
	SkillTick     :cardinal; //���ɃX�L�����؂��Ƃ���Tick
	SkillTickID   :word; //���ɂǂ̃X�L�����؂�邩

	MData         :Pointer;
	ppos          :integer;
	pcnt          :integer;
	path          :array[0..999] of byte; //�L�����̌o�H(�����ŋL�^����Ă܂�)
	NextFlag      :boolean;
	NextPoint     :TPoint;
	MoveTick      :cardinal;

	PartyName     :string; //�����͂��̂����f�[�^�t�@�C������ǂނ悤�ɂ��邱��
	GuildName     :string;
	GuildID       :word;
	ClassName     :string;
{���BNPC�@�\�ǉ�}
  EqLock        :Boolean; //���B�p�������b�N
{���BNPC�@�\�ǉ��R�R�܂�}
{�`���b�g���[���@�\�ǉ�}
	ChatRoomID    :cardinal; //�`���b�g���[��ID
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
	VenderID      :cardinal; //�I�X�J��ID
{�I�X�X�L���ǉ��R�R�܂�}
{����@�\�ǉ�}
	DealingID     :cardinal; //�����ID
	PreDealID     :cardinal; //�����]ID
{����@�\�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
	GuildInv      :cardinal; //�M���h���U�ΏۃL����
	GuildPos      :byte; //�M���h�E�ʃC���f�b�N�X
{�M���h�@�\�ǉ��R�R�܂�}

	Dir           :byte;
	HeadDir       :word;
	Sit           :byte; //0:�ړ� 1:���S 2:���� 3:����
	AMode         :byte;
	//0=�U�����łȂ� 1=1��U�� 2=�U���������� 3=NPC�Ɖ�b�� 4=�q�ɃI�[�v����
	//5=�g���[�h��
	ATarget       :cardinal; //�U���Ώۂ�ID
	AData         :Pointer; //�U���Ώۂ�TNPC�^�f�[�^
	ATick         :cardinal; //�Ō�ɍU�������Ƃ���Tick
	ScriptStep    :integer; //NPC�g�[�N�̃X�e�b�v
	DmgTick       :cardinal; //�m�b�N�o�b�N
	TargetedTick  :cardinal; //���C�Ɉ͂܂�Ă邩�̃`�F�b�N�̍ŏI�m�F����Tick
	TargetedFix   :integer;  //�G�Ɉ͂܂�Ẳ�𗦌���(1/10%)

	MMode         :byte;
	MSkill        :word;
	MUseLV        :word;
	MTarget       :cardinal;
	MTargetType   :byte; //AData�̎�ށB0=to Mob, 1=to Player
	MPoint        :rPoint;
	MTick         :cardinal;

	TalkNPCID     :cardinal;
	UseItemID     :word;

{�ǉ�}
	ItemSkill     :Boolean;
	Auto          :Word; // 0:���� 1:�U�� 2:�X�L�� 4:���[�g 8:�ړ� 16:�ǐ�
	A_Skill       :Word;
	A_Lv          :Word;
	ActTick       :Cardinal;
{�ǉ��R�R�܂�}
{�L���[�y�b�g}
        PetData       :Pointer;
        PetNPC        :Pointer;
        Crusader      :Pointer;
        Autocastactive :Boolean;
        noday         :Boolean;

        noHPRecovery  :Boolean;   {Player Cannot Recover HP}
        noSPRecovery  :Boolean;   {Player Cannot Recover SP}

        SPRedAmount   :integer;   {Amount SP Usage is Reduced by}

        LastSong      :integer;   {Last Song a Bard Cast}
        LastSongLV    :integer;   {Level of last song a Bard Cast}
        InField       :boolean;   {Determine if a player is in a skill field}
        SongTick      :cardinal;   {Determines if Bard is Casting a Song}
        SPSongTick    :cardinal;  {For Decreasing SP when using Songs}

	constructor Create;
	destructor  Destroy; override;
end;
//------------------------------------------------------------------------------
// �v���C���[�f�[�^
type TPlayer = class
	Login         :byte; //0=�I�t���C�� 1=���O�C����
	ID	          :cardinal;
	IP            :string;
	Name          :string;
	Pass          :string;
	Gender        :byte;
	Mail          :string;
	Banned        :byte;
	CName         :array[0..8] of string;
	CData         :array[0..8] of TChara;
	Kafra         :TItemList;

	LoginID1      :cardinal;
	LoginID2      :cardinal;
	ver2          :word;

	constructor Create;
	destructor  Destroy; override;
end;
//------------------------------------------------------------------------------
{�p�[�e�B�[�@�\�ǉ�}
// �p�[�e�B�[�f�[�^
type TParty = class
	Name      :string;//�p�[�e�B�[�̖��O
	MinLV     :word;//�p�[�e�B�[���Œ჌�x��
	MaxLV     :word;//�p�[�e�B�[���ő僌�x��
	EXPShare  :word;//�p�[�e�B�[�o���l�ݒ�(0���o���o����1������)
	ITEMShare :word;//�p�[�e�B�[�A�C�e���ݒ�(0���o���o����1�����L�H�������v�f)
	MemberID  :array[0..11] of cardinal;//�����o�[��ID
	Member    :array[0..11] of TChara;//�����o�[
	EXP       :Cardinal; //�o���l���z�p
	JEXP      :Cardinal; //�o���l���z�p
        PartyBard :array[0..2] of TChara; {Tracks Who the Party's Bard is}
        PartyDancer :array[0..2] of TChara; {Tracks Who the Party's Dancer is}
end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
type TCastle = class
	Name    :string;
  GID     :word;
  GName   :string;
  GMName  :string;
  GKafra  :integer;
  EDegree :cardinal;
  ETrigger:integer;
  DDegree :cardinal;
  DTrigger:integer;
  GuardStatus:array [0..7] of integer;
end;
//------------------------------------------------------------------------------
type TEmp = class
	Map    :string;
  EID    :cardinal;
end;
//------------------------------------------------------------------------------
// �X����A�C�e��
type TShopItem = class
	ID    :word;
	Price :cardinal;
	Data  :TItemDB;
end;
//------------------------------------------------------------------------------
// NPC�X�N���v�g
type rScript = record
	ID      :word; //�R�}���hID
	Data1   :array of string;
	Data2   :array of string;
	Data3   :array of integer;
	DataCnt :cardinal;
end;
//------------------------------------------------------------------------------
// NPC�f�[�^
type TNPC = class
	ID          :cardinal;
	Name        :string;
{NPC�C�x���g�ǉ�}
//	JID         :word;
	JID         :integer;
{NPC�C�x���g�ǉ��R�R�܂�}
	Map         :string;
  Reg         :string;
	Point       :TPoint;
	Dir         :byte;
	CType       :byte; //0=warp 1=shop 2=script 3=item 4=skill
	//warp
	WarpSize    :TPoint;
	WarpMap     :string;
	WarpPoint   :TPoint;
	//shop
	ShopItem    :array of TShopItem;
	//script
	Script      :array of rScript;
	ScriptCnt   :integer;
	ScriptLabel :string;
{NPC�C�x���g�ǉ�}
	ScriptInitS  :integer; //OnInit�X�e�b�v
	ScriptInitD  :Boolean; //OnInit���s�σt���O
  ScriptInitMS :integer;
  
	ChatRoomID  :cardinal; //�`���b�g���[��ID
	Enable      :Boolean; //�L���X�C�b�`
{�A�W�g�@�\�ǉ�}
	Agit        :string; //�G���u�����\���p
{�A�W�g�@�\�ǉ��R�R�܂�}
{NPC�C�x���g�ǉ��R�R�܂�}
	//item
	Item        :TItem;
	SubX        :byte;
	SubY        :byte;
	Tick        :cardinal;
	//skill
	Count       :word;
	CData       :TChara;
{�ǉ�}
	MSkill      :Word;
{�ǉ��R�R�܂�}
	MUseLV      :word;
{�L���[�y�b�g}
        //pet
        HungryTick  :cardinal;
        NextPoint   :TPoint;
        MoveTick    :cardinal;
        ppos        :integer;
	pcnt        :integer;
        path        :array[0..999] of byte; //�L�����̌o�H(�����ŋL�^����Ă܂�)
{�L���[�y�b�g�����܂�}
end;
//------------------------------------------------------------------------------
{NPC�C�x���g�ǉ�}
// �^�C�}�[�f�[�^
type NTimer = class
	ID        :cardinal;//�^�C�}�[ID
	Tick      :cardinal;//�^�C�}�[
	Cnt       :word;//�^�C�}�[�C���f�b�N�X��
	Idx       :array of integer;//�C���f�b�N�X
	Step      :array of integer;//�����
	Done      :array of byte;//���s�ς݃t���O
end;
//�}�b�v�ݒ�f�[�^
type MapTbl = class
	noMemo    :Boolean;
	noSave    :Boolean;
{�A�W�g�@�\�ǉ�}
	noPortal  :Boolean;
	noFly     :Boolean;
	noBfly    :Boolean;
	noBranch  :Boolean;
	noSkill   :Boolean;
	noItem    :Boolean;
	Agit      :Boolean;
{�A�W�g�@�\�ǉ��R�R�܂�}
	noTele    :Boolean;
        PvP       :Boolean;
        PvPG      :Boolean;
        noDay     :Boolean;

end;
{NPC�C�x���g�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
// �}�b�v�u���b�N�f�[�^
type TBlock = class
	NPC         :TIntList32;
	Mob         :TIntList32;
	CList       :TIntList32;
	//MobProcess  :boolean;
	MobProcTick :cardinal;

	constructor Create;
	destructor Destroy; override;
end;
//------------------------------------------------------------------------------
// �}�b�v�f�[�^
type TMap = class
	Name      :string;
	Size      :TPoint;
	gat       :array of array of byte; //bit1=�ړ��\ bit2=�����܂� bit3=Warp
	BlockSize :TPoint;
	Block     :array[-3..67] of array[-3..67] of TBlock; // 512/8=64 0-3~(64-1)+3
	NPC       :TIntList32;
	NPCLabel	:TStringList;
	CList     :TIntList32;
	Mob       :TIntList32;
	Mode      :byte; //0=�����[�h 1=���[�h�� 2=���[�h�ς�
{NPC�C�x���g�ǉ�}
	TimerAct  :TIntList32; //���쒆�^�C�}�[
	TimerDef  :TIntList32; //��`�σ^�C�}�[
{NPC�C�x���g�ǉ��R�R�܂�}

	constructor Create;
	destructor Destroy; override;
end;
//------------------------------------------------------------------------------
// �}�b�v���X�g�f�[�^
type TMapList = class
	Name      :string;
        Ext       :string;
	Size      :TPoint;
	Mode      :byte; //0=�����[�h 1=���[�h�� 2=���[�h�ς�
end;
//------------------------------------------------------------------------------
// �o�H�T���p�\����
type rPath = record
	x       :Integer;
	y       :Integer;
	dist    :integer;
	dir     :integer;
	before  :integer;
	cost    :integer;
end;
//------------------------------------------------------------------------------
{�`���b�g���[���@�\�ǉ�}
// �`���b�g���[���f�[�^
type TChatRoom = class
	ID        :cardinal;//�`���b�g���[��ID
	Title     :string;//�`���b�g���[���^�C�g��
	Limit     :word;//�ő�l��
	Users     :word;//�����l��
	Pub       :Byte;//���Jor����J
	Pass      :string;//�p�X���[�h
	MemberID  :array[0..20] of cardinal;//�����o�[��ID
	MemberCID :array[0..20] of cardinal;//�����o�[��CID
	MemberName :array[0..20] of string;//�����o�[�̖��O
	KickList   :TIntList32;//kick���[�U�[���X�g
{NPC�C�x���g�ǉ�}
	NPCowner  :Byte;
{NPC�C�x���g�ǉ��R�R�܂�}

	constructor Create;
	destructor Destroy; override;
end;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�I�X�X�L���ǉ�}
// �I�X�J�݃f�[�^
type TVender = class
	ID        :cardinal;//�I�[�i�[ID
	CID       :cardinal;//�I�[�i�[CID
	Title     :string;//�I�X�^�C�g��
	Cnt       :word;//�I�X�c��A�C�e����
	MaxCnt    :word;//�I�X�ő�A�C�e����
	Idx       :array[0..12] of word;//�A�C�e���C���f�b�N�X
	Price     :array[0..12] of cardinal;//���i
	Amount    :array[0..12] of word;//����
	Weight    :array[0..12] of word;//�d��
end;
{�I�X�X�L���ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{����@�\�ǉ�}
type TDealings = class
	ID        :cardinal;//���ID
	UserID    :array[0..2] of cardinal;//�A�J�E���gID
	Cnt       :array[0..2] of word;//�A�C�e����
	Zeny      :array[0..2] of cardinal;//�[�j�[
	ItemIdx   :array[0..2] of array[0..10] of word;//�A�C�e���C���f�b�N�X
	Amount    :array[0..2] of array[0..10] of cardinal;//����
	Mode      :array[0..2] of Byte;//�i�s��
end;
{����@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{��{���ǉ�}
type TSummon = class
	Name      :string;
end;
{��{���ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�M���h�@�\�ǉ�}
// �M���h�f�[�^
type TGuild = class
	ID           :Cardinal;//ID
	Name         :string;//���O
	LV           :word;//���x��
	EXP          :Cardinal;//�o���l
	NextEXP      :Cardinal;//���x���A�b�v�o���l
	MasterName   :string;//�M���h�}�X�^�[�̖��O
	RegUsers     :word;//�o�^�Ґ�
	MaxUsers     :word;//���
	SLV          :word;//�����o�[�̃��x���̍��v
	MemberID     :array[0..36] of cardinal;//�����o�[ID
	Member       :array[0..36] of TChara;//�����o�[
	MemberPos    :array[0..36] of Byte;//�����o�[�E��
	MemberEXP    :array[0..36] of cardinal;//��[�o���l
	PosName      :array[0..20] of string;//�E�ʖ�
	PosInvite    :array[0..20] of boolean;//��������
	PosPunish    :array[0..20] of boolean;//��������
	PosEXP       :array[0..20] of byte;//EXP��[%
	Notice       :array[0..2] of string;//���m
	Agit         :string;//�Ǘ��̒n
	Emblem       :Cardinal;//�G���u����
	GSkill       :array[10000..10005] of TSkill;
	GSkillPoint  :word;//�X�L���|�C���g
	Present      :Cardinal;//��[�|�C���g
	DisposFV     :integer;//����F-V
	DisposRW     :integer;//����R-W
	GuildBanList :TStringList;//�Ǖ��҃��X�g
	RelAlliance  :TStringList;//�����M���h���X�g
	RelHostility :TStringList;//�G�΃M���h���X�g

	constructor Create;
	destructor  Destroy; override;
end;
//------------------------------------------------------------------------------
type TGBan = class
// �M���h�Ǖ��҃f�[�^
	Name    :string;//�L������
	AccName :string;//�A�J�E���g��
	Reason  :string;//�Ǖ����R
end;
//------------------------------------------------------------------------------
type TGRel = class
// �����E�G�΃M���h�f�[�^
	ID        :Cardinal;//�M���hID
	GuildName :string;//�����E�G�΃M���h��
end;
{�M���h�@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
// �萔
const
	CodeVersion = 'D-Weiss alpha.$0100-fix5';
	PacketLength:array[0..$200] of integer = (
// +0  +1  +2  +3  +4  +5  +6  +7   +8  +9  +a  +b  +c  +d  +e  +f
	 10,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0000
		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0010
		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0020
		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0030

		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0040
		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x0050
		0,  0,  0,  0, 55, 17,  3, 37,  46, -1, 23, -1,  3,108,  3,  2, // 0x0060
		3, 28, 19, 11,  3, -1,  9,  5,  52, 51, 56, 58, 41,  2,  6,  6, // 0x0070

		7,  3,  2,  2,  2,  5, 16, 12,  10,  7, 29, 23, -1, -1, -1,  0, // 0x0080
		7, 22, 28,  2,  6, 30, -1, -1,   3, -1, -1,  5,  9, 17, 17,  6, // 0x0090
	 23,  6,  6, -1, -1, -1, -1,  8,   7,  6,  7,  4,  7,  0, -1,  6, // 0x00a0
		8,  8,  3,  3, -1,  6,  6, -1,   7,  6,  2,  5,  6, 44,  5,  3, // 0x00b0

		7,  2,  6,  8,  6,  7, -1, -1,  -1, -1,  3,  3,  6,  3,  2, 27, // 0x00c0
		3,  4,  4,  2, -1, -1,  3, -1,   6, 14,  3, -1, 28, 29, -1, -1, // 0x00d0
	 30, 30, 26,  2,  6, 26,  3,  3,   8, 19,  5,  2,  3,  2,  2,  2, // 0x00e0
		3,  2,  6,  8, 21,  8,  8,  2,   2, 26,  3, -1,  6, 27, 30, 10, // 0x00f0


		2,  6,  6, 30, 79, 31, 10, 10,  -1, -1,  4,  6,  6,  2, 11, -1, // 0x0100
	 10, 39,  4, 10, 31, 35, 10, 18,   2, 13, 15, 20, 68,  2,  3, 16, // 0x0110
		6, 14, -1, -1, 21,  8,  8,  8,   8,  8,  2,  2,  3,  4,  2, -1, // 0x0120
		6, 86,  6, -1, -1,  7, -1,  6,   3, 16,  4,  4,  4,  6, 24, 26, // 0x0130

	 22, 14,  6, 10, 23, 19,  6, 39,   8,  9,  6, 27, -1,  2,  6,  6, // 0x0140
	110,  6, -1, -1, -1, -1, -1,  6,  -1, 54, 66, 54, 90, 42,  6, 42, // 0x0150
	 -1, -1, -1, -1, -1, 30, -1,  3,  14,  3, 30, 10, 43, 14,186,182, // 0x0160
	 14, 30, 10,  3, -1,  6,106, -1,   4,  5,  4, -1,  6,  7, -1, -1, // 0x0170

		6,  3,106, 10, 10, 34,  0,  6,   8,  4,  4,  4, 29, -1, 10,  6, // 0x0180
	 90, 86, 24,  6, 30,102,  9,  4,   8,  4, 14, 10,  4,  6,  2,  6, // 0x0190
		3,  3, 35,  5, 11, 26, -1,  4,   4,  6, 10, 12,  6, -1,  4,  4, // 0x01a0
   11,  7, -1, 67, 12, 18, 114, 6,   3,  6, 26, 26, 26, 26,  2,  3, // 0x01b0

    2, 14, 10, -1, 22, 22,  4,  2,  13, 97,  0,  9,  9, 29,  6, 28, // 0x01c0
    8, 14, 10, 35,  6,  8,  4, 11,  54, 53, 60,  2, -1, 47, 33,  6, // 0x01d0
    0,  8,  0,  0,  0,  0,  0,  0,  28,  0,  0,  0,  0,  0,  0,  0, // 0x01e0
    0,  0,  0,  0,  7,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01f0

// Previous packet lengths
//		0,  0, -1,  0,  0,  0,114,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01b0
//		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01c0
//		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01d0
//		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01e0
//		0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0, // 0x01f0
		0);
//------------------------------------------------------------------------------
// �ϐ�
var
	AppPath              :string;

	ServerIP             :cardinal;
	ServerName           :string;
	DefaultNPCID         :cardinal;
	sv1port              :word;
	sv2port              :word;
	sv3port              :word;
	WarpDebugFlag        :boolean;
	BaseExpMultiplier    :cardinal;
	JobExpMultiplier     :cardinal;
	DisableMonsterActive   :boolean;
	AutoStart              :boolean;
	DisableLevelLimit      :boolean;
        DefaultZeny            :cardinal;
        DefaultMap             :string;
        DefaultPoint_X         :cardinal;
        DefaultPoint_Y         :cardinal;
        DefaultItem1           :cardinal;
        DefaultItem2           :cardinal;
	EnableMonsterKnockBack :boolean;
	DisableEquipLimit      :boolean;
	ItemDropType           :boolean;
	ItemDropDenominator    :integer;
  ItemDropMultiplier     :integer;
	ItemDropPer            :integer;
	DisableFleeDown        :boolean;
	DisableSkillLimit      :boolean;
        Timer                  :boolean;

	FormLeft:integer;
	FormTop:integer;
	FormWidth:integer;
	FormHeight:integer;

	ScriptList :TStringList;

{�A�C�e�������ǉ�}
	MaterialDB :TIntList32;
{�A�C�e�������ǉ��R�R�܂�}
{�p�[�e�B�[�@�\�ǉ�}
	PartyNameList	:TStringList;
  CastleList    :TStringList;
  EmpList       :TStringList;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
{�L���[�y�b�g}
	PetDB      :TIntList32;
        PetList    :TIntList32;
{�L���[�y�b�g�����܂�}
{�`���b�g���[���@�\�ǉ�}
	ChatRoomList :TIntList32;
	ChatMaxID  : cardinal;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
	VenderList :TIntList32;
{�I�X�X�L���ǉ��R�R�܂�}
{����@�\�ǉ�}
	DealingList :TIntList32;
	DealMaxID  :cardinal;
{����@�\�ǉ��R�R�܂�}
{��{���ǉ�}
	SummonMobList :TIntList32;
	SummonIOBList :TIntList32;
	SummonIOVList :TIntList32;
	SummonICAList :TIntList32;
	SummonIGBList :TIntList32;
{��{���ǉ��R�R�܂�}
{NPC�C�x���g�ǉ�}
	ServerFlag :TStringList;
	MapInfo    :TStringList;
{NPC�C�x���g�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
	GuildList     :TIntList32;
	NowGuildID    :cardinal;
	GSkillDB      :TIntList32;
	GExpTable     :array[0..50] of cardinal;
{�M���h�@�\�ǉ��R�R�܂�}
	//Item     :TStringList;
	ItemDB     :TIntList32;
	ItemDBName :TStringList;
	MobDB      :TIntList32;
	MobDBName  :TStringList;
  SlaveDBName:TStringList;
  MArrowDB   :TIntList32;
  IDTableDB  :TIntList32;
	SkillDB    :TIntList32;
	Player     :TIntList32;
	PlayerName :TStringList;
	Chara      :TIntList32;
	CharaName  :TStringList;
	CharaPID   :TIntList32;
	Map        :TStringList;
	MapList    :TStringList;

	//NowAccountID :cardinal;
	NowUsers      :word;
	NowLoginID    :cardinal;
	NowCharaID    :cardinal;
	NowNPCID      :cardinal;
	NowItemID     :cardinal;
	NowMobID      :cardinal;
{�L���[�y�b�g}
	NowPetID      :cardinal;
{�L���[�y�b�g�����܂�}

	DebugCnt      :word;
	id1           :cardinal;
	id2           :cardinal;
	CancelFlag    :boolean;
	ServerRunning :boolean;

	DebugOut      :TMemo;


	//exp_db
	ExpTable        :array[0..3] of array[0..255] of cardinal;
	//job_db1
	WeightTable     :array[0..23] of word;
	HPTable         :array[0..23] of word;
	SPTable         :array[0..23] of word;
	WeaponASPDTable :array[0..23] of array[0..16] of word;
	//job_db2
	JobBonusTable   :array[0..23] of array[1..255] of byte;
	//wp_db
	WeaponTypeTable :array[0..2] of array[0..16] of word;
	//ele_db
	ElementTable    :array[0..9] of array[0..99] of integer;

	mm              :array[0..30] of array[0..30] of rSearchMap;

	buf             :array[0..32767] of byte;
  buf2            :array[0..32767] of byte;
	stra            :array[0..32767] of char;
{�I�v�V�����֘A}
        //�L�����N�^�[�����f�[�^�֘A

        GMCheck         :cardinal; // GM�R�}���h��GM�ȊO���g���邩
        DebugCMD        :cardinal; // �f�o�b�O�R�}���h���g���邩
DeathBaseLoss     :integer;
DeathJobLoss      :integer;
MonsterMob        :boolean;
SummonMonsterExp  :boolean;
SummonMonsterAgo  :boolean;
SummonMonsterName :boolean;
SummonMonsterMob  :boolean;
GlobalGMsg        :string;
MapGMsg           :string;
{�I�v�V�����֘A�����܂�}

// Fusion INI Declarations
Option_PVP        :boolean;
Option_MaxUsers   :word;
// Fusion INI Declarations


//------------------------------------------------------------------------------
// �֐���`
		procedure MapLoad(MapName:string);
		procedure MapMove(Socket:TCustomWinSocket; MapName:string; Point:TPoint);
//------------------------------------------------------------------------------
		procedure RFIFOB(index:word; var b:byte);
		procedure RFIFOW(index:word; var w:word);
		procedure RFIFOL(index:word; var l:cardinal);
		function  RFIFOS(index:word; cnt:word):string;
		procedure RFIFOM1(index:word; var xy:TPoint);
		procedure RFIFOM2(index:word; var xy1:TPoint; var xy2:TPoint);
		procedure WFIFOB(index:word; b:byte);
		procedure WFIFOW(index:word; w:word);
		procedure WFIFOL(index:word; l:cardinal);
		procedure WFIFOS(index:word; str:string; cnt:word);
		procedure WFIFOM1(index:word; xy:TPoint; Dir:byte = 0);
		procedure WFIFOM2(index:word; xy1:TPoint; xy2:TPoint);
//------------------------------------------------------------------------------
		procedure PickUpItem(tc:TChara; l:Cardinal);

		procedure CalcAbility(tc:TChara; td:TItemDB; o:Integer = 0);
		procedure CalcEquip(tc:TChara);
		procedure CalcSkill(tc:TChara; Tick:cardinal);
		procedure CalcStat(tc:TChara; Tick:cardinal = 0);

                {Bard Calculations}
                procedure CalcSongSkill(tc:TChara; Tick:cardinal = 0);
                procedure CalcSongStat(tc:TChara; Tick:cardinal = 0);

                {Sage Calculations}
                procedure CalcSageSkill(tc:TChara; Tick:cardinal = 0);

		procedure CalcLvUP(tc1:TChara; EXP:cardinal; JEXP:cardinal);

		procedure SendCGetItem(tc:TChara; Index:word; Amount:word);
		procedure SendCStat(tc:TChara; View:boolean = false);
		procedure SendCStat1(tc:TChara; Mode:word; DType:word; Value:cardinal);
		procedure SendCStoreList(tc:TChara);
		procedure SendCSkillList(tc:TChara);
		procedure SendCData(tc1:TChara; tc:TChara; Use0079:boolean = false);
		procedure SendCMove(Socket: TCustomWinSocket; tc:TChara; before, after:TPoint);
		procedure SendCLeave(tc:TChara; mode:byte);
		procedure SendBCmd(tm:TMap; Point:TPoint; PacketLen:word; tc:TChara = nil; tail:boolean = False);

		procedure SendItemSkill(tc:TChara; s:Cardinal; L:Cardinal = 1);
		procedure SendSkillError(tc:TChara; Code:Cardinal);
		function  UseFieldSkill(tc:TChara; Tick:Cardinal) : Integer;
		function  UseTargetSkill(tc:TChara; Tick:Cardinal) : Integer;

		procedure SendCSkillAtk1(tm:TMap; tc:TChara; ts:TMob; Tick:cardinal; dmg:Integer; k:byte; PType:byte = 0);
                procedure SendCSkillAtk2(tm:TMap; tc:TChara; tc1:TChara; Tick:cardinal; dmg:Integer; k:byte; PType:byte = 0);

		procedure CalcSkillTick(tm:TMap; tc:TChara; Tick:cardinal = 0);

                //procedure PassiveIcons(tm:TMap; tc:TChara);  //Calculate Passive Icons

                function  UpdateSpiritSpheres(tm:TMap; tc:TChara; spiritSpheres:integer) :boolean;
		function  DecSP(tc:TChara; SkillID:word; LV:byte) :boolean;
                function  UseItem(tc:TChara; j:integer): boolean;
                function  UseUsableItem(tc:TChara; w:integer) :boolean;
                function  UpdateWeight(tc:TChara; j:integer; td:TItemDB)  :boolean;
                function  GetMVPItem(tc1:TChara; ts:TMob; mvpitem:boolean) :boolean;

		function  SearchCInventory(tc:TChara; ItemID:word; IEquip:boolean):word;
		function  SearchPInventory(tc:TChara; ItemID:word; IEquip:boolean):word;
//------------------------------------------------------------------------------
		//�����X�ENPC
		procedure SendMData(Socket:TCustomWinSocket; ts:TMob; Use0079:boolean = false);
		procedure SendMMove(Socket: TCustomWinSocket; ts:TMob; before, after:TPoint; ver2:Word);
    procedure SendNData(Socket:TCustomWinSocket; tn:TNPC; ver2:Word; Use0079:boolean = false);
		procedure SendPMove(Socket: TCustomWinSocket; te:TeNPC; before, after:TPoint; ver2:Word);
{�L���[�y�b�g}
                procedure SendPetMove(Socket: TCustomWinSocket; tc:TChara; target:TPoint);
{�L���[�y�b�g�����܂�}
//------------------------------------------------------------------------------
    //�n�_�X�L��
		function  SetSkillUnit(tm:TMap; ID:cardinal; xy:TPoint; Tick:cardinal; SType:word; SCount:word; STime:cardinal; tc:TChara = nil):TNPC;
		procedure DelSkillUnit(tm:TMap; tn:TNPC);
//------------------------------------------------------------------------------
    //�����A�C�e��
		function  MoveItem(ti1:TItemList; ti2:TitemList; Index:Word; cnt:Word) : Integer;

		function  GetItemStore(ti:TItemList; td:TItem; cnt:Word; IsEquip:Boolean = False) : Integer;
		function  DeleteItem(ti:TItemList; index:Word; cnt:Word) : Integer;
		function  SearchInventory(ti:TItemList; ItemID:word; IEquip:boolean) : word;//SearchCInventory()���Ǝg�����͓���
		procedure CalcInventory(ti:TItemList);
		procedure SendCart(tc:TChara);
//------------------------------------------------------------------------------
{�p�[�e�B�[�@�\�ǉ�}
    //�p�[�e�B�[
		procedure PartyDistribution(Map:string; tpa:TParty; EXP:Cardinal = 0; JEXP:Cardinal = 0);
		procedure SendPartyList(tc:TChara);
		procedure SendPCmd(tc:TChara; PacketLen:word; InMap:boolean = false; AvoidSelf:boolean = false);
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�`���b�g���[���@�\�ǉ�}
		procedure ChatRoomExit(tc:TChara; AvoidSelf:boolean = false);
		procedure ChatRoomDisp(Socket: TCustomWinSocket; tc1:TChara);
		procedure SendCrCmd(tc:TChara; PacketLen:word; AvoidSelf:boolean = false);
		procedure SendNCrCmd(tm:TMap; Point:TPoint; PacketLen:word; tc:TChara = nil; AvoidSelf:boolean = false; AvoidChat:boolean = false);
{�`���b�g���[���@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�I�X�X�L���ǉ�}
		procedure VenderExit(tc:TChara; AvoidSelf:boolean = false);
		procedure VenderDisp(Socket: TCustomWinSocket; tc1:TChara);
{�I�X�X�L���ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{����@�\�ǉ�}
		procedure CancelDealings(tc:TChara; AvoidSelf:boolean = false);
{����@�\�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{NPC�C�x���g�ǉ�}
		function ConvFlagValue(tc:TChara; str:string; mode:boolean = false) : Integer;
{NPC�C�x���g�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�M���h�@�\�ǉ�}
		procedure SendGuildInfo(tc:TChara; Tab:Byte; GuildM:boolean = false; AvoidSelf:boolean = false);
		procedure SendGuildMCmd(tc:TChara; PacketLen:word; AvoidSelf:boolean = false);
		procedure CalcGuildLvUP(tg:TGuild; tc:TChara; GEXP:cardinal);
		procedure SendGLoginInfo(tg:TGuild; tc:TChara);
		function  GetGuildConUsers(tg:TGuild) : word;
    procedure GuildDInvest(tn:TNPC);
    procedure SpawnNPCMob(tn:TNPC;MobName:string;X:integer;Y:integer;SpawnDelay1:cardinal;SpawnDelay2:cardinal);
    procedure CallGuildGuard(tn:TNPC;guard:integer);
    procedure SetGuildKafra(tn:TNPC;mode:integer);
    procedure EnableGuildKafra(MapName:string;KafraName:string;Mode:integer);
    procedure ClaimGuildCastle(ID:cardinal;MapName:string);
    function  GetGuildKafra(tn:TNPC) : integer;
    function  GetGuildID(tn:TNPC) : word;
    function  GetGuildEDegree(tn:TNPC) : cardinal;
    function  GetGuildETrigger(tn:TNPC) : word;
    function  GetGuildDDegree(tn:TNPC) : cardinal;
    function  GetGuildDTrigger(tn:TNPC) : word;
    function  CheckGuildID(tn:TNPC; tc:TChara) : word;
    function  CheckGuildMaster(tn:TNPC; tc:TChara) : word;
    function  GetGuildName(tn:TNPC) : string;
    function  GetGuildMName(tn:TNPC) : string;
		function  GetGuildRelation(tg:TGuild; tc:TChara) : integer;
		procedure KillGuildRelation(tg:TGuild; tg1:TGuild; tc:TChara; tc1:TChara; RelType:byte);
		function  LoadEmblem(tg:TGuild) : word;
		procedure SaveEmblem(tg:TGuild; size:cardinal);
//------------------------------------------------------------------------------
{�A�W�g�@�\�ǉ�}
		procedure SetFlagValue(tc:TChara; str:string; svalue:string);
{�A�W�g�@�\�ǉ��R�R�܂�}
{�M���h�@�\�ǉ��R�R�܂�}
//==============================================================================










implementation

//==============================================================================
{�ǉ�}
procedure PickUpItem(tc:TChara; l:Cardinal);
var
	tm:TMap;
	tn:TNPC;
	j:Integer;
begin
	with tc do begin
		tm := tc.MData;
		if tm.NPC.IndexOf(l) <> -1 then begin
			tn := tm.NPC.IndexOfObject(l) as TNPC;
			if tc.MaxWeight >= tc.Weight + tn.Item.Data.Weight * tn.Item.Amount then begin
				j := SearchCInventory(tc, tn.Item.ID, tn.Item.Data.IEquip);
				if j <> 0 then begin
					//�E�����[�V����
					WFIFOW( 0, $008a);
					WFIFOL( 2, tc.ID);
					WFIFOL( 6, tn.ID);
					WFIFOB(26, 1);
					SendBCmd(tm, tc.Point, 29);
					//�A�C�e���P��
					WFIFOW(0, $00a1);
					WFIFOL(2, tn.ID);
					SendBCmd(tm, tn.Point, 6);
					//�A�C�e���ǉ�
					tc.Item[j].ID := tn.Item.ID;
					tc.Item[j].Amount := tc.Item[j].Amount + tn.Item.Amount;
					tc.Item[j].Equip := 0;
					tc.Item[j].Identify := tn.Item.Identify;
					tc.Item[j].Refine := tn.Item.Refine;
					tc.Item[j].Attr := tn.Item.Attr;
					tc.Item[j].Card[0] := tn.Item.Card[0];
					tc.Item[j].Card[1] := tn.Item.Card[1];
					tc.Item[j].Card[2] := tn.Item.Card[2];
					tc.Item[j].Card[3] := tn.Item.Card[3];
					tc.Item[j].Data := tn.Item.Data;
					//�d�ʒǉ�
					tc.Weight := tc.Weight + tn.Item.Data.Weight * tn.Item.Amount;
					WFIFOW( 0, $00b0);
					WFIFOW( 2, $0018);
					WFIFOL( 4, tc.Weight);
					Socket.SendBuf(buf, 8);
					//�A�C�e���Q�b�g�ʒm
					SendCGetItem(tc, j, tn.Item.Amount);
					//�A�C�e���폜
					tm.NPC.Delete(tm.NPC.IndexOf(tn.ID));
					with tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC do
						Delete(IndexOf(tn.ID));
					tn.Free;
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
		end else begin
			//�E���A�C�e�������łɂȂ��Ȃ��Ă�
			WFIFOW( 0, $00a0);
			WFIFOB(22, 1);
			Socket.SendBuf(buf, 23);
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure CalcAbility(tc:TChara; td:TItemDB; o:Integer = 0);
var
	j :Integer;
begin
	with tc do begin
		if td.IType = 6 then begin
			Inc(ATTPOWER, td.ATK);
		end;
		if td.IType <> 10 then begin
			Inc(ATK[0][0], td.ATK);
		end;
		MATKFix := MATKFix + td.MATK; //��p
		DEF1 := DEF1 + td.DEF;
		MDEF1 := td.MDEF;
		HIT := HIT + td.HIT; //����
		FLEE1 := FLEE1 + td.FLEE; //���
		Critical := Critical + td.Crit; //�N���e�B�J��
		Lucky := Lucky + td.Avoid; //���S���
		for j := 0 to 5 do begin
			Bonus[j] := Bonus[j] + td.Param[j];
		end;
		for j:=0 to 9 do begin
			Inc(DamageFixR[o][j],td.DamageFixR[j]);
			Inc(DamageFixE[o][j],td.DamageFixE[j]);
		end;
		for j:=0 to 2 do begin
			Inc(DamageFixS[j],td.DamageFixS[j]);
		end;
		for j:=0 to 4 do begin
			Inc(SFixPer1[0][j],td.SFixPer1[j]);
			Inc(SFixPer2[0][j],td.SFixPer2[j]);
		end;
		Inc(DrainFix[0],td.DrainFix[0]);
		Inc(DrainPer[0],td.DrainPer[0]);
		Inc(DrainFix[1],td.DrainFix[1]);
		Inc(DrainPer[1],td.DrainPer[1]);

                if td.SkillWeapon then begin
                        tc.WeaponID := td.WeaponID;
                        tc.WeaponSkill := td.WeaponSkill;
                        tc.WeaponSkillLv := td.WeaponSkillLv;
                end;

		if td.SplashAttack then SplashAttack := true;
                if td.NoJamstone then  NoJamstone := true;
                if td.AnolianReflect then AnolianReflect := true;
                if td.FullRecover then FullRecover := true;
                if td.FastWalk then FastWalk := true;
                if td.NoTarget then NoTarget := true;
                if td.LessSP then LessSP := true;
                if td.OrcReflect then OrcReflect := true;
                if td.UnlimitedEndure then UnlimitedEndure := true;
                if td.DoppelgagnerASPD then DoppelgagnerASPD := true;
                if td.MagicReflect then MagicReflect := true;
                if td.NoCastInterrupt then  NoCastInterrupt := true;
                if td.GhostArmor then GhostArmor := true;
                if td.SkillWeapon then SkillWeapon := true;
                if td.GungnirEquipped then GungnirEquipped := true;
                if td.LVL4WeaponASPD then LVL4WeaponASPD := true;
                if td.PerfectDamage then PerfectDamage := true;

		for j :=1 to 336 do begin //�X�L���ǉ�
			if td.AddSkill[j] <> 0 then begin
				if (not Skill[j].Data.Job[JID]) and (not DisableSkillLimit) then begin
					Skill[j].Lv := td.AddSkill[j];
					Skill[j].Card := True;
				end;
			end;
		end; //for j :=1 to 336 do begin

		if td.Cast <> 0 then MCastTimeFix := MCastTimeFix * td.Cast div 100; //�r������%
		if td.HP1 <> 0 then begin //MAXHP%(1001�ȏ��+)
			if td.HP1 > 1000 then begin
				MAXHP := MAXHP + (td.HP1 - 1000);
				//end else Inc(MAXHPPer,(td.HP1-100));
                        end else try
                                        Inc(MAXHPPer,(td.HP1 - 100));
                                except
                                        exit;
                                end;
                end;
		if td.HP2 <> 0 then begin //HP�񕜑��x%
			HPDelayFix := HPDelayFix + 100 - td.HP2;
		end;
		if td.SP1 <> 0 then begin //MAXSP%(1001�ȏ��+)
			if td.SP1 > 1000 then begin
				MAXSP := MAXSP + (td.SP1 - 1000);
			end else Inc(MAXSPPer,(td.SP1 - 100));
		end;
		if td.SP2 <> 0 then begin //SP�񕜑��x%
			SPDelayFix := SPDelayFix + 100 - td.SP2;
		end;
  end;
end;
//------------------------------------------------------------------------------
procedure CalcEquip(tc:TChara);
var
	i,j,k,o :integer;
	Side    :byte;
begin
	with tc do begin
		for i := 1 to 100 do begin
			if Item[i].ID <> 0 then begin
				Weight := Weight + Item[i].Data.Weight * Item[i].Amount;
//				if Item[i].Data.IEquip and (Item[i].Equip <> 0) then begin
				if Item[i].Equip <> 0 then begin
					Side := 0;
					o := 0;
					if Item[i].Data.IType = 4 then begin //����
						if Item[i].Equip = $20 then Side := 1;
						ATK[Side][1] := Item[i].Data.ATK;
						WeaponType[Side] := Item[i].Data.View;
						if Item[i].Refine > 0 then begin
							case Item[i].Data.wLV of
							1:		j := 2;
							2:		j := 3;
							3:		j := 5;
							4:		j := 7; //Comodo Patch�ȍ~��7�A����ȑO��5
							else	j := 0;
							end;
							ATK[Side][3] := Item[i].Refine * j;
							Inc(ATK[1][0], Item[i].Refine * j);
						end;
						if Side = 0 then Range := Range + Item[i].Data.Range;
						WElement[Side] := Item[i].Data.Element;
					end else if Item[i].Data.IType = 5 then begin
						if (Item[i].Equip and 256) <> 0 then begin //����i
							Head1 := Item[i].Data.View;
						end else if (Item[i].Equip and 512) <> 0 then begin //�����i
							Head2 := Item[i].Data.View;
						end else if (Item[i].Equip and 1) <> 0 then begin //�����i
							Head3 := Item[i].Data.View;
						end else if (Item[i].Equip and 32) <> 0 then begin //��
							Shield := Item[i].Data.View;
						end;
						if Item[i].Refine > 0 then begin
							DEF1 := DEF1 + Item[i].Refine;
						end;
						o := 1;
					end else if (Item[i].Data.IType = 10) and (Weapon = 11) then begin //��
						Arrow := i;
						WElement[1] := Item[i].Data.Element;
						ATK[1][2] := Item[i].Data.ATK;
					end;
					CalcAbility(tc, Item[i].Data, o);
{�A�C�e�������C��}
					for k := 0 to Item[i].Data.Slot - 1 do begin //�J�[�h�␳1
						//��������̊֌W�ŃJ�[�h�X���b�g��DB�ɂȂ����������邽��(4001-4149)�̎������J�[�h��������悤�ɏC��
						if (Item[i].Card[k] <> 0) and (Item[i].Card[k] > 4000) and (Item[i].Card[k] < 4211) then begin
							CalcAbility(tc, (ItemDB.IndexOfObject(Item[i].Card[k]) as TItemDB), o);
						end;
					end;
					//��������̑����A���̂�����̔���
					if (Item[i].Card[0] = $00FF) and (Item[i].Card[1] <> 0) then begin
						//�J�[�h�X���b�g1�ɓ����ꂽ������$0500�Ŋ������]�肪���̕���̑����ƂȂ�
						WElement[Side] := Item[i].Card[1] mod $0500;
						//�J�[�h�X���b�g1�ɓ����ꂽ������$0500�Ŋ������������̕���ɖ��߂�ꂽ���̂�����̐��ƂȂ�
						//Item[i].Card[1] div $0500;
					end;
{�A�C�e�������ǉ��R�R�܂�}
				end;
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure CalcSkill(tc:TChara; Tick:cardinal);
var
	i,j :Integer;
begin
	with tc do begin
		//�C�� ATK[0][4]
		if (Skill[2].Lv <> 0) and ((WeaponType[0] = 1) or (WeaponType[0] = 2)) then begin //�Z���A��
			ATK[0][4] := Skill[2].Data.Data1[Skill[2].Lv];
		end else if (Skill[3].Lv <> 0) and (WeaponType[0] = 3) then begin //���茕
			ATK[0][4] := Skill[3].Data.Data1[Skill[3].Lv];
		end else if (Skill[55].Lv <> 0) and ((WeaponType[0] = 4) or (WeaponType[0] = 5)) then begin //��
			if (Option and 32) = 0 then begin
				ATK[0][4] := Skill[55].Data.Data1[Skill[55].Lv];
			end else begin
				ATK[0][4] := Skill[55].Data.Data2[Skill[55].Lv];
			end;
		end else if (Skill[65].Lv <> 0) and (WeaponType[0] = 8) then begin //���C�X
			ATK[0][4] := Skill[65].Data.Data1[Skill[65].Lv];
		end else if (Skill[134].Lv <> 0) and (WeaponType[0] = 16) then begin //�J�^�[��
			ATK[0][4] := Skill[134].Data.Data1[Skill[134].Lv];
                end else if (Skill[226].Lv <> 0) and (WeaponType[0] = 6) then begin //Axe Mastery
			ATK[0][4] := Skill[226].Data.Data1[Skill[226].Lv];
                end else if (Skill[259].Lv <> 0) and (WeaponType[0] = 12) then begin //Iron Hand
                        ATK[0][4] := Skill[259].Data.Data1[Skill[259].Lv]
                end else if (Skill[315].Lv <> 0) and (WeaponType[0] = 13) then begin //Musical Lesson
                        ATK[0][4] := Skill[315].Data.Data1[Skill[315].Lv];
                end else if (Skill[323].Lv <> 0) and (WeaponType[0] = 14) then begin //Musical Lesson
                        ATK[0][4] := Skill[323].Data.Data1[Skill[323].Lv];
		end;
		//�f�B���@�C���v���e�N�V����
		if Skill[22].Lv <> 0 then begin
			DEF3 := Skill[22].Data.Data1[Skill[22].Lv];
		end else begin
			DEF3 := 0;
		end;
		//�f�[�����x�C�� ATK[0][5]
		if Skill[23].Lv <> 0 then ATK[0][5] := Skill[23].Data.Data1[Skill[23].Lv];
		//���x����(AGI+)
		if Skill[29].Tick > Tick then begin
			Bonus[1] := Bonus[1] + 2 + Skill[29].EffectLV;
		end;
		//���x����(AGI-)
		if Skill[30].Tick > Tick then begin
		    if (byte(Skill[30].Effect1) > Bonus[1]) then begin
		        Bonus[1] := 0;
		    end else begin
			Bonus[1] := Bonus[1] - byte(Skill[30].Effect1);
		    end;
		end;
                if Skill[33].Tick > Tick then begin
                       i := 10 + (5 * tc.Skill[33].EffectLV);
                       tc.DEF2 := tc.DEF2 + (tc.Param[2] * i div 100);
                end;
		//�u���X(STR,INT,DEX+)
		if Skill[34].Tick > Tick then begin
			Bonus[0] := Bonus[0] + Skill[34].EffectLV;
			Bonus[3] := Bonus[3] + Skill[34].EffectLV;
			Bonus[4] := Bonus[4] + Skill[34].EffectLV;
		end;
		//�������E�ʑ����X�L��
		if Skill[36].Lv <> 0 then begin
			MaxWeight := MaxWeight + cardinal(Skill[36].Data.Data1[Skill[36].Lv]) * 10;
		end;
		//�ӂ��낤�̖ڃX�L��(DEX+)
		if Skill[43].Lv <> 0 then begin
			Bonus[4] := Bonus[4] + Skill[43].Lv;
		end;
		//���V�̖ڃX�L��(�˒��A������+)
		if Skill[44].Lv <> 0 then begin
			if Weapon = 11 then
				Range := Range + Skill[44].Lv;
			HIT := HIT + Skill[44].Lv;
		end;
		//�_�u���A�^�b�N
		if (Skill[48].Lv <> 0) and (WeaponType[0] = 1) then begin
			DAPer := Skill[48].Data.Data1[Skill[48].Lv];
			DAFix := Skill[48].Data.Data2[Skill[48].Lv];
                end else if (Skill[263].Lv <> 0) and ((WeaponType[0] = 12) or (WeaponType[0] = 0)) then begin
			DAPer := Skill[263].Data.Data1[Skill[263].Lv];
			DAFix := Skill[263].Data.Data2[Skill[263].Lv];
		end else if (WeaponType[0] <> 0) and Skill[48].Card then begin   //�{���̎d�l�H
			DAPer := Skill[48].Data.Data1[Skill[48].Lv];
			DAFix := Skill[48].Data.Data2[Skill[48].Lv];
		end else begin
			DAPer := 0;
			DAFix := 100;
		end;
		//��𗦑����X�L��
		if Skill[49].Lv <> 0 then begin
			FLEE2 := Skill[49].Data.Data1[Skill[49].Lv];
		end else begin
			FLEE2 := 0;
		end;

                // Colus, 20031212: Changed Monk's flee skill bonus to be like Thief's
                // Darkhelmet 12/21/03 Colus's Fix was breaking thief Skill
                if Skill[265].Lv <> 0 then begin //Dodge
                        FLEE3 := Skill[265].Data.Data1[Skill[265].Lv];
                end else begin
			FLEE3 := 0;
                end;


		//�O�����A(LUK+)
		if Skill[75].Tick > Tick then begin
			Bonus[5] := Bonus[5] + 30;
		end;

                if Skill[110].Tick > Tick then begin
                     {if (Skill[110].Lv = 1) and (Skill[110].Tick / 1000 = 1) then tc.SP := tc.SP - 1;
                     if (Skill[110].Lv = 2) and (Skill[110].Tick / 2000 = 1) then tc.SP := tc.SP - 1;
                     if (Skill[110].Lv = 3) and (Skill[110].Tick / 3000 = 1) then tc.SP := tc.SP - 1;
                     if (Skill[110].Lv = 4) and (Skill[110].Tick / 4000 = 1) then tc.SP := tc.SP - 1;
                     if (Skill[110].Lv = 5) and (Skill[110].Tick / 5000 = 1) then tc.SP := tc.SP - 1;
                     tc.ATK[0][0] := tc.ATK[0][3];
                     tc.ATK[0][1] := tc.ATK[0][3];
                     tc.ATK[0][2] := tc.ATK[0][3];
                     tc.ATK[1][0] := tc.ATK[0][3];
                     tc.ATK[1][1] := tc.ATK[0][3];
                     tc.ATK[1][2] := tc.ATK[0][3];}
                end;
		//�吺�̏�(STR+)
		if Skill[155].Tick > Tick then begin
			Bonus[0] := Bonus[0] + 5;
		end;
		//�A�X�y���V�I
		if Skill[68].Tick > Tick then begin
			WElement[0] := 6;
			WElement[1] := 6;
		end;
{�ǉ�:119}
		//Enchance Poison - Bellium (Crimson)
		if Skill[138].Tick > Tick then begin
			WElement[0] := 5;
			WElement[1] := 5;
		end;
                if ((tc.Option = 6) and (tc.Skill[213].Lv <> 0)) then begin
                        Speed := (Skill[213].Data.Data2[Skill[213].Lv] * Speed) div 100;
                        ASpeed := Round(ASpeed * (Skill[213].Data.Data2[Skill[213].Lv] / 100));
                end;

                if Skill[268].Tick > Tick then begin //Steel Body
                        // Colus 20031223: Not +90, = 90.
                        tc.DEF1 := 90; //tc.DEF1 + 90;
                        tc.MDEF1 := 90; //tc.MDEF1 +90;
                end;
                if Skill[269].Tick > Tick then begin
                        tc.Option := 6;
                end;
                if Skill[280].Tick > Tick then begin
			WElement[0] := 3;
			WElement[1] := 3;
		end;
                if Skill[281].Tick > Tick then begin
			WElement[0] := 1;
			WElement[1] := 1;
		end;
                if Skill[282].Tick > Tick then begin
			WElement[0] := 4;
			WElement[1] := 4;
		end;
                if Skill[283].Tick > Tick then begin
			WElement[0] := 2;
			WElement[1] := 2;
		end;

	end;
end;



//------------------------------------------------------------------------------


procedure CalcStat(tc:TChara; Tick:cardinal = 0);
var
	i,j,k,o,p :integer;
	Side      :byte;
	td        :TItemDB;
        tl        :TSkillDB;
        mi        :MapTbl;
        g         :double;

begin
	if Tick = 0 then Tick := timeGetTime();
	with tc do begin
                {g := int (Tick / 3600000);
                 // Darkhelmet Auto Day/Night
                if (Tick / 3600000) <= 110 then begin
                        tc.noDay := true;
                end;}

                SPRedAmount := 0;
		Weight := 0;
		Range := 0;
		WeaponType[0] := 0;
		WeaponType[1] := 0;
		Arrow := 0;
		Head1 := 0;
		Head2 := 0;
		Head3 := 0;
		Shield := 0;
		for i := 0 to 1 do
                        for j := 0 to 5 do
                                ATK[i][j] := 0;
                DEF1 := 0;
                MDEF1 := 0;
                for i := 0 to 5 do begin //�{�[�i�X�l�̏�����
                        Bonus[i] := 0;
                        for j := 1 to JobLV do begin
                                if JobBonusTable[JID][j] = i + 1 then Inc(Bonus[i]);
			end;
		end;

		//������
		//ArrowElement := 0;
		MAXHP := 0;
		MAXSP := 0;
		MAXHPPer := 100;
		MAXSPPer := 100;
		for i := 0 to 3 do begin
			HPDelayFix := 0;
			SPDelayFix := 0;
		end;
		ATTPOWER := 0;
		MATK1 := 0;
		MATK2 := 0;
		MATKFix := 0;
{Colus, 20031217: Initting MCastTimeFix to fix cast timer calc}
    MCastTimeFix := 100;
{Colus, 20031217: End MCastTimeFix init}
		HIT := 0;
		Lucky := 1;
		Critical := 1;
                FLEE1 := 1;
                FLEE2 := 0;
		MaxWeight := 20000;
		DEF1 := 0;
		for i:=0 to 1 do begin
			WElement[i] := 0;
			DrainFix[i] := 0;
			DrainPer[i] := 0;
		end;
		for i:=0 to 9 do begin
			DamageFixR[0][i] := 100;
			DamageFixR[1][i] := 0;
			DamageFixE[0][i] := 100;
			DamageFixE[1][i] := 0;
		end;
		DamageFixS[0] := 100;
		DamageFixS[1] := 100;
		DamageFixS[2] := 100;
                FastWalk := false;
		SplashAttack := false;
                NoJamstone := false;
                NoCastInterrupt := false;
                FullRecover := false;
                UnlimitedEndure := false;
                NoTarget := false;
                OrcReflect := false;
                AnolianReflect := false;
                DoppelgagnerASPD := false;
                LessSP := false;
                MagicReflect := false;
                GhostArmor := false;
                SkillWeapon := false;
                GungnirEquipped := false;
                LVL4WeaponASPD := false;
                PerfectDamage := false;
		for i:=0 to 4 do begin
			SFixPer1[0][i] := 0;
			SFixPer1[1][i] := 0;
			SFixPer2[0][i] := 0;
			SFixPer2[1][i] := 0;
		end;

		if not DisableSkillLimit then begin //�X�L���c���[�̍č\�z
			for i := 1 to 336 do begin
				if not Skill[i].Data.Job[JID] then begin
					if not Skill[i].Card then begin
						//SkillPoint := SkillPoint + Skill[i].Lv;
					end;
					Skill[i].Lv := 0;
				end;
				Skill[i].Card := False;
			end;
			if SkillPoint > 714 then SkillPoint := 714; //���ꂾ���L��Ώ\��
		end;
		CalcEquip(tc);
		CalcSkill(tc,Tick);
		for i := 0 to 5 do begin
			ParamUp[i] := ((ParamBase[i] - 1) div 10) + 2;
			Param[i] := ParamBase[i] + Bonus[i];
		end;

		if Skill[45].Tick > Tick then begin
			Bonus[1] := Bonus[1] + Param[1] * (2 + Skill[45].EffectLV) div 100;
			Param[1] := Param[1] * (102 + Skill[45].Lv) div 100;
			Bonus[4] := Bonus[4] + Param[4] * (2 + Skill[45].EffectLV) div 100;
			Param[4] := Param[4] * (102 + Skill[45].Lv) div 100;
		end;
    if ((MAXHP + (35 + BaseLV * 5 + ((1 + BaseLV) * BaseLV div 2) * HPTable[JID] div 100) * (100 + Param[2]) div 100) > 65535) then begin
        MAXHP := 65535;
    end else if (JID = 23) and (MAXHP + (35 + BaseLV * 5 + ((1 + BaseLV) * BaseLV div 2) * 40 div 100) * (100 + Param[2]) div 100 > 65535) then begin
        MAXHP := 65535;
    end else begin

		tc.MAXHP := tc.MAXHP + (35 + tc.BaseLV * 5 + ((1 + tc.BaseLV) * tc.BaseLV div 2) * HPTable[JID] div 100) * (100 + tc.Param[2]) div 100;
                if tc.JID = 23 then tc.MAXHP := tc.MAXHP + (35 + tc.BaseLV * 5 + ((1 + tc.BaseLV) * tc.BaseLV div 2) * 40 div 100) * (100 + tc.Param[2]) div 100;

    end;
    if (Skill[248].Lv <> 0) then begin
    tl := Skill[248].Data;
    if (MAXHP + tl.Data1[Skill[248].Lv] > 65535) then begin
        MAXHP := 65535;
    end else begin
        MAXHP := MAXHP + tl.Data1[Skill[248].Lv];
    end;
    end;

		MAXSP := MAXSP + BaseLV * SPTable[JID] * (100 + Param[3]) div 100;
                if JID = 23 then MAXSP := MAXSP + BaseLV * 2 * (100 + Param[3]) div 100;
		MATK1 := Param[3] + (Param[3] div 7) * (Param[3] div 7);
		MATK2 := Param[3] + (Param[3] div 5) * (Param[3] div 5);
		MATKFix := MATKFix + 100; //��Ȃǂɂ��MATK�␳
		HIT := HIT + BaseLV + Param[4];
		Lucky := Lucky + (Param[5] div 10);
		Critical := Critical + 1 + (Param[5] div 3);

		MaxWeight := MaxWeight + (Param[0]+Bonus[0]) * 300 + WeightTable[JID];

		DEF2 := Param[2];
		MDEF2 := Param[3];
		FLEE1 := FLEE1 + Param[1] + BaseLV + FLEE2 + FLEE3;


                if Skill[270].Tick > Tick then begin //Explosion Spirits
                        tc.Critical := word(tc.Critical + (tc.Critical * tc.Skill[270].Effect1 div 1000) + 1);
                end;

		if WeaponType[1] = 0 then begin
			Weapon := WeaponType[0];
			ArmsFix[0] := 100;
			ArmsFix[1] := 100;
		end else begin
			case WeaponType[0] * $100 + WeaponType[1] of
			$0001: Weapon :=	1; //R�f-L�Z
			$0002: Weapon :=	2; //R�f-L��
			$0006: Weapon :=	6; //R�f-L��
			$0101: Weapon := 17; //R�Z-L�Z
			$0202: Weapon := 18; //R��-L��
			$0606: Weapon := 19; //R��-L��
			$0102: Weapon := 20; //R�Z-L��
			$0201: Weapon := 20; //R��-L�Z
			$0106: Weapon := 21; //R�Z-L��
			$0601: Weapon := 21; //R��-L�Z
			$0206: Weapon := 22; //R��-L��
			$0602: Weapon := 22; //R��-L��
			end;
			if Skill[132].Lv = 0 then //�E��_�C��
				ArmsFix[0] := Skill[132].Data.Data2[1]
			else
				ArmsFix[0] := Skill[132].Data.Data1[Skill[132].Lv];
			if Skill[133].Lv = 0 then //����_�C��
				ArmsFix[1] := Skill[133].Data.Data2[1]
			else
				ArmsFix[1] := Skill[133].Data.Data1[Skill[133].Lv];
		end;

		if Weapon = 11 then begin
			//030318
			ATK[0][0] := ATK[0][0] + Param[4]; //�X�e�[�^�X�ɕ\������鐔���B�|�̎���DEX+����ATK
			//�|�̊�{�U����
			ATK[0][2] := Param[4] + (Param[4] div 10) * (Param[4] div 10) + (Param[0] div 5) + (Param[5] div 5) + ATTPOWER;
		end else begin
			//030317 by Beg.Thread 120
			ATK[0][0] := ATK[0][0] + Param[0]; //�X�e�[�^�X�ɕ\������鐔���B�f���STR�A�����STR+����ATK
			//�|�ȊO�̊�{�U����
			ATK[0][2] := Param[0] + (Param[0] div 10) * (Param[0] div 10) + (Param[4] div 5) + (Param[5] div 5) + ATTPOWER;
			ATK[1][2] := Param[0] + (Param[0] div 10) * (Param[0] div 10) + (Param[4] div 5) + (Param[5] div 5) + ATTPOWER;
		end;


		if Skill[66].Tick > Tick then begin
			ATK[0][3] := ATK[0][3] + 5 * Skill[66].EffectLV;
			ATK[1][3] := ATK[1][3] + 5 * Skill[66].EffectLV;
		end;


		if WeaponType[1] = 0 then begin
			ADelay := 20*WeaponASPDTable[JID][Weapon];
                        if (JID = 23) then ADelay := 20*WeaponASPDTable[0][WeaponType[1]];
		end else if WeaponType[0] = 0 then begin
			ADelay := 20*WeaponASPDTable[JID][WeaponType[1]];
                        if (JID = 23) then ADelay := 20*WeaponASPDTable[0][WeaponType[1]];
		end else begin //�񓁗�
			ADelay := 14*(WeaponASPDTable[JID][WeaponType[0]] + WeaponASPDTable[JID][WeaponType[1]]);
                        if (JID = 23) then ADelay := 14*(WeaponASPDTable[0][WeaponType[0]] + WeaponASPDTable[0][WeaponType[1]]);
		end;
		i := ( ( ADelay * Param[1] div 500 ) * 2 + ADelay * Param[4] div 1000 );
		if ADelay < i then ADelay := 200
		else begin
			ADelay := ADelay - i;
                        {if (JID = 23) then begin  //Super Novice ASPD
                                case tc.Weapon of
                                        1:  ADelay := ADelay * 60 div 100;
                                        2:  ADelay := ADelay * 50 div 100;
                                        6:  ADelay := ADelay * 35 div 100;
                                        8:  ADelay := ADelay * 40 div 100;
                                        10: ADelay := ADelay * 40 div 100;
                                end;
                        end;}

			if (Skill[60].Tick > Tick) and (tc.Weapon = 3) then ADelay := ADelay * 70 div 100; //�c�[�n���h�N�C�b�N��
			if (Skill[111].Tick > Tick) and ((tc.Weapon = 6) or (tc.Weapon = 7) or (tc.Weapon = 8))then ADelay := ADelay * 70 div 100; //Adrenaline Rush
{Editted By AppleGirl}  if (Skill[258].Tick > Tick) and ((tc.Weapon = 4) or (tc.Weapon = 5)) then ADelay := ADelay * 70 div 100; //�c�[�n���h�N�C�b�N��
                        if Skill[268].Tick > Tick then ADelay := ADelay * 2;    {Steel Body}
                        if Skill[291].Tick > Tick then ADelay := ADelay * tc.Skill[291].Effect1 div 100;  {Attack Speed Potions}
                        if Skill[320].Tick > Tick then ADelay := ADelay * tc.Skill[291].Effect1 div 100;
                        if tc.DoppelgagnerASPD then ADelay := ADelay * 70 div 100;  {Doppelgagner Card}
                        if tc.LVL4WeaponASPD then ADelay := ADelay * 75 div 100;     {Level 4 kro new weapon aspd haste effect}
			if ADelay < 200 then ADelay := 200;
		end;
		ASpeed := ADelay div 2;

                if (Skill[60].Tick > Tick) and (tc.Weapon <> 3) then Skill[60].Tick := Tick;
                if (Skill[111].Tick > Tick) and (tc.Weapon <> (6 or 7)) then Skill[111].Tick := Tick;
                if (Skill[258].Tick > Tick) and (tc.Weapon <> (4 or 5)) then Skill[258].Tick := Tick;


        if ((Option and 32) <> 0) then begin
        // AlexKreuz: Skill[64].Lv = 0 caused Crash: Needs else begin.
                if Skill[64].Lv > 0 then begin
                        ASpeed := Round(ASpeed * (Skill[64].Data.Data1[Skill[64].Lv] / 100));
                end else begin
                        ASpeed := Round(ASpeed * (50/100));
                end;
        end;

		if Param[4] <= 150 then begin
{Colus, 20031217: MCastTimeFix correction to involve cards}
 			MCastTimeFix := (100 - (Param[4] * 100) div 150) * MCastTimeFix div 100;
{Colus, 20031217: End MCastTimeFix correction}
		end else begin
			MCastTimeFix := 0;
		end;
		//�T�C�Y�␳
		for i := 0 to 1 do begin
			for j := 0 to 2 do begin
                                ATKFix[i][j] := WeaponTypeTable[j][WeaponType[i]];
			end;
		end;

		//�؂��R��&������=���^�ɂ�100%�_���[�W
		if ((Option and 32) <> 0) and ((WeaponType[0] = 4) or (WeaponType[0] = 5)) then begin
			ATKFix[0][1] := 100;
		end;

		{Weapon Perfection}
		if (Skill[112].Tick > Tick) or (PerfectDamage) then begin
			for i := 0 to 1 do begin
				for j := 0 to 2 do begin
					ATKFix[i][j] := 100;
				end;
			end;
		end;
		//�I�[�o�[�g���X�g(ATK+)
		if Skill[113].Tick > Tick then begin
			//�蔲��
			for i := 0 to 1 do begin
				for j := 0 to 2 do begin
					ATKFix[i][j] := ATKFix[i][j] * (100 + 5 * Skill[113].Lv) div 100;
				end;
			end;
		end;
{:code}
		//�ړ����x
		i := tc.DefaultSpeed;
		if ((Option and 32) <> 0) and (Skill[63].Lv > 0) then begin
                        i := i - 40;
                end;

                if FastWalk then i := i - 30;

    if (((Option and $0008) <> 0) or ((Option and $0080) <> 0)
		or ((Option and $0100) <> 0) or ((Option and $0200) <> 0)
		or ((Option and $0400) <> 0) )and((JID = 10)or(JID = 5)) then begin //�J�[�g
    if Skill[39].Lv = 0 then begin
    i := i + Skill[39].Data.Data1[1];
    end else begin
    i := i + Skill[39].Data.Data1[Skill[39].Lv];
    end;
		end;

		if Skill[29].Tick > Tick then begin //���x����
			if Skill[29].EffectLV > 5 then
				i := i - 45
			else
				i := i - 30;
		end;
		if Skill[30].Tick > Tick then begin //���x����
			if Skill[30].EffectLV > 5 then
				i := i + 45
			else
				i := i + 30;
		end;

                if Skill[257].Tick > Tick then begin
                        i := i + 30;
                end;
                 {//Tunnel Drive
                if ((tc.Option = 6) and (tc.Skill[213].Lv <> 0)) then begin
                        i := Skill[213].Data.Data1[MUseLV] * i div 100;
                end;}
		if i < 25 then i := 25;
		Speed := i;
    //if (Skill[39].Lv <> 0) and (Option = 8) then begin
      //tl := Skill[39].Data;
      //Speed := Round(Speed * (tl.Data2[Skill[39].Lv] / 100));
    //end;
		//030323
		aMotion := ADelay div 2;
		if (Skill[8].Tick > Tick) or (UnlimitedEndure = true) then begin //�C���f���A
			dMotion := 0;
		end else if Param[1] > 100 then begin
			dMotion := 400;
		end else begin
			dMotion := 800 - Param[1] * 4;
		end;
		//030316-2 unknown-user
{�C��}
		//030316-2 Cardinal
		if Param[3] > 123 then begin
			SPDelay[0] := 150;
		end else begin
			SPDelay[0] := 7560 - (60 * Param[3]);
		end;
		if (BaseLV + Param[2]) > 203 then begin
			HPDelay[0] := 150;
		end else begin
			HPDelay[0] := 3000 - (14 * (BaseLV + Param[2])); //�b��
		end;
		//---
{:code}
		if Skill[74].Tick > Tick then begin //�}�O�j
			HPDelay[0] := HPDelay[0] div 2;
			SPDelay[0] := SPDelay[0] div 2;
		end;
{:code}
		HPDelay[1] := HPDelay[0] div 2; //����
		HPDelay[2] := 7200000;          //���S
		//030316 Cardinal
{:119}
		if (Skill[144].Lv <> 0) then HPDelay[3] := HPDelay[0] * 4 //�ړ���_HP_��
		else HPDelay[3] := 7200000; //�ړ�
{:119}
		//---
		SPDelay[1] := SPDelay[0] div 2;
		SPDelay[2] := 7200000;
		SPDelay[3] := SPDelay[0] * 2;
		j := 100 - HPDelayFix;
		if j < 0 then j := 0;
		k := 100 - SPDelayFix;
		if k < 0 then k := 0;
		for i:=0 to 3 do begin
			HPDelay[i] := HPDelay[i] * Cardinal(j) div 100;
			if HPDelay[i] < 150 then HPDelay[i] := 150;
			SPDelay[i] := SPDelay[i] * Cardinal(k) div 100;
			if SPDelay[i] < 150 then SPDelay[i] := 150;
		end;

		BaseNextEXP := ExpTable[0][BaseLV];
		if      JID = 0 then i := 1
		else if JID < 7 then i := 2
		else                 i := 3;
		JobNextEXP := ExpTable[i][JobLV];



		//if Weapon = 11 then Element := ArrowElement;
		//DebugOut.Lines.Add(Format('WElement: %d/%d', [WElement[0], WElement[1]]));
		if Weapon = 16 then Critical := Critical * 2;
		Inc(Range);
    if ((MAXHP * MAXHPPer div 100) > 65535) then begin
    MAXHP := 65535;
    end else begin
		MAXHP := MAXHP * MAXHPPer div 100;
    end;
    if ((MAXSP * MAXSPPer div 100) > 65535) then begin
    MAXSP := 65535;
    end else begin
		MAXSP := MAXSP * MAXSPPer div 100;
    end;
		if HP > MAXHP then HP := MAXHP;
		if SP > MAXSP then SP := MAXSP;
		if Critical > 100 then Critical := 100;
		if Lucky > 100 then Lucky := 100;
	end;
{�J�[�g�@�\}
	tc.Cart.MaxWeight := 80000;
	CalcInventory(tc.Cart);
{�J�[�g�@�\�R�R�܂�}
end;


//------------------------------------------------------------------------------
procedure CalcSongStat(tc:TChara; Tick:cardinal = 0);
var
	i,j,k,o,p :integer;
	Side      :byte;
	td        :TItemDB;
        tl        :TSkillDB;
        mi        :MapTbl;
        g         :double;

begin
	if Tick = 0 then Tick := timeGetTime();
	with tc do begin

                SPRedAmount := 0;

                NoJamstone := false;
                NoTrap := false;

                {Initialize to 0}
                DEF1 := 0;
                FLEE1 := 1;

                MAXHP := 0;
                MAXSP := 0;

                for i := 0 to 1 do
                        for j := 0 to 5 do
                                ATK[i][j] := 0;
                for i := 0 to 5 do begin        {Bonus Calculation}
                        Bonus[i] := 0;
                        for j := 1 to JobLV do begin
                                if JobBonusTable[JID][j] = i + 1 then Inc(Bonus[i]);
			end;
		end;

                {Calculate Needed Skills}
                DEF2 := Param[2];

                MAXSP := MAXSP + BaseLV * SPTable[JID] * (100 + Param[3]) div 100;

                if ((MAXSP * MAXSPPer div 100) > 65535) then begin
                        MAXSP := 65535;
                end else begin
	        	MAXSP := MAXSP * MAXSPPer div 100;
                end;

                if ((MAXHP + (35 + BaseLV * 5 + ((1 + BaseLV) * BaseLV div 2) * HPTable[JID] div 100) * (100 + Param[2]) div 100) > 65535) then begin
                        MAXHP := 65535;
                end else begin
		        tc.MAXHP := tc.MAXHP + (35 + tc.BaseLV * 5 + ((1 + tc.BaseLV) * tc.BaseLV div 2) * HPTable[JID] div 100) * (100 + tc.Param[2]) div 100;
                end;

                if (Skill[248].Lv <> 0) then begin
                        tl := Skill[248].Data;
                        if (MAXHP + tl.Data1[Skill[248].Lv] > 65535) then begin
                                MAXHP := 65535;
                        end else begin
                                MAXHP := MAXHP + tl.Data1[Skill[248].Lv];
                        end;
                end;

                if Skill[322].Tick > Tick then begin
                        tl := Skill[322].Data;
                        if (MAXHP + tc.Skill[322].Effect1 > 65535) then begin
                                MAXHP := 65535;
                        end else begin
                                MAXHP := MAXHP + tc.Skill[322].Effect1;
                        end;
                end;

                if Weapon = 11 then begin
			ATK[0][0] := ATK[0][0] + Param[4]; //�X�e�[�^�X�ɕ\������鐔���B�|�̎���DEX+����ATK
			ATK[0][2] := Param[4] + (Param[4] div 10) * (Param[4] div 10) + (Param[0] div 5) + (Param[5] div 5) + ATTPOWER;
		end else begin
			ATK[0][0] := ATK[0][0] + Param[0]; //�X�e�[�^�X�ɕ\������鐔���B�f���STR�A�����STR+����ATK
			ATK[0][2] := Param[0] + (Param[0] div 10) * (Param[0] div 10) + (Param[4] div 5) + (Param[5] div 5) + ATTPOWER;
			ATK[1][2] := Param[0] + (Param[0] div 10) * (Param[0] div 10) + (Param[4] div 5) + (Param[5] div 5) + ATTPOWER;
		end;

                for i := 0 to 5 do begin
			ParamUp[i] := ((ParamBase[i] - 1) div 10) + 2;
			Param[i] := ParamBase[i] + Bonus[i];
		end;

		if Skill[45].Tick > Tick then begin
			Bonus[1] := Bonus[1] + Param[1] * (2 + Skill[45].EffectLV) div 100;
			Param[1] := Param[1] * (102 + Skill[45].Lv) div 100;
			Bonus[4] := Bonus[4] + Param[4] * (2 + Skill[45].EffectLV) div 100;
			Param[4] := Param[4] * (102 + Skill[45].Lv) div 100;
		end;

                FLEE1 := FLEE1 + Param[1] + BaseLV + FLEE2 + FLEE3;

                if Skill[66].Tick > Tick then begin
			ATK[0][3] := ATK[0][3] + 5 * Skill[66].EffectLV;
			ATK[1][3] := ATK[1][3] + 5 * Skill[66].EffectLV;
		end;

                if ((MAXHP * MAXHPPer div 100) > 65535) then begin
                        MAXHP := 65535;
                end else begin
		        MAXHP := MAXHP * MAXHPPer div 100;
                end;

                NoJamStone := false;
                NoTrap := false;
        end;

end;

//------------------------------------------------------------------------------
procedure CalcSongSkill(tc:TChara; Tick:cardinal = 0);

begin

   with tc do begin

        {Drum Battle Field}
        if (tc.Skill[309].Tick > Tick) and (tc.InField) then begin
                ATK[0][4] := ATK[0][4] * tc.Skill[309].Effect1 div 100;
                tc.DEF2 := tc.DEF2 + ((tc.DEF1 + tc.DEF2 + tc.DEF3) * Skill[309].Data.Data2[tc.Skill[309].EffectLV + 5] div 100);
        end;

        {Into The Abyss}
        if (tc.Skill[312].Tick > Tick) and (Infield) then begin
                tc.NoJamstone := true;
                tc.NoTrap := true;
        end;

        {Whistling}
        if (tc.Skill[319].Tick > Tick) and (tc.InField) then begin
                tc.FLEE1 := tc.FLEE1 + (tc.FLEE1 * tc.Skill[319].Effect1 div 100);
                tc.Bonus[5] := tc.Bonus[5] + (tc.Param[5] * tc.Skill[319].Effect1 div 100);
        end;

        {Service For You}
        if (tc.Skill[330].Tick > Tick) and (tc.InField) then begin
                tc.MAXSP := tc.MAXSP + (tc.MAXSP * (tc.Skill[330].EffectLV + 10) div 100);
                tc.SPRedAmount := tc.SPRedAmount +( tc.SPRedAmount * tc.Skill[330].Effect1);
        end;

        tc.InField := false;
   end;

end;
//------------------------------------------------------------------------------

procedure CalcSageSkill(tc:TChara; Tick:cardinal = 0);
begin
        with tc do begin

                if (tc.Skill[285].Tick > Tick) and (tc.InField) and (tc.WElement[0] = 3)  then begin
                        ATK[0][4] := ATK[0][4] + Skill[285].Data.Data2[Skill[285].EffectLV];
                        tc.SageElementEffect := true;
                end else if (tc.Skill[286].Tick > Tick) and (tc.InField) and (tc.WElement[0] = 1)  then begin
                        tc.MAXHP := tc.MAXHP + (tc.MAXHP * Skill[286].Data.Data2[Skill[286].EffectLV] div 100);
                        tc.SageElementEffect := true;
                end else if (tc.Skill[287].Tick > Tick) and (tc.InField) and (tc.WElement[0] = 4)  then begin
                        tc.FLEE1 := tc.FLEE1 + Skill[287].Data.Data2[Skill[287].EffectLV];
                        tc.SageElementEffect := true;
                end else begin
                        tc.SageElementEffect := false;
                        CalcStat(tc, Tick);
                end;

                tc.InField := false;
        end;
end;
//------------------------------------------------------------------------------
{Display Icons for passive Events}
{procedure PassiveIcons(tm:TMap; tc:TChara);
begin
  with tc do begin
        {Peco Peco}
        {if (tc.Skill[63].Lv <> 0) and (tc.Option = 32) then begin
                //DebugOut.Lines.Add('(߁��)?');
                WFIFOW(0, $0196);
                WFIFOW(2, tc.Skill[63].Data.Icon);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 1);
                SendBCmd(tm, tc.Point, 9);
        end else begin
                WFIFOW(0, $0196);
                WFIFOW(2, tc.Skill[63].Data.Icon);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 0);
                Socket.SendBuf(buf, 9);
        end;

        {Falcon Icon}
        {if (tc.Skill[127].Lv <> 0) and (tc.Option = 16) then begin
                //DebugOut.Lines.Add('(߁��)?');
                WFIFOW(0, $0196);
                WFIFOW(2, tc.Skill[127].Data.Icon);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 1);
                SendBCmd(tm, tc.Point, 9);
                //Socket.SendBuf(buf, 9);
        end else begin
                WFIFOW(0, $0196);
                WFIFOW(2, tc.Skill[127].Data.Icon);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 0);
                Socket.SendBuf(buf, 9);
        end;

        {Overweight 50%}
        {if tc.Weight * 2 >= tc.MaxWeight then begin
                //DebugOut.Lines.Add('(߁��)?');
                WFIFOW(0, $0196);
                WFIFOW(2, 35);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 1);
                SendBCmd(tm, tc.Point, 9);
                //Socket.SendBuf(buf, 9);
        end else begin
                WFIFOW(0, $0196);
                WFIFOW(2, 35);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 0);
                Socket.SendBuf(buf, 9);
        end;

        {Overweight 90%}
        {if Weight * 100 div MaxWeight >= 90 then begin
        //DebugOut.Lines.Add('(߁��)?');
                WFIFOW(0, $0196);
                WFIFOW(2, 36);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 1);
                SendBCmd(tm, tc.Point, 9);
                //Socket.SendBuf(buf, 9);
        end else begin
                WFIFOW(0, $0196);
                WFIFOW(2, 36);
                WFIFOL(4, tc.ID);
                WFIFOB(8, 0);
                Socket.SendBuf(buf, 9);
        end;
  end;
end;}
//------------------------------------------------------------------------------
procedure SendCStat(tc:TChara; View:boolean = false);
var
	i :integer;
begin
	//Speed
	WFIFOW(0, $00b0);
	WFIFOW(2, $0000);
	WFIFOL(4, tc.Speed);
	tc.Socket.SendBuf(buf, 8);

	//HPSP
	WFIFOW(0, $00b0);
	WFIFOW(2, $0005);
	WFIFOL(4, tc.HP);
	tc.Socket.SendBuf(buf, 8);
	WFIFOW(0, $00b0);
	WFIFOW(2, $0006);
	WFIFOL(4, tc.MAXHP);
	tc.Socket.SendBuf(buf, 8);
	WFIFOW(0, $00b0);
	WFIFOW(2, $0007);
	WFIFOL(4, tc.SP);
	tc.Socket.SendBuf(buf, 8);
	WFIFOW(0, $00b0);
	WFIFOW(2, $0008);
	WFIFOL(4, tc.MAXSP);
	tc.Socket.SendBuf(buf, 8);
	//�X�e�[�^�X
	WFIFOW( 0, $00bd);
	WFIFOW( 2, tc.StatusPoint);
	for i := 0 to 5 do begin
		WFIFOB(i*2+4, tc.ParamBase[i]);
		WFIFOB(i*2+5, tc.ParamUp[i]);
	end;
	WFIFOW(16, tc.ATK[0][0]);
	WFIFOW(18, tc.ATK[1][0]);
	WFIFOW(20, tc.MATK2);
	WFIFOW(22, tc.MATK1);
	WFIFOW(24, tc.DEF1);
	WFIFOW(26, tc.DEF2);
	WFIFOW(28, tc.MDEF1);
	WFIFOW(30, tc.MDEF2);
	WFIFOW(32, tc.HIT);
	WFIFOW(34, tc.FLEE1);
	WFIFOW(36, tc.Lucky);
	WFIFOW(38, tc.Critical);
	WFIFOW(40, tc.ASpeed);
	WFIFOW(42, 0);
	tc.Socket.SendBuf(buf, 44);
	//�x�[�X�o���l
	WFIFOW(0, $00b1);
	WFIFOW(2, $0001);
	WFIFOL(4, tc.BaseEXP);
	tc.Socket.SendBuf(buf, 8);
	WFIFOW(0, $00b1);
	WFIFOW(2, $0016);
	WFIFOL(4, tc.BaseNextEXP);
	tc.Socket.SendBuf(buf, 8);
	//�W���u�o���l
	WFIFOW(0, $00b1);
	WFIFOW(2, $0002);
	WFIFOL(4, tc.JobEXP);
	tc.Socket.SendBuf(buf, 8);
	WFIFOW(0, $00b1);
	WFIFOW(2, $0017);
	WFIFOL(4, tc.JobNextEXP);
	tc.Socket.SendBuf(buf, 8);
	//�������X�V
	WFIFOW(0, $00b1);
	WFIFOW(2, $0014);
	WFIFOL(4, tc.Zeny);
	tc.Socket.SendBuf(buf, 8);
	//�d��
	WFIFOW(0, $00b0);
	WFIFOW(2, $0018);
	WFIFOL(4, tc.Weight);
	tc.Socket.SendBuf(buf, 8);
	//�ő�d��
	WFIFOW(0, $00b0);
	WFIFOW(2, $0019);
	WFIFOL(4, tc.MaxWeight);
	tc.Socket.SendBuf(buf, 8);
	//�{�[�i�X
	for i := 0 to 5 do begin
		WFIFOW( 0, $0141);
		WFIFOL( 2, 13+i);
		WFIFOL( 6, tc.ParamBase[i]);
		WFIFOL(10, tc.Bonus[i]);
		tc.Socket.SendBuf(buf, 14);
	end;
	//�˒������Z�b�g
	WFIFOW(0, $013a);
	WFIFOW(2, tc.Range);
	tc.Socket.SendBuf(buf, 4);

//Tumy
if View then begin
      WFIFOW(0, $00c3);
      WFIFOL(2, tc.ID);
      //WFIFOB(6, 2);
      //WFIFOB(7, tc.Weapon);
      //tc.Socket.SendBuf(buf, 8); // patket change for view weapon
      WFIFOB(6, 3);
      WFIFOB(7, tc.Head3);
      tc.Socket.SendBuf(buf, 8);
      WFIFOB(6, 4);
      WFIFOB(7, tc.Head1);
      tc.Socket.SendBuf(buf, 8);
                                          WFIFOB(6, 5);
      WFIFOB(7, tc.Head2);
      tc.Socket.SendBuf(buf, 8);
                        WFIFOB(6, 8);
      WFIFOB(7, tc.Shield);
      tc.Socket.SendBuf(buf, 8); // patket change for view Shield
end;
// Tumy

end;
//------------------------------------------------------------------------------
procedure SendCStat1(tc:TChara; Mode:word; DType:word; Value:cardinal);
begin
	WFIFOW(0, $00b0 + Mode);
	WFIFOW(2, DType);
	WFIFOL(4, Value);
	tc.Socket.SendBuf(buf, 8);
{�p�[�e�B�[�@�\�ǉ�}
	//�X�e�[�^�X�̍X�V����HP�o�[�̏����X�V����
	if tc.PartyName <> '' then begin
		WFIFOW( 0, $0106);
		WFIFOL( 2, tc.ID);
		WFIFOW( 6, tc.HP);
		WFIFOW( 8, tc.MAXHP);
		SendPCmd(tc, 10, true, true);
	end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
end;
//------------------------------------------------------------------------------
procedure SendCData(tc1:TChara; tc:TChara; Use0079:boolean = false);
{�M���h�@�\�ǉ�}
var
	j   :integer;
	w   :word;
	tg  :TGuild;
{�M���h�@�\�ǉ��R�R�܂�}
begin
	ZeroMemory(@buf[0], 54);
	if Use0079 then begin
		WFIFOW(0, $0079);
	end else begin
		WFIFOW(0, $0078);
	end;
	WFIFOL( 2, tc.ID);
	WFIFOW( 6, tc.Speed);
{�ǉ�}
	WFIFOW( 8, tc.Stat1);
	WFIFOW(10, tc.Stat2);
{�ǉ��R�R�܂�}
	WFIFOW(12, tc.Option);
	WFIFOW(14, tc.JID);
	WFIFOW(16, tc.Hair);
	WFIFOW(18, tc.Weapon);
	WFIFOW(20, tc.Head3);
	WFIFOW(22, tc.Shield);
	WFIFOW(24, tc.Head1);
	WFIFOW(26, tc.Head2);
	WFIFOW(28, tc.HairColor);
	WFIFOW(30, tc.ClothesColor);
	WFIFOW(32, tc.HeadDir);
{�M���h�@�\�ǉ�}
	WFIFOL(34, tc.GuildID); //GuildID.L
	w := 0;
	if (tc.GuildID <> 0) then begin
		j := GuildList.IndexOf(tc.GuildID);
		if (j <> -1) then begin
			tg := GuildList.Objects[j] as TGuild;
			w := tg.Emblem;
		end;
	end;
	WFIFOL(38, w); //EmblemID.L
	WFIFOW(42, tc.Manner); //.W?
	WFIFOB(44, tc.Karma); //.B?
{�M���h�@�\�ǉ��R�R�܂�}
	WFIFOB(45, tc.Gender);
	WFIFOM1(46, tc.Point, tc.Dir);
	WFIFOB(49, 5);
	WFIFOB(50, 5);
{�C��}
	if Use0079 then begin
{�ǉ�}
		WFIFOW(51, tc.BaseLV);
{�ǉ��R�R�܂�}
		if tc.Socket <> nil then begin
                        if tc1.Login > 0 then begin
        			if tc.ver2 = 9 then tc1.Socket.SendBuf(buf, 53)	//Kr?
	        		else                tc1.Socket.SendBuf(buf, 51); //Jp
                        end;
		end;
	end else begin
		WFIFOB(51, tc.Sit);
{�ǉ�}
		WFIFOW(52, tc.BaseLV);
{�ǉ��R�R�܂�}
		if tc.Socket <> nil then begin
                        if tc1.Login > 0 then begin
        			if tc.ver2 = 9 then tc1.Socket.SendBuf(buf, 54)	//Kr?
	        		else                tc1.Socket.SendBuf(buf, 52); //Jp
                        end;
		end;
	end;
{�R�R�܂�}
{�p�[�e�B�[�@�\�ǉ�}
	if tc.PartyName <> '' then begin
	//�p�[�e�B�[�����o�[��HP�o�[��\��������
	WFIFOW( 0, $0106);
	WFIFOL( 2, tc.ID);
	WFIFOW( 6, tc.HP);
	WFIFOW( 8, tc.MAXHP);
	SendPCmd(tc, 10, true, true);

	//�p�[�e�B�[�����o�[�̈ʒu�\��
	WFIFOW( 0, $0107);
	WFIFOL( 2, tc.ID);
	WFIFOW( 6, tc.Point.X);
	WFIFOW( 8, tc.Point.Y);
	SendPCmd(tc, 10, true, true);
  end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
end;
//------------------------------------------------------------------------------
procedure SendCMove(Socket: TCustomWinSocket; tc:TChara; before, after:TPoint);
{�M���h�@�\�ǉ�}
var
	j   :integer;
	w   :word;
	tg  :TGuild;
        Tick :cardinal;
{�M���h�@�\�ǉ��R�R�܂�}
begin
	//DebugOut.Lines.Add(Format('S 007b %s (%d,%d)-(%d,%d)', [tc.Name, before.X, before.Y, after.X, after.Y]));
	ZeroMemory(@buf[0], 60);
	WFIFOW( 0, $007b);
	WFIFOL( 2, tc.ID);
	WFIFOW( 6, tc.Speed);
{�ǉ�}
	WFIFOW( 8, tc.Stat1);
	WFIFOW(10, tc.Stat2);
{�ǉ��R�R�܂�}
	WFIFOW(12, tc.Option);
	WFIFOW(14, tc.JID);
	WFIFOW(16, tc.Hair);
	WFIFOW(18, tc.Weapon);
	WFIFOW(20, tc.Head3);
	WFIFOL(22, timeGetTime());
	WFIFOW(26, tc.Shield);
	WFIFOW(28, tc.Head1);
	WFIFOW(30, tc.Head2);
	WFIFOW(32, tc.HairColor);
	WFIFOW(34, tc.ClothesColor);
	WFIFOW(36, tc.HeadDir);
{�M���h�@�\�ǉ�}
	WFIFOL(38, tc.GuildID); //GuildID.L
	w := 0;
	if (tc.GuildID <> 0) then begin
		j := GuildList.IndexOf(tc.GuildID);
		if (j <> -1) then begin
			tg := GuildList.Objects[j] as TGuild;
			w := tg.Emblem;
		end;
	end;
	WFIFOL(42, w); //EmblemID.L
	WFIFOW(46, tc.Manner); //.W?
	WFIFOB(48, tc.Karma); //.B?
{�M���h�@�\�ǉ��R�R�܂�}
	WFIFOB(49, tc.Gender);
	WFIFOM2(50, after, before);
	WFIFOB(56, 5);
	WFIFOB(57, 5);
{�ǉ�}
	WFIFOW(59, tc.BaseLV);
{�ǉ��R�R�܂�}
{�C��}
	if tc.ver2 = 9 then Socket.SendBuf(buf, 60)  //Kr?
	else                Socket.SendBuf(buf, 58); //Jp
{�C���R�R�܂�}
	//WFIFOW( 0, $007f);
	//WFIFOL( 2, timeGetTime()+1000);
	//Socket.SendBuf(buf, 6);
end;
//------------------------------------------------------------------------------
procedure SendCLeave(tc:TChara; mode:byte);
var
	i, j, k :integer;
	tm      :TMap;
	tc1     :TChara;
        mi      :MapTbl;
{�L���[�y�b�g}
        tn      :TNPC;
{�L���[�y�b�g�����܂�}
begin
{�p�[�e�B�[�@�\�ǉ�}
	//�ʒu�}�[�N�̍폜���@���킩��Ȃ������̂�
	//�}�b�v���痣���Ƃ���(0,0)�ɂ���Ƃ������𑗂��Ă��܂����Ă���
	if tc.PartyName <> '' then begin
		WFIFOW( 0, $0107);
		WFIFOL( 2, tc.ID);
		WFIFOW( 6, 0);
		WFIFOW( 8, 0);
		SendPCmd(tc,10,true,true);
	end;


{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
	tc.Login := 1; //���[�h���ɐ؂�ւ�
	tc.pcnt := 0;
	tc.AMode := 0;
	tc.MMode := 0;
	tm := Map.Objects[Map.IndexOf(tc.Map)] as TMap;
  mi := MapInfo.Objects[MapInfo.IndexOf(tm.Name)] as MapTbl;
{�L���[�y�b�g}
        if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin
                tn := tc.PetNPC;

                WFIFOW( 0, $0080 );
                WFIFOL( 2, tn.ID );
                WFIFOB( 6, 0 );
                SendBCmd( tm, tn.Point, 7 ,tc);


                //�y�b�g�폜
                i := tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.IndexOf(tn.ID);
                if i <> -1 then begin
                        tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.Delete(i);
                end;

								i := tm.NPC.IndexOf( tn.ID );
								if i <> -1 then begin
												tm.NPC.Delete(i);
								end;

								tn.Free;
								tc.PetNPC := nil;
        end;
{�L���[�y�b�g�����܂�}

{�`���b�g���[���@�\�ǉ�}
		//�����������o�[�̍폜����
		if (tc.ChatRoomID <> 0) then begin
			if (mode = 2) then ChatRoomExit(tc, true)
			else ChatRoomExit(tc);
			tc.ChatRoomID := 0;
		end;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
{�I�X�X�L���ǉ�}
		//�I�X���I������
		if (tc.VenderID <> 0) then begin
			if (mode = 2) then VenderExit(tc, true)
			else VenderExit(tc);
			tc.VenderID := 0;
		end;
{�I�X�X�L���ǉ��R�R�܂�}
{����@�\�ǉ�}
		if (tc.DealingID <> 0) then begin
			if (mode = 2) then CancelDealings(tc, true)
			else CancelDealings(tc);
			tc.DealingID := 0;
			tc.PreDealID := 0;
		end;
{����@�\�ǉ��R�R�܂�}
{�M���h�@�\�ǉ�}
		//�����o�[�ɒʒm
		WFIFOW( 0, $016d);
		WFIFOL( 2, tc.ID);
		WFIFOL( 6, tc.CID);
		WFIFOL(10, 0);
		SendGuildMCmd(tc, 14, true);
{�M���h�@�\�ǉ��R�R�܂�}

	if tm.Clist.IndexOf(tc.ID) <> -1 then begin //��d�����͂��Ȃ�
		//�u���b�N����
		WFIFOW(0, $0080);
		WFIFOL(2, tc.ID);
		WFIFOB(6, mode);
		for j := tc.Point.Y div 8 - 2 to tc.Point.Y div 8 + 2 do begin
			for i := tc.Point.X div 8 - 2 to tc.Point.X div 8 + 2 do begin
				//����̐l�Ƀ��O�A�E�g�ʒm
				for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
					tc1 := tm.Block[i][j].CList.Objects[k] as TChara;
					if (tc <> tc1) and (abs(tc.Point.X - tc1.Point.X) < 16) and
					(abs(tc.Point.Y - tc1.Point.Y) < 16) then tc1.Socket.SendBuf(buf, 7);
 				end;
			end;
		end;
              //if (mi.noPvP = false) then begin
              //for j := 0 to tm.CList.Count - 1 do begin
              //tc1 := tm.CList.Objects[j] as TChara;
              //WFIFOW( 0, $0199);
							//WFIFOW( 2, 1);
							//tc1.Socket.SendBuf(buf, 4);
              //k := j + 1;
              //i := tm.CList.Count - 1;
              //WFIFOW( 0, $019a);
              //WFIFOL( 2, tc1.ID);
              //WFIFOL( 6, k);
              //WFIFOL( 10, i);
              //tc1.Socket.SendBuf(buf, 14);
              //end;
              //end;

		//�}�b�v���玩���̃f�[�^������
		tm.CList.Delete(tm.Clist.IndexOf(tc.ID));
		with tm.Block[tc.Point.X div 8][tc.Point.Y div 8] do begin
                        if Clist.IndexOf(tc.ID) <> -1 then
			        CList.Delete(Clist.IndexOf(tc.ID));
		end;
                if CharaPID.IndexOf(tc.ID) <> -1 then
                	CharaPID.Delete(CharaPID.IndexOf(tc.ID));
	end;
end;
//------------------------------------------------------------------------------
procedure SendBCmd(tm:TMap; Point:TPoint; PacketLen:word; tc:TChara = nil; tail:boolean = False);
var
	i, j, k :integer;
	tc1     :TChara;
begin
	for j := Point.Y div 8 - 2 to Point.Y div 8 + 2 do begin
		for i := Point.X div 8 - 2 to Point.X div 8 + 2 do begin
			//���͂̐l�ɒʒm(tc <> nil�̏ꍇ�͎���������)
                        if assigned(tm) then begin // AlexKreuz
                                if assigned(tm.Block[i][j]) then begin
		                	for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
			                	tc1 := tm.Block[i][j].CList.Objects[k] as TChara;

				                if tc1 = nil then continue;
        				        if (tc = nil) or (tc <> tc1) then begin
        	        				if (abs(Point.X - tc1.Point.X) < 50) and (abs(Point.Y - tc1.Point.Y) < 50) then begin
	        	        				if tail and (tc1.Stat2 = 9) then begin
		        	        				tc1.Socket.SendBuf(buf, (PacketLen+2));
			        	        		end else begin
				        	        		tc1.Socket.SendBuf(buf, PacketLen);
					        	        end;
        					        end;
                                                end;
	        			end;
{�C���R�R�܂�}
		        	end;
                        end;
	        end;
        end;
end;

//------------------------------------------------------------------------------
procedure CalcSkillTick(tm:TMap; tc:TChara; Tick:cardinal = 0);
var
	i :integer;
begin
	if Tick = 0 then Tick := timeGetTime();
	with tc do begin
		SkillTick := $FFFFFFFF;
		for i := 1 to 330 do begin
			if Skill[i].Tick > Tick then begin
				if SkillTick > Skill[i].Tick then begin
					SkillTick := Skill[i].Tick;
					SkillTickID := i;
				end;
			end;
		end;
	end;
end;

procedure SendCGetItem(tc:TChara; Index:word; Amount:word);
begin
	WFIFOW( 0, $00a0);
	WFIFOW( 2, Index);
	WFIFOW( 4, Amount);
	WFIFOW( 6, tc.Item[Index].ID);
	WFIFOB( 8, tc.Item[Index].Identify);
	WFIFOB( 9, tc.Item[Index].Attr);
	WFIFOB(10, tc.Item[Index].Refine);
	WFIFOW(11, tc.Item[Index].Card[0]);
	WFIFOW(13, tc.Item[Index].Card[1]);
	WFIFOW(15, tc.Item[Index].Card[2]);
	WFIFOW(17, tc.Item[Index].Card[3]);
	with tc.Item[Index].Data do begin
		if (tc.JID = 12) and (IType = 4) and (Loc = 2) and
			 ((View = 1) or (View = 2) or (View = 6)) then
			WFIFOW(19, 34)
		else
			WFIFOW(19, Loc);
		WFIFOB(21, IType);
	end;
	WFIFOB(22, 0);
	tc.Socket.SendBuf(buf, 23);
end;
//------------------------------------------------------------------------------
procedure SendCStoreList(tc:TChara);
var
	i,j :integer;
	cnt :word;
	tp  :TPlayer;
begin
	tp := tc.PData;
	with tp do begin
		cnt := 0;
		//�A�C�e���f�[�^
		WFIFOW(0, $00a5);
		j := 0;
		for i := 1 to 100 do begin
			if (tp.Kafra.Item[i].ID <> 0) and not tp.Kafra.Item[i].Data.IEquip then begin
				WFIFOW( 4 +j*10, i);
				WFIFOW( 6 +j*10, tp.Kafra.Item[i].Data.ID);
				WFIFOB( 8 +j*10, tp.Kafra.Item[i].Data.IType);
				WFIFOB( 9 +j*10, tp.Kafra.Item[i].Identify);
				WFIFOW(10 +j*10, tp.Kafra.Item[i].Amount);
				if tp.Kafra.Item[i].Data.IType = 10 then
					WFIFOW(12 +j*10, 32768)
				else
					WFIFOW(12 +j*10, 0);
				Inc(j);
				Inc(cnt);
			end;
		end;
		WFIFOW(2, 4+j*10);
		tc.Socket.SendBuf(buf, 4+j*10);
		//�����f�[�^
		WFIFOW(0, $00a6);
		j := 0;
		for i := 1 to 100 do begin
			if (tp.Kafra.Item[i].ID <> 0) and tp.Kafra.Item[i].Data.IEquip then begin
				WFIFOW( 4 +j*20, i);
				WFIFOW( 6 +j*20, tp.Kafra.Item[i].Data.ID);
				WFIFOB( 8 +j*20, tp.Kafra.Item[i].Data.IType);
				WFIFOB( 9 +j*20, tp.Kafra.Item[i].Identify);
				with tp.Kafra.Item[i].Data do begin
					if (tc.JID = 12) and (IType = 4) and (Loc = 2) and
						 ((View = 1) or (View = 2) or (View = 6)) then
						WFIFOW(10 +j*20, 34)
					else
						WFIFOW(10 +j*20, Loc);
				end;
				WFIFOW(12 +j*20, tp.Kafra.Item[i].Equip);
				WFIFOB(14 +j*20, tp.Kafra.Item[i].Attr);
				WFIFOB(15 +j*20, tp.Kafra.Item[i].Refine);
				WFIFOW(16 +j*20, tp.Kafra.Item[i].Card[0]);
				WFIFOW(18 +j*20, tp.Kafra.Item[i].Card[1]);
				WFIFOW(20 +j*20, tp.Kafra.Item[i].Card[2]);
				WFIFOW(22 +j*20, tp.Kafra.Item[i].Card[3]);
				Inc(j);
				Inc(cnt);
			end;
		end;
		WFIFOW(2, 4+j*20);
		tc.Socket.SendBuf(buf, 4+j*20);
		//���\��
		tp.Kafra.Count := cnt;
		WFIFOW(0, $00f2);
		WFIFOW(2, tp.Kafra.Count);
		WFIFOW(4, 100);
		tc.Socket.SendBuf(buf, 6);
	end;
end;
//------------------------------------------------------------------------------
procedure SendCSkillList(tc:TChara);
var
	i, j, k :integer;
	b       :byte;
begin
	//�X�L�����M
	WFIFOW( 0, $010f);
	j := 0;
	for i := 1 to 336 do begin
		//if (not tc.Skill[i].Data.Job[tc.JID]) and (not DisableSkillLimit) then continue;
		if (not (tc.Skill[i].Data.Job[tc.JID]) and (not tc.Skill[i].Card) and (not tc.Skill[i].Plag) and (not DisableSkillLimit)) then continue;
                if tc.Skill[i].Plag then tc.Skill[i].Lv := tc.PLv;

		WFIFOW( 0+37*j+4, i);
		WFIFOW( 2+37*j+4, tc.Skill[i].Data.SType);
		WFIFOW( 4+37*j+4, 0);
		WFIFOW( 6+37*j+4, tc.Skill[i].Lv);

		if tc.Skill[i].Lv <> 0 then
			WFIFOW( 8+37*j+4, tc.Skill[i].Data.SP[tc.Skill[i].Lv])
		else
			WFIFOW( 8+37*j+4, tc.Skill[i].Data.SP[1]);
		WFIFOW(10+37*j+4, tc.Skill[i].Data.Range);
		WFIFOS(12+37*j+4, tc.Skill[i].Data.IDC, 24);
		b	:= 0;
		if tc.Skill[i].Card and (not DisableSkillLimit) then begin
			b := 0;
    end else if tc.Skill[i].Plag and (not DisableSkillLimit) then begin
      b := 0;
		end else if tc.Skill[i].Lv = tc.Skill[i].Data.MasterLV then begin
			b := 0;
		end else if (tc.Skill[i].Data.MasterLV <> 0) then begin
			b := 1;
			for k := 0 to 4 do begin
                if ((tc.Skill[i].Data.ReqJID1 = 99) or (tc.Skill[i].Data.ReqJID1 = tc.JID)) and (tc.Skill[i].Data.ReqSkill1[k] <> 0) and (tc.Skill[tc.Skill[i].Data.ReqSkill1[k]].Lv < tc.Skill[i].Data.ReqLV1[k]) then begin
					b := 0;
					continue;
				end;
			end;
      if (b <> 0) then begin
        for k := 0 to 4 do begin
                    if ((tc.Skill[i].Data.ReqJID2 = 99) or (tc.Skill[i].Data.ReqJID2 = tc.JID)) and (tc.Skill[i].Data.ReqSkill2[k] <> 0) and (tc.Skill[tc.Skill[i].Data.ReqSkill2[k]].Lv < tc.Skill[i].Data.ReqLV2[k]) then begin
					b := 0;
					continue;
				end;
			end;
		end;
		end;
		WFIFOB(36+37*j+4, b);
		Inc(j);
	end;
                
	WFIFOW( 2, 4+37*j);
	tc.Socket.SendBuf(buf, 4+37*j);

	//�X�L���|�C���g���M
	WFIFOW( 0, $00b0);
	WFIFOW( 2, $000c);
	WFIFOL( 4, tc.SkillPoint);
	tc.Socket.SendBuf(buf, 8);
end;
//------------------------------------------------------------------------------
{�ǉ�} //�C�O�t��A���e�B�y�C�������g���p
procedure SendItemSkill(tc:TChara; s:Cardinal; L:Cardinal = 1);
var
	tl:TSkillDB;
begin
	tl := SkillDB.IndexOfObject(s) as TSkillDB;
	if tl = nil then Exit;
	if tl.MasterLV < L then L := tl.MasterLv
	else if L < 1 then L := 1;
	WFIFOW( 0, $0147);
	WFIFOW( 2, s);
	WFIFOW( 4, tl.SType);
	//WFIFOW( 6, L);
	//WFIFOW( 8, tl.SP[L]);
	//WFIFOW(10, tl.Range);
	//WFIFOS(12, tl.IDC, 24);
	//WFIFOB(36, 0);
	//tc.Socket.SendBuf(buf, 37);
        WFIFOW( 6, 0);
        WFIFOW( 8, L);
	WFIFOW(10, tl.SP[L]);
	WFIFOW(12, tl.Range);
	WFIFOS(14, tl.IDC, 24);
	WFIFOB(38, 0);
	tc.Socket.SendBuf(buf, 39);
	tc.ItemSkill := True;
end;

//------------------------------------------------------------------------------
procedure SendSkillError(tc:TChara; Code:Cardinal);
begin
	with tc do begin
		case Code of
			1: //SP�s��
				begin
					WFIFOW( 0, $0110);
					WFIFOW( 2, MUseLV);
					WFIFOW( 4, 0);
					WFIFOW( 6, 0);
					WFIFOB( 8, 0);
					WFIFOB( 9, 1);
					Socket.SendBuf(buf, 10);
				end;
			2: //�d�ʃI�[�o�[
				begin
					WFIFOW(0, $013b);
					WFIFOW(2, 2);
					Socket.SendBuf(buf, 4);
				end;
			3: //�������}�[
				begin
					WFIFOW( 0, $0110);
					WFIFOW( 2, tc.MUseLV);
					WFIFOW( 4, 0);
					WFIFOW( 6, 0);
					WFIFOB( 8, 0);
					WFIFOB( 9, 5);
					Socket.SendBuf(buf, 10);
				end;
			else //��������
		end;
	end;
end;
//------------------------------------------------------------------------------
function UseFieldSkill(tc:TChara; Tick:Cardinal) : Integer;
var
	tm:TMap;
	tc1:TChara;
	ts:TMob;
	tl:TSkillDB;
	i:Integer;
begin
	Result := 0;
	tm := tc.MData;
	with tc do begin
		if (tc.Skill[tc.MSkill].Lv >= tc.MUseLV) and (tc.MUseLV > 0) then begin
			tl := tc.Skill[tc.MSkill].Data;

			if tc.SP < tl.SP[tc.MUseLV] then begin
				//SP�s��
				Result := 1;
				Exit;
			end;
			if tc.Weight * 100 div tc.MaxWeight >= 90 then begin
				Result := 2;
				Exit;
			end;
			if tm.Mob.IndexOf(tc.MTarget) <> -1 then begin
				ts := tm.Mob.IndexOfObject(tc.MTarget) as TMob;
				if ts.HP = 0 then Exit;
				tc.MTargetType := 0;
				tc.AData := ts;
			end else if tm.CList.IndexOf(tc.MTarget) <> -1 then begin
				tc1 := tm.CList.IndexOfObject(tc.MTarget) as TChara;
				tc.MTargetType := 1;
				tc.AData := tc1;
			end else begin
				tc1 := tc;
				tc.MTargetType := 1;
				tc.AData := tc1;
			end;
			tc.pcnt := 0;
			if (tc.AMode = 1) or (tc.AMode = 2) then tc.AMode := 0;
			with tc.Skill[tc.MSkill] do begin
				i := Data.CastTime1 + Data.CastTime2 * tc.MUseLV;
				if i < Data.CastTime3 then i := Data.CastTime3;
			end;
			i := i * tc.MCastTimeFix div 100;
			if i > 0 then begin
				//�r���J�n
				WFIFOW( 0, $013e);
				WFIFOL( 2, tc.ID);
				WFIFOL( 6, 0);
				WFIFOW(10, tc.MPoint.X);
				WFIFOW(12, tc.MPoint.Y);
				WFIFOW(14, tc.MSkill); //SkillID
				WFIFOL(16, tl.Element); //Element
				WFIFOL(20, i);
				SendBCmd(tm, tc.Point, 24);
				tc.MMode := 2;
				tc.MTick := Tick + cardinal(i);
			end else begin
				//�r���Ȃ�
				tc.MMode := 2;
				tc.MTick := Tick;
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
function UseTargetSkill(tc:TChara; Tick:Cardinal) : Integer;
var
	tm:TMap;
	tc1:TChara;
	ts:TMob;
	tl:TSkillDB;
	i:Integer;
begin
	Result := 0;
	tm := tc.MData;
	with tc do begin
		tl := tc.Skill[tc.MSkill].Data;

		if (tc.SP < tl.SP[tc.MUseLV]) and (tc.ItemSkill = false) then begin
			//SP�s��
			Result := 1;
			Exit;
		end;


		if tc.Weight * 100 div tc.MaxWeight >= 90 then begin
			//�d�ʃI�[�o�[
			Result := 2;
			Exit;
		end;

		if (tc.MSkill = 42) and (tc.Zeny < cardinal(tl.Data2[tc.MUseLV])) then begin
			//�������}�[
			Result := 3;
			Exit;
		end;

		if tm.Mob.IndexOf(tc.MTarget) <> -1 then begin
			ts := tm.Mob.IndexOfObject(tc.MTarget) as TMob;
			if ts.HP = 0 then Exit;
			tc.MTargetType := 0;
			tc.AData := ts;
			if (ts.ATarget = 0) and Boolean(ts.Data.Mode and $10) then begin

				ts.ATarget := ID;
				ts.AData := tc;
				ts.isLooting := False;
				ts.ATick := Tick + aMotion;
			end;

		end else if (tc.MSkill = 41) then begin //�I�X�J��
			i := tl.Data1[tc.Skill[41].Lv];
			if (i >= 3) and (i <= 12) then begin
				if (DecSP(tc, 41, Skill[41].Lv) = true) then begin
					//�I�X�ő�A�C�e��������
					WFIFOW(0, $012d);
					WFIFOW(2, i);
					Socket.SendBuf(buf, 4);
				end;
			end;


		end else if tm.CList.IndexOf(tc.MTarget) <> -1 then begin
			tc1 := tm.CList.IndexOfObject(tc.MTarget) as TChara;
			tc.MTargetType := 1;
			tc.AData := tc1;
		end else begin
			tc1 := tc;
			tc.MTargetType := 1;
			tc.AData := tc1;
		end;
		tc.pcnt := 0;
		if (tc.AMode = 1) or (tc.AMode = 2) then tc.AMode := 0;

                 if (tc.MSkill =  153) then begin  {Cart Revolution}
                        if (tc.Option <> 8) and (tc.Option <> 9) then exit;
                 end;
                 
		if tc.MSkill =	26 then begin //�e���|�[�g
			//�I��
			ZeroMemory(@buf[0], 68);
			WFIFOW( 0, $011c);
			WFIFOW( 2, 26);
			WFIFOS( 4, 'Random', 16);
			if tc.Skill[26].Lv = 2 then
				WFIFOS(20, tc.SaveMap + '.gat', 16);
			Socket.SendBuf(buf, 68);
			WFIFOW( 0, $011a);
			WFIFOW( 2, 26);
			WFIFOW( 4, tc.Skill[26].Lv);
			WFIFOL( 6, tc.ID);
			WFIFOL(10, tc.ID);
			WFIFOB(14, 1);
			Socket.SendBuf(buf, 15);
		end else begin
			with tc.Skill[tc.MSkill] do begin
				i := Data.CastTime1 + Data.CastTime2 * tc.MUseLV;
				if i < Data.CastTime3 then i := Data.CastTime3;
			end;
			i := i * tc.MCastTimeFix div 100;
			if (i > 0) or (tc.ItemSkill = true) then begin
				//�r���J�n
				WFIFOW( 0, $013e);
				WFIFOL( 2, tc.ID);
				WFIFOL( 6, tc.MTarget);
				WFIFOW(10, 0);
				WFIFOW(12, 0);
				WFIFOW(14, tc.MSkill); //SkillID?
				WFIFOL(16, tl.Element); //Element
				WFIFOL(20, i);
				SendBCmd(tm, tc.Point, 24);
				tc.MMode := 1;
				tc.MTick := Tick + cardinal(i);
			end else begin
				//�r���Ȃ�
				tc.MMode := 1;
				tc.MTick := Tick;
			end;
		end;
	end;
	Result := 0;
end;
//------------------------------------------------------------------------------
procedure SendCSkillAtk1(tm:TMap; tc:TChara; ts:TMob; Tick:cardinal; dmg:Integer; k:byte; PType:byte = 0);
var
  j: integer;
  tg: TGuild;
begin

  // AlexKreuz: Needed to stop damage to Emperium
  // From Splash Attacks.
  if (ts.isEmperium) then begin
    j := GuildList.IndexOf(tc.GuildID);
    if (j <> -1) then begin
	    tg := GuildList.Objects[j] as TGuild;
      if (tg.GSkill[10000].Lv < 1) then begin
        dmg := 0;
        Exit;
      end;
    end else begin
        dmg := 0;
        Exit;
    end;
  end;
  
	WFIFOW( 0, $01de);
	WFIFOW( 2, tc.MSkill);
	WFIFOL( 4, tc.ID);
	WFIFOL( 8, ts.ID);
	WFIFOL(12, Tick);
	WFIFOL(16, tc.aMotion);
	WFIFOL(20, ts.Data.dMotion);
	WFIFOL(24, dmg);
	WFIFOW(28, tc.MUseLV);
	WFIFOW(30, k);
	if PType <> 0 then WFIFOB(32, PType)
	else if k = 1 then WFIFOB(32, 6)
	else               WFIFOB(32, 8);
	if ts.Stat1 = 5 then dmg := dmg * 2; //���b�N�X_�G�[�e���i
	SendBCmd(tm, tc.Point, 33);
end;
//------------------------------------------------------------------------------
procedure SendCSkillAtk2(tm:TMap; tc:TChara; tc1:TChara; Tick:cardinal; dmg:Integer; k:byte; PType:byte = 0);
begin
	WFIFOW( 0, $01de);
	WFIFOW( 2, tc.MSkill);
	WFIFOL( 4, tc.ID);
	WFIFOL( 8, tc1.ID);
	WFIFOL(12, Tick);
	WFIFOL(16, tc.aMotion);
	WFIFOL(20, tc1.dMotion);
	WFIFOL(24, dmg);
	WFIFOW(28, tc.MUseLV);
	WFIFOW(30, k);
	if PType <> 0 then WFIFOB(32, PType)
	else if k = 1 then WFIFOB(32, 6)
	else               WFIFOB(32, 8);
	if tc1.Stat1 = 5 then dmg := dmg * 2;
	SendBCmd(tm, tc.Point, 33);
end;

//------------------------------------------------------------------------------
function UpdateSpiritSpheres(tm:TMap; tc:TChara; spiritSpheres:integer) :boolean;
begin
        WFIFOW( 0, $01d0);
        WFIFOL( 2, tc.ID);
        WFIFOW( 6, spiritspheres);
        // Colus, 20031222: This packet only has 8 bytes, not 16!
        SendBCmd(tm, tc.Point, 8);
end;
//------------------------------------------------------------------------------
function DecSP(tc:TChara; SkillID:word; LV:byte) :boolean;
begin
	Result := false;
        if SkillID = 0 then
         exit;
	if tc.SP < tc.Skill[SkillID].Data.SP[LV] then exit;

        if tc.LessSP then begin
                tc.SP := tc.SP - (tc.Skill[SkillID].Data.SP[LV] * 70 div 100);
        end else if tc.NoJamstone then begin
                tc.SP := tc.SP - (tc.Skill[SkillID].Data.SP[LV] * 125 div 100);
        end else if tc.SPRedAmount > 0 then begin
                tc.SP := tc.SP - (tc.Skill[SkillID].Data.SP[LV] - (tc.Skill[SkillID].Data.SP[LV] * tc.SPRedAmount div 100));
        end else begin
	        tc.SP := tc.SP - tc.Skill[SkillID].Data.SP[LV];
        end;
	WFIFOW( 0, $00b0);
	WFIFOW( 2, $0007);
	WFIFOL( 4, tc.SP);
	tc.Socket.SendBuf(buf, 8);
	Result := true;
end;

//------------------------------------------------------------------------------

function UseItem(tc:TChara; j:integer) :boolean;

begin
        Dec(tc.Item[j].Amount, 1);
        if tc.Item[j].Amount = 0 then tc.Item[j].ID := 0;
        WFIFOW( 0, $00af);
        WFIFOW( 2, j);
        WFIFOW( 4, 1);
        tc.Socket.SendBuf(buf, 6);
        //�d�ʕύX
        tc.Weight := tc.Weight - tc.Item[j].Data.Weight;
        WFIFOW( 0, $00b0);
        WFIFOW( 2, $0018);
        WFIFOL( 4, tc.Weight);
        tc.Socket.SendBuf(buf, 8);
end;

//------------------------------------------------------------------------------

function  UpdateWeight(tc:TChara; j:integer; td:TItemDB)  :boolean;

begin
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
        tc.Weight := tc.Weight + cardinal(td.Weight);
        WFIFOW( 0, $00b0);
        WFIFOW( 2, $0018);
        WFIFOL( 4, tc.Weight);
end;
//------------------------------------------------------------------------------

function UseUsableItem(tc:TChara; w:integer) :boolean;

begin
        Dec(tc.Item[w].Amount);
        WFIFOW( 0, $00a8);
        WFIFOW( 2, w);
        WFIFOW( 4, tc.Item[w].Amount);
        WFIFOB( 6, 1);
        tc.Socket.SendBuf(buf, 7);
        if tc.Item[w].Amount = 0 then tc.Item[w].ID := 0;
        tc.Weight := tc.Weight - tc.Item[w].Data.Weight;
        
        WFIFOW( 0, $00af);
        WFIFOW( 2, w);
        WFIFOW( 4, 1);

        WFIFOW( 0, $00b0);
        WFIFOW( 2, $0018);
        WFIFOL( 4, tc.Weight);
        tc.Socket.SendBuf(buf, 8);
end;

//------------------------------------------------------------------------------

function  GetMVPItem(tc1:TChara; ts:TMob; mvpitem:boolean) :boolean;
var
        j :integer;
        i :integer;
        td :TItemDB;
begin
        if ts.Data.MEXPPer <= Random(10000) then begin
                for i := 0 to 2 do begin
                        if ts.Data.MVPItem[i].Per > cardinal(Random(10000)) then begin
                                //MVP Item
                                td := ItemDB.IndexOfObject(ts.Data.MVPItem[i].ID) as TItemDB;
                                //�d�ʃI�[�o�[��A�C�e����ސ��I�[�o�[�̎��́A�K���o���l�ɂȂ�@�ׂ��������}���h�N�Z('A�M)�m
                                if tc1.MaxWeight >= tc1.Weight + td.Weight then begin
                                        j := SearchCInventory(tc1, td.ID, td.IEquip);
                                        if j <> 0 then begin
                                                //MVP Get Item
                                                WFIFOW( 0, $010a);
                                                WFIFOW( 2, td.ID);
                                                tc1.Socket.SendBuf(buf, 4);

                                                //Set Item Properites
                                                tc1.Item[j].ID := td.ID;
                                                tc1.Item[j].Amount := tc1.Item[j].Amount + 1;
                                                tc1.Item[j].Equip := 0;
                                                tc1.Item[j].Identify := 1 - byte(td.IEquip);
                                                tc1.Item[j].Refine := 0;
                                                tc1.Item[j].Attr := 0;
                                                tc1.Item[j].Card[0] := 0;
                                                tc1.Item[j].Card[1] := 0;
                                                tc1.Item[j].Card[2] := 0;
                                                tc1.Item[j].Card[3] := 0;
                                                tc1.Item[j].Data := td;
                                                //�d�ʒǉ�
                                                tc1.Weight := tc1.Weight + td.Weight;
                                                WFIFOW( 0, $00b0);
                                                WFIFOW( 2, $0018);
                                                WFIFOL( 4, tc1.Weight);
                                                tc1.Socket.SendBuf(buf, 8);

                                                //�A�C�e���Q�b�g�ʒm
                                                SendCGetItem(tc1, j, 1);
                                                mvpitem := true;
                                        end;
                                end;
                                break;
                        end;
                end;
        end;
end;

//------------------------------------------------------------------------------
function SearchCInventory(tc:TChara; ItemID:word; IEquip:boolean):word;
var
	i :integer;
begin
	Result := 0;
	if IEquip then begin
		for i := 1 to 100 do begin
			//��index��T��
			if tc.Item[i].ID = 0 then begin
				tc.Item[i].Amount := 0;
				Result := i;
				break;
			end;
		end;
	end else begin
		for i := 1 to 100 do begin
			//�����A�C�e���������Ă邩�T��
			if tc.Item[i].ID = ItemID then begin
				Result := i;
				exit;
			end;
		end;
		for i := 1 to 100 do begin
			//��index��T��
			if tc.Item[i].ID = 0 then begin
				tc.Item[i].Amount := 0;
				Result := i;
				break;
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
function SearchPInventory(tc:TChara; ItemID:word; IEquip:boolean):word;
var
	i   :integer;
	tp  :TPlayer;
begin
	Result := 0;
	tp := tc.PData;
	if IEquip then begin
		for i := 1 to 100 do begin
			//��index��T��
			if tp.Kafra.Item[i].ID = 0 then begin
				tp.Kafra.Item[i].Amount := 0;
				Result := i;
				break;
			end;
		end;
	end else begin
		for i := 1 to 100 do begin
			//�����A�C�e���������Ă邩�T��
			if tp.Kafra.Item[i].ID = ItemID then begin
				Result := i;
				exit;
			end;
		end;
		for i := 1 to 100 do begin
			//��index��T��
			if tp.Kafra.Item[i].ID = 0 then begin
				tp.Kafra.Item[i].Amount := 0;
				Result := i;
				break;
			end;
		end;
	end;
end;
//==============================================================================






//==============================================================================
procedure SendMData(Socket: TCustomWinSocket; ts:TMob; Use0079:boolean = false);
begin
	ZeroMemory(@buf[0], 41);
	WFIFOW( 0, $007c);
	WFIFOL( 2, ts.ID);
	WFIFOW( 6, ts.Speed);
{�ǉ�}
	WFIFOW( 8, ts.Stat1);
	WFIFOW(10, ts.Stat2);
{�ǉ��R�R�܂�}
	WFIFOW(20, ts.JID);
	WFIFOM1(36, ts.Point, ts.Dir);
	Socket.SendBuf(buf, 41);
end;
//------------------------------------------------------------------------------
procedure SendMMove(Socket: TCustomWinSocket; ts:TMob; before, after:TPoint; ver2:Word);
begin
	//DebugOut.Lines.Add(Format('S 007b %s (%d,%d)-(%d,%d)', [tc.Name, before.X, before.Y, after.X, after.Y]));
	ZeroMemory(@buf[0], 60);
	WFIFOW( 0, $007b);
	WFIFOL( 2, ts.ID);
	WFIFOW( 6, ts.Speed);
{�ǉ�}
	WFIFOW( 8, ts.Stat1);
	WFIFOW(10, ts.Stat2);
{�ǉ��R�R�܂�}
	WFIFOW(14, ts.JID);
	WFIFOL(22, timeGetTime());
	WFIFOW(36, ts.Dir);
	WFIFOM2(50, after, before);
	WFIFOB(56, 5);
	WFIFOB(57, 5);
{�C��}
	if ver2 = 9 then begin
		Socket.SendBuf(buf, 60); //kr�d�l
	end else begin
		Socket.SendBuf(buf, 58); //Jp�d�l
	end;
{�C���R�R�܂�}
	//WFIFOW( 0, $007f);
	//WFIFOL( 2, timeGetTime()+1000);
	//Socket.SendBuf(buf, 6);
end;
//------------------------------------------------------------------------------
procedure SendPMove(Socket: TCustomWinSocket; te:TeNPC; before, after:TPoint; ver2:Word);
begin
	ZeroMemory(@buf[0], 60);
	WFIFOW( 0, $007b);
	WFIFOL( 2, te.ID);
	WFIFOW( 6, te.Speed);
	WFIFOW( 8, te.Stat1);
	WFIFOW(10, te.Stat2);
	WFIFOW(12, te.Option);
	WFIFOW(14, te.JID);
	WFIFOW(16, te.Hair);
	WFIFOW(18, te.Weapon);
	WFIFOW(20, te.Head3);
	WFIFOL(22, timeGetTime());
	WFIFOW(26, te.Shield);
	WFIFOW(28, te.Head1);
	WFIFOW(30, te.Head2);
	WFIFOW(32, te.HairColor);
	WFIFOW(34, te.ClothesColor);
	WFIFOW(36, te.HeadDir);
	WFIFOW(38, te.GuildID);
	WFIFOW(44, te.Manner);
	WFIFOW(46, te.Karma);
	WFIFOB(49, te.Gender);
	WFIFOM2(50, after, before);
	WFIFOB(56, 5);
	WFIFOB(57, 5);
{�C��}
	if ver2 = 9 then Socket.SendBuf(buf, 60)  //Kr?
	else             Socket.SendBuf(buf, 58); //Jp
end;
//------------------------------------------------------------------------------
{�A�W�g�@�\�ǉ�}
var
	i  :integer;
	j  :integer;
	w1 :word;
	w2 :word;
	tg :TGuild;
{�A�W�g�@�\�ǉ��R�R�܂�}
procedure SendNData(Socket: TCustomWinSocket; tn:TNPC; ver2:Word; Use0079:boolean = false);
begin
{NPC�C�x���g�ǉ�}
	if (tn.JID = -1) then exit;
{NPC�C�x���g�ǉ��R�R�܂�}
	if (tn.CType = 3) then begin
		WFIFOW( 0, $009d);
		WFIFOL( 2, tn.ID);
		WFIFOW( 6, tn.Item.ID);
		WFIFOB( 8, tn.Item.Identify);
		WFIFOW( 9, tn.Point.X);
		WFIFOW(11, tn.Point.Y);
		WFIFOW(13, tn.Item.Amount);
		WFIFOB(15, tn.SubX);
		WFIFOB(16, tn.SubY);
		Socket.SendBuf(buf, 17);
	end else if tn.CType = 4 then begin
		WFIFOW( 0, $011f);
		WFIFOL( 2, tn.ID);
		WFIFOL( 6, 0);
		WFIFOW(10, tn.Point.X);
		WFIFOW(12, tn.Point.Y);
		WFIFOB(14, tn.JID);
		WFIFOB(15, 1);
		Socket.SendBuf(buf, 16);
	end else if tn.JID < 45 then begin
		ZeroMemory(@buf[0], 53);
		WFIFOW(0, $0079);
		WFIFOL( 2, tn.ID);
		WFIFOW( 6, 200);
		WFIFOW(14, tn.JID);
		WFIFOM1(46, tn.Point, tn.Dir);
		WFIFOB(49, 5);
		WFIFOB(50, 5);
{�C��}
		if Socket <> nil then begin
			if ver2 = 9 then Socket.SendBuf(buf, 53) //Kr?
			else             Socket.SendBuf(buf, 51);//Jp
		end;
{�C���R�R�܂�}
	end else begin
{�A�W�g�@�\�ǉ�}
//		ZeroMemory(@buf[0], 41);
//		WFIFOW( 0, $007c);
//		WFIFOL( 2, tn.ID);
//		WFIFOW( 6, 200);
//		WFIFOW(20, tn.JID);
//		WFIFOM1(36, tn.Point, tn.Dir);
//		Socket.SendBuf(buf, 41);
		ZeroMemory(@buf[0], 54);
		WFIFOW(0, $0078);
		WFIFOL( 2, tn.ID);
		WFIFOW( 6, 200);
		WFIFOW(14, tn.JID);
		w1 := 0;
		w2 := 0;
		if (tn.Agit <> '') then begin
			for i := 0 to GuildList.Count - 1 do begin
				tg := GuildList.Objects[i] as TGuild;
				if (tg.Agit = tn.Agit) then begin
					w1 := tg.Emblem;
					w2 := tg.ID;
					break;
				end;
			end;
		end;
		WFIFOL(22, w1);
		WFIFOL(26, w2);
		WFIFOM1(46, tn.Point, tn.Dir);
		WFIFOB(49, 5); //0=warp,1,5,20=hidden
		WFIFOB(50, 5); //�V
		if Socket <> nil then begin
			if ver2 = 9 then Socket.SendBuf(buf, 54)	//Kr?
			else             Socket.SendBuf(buf, 52); //Jp
		end;
{�A�W�g�@�\�ǉ��R�R�܂�}
	end;
end;
//------------------------------------------------------------------------------
{�L���[�y�b�g}
procedure SendPetMove(Socket: TCustomWinSocket; tc:TChara; target:TPoint );
var
        tn:TNPC;
        tpe:TPet;
begin
        if ( tc.PetData <> nil ) and ( tc.PetNPC <> nil ) then begin
                tpe := tc.PetData;
                tn := tc.PetNPC;

	        ZeroMemory(@buf[0], 60);
					WFIFOW( 0, $007b);
	        WFIFOL( 2, tn.ID );
	        WFIFOW( 6, tc.Speed);
	        WFIFOW(14, tpe.JID);
                WFIFOW(16, 20 ); // ��
                WFIFOW(20, tpe.Accessory);
	        WFIFOL(22, timeGetTime());
	        WFIFOW(36, tn.Dir);
	        WFIFOM2(50, target, tn.Point );
	WFIFOB(56, 5);
	WFIFOB(57, 5);

	        if tc.ver2 = 9 then begin
		        Socket.SendBuf(buf, 60); //kr�d�l
	        end else begin
		        Socket.SendBuf(buf, 58); //Jp�d�l
	        end;
        end;
end;
{�L���[�y�b�g�����܂�}
//------------------------------------------------------------------------------
function SetSkillUnit(tm:TMap; ID:cardinal; xy:TPoint; Tick:cardinal; SType:word; SCount:word; STime:cardinal; tc:TChara = nil):TNPC;
var
	tn :TNPC;
begin
	tn := TNPC.Create;
	tn.ID := NowItemID;
	Inc(NowItemID);
	tn.Name := 'skillunit';
	tn.JID := SType;
	tn.Map := tm.Name;
	tn.Point := xy;
	tn.CType := 4; //SkillUnit
	tn.Tick := Tick + STime;
	tn.Count := SCount;
	tn.CData := tc;
	tm.NPC.AddObject(tn.ID, tn);
	tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);

        if tn.JID = 141 then begin
          tm.gat[tn.Point.X][tn.Point.Y] := 1;
        end;

        if tn.JID = $46 then begin
                WFIFOW( 0, $011f);
	        WFIFOL( 2, tn.ID);
	        WFIFOL( 6, ID);
	        WFIFOW(10, tn.Point.X);
	        WFIFOW(12, tn.Point.Y);
	        WFIFOB(14, $83);
	        WFIFOB(15, 1);
	        SendBCmd(tm, tn.Point, 16);
        end else begin
	//����ɒʒm
	        WFIFOW( 0, $011f);
	        WFIFOL( 2, tn.ID);
	        WFIFOL( 6, ID);
	        WFIFOW(10, tn.Point.X);
	        WFIFOW(12, tn.Point.Y);
	        WFIFOB(14, tn.JID);
	        WFIFOB(15, 1);
	        SendBCmd(tm, tn.Point, 16);
        end;

	Result := tn;
end;
//------------------------------------------------------------------------------
procedure DelSkillUnit(tm:TMap; tn:TNPC);
begin
	//�X�L�����\�n�P��
	WFIFOW(0, $0120);
	WFIFOL(2, tn.ID);
	SendBCmd(tm, tn.Point, 6);
	//�X�L�����\�n�폜
	tm.NPC.Delete(tm.NPC.IndexOf(tn.ID));
	with tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC do
		Delete(IndexOf(tn.ID));
	tn.Free;
end;
//==============================================================================








//==============================================================================
function	MoveItem(ti1:TItemList; ti2:TitemList; Index:Word; cnt:Word) : Integer; overload;
var
	i,j:Integer;
begin
	Result := -1;
	if 100 < index then Exit; //�����͈͊O
	if ti2.Item[Index].ID = 0 then Exit; //�����A�C�e�������ĂȂ�
	i := SearchInventory(ti1, ti2.Item[Index].ID, ti2.Item[Index].Data.IEquip);
	if i = 0 then begin //����󂫖���
		Result := 3;
		Exit;
	end;
	//�����������玝���Ă鐔��
	if ti2.Item[Index].Amount < cnt then cnt := ti2.Item[Index].Amount;
	j := GetItemStore(ti1, ti2.Item[Index], cnt);
	if j = 0 then begin
		DeleteItem(ti2,Index,cnt);
		Result := 0;
	end else if j = 2 then begin //����d�ʃI�[�o�[
		Result := j;
	end else if j = 3 then begin //�����ރI�[�o�[
		Result := j;
	end;
end;
//------------------------------------------------------------------------------
function  GetItemStore(ti:TItemList; td:TItem; cnt:Word; IsEquip:Boolean = False) : Integer;
var
	i:Integer;
begin
	Result := 0;
	with ti do begin
		//�d�ʃI�[�o�[
		if MaxWeight < (Weight + td.Data.Weight * cnt) then begin
			Result := 2;
			Exit;
		end;
		if not IsEquip then IsEquip := td.Data.IEquip;
		i := SearchInventory(ti,td.ID,IsEquip);
		//������ރI�[�o�[
		if i = 0 then begin
			Result := 3;
			Exit;
		end;
		//�������I�[�o�[
		if cnt + Item[i].Amount > 30000 then begin
			Result := -1;
			Exit;
		end;
		with Item[i] do begin
			if Amount = 0 then Inc(Count);
			ID := td.ID;
			Inc(Amount,cnt);
			Equip := 0;
			Identify := td.Identify;
			Refine := td.Refine;
			Attr := td.Attr;
			Card[0] := td.Card[0];
			Card[1] := td.Card[1];
			Card[2] := td.Card[2];
			Card[3] := td.Card[3];
			Data := td.Data;
		end;
		Inc(Weight,(td.Data.Weight * cnt));
	end;
end;
//------------------------------------------------------------------------------
function DeleteItem(ti:TItemList; index:Word; cnt:Word) : Integer;
begin
	Result := -1;
	if 100 < index then Exit; //�͈͊O
	with ti.item[index] do begin
		if ID = 0 then Exit;       //�������Ă��Ȃ�
		if Amount > cnt then begin //���L���ȉ�
			Dec(Amount,cnt);
			Dec(ti.Weight,(Data.Weight * cnt));
		end else begin
			ID := 0;
			Dec(ti.Weight,(Data.Weight * Amount));
			Amount := 0;
			Dec(ti.Count);
		end;
	end;
	Result := 0;
end;
//------------------------------------------------------------------------------
procedure CalcInventory(ti:TItemList);
var
	i,j:Integer;
begin
	ti.Weight := 0;
	j := 0;
	//�A�C�e���d�ʂ��v�Z
	for i := 1 to 100 do begin
		if ti.Item[i].ID <> 0 then begin
                        //if ti.Item[i].Amount <= 0 then ti.Item[i].Amount := 0;
			Inc(ti.Weight,(ti.item[i].Data.Weight * ti.item[i].Amount));
			Inc(j);
		end;
	end;
	ti.Count := j;
end;
//------------------------------------------------------------------------------
function SearchInventory(ti:TItemList; ItemID:Word; IEquip:Boolean) : Word;
var
	i :integer;
begin
	Result := 0;
	if not IEquip then begin
		for i := 1 to 100 do begin
			//�����A�C�e���������Ă邩�T��
			if ti.Item[i].ID = ItemID then begin
				Result := i;
				Exit;
			end;
		end;
	end;
	if ti.Count = 100 then Exit;
	for i := 1 to 100 do begin
		//��index��T��
		if ti.Item[i].ID = 0 then begin
			ti.Item[i].Amount := 0;
			Result := i;
			Exit;
		end;
	end;
end;
//------------------------------------------------------------------------------
{�J�[�g�@�\�ǉ�}
procedure SendCart(tc:TChara);
var
	j,i:Integer;
begin
	with tc.Cart do begin
	//�J�[�g�����Օi�����W�i�̕\���p�P�b�g�쐬
	WFIFOW(0, $0123);
	j := 0;
	for i := 1 to 100 do begin
		if (Item[i].ID <> 0) and (not item[i].Data.IEquip) then begin
			WFIFOW( 4 +j*10, i);
			WFIFOW( 6 +j*10, item[i].Data.ID);
			WFIFOB( 8 +j*10, item[i].Data.IType);
			WFIFOB( 9 +j*10, item[i].Identify);
			WFIFOW(10 +j*10, item[i].Amount);
			if item[i].Data.IType = 10 then
				WFIFOW(12 +j*10, 32768)
			else
				WFIFOW(12 +j*10, 0);
			Inc(j);
		end;
	end;
	WFIFOW(2, 4+j*10);
	tc.Socket.SendBuf(buf, 4+j*10);

	//�J�[�g�������i
	WFIFOW(0, $0122);
	j := 0;
	for i := 1 to 100 do begin
		if (item[i].ID <> 0) and item[i].Data.IEquip then begin
			WFIFOW( 4 +j*20, i);
			WFIFOW( 6 +j*20, item[i].Data.ID);
			WFIFOB( 8 +j*20, item[i].Data.IType);
			WFIFOB( 9 +j*20, item[i].Identify);
			with item[i].Data do begin
				if (tc.JID = 12) and (IType = 4) and (Loc = 2) and
					 ((View = 1) or (View = 2) or (View = 6)) then
					WFIFOW(10 +j*20, 34)
				else
					WFIFOW(10 +j*20, Loc);
			end;
			WFIFOW(12 +j*20, item[i].Equip);
			WFIFOB(14 +j*20, item[i].Attr);
			WFIFOB(15 +j*20, item[i].Refine);
			WFIFOW(16 +j*20, item[i].Card[0]);
			WFIFOW(18 +j*20, item[i].Card[1]);
			WFIFOW(20 +j*20, item[i].Card[2]);
			WFIFOW(22 +j*20, item[i].Card[3]);
			Inc(j);
		end;
	end;
	WFIFOW(2, 4+j*20);
	tc.Socket.SendBuf(buf, 4+j*20);

	//�J�[�g�d�ʁA�e�ʃf�[�^�̑��M
	//0121 <num>.w <num limit>.w <weight>.l <weight limit>l
	WFIFOW(0, $0121);
	WFIFOW(2, Count);
	WFIFOW(4, 100);
	WFIFOL(6, Weight);
	WFIFOL(10, MaxWeight);
	tc.Socket.SendBuf(buf, 14);
  end;
end;
{�J�[�g�@�\�ǉ��R�R�܂�}
//==============================================================================






//==============================================================================
//�l�̃��x���A�b�v�p
procedure CalcLvUP(tc1:TChara; EXP:cardinal; JEXP:cardinal);
var
	j:Integer;
	tm:TMap;
begin
	tm := tc1.MData;

	if DisableLevelLimit or (tc1.BaseLV < 99) then
		tc1.BaseEXP := tc1.BaseEXP + EXP;

	if DisableLevelLimit or ((tc1.JID = 0) and (tc1.JobLV < 10)) or ((tc1.JID <> 0) and (tc1.JobLV < 50)) then
		tc1.JobEXP := tc1.JobEXP + JEXP;

	if tc1.BaseEXP >= tc1.BaseNextEXP then begin
		while tc1.BaseEXP >= tc1.BaseNextEXP do begin

			//�x�[�X���x���A�b�v
			tc1.StatusPoint := tc1.StatusPoint + tc1.BaseLV div 5 + 3;
			Inc(tc1.BaseLV);
			if DisableLevelLimit or (tc1.BaseLV < 99) then begin
				tc1.BaseEXP := tc1.BaseEXP - tc1.BaseNextEXP;
				if (tc1.BaseEXP >= tc1.BaseNextEXP) and (not DisableLevelLimit) then begin
					try
						tc1.BaseEXP := tc1.BaseNextEXP - 1;
					finally
						tc1.BaseEXP := 0;
					end;
				end;
			end else begin
				tc1.BaseEXP := 0;
			end;
			tc1.BaseNextEXP := ExpTable[0][tc1.BaseLV];

		end;
		SendCStat1(tc1, 0, $000b, tc1.BaseLV);
		SendCStat1(tc1, 0, $0009, tc1.StatusPoint);
		CalcStat(tc1);

		tc1.HP := tc1.MaxHP;
		tc1.SP := tc1.MaxSP;
		WFIFOW( 0, $019b);
		WFIFOL( 2, tc1.ID);
		WFIFOL( 6, 0);
		SendBCmd(tm, tc1.Point, 10);
		SendCStat(tc1);
	end else begin
		SendCStat1(tc1, 1, $0001, tc1.BaseEXP);
	end;

	if tc1.JobEXP >= tc1.JobNextEXP then begin
		repeat
			//�W���u���x���A�b�v
			Inc(tc1.SkillPoint);
			Inc(tc1.JobLV);
			if DisableLevelLimit or ((tc1.JID = 0) and (tc1.JobLV < 10)) or ((tc1.JID <> 0) and (tc1.JobLV < 50)) then begin
				tc1.JobEXP := tc1.JobEXP - tc1.JobNextEXP;
				if (tc1.JobEXP >= tc1.JobNextEXP) and (not DisableLevelLimit) then begin
					tc1.JobEXP := tc1.JobNextEXP - 1;
				end;
			end else begin
				tc1.JobEXP := 0;
			end;

			if tc1.JID < 13 then begin
				j := (tc1.JID + 5) div 6 + 1;
			end else begin
				j := 3; //�b��
			end;
			tc1.JobNextEXP := ExpTable[j][tc1.JobLV];

		until tc1.JobEXP < tc1.JobNextEXP;
		SendCStat1(tc1, 0, $0037, tc1.JobLV);
		SendCStat(tc1);
		if tc1.SkillPoint = 1 then
			SendCSkillList(tc1)
		else
			SendCStat1(tc1, 0, $000c, tc1.SkillPoint);
		WFIFOW( 0, $019b);
		WFIFOL( 2, tc1.ID);
		WFIFOL( 6, 1);
		SendBCmd(tm, tc1.Point, 10);
	end else begin
		SendCStat1(tc1, 1, $0002, tc1.JobEXP);
	end;
end;
//------------------------------------------------------------------------------
//�o���l���z�p
procedure PartyDistribution(Map:string; tpa:TParty; EXP:Cardinal = 0; JEXP:Cardinal = 0);
var
	m,l,w:Cardinal;
	i:Integer;
	tc1:TChara;
begin
	Inc(tpa.EXP,EXP);
	Inc(tpa.JEXP,JEXP);
	if tpa.EXPShare = 1 then begin
		m := 1;
		for i := 0 to 11 do begin
			if tpa.MemberID[i] = 0 then Continue;
			tc1 := tpa.Member[i];
			if tc1.Login = 2 then begin
				if tc1.Map = Map then Inc(m);
			end;
		end;

		//l := (tpa.EXP  +  (tpa.EXP div 10) * (m - 1)) div m + 1; //�K���`
		//w := (tpa.JEXP + (tpa.JEXP div 10) * (m - 1)) div m + 1; //�K���`
                {�o�O��655}
                l := (tpa.EXP + 1 + (tpa.EXP div 4) * (m - 2)) div (m - 1);
                w := (tpa.JEXP + 1 + (tpa.JEXP div 4) * (m - 2)) div (m - 1);
                {�o�O��655 �����܂�}
		for i := 0 to 11 do begin
			if tpa.MemberID[i] = 0 then Continue;
			tc1 := tpa.Member[i];
			if tc1.Login = 2 then begin
				if tc1.Map = Map then CalcLvUP(tc1,l,w);
			end;
		end;
		tpa.EXP := 0;
		tpa.JEXP:= 0;
	end;
end;
{�ǉ��R�R�܂�}
//------------------------------------------------------------------------------
{�p�[�e�B�[�@�\�ǉ�}
procedure SendPartyList(tc:TChara);//tc�������Ƃ��ė^����ƃp�[�e�B�[�����X�V���APTM�ɒʒm����
var
	i,j,k :integer;
	tpa   :TParty;
begin
	i := PartyNameList.IndexOf(tc.PartyName);
	if (i <> -1) then begin
		tpa := PartyNameList.Objects[i] as TParty;

		tpa.MinLV := 99;
		tpa.MaxLV := 1;
		i := 0;
		//�p�[�e�B�[�����o�[�̐���(�p�[�e�B�[�ɓ������܂܍폜���ꂽ�L�����N�^�[�̓p�[�e�B�[������폜����)
		while (i >= 0) and (i <= 11) do begin
			if (tpa.MemberID[i] <> 0) and (Chara.IndexOf(tpa.MemberID[i]) = -1) then begin
				for j := i to 10 do begin
					tpa.MemberID[j] := tpa.MemberID[j+1];
					tpa.Member[j] := tpa.Member[j+1];
				end;
					tpa.MemberID[11] := 0;
					tpa.Member[11] := nil;
					Dec(i);
			end;
			Inc(i);
		end;

		//�p�[�e�B�[���̑��M(00FB�p�P�b�g)
		j := 28;
		for k := 0 to 11 do begin
			//DebugOut.Lines.Add(Format('k = %d : tpa.MemberID = %d', [k,tpa.MemberID[k]]));
			if (tpa.MemberID[k] = 0) then break;
			if (tpa.Member[k].Login = 2) and (tpa.Member[k].BaseLV < tpa.MinLV) then tpa.MinLV := tpa.Member[k].BaseLV;//�p�[�e�B�[�ō����x��
			if (tpa.Member[k].Login = 2) and (tpa.Member[k].BaseLV > tpa.MaxLV) then tpa.MaxLV := tpa.Member[k].BaseLV;//�p�[�e�B�[�Œ჌�x��
			WFIFOL(j, tpa.Member[k].ID);
			WFIFOS(j+4, tpa.Member[k].Name, 24);
			WFIFOS(j+28, tpa.Member[k].Map + '.gat', 16);
			if (k = 0) then begin
				WFIFOB(j+44, 0);//���[�_�[
			end else begin
				WFIFOB(j+44, 1);//�񃊁[�_�[
			end;
			//WFIFOB(j+44, 1);
			//WFIFOB(j+45, tpa.Member[k].Login);
			if (tpa.Member[k].Login = 2) then begin
				WFIFOB(j+45, 0);//�I�����C��
			end else begin
				WFIFOB(j+45, 1);//�I�t���C��
			end;
			//DebugOut.Lines.Add(Format('k = %d : ID = %d : Name = %s : Map = %s ', [k, tpa.Member[k].ID, tpa.Member[k].Name, tpa.Member[k].Map]));
			j := j + 46;
		end;
		WFIFOW(0, $00fb);
		WFIFOW(2, j);
		WFIFOS(4, tpa.Name, 24);
		SendPCmd(tc, j);

		//�p�[�e�B�[���L�ݒ�̑��M(0101�p�P�b�g)
		//�����̌����\���x����ini����ǂ݂��݂ɂ���Ƃ�������
		if (tpa.MaxLV - tpa.MinLV > 10) and (tpa.EXPShare = 1) then begin
			tpa.EXPShare := 0;//�����\���x���𒴂��Ă����疳�����Ɍʎ擾�ɂ���
		end;
		WFIFOW(0, $0101);
		WFIFOW(2, tpa.EXPShare);
		WFIFOW(4, tpa.ITEMShare);
		SendPCmd(tc, 6);

		for i := 0 to 11 do begin
			if (tpa.MemberID[i] = 0) then break;
			//�p�[�e�B�[�����o�[��HP�o�[�\��
			WFIFOW( 0, $0106);
			WFIFOL( 2, tpa.Member[i].ID);
			WFIFOW( 6, tpa.Member[i].HP);
			WFIFOW( 8, tpa.Member[i].MAXHP);
			SendPCmd(tpa.Member[i], 10, true, true);//����}�b�v���̎����ȊO��PTM�ɑ���

			//�p�[�e�B�[�����o�[�̈ʒu�\��
			WFIFOW( 0, $0107);
			WFIFOL( 2, tpa.Member[i].ID);
			WFIFOW( 6, tpa.Member[i].Point.X);
			WFIFOW( 8, tpa.Member[i].Point.Y);
			SendPCmd(tpa.Member[i], 10, true, true);//����}�b�v���̎����ȊO��PTM�ɑ���
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure SendPCmd(tc:TChara; PacketLen:word; InMap:boolean = false; AvoidSelf:boolean = false);
//�p�[�e�B�[�����o�[�ɓ���p�P�b�g�𑗂����
//InMap��true���}�b�v���̃����o�[�݂̂Ƀp�P�b�g���M(�ʒu�\����HP�o�[�Ȃ�)
//AvoidSelf��true���������g�����������o�[�Ƀp�P�b�g���M
var
	i	:integer;
	tc1	:TChara;
	tpa	:Tparty;
begin
	i := PartyNameList.IndexOf(tc.PartyName);
	if (i <> -1) then begin
		tpa := PartyNameList.Objects[i] as TParty;
		for i := 0 to 11 do begin
			if tpa.MemberID[i] = 0 then break;
			if Chara.IndexOf(tpa.MemberID[i]) = -1 then Continue;
			tc1 := tpa.Member[i];
			if tc1.Login <> 2 then Continue;
			if (tc.Map = tc1.Map) or (InMap = false) then begin
				if (tc.ID = tc1.ID) and (AvoidSelf = true) then continue;
				tc1.Socket.SendBuf(buf, PacketLen);
				//DebugOut.Lines.Add(Format('Send to ID %d : Length %d ', [tc1.ID, PacketLen]));
			end;
		end;
	end;
end;
{�p�[�e�B�[�@�\�ǉ��R�R�܂�}
//==============================================================================






//==============================================================================
{�`���b�g���[���@�\�ǉ�}
procedure ChatRoomExit(tc:TChara; AvoidSelf:boolean = false);
//�`���b�g���[�����烁���o�[���폜����
//AvoidSelf��true���������g�����������o�[�Ƀp�P�b�g���M
var
	i	:integer;
	j	:integer;
	l	:cardinal;
	w	:word;
	str	:string;
	tcr	:TChatRoom;
begin
	i := ChatRoomList.IndexOf(tc.ChatRoomID);
	if (i <> -1) then begin
		tcr := ChatRoomList.Objects[i] as TChatRoom;
		j := -1;
		for i := 0 to 19 do begin;
			if tc.ID = tcr.MemberID[i] then begin
				j := i;
				break;
			end;
		end;

		if (j = -1) then exit;
		if (j = 0) and (tcr.Users > 1) then begin
			//�I�[�i�[�����̏ꍇ�̃_�~�[���M
			WFIFOW( 0, $00e1);
			WFIFOL( 2, 1);
			WFIFOS( 6, tcr.MemberName[0], 24);
			SendCrCmd(tc, 30, true);

			WFIFOW( 0, $00e1);
			WFIFOL( 2, 0);
			WFIFOS( 6, tcr.MemberName[1], 24);
			SendCrCmd(tc, 30, true);
		end;

		//�����郁���o�[�����X�g�̌��ɔz�u
		if (tcr.Users > 1) then begin
			l := tcr.MemberID[j];
			str := tcr.MemberName[j];
			if (j <= 18) and (j <> tcr.Users - 1) then begin
				for i := j to tcr.Users - 2 do begin
					tcr.MemberID[i] := tcr.MemberID[i+1];
					tcr.MemberCID[i] := tcr.MemberCID[i+1];
					tcr.MemberName[i] := tcr.MemberName[i+1];
				end;
				tcr.MemberID[tcr.Users - 1] := l;
				tcr.MemberCID[tcr.Users - 1] := l;
				tcr.MemberName[tcr.Users - 1] := str;
			end;
		end;

		//�`���b�g�����ʒm
		WFIFOW( 0, $00dd);
		WFIFOW( 2, tcr.Users - 1);
		WFIFOS( 4, tc.Name, 24);
		WFIFOB(28, 0);
		SendCrCmd(tc, 29, AvoidSelf);

		tcr.Users := tcr.Users - 1;
		tcr.MemberID[tcr.Users] := 0;
		tcr.MemberCID[tcr.Users] := 0;
		tcr.MemberName[tcr.Users] := '';
		//DebugOut.Lines.Add(Format('%s Leaves %s', [tc.Name ,tcr.Title]));

		if (tcr.Users = 0) then begin
			//�󎺃`���b�g��
			WFIFOW( 0, $00d8);
			WFIFOL( 2, tcr.ID);
			SendNCrCmd(tc.MData, tc.Point, 6, tc, true);
			//DebugOut.Lines.Add(Format('ChatRoom(%s) was deleted / Remaining ChatRoom(%d)', [tcr.Title,ChatRoomList.Count-1]));
			ChatRoomList.Delete(ChatRoomList.IndexOf(tcr.ID));
			tcr.Free;
		end else begin
			if (j = 0) then begin
				//�I�[�i�[�ύX�`���b�g����
				WFIFOW( 0, $00d8);
				WFIFOL( 2, tcr.ID);
				SendNCrCmd(tc.MData, tc.Point, 6, tc, true);
			end;

			//���͂ɃX�e�[�^�X�X�V
			w := Length(tcr.Title);
			WFIFOW(0, $00d7);
			WFIFOW(2, w + 17);
			WFIFOL(4, tcr.MemberID[0]);
			WFIFOL(8, tcr.ID);
			WFIFOW(12, tcr.Limit);
			WFIFOW(14, tcr.Users);
			WFIFOB(16, tcr.Pub);
			WFIFOS(17, tcr.Title, w);
			SendNCrCmd(tc.MData, tc.Point, w + 17, tc, AvoidSelf);
		end;
		tc.ChatRoomID := 0;
	end;
end;
//------------------------------------------------------------------------------
procedure ChatRoomDisp(Socket: TCustomWinSocket; tc1:TChara);
//���ӂ̃`���b�g���[����\������
var
	i	:integer;
	w	:word;
	tcr	:TChatRoom;
begin
	if (tc1.ChatRoomID <> 0) then begin
		i := ChatRoomList.IndexOf(tc1.ChatRoomID);
		if (i <> -1) then begin
			tcr := ChatRoomList.Objects[i] as TChatRoom;
			if (tc1.ID = tcr.MemberID[0]) then begin
				w := Length(tcr.Title);
				WFIFOW(0, $00d7);
				WFIFOW(2, w + 17);
				WFIFOL(4, tcr.MemberID[0]);
				WFIFOL(8, tcr.ID);
				WFIFOW(12, tcr.Limit);
				WFIFOW(14, tcr.Users);
				WFIFOB(16, tcr.Pub);
				WFIFOS(17, tcr.Title, w);
				if Socket <> nil then begin
					Socket.SendBuf(buf, w + 17);
				end;
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure SendCrCmd(tc:TChara; PacketLen:word; AvoidSelf:boolean = false);
//�`���b�g���[�������o�[�ɓ���p�P�b�g�𑗂����
//AvoidSelf��true���������g�����������o�[�Ƀp�P�b�g���M
var
	i	:integer;
	tc1	:TChara;
	tcr	:TChatRoom;
begin
	i := ChatRoomList.IndexOf(tc.ChatRoomID);
	if (i <> -1) then begin
		tcr := ChatRoomList.Objects[i] as TChatRoom;
		for i := 0 to 19 do begin
			if tcr.MemberID[i] = 0 then break;
			if Chara.IndexOf(tcr.MemberCID[i]) = -1 then Continue;
			tc1 := Chara.IndexOfObject(tcr.MemberCID[i]) as TChara;
			if tc1 = nil then continue;
			if (tc.ID = tc1.ID) and (AvoidSelf = true) then continue;
			if (tc1.Socket <> nil) then begin
				tc1.Socket.SendBuf(buf, PacketLen);
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure SendNCrCmd(tm:TMap; Point:TPoint; PacketLen:word; tc:TChara = nil; AvoidSelf:boolean = false; AvoidChat:boolean = false);
//�`���b�g���[�������o�[�ȊO�ɓ���p�P�b�g�𑗂����
//AvoidSelf��true�������ȊO�Ƀp�P�b�g���M
//AvoidChat��true���S�`���b�g���[�����������o�[�ȊO�Ƀp�P�b�g���M
var
	i	:integer;
	j	:integer;
	k	:integer;
	tc1	:TChara;
begin
	for j := Point.Y div 8 - 2 to Point.Y div 8 + 2 do begin
		for i := Point.X div 8 - 2 to Point.X div 8 + 2 do begin
			for k := 0 to tm.Block[i][j].CList.Count - 1 do begin
				tc1 := tm.Block[i][j].CList.Objects[k] as TChara;
				if tc1 = nil then continue;
				if (tc.ID = tc1.ID) and (AvoidSelf = true) then continue;
				if (tc1.ChatRoomID <> 0) and (AvoidChat = true) then continue;
				if (tc1.ChatRoomID <> 0) and (tc1.ChatRoomID = tc.ChatRoomID) and (tc.ID <> tc1.ID) then continue;
				if (abs(Point.X - tc1.Point.X) < 16) and (abs(Point.Y - tc1.Point.Y) < 16) and
					(tc1.Socket <> nil) then begin
					tc1.Socket.SendBuf(buf, PacketLen);
				end;
			end;
		end;
	end;
end;
{�`���b�g���[���@�\�ǉ��R�R�܂�}
//==============================================================================
{�I�X�X�L���ǉ�}
procedure VenderExit(tc:TChara; AvoidSelf:boolean = false);
//�I�X���I������
//AvoidSelf��true���������g�����������o�[�Ƀp�P�b�g���M
var
	i	:integer;
	j	:integer;
	tv  :TVender;
begin
	if (tc.VenderID <> 0) then begin
		i := VenderList.IndexOf(tc.VenderID);
		if (i <> -1) then begin
			tv := VenderList.Objects[i] as TVender;

			if (AvoidSelf = false) then begin
				//�J�[�g�ɃA�C�e����߂�
				for j := 0 to tv.MaxCnt - 1 do begin
					if (tv.Idx[j] <> 0) then begin
						WFIFOW( 0, $0124);
						WFIFOW( 2, tv.Idx[j]);
						WFIFOL( 4, tv.Amount[j]);
						WFIFOW( 8, tc.Cart.Item[tv.Idx[j]].ID);
						WFIFOB(10, tc.Cart.Item[tv.Idx[j]].Identify);
						WFIFOB(11, tc.Cart.Item[tv.Idx[j]].Attr);
						WFIFOB(12, tc.Cart.Item[tv.Idx[j]].Refine);
						WFIFOW(13, tc.Cart.Item[tv.Idx[j]].Card[0]);
						WFIFOW(15, tc.Cart.Item[tv.Idx[j]].Card[1]);
						WFIFOW(17, tc.Cart.Item[tv.Idx[j]].Card[2]);
						WFIFOW(19, tc.Cart.Item[tv.Idx[j]].Card[3]);
						tc.Socket.SendBuf(buf, 21);
					end;
				end;

				//�J�[�g�̏d�ʕ\���X�V
				WFIFOW(0, $0121);
				WFIFOW(2, tc.Cart.Count);
				WFIFOW(4, 100);
				WFIFOL(6, tc.Cart.Weight);
				WFIFOL(10, tc.Cart.MaxWeight);
				tc.Socket.SendBuf(buf, 14);
			end;

			//�Ŕ��������͂ɒʒm
			WFIFOW(0, $0132);
			WFIFOL(2, tv.ID);
			SendBCmd(tc.Mdata, tc.Point, 6, tc);
			tc.VenderID := 0;

			//�I�X���X�g�폜
			//DebugOut.Lines.Add(Format('Vender(%s) was close / Remaining Vender(%d)', [tv.Title,VenderList.Count-1]));
			VenderList.Delete(VenderList.IndexOf(tv.ID));
			tv.Free;
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure VenderDisp(Socket: TCustomWinSocket; tc1:TChara);
//���ӂ̘I�X��\������
var
	i	:integer;
	tv	:TVender;
begin
	if (tc1.VenderID <> 0) then begin
		i := VenderList.IndexOf(tc1.VenderID);
		if (i <> -1) then begin
			tv := VenderList.Objects[i] as TVender;
			WFIFOW(0, $0131);
			WFIFOL(2, tv.ID);
			WFIFOS(6, tv.Title, 80);
			Socket.SendBuf(buf, 86);
		end;
	end;
end;
{�I�X�X�L���ǉ��R�R�܂�}
//==============================================================================
{����@�\�ǉ�}
procedure CancelDealings(tc:TChara; AvoidSelf:boolean = false);
//������L�����Z������
//AvoidSelf��true���������g�̏����s�v
var
	i	:integer;
	j	:integer;
	k	:integer;
	l	:cardinal;
	td  :TItemDB;
	tdl	:TDealings;
begin
	if (tc.DealingID <> 0) then begin
		i := DealingList.IndexOf(tc.DealingID);
		if (i <> -1) then begin
			tdl := DealingList.Objects[i] as TDealings;
			for k := 0 to 1 do begin
				if (k = 0) then begin
					tc.DealingID := 0;
					if (tdl.UserID[0] = tc.ID) then l := 0 else l := 1;
					if (AvoidSelf = true) then continue;
				end else begin
					if (l = 0) then l := 1 else l := 0;
					tc := CharaPID.IndexOfObject(tdl.UserID[l]) as TChara;
					if (tc = nil) then continue;
					tc.DealingID := 0;
				end;

				//�A�C�e���Ԋ�
				if (tdl.Cnt[l] <> 0) then begin
					for i := 0 to tdl.Cnt[l] - 1 do begin
						if (tc.Item[tdl.ItemIdx[l][i]].ID = 0) then break;
						td := tc.Item[tdl.ItemIdx[l][i]].Data;
						j := SearchCInventory(tc, td.ID, td.IEquip);
						SendCGetItem(tc, j, tdl.Amount[l][i]);
					end;
				end;
				if (tdl.Zeny[l] <> 0) then begin
					//�[�j�[�Ԋ�
					WFIFOW(0, $00b1);
					WFIFOW(2, $0014);
					WFIFOL(4, tc.Zeny);
					tc.Socket.SendBuf(buf, 8);
				end;
				//����L�����Z���p�P
				WFIFOW(0, $00ee);
				tc.Socket.SendBuf(buf, 2);
			end;
			//DebugOut.Lines.Add(Format('Dealings(%d) was canceled / Remaining Dealings(%d)', [tdl.ID,DealingList.Count-1]));
			DealingList.Delete(DealingList.IndexOf(tdl.ID));
			tdl.Free;
		end;
	end;
end;
{����@�\�ǉ��R�R�܂�}
//==============================================================================
{NPC�C�x���g�ǉ�}
function ConvFlagValue(tc:TChara; str:string; mode:boolean = false) : Integer;
// �X�N���v�g�t���O��ϊ�����
// mode=true���̓G���[�̏ꍇ��-1��Ԃ�
var
	i	:integer;
	j	:integer;
begin
	if (Copy(str, 1, 1) <> '\') then begin
		Val(str, i, j);
		if j <> 0 then begin
			Val(tc.Flag.Values[str], i, j);
			if j <> 0 then begin
				if mode = true then i := -1 else i := 0;
			end;
		end;
	end else begin
		Val(ServerFlag.Values[str], i, j);
		if (j <> 0) then begin
			if mode = true then i := -1 else i := 0;
		end;
	end;
	Result := i;
end;
{NPC�C�x���g�ǉ��R�R�܂�}
//==============================================================================
{�M���h�@�\�ǉ�}
procedure SendGuildInfo(tc:TChara; Tab:Byte; GuildM:boolean = false; AvoidSelf:boolean = false);
//�M���h���𑗐M����
//GuildM=true���̓M���h�����o�[�S���ɑ��M����
var
	i   :integer;
	j   :integer;
	k   :integer;
	w   :word;
	tc1 :TChara;
	tg  :TGuild;
	tgb :TGBan;
begin
	if (Tab > 5) then exit;
	j := GuildList.IndexOf(tc.GuildID);
	if (j = -1) then exit;
	tg := GuildList.Objects[j] as TGuild;
	with tg do begin
		case Tab of
		0: //�M���h��{���
			begin
				WFIFOW( 0, $01b6);
				WFIFOL( 2, ID);
				WFIFOL( 6, LV);
				WFIFOL(10, GetGuildConUsers(tg));
				WFIFOL(14, MaxUsers);
				WFIFOL(18, SLV div RegUsers);
				WFIFOL(22, EXP);
				WFIFOL(26, NextEXP);
				WFIFOL(30, Present);
				Move(DisposFV, buf[34], 4);
				Move(DisposRW, buf[38], 4);
				WFIFOL(42, 2);//members?
				WFIFOS(46, Name, 24);
				WFIFOS(70, MasterName, 24);
				WFIFOS(94, Agit, 20);
				if (GuildM = false) then tc.Socket.SendBuf(buf, 114)
				else SendGuildMCmd(tc, 114, AvoidSelf);
				//�����E�G�Ώ��
				i :=GetGuildRelation(tg, tc);
				if (i <> -1) then begin
					if (GuildM = false) then tc.Socket.SendBuf(buf, i)
					else SendGuildMCmd(tc, i, AvoidSelf);
				end;
			end;
		1: //�M���h�����
			begin
				//�E�ʏ��
				w := 28 * 20 + 4;
				WFIFOW( 0, $0166);
				WFIFOW( 2, w);
				for i := 0 to 19 do begin
					WFIFOL(i * 28 + 4, i);
					WFIFOS(i * 28 + 8, PosName[i], 24);
				end;
				if (GuildM = false) then tc.Socket.SendBuf(buf, w)
				else SendGuildMCmd(tc, w, AvoidSelf);
				//�����o�[���
				w := 4;
				WFIFOW( 0, $0154);
				for i := 0 to 35 do begin
					tc1 := Member[i];
					if (tc1 <> nil) then begin
						WFIFOL(w      , tc1.ID);
						WFIFOL(w +   4, tc1.CID);
						WFIFOW(w +   8, tc1.Hair);
						WFIFOW(w +  10, tc1.HairColor);
						WFIFOW(w +  12, tc1.Gender);
						WFIFOW(w +  14, tc1.JID);
						WFIFOW(w +  16, tc1.BaseLV);
						WFIFOL(w +  18, MemberEXP[i]);
						if (tc1.Login = 2) then k := 1 else k := 0;
						WFIFOL(w +  22, k);
						WFIFOL(w +  26, MemberPos[i]);
						WFIFOS(w +  30, '', 50);//?
						WFIFOS(w +  80, tc1.Name, 24);
						w := w + 104;
					end;
				end;
				WFIFOW( 2, w);
				if (GuildM = false) then tc.Socket.SendBuf(buf, w)
				else SendGuildMCmd(tc, w, AvoidSelf);
			end;
		2: //�E�ʐݒ�
			begin
				//�E�ʏ��
				w := 28 * 20 + 4;
				WFIFOW( 0, $0166);
				WFIFOW( 2, w);
				for i := 0 to 19 do begin
					WFIFOL( 4 + i * 28, i);
					WFIFOS( 8 + i * 28, PosName[i], 24);
				end;
				if (GuildM = false) then tc.Socket.SendBuf(buf, w)
				else SendGuildMCmd(tc, w, AvoidSelf);
				//��������[
				w := 16 * 20 + 4;
				WFIFOW( 0, $0160);
				WFIFOW( 2, w);
				for i := 0 to 19 do begin
					WFIFOL( 4 + i * 16, i);
					if (PosInvite[i] = true) then j := 16 else j := 0;
					if (PosPunish[i] = true) then j := j + 1;
					WFIFOL( 8 + i * 16, j);
					WFIFOL(12 + i * 16, i);
					WFIFOL(16 + i * 16, PosEXP[i]);
				end;
				if (GuildM = false) then tc.Socket.SendBuf(buf, w)
				else SendGuildMCmd(tc, w, AvoidSelf);
			end;
		3: //�M���h�X�L��
			begin
				w := 37 * 5 + 6;
				j := 0;
				WFIFOW( 0, $0162);
				WFIFOW( 2, w);
				WFIFOW( 4, GSkillPoint);
				for i := 10000 to 10004 do begin
					WFIFOW( 6 + 37 * j, i);
					WFIFOW( 8 + 37 * j, 0);
					WFIFOW(10 + 37 * j, 0);
					WFIFOW(12 + 37 * j, GSkill[i].Lv);
					WFIFOW(14 + 37 * j, 0);
					WFIFOW(16 + 37 * j, 0);
					WFIFOS(18 + 37 * j, GSkill[i].Data.IDC, 24);
                                        WFIFOB(42 + 37 * j, 1);
					Inc(j);
				end;
				if (GuildM = false) then tc.Socket.SendBuf(buf, w)
				else SendGuildMCmd(tc, w, AvoidSelf);
			end;
		4: //�Ǖ��҃��X�g
			begin
				if (GuildBanList.Count > 0) then begin
					w := 4;
					WFIFOW( 0, $0163);
					for i := 0 to GuildBanList.Count - 1 do begin
						tgb := GuildBanList.Objects[i] as TGBan;
						WFIFOS(w     , tgb.Name, 24);
						WFIFOS(w + 24, tgb.AccName, 24);
						WFIFOS(w + 48, tgb.Reason, 40);
						Inc(w, 88);
					end;
					WFIFOW( 2, w);
					SendGuildMCmd(tc, w);
				end;
			end;
		5: //���m����
			begin
				//�s�v
			end;
		end;
	end;
end;
//------------------------------------------------------------------------------
procedure SendGuildMCmd(tc:TChara; PacketLen:word; AvoidSelf:boolean = false);
//�M���h�����o�[�ɓ���p�P�b�g�𑗂����
//AvoidSelf��true���������g�����������o�[�Ƀp�P�b�g���M
var
	i   :integer;
	j   :integer;
	tc1 :TChara;
	tg  :TGuild;
begin
	j := GuildList.IndexOf(tc.GuildID);
	if (j = -1) then exit;
	tg := GuildList.Objects[j] as TGuild;
	for i := 0 to tg.RegUsers - 1 do begin
		if tg.MemberID[i] = 0 then break;
		if Chara.IndexOf(tg.MemberID[i]) = -1 then break;
		tc1 := tg.Member[i];
		if tc1.Login <> 2 then continue;
		if (tc.ID = tc1.ID) and (AvoidSelf = true) then continue;
		tc1.Socket.SendBuf(buf, PacketLen);
	end;
end;
//------------------------------------------------------------------------------
procedure CalcGuildLvUP(tg:TGuild; tc:TChara; GEXP:cardinal);
begin
	tg.EXP := tg.EXP + GEXP;
	tg.MemberEXP[tc.GuildPos] := tg.MemberEXP[tc.GuildPos] + GEXP;

        if (tg.EXP >= GExpTable[tg.LV]) then begin
                while (tg.EXP >= GExpTable[tg.LV]) do begin
			tg.EXP := tg.EXP - GExpTable[tg.LV];
			if (tg.LV < 50) then begin
				tg.LV := tg.LV + 1;
				tg.GSkillPoint := tg.GSkillPoint + 1;
			end;
		end;
		SendGuildInfo(tc, 3, true);
	end;
	SendGuildInfo(tc, 0, true);
	SendGuildInfo(tc, 1, true);
end;
//------------------------------------------------------------------------------
procedure SendGLoginInfo(tg:TGuild; tc:TChara);
//���O�C�����̃M���h���𑗐M����
var
	l :word;
begin
	WFIFOW( 0, $016c);
	WFIFOL( 2, tg.ID);
	WFIFOL( 6, tg.Emblem);
	if (tg.PosInvite[tc.GuildPos] = true) then l := 16 else l := 0;
	if (tg.PosPunish[tc.GuildPos] = true) then l := l + 1;
	WFIFOL(10, l);
	if (tc.Name = tg.MasterName) then WFIFOB(14, 1) else WFIFOB(14, 0);
	WFIFOL(15, 1);//?
	WFIFOS(19, tg.Name, 24);
	tc.Socket.SendBuf(buf, 43);
end;
//------------------------------------------------------------------------------
function GetGuildConUsers(tg:TGuild) : word;
//���O�C�����̃M���h�����o�[�����擾����
var
	i  :integer;
	w  :word;
begin
	w := 0;
	for i := 0 to 35 do begin
		if (tg.Member[i] <> nil) then begin
			if (tg.Member[i].Login = 2) then Inc(w);
		end;
	end;
	Result := w;
end;
//------------------------------------------------------------------------------
procedure ClaimGuildCastle(ID:cardinal;MapName:string);
var
	i  :integer;
  tg :TGuild;
  tgc:TCastle;
begin
i := GuildList.IndexOf(ID);
if (i <> -1) then begin
tg := GuildList.Objects[i] as TGuild;
tgc := TCastle.Create;
		with tgc do begin
			Name := MapName;
      GID  := tg.ID;
      GName:= tg.Name;
      GMName:=tg.MasterName;
      GKafra:=0;
      EDegree:=0;
      ETrigger:=0;
      DDegree:=0;
      DTrigger:=0;
      for i := 0 to 7 do begin
      GuardStatus[i] := 0;
      end;
		end;
CastleList.AddObject(tgc.Name, tgc);
end;
end;
//------------------------------------------------------------------------------
procedure EnableGuildKafra(MapName:string;KafraName:string;Mode:integer);
var
	i,j,k,l,m,n  :integer;
  tg           :TGuild;
  tgc          :TCastle;
  tm           :TMap;
  tm1          :TMap;
  tn1          :TNPC;
  tc1          :TChara;
begin
					if Map.IndexOf(MapName) = -1 then
						MapLoad(MapName);
					tm1 := Map.Objects[Map.IndexOf(MapName)] as TMap;
          tm := Map.Objects[Map.IndexOf(MapName)] as TMap;
					if (Mode = 1) then begin
						//enable
						i := -1;
						for k := 0 to tm1.NPC.Count - 1 do begin
							tn1 := tm1.NPC.Objects[k] as TNPC;
							if (tn1.Name = KafraName) then begin
								i := 0;
								break;
							end;
						end;
						//if (tn1.ScriptInitS <> -1) then begin
							//OnInit���x�������s
							//DebugOut.Lines.Add(Format('OnInit Event(%d)', [tn1.ID]));
							//tc1 := TChara.Create;
							//tc1.TalkNPCID := tn1.ID;
							//tc1.ScriptStep := tn1.ScriptInitS;
							//tc1.AMode := 3;
							//tc1.AData := tn1;
							//tc1.Login := 0;
							//NPCScript(tc1,0,1);
							//tn.ScriptInitD := true;
							//tc1.Free;
						//end;
						if (i = 0) and (tn1.Enable = false) then begin
							tn1.Enable := true;
							for j := tn1.Point.Y div 8 - 2 to tn1.Point.Y div 8 + 2 do begin
								for i := tn1.Point.X div 8 - 2 to tn1.Point.X div 8 + 2 do begin
									for k := 0 to tm1.Block[i][j].CList.Count - 1 do begin
										tc1 := tm1.Block[i][j].Clist.Objects[k] as TChara;
										if (abs(tc1.Point.X - tn1.Point.X) < 16) and (abs(tc1.Point.Y - tn1.Point.Y) < 16) then begin
											SendNData(tc1.Socket, tn1, tc1.ver2);
										end;
									end;
								end;
							end;
						end;
					end else begin
						//disable
						i := -1;
						for k := 0 to tm1.NPC.Count - 1 do begin
							tn1 := tm1.NPC.Objects[k] as TNPC;
							if (tn1.Name = KafraName) then begin
								i := 0;
								break;
							end;
						end;
						if (i = 0) and (tn1.Enable = true) then begin
							tn1.Enable := false;
							l := tm.TimerAct.IndexOf(tn1.ID);
							if (l <> -1) then begin
								//DebugOut.Lines.Add(Format('NPC Timer(%d) was deleted / Remaining Timer(%d)', [tn1.ID,tm.TimerAct.Count-1]));
								tm.TimerAct.Delete(tm.TimerAct.IndexOf(tn1.ID));
							end;
							for j := tn1.Point.Y div 8 - 2 to tn1.Point.Y div 8 + 2 do begin
								for i := tn1.Point.X div 8 - 2 to tn1.Point.X div 8 + 2 do begin
									for k := 0 to tm1.Block[i][j].CList.Count - 1 do begin
										tc1 := tm1.Block[i][j].Clist.Objects[k] as TChara;
										if (abs(tc1.Point.X - tn1.Point.X) < 16) and (abs(tc1.Point.Y - tn1.Point.Y) < 16) then begin
											WFIFOW(0, $0080);
											WFIFOL(2, tn1.ID);
											WFIFOB(6, 0);
											tc1.Socket.SendBuf(buf, 7);
										end;
									end;
								end;
							end;
						end;
					end;
				end;
//------------------------------------------------------------------------------
function GetGuildKafra(tn:TNPC) : integer;
var
  tgc:TCastle;
  i  :integer;
	w  :integer;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.GKafra;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
procedure SetGuildKafra(tn:TNPC;mode:integer);
var
  tgc:TCastle;
  i  :integer;
begin
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  tgc.GKafra := mode;
  end;

end;
//------------------------------------------------------------------------------
procedure SpawnNPCMob(tn:TNPC;MobName:string;X:integer;Y:integer;SpawnDelay1:cardinal;SpawnDelay2:cardinal);
var
  i,j,k :integer;
  m     :integer;
  ts    :TMob;
  tm    :TMap;
  te    :TEmp;
  tgc   :TCastle;
begin
          //DebugOut.Lines.Add(MobName);
          tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
          ts := TMob.Create;
					ts.Data := MobDBName.Objects[MobDBName.IndexOf(MobName)] as TMobDB;
					ts.ID := NowMobID;
					Inc(NowMobID);
					ts.Name := ts.Data.JName;
					ts.JID := ts.Data.ID;
					ts.Map := tn.Map;
          ts.Data.isLink :=false;
          ts.NPCID := tn.ID;

          if (X = 0) and (Y = 0) then begin
          repeat
					ts.Point.X := Random(tm.Size.X - 2);
					ts.Point.Y := Random(tm.Size.y - 2);
          until ( (tm.gat[ts.Point.X][ts.Point.Y] <> 1) and (tm.gat[ts.Point.X][ts.Point.Y] <> 5) );
          end else begin
					ts.Point.X := X;
					ts.Point.Y := Y;
          end;

					ts.Dir := Random(8);
					ts.HP := ts.Data.HP;
					ts.Speed := ts.Data.Speed;

					ts.SpawnDelay1 := SpawnDelay1;
					ts.SpawnDelay2 := SpawnDelay2;

					ts.SpawnType := 0;
					ts.SpawnTick := 0;

					ts.ATarget := 0;
					ts.ATKPer := 100;
					ts.DEFPer := 100;
					ts.DmgTick := 0;

          ts.Element := ts.Data.Element;

          ts.Name := ts.Data.JName;

					ts.Data.MEXP := 0;
					ts.Data.EXP := 0;
					ts.Data.JEXP := 0;

           ts.isLooting := False;
  						for j:= 1 to 10 do begin
								ts.Item[j].ID := 0;
								ts.Item[j].Amount := 0;
								ts.Item[j].Equip := 0;
								ts.Item[j].Identify := 0;
								ts.Item[j].Refine := 0;
								ts.Item[j].Attr := 0;
								ts.Item[j].Card[0] := 0;
								ts.Item[j].Card[1] := 0;
								ts.Item[j].Card[2] := 0;
								ts.Item[j].Card[3] := 0;
						  end;
              if ts.Data.isDontMove then
              ts.MoveWait := 4294967295
              else
              ts.MoveWait := TimeGetTime() + 5000 + Cardinal(Random(10000));

              if (ts.JID = 1288) then begin
              ts.isEmperium := true;
              m := CastleList.IndexOf(ts.Map);
              if (m <> - 1) then begin
              tgc := CastleList.Objects[m] as TCastle;
              ts.GID := tgc.GID;
              end;
              k := EmpList.IndexOf(ts.Map);
              if (k = -1) then begin
              te := TEmp.Create;
		          with te do begin
              Map := ts.Map;
              EID := ts.ID;
              end;
		          EmpList.AddObject(te.Map, te);
              end;
              end;

          ts.isActive := ts.Data.isActive;

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
          ts.isSummon := True;

					tm.Mob.AddObject(ts.ID, ts);
					tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.AddObject(ts.ID, ts);

					//SendMData(tc.Socket, ts);
					//SendBCmd(tm,ts.Point,41,tc,False);
end;
//------------------------------------------------------------------------------
function CheckGuildID(tn:TNPC; tc:TChara) : word;
var
  tgc:TCastle;
  i  :integer;
	w  :word;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  if (tgc.GID = tc.GuildID) then begin
  w := 1;
  end;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function CheckGuildMaster(tn:TNPC; tc:TChara) : word;
var
  tgc:TCastle;
  i  :integer;
	w  :word;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  if (tgc.GMName = tc.Name) then begin
  w := 1;
  end;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildID(tn:TNPC) : word;
var
  tgc:TCastle;
  i  :integer;
	w  :word;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.GID;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
procedure GuildDInvest(tn:TNPC);
var
  tgc:TCastle;
  i,k  :integer;
  ts  :TMob;
  tm  :TMap;
begin
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  tm := Map.Objects[Map.IndexOf(tn.Reg)] as TMap;
  if (tgc.DTrigger < 2) then begin
  tgc.DDegree := tgc.DDegree + 10000;
  tgc.DTrigger := tgc.DTrigger + 1;
  for k := 0 to tm.Mob.Count - 1  do begin
  ts := tm.Mob.Objects[k] as TMob;
  if (ts.isGuardian = tgc.GID) then begin
  ts.HP := ts.HP + 2000;
  end;
  end;
  end;
  end;
  
end;
//------------------------------------------------------------------------------
procedure CallGuildGuard(tn:TNPC;guard:integer);
var
  tgc        :TCastle;
  i,j,k,l,m  :integer;
  ts         :TMob;
  tm         :TMap;
  te         :TEmp;
begin
          //guard := guard - 1;
          tm := Map.Objects[Map.IndexOf(tn.Map)] as TMap;
	        j := CastleList.IndexOf(tm.Name);
          if (j <> - 1) then begin
          tgc := CastleList.Objects[j] as TCastle;
          j := EmpList.IndexOf(tm.Name);
          if (j <> - 1) then te := EmpList.Objects[j] as TEmp;
          ts := TMob.Create;
          //if (tgc.GuardStatus[guard] = 1) then begin
          case guard of
          0,1,2:
          begin
					ts.Data := MobDBName.Objects[MobDBName.IndexOf('SOLDIER_GUARDIAN')] as TMobDB;
          end;
          3,4:
          begin
          ts.Data := MobDBName.Objects[MobDBName.IndexOf('ARCHER_GUARDIAN')] as TMobDB;
          end;
          5,6,7:
          begin
          ts.Data := MobDBName.Objects[MobDBName.IndexOf('KNIGHT_GUARDIAN')] as TMobDB;
          end;
          end;
					ts.ID := NowMobID;
					Inc(NowMobID);
					ts.Name := ts.Data.JName;
					ts.JID := ts.Data.ID;
					ts.Map := tm.Name;
          ts.Data.isLink :=false;
          ts.isGuardian := tgc.GID;

          if (te <> nil) then begin
          ts.EmperiumID := te.EID;
          end else begin
          ts.EmperiumID := 0;
          end;

          repeat
					ts.Point1.X := Random(tm.Size.X - 2);
					ts.Point1.Y := Random(tm.Size.y - 2);
                    
          until ( (tm.gat[ts.Point1.X][ts.Point1.Y] <> 1) and (tm.gat[ts.Point1.X][ts.Point1.Y] <> 5) );

          ts.Point := ts.Point1;

					ts.Dir := Random(8);
					ts.HP := ts.Data.HP + cardinal(tgc.DTrigger * 2000);
					ts.Speed := ts.Data.Speed;
					ts.SpawnDelay1 := $7FFFFFFF;
					ts.SpawnDelay2 := 0;
					ts.SpawnType := 0;
					ts.SpawnTick := 0;
					if ts.Data.isDontMove then
						ts.MoveWait := $FFFFFFFF
					else
          ts.MoveWait := timeGetTime();
					ts.ATarget := 0;
					ts.ATKPer := 100;
					ts.DEFPer := 100;
					ts.DmgTick := 0;
          ts.Element := ts.Data.Element;
          ts.Name := ts.Data.JName;
          ts.isActive := ts.Data.isActive;
					ts.MoveWait := timeGetTime();
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
          ts.isSummon := True;
					tm.Mob.AddObject(ts.ID, ts);
					tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.AddObject(ts.ID, ts);
          //end;
          end;
end;
//------------------------------------------------------------------------------
function GetGuildEDegree(tn:TNPC) : cardinal;
var
  tgc:TCastle;
  i  :integer;
	w  :cardinal;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.EDegree;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildETrigger(tn:TNPC) : word;
var
  tgc:TCastle;
  i  :integer;
	w  :word;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.ETrigger;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildDDegree(tn:TNPC) : cardinal;
var
  tgc:TCastle;
  i  :integer;
	w  :cardinal;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.DDegree;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildDTrigger(tn:TNPC) : word;
var
  tgc:TCastle;
  i  :integer;
	w  :word;
begin
	w := 0;
  i := CastleList.IndexOf(tn.Reg);

  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.DTrigger;
  end else begin
  w := 0;
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildName(tn:TNPC) : string;
var
  tgc:TCastle;
  i  :integer;
	w  :string;
begin
	w := '';
  i := CastleList.IndexOf(tn.Reg);
  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.GName;
  end else begin
  w := '$guildname';
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildMName(tn:TNPC) : string;
var
  tgc:TCastle;
  i  :integer;
	w  :string;
begin
	w := '';
  i := CastleList.IndexOf(tn.Reg);
  if (i <> - 1) then begin
  tgc := CastleList.Objects[i] as TCastle;
  w := tgc.GMName;
  end else begin
  w := '$guildmaster';
  end;

	Result := w;
end;
//------------------------------------------------------------------------------
function GetGuildRelation(tg:TGuild; tc:TChara) : integer;
//�����E�G�΃M���h���𑗐M����
var
	i   :integer;
	w   :word;
	tgl :TGRel;
begin
	if (tg.RelAlliance.Count = 0) and (tg.RelHostility.Count = 0) then begin
		Result := -1;
		exit;
	end;
	w := 4;
	WFIFOW( 0, $014c);
	for i := 0 to tg.RelAlliance.Count - 1 do begin
		tgl := tg.RelAlliance.Objects[i] as TGRel;
		WFIFOL(w, 0);
		WFIFOL(w + 4, tgl.ID);
		WFIFOS(w + 8, tgl.GuildName, 24);
		Inc(w, 32);
	end;
	for i := 0 to tg.RelHostility.Count - 1 do begin
		tgl := tg.RelHostility.Objects[i] as TGRel;
		WFIFOL(w, 1);
		WFIFOL(w + 4, tgl.ID);
		WFIFOS(w + 8, tgl.GuildName, 24);
		Inc(w, 32);
	end;
	WFIFOW( 2, w);
	Result := w;
end;
//------------------------------------------------------------------------------
procedure KillGuildRelation(tg:TGuild; tg1:TGuild; tc:TChara; tc1:TChara; RelType:byte);
//�����E�G�Ί֌W����������
var
	j   :integer;
	w   :word;
	tgl :TGRel;
begin
	//�����ʒm
	if (RelType = 0) then begin
		//��������(�����M���h)
		j := tg.RelAlliance.IndexOf(tg1.Name);
		if (j <> -1) then begin
			tgl := tg.RelAlliance.Objects[j] as TGRel;
			tg.RelAlliance.Delete(j);
			WFIFOW( 0, $0184);
			WFIFOL( 2, tg1.ID);
			WFIFOL( 6, RelType);
			SendGuildMCmd(tc, 10);
		end;
		//��������(����M���h)
		j := tg1.RelAlliance.IndexOf(tg.Name);
		if (j <> -1) then begin
			tgl := tg1.RelAlliance.Objects[j] as TGRel;
			tg1.RelAlliance.Delete(j);
			WFIFOW( 0, $0184);
			WFIFOL( 2, tg.ID);
			WFIFOL( 6, RelType);
			SendGuildMCmd(tc1, 10);
		end;
	end else begin
		//�G�Ή���(�����M���h�̂�)
		j := tg.RelHostility.IndexOf(tg1.Name);
		if (j <> -1) then begin
			tgl := tg.RelHostility.Objects[j] as TGRel;
			tg.RelHostility.Delete(j);
			WFIFOW( 0, $0184);
			WFIFOL( 2, tg1.ID);
			WFIFOL( 6, RelType);
			SendGuildMCmd(tc, 10);
		end;
	end;
end;
//------------------------------------------------------------------------------
function LoadEmblem(tg:TGuild) : word;
//�M���h�G���u������ǂݍ���
var
	i     :integer;
	l     :cardinal;
	str   :string;
	embfs :TFileStream;
	embdt :PByte;
	embpt :PByte;
begin
	//�t�@�C���`�F�b�N
	str := AppPath + 'emblem\' + IntToStr(tg.ID) + '_' + IntToStr(tg.Emblem) + '.emb';
	if not FileExists(str) then begin
		Result := 0;
		exit;
	end;

	//�t�@�C���ǂݍ���
	embfs := TFileStream.Create(str, fmOpenRead);
        try
        l := embfs.Size;
        GetMem(embdt, l);
        embfs.Read(embdt^, l);
        finally
	embfs.Free;
	end;
        if (l = 0) then begin
        Result := 0;
        end else begin
          embpt := embdt;
          WFIFOW( 0, $0152);
          WFIFOW( 2, l + 12);
          WFIFOL( 4, tg.ID);
          WFIFOL( 8, tg.Emblem);
          for i := 0 to l - 1 do begin
              WFIFOB(i + 12, embpt^);
              Inc(embpt);
          end;
          Result := l + 12;
	end;
	FreeMem(embdt);
end;
//------------------------------------------------------------------------------
procedure SaveEmblem(tg:TGuild; size:cardinal);
//�M���h�G���u��������������
var
	i     :integer;
	str   :string;
	embfs :TFileStream;
	embdt :PByte;
	embpt :PByte;
begin
	//�t�@�C����������
	str := AppPath + 'emblem\' + IntToStr(tg.ID) + '_' + IntToStr(tg.Emblem) + '.emb';
	GetMem(embdt, size);
	embpt := embdt;
	for i := 0 to size - 1 do begin
		RFIFOB(i + 4, embpt^);
		Inc(embpt);
	end;
	embfs := TFileStream.Create(str, fmCreate or fmOpenWrite);
        try
          embfs.Write(embdt^, size);
        finally
          embfs.Free;
        end;
	FreeMem(embdt);
end;
{�M���h�@�\�ǉ��R�R�܂�}
{�A�W�g�@�\�ǉ�}
procedure SetFlagValue(tc:TChara; str:string; svalue:string);
// �X�N���v�g�t���O��������
begin
	if (Copy(str, 1, 1) = '\') then begin
		ServerFlag.Values[str] := svalue;
	end else if (tc.Login = 2) then begin
		tc.Flag.Values[str] := svalue;
	end;
end;
{�A�W�g�@�\�ǉ��R�R�܂�}
//==============================================================================
//==============================================================================






//==============================================================================
procedure MapLoad(MapName:string);
var
	i,j,k,l :integer;
	i1,g,ii :integer;
  m       :integer;
  x,p       :integer;
	cnt     :array[0..3] of integer;
	lines   :integer;
	mcnt    :integer;
	SDelay  :cardinal;
	w       :word;
	str     :string;
  str2    :string;
	ScriptPath :string;
	Tick    :cardinal;
	dat     :TMemoryStream;
	txt     :TextFile;
	tm      :TMap;
	tn      :TNPC;
	tn1     :TNPC;
	ts      :TMob;
  tgc     :TCastle;
  te      :TEmp;
	ts0     :TMob;
  ts1     :TMob;
  tss     :TSlaveDB;
  tc1     :TChara;
	h  :array[0..3] of single;
	maptype :integer;
	sl:TStringList;
	sl1:TStringList;
	sl2:TStringList;
	flag:boolean;
{NPC�C�x���g�ǉ�}
	tc      :TChara;
	tr      :NTimer;
	ta	:TMapList;
{NPC�C�x���g�ǉ��R�R�܂�}

        afm :textfile;
        letter :char;
begin
	MapName := ChangeFileExt(MapName, '');
	dat := TMemoryStream.Create; //�ǂݍ��ݗp�������o�b�t�@


	if MapList.IndexOf(MapName) = -1 then begin
		//DebugOut.Lines.Add('Map Not found : ' + MapName);
		exit;
	end;

	tm := TMap.Create;
	tm.Name := MapName;
	Map.AddObject(MapName, tm);
	tm.Mode := 1;

        ta := MapList.Objects[MapList.IndexOf(MapName)] as TMapList;

        if ta.Ext = 'af2' then begin

          assignfile(afm,AppPath + 'map\tmpFiles\' + MapName + '.out');
          Reset(afm);

          ReadLn(afm,str);
          if (str <> 'ADVANCED FUSION MAP') then begin
            DebugOut.Lines.Add('Mapfile error 500 : ' + MapName);
            tm.Free;
            exit;
          end;

          ReadLn(afm,str);
          if (str <> MapName) then begin
            DebugOut.Lines.Add('The loaded map was not the memory map : ' + MapName);
            tm.Free;
            exit;
          end;

          ReadLn(afm,tm.Size.x,tm.Size.y);
          ReadLn(afm,str);

          SetLength(tm.gat, tm.Size.X, tm.Size.Y);
          for j := 0 to tm.Size.Y - 1 do begin
            for i := 0 to tm.Size.X - 1 do begin
              Read(afm,letter);
              tm.gat[i][j] := strtoint(letter);
            end;
            ReadLn(afm,str);
          end;
          CloseFile(afm);
        end

        else if ta.Ext = 'afm' then begin

          assignfile(afm,AppPath + 'map/' + MapName + '.afm');
          Reset(afm);

          ReadLn(afm,str);
          if (str <> 'ADVANCED FUSION MAP') then begin
            DebugOut.Lines.Add('Mapfile error 500 : ' + MapName);
            tm.Free;
            exit;
          end;

          ReadLn(afm,str);
          if (str <> MapName) then begin
            DebugOut.Lines.Add('The loaded map was not the memory map : ' + MapName);
            tm.Free;
            exit;
          end;

          ReadLn(afm,tm.Size.x,tm.Size.y);
          ReadLn(afm,str);

          SetLength(tm.gat, tm.Size.X, tm.Size.Y);
          for j := 0 to tm.Size.Y - 1 do begin
            for i := 0 to tm.Size.X - 1 do begin
              Read(afm,letter);
              tm.gat[i][j] := strtoint(letter);
            end;
            ReadLn(afm,str);
          end;
          CloseFile(afm);
        end

        else begin
         
          if ta.Ext = 'gat' then begin
            //DebugOut.Lines.Add('Loading mapfile... : ' + MapName + '.gat');
            dat.LoadFromFile(AppPath + 'map\' + MapName + '.gat');
            SetLength(str, 4);
            dat.Read(str[1], 4);
          end;
          
          if (str <> 'GRAT') then begin
            DebugOut.Lines.Add('Mapfile error 500 : ' + MapName);
            tm.Free;
            exit;
          end;

          dat.Read(w, 2);
          dat.Read(tm.Size.X, 4);
          dat.Read(tm.Size.Y, 4);
          
          SetLength(tm.gat, tm.Size.X, tm.Size.Y);
          for j := 0 to tm.Size.Y - 1 do begin
            for i := 0 to tm.Size.X - 1 do begin
                         
              if ta.Ext = 'gat' then begin
                dat.Read(h[0], 4);
                dat.Read(h[1], 4);
                dat.Read(h[2], 4);
                dat.Read(h[3], 4);
                dat.Read(maptype, 4);

                tm.gat[i][j] := maptype;

              end;
            end;
          end;
          dat.Free;
        end;

	tm.BlockSize.X := (tm.Size.X + 7) div 8;
	tm.BlockSize.Y := (tm.Size.Y + 7) div 8;
	for j := 0 - 3 to tm.BlockSize.Y + 3 do begin
		for i := 0 - 3 to tm.BlockSize.X + 3 do begin
			tm.Block[i][j] := TBlock.Create;
			if (i < 0) or (j < 0) or (i >= tm.BlockSize.X) or (j >= tm.BlockSize.Y) then
				tm.Block[i][j].MobProcTick := $FFFFFFFF //��ʊO�u���b�N�̓����X�^�[�������s��Ȃ�
			else
				tm.Block[i][j].MobProcTick := 0;
		end;
	end;

	//�X�N���v�g���[�h
	//DebugOut.Lines.Add('Loading script...');
	for i := 0 to 3 do cnt[i] := 0;
	Tick := timeGetTime();
	lines := 0;
	sl := TStringList.Create;
	sl1 := TStringList.Create;
	sl2 := TStringList.Create;
	for i1 := 0 to ScriptList.Count - 1 do begin
		AssignFile(txt, ScriptList.Strings[i1]);
		Reset(txt);
		while not eof(txt) do begin
			Readln(txt, str);
			Inc(lines);
			sl.Delimiter := #9;
			sl.QuoteChar := '"';
			sl.DelimitedText := str;
			if sl.Count = 4 then begin
				sl1.DelimitedText := sl.Strings[0];
				if ChangeFileExt(sl1.Strings[0], '') = MapName then begin
	// ���[�v�|�C���g ------------------------------------------------------------
					if sl.Strings[1] = 'warp' then begin
						tn := TNPC.Create;
						tn.ID := NowNPCID;
						Inc(NowNPCID);
						tn.Name := sl.Strings[2];
						//DebugOut.Lines.Add('-> adding warp point ' + tn.Name);
						if WarpDebugFlag then tn.JID := 1002 else tn.JID := 45; //hiddenwarp=139
						tn.Map := MapName;
						tn.Point.X := StrToInt(sl1.Strings[1]);
						tn.Point.Y := StrToInt(sl1.Strings[2]);
						tn.Dir := StrToInt(sl1.Strings[3]);
						sl1.DelimitedText := sl.Strings[3];
						tn.CType := 0;
						tn.WarpSize.X := StrToInt(sl1.Strings[0]);
						tn.WarpSize.Y := StrToInt(sl1.Strings[1]);
						tn.WarpMap := ChangeFileExt(sl1.Strings[2], '');
						tn.WarpPoint.X :=  StrToInt(sl1.Strings[3]);
						tn.WarpPoint.Y :=  StrToInt(sl1.Strings[4]);
{NPC�C�x���g�ǉ�}
						tn.Enable := true;
						tn.ScriptInitS := -1;
{NPC�C�x���g�ǉ��R�R�܂�}
						tm.NPC.AddObject(tn.ID, tn);
						tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);
						for j := tn.Point.Y - tn.WarpSize.Y to tn.Point.Y + tn.WarpSize.Y do begin
							for i := tn.Point.X - tn.WarpSize.X to tn.Point.X + tn.WarpSize.X do begin
								tm.gat[i][j] := (tm.gat[i][j] or $4);
							end;
						end;
						Inc(cnt[0]);
	// NPC�V���b�v ---------------------------------------------------------------
					end else if sl.Strings[1] = 'shop' then begin
						tn := TNPC.Create;
						tn.ID := NowNPCID;
						Inc(NowNPCID);
						tn.Name := sl.Strings[2];
						//DebugOut.Lines.Add('-> adding shop ' + tn.Name);
						tn.Map := MapName;
						tn.Point.X := StrToInt(sl1.Strings[1]);
						tn.Point.Y := StrToInt(sl1.Strings[2]);
						tn.Dir := StrToInt(sl1.Strings[3]);
						sl1.DelimitedText := sl.Strings[3];
						tn.CType := 1;
						tn.JID := StrToInt(sl1.Strings[0]);
						SetLength(tn.ShopItem, sl1.Count - 1);
						for i := 0 to sl1.Count - 2 do begin
							tn.ShopItem[i] := TShopItem.Create;
							j := Pos(':', sl1.Strings[i+1]);
							tn.ShopItem[i].ID := StrToInt(Copy(sl1.Strings[i+1], 1, j - 1));
							tn.ShopItem[i].Price := StrToInt(Copy(sl1.Strings[i+1], j + 1, 8));
							tn.ShopItem[i].Data := ItemDB.IndexOfObject(tn.ShopItem[i].ID) as TItemDB;
						end;

{NPC�C�x���g�ǉ�}
						tn.Enable := true;
						tn.ScriptInitS := -1;
{NPC�C�x���g�ǉ��R�R�܂�}
						tm.NPC.AddObject(tn.ID, tn);
						tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);

						for j := tn.Point.Y - tn.WarpSize.Y to tn.Point.Y + tn.WarpSize.Y do begin
							for i := tn.Point.X - tn.WarpSize.X to tn.Point.X + tn.WarpSize.X do begin
								tm.gat[i][j] := (tm.gat[i][j] and $fe);
							end;
						end;
						Inc(cnt[1]);
{d$0100fix5���}
	// �X�N���v�g ----------------------------------------------------------------
					end else if sl.Strings[1] = 'script' then begin
						tn := TNPC.Create;
						tn.ID := NowNPCID;
						Inc(NowNPCID);
						tn.Name := sl.Strings[2];
						//DebugOut.Lines.Add('-> adding script ' + tn.Name);
						tn.Map := MapName;
						tn.Point.X := StrToInt(sl1.Strings[1]);
						if (tn.Point.X < 0) or (tn.Point.X >= tm.Size.X) then tn.Point.X := 0;
						tn.Point.Y := StrToInt(sl1.Strings[2]);
						if (tn.Point.Y < 0) or (tn.Point.Y >= tm.Size.Y) then tn.Point.Y := 0;
						tn.Dir := StrToInt(sl1.Strings[3]);
						tn.CType := 2;
						sl1.DelimitedText := sl.Strings[3];
						tn.JID := StrToInt(sl1.Strings[0]);
						ScriptPath := ExtractRelativePath(AppPath, ScriptList.Strings[i1]);
{NPC�C�x���g�ǉ�}
						tn.ScriptInitS := -1;
						tn.ScriptInitD := false;
						tn.Enable := true;
{NPC�C�x���g�ǉ��R�R�܂�}
						k := 0;
						sl2.Clear;
						while not eof(txt) do begin
							//�X�N���v�g�ǂݍ���
							Readln(txt, str);
							Inc(lines);
							if str = '}' then break; //���F�X�N���v�g�I�������u}�v�͂P�s�ɂ���̂ݏ�������
							while Pos(#9#9, str) <> 0 do str := StringReplace(str, #9#9, #9, [rfReplaceAll]);
							str := StringReplace(str, #9, ' ', [rfReplaceAll]);
							str := Trim(str);
							if Copy(str, Length(str), 1) = ';' then str := Copy(str, 1, Length(str) - 1);
							str := Trim(str);
							sl.Delimiter := ' ';
							sl.QuoteChar := #1;
							sl.DelimitedText := str;
							if sl.Count > 2 then begin
								for i := 2 to sl.Count - 1 do begin
									sl.Strings[1] := sl.Strings[1] + ' ' + sl.Strings[2];
									sl.Delete(2);
								end;
							end;
							case sl.Count of
							1:	sl1.Clear;
							2:	sl1.DelimitedText := sl.Strings[1];
							else
								begin
									DebugOut.Lines.Add(Format('%s %.4d: syntax error', [ScriptPath, lines]));
									exit;
								end;
							end;
							str := LowerCase(sl.Strings[0]);
							sl.Delete(0);
							if str = 'mes' then begin //------- 1 mes
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [mes] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 1;
								SetLength(tn.Script[k].Data1, 1);
								sl1.Strings[0] := StringReplace(sl1.Strings[0], '&sp;', ' ', [rfReplaceAll]);
								sl1.Strings[0] := StringReplace(sl1.Strings[0], '&amp;', '&', [rfReplaceAll]);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);
							end else if str = 'next' then begin //------- 2 next
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [next] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 2;
								Inc(k);
							end else if str = 'close' then begin //------- 3 close
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [close] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 3;
								Inc(k);
							end else if str = 'menu' then begin //------- 4 menu
								if sl1.Count <> sl1.Count div 2 * 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [menu] function error', [ScriptPath, lines]));
									exit;
								end;
								if sl1.Count > 40 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [menu] too many selections', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 4;
								SetLength(tn.Script[k].Data1, sl1.Count div 2);
								SetLength(tn.Script[k].Data2, sl1.Count div 2);
								SetLength(tn.Script[k].Data3, sl1.Count div 2);
								tn.Script[k].DataCnt := sl1.Count div 2;
								for i := 0 to sl1.Count div 2 - 1 do begin
									sl1.Strings[i*2] := StringReplace(sl1.Strings[i*2], '&sp;', ' ', [rfReplaceAll]);
									sl1.Strings[i*2] := StringReplace(sl1.Strings[i*2], '&amp;', '&', [rfReplaceAll]);
									tn.Script[k].Data1[i] := sl1.Strings[i*2];
									tn.Script[k].Data2[i] := LowerCase(sl1.Strings[i*2+1]);
								end;
								Inc(k);
							end else if str = 'goto' then begin //------- 5 goto
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [goto] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 5;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
							end else if str = 'cutin' then begin //------- 6 cutin
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [cutin] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 255) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [cutin] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 6;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								if ExtractFileExt(tn.Script[k].Data1[0]) = '' then ChangeFileExt(tn.Script[k].Data1[0], '.bmp');
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'store' then begin //------- 7 store
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [store] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 7;
								Inc(k);
							end else if str = 'warp' then begin //------- 8 warp
								if sl1.Count <> 3 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warp] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warp] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warp] range error (3)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 8;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[2]);
								Inc(k);
							end else if str = 'save' then begin //------- 9 save
								if sl1.Count <> 3 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [save] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [save] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [save] range error (3)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 9;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[2]);
								Inc(k);
							end else if str = 'heal' then begin //------- 10 heal
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [heal] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if (j <> 0) or (i < 0) or (i > 30000) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [heal] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 30000) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [heal] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 10;
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[0]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'set' then begin //------- 11 set
								sl.Strings[0] := StringReplace(sl.Strings[0], '+=', '+', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '-=', '-', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '*=', '*', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '/=', '/', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '+', ',1,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '-', ',2,',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '=', ',0,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '*', ',3,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '/', ',4,', []);
								while Pos('- ', sl.Strings[0]) <> 0 do
									sl.Strings[0] := StringReplace(sl.Strings[0], '- ', '-',	[]);
								sl1.DelimitedText := sl.Strings[0];
								if sl1.Count = 3 then sl1.Add('0');
								if sl1.Count <> 4 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [set] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 4) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [set] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if j = 0 then begin
									if (i < -999999999) or (i > 999999999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [set] range error (3)', [ScriptPath, lines]));
										exit;
									end else if (StrToInt(sl1.Strings[1]) = 3) and (i = 0) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [set] div 0 error (3)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[3], i, j);
								if (j <> 0) or (i < -999999999) or (i > 999999999) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [set] range error (4)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 11;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[2]);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[3]);
								Inc(k);
							end else if str = 'additem' then begin //------- 12 additem
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [additem] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [additem] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 30000) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [additem] range error (2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 12;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
							end else if str = 'delitem' then begin //------- 13 delitem
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [delitem] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [delitem] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 30000) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [delitem] range error (2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 13;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
							end else if str = 'checkitem' then begin //------- 14 checkitem
								if sl1.Count <> 4 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [checkitem] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [checkitem] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 30000) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [checkitem] range error (2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 14;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data2, 2);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[2]);
								tn.Script[k].Data2[1] := LowerCase(sl1.Strings[3]);
								tn.Script[k].DataCnt := 2;
								Inc(k);
							end else if str = 'check' then begin //------- 15 check
								sl.Strings[0] := StringReplace(sl.Strings[0], '=>', '>=', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '=<', '<=', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '==', '=',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '><', '<>', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '!=', '<>', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '>',	',>,',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '<',	',<,',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '=',	',=,',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], ',>,,=,', ',>=,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], ',<,,=,', ',<=,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], ',<,,>,', ',<>,', []);
								sl1.DelimitedText := sl.Strings[0];
								if sl1.Count <> 5 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [check] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 999999999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [check] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 15;
								SetLength(tn.Script[k].Data1, 3);
								SetLength(tn.Script[k].Data2, 2);
								SetLength(tn.Script[k].Data3, 3);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[2]);
								tn.Script[k].Data1[2] := sl1.Strings[1];
								str := sl1.Strings[1];
								j := -1;
										 if str = '>=' then j := 0
								else if str = '<=' then j := 1
								else if str = '='	then j := 2
								else if str = '<>' then j := 3
								else if str = '>'	then j := 4
								else if str = '<'	then j := 5;
								if j = -1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [check] syntax error (2)', [ScriptPath, lines]));
									exit;
								end;
								tn.Script[k].Data3[2] := j;
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[3]);
								tn.Script[k].Data2[1] := LowerCase(sl1.Strings[4]);
								tn.Script[k].DataCnt := 2;
								Inc(k);
							end else if str = 'checkadditem' then begin //------- 16 checkadditem
								if sl1.Count <> 4 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [checkadditem] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [checkadditem] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 30000) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [checkadditem] range error (2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 16;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data2, 2);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[2]);
								tn.Script[k].Data2[1] := LowerCase(sl1.Strings[3]);
								tn.Script[k].DataCnt := 2;
								Inc(k);
							end else if str = 'jobchange' then begin //------- 17 jobchange
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [jobchange] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if (j <> 0) or (i < 0) or (i > 44) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [jobchange] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 17;
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[0]);
								Inc(k);

							end else if str = 'viewpoint' then begin //------- 18 viewpoint
								if sl1.Count <> 5 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [viewpoint] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if (j <> 0) or (i < 1) or (i > 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [viewpoint] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [viewpoint] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [viewpoint] range error (3)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[3], i, j);
								if (j <> 0) or (i < 0) or (i > 255) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [viewpoint] range error (4)', [ScriptPath, lines]));
									exit;
								end;
								sl1.Strings[4] := StringReplace(sl1.Strings[4], '0x', '', []);
								if Copy(sl1.Strings[4], 1, 1) <> '$' then sl1.Strings[4] := '$' + sl1.Strings[4];
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 18;
								SetLength(tn.Script[k].Data3, 5);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[0]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[2] := StrToInt(sl1.Strings[2]);
								tn.Script[k].Data3[3] := StrToInt(sl1.Strings[3]);
								tn.Script[k].Data3[4] := StrToInt(sl1.Strings[4]);
								Inc(k);
							end else if str = 'input' then begin //------- 19 input
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [input] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 19;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);
							end else if str = 'random' then begin //------- 20 random
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [random] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 999999999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [random] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 999999999) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [random] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 20;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'option' then begin //------- 21 option
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [option] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if (j <> 0) or (i < 0) or (i > 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [option] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [option] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 21;
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[0]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'speed' then begin //------- 22 speed
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [speed] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 25) or (i > 1000) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [speed] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 22;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);
							end else if str = 'die' then begin //------- 23 die
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [die] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 23;
								Inc(k);
							end else if str = 'ccolor' then begin //------- 24 ccolor
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [ccolor] function error', [ScriptPath, lines]));
									exit;
								end;
								{val(sl1.Strings[0], i, j);
								if (j <> 0) or (i > 5) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [ccolor] range error (1)', [ScriptPath, lines]));
									exit;
								end;}
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 24;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);
							end else if str = 'refine' then begin //------- 25 refine	 refine[itemID][fail][+val]
								if sl1.Count <> 3 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [refine] function error', [ScriptPath, lines]));
									exit;
								end;
								//val(sl1.Strings[0], i, j);
								//val(sl1.Strings[1], i, j);
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i > 10) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [refine] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 25;
								SetLength(tn.Script[k].Data1, 3);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data1[1] := sl1.Strings[1];
								tn.Script[k].Data1[2] := sl1.Strings[2];
								Inc(k);
							end else if str = 'getitemamount' then begin //------- 26 getitemamount
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getitemamount] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19999) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [getitemamount] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 26;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
{�ǉ�:�X�N���v�g144}
							end else if str = 'getskilllevel' then begin //--------27 getskilllevel // S144 addstart
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getskilllevel] function error', [ScriptPath, lines]));
									exit;
								end;

								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 27;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
							end else if str = 'setskilllevel' then begin //--------28 setskilllevel
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setskilllevel] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 10) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [setskilllevel] range error(2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 28;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);                                    // S144 addend
{�ǉ�:�X�N���v�g144�����܂�}
{���BNPC�@�\�ǉ�}
							end else if str = 'refinery' then begin //--------29 refinery
								if sl1.Count <> 3 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [refinery] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 10) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [refinery] range error (1)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 2) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [refinery] range error (2)', [ScriptPath, lines]));
										exit;
									end;
								end;
								val(sl1.Strings[2], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 10) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [refinery] range error (3)', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 29;
								SetLength(tn.Script[k].Data1, 3);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								tn.Script[k].Data1[2] := LowerCase(sl1.Strings[2]);
								Inc(k);
							end else if str = 'equipmenu' then begin //--------30 equipmenu
								if sl1.Count <> 3 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [equipmenu] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 30;
								SetLength(tn.Script[k].Data1, 3);
								SetLength(tn.Script[k].Data2, 10);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								tn.Script[k].Data1[2] := LowerCase(sl1.Strings[2]);
								Inc(k);
							end else if str = 'lockitem' then begin //--------31 lockitem
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [lockitem] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 1) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [lockitem] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 31;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
{���BNPC�@�\�ǉ��R�R�܂�}
{���F�ύX�ǉ�}
							end else if str = 'hcolor' then begin //------- 32 hcolor
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [hcolor] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 8) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [hcolor] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 32;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
{���F�ύX�ǉ��R�R�܂�}
{NPC�C�x���g�ǉ�}
							end else if str = 'callmob' then begin //------- 33 callmob
								if (sl1.Count = 6) then sl1.Add('');
								if (sl1.Count <> 7) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [callmob] function error', [ScriptPath, lines]));
									exit;
								end;
								i := 0;
								if (tn.Map <> ChangeFileExt(sl1.Strings[0], '')) then i := 1;
								if (MobDB.IndexOf(StrToInt(sl1.Strings[4])) = -1) then i := 1;
								if i <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [callmob] range error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 33;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data2, 1);
								SetLength(tn.Script[k].Data3, 4);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[2]);
								tn.Script[k].Data1[1] := sl1.Strings[3];
								tn.Script[k].Data3[2] := StrToInt(sl1.Strings[4]);
								tn.Script[k].Data3[3] := StrToInt(sl1.Strings[5]);
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[6]);
								Inc(k);
							end else if str = 'broadcast' then begin //------- 34 broadcast
								if (sl1.Count = 1) then sl1.Add('0');
								if (sl1.Count <> 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [broadcast] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 34;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								sl1.Strings[0] := StringReplace(sl1.Strings[0], '&sp;', ' ', [rfReplaceAll]);
								sl1.Strings[0] := StringReplace(sl1.Strings[0], '&amp;', '&', [rfReplaceAll]);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'npctimer' then begin //------- 35 npctimer
								if (sl1.Count <> 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [npctimer] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 8) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [npctimer] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 35;
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[0]);
								Inc(k);
							end else if str = 'addnpctimer' then begin //------- 36 addnpctimer
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [addnpctimer] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < -999999999) or (i > 999999999) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [addnpctimer] range error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 36;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'return' then begin //------- 37 return
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [return] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 37;
								Inc(k);
							end else if str = 'warpallpc' then begin //------- 38 warpallpc
								if (sl1.Count = 3) then sl1.Add('0');
								if (sl1.Count <> 4) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warpallpc] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warpallpc] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i < 0) or (i > 511) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warpallpc] range error (3)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[3], i, j);
								if (j <> 0) or (i < 0) or (i > 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [warpallpc] range error (4)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 38;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 3);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := StrToInt(sl1.Strings[2]);
								tn.Script[k].Data3[2] := StrToInt(sl1.Strings[3]);
								Inc(k);
							end else if str = 'waitingroom' then begin //------- 39 waitingroom
								if (sl1.Count <> 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [waitingroom] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 2) or (i > 20) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [waitingroom] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 39;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 2);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								tn.Script[k].Data3[1] := k + 1;
								Inc(k);
							end else if str = 'enablenpc' then begin //------- 40 enablenpc
								if (sl1.Count <> 3) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [enablenpc] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[2], i, j);
								if (j <> 0) or (i < 0) or (i > 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [enablenpc] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 40;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data1[1] := sl1.Strings[1];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[2]);
								Inc(k);
							end else if str = 'resetmymob' then begin //------- 41 resetmymob
								if (sl1.Count <> 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [resetmymob] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 41;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);
							end else if str = 'getmapusers' then begin //------- 42 getmapusers
								if (sl1.Count <> 2) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getmapusers] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 42;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
							end else if str = 'setstr' then begin //------- 43 setstr
								sl.Strings[0] := StringReplace(sl.Strings[0], '+=', '+', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '+', ',1,', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '=', ',0,', []);
								sl1.DelimitedText := sl.Strings[0];
								if (sl1.Count <> 3) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setstr] function error', [ScriptPath, lines]));
									exit;
								end;
								if (Copy(sl1.Strings[0], 1, 1) <> '$') and (Copy(sl1.Strings[0], 1, 2) <> '\$') then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setstr] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[1], i, j);
								if (j <> 0) or (i < 0) or (i > 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setstr] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 43;
								SetLength(tn.Script[k].Data1, 2);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := sl1.Strings[2];
								tn.Script[k].Data3[0] := StrToInt(sl1.Strings[1]);
								Inc(k);
							end else if str = 'checkstr' then begin //------- 44 checkstr
								sl.Strings[0] := StringReplace(sl.Strings[0], '==', '=',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '><', '<>', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '!=', '<>', []);
								sl.Strings[0] := StringReplace(sl.Strings[0], '=',	',=,',	[]);
								sl.Strings[0] := StringReplace(sl.Strings[0], '<>', ',<>,', []);
								sl1.DelimitedText := sl.Strings[0];
								if sl1.Count <> 5 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [checkstr] function error', [ScriptPath, lines]));
									exit;
								if (Copy(sl1.Strings[0], 1, 1) <> '$') and (Copy(sl1.Strings[0], 1, 2) <> '\$') then begin
									DebugOut.Lines.Add(Format('%s %.4d: [checkstr] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 44;
								SetLength(tn.Script[k].Data1, 3);
								SetLength(tn.Script[k].Data2, 2);
								SetLength(tn.Script[k].Data3, 3);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[2]);
								tn.Script[k].Data1[2] := sl1.Strings[1];
								str := sl1.Strings[1];
								j := -1;
								if str = '='	then j := 0
								else if str = '<>' then j := 1;
								if j = -1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [checkstr] syntax error (2)', [ScriptPath, lines]));
									exit;
								end;
								tn.Script[k].Data3[2] := j;
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[3]);
								tn.Script[k].Data2[1] := LowerCase(sl1.Strings[4]);
								tn.Script[k].DataCnt := 2;
								Inc(k);
{�A�W�g�@�\�ǉ�}
							end else if str = 'getagit' then begin //------- 44a getagit
								if (sl1.Count <> 3) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getagit] function error', [ScriptPath, lines]));
									exit;
								end;
								if (Copy(sl1.Strings[1], 1, 1) <> '$') and (Copy(sl1.Strings[1], 1, 2) <> '\$') then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getagit] range error (2)', [ScriptPath, lines]));
									exit;
								end;
								if (Copy(sl1.Strings[2], 1, 1) <> '$') and (Copy(sl1.Strings[2], 1, 2) <> '\$') then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getagit] range error (3)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 45;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data2, 2);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								tn.Script[k].Data2[0] := LowerCase(sl1.Strings[1]);
								tn.Script[k].Data2[1] := LowerCase(sl1.Strings[2]);
								Inc(k);
							end else if str = 'getmyguild' then begin //------- 44b getguild
								if (sl1.Count <> 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getmyguild] function error', [ScriptPath, lines]));
									exit;
								end;
								if (Copy(sl1.Strings[0], 1, 1) <> '$') and (Copy(sl1.Strings[0], 1, 2) <> '\$') then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getmyguild] range error (1)', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 46;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);


							end else if str = 'agitregist' then begin //------- 44c agitregist
								if (sl1.Count <> 1) then begin
									DebugOut.Lines.Add(Format('%s %.4d: [agitregist] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 47;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := sl1.Strings[0];
								Inc(k);

              end else if str = 'resetstat' then begin //------- 45 resetstat
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [resetstat] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 45;
								Inc(k);
                                                                     
              end else if str = 'resetbonusstat' then begin //------- 57 resetbonusstat
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [resetstat] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 57;
								Inc(k);
              end else if str = 'resetskill' then begin //------- 46 resetskill
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [resetskill] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 46;
								Inc(k);
              end else if str = 'hstyle' then begin //------- 47 hstyle
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [hstyle] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 19) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [hstyle] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 47;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
              end else if str = 'guildreg' then begin //------- 48 guildreg
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [guildreg] function error', [ScriptPath, lines]));
									exit;
								end;
                //j := CastleList.IndexOf(sl1.Strings[0]);
								//if j = - 1 then begin
                  //DebugOut.Lines.Add(Format('%s %.4d: [guildreg] map error', [ScriptPath, lines]));
                  //exit;
								//end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 48;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
              end else if str = 'getgskilllevel' then begin //--------49 getgskilllevel
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getgskilllevel] function error', [ScriptPath, lines]));
									exit;
								end;

								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 49;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
              end else if str = 'getguardstatus' then begin //--------50 getguardstatus
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [getguardstatus] function error', [ScriptPath, lines]));
									exit;
								end;

								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 50;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
              end else if str = 'setguildkafra' then begin //------- 51 setguildkafra
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setguildkafra] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 1) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [setguildkafra] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 51;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
              end else if str = 'setguardstatus' then begin //--------52 setguardstatus
								if sl1.Count <> 2 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [setguardstatus] function error', [ScriptPath, lines]));
									exit;
								end;
                val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 1) or (i > 8) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [setguardstatus] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
                val(sl1.Strings[1], i, j);
								if j = 0 then begin
									if (i < 0) or (i > 1) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [setguardstatus] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 52;
								SetLength(tn.Script[k].Data1, 2);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
								Inc(k);
              end else if str = 'callguard' then begin //------- 53 callguard
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [callguard] function error', [ScriptPath, lines]));
									exit;
								end;
								val(sl1.Strings[0], i, j);
								if j = 0 then begin
									if (i < 1) or (i > 8) then begin
										DebugOut.Lines.Add(Format('%s %.4d: [callguard] range error', [ScriptPath, lines]));
										exit;
									end;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 53;
								SetLength(tn.Script[k].Data1, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
              end else if str = 'callmymob' then begin //------- 54 callmymob
								if sl1.Count <> 5 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [callmymob] function error', [ScriptPath, lines]));
									exit;
								end;

								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 54;
								SetLength(tn.Script[k].Data1, 5);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
                tn.Script[k].Data1[1] := LowerCase(sl1.Strings[1]);
                tn.Script[k].Data1[2] := LowerCase(sl1.Strings[2]);
                tn.Script[k].Data1[3] := LowerCase(sl1.Strings[3]);
                tn.Script[k].Data1[4] := LowerCase(sl1.Strings[4]);
								Inc(k);
              end else if str = 'resetguild' then begin //------- 55 resetguild
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [resetguild] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 55;
								Inc(k);
              end else if str = 'guilddinvest' then begin //------- 56 guilddinvest
								if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [guilddinvest] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 56;
								Inc(k);
              {end else if str = 'movenpc' then begin //------- 60 Move NPC
                                                                if sl1.Count <> 0 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [guilddinvest] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 60;
                                                                SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 1);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);}

							end else if str = 'script' then begin //------- 99 script
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [script] function error', [ScriptPath, lines]));
									exit;
								end;
								SetLength(tn.Script, k + 1);
								tn.Script[k].ID := 99;
								SetLength(tn.Script[k].Data1, 1);
								SetLength(tn.Script[k].Data3, 4);
								tn.Script[k].Data1[0] := LowerCase(sl1.Strings[0]);
								Inc(k);
							end else if Copy(str, Length(str), 1) = ':' then begin //label
{NPC�C�x���g�ǉ�}
								if (LowerCase(Copy(str, 1, 7)) = 'ontimer') then begin
									j := StrToInt(Copy(str, 8, Length(str) - 8));
									if (j >= 0) and (j < 999999999) then begin
										i := tm.TimerDef.IndexOf(tn.ID);
										if (i <> -1) then begin
											tr := tm.TimerDef.Objects[i] as NTimer;
										end else begin
											tr := NTimer.Create;
											tm.TimerDef.AddObject(tn.ID, tr);
										end;
										tr.ID := tn.ID;
										SetLength(tr.Idx, tr.Cnt + 1);
										SetLength(tr.Step, tr.Cnt + 1);
										SetLength(tr.Done, tr.Cnt + 1);
										tr.Idx[tr.Cnt] := j;
										tr.Step[tr.Cnt] := k;
										tr.Cnt := tr.Cnt + 1;
									end;
								end else if (LowerCase(Copy(str, 1, 6)) = 'oninit') then begin
									tn.ScriptInitS := k;
                end else if (LowerCase(Copy(str, 1, 11)) = 'onmymobdead') then begin
									tn.ScriptInitMS := k;
								end;

								str := Copy(str, 1, Length(str) - 1);
								sl2.Add(str + '=' + IntToStr(k));
							end else if str = 'scriptlabel' then begin //scriptlabel
								if sl1.Count <> 1 then begin
									DebugOut.Lines.Add(Format('%s %.4d: [scriptlabel] function error', [ScriptPath, lines]));
									exit;
								end;
								tn.ScriptLabel := LowerCase(sl1.Strings[0]);
							end;
						end;
						tn.ScriptCnt := k;
						for i := 0 to k - 1 do begin
							case tn.Script[i].ID of
							4,14,15,16,44:
								begin
									for j := 0 to tn.Script[i].DataCnt - 1 do begin
										if tn.Script[i].Data2[j] = '-' then begin //nop���x��
											tn.Script[i].Data3[j] := i + 1;
										end else if sl2.IndexOfName(tn.Script[i].Data2[j]) = -1 then begin
											DebugOut.Lines.Add(Format('%s : label "%s" not found', [ScriptPath, tn.Script[i].Data2[j]]));
											exit;
											//tn.Script[i].Data3[j] := $FFFF;
										end else begin
											tn.Script[i].Data3[j] := StrToInt(sl2.Values[tn.Script[i].Data2[j]]);
										end;
									end;
								end;
							5:
								begin
									if sl2.IndexOfName(tn.Script[i].Data1[0]) = -1 then begin
										DebugOut.Lines.Add(Format('%s : label "%s" not found', [ScriptPath, tn.Script[i].Data1[0]]));
										exit;
										//tn.Script[i].Data3[0] := $FFFF;
									end else begin
										tn.Script[i].Data3[0] := StrToInt(sl2.Values[tn.Script[i].Data1[0]]);
									end;
								end;
							end;
						end;

						if tn.ScriptLabel <> '' then tm.NPCLabel.AddObject(tn.ScriptLabel, tn);
						tm.NPC.AddObject(tn.ID, tn);
						tm.Block[tn.Point.X div 8][tn.Point.Y div 8].NPC.AddObject(tn.ID, tn);
						tm.gat[tn.Point.X][tn.Point.Y] := (tm.gat[tn.Point.X][tn.Point.Y] or $8);

						Inc(cnt[2]);
{d$0100fix5���R�R�܂�}
	// �����X�^�[ ----------------------------------------------------------------
					end else if sl.Strings[1] = 'monster' then begin
						for i := sl.Count to 4 do sl.Add('0');
						ts0 := TMob.Create;
						ts0.Name := sl.Strings[2];
						//DebugOut.Lines.Add('-> adding mob ' + ts0.Name);
						ts0.Map := MapName;
						ts0.Point1.X := StrToInt(sl1.Strings[1]);
						ts0.Point1.Y := StrToInt(sl1.Strings[2]);
						ts0.Dir := 3;
						ts0.Point2.X := StrToInt(sl1.Strings[3]);
						ts0.Point2.Y := StrToInt(sl1.Strings[4]);
						sl1.DelimitedText := sl.Strings[3];
						for i := sl.Count to 4 do sl.Add('0');
						ts0.JID := StrToInt(sl1.Strings[0]);
						mcnt := StrToInt(sl1.Strings[1]);
						ts0.SpawnDelay1 := StrToInt(sl1.Strings[2]);
						ts0.SpawnDelay2 := StrToInt(sl1.Strings[3]);
						ts0.SpawnType := StrToInt(sl1.Strings[4]);
						if MobDB.IndexOf(ts0.JID) = -1 then continue;
						ts0.Data := MobDB.IndexOfObject(ts0.JID) as TMobDB;
						if (ts0.Point1.X = 0) and (ts0.Point1.Y = 0) and (ts0.Point2.X = 0) and (ts0.Point2.Y = 0) then begin
							//0,0,0,0�w�莞�̓}�b�v�S��Ƀ����_���z�u
							ts0.Point1.X := tm.Size.X div 2;
							ts0.Point1.Y := tm.Size.Y div 2;
							ts0.Point2.X := tm.Size.X - 1;
							ts0.Point2.Y := tm.Size.Y - 1;
						end;

						for i := 0 to mcnt - 1 do begin
							//���萔�����X�^�[�̏����z�u
							ts := TMob.Create;
							ts.ID := NowMobID;
							Inc(NowMobID);
							ts.Name := ts0.Data.JName;
							ts.JID := ts0.JID;
							ts.Map := ts0.Map;
							ts.Point1.X := ts0.Point1.X;
							ts.Point1.Y := ts0.Point1.Y;
							ts.Point2.X := ts0.Point2.X;
							ts.Point2.Y := ts0.Point2.Y;

{�ǉ�}        if (ts.JID = 1288) then begin
              ts.isEmperium := true;
              m := CastleList.IndexOf(ts.Map);
              if (m <> - 1) then begin
              tgc := CastleList.Objects[m] as TCastle;
              ts.GID := tgc.GID;
              end;
              k := EmpList.IndexOf(ts.Map);
              if (k = -1) then begin
              te := TEmp.Create;
		          with te do begin
              Map := ts.Map;
              EID := ts.ID;
              end;
		          EmpList.AddObject(te.Map, te);
              end;
              end;

							ts.isLooting := False;
  						for j:= 1 to 10 do begin
								ts.Item[j].ID := 0;
								ts.Item[j].Amount := 0;
								ts.Item[j].Equip := 0;
								ts.Item[j].Identify := 0;
								ts.Item[j].Refine := 0;
								ts.Item[j].Attr := 0;
								ts.Item[j].Card[0] := 0;
								ts.Item[j].Card[1] := 0;
								ts.Item[j].Card[2] := 0;
								ts.Item[j].Card[3] := 0;
						  end;
{�ǉ��R�R�܂�}
							j := 0;
							repeat
								ts.Point.X := ts.Point1.X + Random(ts.Point2.X + 1) - (ts.Point2.X div 2);
								ts.Point.Y := ts.Point1.Y + Random(ts.Point2.Y + 1) - (ts.Point2.Y div 2);
								//030317
								if (ts.Point.X < 0) or (ts.Point.X > tm.Size.X - 2) or (ts.Point.Y < 0) or (ts.Point.Y > tm.Size.Y - 2) then begin
									//DebugOut.Lines.Add(Format('***RandomRoute Error!! (%d,%d) %dx%d', [xy.X,xy.Y,tm.Size.X,tm.Size.Y]));
									if ts.Point.X < 0 then ts.Point.X := 0;
									if ts.Point.X > tm.Size.X - 2 then ts.Point.X := tm.Size.X - 2;
									if ts.Point.Y < 0 then ts.Point.Y := 0;
									if ts.Point.Y > tm.Size.Y - 2 then ts.Point.Y := tm.Size.Y - 2;
								end;
								//---
								Inc(j);
							until ( (tm.gat[ts.Point.X][ts.Point.Y] <> 1) and (tm.gat[ts.Point.X][ts.Point.Y] <> 5) or (j = 100) );
            if j <> 100 then begin
								ts.Dir := Random(8);
								ts.HP := ts0.Data.HP;
								ts.Speed := ts0.Data.Speed;
								ts.SpawnDelay1 := ts0.SpawnDelay1;
								ts.SpawnDelay2 := ts0.SpawnDelay2;
								ts.SpawnType := ts0.SpawnType;
								ts.SpawnTick := 0;
								if ts0.Data.isDontMove then
									ts.MoveWait := 4294967295
								else
                ts.MoveWait := Tick + 5000 + Cardinal(Random(10000));
								ts.ATarget := 0;
								ts.ATKPer := 100;
								ts.DEFPer := 100;
								ts.DmgTick := 0;
								ts.Data := ts0.Data;
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
{�ǉ�}					ts.Element := ts.Data.Element;
{�ǉ�}					ts.isActive := ts.Data.isActive;
                ts.EmperiumID := 0;
								tm.Mob.AddObject(ts.ID, ts);
								tm.Block[ts.Point.X div 8][ts.Point.Y div 8].Mob.AddObject(ts.ID, ts);
							end else begin
								ts.Free;
							end;

if (MonsterMob = true) then begin
    k := SlaveDBName.IndexOf(ts0.Data.Name);
    if (k <> -1) then begin
     ts.isLeader := true;
    end;
end;



						end;
						ts0.Free;
						Inc(cnt[3]);
					end;
				end;
			end;
		end;
		CloseFile(txt);
	end;
	//�X�N���v�g�̃R�s�[
	for i1 := 0 to tm.NPC.Count - 1 do begin
		tn := tm.NPC.Objects[i1] as TNPC;
		if (tn.CType = 2) and (tn.ScriptCnt <> 0) then begin
			if tn.Script[0].ID = 99 then begin
				j := tm.NPCLabel.IndexOf(tn.Script[0].Data1[0]);
				if j <> -1 then begin
					SetLength(tn.Script[0].Data1, 0);
					tn1 := tm.NPCLabel.Objects[j] as TNPC;
					SetLength(tn.Script, tn1.ScriptCnt);
					for i := 0 to tn1.ScriptCnt - 1 do begin
						tn.Script[i] := tn1.Script[i];
					end;
					tn.ScriptCnt := tn1.ScriptCnt;
				end;
{NPC�C�x���g�ǉ�}
			end else begin
				for i := 0 to tn.ScriptCnt - 1 do begin
					//callmob�C�x���g�`�F�b�N
					if (tn.Script[i].ID = 33) and (tn.Script[i].Data2[0] <> '') then begin
						k := 0;
						for j := 0 to tm.NPC.Count - 1 do begin
							tn1 := tm.NPC.Objects[j] as TNPC;
							if (tn1.Name = tn.Script[i].Data2[0]) and (tn1.JID = -1) then begin
								tn.Script[i].Data2[0] := IntToStr(tn1.ID);
								k := 1;
								break;
							end;
						end;
						if (k = 0) then begin
							//DebugOut.Lines.Add(Format('%s: [callmob] event not found', [tn.Script[i].Data2[0]]));
							tn.Script[i].Data2[0] := '';
						end;
					end;
				end;
			end;
{NPC�C�x���g�ǉ��R�R�܂�}
		end;
	end;

	//DebugOut.Lines.Add('WarpPoint: ' + IntToStr(cnt[0]));
	//DebugOut.Lines.Add('Shop: ' + IntToStr(cnt[1]));
	//DebugOut.Lines.Add('NPC: ' + IntToStr(cnt[2]));
	//DebugOut.Lines.Add('Monster: ' + IntToStr(cnt[3]));
	//DebugOut.Lines.Add('-> Map load success.');

	sl.Free;
	sl1.Free;
	sl2.Free;

	tm.Mode := 2;
end;
//------------------------------------------------------------------------------
procedure MapMove(Socket:TCustomWinSocket; MapName:string; Point:TPoint);
var
i,j,k :integer;
tm    :TMap;
tc1   :TChara;

begin
  WFIFOW(0, $0091);
	WFIFOS(2, MapName + '.rsw', 16);
	WFIFOW(18, Point.X);
	WFIFOW(20, Point.Y);
	Socket.SendBuf(buf, 22);

	//�}�b�v���[�h
	if Map.IndexOf(MapName) = -1 then MapLoad(MapName);

  //tm := Map.Objects[Map.IndexOf(MapName)] as TMap;
  //WFIFOW( 0, $0199);
  //WFIFOW( 2, 1);
  //Socket.SendBuf(buf, 4);
  //for j := 0 to tm.CList.Count - 1 do begin
  //tc1 := tm.CList.Objects[j] as TChara;
  //k := j + 1;
  //i := tm.CList.Count;
  //WFIFOW( 0, $019a);
  //WFIFOL( 2, tc1.ID);
  //WFIFOL( 6, k);
  //WFIFOL( 10, i);
  //Socket.SendBuf(buf, 14);
  //end;

end;
//------------------------------------------------------------------------------
procedure RFIFOB(index:word; var b:byte);
begin
	Assert(index <= 32767, 'RFIFOB: index overflow ' + IntToStr(index));
	Move(buf[index], b, 1);
end;
//------------------------------------------------------------------------------
procedure RFIFOW(index:word; var w:word);
begin
	Assert(index <= 32766, 'RFIFOW: index overflow ' + IntToStr(index));
	Move(buf[index], w, 2);
end;
//------------------------------------------------------------------------------
procedure RFIFOL(index:word; var l:cardinal);
begin
	Assert(index <= 32764, 'RFIFOL: index overflow ' + IntToStr(index));
	Move(buf[index], l, 4);
end;
//------------------------------------------------------------------------------
function RFIFOS(index:word; cnt:word):string;
begin
	Assert(index <= 32767, 'RFIFOS: index overflow ' + IntToStr(index));
	Assert(index + cnt <= 32767, 'RFIFOS: index+cnt overflow ' + IntToStr(index+cnt));
	stra[cnt] := #0;
	Move(buf[index], stra, cnt);
	Result := stra;
end;
//------------------------------------------------------------------------------
procedure RFIFOM1(index:word; var xy:TPoint);
var
	l   :cardinal;
	bb  :array[0..3] of byte;
begin
	Move(buf[index], bb[0], 3);
	bb[3] := bb[0]; bb[0] := bb[2]; bb[2] := bb[3];
	Move(bb[0], l, 3);
	l := l shr 4;
	xy.Y :=  (l and $003ff);
	xy.X := ((l and $ffc00) shr 10);
end;
//------------------------------------------------------------------------------
procedure RFIFOM2(index:word; var xy1:TPoint; var xy2:TPoint);
var
	i   :int64;
	bb  :array[0..5] of byte;
begin
	Move(buf[index], i, 5);
	bb[5] := bb[0]; bb[0] := bb[4]; bb[4] := bb[5];
	bb[5] := bb[1]; bb[1] := bb[3]; bb[3] := bb[5];
	Move(bb[0], i, 5);
	xy1.Y :=  (i and $00000003ff);
	xy1.X := ((i and $00000ffc00) shr 10);
	xy2.Y := ((i and $003ff00000) shr 20);
	xy2.X := ((i and $ffc0000000) shr 30);
end;
//------------------------------------------------------------------------------
procedure WFIFOB(index:word; b:byte);
begin
	Assert(index <= 32767, 'WFIFOB: index overflow ' + IntToStr(index));
	Move(b, buf[index], 1);
end;
//------------------------------------------------------------------------------
procedure WFIFOW(index:word; w:word);
begin
	Assert(index <= 32766, 'WFIFOW: index overflow ' + IntToStr(index));
	Move(w, buf[index], 2);
end;
//------------------------------------------------------------------------------
procedure WFIFOL(index:word; l:longword);
begin
	Assert(index <= 32764, 'WFIFOL: index overflow ' + IntToStr(index));
	Move(l, buf[index], 4);
end;
//------------------------------------------------------------------------------
procedure WFIFOS(index:word; str:string; cnt:word);
var
	i :integer;
begin
	Assert(index <= 32767, 'WFIFOS: index overflow ' + IntToStr(index));
	Assert(index + cnt <= 32767, 'WFIFOS: index+cnt overflow ' + IntToStr(index+cnt));

	ZeroMemory(@buf[index], cnt);
	i := Length(str);
	if i = 0 then exit;
	if i > cnt then i := cnt;
	Move(str[1], buf[index], i);
end;
//------------------------------------------------------------------------------
procedure WFIFOM1(index:word; xy:TPoint; Dir:byte = 0);
var
	l   :cardinal;
	bb  :array[0..3] of byte;
begin
	l := (((xy.X and $3ff) shl 14) or ((xy.Y and $3ff) shl 4));
	Move(l, bb[0], 3);
	bb[3] := bb[0]; bb[0] := bb[2]; bb[2] := bb[3];
	bb[2] := (bb[2] or (Dir and $f));
	Move(bb[0], buf[index], 3);
end;
//------------------------------------------------------------------------------
procedure WFIFOM2(index:word; xy1:TPoint; xy2:TPoint);
var
	i :int64;
	bb  :array[0..5] of byte;
begin
	i := (((int64(xy2.X) and $3ff) shl 30) or ((int64(xy2.Y) and $3ff) shl 20) or
				((int64(xy1.X) and $3ff) shl 10) or  (int64(xy1.Y) and $3ff));
	Move(i, bb[0], 5);
	bb[5] := bb[0]; bb[0] := bb[4]; bb[4] := bb[5];
	bb[5] := bb[1]; bb[1] := bb[3]; bb[3] := bb[5];
	Move(bb[0], buf[index], 5);
end;
//==============================================================================










//==============================================================================
// �R���X�g���N�^�A�f�X�g���N�^
{�ǉ�}
constructor TMob.Create;
var
	i :integer;
begin
	inherited;
	for i := 1 to 10 do
		Item[i] := TItem.Create;
  isSummon := False;
  isLooting := False;
end;

destructor TMob.Destroy;
var
	i :integer;
begin
	for i := 1 to 10 do
		Item[i].Free;

	inherited;
end;

constructor TItemList.Create;
var
	i :integer;
begin
	inherited;
	for i := 1 to 100 do
		Item[i] := TItem.Create;
end;

destructor TItemList.Destroy;
var
	i :integer;
begin
	for i := 1 to 100 do
		Item[i].Free;
	inherited;
end;
{�ǉ������܂�}
constructor TChara.Create;
var
	i :integer;
begin
	inherited;

	for i := 0 to 336 do
		Skill[i] := TSkill.Create;
	for i := 1 to 100 do
		Item[i] := TItem.Create;
	Cart := TItemList.Create;
	Flag := TStringList.Create;

end;

{�`���b�g���[���@�\�ǉ�}
constructor TChatRoom.Create;
begin
	inherited;

	KickList := TIntList32.Create;
end;

destructor TChatRoom.Destroy;
begin
	KickList.Free;

	inherited;
end;
{�`���b�g���[���@�\�ǉ��R�R�܂�}


destructor TChara.Destroy;
var
	i :integer;
begin
	for i := 0 to 336 do
		Skill[i].Free;
	for i := 1 to 100 do
		Item[i].Free;
	Cart.Free;
	Flag.Free;
	inherited;
end;

constructor TPlayer.Create;
begin
	inherited;
  Kafra := TItemList.Create;
  Kafra.MaxWeight := 4000000000;
end;

destructor TPlayer.Destroy;
begin
  Kafra.Free;
	inherited;
end;

constructor TBlock.Create;
begin
	inherited;

	NPC := TIntList32.Create;
	CList := TIntList32.Create;
	Mob := TIntList32.Create;
end;

destructor TBlock.Destroy;
begin
	NPC.Free;
	CList.Free;
	Mob.Free;

	inherited;
end;

constructor TMap.Create;
begin
	inherited;

	NPC := TIntList32.Create;
	NPCLabel := TStringList.Create;
	CList := TIntList32.Create;
	Mob := TIntList32.Create;
{NPC�C�x���g�ǉ�}
	TimerAct := TIntList32.Create;
	TimerDef := TIntList32.Create;
{NPC�C�x���g�ǉ��R�R�܂�}
end;

destructor TMap.Destroy;
begin
	NPC.Free;
	NPCLabel.Free;
	CList.Free;
	Mob.Free;
{NPC�C�x���g�ǉ�}
	TimerAct.Free;
	TimerDef.Free;
{NPC�C�x���g�ǉ��R�R�܂�}

	inherited;
end;

{�M���h�@�\�ǉ��R�R�܂�}
constructor TGuild.Create;
var
	i :integer;
begin
	inherited;

	for i := 10000 to 10004 do
		GSkill[i] := TSkill.Create;
	GuildBanList := TStringList.Create;
	RelAlliance := TStringList.Create;
	RelHostility := TStringList.Create;
end;

destructor TGuild.Destroy;
var
	i :integer;
begin
	for i := 10000 to 10004 do
		GSkill[i].Free;
	GuildBanList.Free;
	RelAlliance.Free;
	RelHostility.Free;

	inherited;
end;
{�M���h�@�\�ǉ��R�R�܂�}
//==============================================================================
end.
 

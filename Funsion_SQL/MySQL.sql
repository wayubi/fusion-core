CREATE DATABASE nlogin;
use nlogin;

CREATE TABLE login (
  AID bigint(10) unsigned NOT NULL auto_increment,
  ID varchar(24) NOT NULL,
  passwd varchar(24) NOT NULL,
  Gender tinyint(2) NOT NULL DEFAULT '1',
  Mail varchar(50) NOT NULL DEFAULT '-@-',
  GMMode tinyint(2) NOT NULL DEFAULT '0',
  regDate datetime,
  PRIMARY KEY (AID),
  KEY ID (ID)
) TYPE=MyISAM;

INSERT INTO login (AID, ID, passwd, regDate) VALUES ('100001','gm001','1234',NOW());

CREATE TABLE Characters (
  GID bigint(10) unsigned NOT NULL auto_increment,
  Name varchar(24) NOT NULL,
  JID int(4),
  BaseLV int(4) unsigned,
  BaseEXP bigint(10) unsigned,
  StatusPoint int(4) unsigned,
  JobLV int(4) unsigned,
  JobEXP bigint(10) unsigned,
  SkillPoint int(4) unsigned,
  Zeny bigint(10) unsigned,
  Stat1 int(4),
  Stat2 int(4),
  Options int(4),
  Karma int(4),
  Manner int(4),
  HP int(4) unsigned,
  SP int(4) unsigned,
  DefaultSpeed smallint(2),
  Hair smallint(2),
  _2 smallint(2),
  _3 smallint(2),
  Weapon smallint(2),
  Shield smallint(2),
  Head1 smallint(2),
  Head2 smallint(2),
  Head3 smallint(2),
  HairColor smallint(2),
  ClothesColor smallint(2),
  STR smallint(2),
  AGI smallint(2),
  VIT smallint(2),
  INTS smallint(2),
  DEX smallint(2),
  LUK smallint(2),
  CharaNumber smallint(2),
  Map varchar(24),
  X smallint(2),
  Y smallint(2),
  SaveMap varchar(24),
  SX smallint(2),
  SY smallint(2),
  Plag smallint(2),
  PLv smallint(2),
  AID bigint(10) unsigned NOT NULL,
  PRIMARY KEY (GID),
  UNIQUE KEY Name (Name),
  UNIQUE KEY AID (AID)
) TYPE=MyISAM;

CREATE TABLE warpInfo (
  GID bigint(10) unsigned NOT NULL,
  mapName0 varchar(24) NOT NULL DEFAULT '',
  xPos0 smallint(2),
  yPos0 smallint(2),
  mapName1 varchar(24) NOT NULL DEFAULT '',
  xPos1 smallint(2),
  yPos1 smallint(2),
  mapName2 varchar(24) NOT NULL DEFAULT '',
  xPos2 smallint(2),
  yPos2 smallint(2),
  UNIQUE KEY GID (GID)
) TYPE=MyISAM;

CREATE TABLE skills (
  GID bigint(10) unsigned NOT NULL,
  skillInfo BLOB,
  UNIQUE KEY GID (GID)
) TYPE=MyISAM;

CREATE TABLE item (
  GID bigint(10) unsigned NOT NULL,
  equipItem BLOB,
  UNIQUE KEY GID (GID)
) TYPE=MyISAM;

CREATE TABLE cartItem (
  GID bigint(10) unsigned NOT NULL,
  cartitem BLOB,
  UNIQUE KEY GID (GID)
) TYPE=MyISAM;

CREATE TABLE storeitem (
  AID bigint(10) unsigned NOT NULL,
  storeitem BLOB,
  money int(4) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY AID (AID)
) TYPE=MyISAM;

CREATE TABLE gcastle (
  Name varchar(24) NOT NULL,
  GDID bigint(10) unsigned,
  GName varchar(24),
  GMName varchar(24),
  GKafra int(4),
  EDegree int(4),
  ETrigger int(4),
  DDegree int(4),
  DTrigger int(4),
  GuardStatus0 int(4),
  GuardStatus1 int(4),
  GuardStatus2 int(4),
  GuardStatus3 int(4),
  GuardStatus4 int(4),
  GuardStatus5 int(4),
  GuardStatus6 int(4),
  GuardStatus7 int(4),
  UNIQUE KEY Name (Name)
) TYPE=MyISAM;

CREATE TABLE party (
  GRID bigint(10) unsigned NOT NULL auto_increment,
  Name varchar(24) NOT NULL,
  EXPShare smallint(2) NOT NULL DEFAULT '0',
  ITEMShare smallint(2) NOT NULL DEFAULT '0',
  MemberID0 bigint(10) unsigned, 
  MemberID1 bigint(10) unsigned, 
  MemberID2 bigint(10) unsigned, 
  MemberID3 bigint(10) unsigned, 
  MemberID4 bigint(10) unsigned, 
  MemberID5 bigint(10) unsigned, 
  MemberID6 bigint(10) unsigned, 
  MemberID7 bigint(10) unsigned, 
  MemberID8 bigint(10) unsigned, 
  MemberID9 bigint(10) unsigned, 
  MemberID10 bigint(10) unsigned, 
  MemberID11 bigint(10) unsigned, 
  PRIMARY KEY (GRID)
) TYPE=MyISAM;

CREATE TABLE guildinfo (
  GDID bigint(10) unsigned NOT NULL auto_increment,
  Name varchar(24) NOT NULL,
  LV int(4) unsigned,
  EXP bigint(10) unsigned,
  GSkillPoint int(4) unsigned,
  Subject varchar(60),
  Notice varchar(120),
  Agit varchar(24),
  Emblem int(4) unsigned,
  present bigint(10) unsigned,
  DisposFV int(4),
  DisposRW int(4),
  skill BLOB,
  PRIMARY KEY (GDID)
) TYPE=MyISAM;

CREATE TABLE guildMinfo (
  GDID bigint(10) unsigned NOT NULL,
  GID bigint(10) unsigned,
  MemberExp bigint(10) unsigned,
  PositionID int(4) unsigned,
  UNIQUE KEY GID (GID)
) TYPE=MyISAM;

CREATE TABLE guildMPosition (
  GDID bigint(10) unsigned NOT NULL,
  PosName varchar(24),
  PosInvite smallint(2),
  PosPunish smallint(2),
  PosEXP bigint(10) unsigned,
  UNIQUE KEY GDID (GDID)
) TYPE=MyISAM;

CREATE TABLE guildBanishInfo (
  GDID bigint(10) unsigned NOT NULL,
  MemberName varchar(24),
  MemberAccount varchar(24),
  Reason varchar(50),
  UNIQUE KEY GDID (GDID)
) TYPE=MyISAM;

CREATE TABLE guildAllyInfo (
  GDID bigint(10) unsigned NOT NULL,
  GuildName varchar(24),
  Relation smallint(2),
  UNIQUE KEY GDID (GDID)
) TYPE=MyISAM;

CREATE TABLE pet (
  PID bigint(10) unsigned NOT NULL auto_increment,
  PlayerID bigint(10) unsigned,
  CharaID bigint(10) unsigned,
  Cart int(4),
  PIndex int(4),
  Incubated smallint(2),
  JID int(4),
  Name varchar(24),
  Renamed smallint(2),
  LV int(4) unsigned,
  Relation int(4),
  Fullness int(4),
  Accessory int(4) unsigned,
  PRIMARY KEY (PID)
) TYPE=MyISAM;

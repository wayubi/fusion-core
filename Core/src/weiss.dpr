program Weiss;

{$R 'manifest.res' 'manifest.rc'}

uses
  {$IFDEF MSWINDOWS}
  madExcept,
  Forms,
  {$ENDIF}
  {$IFDEF LINUX}
  QForms,
  {$ENDIF}

  Main in 'CORE\Main.pas' {frmMain},
  Common in 'CORE\Common.pas',
  Globals in 'CORE\Globals.pas',

  Login in 'ZONE\Login.pas',
  CharaSel in 'ZONE\CharaSel.pas',
  Game in 'ZONE\Game.pas',

  Database in 'DATABASE\Database.pas',
  PlayerData in 'DATABASE\PlayerData.pas',

  FusionSQL in 'SQL\FusionSQL.pas',
  SQLData in 'SQL\SQLData.pas',

  MonsterAI in 'AI\MonsterAI.pas',
  Path in 'AI\Path.pas',

  Game_Master in 'FEATURES\Game_Master.pas',
  JCon in 'FEATURES\JCon.pas',
  Player_Skills in 'FEATURES\Player_Skills.pas',
  WeissINI in 'FEATURES\WeissINI.pas',

  GlobalLists in 'OLD\GlobalLists.pas',
  Manifest in 'OLD\Manifest.pas',
  PacketProcesses in 'OLD\PacketProcesses.pas',
  Script in 'OLD\Script.pas',
  Skills in 'OLD\Skills.pas',
  Skill_Constants in 'OLD\Skill_Constants.pas',
  TrimStr in 'OLD\TrimStr.pas',

  Zip in '3RDPARTY\Zip.pas',
  ZipDlls in '3RDPARTY\ZipDlls.pas',
  List32 in '3RDPARTY\List32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'The Fusion Project';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

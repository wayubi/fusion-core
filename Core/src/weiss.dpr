program Weiss;

{$R 'manifest.res' 'manifest.rc'}

uses
  {$IFDEF MSWINDOWS}
  madExcept,
  Forms,
  List32 in '..\lib\List32.pas',
  {$ENDIF}
  {$IFDEF LINUX}
  QForms,
  List32 in '../lib/List32.pas',
  {$ENDIF}
  Main in 'Main.pas' {frmMain},
  Common in 'Common.pas',
  Path in 'Path.pas',
  Login in 'Login.pas',
  CharaSel in 'CharaSel.pas',
  Game in 'Game.pas',
  Database in 'Database.pas',
  Script in 'Script.pas',
  Skills in 'Skills.pas',
  WeissINI in 'WeissINI.pas',
  JCon in 'JCon.pas',
  PlayerData in 'PlayerData.pas',
  SQLData in 'SQLData.pas',
  FusionSQL in 'FusionSQL.pas',
  TrimStr in 'TrimStr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'The Fusion Project';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

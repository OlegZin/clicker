program historica;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {fMain},
  uResourceManager in 'uResourceManager.pas',
  uGameManager in 'uGameManager.pas',
  uTiledModeManager in 'uTiledModeManager.pas',
  uImgMap in 'uImgMap.pas' {fImgMap},
  uGameObjectManager in 'uGameObjectManager.pas',
  DB in 'data\DB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

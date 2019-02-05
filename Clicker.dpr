program Clicker;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {fMain},
  uResourceManager in 'uResourceManager.pas',
  uGameManager in 'uGameManager.pas',
  uTiledModeManager in 'uTiledModeManager.pas',
  uImgMap in 'uImgMap.pas' {fImgMap};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

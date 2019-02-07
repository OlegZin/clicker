unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl, System.ImageList,
  FMX.ImgList, FMX.ExtCtrls, FMX.Objects,

  uResourceManager, uTiledModeManager, uGameManager, uGameObjectManager;

type
  TfMain = class(TForm)
    sbScreen: TScrollBox;
    lNavigation: TLayout;
    sbMenu: TSpeedButton;
    il18: TImageList;
    flResources: TFlowLayout;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    lItems: TLayout;
    lTabs: TLayout;
    lResources: TLayout;
    lTabbed: TLayout;
    tResTimer: TTimer;
    sbItems: TScrollBox;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure tResTimerTimer(Sender: TObject);
    procedure sbItemsHScrollChange(Sender: TObject);
    procedure OnClickCallback(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetTileBitmap(index: integer): TBitMap;

    procedure InitGame;
    procedure SetGameState;
    procedure StartGame;
  end;

var
  fMain: TfMain;

implementation

{$R *.fmx}

uses uImgMap, DB;
{$R *.Macintosh.fmx MACOS}

var
    TileSize: TSizeF;


procedure TfMain.FormCreate(Sender: TObject);
begin
    // ��������� ������ ���������, ��� �������������� ����� ����
    InitGame;

    // ������ �� ����������� ��� ������������������ ������, �������� ���� � �������������� ���������
    SetGameState;

    // ��������� ������� (�������� ������� � ��� �����)
    StartGame;
end;

procedure TfMain.SetGameState;
{ ��������� ���������� � �������� ���� �����, �������� �������� ��������: ���, ������.
  ���������������, ��� ��� ��������� ������� ��� ������� ��� ��������� �� �����.

  � ��������� ��������� ���� ���������:
     - ����������� ������ ������������ � ������ ����� � ������ ��������
     - ���������� ��������� �������� � ����� �� �� ������
     - ����������� ������ ��� �������� ������
     - �������� ������ � ������� ������� � �������������
     - ������ ���� ����� ���� ��������
}
begin

     // ��������� ������ ��������
     // ���������� ��������� ��������, ������ �� ������� ��� � ������
     with mResManager, mGameManager.GameSatate do
     begin
         SetAttr(RESOURCE_IQ, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY, MODE_PLANET])
         );

         SetAttr(RESOURCE_FOOD, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY])
         );

         SetAttr(RESOURCE_HEALTH, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL])
         );

         SetAttr(RESOURCE_MAN, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY, MODE_PLANET])
         );

         SetAttr(RESOURCE_WOMAN, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL]) and
            (Mode in [MODE_LOCAL])
         );

         SetAttr(RESOURCE_WOOD, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY])
         );

         SetAttr(RESOURCE_STONE, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY])
         );

         // �������� �������� ��������� ��������� �������� �� ������
         UpdateResPanel;
     end;

     // ������������� ������ ��� �������� ������
     mTileDrive := TTileModeDrive.Create;
     mTileDrive.SetupComponents(sbScreen);
     mTileDrive.callback := OnClickCallback;
     mTileDrive.BuildField;
     mTileDrive.UpdateField;

end;

function TfMain.GetTileBitmap(index: integer): TBitMap;
begin
//     result := ilObjects.Bitmap(TileSize, index);
end;

procedure TfMain.OnClickCallback(Sender: TObject);
{ �������� ���������� ����� �� �������� �� ������� ����.
  �� �������� ��� ���������� OnClick ���� ��������.
  Sender - ������ TImage ������������ ������ �� ����
  (Sender as TImage).Tag - id ������� � �������
   }
begin
//    ShowMessage( IntToStr( (Sender as TImage).Tag ) );
{
    mResManager.ResCount(RES_WOOD, 1);
    if mResManager.GetCount(RES_WOOD) = 10 then
    mResManager.ResCount(RES_IQ, 1);
}
    mGameManager.ProcessObjectClick( (Sender as TImage).Tag );
end;

procedure TfMain.InitGame;
begin

    // ������� �����, ���������� ���� ���� ������������ � ���� �����������
    fImgMap := TfImgMap.Create(Application);

    // ������� �������� ��������
    mResManager := TResourceManager.Create;
    // ����������� �������� � ������� �����
    mResManager.SetupComponents(lResources, flResources);

    // ������� �������� ������� ������
    mGameManager := TGameManager.Create;
    // �������������� ����
    mGameManager.InitGame;


    TileSize.cx := TILE_HEIGHT;
    TileSize.cy := TILE_WIDTH;


end;

procedure TfMain.StartGame;
begin
    tResTimer.Enabled := true;
end;

procedure TfMain.sbItemsHScrollChange(Sender: TObject);
var
    s: TControlSize;
begin
    s := fMain.sbScreen.Size;
    fMain.Caption := 'cx: ' + floattostr(s.Size.cx) + ' cy: ' + floatTostr(s.Size.cy);
end;

procedure TfMain.tResTimerTimer(Sender: TObject);
begin
   mResManager.OnTimer;
end;

end.

{
// ��������� scrollbox
ScrollBox1.ScrollBy(0, -ScrollBox1.ContentBounds.Height);
}

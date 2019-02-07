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
    // загружаем данные автосейва, или инициализируем новую игру
    InitGame;

    // исходя их загруженных или инициализированных данных, приводим игру в соответсвующее состояние
    SetGameState;

    // запускаем веселье (стартуем таймеры и все такое)
    StartGame;
end;

procedure TfMain.SetGameState;
{ настройка менеджеров и внешнего вида формы, соглвсно текущему стсоянию: эре, режиму.
  подразумевается, что все возможные ресурсы уже созданы или загружены из сейва.

  к настройке состояния игры относится:
     - определение набора используемых в данной эпохе и режиме ресурсов
     - назначение видимости ресурсов и показ их на панели
     - определение движка для текущего режима
     - привязка движка в игровой области и инициализация
     - запуск игры после всех настроек
}
begin

     // настройка панели ресурсов
     // определяем видимость ресурсов, исходя из текущей эры и режима
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

         // менеджер ресурсов обновляет видимость ресурсов на панели
         UpdateResPanel;
     end;

     // инициализация движка для текущего режима
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
{ ключевой обработчик клика по элементу на игровом поле.
  он привязан как обработчик OnClick всех объектов.
  Sender - объект TImage отображающий объект на поле
  (Sender as TImage).Tag - id объекта в массиве
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

    // создаем форму, содержащую базу всех используемых в игре изображений
    fImgMap := TfImgMap.Create(Application);

    // создаем менеджер ресурсов
    mResManager := TResourceManager.Create;
    // привязываем менеджер к главной форме
    mResManager.SetupComponents(lResources, flResources);

    // создаем менеджер игровой логики
    mGameManager := TGameManager.Create;
    // инициализируем игру
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
// прокрутка scrollbox
ScrollBox1.ScrollBy(0, -ScrollBox1.ContentBounds.Height);
}

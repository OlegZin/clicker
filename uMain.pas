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
    ilResources: TImageList;
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

uses uImgMap;
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
         SetAttr(RES_IQ, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY, MODE_PLANET])
         );

         SetAttr(RES_FOOD, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY])
         );

         SetAttr(RES_HEALTH, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL])
         );

         SetAttr(RES_MAN, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL, ERA_TECHNICAL, ERA_ELECTRONIC, ERA_COSMIC, ERA_EXPANSE, ERA_SINGULAR]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY, MODE_PLANET])
         );

         SetAttr(RES_WOMAN, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL]) and
            (Mode in [MODE_LOCAL])
         );

         SetAttr(RES_WOOD, FIELD_VISIBLE,
            (Era in [ERA_PRIMAL, ERA_ANCIENT, ERA_MEDIVAL]) and
            (Mode in [MODE_LOCAL, MODE_COUNTRY])
         );

         SetAttr(RES_STONE, FIELD_VISIBLE,
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
var
   fResFile: File of TResource;
   rResRec : TResource;

   fStateFile: File of TGameState;

   resLoaded          // удалось ли загрузить данные ресурсов из автосейва
  ,stateLoaded        // удалось ли загрузить данные состояния игры из автосейва
           : boolean;
begin

    // создаем форму, содержащую базу всех используемых в игре изображений
    fImgMap := TfImgMap.Create(Application);

    // создаем менеджер ресурсов
    mResManager := TResourceManager.Create;
    // привязываем менеджер к главной форме
    mResManager.SetupComponents(lResources, flResources);
    resLoaded := false;

    // создаем менеджер игровой логики
    mGameManager := TGameManager.Create;
    stateLoaded := false;

    TileSize.cx := TILE_HEIGHT;
    TileSize.cy := TILE_WIDTH;

    // пытаемся считать данные предыдущей сессии игры (автосейв при выходе из игры)
{    if FileExists( FILE_RESOURCES_SAVE ) then
    begin
        try
            AssignFile( fResFile, FILE_RESOURCES_SAVE );

            while not EOF( fResFile ) do
            begin
                Read( fResFile, rResRec );
                mResManager.SetResData( rResRec );
            end;

            resLoaded := true;
            CloseFile( fResFile );
        except
        end;
    end;

    // пытаемся считать данные предыдущей сессии игры (автосейв при выходе из игры)
    if FileExists( FILE_GAMESTATE_SAVE ) then
    begin
        try
            AssignFile( fStateFile, FILE_GAMESTATE_SAVE );

            Read( fStateFile, mGameManager.GameSatate );

            stateLoaded := true;
            CloseFile( fStateFile );
        except
        end;
    end;
 }


    // при неудачной загрузке инициализируем новую игру
    // в этом случае создаем все типы ресурсов из всех эпох, чтобы далее к этому не возвращаться
    if not ( resLoaded and stateLoaded ) then
    with mResManager, mGameManager do
    begin

        // создаем ресурсы
        CreateRecource(RES_IQ,     'Интеллект', ICON_IQ,     0, 0,
            'Потенциал для изобретения новых технологий. Сохраняется при старте новой игры.');

        CreateRecource(RES_FOOD,   'Еда',       ICON_FOOD,   10, -1,
            'При нулевом уровне начинает падать здоровье племени.');

        CreateRecource(RES_HEALTH, 'Здоровье',  ICON_HEALTH, 90, 1,
            'Здоровье самого слабого представителя племени. При падении до нуля - один из членов племени умирает.');
        SetAttr(RES_HEALTH, FIELD_MAXIMUM, 100);

        CreateRecource(RES_MAN,    'Мужчины',   ICON_MAN,    1, 0,
            'Мужчины вашего племени. Занимаются охотой и разборками с другими племенами. При гибели всех - племя погибает.');

        CreateRecource(RES_WOMAN,  'Женщины',   ICON_WOMAN,  0, 0,
            'Женщины вашего племени. Дают прирост к рождаемости, занимаются сбором и ремеслами.');

        CreateRecource(RES_WOOD,   'Дерево',    ICON_WOOD,   0, 0,
            'Обычная древесина. Используется в строительстве, изготовлении инструментов.');

        CreateRecource(RES_STONE,  'Камень',    ICON_STONE,  0, 0,
            'Обычный камень. Используется в строительстве, изготовлении инструментов.');

        GameSatate.Potential := 0;
        GameSatate.Era := ERA_PRIMAL;
        GameSatate.Mode := MODE_LOCAL;
    end;

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

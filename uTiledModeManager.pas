unit uTiledModeManager;

///    МЕНЕДЖЕР РЕЖИМА ИГРЫ ОСНОВОННОЙ НА ТАЙЛАХ
///    данный режим применяется для игры на некой территории (местности):
///        - исследование территорий
///        - постройка города
///
///    каждый тайл имеет 4 признака:
///    - исследование (иначе содержимое скрыто)
///    - тип местности
///    - объект (не всегда. тут же залежи ресурсов)
///    - постройка игрока (не всегда. может быть недоступно из-за типа местности или присутсвующего объекта)

interface

uses
    FMX.Layouts, FMX.Objects, SysUtils, System.Types, FMX.Graphics, FMX.ImgList, uImgMap;

const

    // определение типов тайлов
    // типы местности
    LAND_FOREST = 0;      // лес
    LAND_PLAIN  = 1;     // равнина
    LAND_MOUNT  = 2;     // горы
    LAND_SAND   = 3;     // пустыня
    LAND_ICE    = 4;     // ледник
    LAND_CANYON = 5;     // разлом
    LAND_LAVA   = 6;     // лавовое поле

    // типы объектов
    OBJ_NONE        =  0;  // нет объекта
    OBJ_FOG         =  1;  // тайл еще не исследован (туман войны)
    OBJ_TOWN_SMALL  =  2;  // маленькое поселение
    OBJ_TOWN_MEDIUM =  3;  // среднее поселение
    OBJ_TOWN_BIG    =  4;  // большое поселение
    OBJ_TOWN_GREAT  =  5;  // огромное поселение
    OBJ_PREDATOR    =  6;  // хищник
    OBJ_MAMONT      =  7;  // мамонт (временный)
    OBJ_ATTACKER    =  8;  // атакующее племя (временный)
    OBJ_CAVE        =  9;  // пещера
    OBJ_HERD        = 10;  // стадо (временный)

    MAP_COL_COUNT   = 50;
    MAP_ROW_COUNT   = 50;

    TILE_WIDTH      = 50;
    TILE_HEIGHT     = 50;

type

    { игровой тайтл, содержащий в себе несколько игровых слоев.
      1 - тип местности
      2 - объект
      3 - туман, если сектор еще не исследован
    }
    TTile = record
        Land: smallint;   // тип местности. см. константы LAND_ХХХ
        Obj: smallint;    // тип объекта, если есть
        Fog: boolean;     // скрыт ли сектор туманом неизвестности
    end;

    TTileModeDrive = class
    private
        fScreen : TScrollBox;
        fTiles: array [0..MAP_COL_COUNT, 0..MAP_ROW_COUNT] of TTile;
        fImages: TImageList;
        fViewPort: TLayout;
    public

        procedure SetupComponents(screen: TObject);
                 // ривязываем к движку элемент формы в котором развернем свою деятельность

        procedure BuildField;
                 // формирование игрового поля

        procedure UpdateField;
                 // строим / обновляем игровое поле
    end;

var
    mTileDrive : TTileModeDrive;

implementation

{ TTileModeDrive }

 uses
    uMain;

 var
   BitmapSize: TSizeF;


procedure TTileModeDrive.BuildField;
{ формирование игрового поля }
var
    col, row: integer;
begin

    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    fTiles[col, row].Land := LAND_FOREST;

end;

procedure TTileModeDrive.UpdateField;
var
    col, row: integer;
    image: TImage;
begin

    if Assigned(fViewPort) then FreeAndNil(fViewPort);
    fViewPort := TLayout.Create(fScreen);
    fViewPort.Parent := fScreen;
    fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
    fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;

    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    begin

        image := TImage.Create(fViewPort);
        image.Parent := fViewPort;
        image.Height := TILE_WIDTH;
        image.Width := TILE_HEIGHT;
        image.Position.X := col * TILE_WIDTH;
        image.Position.Y := row * TILE_HEIGHT;

        case fTiles[col,row].Land of
            LAND_FOREST: image.bitmap.Assign( fImgMap.iForest.MultiResBitmap.Bitmaps[1.0] );
        end;

    end;

end;

procedure TTileModeDrive.SetupComponents(screen: TObject);
begin
    fScreen := Screen as TScrollBox;
end;

initialization

    BitmapSize.cx := 50;
    BitmapSize.cy := 50;

finalization

    mTileDrive.Free;

end.

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

    MAP_COL_COUNT   = 50;
    MAP_ROW_COUNT   = 50;

    TILE_WIDTH      = 50;
    TILE_HEIGHT     = 50;

type

    TCallback = procedure (Sender: TObject) of object;

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
        fLand: array [0..MAP_COL_COUNT, 0..MAP_ROW_COUNT] of TTile;
        fObjects: array [0..MAP_COL_COUNT, 0..MAP_ROW_COUNT] of TTile;
        fImages: TImageList;
        fViewPort: TLayout;
    public
        callback : TCallback;

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
    uMain, uGameObjectManager, DB;

 var
   BitmapSize: TSizeF;


procedure TTileModeDrive.BuildField;
{ формирование игрового поля.
 }
var
    col, row: integer;
begin

    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    mngObject.CreateTile( OBJ_DEAD, col, row, 1 );

    for col := 2 to MAP_COL_COUNT - 3 do
    for row := 2 to MAP_ROW_COUNT - 3 do
    mngObject.CreateTile( OBJ_PLAIN, col, row, 2 );

    for col := 4 to MAP_COL_COUNT - 5 do
    for row := 4 to MAP_ROW_COUNT - 5 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_FOREST, col, row, 3 ),
        RESOURCE_WOOD, 50, -10, 1, 0
    );

    mngObject.SetResource(
        mngObject.CreateTile( OBJ_FOG, 0, 0, 10 ),
        RESOURCE_STONE, 50, -10, 0, 0
    );
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_FOG, 1, 1, 10 ),
        RESOURCE_STONE, 50, -10, 0, 0
    );
end;

procedure TTileModeDrive.UpdateField;
var
    layer, index: integer;
    image, source: TImage;
    obj: TBaseObject;
begin

    // полный сброс отображения текущего поля
    if Assigned(fViewPort) then FreeAndNil(fViewPort);
    fViewPort := TLayout.Create(fScreen);
    fViewPort.Parent := fScreen;
    fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
    fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;

    // вывод объектов по слоям, что обеспечивает их привильное перекрытие
    for layer := 0 to mngObject.GetLayerCount do
    begin
        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin
            image := TImage.Create(fViewPort);
            image.Parent := fViewPort;
            image.Tag := obj.id;
            image.OnClick := callback;
            image.Height := TILE_WIDTH;
            image.Width := TILE_HEIGHT;
            image.Position.X := obj.Position.Х * TILE_WIDTH;
            image.Position.Y := obj.Position.Y * TILE_HEIGHT;
            source := TImage(fImgMap.FindComponent( obj.Visualization.Name[ VISUAL_TILE ]) );
            if assigned(source) then image.bitmap.Assign( source.MultiResBitmap.Bitmaps[1.0] );

            obj := mngObject.GetNextOnLayer( layer ) as TResourcedObject;
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

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
    FMX.Layouts, FMX.Objects, SysUtils, System.Types, FMX.Graphics, FMX.ImgList, uImgMap,
    System.UITypes, System.Classes;

type

    TCallback = procedure (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single) of object;
    TMoveCallback = procedure (Sender: TObject; Shift: TShiftState; X, Y: Single) of object;

    TTileModeDrive = class
    private
        fScreen : TScrollBox;
        fViewPort: TLayout;
    public
        UpCallback,
        DownCallback
                : TCallback;
        MoveCallback
                : TMoveCallback;
                 // внешний обработчик, вызываемый при клике по картинке объекта

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

 type
    TImgLink = record
        id : integer;
        img : TImage;
    end;

 var
   BitmapSize: TSizeF;

   arrImgLink: array of TImgLink;
   /// содержит массив связей id с объектами-картинками на поле
   /// заполняется при первоначальном заполнении поля
   /// используется для быстрого поиска объектов-картинок при последующих обновлениях

procedure TTileModeDrive.BuildField;
{ формирование игрового поля.
 }
var
    col, row, id: integer;
begin

    // основа карты
    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    begin
//        mngObject.CreateTile( OBJ_DEAD, col, row, 1 );
        mngObject.CreateTile( OBJ_PLAIN, col, row, 2 );
    end;

    // простые деревья
    for col := 0 to 50 do
    begin
        id := mngObject.CreateTile( OBJ_BUSH, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_WOOD, 10, -1, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;

    for col := 0 to 200 do
    begin
        id := mngObject.CreateTile( OBJ_TREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_WOOD, 50, -2, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_BIGTREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_WOOD, 100, -3, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;

    for col := 0 to 10 do
    begin
        ID := mngObject.CreateTile( OBJ_DEADTREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_WOOD, 200, -2, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;




    // простая трава
    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_PAPOROTNIK, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_GRASS, 30, -1, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_SMALLGRASS, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id,RESOURCE_GRASS, 10, -1, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.1, 0, 0, false );
    end;



    // простые камни
    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_BROVNSTONE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_STONE, 100, -1, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.2, 0, 0, false );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_GRAYSTONE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        mngObject.SetResource( id, RESOURCE_STONE, 300, -2, 0, 0 );
        mngObject.SetResource( id, RESOURCE_IQ, 999, -0.3, 0, 0, false );
    end;



    // еда с растений
    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_MUSH, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_FOOD, 10, -1, 0, 5
    );




    for col := 0 to 10 do
    begin
        id := mngObject.CreateTile( OBJ_BIZON, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 );
        mngObject.SetResource( id, RESOURCE_FOOD, 100, -2, 0, 0 );
        mngObject.SetResource( id, RESOURCE_HIDE, 50, -1, 0, 0 );
        mngObject.SetResource( id, RESOURCE_HEALTH, 0, 1, 0, 0, false );
    end;


    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_APPLETREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_FOOD, 10, -1, 1, 10
    );


    for col := 0 to 10 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_WOLF, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_BONE, 10, -1, 1, 10
    );
    for col := 0 to 10 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BEAR, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_BONE, 10, -1, 1, 10
    );

    for col := 0 to 5 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BLACKWOLF, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_BONE, 10, -1, 1, 10
    );
{
    // горы с ресурсами
    for col := 0 to 100 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_MOUNT, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_STONE, 50, -10, 0, 0
    );

    // лесочки с ресурсами
    for col := 0 to 100 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_FOREST, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 50, -10, 1, 0
    );
}
    // туман войны
    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    if ((col > 2) or (row > 2))
//    if ((col < MAP_COL_COUNT - 3) or (row < MAP_ROW_COUNT - 3))

    then
//       mngObject.CreateTile( OBJ_FOG, col, row, 10 );
end;

procedure TTileModeDrive.UpdateField;
var
    layer: integer;
    image, source: TImage;
    obj: TBaseObject;
    I: Integer;

begin

    // создание поля при запуске
    if not Assigned(fViewPort) then
    begin
        fViewPort := TLayout.Create(fScreen);
        fViewPort.Parent := fScreen;
        fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
        fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;
        fViewPort.SendToBack;
    end;

    for layer := 0 to mngObject.GetLayerCount do
    begin
        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin

            image := nil;

            /// сопоставляем объект массива с картинкой на поле
            for I := 0 to High(arrImgLink) do
            if arrImgLink[i].id = obj.id
            then
            begin
                image := arrImgLink[i].img;
                break;
            end;

            /// если найдена, приводим в соответствие с состоянием объекта
            /// или сначала создаем картинку, если объект новый
            if not assigned( image ) then
            begin
                /// создается объект картинки, позиционируется на поле, назначается картинка
                image := TImage.Create(fViewPort);
                image.Parent := fViewPort;
                image.Tag := obj.id;
                image.OnMouseDown := DownCallback;
                image.OnMouseMove := MoveCallback;
                image.OnMouseUp := UpCallback;
                image.Height := TILE_WIDTH;
                image.Width := TILE_HEIGHT;

                /// запоминаем сопоставление
                SetLength(arrImgLink, Length(arrImgLink) + 1);
                arrImgLink[High(arrImgLink)].id := obj.id;
                arrImgLink[High(arrImgLink)].img := image;
            end;

            image.Visible := obj.visible;
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

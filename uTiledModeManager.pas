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
    System.UITypes, System.Classes, uGameObjectManager;

type

    TCallback = procedure (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single) of object;
    TMoveCallback = procedure (Sender: TObject; Shift: TShiftState; X, Y: Single) of object;

    TTileModeDrive = class
    private
        fScreen : TScrollBox;
        fViewPort: TLayout;

        fSelect_top,
        fSelect_bottom,
        fSelect_right,
        fSelect_left
                : TRectangle;

        function ImgHeight( kind: integer):real;

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

        procedure SetSelection( obj: TResourcedObject );
                 // выделяем кликнутый объект рамкой
        procedure DropSelection;
    end;

var
    mTileDrive : TTileModeDrive;

implementation

{ TTileModeDrive }
 uses
    uMain, DB;

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
    ColMax, RowMax: integer;
    currLayer: integer;
begin

////////////////////////////////////////////////////////////////////////////////
    currLayer := 2;

    // основа карты
    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    begin
//        mngObject.CreateTile( OBJ_DEAD, col, row, 1 );
        mngObject.CreateTile( OBJ_PLAIN, col * TILE_WIDTH, row * TILE_HEIGHT, currLayer, 0 );
    end;

    RowMax := MAP_COL_COUNT * TILE_WIDTH + TILE_WIDTH;
    ColMax := MAP_ROW_COUNT * TILE_HEIGHT + TILE_HEIGHT;



////////////////////////////////////////////////////////////////////////////////
    currLayer := 3;

    // простая трава
    for col := 0 to 1000 do
    begin
        id := mngObject.CreateTile( OBJ_SMALLGRASS, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_SMALLGRASS) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_GRASS, 10 ) .Action( ACT_CLICK, -1,  0.1 ) );
    end;



////////////////////////////////////////////////////////////////////////////////
    currLayer := 4;

    // более редкие растения
    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_PAPOROTNIK, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_PAPOROTNIK) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_GRASS, 30 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_MUSH, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_MUSH) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 50 do
    begin
        id := mngObject.CreateTile( OBJ_WHITE_FLOWERS, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_WHITE_FLOWERS) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 50 do
    begin
        id := mngObject.CreateTile( OBJ_YELLOW_FLOWERS, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_YELLOW_FLOWERS) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 30 do
    begin
        id := mngObject.CreateTile( OBJ_BROWN_FLOWERS, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BROWN_FLOWERS) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_HEALTH, 10 ).Maximum(10).Growing(0.001, 0).Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 30 do
    begin
        id := mngObject.CreateTile( OBJ_BROWN_MUSH, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BROWN_MUSH) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;



////////////////////////////////////////////////////////////////////////////////
    currLayer := 5;

    // простые камни
    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_BROVNSTONE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BROVNSTONE) );
        /// часть ресурса, которую можно собрать быстро
        mngObject.SetResource( id, TResource.Create( RESOURCE_STONE, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
        /// основная часть ресурса
        mngObject.SetResource( id, TResource.Create( RESOURCE_STONE, 500 ).Action( ACT_CLICK, -0.1, 0.1 ).Action( ACT_PICK, -2, 0.2, 10 ) );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_GRAYSTONE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_GRAYSTONE) );
        /// часть ресурса, которую можно собрать быстро
        mngObject.SetResource( id, TResource.Create( RESOURCE_STONE, 30 ) .Action( ACT_CLICK, -1, 0.1 ) );
        /// основная часть ресурса
        mngObject.SetResource( id, TResource.Create( RESOURCE_STONE, 1000 ).Action( ACT_CLICK, -0.1, 0.1 ).Action( ACT_PICK, -2, 0.3, 20 ) );
    end;


    // простые деревья
    for col := 0 to 50 do
    begin
        id := mngObject.CreateTile( OBJ_BUSH, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BUSH) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD, 10 ) .Action( ACT_CLICK, -1, 0.1 ) );
    end;

    for col := 0 to 200 do
    begin
        id := mngObject.CreateTile( OBJ_TREE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_TREE) );
        /// часть ресурса, которую можно собрать быстро
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD,  10 ).Action( ACT_CLICK, -1, 0.1 ) );
        /// основная часть ресурса
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD,  500 ).Action( ACT_CLICK, -0.1, 0.1 ).Action( ACT_AXE, -10, 1, 15 ) );
    end;

    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_BIGTREE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BIGTREE) );
        /// часть ресурса, которую можно собрать быстро
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD,  20 ) .Action( ACT_CLICK, -1, 0.1 ) );
        /// основная часть ресурса
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD,  1000 ).Action( ACT_CLICK, -0.1, 0.1 ).Action( ACT_AXE, -15, 2, 25 ) );
    end;

    for col := 0 to 10 do
    begin
        ID := mngObject.CreateTile( OBJ_DEADTREE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_DEADTREE) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_WOOD,  800 ).Action( ACT_CLICK, -0.1, 0.1 ).Action( ACT_AXE, -5, 1, 10 ) );
    end;



    for col := 0 to 20 do
    begin
        id := mngObject.CreateTile( OBJ_APPLETREE, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_APPLETREE) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 30 ).Maximum( 30 ).Growing( 0.01, 10 ).Action( ACT_CLICK, -1, 0.1 ) );
    end;


    for col := 0 to 10 do
    begin
        id := mngObject.CreateTile( OBJ_BIZON, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BIZON) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_IQ, 20 ).Action( ACT_CLICK, -0.03, 0.01 ).Action( ACT_SPEAR, -1, 0, 3 ) );
    end;

    for col := 0 to 10 do
    begin
        id := mngObject.CreateTile( OBJ_WOLF, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_WOLF) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_IQ, 10 ).Action( ACT_CLICK, -0.03, 0.01 ).Action( ACT_SPEAR, -1, 0, 3 ) );
    end;

    for col := 0 to 10 do
    begin
        id := mngObject.CreateTile( OBJ_BEAR, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BEAR) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_IQ, 50 ).Action( ACT_CLICK, -0.03, 0.01 ).Action( ACT_SPEAR, -1, 0, 3 ) );
    end;

    for col := 0 to 5 do
    begin
        id := mngObject.CreateTile( OBJ_BLACKWOLF, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_BLACKWOLF) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_IQ, 30 ).Action( ACT_CLICK, -0.03, 0.01 ).Action( ACT_SPEAR, -1, 0, 3 ) );
    end;


    for col := 0 to 5 do
    begin
        id := mngObject.CreateTile( OBJ_DEADANIMAL, Random(ColMax)-TILE_WIDTH, Random(RowMax)-TILE_HEIGHT, currLayer, ImgHeight(OBJ_DEADANIMAL) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_FOOD, 20 ).Action( ACT_CLICK, -0.3, 0.01 ).Action( ACT_HAND, -2, 0.5, 5 ) );
        mngObject.SetResource( id, TResource.Create( RESOURCE_HIDE, 10 ).Action( ACT_CLICK, -0.015, 0.02 ).Action( ACT_KNIFE, -1, 0.5, 5 ) );
    end;






////////////////////////////////////////////////////////////////////////////////
    currLayer := 98;
{
    // туман войны
    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    if ((col > 2) or (row > 2))
//    if ((col < MAP_COL_COUNT - 3) or (row < MAP_ROW_COUNT - 3))

    then
    begin
       id := mngObject.CreateTile( OBJ_FOG, col * TILE_WIDTH, row * TILE_HEIGHT, currLayer );
        mngObject.SetResource( id, RESOURCE_IQ, 5, -1, 0, 0 );
    end;
}
    /// оптимизируем порядок объектов по слоям для корректной отрисовки по глубине
    mngObject.OptimizeObjects;
end;

procedure TTileModeDrive.UpdateField;
var
    layer: integer;
    source: TImage;
    obj: TBaseObject;
    I, J: Integer;

begin

    // создание поля при запуске
    if not Assigned(fViewPort) then
    begin
        fViewPort := TLayout.Create(fScreen);
        fViewPort.Parent := fScreen;
        fViewPort.ClipChildren := true;
        fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
        fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;
        fViewPort.SendToBack;
    end;

    for layer := 0 to mngObject.GetLayerCount do
    begin
        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin

            /// или сначала создаем картинку, если объект новый
            if not assigned( obj.image ) then
            begin
                /// создается объект картинки, позиционируется на поле, назначается картинка
                obj.image := TImage.Create(fViewPort);
                TImage(obj.image).Parent := fViewPort;
                TImage(obj.image).Tag := obj.id;
                TImage(obj.image).OnMouseDown := DownCallback;
                TImage(obj.image).OnMouseMove := MoveCallback;
                TImage(obj.image).OnMouseUp := UpCallback;
            end;

            /// приводим в соответствие с состоянием объекта
            TImage(obj.image).Visible := obj.visible;
            TImage(obj.image).Position.X := obj.Position.Х;
            TImage(obj.image).Position.Y := obj.Position.Y;// - image.Height;
            source := TImage(fImgMap.FindComponent( obj.Visualization.Name[ VISUAL_TILE ]) );
            if assigned(source) then
            begin
                TImage(obj.image).Height := source.Height;
                TImage(obj.image).Width := Source.Width;
                TImage(obj.image).bitmap.Assign( source.MultiResBitmap.Bitmaps[1.0] );
            end;

            /// берем следующий объект слоя
            obj := mngObject.GetNextOnLayer( layer ) as TResourcedObject;

        end;
    end;
end;

procedure TTileModeDrive.DropSelection;
/// сбрасываем выделение с текущего объекта
begin
    if not Assigned(fSelect_top) then exit;
    fSelect_top.Visible := false;
    fSelect_bottom.Visible := false;
    fSelect_right.Visible := false;
    fSelect_left.Visible := false;
end;

function TTileModeDrive.ImgHeight(kind: integer): real;
var
    aname: string;
begin
    aname := TableObjects[ kind, TABLE_FIELD_TILE_IMAGE ];
    result := TImage(fImgMap.FindComponent( aname )).Height;
end;

procedure TTileModeDrive.SetSelection( obj: TResourcedObject );
/// программно создаем рамку выделения на указанном объекте
/// уже известно, что данный объект еще не выделен
var
    shift : integer;

    procedure CreateElement( var rect: TRectangle );
    begin
        rect := TRectangle.Create(nil);
        rect.Parent := fViewPort;
        rect.Visible := false;
        rect.Stroke.Kind := TBrushKind.None;
        rect.Fill.Color := TAlphaColorRec.White;
    end;
begin
    if not assigned(obj.Image) then exit;

    shift := 5;

    /// проверка на существование объектов, из которых состояит выделение
    if not Assigned(fSelect_top) then
    begin
        CreateElement( fSelect_top );
        CreateElement( fSelect_bottom );
        CreateElement( fSelect_left );
        CreateElement( fSelect_right );
    end;

    fSelect_top.BringToFront;
    fSelect_top.Position.X := TImage(obj.Image).Position.X + shift;
    fSelect_top.Position.Y := TImage(obj.Image).Position.Y;
    fSelect_top.Height := 1;
    fSelect_top.Width := TImage(obj.Image).Width - shift * 2;
    fSelect_top.Visible := true;

    fSelect_bottom.BringToFront;
    fSelect_bottom.Position.X := TImage(obj.Image).Position.X + shift;
    fSelect_bottom.Position.Y := TImage(obj.Image).Position.Y + TImage(obj.Image).Height;
    fSelect_bottom.Height := 1;
    fSelect_bottom.Width := TImage(obj.Image).Width - shift * 2;
    fSelect_bottom.Visible := true;

    fSelect_left.BringToFront;
    fSelect_left.Position.X := TImage(obj.Image).Position.X;
    fSelect_left.Position.Y := TImage(obj.Image).Position.Y + shift;
    fSelect_left.Height := TImage(obj.Image).Height - shift * 2;
    fSelect_left.Width := 1;
    fSelect_left.Visible := true;

    fSelect_right.BringToFront;
    fSelect_right.Position.X := TImage(obj.Image).Position.X + TImage(obj.Image).Width;
    fSelect_right.Position.Y := TImage(obj.Image).Position.Y + shift;
    fSelect_right.Height := TImage(obj.Image).Height - shift * 2;
    fSelect_right.Width := 1;
    fSelect_right.Visible := true;
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

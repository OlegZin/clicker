unit uTiledModeManager;

///    �������� ������ ���� ���������� �� ������
///    ������ ����� ����������� ��� ���� �� ����� ���������� (���������):
///        - ������������ ����������
///        - ��������� ������
///
///    ������ ���� ����� 4 ��������:
///    - ������������ (����� ���������� ������)
///    - ��� ���������
///    - ������ (�� ������. ��� �� ������ ��������)
///    - ��������� ������ (�� ������. ����� ���� ���������� ��-�� ���� ��������� ��� �������������� �������)

interface

uses
    FMX.Layouts, FMX.Objects, SysUtils, System.Types, FMX.Graphics, FMX.ImgList, uImgMap,
    System.UITypes, System.Classes;

type

    TCallback = procedure (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single) of object;

    TTileModeDrive = class
    private
        fScreen : TScrollBox;
        fViewPort: TLayout;
    public
        callback : TCallback;
                 // ������� ����������, ���������� ��� ����� �� �������� �������

        procedure SetupComponents(screen: TObject);
                 // ���������� � ������ ������� ����� � ������� ��������� ���� ������������

        procedure BuildField;
                 // ������������ �������� ����

        procedure UpdateField;
                 // ������ / ��������� ������� ����
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
   /// �������� ������ ������ id � ���������-���������� �� ����
   /// ����������� ��� �������������� ���������� ����
   /// ������������ ��� �������� ������ ��������-�������� ��� ����������� �����������

procedure TTileModeDrive.BuildField;
{ ������������ �������� ����.
 }
var
    col, row, id: integer;
begin

    // ������ �����
    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    begin
//        mngObject.CreateTile( OBJ_DEAD, col, row, 1 );
        mngObject.CreateTile( OBJ_PLAIN, col, row, 2 );
    end;

    // ������� � ���������
    for col := 0 to 200 do
    begin
        mngObject.SetResource( mngObject.CreateTile( OBJ_TREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 50, -2, 0, 0 );
    end;

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BUSH, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 10, -1, 0, 0
    );

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BIGTREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 100, -3, 0, 0
    );

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_DEADTREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 1000, -2, 0, 0
    );



    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_PAPOROTNIK, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_GRASS, 10, -1, 1, 10
    );

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_SMALLGRASS, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_GRASS, 10, -1, 1, 10
    );



    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_APPLETREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_FOOD, 10, -1, 1, 10
    );


    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_GRAYSTONE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_STONE, 10, -1, 1, 10
    );

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BROVNSTONE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_STONE, 10, -1, 1, 10
    );

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_MUSH, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_FOOD, 10, -1, 1, 10
    );



    for col := 0 to 10 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_WOLF, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_BONE, 10, -1, 1, 10
    );
    for col := 0 to 10 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BIZON, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_FOOD, 10, -1, 1, 10
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
    // ���� � ���������
    for col := 0 to 100 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_MOUNT, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 4 ),
        RESOURCE_STONE, 50, -10, 0, 0
    );

    // ������� � ���������
    for col := 0 to 100 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_FOREST, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_WOOD, 50, -10, 1, 0
    );
}
    // ����� �����
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

    procedure SetAttr;
    begin
        image.Visible := obj.visible;
        image.Position.X := obj.Position.� * TILE_WIDTH;
        image.Position.Y := obj.Position.Y * TILE_HEIGHT;
        source := TImage(fImgMap.FindComponent( obj.Visualization.Name[ VISUAL_TILE ]) );
        if assigned(source) then image.bitmap.Assign( source.MultiResBitmap.Bitmaps[1.0] );
    end;

    procedure CreateImg;
    begin
        /// ��������� ������ ��������, ��������������� �� ����, ����������� ��������
        image := TImage.Create(fViewPort);
        image.Parent := fViewPort;
        image.Tag := obj.id;
        image.OnMouseUp := callback;
        image.Height := TILE_WIDTH;
        image.Width := TILE_HEIGHT;

        /// ���������� �������������
        SetLength(arrImgLink, Length(arrImgLink) + 1);
        arrImgLink[High(arrImgLink)].id := obj.id;
        arrImgLink[High(arrImgLink)].img := image;
    end;

begin

    // �������� ���� ��� �������
    if not Assigned(fViewPort) then
    begin
        fViewPort := TLayout.Create(fScreen);
        fViewPort.Parent := fScreen;
        fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
        fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;
    end;

    for layer := 0 to mngObject.GetLayerCount do
    begin
        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin

            image := nil;

            /// ������������ ������ ������� � ��������� �� ����
            for I := 0 to High(arrImgLink) do
            if arrImgLink[i].id = obj.id
            then
            begin
                image := arrImgLink[i].img;
                break;
            end;

            /// ���� �������, �������� � ������������ � ���������� �������
            /// ��� ������� ������� ��������, ���� ������ �����
            if not assigned( image ) then CreateImg;
            SetAttr;

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

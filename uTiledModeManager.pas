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
    FMX.Layouts, FMX.Objects, SysUtils, System.Types, FMX.Graphics, FMX.ImgList, uImgMap;

type

    TCallback = procedure (Sender: TObject) of object;

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

 var
   BitmapSize: TSizeF;


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
        mngObject.CreateTile( OBJ_DEAD, col, row, 1 );
        mngObject.CreateTile( OBJ_PLAIN, col, row, 2 );
    end;

    // ������� � ���������
    for col := 0 to 100 do
    begin
        id := mngObject.CreateTile( OBJ_TREE, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 );
        if id >= 0
        then mngObject.SetResource( id, RESOURCE_WOOD, 50, -10, 1, 0 );
    end;

    for col := 0 to 20 do
    mngObject.SetResource(
        mngObject.CreateTile( OBJ_BERRY, Random(MAP_COL_COUNT), Random(MAP_ROW_COUNT), 3 ),
        RESOURCE_FOOD, 10, -1, 1, 10
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
    mngObject.CreateTile( OBJ_FOG, 0, 0, 10 );
    mngObject.CreateTile( OBJ_FOG, 1, 1, 10 );
end;

procedure TTileModeDrive.UpdateField;
var
    layer: integer;
    image, source: TImage;
    obj: TBaseObject;
begin

    // ������ ����� ����������� �������� ����
    if Assigned(fViewPort) then FreeAndNil(fViewPort);
    fViewPort := TLayout.Create(fScreen);
    fViewPort.Parent := fScreen;
    fViewPort.Width := MAP_COL_COUNT * TILE_WIDTH;
    fViewPort.Height := MAP_ROW_COUNT * TILE_HEIGHT;

    // ����� �������� �� �����, ��� ������������ �� ���������� ����������
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
            image.Position.X := obj.Position.� * TILE_WIDTH;
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

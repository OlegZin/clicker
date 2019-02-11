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

const

    MAP_COL_COUNT   = 50;
    MAP_ROW_COUNT   = 50;

    TILE_WIDTH      = 50;
    TILE_HEIGHT     = 50;

type

    TCallback = procedure (Sender: TObject) of object;

    { ������� �����, ���������� � ���� ��������� ������� �����.
      1 - ��� ���������
      2 - ������
      3 - �����, ���� ������ ��� �� ����������
    }
    TTile = record
        Land: smallint;   // ��� ���������. ��. ��������� LAND_���
        Obj: smallint;    // ��� �������, ���� ����
        Fog: boolean;     // ����� �� ������ ������� �������������
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

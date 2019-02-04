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
    FMX.Layouts, FMX.Objects, SysUtils, System.Types, FMX.Graphics, FMX.ImgList;

const

    // ����������� ����� ������
    // ���� ���������
    LAND_FOREST = 0;      // ���
    LAND_PLAIN  = 1;     // �������
    LAND_MOUNT  = 2;     // ����
    LAND_SAND   = 3;     // �������
    LAND_ICE    = 4;     // ������
    LAND_CANYON = 5;     // ������
    LAND_LAVA   = 6;     // ������� ����

    // ���� ��������
    OBJ_NONE        =  0;  // ��� �������
    OBJ_FOG         =  1;  // ���� ��� �� ���������� (����� �����)
    OBJ_TOWN_SMALL  =  2;  // ��������� ���������
    OBJ_TOWN_MEDIUM =  3;  // ������� ���������
    OBJ_TOWN_BIG    =  4;  // ������� ���������
    OBJ_TOWN_GREAT  =  5;  // �������� ���������
    OBJ_PREDATOR    =  6;  // ������
    OBJ_MAMONT      =  7;  // ������ (���������)
    OBJ_ATTACKER    =  8;  // ��������� ����� (���������)
    OBJ_CAVE        =  9;  // ������
    OBJ_HERD        = 10;  // ����� (���������)

    MAP_COL_COUNT   = 50;
    MAP_ROW_COUNT   = 50;

    TILE_WIDTH      = 50;
    TILE_HEIGHT     = 50;

type

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
        fScreen : TImage;
        fTiles: array [0..MAP_COL_COUNT, 0..MAP_ROW_COUNT] of TTile;
        fImages: TImageList;
    public

        procedure SetupComponents(screen: TImage; list: TImageList);
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
    uMain;

 var
   BitmapSize: TSizeF;


procedure TTileModeDrive.BuildField;
{ ������������ �������� ���� }
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
    bm :TBitMap;
    size: TSizeF;
    sourceRect, targetRect: TrectF;
begin

    bm := TBitmap.Create;
    //bm.Transparent:=true;
    size.cx := TILE_HEIGHT;
    size.cy := TILE_WIDTH;

    sourceRect.Left := 0;
    sourceRect.Top := 0;
    sourceRect.Width := TILE_WIDTH;
    sourceRect.Height := TILE_HEIGHT;

    bm := TBitmap.Create;

{    // �����������
    if Assigned(fViewPort) then
    begin
        FreeAndNil(fViewPort);
        fViewPort := TLayout.Create(fScreen);
        fViewPort.Visible := false;
    end;
}
//    fScreen.Bitmap.Canvas.BeginScene;

    for col := 0 to MAP_COL_COUNT - 1 do
    for row := 0 to MAP_ROW_COUNT - 1 do
    begin

        targetRect.Left := col * TILE_WIDTH;
        targetRect.Top := row * TILE_HEIGHT;
        targetRect.Width := TILE_WIDTH;
        targetRect.Height := TILE_HEIGHT;

        bm := fImages.Bitmap(size, fTiles[col,row].Land);

        fScreen.Bitmap.Canvas.DrawBitmap(
            bm,
            sourceRect,
            targetRect,
            1,
            false);

    end;

//    fScreen.Bitmap.Canvas.EndScene;

end;

procedure TTileModeDrive.SetupComponents(screen: TImage; list: TImageList);
begin
    fScreen := Screen;
    fImages := list;
end;

initialization

    BitmapSize.cx := 50;
    BitmapSize.cy := 50;

finalization

    mTileDrive.Free;

end.

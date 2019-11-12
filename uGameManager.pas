unit uGameManager;

///    �������� ������� ������
///    ������ �� ������� �������:
///      - ���������� ������� ��� �������� ����� ������������ (����, �����, ����� � �.�.)
///      - ������������ ����
///      - ��������� �� ������ ������� �������

interface

const
    FILE_RESOURCES_SAVE = 'resources.dat';
    FILE_GAMESTATE_SAVE = 'gamestate.dat';

    ///    ��������� �����
    ///    - ��������� (� ����� ����� �������� ������)
    ///    - ������ (� ����� ������� ������� �������� ������)
    ///
    ERA_PRIMAL     = 1;         // ����������� �������� (�������� ���)
    ERA_ANCIENT    = 2;         // ������� ��� (����������)
    ERA_MEDIVAL    = 4;         // ������� ����
    ERA_TECHNICAL  = 8;         // ����� ��� (����������� ���������)
    ERA_ELECTRONIC = 16;        // �������� ��� (������������� � ������������)
    ERA_COSMIC     = 32;        // ����������� ��� (������ ��������� �������)
    ERA_EXPANSE    = 64;        // ��� ��������� ��������� ������� (������ ��������� �������)
    ERA_SINGULAR   = 128;       // ��� ������������� (������� ������������ �������������)

    ///    ���� �������
    ///    � ����������� �� ������� ��� ���� ������ � ������ �� �����������,
    ///    �� ���������� �� �������� � ������ �������
    MODE_LOCAL     = 1;         // ����� ����������� ������� (��������� ������, ������������ ����������)
    MODE_COUNTRY   = 2;         // ����� ���������� ����������� (������, ������)
    MODE_PLANET    = 4;         // ����� ���������� ����������� (������, ������)

type
    TGameState = record
        Potential: Currency;          // ������� ���������, ������� �� �������� ��� ������ ����� ����
                                       // � �������� ����� �� ��������
        Era      : Integer;           // ������� ������� ���. ������������ ��������� TAG_ERA_XXX
        Mode     : Integer            // ������� ������� �����. ������������ ��������� TAG_MODE_XXX
    end;

    TGameManager = class
        GameSatate : TGameState;

        procedure ProcessObjectClick( id : integer );
        procedure InitGame;
        procedure CalcGameState;
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager, DB;

procedure TGameManager.CalcGameState;
///    ���������� ����.
///    ����� ���������� ��������, ������ ������, ��� ������������� ����.

///    ��� ��������� ��������� �������� ��� ���� �������� �������� ����������
///    ���������� ��������� ���� � ������ ��������� � �������, ���� �����������
///    ����������� �������.
///    ��������, ��� ���������� ����� ���������� �������, ����� ��������� �����������
///    ������ ������ ��������

///    �������� ���������� ��� ���� �������� �� DB.logic - �������, ��� �����������
///    ���������� ��� ��������� � ���� ������� ������� ��� �������
///    ��� ���������� ���������, ��� ������� ������������ ���� ���������, �����
///    ������������. ����� ���� ����������� ������ �������� ��������������
///    ��������������
begin

end;

procedure TGameManager.InitGame;
var
   fResFile: File of TResource;
   rResRec : TResource;

   fStateFile: File of TGameState;

   resLoaded          // ������� �� ��������� ������ �������� �� ���������
  ,stateLoaded        // ������� �� ��������� ������ ��������� ���� �� ���������
           : boolean;
begin
    // �������� ������� ������ ���������� ������ ���� (�������� ��� ������ �� ����)
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

    // �������� ������� ������ ���������� ������ ���� (�������� ��� ������ �� ����)
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


    // ��� ��������� �������� �������������� ����� ����
    // � ���� ������ ������� ��� ���� �������� �� ���� ����, ����� ����� � ����� �� ������������
//    if not ( resLoaded and stateLoaded ) then
    with mResManager, mGameManager do
    begin

        // ������� �������: ���, ��������� ����������, ��������� �� ��� �������
        CreateRecource( RESOURCE_IQ,      0,   0  );
        CreateRecource( RESOURCE_HEALTH, 29,  0.1 );
        CreateRecource( RESOURCE_MAN,     1,   0  );
        CreateRecource( RESOURCE_WOMAN,   0,   0  );
        CreateRecource( RESOURCE_WOOD,    0,   0  );
        CreateRecource( RESOURCE_GRASS,   0,   0  );
        CreateRecource( RESOURCE_STONE,   0,   0  );
        CreateRecource( RESOURCE_ICE,     0,   0  );
        CreateRecource( RESOURCE_LAVA,    0,   0  );
        CreateRecource( RESOURCE_FOOD,   10, -0.1 );
        CreateRecource( RESOURCE_BONE,    0,   0  );
        CreateRecource( RESOURCE_PRODUCT, 1,   0  );


        SetAttr(RESOURCE_HEALTH, FIELD_MAXIMUM, 100);
        SetAttr(RESOURCE_PRODUCT, FIELD_VISIBLE, true);
//        SetAttr(RESOURCE_FOOD, FIELD_VISIBLE, true);

        GameSatate.Potential := 0;
        GameSatate.Era := ERA_PRIMAL;
        GameSatate.Mode := MODE_LOCAL;
    end;

end;

procedure TGameManager.ProcessObjectClick(id: integer);
var
    obj : TBaseObject;
    i: integer;
    resTile: uGameObjectManager.TResource;

    deltaSource
   ,deltaTarget : real;

    hasChanges: boolean;

begin

    hasChanges := false;

    // �������� ������ �� ������� �� �������
    obj := mngObject.FindObject( id );

    // ����� ������������, ���� �� ����� ��������� � �������� �������
    if obj is TResourcedObject then
    if   Length((obj as TResourcedObject).Recource) > 0 then

    // ���������� ��� ��������� � ������� ������� � ���������� �� ��������
    for I := 0 to High((obj as TResourcedObject).Recource) do
    begin
        // �������� ���������� ���
        resTile := (obj as TResourcedObject).Recource[i];

        ///    ������ ��������� ���������. ��� ����� �� ������� �� Once
        ///    (�������� �� ����) ����� ������������� ��������, ���
        ///    ��������� ����� � ������� ( Count ), �� ��� ����, � �����
        ///    ��������� ����� ������ �������������. �.�. ������� � �������� ������
        ///    � �� ������, ��� ������ ���� �� ������� �������������������
        ///    ��������, ��� ������ � ��� ��� ����� ����������� ���-�� �� ��������

        // ��������� ����������� ������ �������
        // ������������ ������ � �������
        deltaSource :=
        mResManager.TargetResCount(
            resTile,                                                // ���������� ������
            CALC_MODE_VALUE,                                        // �������� �� ��������� ����������
            resTile.Item.Once.current + resTile.Item.Once.bonus     // ���������� �� ���������
        );

        // ���� ��������� ���������� ������� �� ��������� (��������� ������� ��� ������ �����)
        // � ���������� ��������� ������ ���� �� �����
        if deltaSource <> 0 then

        // ������������� � ���������� ���������
        mResManager.ResCount(
            CALC_MODE_VALUE,                                        // �������� �� ��������� ����������
            resTile.Identity.Common,                                // ��� ����������� �������
            -(deltaSource)  // ���������� �� ���������
        );
        ///    ��� ����� ����� ��������� �������� � ������ CALC_MODE_CLICK,
        ///    �� ��� ���� ������ ������������ ��������� �������� ���������
        ///    ������ ������� �� ���������, � �� �������������� ���������
        ///    ����� �������.
        ///    ������ ������������ ����� CALC_MODE_VALUE, ����� ���������
        ///    �������������� ����������� �������

        // ������ ���� ���������, ����� ��������� �������� ��������� ����
        hasChanges := true;

    end;

    // ������������� ��������� ����
    if hasChanges then CalcGameState;

end;

end.

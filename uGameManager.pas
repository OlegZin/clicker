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

    /// ����� ������, ������������ �������, ����������� ProcessObjectClick
    /// ����� ��������� � �������� ���� ���������� ����������, ����� ��� ����������
    /// ��������, ���������� ������������ ��� ��������� �������� �� ����

    PROCESS_CHANGE_FIELD = 1;  // ���������� ��������� ������� �� ����

type
    TGameState = record
        Potential: Currency;          // ������� ���������, ������� �� �������� ��� ������ ����� ����
                                       // � �������� ����� �� ��������
        Era      : Integer;           // ������� ������� ���. ������������ ��������� TAG_ERA_XXX
        Mode     : Integer;            // ������� ������� �����. ������������ ��������� TAG_MODE_XXX
        CurSelObjectId: integer;      // ������� ��������� �� ������� ���� ������. 0 - �� ������
    end;

    TGameManager = class
        GameSatate : TGameState;

        function ProcessObjectClick( id : integer ): integer;
        procedure InitGame;
        procedure CalcGameState;
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager, uTiledModeManager, DB, uToolPanelManager;

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
        CreateRecource( RESOURCE_SPEAR,   5,   0  );
        CreateRecource( RESOURCE_SKIN,    3,   0  );
        CreateRecource( RESOURCE_HIDE,    8,   0  );


        SetAttr(RESOURCE_HEALTH, FIELD_MAXIMUM, 100);
        SetAttr(RESOURCE_PRODUCT, FIELD_VISIBLE, true);
        SetAttr(RESOURCE_GRASS, FIELD_VISIBLE, true);
        SetAttr(RESOURCE_SPEAR, FIELD_VISIBLE, true);
        SetAttr(RESOURCE_SKIN, FIELD_VISIBLE, true);
        SetAttr(RESOURCE_HIDE, FIELD_VISIBLE, true);

        GameSatate.Potential := 0;
        GameSatate.Era := ERA_PRIMAL;
        GameSatate.Mode := MODE_LOCAL;
    end;

end;

function TGameManager.ProcessObjectClick(id: integer): integer;
var
    obj : TBaseObject;
    i: integer;
    resTile: uGameObjectManager.TResource;

    deltaSource
   ,deltaTarget : real;

    hasChanges
   ,ResIsOut   // ������� ����, ��� �� ������� ����������� ��� ��������� ��������,
               // � �� ������ ���� �� ���������. ��� ��������� ������������ �������
               // �� ��� ���, ���� �� �� ����� �������� ���������
            : boolean;
begin


    hasChanges := false;
    ResIsOut := true;
    result := 0;

    // �������� ������ �� ������� �� �������
    obj := mngObject.FindObject( id );

    /// ������� ���������� ������ �� ��������� � ����������
    if   mGameManager.GameSatate.CurSelObjectId <> id then
    begin
        // �������� ��������� ������, ���� �� ��� ��� �� ������
        mTileDrive.SetSelection( obj as TResourcedObject );
        // ���������� ��� �� ������ �������/��������
        mToolPanel.ObjectSelect( obj as TResourcedObject );
    end;

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



        /// ���� ������ ������ ��� �� ��������, ������ ����, ��� ������ �� �����
        /// ����������, ������� �� ��������� ���������� ������ ��������
        if ( resTile.Item.Count.current > resTile.Item.Min.current ) and
           ( resTile.Valued )
        then ResIsOut := false;

    end;

    if ResIsOut then
    begin
        /// ��������� ���� �������� ��� ���� ������ ���� ��������� ��� �������� �������
        /// ��������, ������ ���������� �������, ���� � ������� - ������� ������
{        case obj.Identity.Common of
            /// ������� ��������� ������� ������ ���������
            OBJ_BUSH,
            OBJ_TREE,
            OBJ_BIGTREE,
            OBJ_DEADTREE,

            OBJ_SMALLGRASS,
            OBJ_PAPOROTNIK,

            OBJ_BROVNSTONE,
            OBJ_GRAYSTONE,

            OBJ_MUSH,

            OBJ_BIZON
            :
                mngObject.RemoveTile( obj.id );
            else mngObject.RemoveTile( obj.id );
        end;
}
        /// ���� ��� ������������ ��� �������, ����� ���������
        if obj.Identity.Common > OBJ_DEAD then
        begin
           mngObject.RemoveTile( obj.id );
           mTileDrive.DropSelection;
        end;

        result := result or PROCESS_CHANGE_FIELD;
    end;

    // ������������� ��������� ����
    if hasChanges then CalcGameState;

end;

end.

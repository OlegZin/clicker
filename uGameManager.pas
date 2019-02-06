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
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager;

procedure TGameManager.ProcessObjectClick(id: integer);
var
    obj : TBaseObject;
begin
    obj := mngObject.FindObject( id );
    if obj is TResoursed then
    begin
        // ���� �������� ���� �� ���� ������
        if   Length((obj as TResoursed).Recource) > 0
        then mResManager.ResCount(RES_WOOD, 1);
    end;

end;

end.

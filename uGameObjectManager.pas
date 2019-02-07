unit uGameObjectManager;
{ ������ ��������� ��������.
  ��������� � �������� ��� ���� �������� (������, ������������, �������� � �.�),
  � ��� �� ������������� ��������� ��� ��������������� ���.

  ������ ������ �������� ����� ���������� ����������������, ������������
  ������������ ��� � ����� ������� ������� (��������, ���������, ��������� � �.�.)

}
interface

const

    // ������������ ���������� �����
    LAYER_COUNT = 99;

    // ����� ��� ���� ����������� � �������  TVisualization.Name / TVisualization.Id
    VISUAL_TILE = 0;
    VISUAL_ICON = 1;

type

    TBaseObject = class;

    // �������� �� ���������������� � 2d/3d ���������
    TPosition = record
        �, Y, Z: real;
    end;

    // ����� ������������ ����� ���������
    TIdentity = record
        Common                       // ����� ����������������� ����� (��������� ��������, ���������,.. )
       ,Rare                         // ���������� �������� (���, ����, ��������, �������,.. )
       ,Unique                       // ���������� ��� (�������� ���, ������� ��������,.. )
                : integer;

        CommonTag                    // �� ������ ���������� �����������, �� �������� ����
       ,RareTag                      // ��� ��������� ��������� ����� (�����) � �����������
       ,UniqueTag                    // ����� �������
                : string;
    end;

    TRelations = record
        Parent  : array of integer;  // ��������(-�), � ������� ��������
        Child   : array of integer;  // �������(-��), ������� �� ���� ���������
        Together: array of integer;  // ����������� � ��� �� ��������� �������� ������
    end;

    TVisualization = record
        Name: array [0..9] of string;  // ����� ���� ����������� ��� ��������� ������� �������
        Id  : array [0..9] of integer; // ����� �������� ����������� ��� ��������� �������
    end;

    TFloatValue = record
        current                      // ������� ��������
       ,delta                        // �������� �������� ��������� (+/-) ��� ��������
       ,bonus                        // ������� ��������� �����
       ,bonusPeriod                  // ���������� ����� ���������� ������ � �����
                : real;
    end;

    // ��������� ������� ��������� � ������ ��������� ���������� ��������
    TCount = record
        Count                        // ������� ��������
       ,Period                       // ������ � ����� ������� ���������� ��������

       ,Delta                        // ������ �������� �������� ��������� ��� ����.
       ,Once                         // ������ �������� �������� ��������� ��� ������� ������.
                                     // ��������, ��� ����� �� ���� ������� ����� ������ ���������

       ,Max                          // ����������� ��������� ������� ��������

       ,Min                          // ���������� ��������� ������� ��������
                : TFloatValue;

        PassTicks: integer;          // ������� ����������� �����. ����� ������������ �
                                     // Period.current, ������������ �� 0 � ������������
                                     // ���������� Delta.current � Count.current
    end;

    // ������ � ������� ������� �������
    TBaseObject = class
        id: integer;                   // ���������� � ������ ����� ���� �������������
        Name : string;
        Description : string;

        Identity: TIdentity;           // ������������ ����� ���������
        Relation: TRelations;          // ����� ������ � ������� ���������
        Position: TPosition;           // ��������� � ����� ������� ������������
        Dependence: TRelations;        // ����� ������������ ��������. ��������,
                                       // ������ ����������, ����� �������� ��� ������
        Visualization: TVisualization; // ������ �� ������� ����������� � ������ ����������

        constructor Create; overload;
    end;

    TResource = class(TBaseObject)
        Item: TCount;
        constructor Create(kind: integer); overload;
    end;

    // ������, ������������ �������/������� �������� ���� � ����������� �����������
    // ����� ��������� ��������� ��������
    TResourcedObject = class(TBaseObject)
        Recource: array of TResource;
    end;

    TObjectManager = class
      private
        fObjects: array [0..LAYER_COUNT] of array of TBaseObject;
        ///    ��� ��������� � ���� �������.
        ///    ������ ������ - ����, �� ������� ��������� ������
        ///    ������ ������ - ����������� � ������� ���� �������� �� ������ ����
        ///
        ///    ���� ������� �� ������ ��������. ��������, ��� ����������� ��������� ��������
        ///    �� ������� ���� ��� ����������� ����������.
        ///    ��� ��� ����������� �������� �������� ��� ��������� ����: ������/��������,
        ///    ��������������, �����������.
        ///    � ������ ������, ��� ��������� ��������� ���������� �������� ������������� ���� �����
        ///    ������� ��������, ����� �������, ����� ����� �����. ��� �������
        ///    ����������� ��������, ���� ����������, � ����� ����������� ���.

        fLayerIndex: array [0..LAYER_COUNT] of integer;
        ///    ������ �������� ������� ��������� �������� �� ������ ����
        ///    �� ������ �� ����.
        ///    ������������ ��� ��������� �������� �������� ���� ��������
        ///    GetFirstOnLayer � GetNextOnLayer
        ///    ��� �����������, ��������, ��� ��������� ����, ������ ���� ��������������
        ///    � ����������� ���������� �������

        function GetId( layer: integer ): integer;
        ///    ���������� ���������� id ��� ������ �������.
        ///    ��������� �� ������ ������ ���� � ������� ������� � ������� ������� ����.
        ///    ��� ��������� �� ������ id ���������� ��������� ������ �������
        ///    �� �������� ������� ����� � ��������.
        ///    ���������������, ��� ��������� �������� � ������� �������� �
        ///    ���������� ���������� �� ��������� �� �������, � ������ ���������� nil

        procedure AddObjectToArray( obj: TBaseObject; layer: integer );
        ///    ��������� ������ � ����� ������� ���������� ����

      public

        function GetLayerCount: integer;
        ///    ���������� ������������ ��������� ������ ����

        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;
        ///    ������, ����������� ��������������� ��������� ��� �������
        ///    ���������� ����, ��� �������, �� ������, ��� ��������� ����

        function CreateTile( Kind, X, Y, layer: integer ): integer;
        ///    ������� ����� ������� ��� ������� � ���������� ��� id

        procedure SetResource( id, Kind: integer; Count, Once, Delta, Period: real );
        ///    �������������� � ����������� ������ � ���������� �������, �������
        ///    ����� ��������� �������

        function FindObject( id : integer ): TBaseObject;
        ///    ������������ ���������� id �� ������� � ������� fObjects �
        ///    ���������� �������������� ������

    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB;

procedure TObjectManager.AddObjectToArray(obj: TBaseObject; layer: integer);
///    ���������� ������� � ����� ������� �������� ���������� ����
begin
    SetLength(fObjects[layer], Length(fObjects[layer]) + 1 );
    fObjects[layer][High(fObjects[layer])] := obj;
end;

function TObjectManager.CreateTile(Kind, X, Y, layer: integer): integer;
///    ������� �������� ������� ���������� ���� � ��������� �� � ������ ��������
///    kind - ��� �������
///    x, y - ��������� �� �����
///    layer - ���� ������������, ������� ����� �������� ���� ����� ����������� ���
///    � �������� ������ ������������ ������� ������������ ������ �� ������ DB
var
    location: TResourcedObject;
begin
    result := 0;

    // ������� ������ �������, ���������� ��� � ���������
    location := TResourcedObject.Create;
    location.id := GetId( layer );
    location.Identity.Common := Kind;
    location.Position.� := X;
    location.Position.Y := Y;

    // ������ ���, ��� ����������, �������� ��� ������� ���� �������
    location.Visualization.Name[ VISUAL_TILE ]  := TableObjects[ Kind, TABLE_FIELD_TILE_IMAGE ];
    location.Name := TableObjects[ Kind, TABLE_FIELD_NAME ];

    // ��������� � ����� ������
    AddObjectToArray( location, layer );

    result := location.id;
end;

procedure TObjectManager.SetResource(id, Kind: integer; Count,
  Once, Delta, Period: real);
///    �������� � ��������� ������� �������.
///    id - ������������� ������� � ������� fObjects
///    kind - ��� �������
var
    location : TResourcedObject;
    resource : TResource;
    obj : TBaseObject;
begin
    // ������� ������, �������� ����� �������� ������
    obj := FindObject( id );

    // ��������� ������� ������� ���� ���/�������, ��������������
    // �������� ��������
    if not (obj is TResourcedObject) then exit;

    // ����� ��� � ������
    location := obj as TResourcedObject;

    // ��������� ����� ������ � ������ �������� ������� �������
    resource := TResource.Create( kind );
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := resource;

    // �������������� ��������� �������
    resource.Item.Count.current  := Count;     // ��������� �������� ������ �������
    resource.Item.Once.current   := Once;      // ������ ��� �����
    resource.Item.Delta.current  := Delta;     // ��������� �� ������� (�������/������)
    resource.Item.Period.current := Period;    // ����� ������� ����� ��������� Delta
    resource.Item.PassTicks      := 0;         // ������������� �������� ����������� �����

end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ ����� ������� �� ��� id }
var
    layer, index : integer;
begin
    layer := id mod 1000;
    index := id div 1000;

    result := fObjects[layer][index];
end;

function TObjectManager.GetFirstOnLayer(layer: integer): TBaseObject;
begin
    result := nil;

    if ( layer < 0 ) or ( layer > Length(fObjects)-1 ) then exit;

    fLayerIndex[layer] := 0;

    if   Length( fObjects[layer] ) > 0
    then result := fObjects[layer][0];
end;

function TObjectManager.GetNextOnLayer(layer: integer): TBaseObject;
begin
    result := nil;

    if ( layer < 0 ) or ( layer > Length(fObjects)-1 ) then exit;

    Inc(fLayerIndex[layer]);

    if   fLayerIndex[layer] <= (Length( fObjects[layer] ) - 1)
    then result := fObjects[layer][fLayerIndex[layer]];
end;

function TObjectManager.GetId( layer: integer ): integer;
begin
    result := ( Length( fObjects[layer] ) );
    result := layer + ( result * 1000 );
end;

function TObjectManager.GetLayerCount: integer;
begin
    result := LAYER_COUNT ;
end;

{ TBaseObject }

constructor TBaseObject.Create;
begin
end;

{ TResource }

constructor TResource.Create(kind: integer);
{ �� ���������� ���� ��������� ������� ���� }
begin
    self.Identity.Common := kind;
    self.Name := TableResource[ kind, TABLE_FIELD_NAME ];
    self.Visualization.Name[ VISUAL_ICON ] := TableResource[ kind, TABLE_FIELD_ICON_IMAGE ];
end;

initialization
    mngObject := TObjectManager.Create;

finalization
    mngObject.Free;

end.

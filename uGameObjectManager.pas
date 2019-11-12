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

    // ��������� ��� ������ �� ������ ��� ������� ������� ���������� �������
    BOUND_MODE_CUT     = 0;                    // ��������� � ������������� ����� �� �������
    BOUND_MODE_BLOCK   = 1;                    // ����������� ������ ���������

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
        Name: array [0..99] of string[20];  // ����� ���� �������� ��� ��������� ������� �������
        Id  : array [0..99] of integer; // ����� �������� ����������� ��� ��������� �������
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

        PassTicks                    // ������� ����������� �����. ����� ������������ �
                                     // Period.current, ������������ �� 0 � ������������
                                     // ���������� Delta.current � Count.current
       ,LowBoundMode                 // ��� ������ ��� ������ �� ������ �������
                                     // ���� �� �������� ������ BOUND_MODE_XXX
       ,HighBoundMode                // ��� ������ ��� ������ �� ������� �������
                                     // ���� �� �������� ������ BOUND_MODE_XXX
                : integer;
    end;

    // ������ � ������� ������� �������
    TBaseObject = class
        id: integer;                   // ���������� � ������ ����� ���� �������������
        visible: boolean;              // ���������� ������� ���������. ��������,
                                       // ��� ����������, ����� ������ �� ����� ������������ �� ����, ���� �������� ������
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

        procedure RemoveTile(id : integer);

        procedure SetResource( id, Kind: integer; Count, Once, Delta, Period: real );
        ///    �������������� � ����������� ������ � ���������� �������, �������
        ///    ����� ��������� �������

        function FindObject( id : integer ): TBaseObject;
        ///    ������������ ���������� id �� ������� � ������� fObjects �
        ///    ���������� �������������� ������

        function PosIsFree( x, y: real; layer: integer ): boolean;
        ///    ��������, �������� �� ��������� ������� �� ��������� ����
        ///    ������������ ��� ��������� ��������� �������� �� ����
    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB, SysUtils;

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
    result := -1;

    if not PosIsFree(x, y, layer) then exit;

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

procedure TObjectManager.RemoveTile(id: integer);
var
    obj: TBaseObject;
begin
    obj := FindObject(id);

    if assigned( obj )
    then obj.visible := false;
end;

procedure TObjectManager.SetResource(id, Kind: integer; Count,
  Once, Delta, Period: real);
///    �������� � ��������� ������� �������.
///    id - ������������� ������� � ������� fObjects
///    kind - ��� �������
///    count - ��������� ����������
///    once - ���������� ����������� ������� ��� ����� �� ������� � ���
///    delta - ��������� ������� �� �������
///    period - ������� ����� ���������� ����� ����������� ��������� ����������
///             ��� �� ������ �� �������� ��������� ��� ������, ���� ������ ��
///             ����������, ���������� �� ����������� ����� ������������
var
    location : TResourcedObject;
    resource : TResource;
    obj : TBaseObject;
begin
    if id < 0 then exit;

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
    resource.Item.Count.current  := Count;       // ��������� �������� ������ �������
    resource.Item.Once.current   := Once;        // ������ ��� �����
    resource.Item.Delta.current  := Delta;       // ��������� �� ������� (�������/������)
    resource.Item.Period.current := Period;      // ����� ������� ����� ��������� Delta
    resource.Item.PassTicks      := 0;           // ������������� �������� ����������� �����
    resource.Item.Max.current    := MaxCurrency; // ������������ ������

end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ ����� ������� �� ��� id }
var
    layer, index : integer;
begin
    if id < 0 then exit;

    layer := id mod 1000;
    index := id div 1000;

    result := fObjects[layer][index];
end;

function TObjectManager.GetFirstOnLayer(layer: integer): TBaseObject;
begin
    result := nil;

    if ( layer < 0 ) or ( layer > Length(fObjects)-1 ) then exit;

    if Length(fObjects[layer]) = 0 then exit;

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

function TObjectManager.PosIsFree(x, y: real; layer: integer): boolean;
var
    obj: TBaseObject;
begin
    result := true;

    obj := GetFirstOnLayer( layer );
    while Assigned( obj ) do
    begin
        if (obj.Position.� = x) and ( obj.Position.Y = y ) then
        begin
            result := false;
            exit;
        end;
        obj := GetNextOnLayer( layer );
    end;
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
    visible := true;
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

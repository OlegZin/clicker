unit uGameObjectManager;
{ ������ ��������� ��������.
  ��������� � �������� ��� ���� �������� (������, ������������, �������� � �.�),
  � ��� �� ������������� ��������� ��� ��������������� ���.

  ������ ������ �������� ����� ���������� ����������������, ������������
  ������������ ��� � ����� ������� ������� (��������, ���������, ��������� � �.�.)

}
interface

const

    // ����������� ����� ������
    // ���� ���������
    LAND_FOREST = 0;     // ���
    LAND_PLAIN  = 1;     // �������
    LAND_MOUNT  = 2;     // ����
    LAND_SAND   = 3;     // �������
    LAND_ICE    = 4;     // ������
    LAND_CANYON = 5;     // ������
    LAND_LAVA   = 6;     // ������� ����
    LAND_FOG    = 7;     // ������� ����

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

    // ���� ��������
    RESOURCE_IQ     = 0;
    RESOURCE_HEALTH = 1;
    RESOURCE_MAN    = 2;
    RESOURCE_WOMAN  = 3;

    RESOURCE_WOOD   = 4;
    RESOURCE_GRASS  = 5;
    RESOURCE_STONE  = 6;
    RESOURCE_ICE    = 7;
    RESOURCE_LAVA   = 8;

    RESOURCE_FOOD   = 9;
    RESOURCE_BONE   = 10;

    LAYER_COUNT = 99;

    // ����� ��� ���� ����������� � �������  TVisualization.Name / TVisualization.Id
    VISUAL_TILE = 0;

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
        Res: TCount;
    end;

    // ������, ������������ �������/������� �������� ���� � ����������� �����������
    // ����� ��������� ��������� ��������
    TLocation = class(TBaseObject)
        Recource: array of TResource;
    end;

    TObjectManager = class
      private
        ID: integer;                        // id-������� ��� ���������� ������������ �������
        fObjects: array [0..LAYER_COUNT] of array of TBaseObject;     // ��� ��������� � ���� �������
        fLayerIndex: array [0..LAYER_COUNT] of integer;

        function GetId( layer: integer ): integer;            // ���������� ���������� id ��� ������ �������
        function FindObject( id : integer ): TBaseObject;
        procedure AddObjectToArray( obj: TBaseObject; layer: integer );
      public

        function GetLayerCount: integer;
        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;

        function CreateLocationTile( Kind, X, Y, Z: integer ): integer;
        // ������� ������� ������� � ���� ����� ��� ������� � ���������� ��� id

        procedure SetLocationResource( id, Kind: integer; Count, Once, Delta, Period: real );
        // ����������� ������ � ��������� �������

    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB;

procedure TObjectManager.AddObjectToArray(obj: TBaseObject; layer: integer);
begin
    SetLength(fObjects[layer], Length(fObjects[layer]) + 1 );
    fObjects[layer][High(fObjects[layer])] := obj;
end;

function TObjectManager.CreateLocationTile(Kind, X, Y, Z: integer): integer;
{
}
var
    location: TLocation;
begin
    result := 0;

    location := TLocation.Create;
    location.id := GetId( Z );
    location.Identity.Common := Kind;
    location.Position.� := X;
    location.Position.Y := Y;

    // ��������� ��� � ��� ���������� � ��������� ��� ������� ���� ��������
    location.Visualization.Name[ VISUAL_TILE ]  := TableLocations[ Kind, LAND_FIELD_IMAGE ];
    location.Name := TableLocations[ Kind, LAND_FIELD_NAME];

    AddObjectToArray( location, Z );

    // ��������� �������� ������� ��� �����
//    SetLocationResource( location.id, RESOURCE_WOOD, 1000, 1, 0.01, 1 );

    result := location.id;
end;

procedure TObjectManager.SetLocationResource(id, Kind: integer; Count,
  Once, Delta, Period: real);
{ �������� � ��������� ������� ������� }
var
    location : TLocation;
    resource : TResource;
begin
    location := FindObject( id ) as TLocation;

    // ��������� ����� ������ � ������
    resource := TResource.Create;
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := resource;

    resource.Res.Count.current  := Count;     // ��������� �������� ������ �������
    resource.Res.Once.current   := Once;      // ������ ��� �����
    resource.Res.Delta.current  := Delta;     // ��������� �� ������� (�������/������)
    resource.Res.Period.current := Period;    // ������� ����� �� ���� Delta
    resource.Res.PassTicks      := 0;         // ������������� �������� ����������� �����
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

//    Result := self.ID;
//    Inc(self.ID);
end;

function TObjectManager.GetLayerCount: integer;
begin
    result := LAYER_COUNT ;
end;

{ TBaseObject }

constructor TBaseObject.Create;
begin
end;

initialization
    mngObject := TObjectManager.Create;
    mngObject.ID := 1;

finalization
    mngObject.Free;

end.

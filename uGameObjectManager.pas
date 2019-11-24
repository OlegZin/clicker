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

    /// ���� ��������� �������� � ��������/��������
    ACT_CLICK  = 0;  // ������� ����, ��� ������������� ������ ��������
    ACT_HAND   = 1;  // ������� �������� ��� ������������
    ACT_SPEAR  = 2;  // ������������� ������ (�����/�����/�����������/...)
    ACT_AXE    = 3;  // ������������� ������ (�����/�����/...)
    ACT_PICK   = 4;  // ������������� ����� (������/�����/...)
    ACT_SHOVEL = 5;  // ������������� ������ (����������/�����/...)
    ACT_TALK   = 6;  // ������������� ���� (��������/����������/����������/...)
    ACT_GROW   = 7;  // ���������� (����/�������/...)
    ACT_EXAME  = 8;  // �������� ������� (�����/��������/...)
    ACT_KNIFE  = 9;  // ������������� ���� (������ �����/...)


    // ��������� ��� ������ �� ������ ��� ������� ������� ���������� �������
//    BOUND_MODE_CUT     = 0;                    // ��������� � ������������� ����� �� �������
//    BOUND_MODE_BLOCK   = 1;                    // ����������� ������ ���������

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

    /// �������� ������������, ����������� �� �����-���� ��������
    TBonus = record
        field: integer;  /// ���� �������� �� TCount. ������������� ������� �������� uResourceManager.FIELD_XXX
        name: string;    /// ������������� ���� ������. �� ���� ���������� ��������� ���������, ���� �� ��������� � ���������� ����� � ���������� �������
        value: real;     /// �������� ���������. ��� ��������� ������������, ���������� � ��������� ����
                         /// ����� �������� �� ��� �������� ����� (+). ��� ������, �����������
                         /// �������� ��������� ����� (-).
        period: real;    /// ������ ������������� ������� ������������ � �����, ����� ���� ����� ������������� ������
                         /// ��� �������� -1 - ����������
        active: boolean; /// �������� �� ��������. false - �� ����������� � ��������, �� � �� ���������, period �� ����������.
                         /// true - � ������� ������. ������������ ��� �������� ���������� ���������� �������������
        deleted: boolean;/// ���� ����, ��� ������ ����� � ������� �� ������������ � ����� ���� ����������� �����
    end;

    // ��������� ������� ��������� � ������ ��������� ���������� ��������
    TCount = record
       Count                        // ������� �������� (�������)
      ,Period                       // ������ � ����� ������� ���������� �������� (�������)

       ,Delta                        // ������ �������� �������� ��������� ��� ����. (�������)
       ,Once                         // ������ �������� �������� ��������� ��� ������� ������.
                                     // ��������, ��� ����� �� ���� ������� ����� ������ ���������

       ,Max                          // ����������� ��������� ������� �������� (�������)

       ,Min                          // ���������� ��������� ������� �������� (�������)

        /// �������� ���������� � ������ ���� �������� �� ������ ������ �������
       ,bCount                       // ������� ��������
       ,bPeriod                      // ������ � ����� ������� ���������� ��������
       ,bDelta                       // ������ �������� �������� ��������� ��� ����.
       ,bOnce                        // ������ �������� �������� ��������� ��� ������� ������.
       ,bMax                         // ����������� ��������� ������� ��������
       ,bMin                         // ���������� ��������� ������� ��������
                : real;

        PassTicks                    // ������� ����������� �����. ����� ������������ �
                                     // Period.current, ������������ �� 0 � ������������
                                     // ���������� Delta.current � Count.current
       ,LowBoundMode                 // ��� ������ ��� ������ �� ������ �������
                                     // ���� �� �������� ������ BOUND_MODE_XXX
       ,HighBoundMode                // ��� ������ ��� ������ �� ������� �������
                                     // ���� �� �������� ������ BOUND_MODE_XXX
                : integer;

        Bonus : array of TBonus;
    end;

    // �������� ��� �������� ��� ��������
    TObjAction = record
        Kind : integer;     // ��� �������� (������ �� ������ ��������). �������� � ��������� ������� � ��������)
        Cost: TCount;       // ��������� �������� � �������� ������������. ������ �� �������� ���������� ��������.
                            // ��������, ���� � ������ ����� ���� ������� ������������, � ��������� �������� 10, ��
                            // �������� ���������� ����� 10 ����� �������
        Exp: TCount;        // ������� ���������� ����� �� �������� ���������� ��������
        Item : TCount;      // �������������� ��������� ������� ��� ���������� ��������
    end;

    // ������ � ������� ������� �������
    TBaseObject = class
        id: integer;                   // ���������� � ������ ����� ���� �������������
        visible: boolean;              // ���������� ������� ���������. ��������,
                                       // ��� ����������, ����� ������ �� ����� ������������ �� ����, ���� �������� ������
        Image: TObject;                // ������-��������, ������� ������������
        FullY: real;                   // ��������� �� Y ������� ���� ��������
        Name : string;
        Description : string;
        Identity: TIdentity;           // ������������ ����� ���������
        Position: TPosition;           // ��������� � ����� ������� ������������
        Visualization: TVisualization; // ������ �� ������� ����������� � ������ ����������
        constructor Create; overload;
    end;

    TResource = class(TBaseObject)
        Item: TCount;
        Valued: boolean;               // �� ������� "��������" ������� �� ����������� ��� ��������
                                       // �� ��������� ���� ���������� �� ������� ��� ��� �����������
        Actions: array of TObjAction;  // ������ ��������, ������� ����� ��������� � ���� ��������.
                                       // ������ �� ������������ ������ ���������� �������

        constructor Create(kind: integer; Count: real; valued: boolean = true ); overload;

        function Maximum( max: real ):TResource;
        /// ��������� ��������� �������

        function Growing( Delta, Period: real ): TResource;
        /// ���� ������� ����������� ��������������� ��������/��������� � �������� �������

        function Action( Kind: integer; Count, Exp: real; Cost: real = 0 ): TResource;
        /// ����������� � ������� �����-���� ��������

        function GetAction( Kind: integer ): TObjAction;
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

        procedure ClearField;
        /// ����� �������� ������ ��������, � ������ � ��� ��������� ��� ��� �������-��������

        function GetLayerCount: integer;
        ///    ���������� ������������ ��������� ������ ����

        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;
        ///    ������, ����������� ��������������� ��������� ��� �������
        ///    ���������� ����, ��� �������, �� ������, ��� ��������� ����

        function CreateTile( Kind, X, Y, layer: integer; H: real ): integer;
        ///    ������� ����� ������� ��� ������� � ���������� ��� id

        procedure RemoveTile(id : integer);

        procedure SetResource( id: integer; res: TResource );
        ///    �������������� � ����������� ������ � ���������� ������� (id), �������
        ///    ����� ��������� �������. ���������� ��������� ������ ��� ��������� ����� ������ ���������

        function FindObject( id : integer ): TBaseObject;
        ///    ������������ ���������� id �� ������� � ������� fObjects �
        ///    ���������� �������������� ������

        function PosIsFree( x, y: real; layer: integer ): boolean;
        ///    ��������, �������� �� ��������� ������� �� ��������� ����
        ///    ������������ ��� ��������� ��������� �������� �� ����

        procedure OptimizeObjects;

        procedure CalcBonus( var item: TCount );
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

procedure TObjectManager.CalcBonus(var item: TCount);
var
    i : integer;
begin
    ///�������� ������� ������ �������
    item.bCount := item.Count;
    item.bPeriod := item.Period;
    item.bDelta := item.Delta;
    item.Once := item.Once;

    for I := 0 to High(item.Bonus) do
    if item.Bonus[i].active and not item.Bonus[i].deleted then
    case item.Bonus[i].field of
        FIELD_COUNT : item.bCount  := item.bCount  + item.Bonus[i].value;
        FIELD_PERIOD: item.bPeriod := item.bPeriod + item.Bonus[i].value;
        FIELD_DELTA : item.bDelta  := item.bDelta  + item.Bonus[i].value;
        FIELD_ONCE  : item.bOnce   := item.bOnce   + item.Bonus[i].value;
    end;

end;

procedure TObjectManager.ClearField;
/// ��������� �������� ������ ����� ��������� �������� �����
var
    layer, i, j: integer;
begin
    for layer := 0 to High(fObjects) do
    begin
        /// ������� ��������
        for I := 0 to High(fObjects[layer]) do
        begin
            if assigned(fObjects[layer][i].Image) then
            begin
                fObjects[layer][i].Image.Free;
                fObjects[layer][i].Image := nil;
            end;

            if fObjects[layer][i] is TResourcedObject then
            for j := 0 to High((fObjects[layer][i] as TResourcedObject).Recource) do
            begin
                (fObjects[layer][i] as TResourcedObject).Recource[j].Free;
                (fObjects[layer][i] as TResourcedObject).Recource[j] := nil;
            end;

            fObjects[layer][i].Free;
            fObjects[layer][i] := nil;
        end;

        /// ������� �������� ����
        SetLength(fObjects[layer], 0);
    end;
end;

function TObjectManager.CreateTile(Kind, X, Y, layer: integer; H: real): integer;
///    ������� �������� ������� ���������� ���� � ��������� �� � ������ ��������
///    kind - ��� �������
///    x, y - ��������� �� �����
///    layer - ���� ������������, ������� ����� �������� ���� ����� ����������� ���
///    � �������� ������ ������������ ������� ������������ ������ �� ������ DB
var
    location: TResourcedObject;
begin
    result := -1;

//    if not PosIsFree(x, y, layer) then exit;

    // ������� ������ �������, ���������� ��� � ���������
    location := TResourcedObject.Create;
    location.id := GetId( layer );
    location.Identity.Common := Kind;
    location.Position.� := X;
    location.Position.Y := Y;
    location.FullY := Y + H;

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

procedure TObjectManager.SetResource(id: integer; res: TResource);
///    �������� � ��������� ������� �������.
///    id - ������������� ������� � ������� fObjects
///    kind - ��� �������
///    count - ��������� ����������
///    once - ���������� ����������� ������� ��� ����� �� ������� � ���
///    delta - ��������� ������� �� �������, ���� �������� �� �������, ��
///            ���������� ������� ����� ���������� ���������� �� ���������
///    period - ������� ����� ���������� ����� ����������� ��������� ����������
///    vaued - �������, ����� �� ����� ��������� ������ ������ ��� ��������
///            �� ���������� ���� ���������� �������� �������. ���������� �������
///            ������������ ��� ����������� ������� �� ��������� ���� �������� ��������.
///            ��������, � �������� �������� �������� ��� ��������� � ���������
var
    location : TResourcedObject;
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
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := res;
end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ ����� ������� �� ��� id }
var
    layer, index : integer;
begin
    if id < 0 then exit;

    layer := id mod 1000000;
    index := id div 1000000;

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

procedure TObjectManager.OptimizeObjects;
/// �������� ������������ ������� ��������
/// ��������: ����� ��������� ��������� �������� � ������������ ������� ��������
/// ���������� Y ���� � ���������. ��� ��������� �������� ���� ��� �������
/// �������� � ����, ��� "�������" � ������ ������� (� ������� Y) �����
/// ������������� "��������" ���������, ��������� ��� ��������� ������ � �����
/// ������� ��������.
/// ������� - ����������� ��������� �� ���� ����� ������������ ������� � �������
/// ����������� ���������� Y (� ������ ������ �������)
///
/// ��������� id ��������, ��� �� ���������� � ������� ���� ��������, �� ���
/// ������ �������� ������� � �������, id ����� ����������� �������, �� ���������� �����
var
    layer, i, j, idj, idi: integer;
    buffObj: TBaseObject;
    highLayerIndex: integer;
begin
///
    for layer := Low(fObjects) to High(fObjects) do
    if Length(fObjects[layer]) > 1 then
    begin
        highLayerIndex := High(fObjects[layer]);
        for I := highLayerIndex downto 1 do
        for J := 0 to I-1 do
        if (fObjects[layer][j].FullY) >= (fObjects[layer][j+1].FullY) then
        begin
            idj := fObjects[layer][j].id;
            idi := fObjects[layer][j+1].id;

            buffObj := fObjects[layer][j];
            fObjects[layer][j] := fObjects[layer][j+1];
            fObjects[layer][j+1] := buffObj;

            fObjects[layer][j].id := idj;
            fObjects[layer][j+1].id := idi;
        end;
    end;
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
    result := layer + ( result * 1000000 );
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

constructor TResource.Create(kind: integer; Count: real; valued: boolean = true);
{ �� ���������� ���� ��������� ������� ���� }
begin

    self.Identity.Common := kind;
    self.Name := TableResource[ kind, TABLE_FIELD_NAME ];
    self.Visualization.Name[ VISUAL_ICON ] := TableResource[ kind, TABLE_FIELD_ICON_IMAGE ];

    // �������������� ��������� �������
    /// ������� ��������, ��� ����� �������
    self.Item.Count  := Count;       // ��������� �������� ������ �������
    self.Item.Once   := 0;           // ������ ��� �����
    self.Item.Delta  := 0;           // ��������� �� ������� (�������/������)
    self.Item.Period := 0;           // ����� ������� ����� ��������� Delta

    /// ��������, � ������ �������
    self.Item.bCount  := Count;       // ��������� �������� ������ �������
    self.Item.bOnce   := 0;           // ������ ��� �����
    self.Item.bDelta  := 0;           // ��������� �� ������� (�������/������)
    self.Item.bPeriod := 0;           // ����� ������� ����� ��������� Delta

    self.Item.PassTicks      := 0;           // ������������� �������� ����������� �����
    self.Item.Max    := MaxCurrency; // ������������ ������
    self.Item.Min    := 0;           // ����������� ������
    self.Valued              := valued;      // ������� ������� ������� ��� �������� �� ��������� (����� �� �����������)
end;

function TResource.GetAction(Kind: integer): TObjAction;
/// �������� ������ �������� �� ��� ����
var
    i : integer;
begin
    for i := 0 to High(Actions) do
    if Actions[i].Kind = Kind then
    begin
        result := Actions[i];
        break;
    end;
end;

function TResource.Growing(Delta, Period: real): TResource;
begin
    result := self;
    Item.Delta  := Delta;           // ��������� �� ������� (�������/������)
    Item.Period := Period;           // ����� ������� ����� ��������� Delta

    Item.bDelta  := Delta;           // ��������� �� ������� (�������/������)
    Item.bPeriod := Period;           // ����� ������� ����� ��������� Delta
end;

function TResource.Maximum(max: real): TResource;
begin
    result := self;
    Item.Max := max;
end;

function TResource.Action(Kind: integer; Count, Exp: real; Cost: real = 0 ): TResource;
/// ����������� �������� � �������
///    kind - ��� ��������. ��������� ACT_XXX
///    count - �������������� ��������� ������� ��� ���������� ��������
///    exp - ������� ���������� ����� �� ����������� ��������
///    cost - ��������� � �������� ������������ ��� ���������� ��������
begin
    result := self;
    SetLength(Actions, Length(Actions) + 1);
    Actions[High(Actions)].Kind := Kind;

    /// ���������� ������� �������� (������� ���������)
    Actions[High(Actions)].Item.Count := Count;
    Actions[High(Actions)].Exp.Count := Exp;
    Actions[High(Actions)].Cost.Count := Cost;

    /// ���������� �������� � ������ ������� (���� ��� ��������, ����� ���������������)
    Actions[High(Actions)].Item.bCount := Count;
    Actions[High(Actions)].Exp.bCount := Exp;
    Actions[High(Actions)].Cost.bCount := Cost;
end;

initialization
    mngObject := TObjectManager.Create;

finalization
    mngObject.Free;

end.

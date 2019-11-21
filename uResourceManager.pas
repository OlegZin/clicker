unit uResourceManager;

///    �������� ��������.
///    ����� �� ���� ��� ������ �� ��������, ������������ � ����������� ��������
///    ��������� �� ������ ��������.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types, System.UITypes,

    uGameObjectManager, DB;

type

    TComponents = record
        layout: TLayout;
        image: TImage;
        text: Tlabel;
    end;

    TSoredResource = record
        Resource: TResourcedObject;    // �������� �������� �������� �������

        view : TComponents;      // ������ �� ��������� ���������, ������� ������������ ������ ������

//        used                     // ������� ������������� ������ (������ ��������������� � �������)
        visible                  // ������� ��������� �� ������ (������ �������� ��������)
       ,virgin                   // ������ ��� �� ���� �� ��� ������� ������� � ����� �����, ���� �� ������ �������������
                                 // �������� ������������ �������� ��������, ��� ������ ���� ����� �������������
            : boolean;
    end;

    TResourceManager = class
    private
        fLayout  : TLayout;      // ������������ ������ ��� ����� �������� (� ������� ����)
        fFLayout : TFlowLayout;  // ������� ������ ��� ����� ��������

        fResources : array of TSoredResource;
                                 // ������ �� ����� ������������� ���������

        procedure UpdateView( index: integer );
                                 // ��������� ���������� ������������� �������
        procedure CreateView( index: integer; icon: string );
                                 // ������� �������� ��������� ��� ����������� ������� �� ������ fFLayout

    public

        /// ������ �������������

        procedure SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
                                 // ����������� �������� � ����������� �� �����

        function CreateRecource(_kind: integer; _count, _increment: real): integer;
                                 // ������� ����� ������

        /// ������ ����������
        procedure OnTimer;       // ���������� �� ��� �������

        procedure UpdateResPanel;
                                 // ��������� ��������� �������� �� ������

        procedure ResCount( mode, index: integer; _increment: real = 0 );
                                 // �������������� ��������� ���������� ������� �� ��������
        function TargetResCount(res: uGameObjectManager.TResource; mode: integer; _increment: real = 0 ): real;

        procedure SetAttr( index: integer; field: integer; value: variant );
                                 // ������������� �������� ������ �� ���������� �������
        function GetAttr( index: integer; field: integer ): variant;

        function GetCount( index: integer ): real;

        procedure AddBonus(res_index, field: integer; bonus_name: string; bonus_value: real );
        procedure DelBonus(res_index, field: integer; bonus_name: string );
    end;

var
    mResManager : TResourceManager;

implementation

{ TResourceManager }

uses
    uMain, uImgMap;

var
   BitmapSize: TSizeF;

procedure TResourceManager.AddBonus(res_index, field: integer;
  bonus_name: string; bonus_value: real);
/// ��������� �����, ����������� � ���������� ������� � ������������� �������� � ������ ������
var
    res: TCount;
    i, freeSlot: integer;
    found : boolean;

begin
    res := fResources[res_index].Resource.Recource[0].Item;
    freeSlot := -1;

    /// ���������, ���� �� ��� ����� �����, ����� �� ����������� ��������
    found := false;
    for I := 0 to High( res.Bonus ) do
    begin
        /// ���������� ��������� ���� � �������, ���� ����� ����� ��������� �����
        if res.Bonus[i].deleted then freeSlot := i;
        /// ����������, ���� ����� ����� ��� ���� � �������
        if (res.Bonus[i].field = field) and (res.Bonus[i].name = bonus_name) then found := true;
    end;

    /// ����� ����������� � ��� ��������� ������
    if not found and (freeSlot < 0) then
    begin
        SetLength(res.Bonus, Length(res.Bonus)+1);
        freeSlot := high(res.Bonus);
    end;

    /// ����� ����������� � �������� � ����� ���� ���������
    if not found then
    begin
        /// ��������� �����
        res.Bonus[freeSlot].field := field;
        res.Bonus[freeSlot].name := bonus_name;
        res.Bonus[freeSlot].value := bonus_value;
        res.Bonus[freeSlot].period := -1;
        res.Bonus[freeSlot].active := true;
        res.Bonus[freeSlot].deleted := false;

        /// ������������� ��������� �������, ������ �� ������������ ������ �������
        mngObject.CalcBonus(res);
    end;

    fResources[res_index].Resource.Recource[0].Item := res;
end;

procedure TResourceManager.DelBonus(res_index, field: integer; bonus_name: string );
/// ������� �����. �� ����� ���� ������ �������� ������� ��������, ����� �� �������
/// ����� �� ��������� ������������ � ������������ �������. ��� ���������� �����
/// ������� ��������� ����� ����� ������������
var
    res: TCount;
    i: integer;
begin
    res := fResources[res_index].Resource.Recource[0].Item;

    /// ���� ��������� ����� ����������� � ���������� ����, ���� ������� - ������� ��� (������ �������)
    for i := 0 to High(res.Bonus ) do
    if (res.Bonus[i].field = field) and (res.Bonus[i].name = bonus_name) then
    begin
        res.Bonus[i].deleted := true;
        mngObject.CalcBonus(res);
    end;

    fResources[res_index].Resource.Recource[0].Item := res;
end;

function TResourceManager.CreateRecource(_kind: integer; _count, _increment: real): integer;
{ ����������������� �������: ��������� � �������� ������������� }
begin

    // ��������� �������
    SetLength(fResources, Length(fResources)+1);
    with fResources[high(fResources)] do
    begin
        Resource := TResourcedObject.Create;
        SetLength(Resource.Recource, 1 );
        Resource.Recource[0] :=
            uGameObjectManager.TResource
                .Create( _kind, _count )
                .Growing( _increment, 0 );

        visible     := _count <> 0;// false; // _count <> 0;
        virgin      := _count = 0;
    end;

end;

procedure TResourceManager.CreateView(index: integer; icon: string);
{ �������� ������������� ������� ��� ������ �������� }
var
   _layout: TLayout;
   _image: TImage;
   _label: TLabel;
   source: TImage;
begin

    _layout := TLayout.Create(fFLayout);
    with _layout do
    begin
        Width := 60;
        height := 17;
    end;

    _image := TImage.Create(_layout);
    with _image do
    begin
        Parent := _layout;
        Height := 15;
        Width := 15;
        Position.X := 1;
        Position.Y := 1;
        source := TImage(fImgMap.FindComponent( icon ));
        if assigned(source) then bitmap.Assign( source.MultiResBitmap.Bitmaps[1.0] );
    end;

    _label := TLabel.Create(_layout);
    with _label do
    begin
        Parent := _layout;
        Height := 15;
        Width := 63;
        Position.X := 17;
        Position.Y := 1;
        StyledSettings := StyledSettings - [TStyledSetting.FontColor] - [TStyledSetting.Style];
        TextSettings.Font.Style := TextSettings.Font.Style + [TFontStyle.fsBold];
        TextSettings.FontColor := TAlphaColorRec.Cornsilk;//$B8860B;

    end;

    fResources[ index ].view.layout := _layout;
    fResources[ index ].view.image := _image;
    fResources[ index ].view.text := _label;

end;


function TResourceManager.GetAttr(index, field: integer): variant;
/// �������� �������� ���������� �������� ���������� �������
begin
    case field of
        FIELD_CAPTION     : result := fResources[ index ].Resource.Recource[0].Name;
        FIELD_DESCRIP     : result := fResources[ index ].Resource.Recource[0].Description;
        FIELD_COUNT       : result := fResources[ index ].Resource.Recource[0].Item.Count;
        FIELD_DELTA       : result := fResources[ index ].Resource.Recource[0].Item.Delta;
        FIELD_ONCE        : result := fResources[ index ].Resource.Recource[0].Item.Once;
        FIELD_MAXIMUM     : result := fResources[ index ].Resource.Recource[0].Item.Max;
        FIELD_MINIMUM     : result := fResources[ index ].Resource.Recource[0].Item.Min;
        FIELD_PERIOD      : result := fResources[ index ].Resource.Recource[0].Item.Period;
        FIELD_VISIBLE     : result := fResources[ index ].visible;
    end;
end;

function TResourceManager.GetCount(index: integer): real;
begin
    result := fResources[ index ].Resource.Recource[0].Item.count;
end;

procedure TResourceManager.SetAttr(index, field: integer; value: variant);
{ ������ �������� ������ �� ����� ������� }
begin
    case field of
    FIELD_CAPTION     : fResources[ index ].Resource.Recource[0].Name        := value;
    FIELD_DESCRIP     : fResources[ index ].Resource.Recource[0].Description := value;
    FIELD_COUNT       : fResources[ index ].Resource.Recource[0].Item.Count  := value;
    FIELD_DELTA       : fResources[ index ].Resource.Recource[0].Item.Delta  := value;
    FIELD_ONCE        : fResources[ index ].Resource.Recource[0].Item.Once   := value;
    FIELD_MAXIMUM     : fResources[ index ].Resource.Recource[0].Item.Max    := value;
    FIELD_MINIMUM     : fResources[ index ].Resource.Recource[0].Item.Min    := value;
    FIELD_PERIOD      : fResources[ index ].Resource.Recource[0].Item.Period := value;
    FIELD_VISIBLE     : fResources[ index ].visible     := value;
    end;
end;

procedure TResourceManager.SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
begin
    fLayout := _layout;
    fFLayout := _flayout;
end;

procedure TResourceManager.UpdateResPanel;
{ �� ������ ������ �������� ������ ��� ���������� ��������� ���� �������� }
var
    i : integer;
begin

    for I := 0 to Length(fResources)-1 do
    with fResources[i] do
    begin

        // ������� �������������, ���� ��� ��� � ����� ��� ��������
        if   not Assigned( view.layout )
        then CreateView( i, fResources[i].Resource.Recource[0].Visualization.Name[ VISUAL_ICON ] );

        // ������� ������������� ����������� � �������, ����� �������� �� ������
        if   Assigned( view.layout ) and visible and ( not virgin )
        then view.layout.Parent := fFLayout;

        // ���������� ������������� �� �����, ���� ����� ������
        if   Assigned( view.layout ) and ( not visible )
        then view.layout.Parent := nil;

        UpdateView( i );
    end;

end;

procedure TResourceManager.UpdateView( index: integer );
var
   count
  ,increment
   : real;
begin
    with fResources[ index ] do
    if visible then
    begin

        count := Resource.Recource[0].Item.count;
        increment := Resource.Recource[0].Item.Delta;

        if round(count) <> count
        then
            view.text.Text := Format('%1.1f', [count])
        else
            view.text.Text := Format('%1.0f', [count]);
{
        if round(increment) <> increment
        then
            view.text.Text := view.text.Text + Format(' (%1.1f)', [increment])
        else
        if   increment <> 0
        then view.text.Text := view.text.Text + Format(' (%1.0f)', [increment])
}

    end;
end;

function TResourceManager.TargetResCount(res: uGameObjectManager.TResource; mode: integer; _increment: real = 0 ): real;
var
   count
  ,increment
  ,minimum
  ,maximum
   : real;
begin

    count := res.Item.count;

    case mode of
        CALC_MODE_AUTO : increment := res.Item.bDelta;
        CALC_MODE_CLICK : increment := res.Item.bOnce;
        CALC_MODE_VALUE : increment := _increment;
    end;

    minimum := res.Item.Min;
    maximum := res.Item.Max;

    count := count + increment;

    if count < minimum then count := minimum;
    if count > maximum then count := maximum;

    // ���������� �������� ������������ ���������
    result := count - res.Item.count;

    res.Item.Count := count;

end;

procedure TResourceManager.ResCount(mode, index: integer; _increment: real = 0 );
{ ����� ������������ ���������� ������� � ���������� ��� ���� ������� }
var
   period
           : real;
begin

    with fResources[ index ] do
    begin

        // ��������� �� ������� ��������� ����� �������
        period := Resource.Recource[0].Item.bPeriod;

        // ���� ������ ��������� ������ (��������� ������ ���)
        // ��������� �� �������� �� ���������� ����������� ����� ������� ��������
        if period > Resource.Recource[0].Item.PassTicks then
        begin

           // ������ �� ���� ����� �������...
           Inc(Resource.Recource[0].Item.PassTicks);

           // ���� �������� ����� �������
           if period = Resource.Recource[0].Item.PassTicks
           // ���������� ������� � ���� �� ��������� �������
           then Resource.Recource[0].Item.PassTicks := 0
           // ����� �������. ��� �� �����...
           else exit;

        end;

        // ������������ ������ � �������� ������� ��������
        TargetResCount( Resource.Recource[0], mode, _increment );

        // ������ ������ ���������� ������ ������� (������ �� ����� ������������ �� ������)
        if virgin and ( Resource.Recource[0].Item.Count > 0 ) and visible then
        begin
            virgin := false;
            view.layout.Parent := fFLayout;
        end;

        UpdateView( index );
    end;

end;

procedure TResourceManager.OnTimer;
{ ����� ����������� �� ������. ��������� ������� �������� �������� �������� ��������}
var
    i : integer;
    layer, index: integer;
    obj: TBaseObject;
begin

    // ���������� ��� ��������� ���������� �������
    for I := 0 to High(fResources) do ResCount( CALC_MODE_AUTO, i );

    // ���������� ��� ������� ������� ������� � ������������� ��, ��� �������������
    for layer := 0 to mngObject.GetLayerCount do
    begin

        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin

            if obj is TResourcedObject then
            for index := 0 to High((obj as TResourcedObject).Recource) do
            begin

                mResManager.TargetResCount(
                    (obj as TResourcedObject).Recource[index],              // ���������� ������
                    CALC_MODE_VALUE,                                        // �������� �� ��������� ����������
                    (obj as TResourcedObject).Recource[index].Item.bDelta    // ���������� �� ���������
                );

            end;

            obj := mngObject.GetNextOnLayer( layer ) as TResourcedObject;
        end;
    end;
end;

initialization

    BitmapSize.cx := RES_ICON_SIZE;
    BitmapSize.cy := RES_ICON_SIZE;

finalization

    mResManager.Free;

end.

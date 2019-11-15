unit uResourceManager;

///    �������� ��������.
///    ����� �� ���� ��� ������ �� ��������, ������������ � ����������� ��������
///    ��������� �� ������ ��������.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types, System.UITypes,

    uGameObjectManager;

const

    // �������� ����� ������ �������
    FIELD_CAPTION     = 0;
    FIELD_DESCRIP     = 1;
    FIELD_TAGS        = 2;
    FIELD_COUNT       = 3;
    FIELD_INCREMENT   = 4;
    FIELD_MAXIMUM     = 5;
    FIELD_MINIMUM     = 6;
    FIELD_USED        = 7;
    FIELD_VISIBLE     = 8;
    FIELD_ICON        = 9;
    FIELD_PASSTICKS   = 10;

    // ������ ��������� ���������� ��������.
    CALC_MODE_AUTO  = 0;   // �� ������. ����� �������� Delta � ������ �������� �����
    CALC_MODE_CLICK = 1;   // ���� ������. ����� �������� Once
    CALC_MODE_VALUE = 2;   // �������������. ������������ ��������� ��������

type

    TComponents = record
        layout: TLayout;
        image: TImage;
        text: Tlabel;
    end;

    TResource = record
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

        fResources : array of TResource;
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

        function GetCount( index: integer ): real;
    end;

var
    mResManager : TResourceManager;

implementation

{ TResourceManager }

uses
    uMain, uImgMap;

var
   BitmapSize: TSizeF;

function TResourceManager.CreateRecource(_kind: integer; _count, _increment: real): integer;
{ ����������������� �������: ��������� � �������� ������������� }
begin

    // ��������� �������
    SetLength(fResources, Length(fResources)+1);
    with fResources[high(fResources)] do
    begin
        Resource := TResourcedObject.Create;
        SetLength(Resource.Recource, 1 );
        Resource.Recource[0] := uGameObjectManager.TResource.Create( _kind );
        Resource.Recource[0].Item.Count.current  := _count;
        Resource.Recource[0].Item.Delta.current  := _increment;
        Resource.Recource[0].Item.Min.current    := 0;
        Resource.Recource[0].Item.Max.current    := MaxCurrency;

        visible     := false; // _count <> 0;
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

function TResourceManager.GetCount(index: integer): real;
begin
    result := fResources[ index ].Resource.Recource[0].Item.count.current;
end;

procedure TResourceManager.SetAttr(index, field: integer; value: variant);
{ ������ �������� ������ �� ����� ������� }
begin
    case field of
    FIELD_CAPTION     : fResources[ index ].Resource.Recource[0].Name                := value;
    FIELD_DESCRIP     : fResources[ index ].Resource.Recource[0].Description         := value;
    FIELD_COUNT       : fResources[ index ].Resource.Recource[0].Item.Count.current  := value;
    FIELD_INCREMENT   : fResources[ index ].Resource.Recource[0].Item.Delta.current  := value;
    FIELD_MAXIMUM     : fResources[ index ].Resource.Recource[0].Item.Max.current    := value;
    FIELD_MINIMUM     : fResources[ index ].Resource.Recource[0].Item.Min.current    := value;
    FIELD_PASSTICKS   : fResources[ index ].Resource.Recource[0].Item.Period.current := value;
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

        count := Resource.Recource[0].Item.count.current;
        increment := Resource.Recource[0].Item.Delta.current;

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

    count := res.Item.count.current;

    case mode of
        CALC_MODE_AUTO : increment := res.Item.Delta.current;
        CALC_MODE_CLICK : increment := res.Item.Once.current;
        CALC_MODE_VALUE : increment := _increment;
    end;

    minimum := res.Item.Min.current;
    maximum := res.Item.Max.current;

    count := count + increment;

    if count < minimum then count := minimum;
    if count > maximum then count := maximum;

    // ���������� �������� ������������ ���������
    result := count - res.Item.count.current;

    res.Item.Count.current := count;

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
        period := Resource.Recource[0].Item.Period.current + Resource.Recource[0].Item.Period.bonus;

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
        if virgin and ( Resource.Recource[0].Item.Count.current > 0 ) and visible then
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
                    (obj as TResourcedObject).Recource[index],                                                // ���������� ������
                    CALC_MODE_VALUE,                                        // �������� �� ��������� ����������

                    (obj as TResourcedObject).Recource[index].Item.Delta.current +
                    (obj as TResourcedObject).Recource[index].Item.Delta.bonus     // ���������� �� ���������
                );

            end;

            obj := mngObject.GetNextOnLayer( layer ) as TResourcedObject;
        end;
    end;


end;

initialization

    BitmapSize.cx := 20;
    BitmapSize.cy := 20;

finalization

    mResManager.Free;

end.

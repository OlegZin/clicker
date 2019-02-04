unit uResourceManager;

///    �������� ��������.
///    ����� �� ���� ��� ������ �� ��������, ������������ � ����������� ��������
///    ��������� �� ������ ��������.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types;

const

    // ������������ ���������� ����� ��������. ������ �� ������ ������� ��������
    RES_COUNT = 1000;

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

    // �������� ��������
    RES_IQ             = 0;
    RES_FOOD           = 1;
    RES_HEALTH         = 2;
    RES_MAN            = 3;
    RES_WOMAN          = 4;
    RES_WOOD           = 5;
    RES_STONE          = 6;

    // �������� id ������ �������� � fMain.ilResources (ImageList)
    ICON_IQ             = 0;
    ICON_FOOD           = 1;
    ICON_HEALTH         = 2;
    ICON_MAN            = 3;
    ICON_WOMAN          = 4;
    ICON_WOOD           = 5;
    ICON_STONE          = 6;

type

    TCompinents = record
        layout: TLayout;
        image: TImage;
        text: Tlabel;
    end;

    TResource = record
        caption                  // ��� ������� ��� ������������
       ,descrip                  // ������� ��������
            : shortstring;

        icon                     // ������ ������ ��� ������� �� fMain.ilResources (ImageList)
            : integer;

        count                    // ������� ��������� ����������
       ,increment                // ������� �������
       ,maximum                  // ������ ������������� ��������
       ,minimum                  // ������ ������������ ��������
            : Real;

        view : TCompinents;      // ������ �� ��������� ���������, ������� ������������ ������ ������

        used                     // ������� ������������� ������ (������ ��������������� � �������)
       ,visible                  // ������� ��������� �� ������ (������ �������� ��������)
       ,virgin                   // ������ ��� �� ���� �� ��� ������� ������� � ����� �����, ���� �� ������ �������������
                                 // �������� ������������ �������� ��������, ��� ������ ���� ����� �������������
            : boolean;
    end;

    TResourceManager = class
    private
        fLayout  : TLayout;      // ������������ ������ ��� ����� �������� (� ������� ����)
        fFLayout : TFlowLayout;  // ������� ������ ��� ����� ��������

        fResources : array[ 0 .. RES_COUNT - 1 ] of TResource;
                                 // ������ �� ����� ������������� ���������
        fMax     : integer;      // ������������ ������ ������������������� ������� ��� ����������� �������� ������� fResources

        procedure UpdateView( index: integer );
                                 // ��������� ���������� ������������� �������
        procedure CreateView( index, icon: integer );
                                 // ������� �������� ��������� ��� ����������� ������� �� ������ fFLayout

    public

        /// ������ �������������

        procedure SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
                                 // ����������� �������� � ����������� �� �����

        function CreateRecource(_index: integer; _caption: shortstring; _icon: integer; _count, _increment: real; _descrip: string): integer;
                                 // ������� ����� ������

        procedure SetResData( data: TResource );
                                 // ������ ������ �� ������ �� �������� ��� ��������� � ������

        /// ������ ����������
        procedure OnTimer;       // ���������� �� ��� �������

        procedure UpdateResPanel;
                                 // ��������� ��������� �������� �� ������

        procedure ResCount( index: integer; _increment: real );
                                 // �������������� ��������� ���������� ������� �� ��������
                                 //_increment (� ���� ��� �����)

        procedure SetAttr( index: integer; field: integer; value: variant );
                                 // ������������� �������� ������ �� ���������� �������

        function GetCount( index: integer ): real;
    end;

var
    mResManager : TResourceManager;

implementation

{ TResourceManager }

uses
    uMain;

var
   BitmapSize: TSizeF;

function TResourceManager.CreateRecource(_index: integer; _caption: shortstring;
  _icon: integer; _count, _increment: real; _descrip: string): integer;
{ ����������������� �������: ��������� � �������� ������������� }
begin

    // ���� �������� ������ ������ ��������
    if (_index > RES_COUNT) OR (_index < 0) then
    begin
        result := -1;
        exit;
    end;

    // ��������� �������
    with fResources[_index] do
    begin
        caption     := _caption;
        descrip     := _descrip;
        icon        := _icon;
        count       := _count;
        increment   := _increment;
        minimum     := 0;
        maximum     := MaxCurrency;
        used        := true;
        visible     := false;
        virgin      := _count = minimum;
    end;

    result := _index;

    // ���������� ������������ ������������ ������ ��� ���������� ����������� �������� �������
    if fMax < _index then fMax := _index;

end;

procedure TResourceManager.CreateView(index, icon: integer);
{ �������� ������������� ������� ��� ������ �������� }
var
   _layout: TLayout;
   _image: TImage;
   _label: TLabel;
begin

    _layout := TLayout.Create(fFLayout);
    with _layout do
    begin
        Width := 80;
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
        Bitmap.Assign( fMain.ilResources.Bitmap(BitmapSize, icon) );
    end;

    _label := TLabel.Create(_layout);
    with _label do
    begin
        Parent := _layout;
        Height := 15;
        Width := 63;
        Position.X := 17;
        Position.Y := 1;
    end;

    fResources[ index ].view.layout := _layout;
    fResources[ index ].view.image := _image;
    fResources[ index ].view.text := _label;

end;

function TResourceManager.GetCount(index: integer): real;
begin
    result := fResources[ index ].count;
end;

procedure TResourceManager.SetAttr(index, field: integer; value: variant);
{ ������ �������� ������ �� ����� ������� }
begin
    case field of
    FIELD_CAPTION     : fResources[ index ].caption     := value;
    FIELD_DESCRIP     : fResources[ index ].descrip     := value;
    FIELD_COUNT       : fResources[ index ].count       := value;
    FIELD_INCREMENT   : fResources[ index ].increment   := value;
    FIELD_MAXIMUM     : fResources[ index ].maximum     := value;
    FIELD_MINIMUM     : fResources[ index ].minimum     := value;
    FIELD_USED        : fResources[ index ].used        := value;
    FIELD_VISIBLE     : fResources[ index ].visible     := value;
    end;
end;

procedure TResourceManager.SetResData(data: TResource);
{ �������� �� �������� ��������� ������ �� ������ �� ��������.
  ������ ������ ����������� � ������ � ������ ��������� ������ }
var
    i : integer;
begin
    for I := 0 to RES_COUNT - 1 do
    if not fResources[i].used then
        fResources[i] := data;
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

    for I := 0 to RES_COUNT - 1 do
    with fResources[i] do
    begin

        // ������� �������������, ���� ��� ��� � ����� ��� ��������
        if   not Assigned( view.layout )
        then CreateView( i, icon );

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
begin
    with fResources[ index ] do
    if visible then
    begin

        if round(count) <> count
        then
            view.text.Text := Format('%1.1f', [count])
        else
            view.text.Text := Format('%1.0f', [count]);

        if round(increment) <> increment
        then
            view.text.Text := view.text.Text + Format(' (%1.1f)', [increment])
        else
        if   increment <> 0
        then view.text.Text := view.text.Text + Format(' (%1.0f)', [increment])
        else view.text.Text := view.text.Text;


    end;
end;

procedure TResourceManager.ResCount(index: integer; _increment: real);
begin
    with fResources[ index ] do
    begin
       count := count + _increment;

       if count < minimum then count := minimum;
       if count > maximum then count := maximum;

       // ������ ������ ���������� ������ ������� (������ �� ����� ������������ �� ������)
       if virgin and ( count > 0 ) then
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
begin

   for I := 0 to fMax do
   With fResources[i] do
       if used then ResCount( i, increment );

end;

initialization

    BitmapSize.cx := 20;
    BitmapSize.cy := 20;

finalization

    mResManager.Free;

end.

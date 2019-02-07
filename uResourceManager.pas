unit uResourceManager;

///    Менеджер ресурсов.
///    Берет на себя всю работу по созданию, манипуляциям и отображению текущего
///    состояния на панели ресурсов.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types,

    uGameObjectManager;

const

    // синонимы полей записи ресурса
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

type

    TComponents = record
        layout: TLayout;
        image: TImage;
        text: Tlabel;
    end;

    TResource = record
        Resource: TResourcedObject;    // основные числовые атрибуты ресурса

        view : TComponents;      // ссылка на структуру компонент, которая представляет данный ресурс

        used                     // признак использования ячейки (ресурс инициализирован и активен)
       ,visible                  // признак видимости на панели (ресурс остается активным)
       ,virgin                   // ресурс еще ни разу не был получен игроком и будет скрыт, пока не начнет увеличиваться
                                 // механизм постепенного открытия ресурсов, что делает игру более увлевательной
            : boolean;
    end;

    TResourceManager = class
    private
        fLayout  : TLayout;      // родительская панель для блока ресурсов (с кнопкой меню)
        fFLayout : TFlowLayout;  // рабочая панель для блока ресурсов

        fResources : array of TResource;
                                 // массив со всеми существующими ресурсами

        procedure UpdateView( index: integer );
                                 // обновляем содержимое представления ресурса
        procedure CreateView( index: integer; icon: string );
                                 // создает комплект компонент для отображения ресурса на панели fFLayout

    public

        /// МЕТОДЫ ИНИЦИАЛИЗАЦИИ

        procedure SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
                                 // привязываем менеджер к компонентам на форме

        function CreateRecource(_kind: integer; _count, _increment, _once: real): integer;
                                 // создает новый ресурс

//        procedure SetResData( data: TResource );
                                 // полные данные по одному из ресурсов для включения в массив

        /// МЕТОДЫ УПРАВЛЕНИЯ
        procedure OnTimer;       // вычисления на тик таймера

        procedure UpdateResPanel;
                                 // обновляем видимость ресурсов на панели

        procedure ResCount( index: integer; _increment: real = 0 );
                                 // единовременное изменение количества ресурса на значение

        procedure SetAttr( index: integer; field: integer; value: variant );
                                 // устанавливаем значение одного из параметров ресурса

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

function TResourceManager.CreateRecource(_kind: integer; _count, _increment, _once: real): integer;
{ инициализирование ресурса: параметры и создание пердставления }
begin

    // заполняем данными
    SetLength(fResources, Length(fResources)+1);
    with fResources[high(fResources)] do
    begin
        Resource := TResourcedObject.Create;
        SetLength(Resource.Recource, 1 );
        Resource.Recource[0] := uGameObjectManager.TResource.Create( _kind );
        Resource.Recource[0].Item.Count.current := _count;
        Resource.Recource[0].Item.Once.current := _once;
        Resource.Recource[0].Item.Delta.current := _increment;
        Resource.Recource[0].Item.Min.current   := 0;
        Resource.Recource[0].Item.Max.current   := MaxCurrency;

        used        := true;
        visible     := false;
        virgin      := _count = 0;
    end;

end;

procedure TResourceManager.CreateView(index: integer; icon: string);
{ создание представления ресурса для панели ресурсов }
var
   _layout: TLayout;
   _image: TImage;
   _label: TLabel;
   source: TImage;
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
        source := TImage(fImgMap.FindComponent( icon ));
        if assigned(source) then bitmap.Assign( source.MultiResBitmap.Bitmaps[1.0] );

//        Bitmap.Assign( fMain.ilResources.Bitmap(BitmapSize, icon) );
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
    result := fResources[ index ].Resource.Recource[0].Item.count.current;
end;

procedure TResourceManager.SetAttr(index, field: integer; value: variant);
{ меняем значение одного из полей ресурса }
begin
    case field of
    FIELD_CAPTION     : fResources[ index ].Resource.Recource[0].Name               := value;
    FIELD_DESCRIP     : fResources[ index ].Resource.Recource[0].Description        := value;
    FIELD_COUNT       : fResources[ index ].Resource.Recource[0].Item.Count.current := value;
    FIELD_INCREMENT   : fResources[ index ].Resource.Recource[0].Item.Delta.current := value;
    FIELD_MAXIMUM     : fResources[ index ].Resource.Recource[0].Item.Max.current   := value;
    FIELD_MINIMUM     : fResources[ index ].Resource.Recource[0].Item.Min.current   := value;
    FIELD_USED        : fResources[ index ].used        := value;
    FIELD_VISIBLE     : fResources[ index ].visible     := value;
    end;
end;

{
procedure TResourceManager.SetResData(data: TResource);
///  получаем из внешнего источника данные по одному из ресурсов.
///  данный ресурс добавляется в массив в первую свободную ячейку
var
    i : integer;
begin
    for I := 0 to RES_COUNT - 1 do
    if not fResources[i].used then
        fResources[i] := data;
end;
}

procedure TResourceManager.SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
begin
    fLayout := _layout;
    fFLayout := _flayout;
end;

procedure TResourceManager.UpdateResPanel;
{ на данный момент менеджер логики уже определеил видимость всех ресурсов }
var
    i : integer;
begin

    for I := 0 to Length(fResources)-1 do
    with fResources[i] do
    begin

        // создаем представление, если еще нет и нужно его показать
        if   not Assigned( view.layout )
        then CreateView( i, fResources[i].Resource.Recource[0].Visualization.Name[ VISUAL_ICON ] );

        // готовое представление привязываем к объекту, чтобы показать на панели
        if   Assigned( view.layout ) and visible and ( not virgin )
        then view.layout.Parent := fFLayout;

        // отвязываем представление от формы, если нужно скрыть
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

        if round(increment) <> increment
        then
            view.text.Text := view.text.Text + Format(' (%1.1f)', [increment])
        else
        if   increment <> 0
        then view.text.Text := view.text.Text + Format(' (%1.0f)', [increment])
        else view.text.Text := view.text.Text;

    end;
end;

procedure TResourceManager.ResCount(index: integer; _increment: real = 0 );
var
   count
  ,increment
  ,minimum
  ,maximum
   : real;
begin

    with fResources[ index ] do
    begin
        count := fResources[ index ].Resource.Recource[0].Item.count.current;

        if _increment > 0
        then increment := _increment
        else increment := fResources[ index ].Resource.Recource[0].Item.Delta.current;

        minimum := fResources[ index ].Resource.Recource[0].Item.Min.current;
        maximum := fResources[ index ].Resource.Recource[0].Item.Max.current;

       count := count + increment;

       if count < minimum then count := minimum;
       if count > maximum then count := maximum;

       // радуем игрока появлением нового ресурса (теперь он будет отображаться на панели)
       if virgin and ( count > 0 ) then
       begin
           virgin := false;
           view.layout.Parent := fFLayout;
       end;

       fResources[ index ].Resource.Recource[0].Item.count.current := count;

       UpdateView( index );
    end;

end;

procedure TResourceManager.OnTimer;
{ метод срабатывает на таймер. реализует прирост ресурсов согласно значению прироста}
var
   i : integer;
begin

   for I := 0 to High(fResources) do
   With fResources[i] do
       if used then ResCount( i );

end;

initialization

    BitmapSize.cx := 20;
    BitmapSize.cy := 20;

finalization

    mResManager.Free;

end.

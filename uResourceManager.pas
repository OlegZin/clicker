unit uResourceManager;

///    Менеджер ресурсов.
///    Берет на себя всю работу по созданию, манипуляциям и отображению текущего
///    состояния на панели ресурсов.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types;

const

    // максимальное количество типов ресурсов. влияет на размер массива ресурсов
    RES_COUNT = 1000;

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

    // синонимы ресурсов
    RES_IQ             = 0;
    RES_FOOD           = 1;
    RES_HEALTH         = 2;
    RES_MAN            = 3;
    RES_WOMAN          = 4;
    RES_WOOD           = 5;
    RES_STONE          = 6;

    // синонимы id иконок ресурсов в fMain.ilResources (ImageList)
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
        caption                  // имя ресурса для пользователя
       ,descrip                  // краткое описание
            : shortstring;

        icon                     // индекс иконки для ресурса из fMain.ilResources (ImageList)
            : integer;

        count                    // текущее имеющееся количество
       ,increment                // текущий прирост
       ,maximum                  // предел максимального значения
       ,minimum                  // предел минимального значения
            : Real;

        view : TCompinents;      // ссылка на структуру компонент, которая представляет данный ресурс

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

        fResources : array[ 0 .. RES_COUNT - 1 ] of TResource;
                                 // массив со всеми существующими ресурсами
        fMax     : integer;      // максимальный индекс зарегистрированного ресурса для оптимизации перебора массива fResources

        procedure UpdateView( index: integer );
                                 // обновляем содержимое представления ресурса
        procedure CreateView( index, icon: integer );
                                 // создает комплект компонент для отображения ресурса на панели fFLayout

    public

        /// МЕТОДЫ ИНИЦИАЛИЗАЦИИ

        procedure SetupComponents(_layout: TLayout; _flayout: TFlowLayout);
                                 // привязываем менеджер к компонентам на форме

        function CreateRecource(_index: integer; _caption: shortstring; _icon: integer; _count, _increment: real; _descrip: string): integer;
                                 // создает новый ресурс

        procedure SetResData( data: TResource );
                                 // полные данные по одному из ресурсов для включения в массив

        /// МЕТОДЫ УПРАВЛЕНИЯ
        procedure OnTimer;       // вычисления на тик таймера

        procedure UpdateResPanel;
                                 // обновляем видимость ресурсов на панели

        procedure ResCount( index: integer; _increment: real );
                                 // единовременное изменение количества ресурса на значение
                                 //_increment (в плюс или минус)

        procedure SetAttr( index: integer; field: integer; value: variant );
                                 // устанавливаем значение одного из параметров ресурса

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
{ инициализирование ресурса: параметры и создание пердставления }
begin

    // если привышен размер массва ресурсов
    if (_index > RES_COUNT) OR (_index < 0) then
    begin
        result := -1;
        exit;
    end;

    // заполняем данными
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

    // запоминаем максимальный используемый индекс для дальнейшей оптимизации перебора массива
    if fMax < _index then fMax := _index;

end;

procedure TResourceManager.CreateView(index, icon: integer);
{ создание представления ресурса для панели ресурсов }
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
{ меняем значение одного из полей ресурса }
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
{ получаем из внешнего источника данные по одному из ресурсов.
  данный ресурс добавляется в массив в первую свободную ячейку }
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
{ на данный момент менеджер логики уже определеил видимость всех ресурсов }
var
    i : integer;
begin

    for I := 0 to RES_COUNT - 1 do
    with fResources[i] do
    begin

        // создаем представление, если еще нет и нужно его показать
        if   not Assigned( view.layout )
        then CreateView( i, icon );

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

       // радуем игрока появлением нового ресурса (теперь он будет отображаться на панели)
       if virgin and ( count > 0 ) then
       begin
           virgin := false;
           view.layout.Parent := fFLayout;
       end;

       UpdateView( index );
    end;

end;

procedure TResourceManager.OnTimer;
{ метод срабатывает на таймер. реализует прирост ресурсов согласно значению прироста}
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

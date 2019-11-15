unit uResourceManager;

///    Менеджер ресурсов.
///    Берет на себя всю работу по созданию, манипуляциям и отображению текущего
///    состояния на панели ресурсов.
///

interface

uses

    FMX.Layouts, FMX.Types, FMX.Objects, FMX.StdCtrls, SysUtils, System.Types, System.UITypes,

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
    FIELD_PASSTICKS   = 10;

    // режимы пересчета количества ресурсов.
    CALC_MODE_AUTO  = 0;   // на таймер. брать значение Delta с учетом пропуска тиков
    CALC_MODE_CLICK = 1;   // клик игрока. брать значение Once
    CALC_MODE_VALUE = 2;   // принудительно. использовать указанное значение

type

    TComponents = record
        layout: TLayout;
        image: TImage;
        text: Tlabel;
    end;

    TResource = record
        Resource: TResourcedObject;    // основные числовые атрибуты ресурса

        view : TComponents;      // ссылка на структуру компонент, которая представляет данный ресурс

//        used                     // признак использования ячейки (ресурс инициализирован и активен)
        visible                  // признак видимости на панели (ресурс остается активным)
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

        function CreateRecource(_kind: integer; _count, _increment: real): integer;
                                 // создает новый ресурс

        /// МЕТОДЫ УПРАВЛЕНИЯ
        procedure OnTimer;       // вычисления на тик таймера

        procedure UpdateResPanel;
                                 // обновляем видимость ресурсов на панели

        procedure ResCount( mode, index: integer; _increment: real = 0 );
                                 // единовременное изменение количества ресурса на значение
        function TargetResCount(res: uGameObjectManager.TResource; mode: integer; _increment: real = 0 ): real;

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

function TResourceManager.CreateRecource(_kind: integer; _count, _increment: real): integer;
{ инициализирование ресурса: параметры и создание пердставления }
begin

    // заполняем данными
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
{ меняем значение одного из полей ресурса }
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

    // возвращаем величину фактического изменения
    result := count - res.Item.count.current;

    res.Item.Count.current := count;

end;

procedure TResourceManager.ResCount(mode, index: integer; _increment: real = 0 );
{ метод модифицирует глобальные ресурсы и вызывается при тике таймера }
var
   period
           : real;
begin

    with fResources[ index ] do
    begin

        // проверяем на наличие настройки тиков ресурса
        period := Resource.Recource[0].Item.Period.current + Resource.Recource[0].Item.Period.bonus;

        // если указан ненулевой период (отработка каждый тик)
        // проверяем не достигло ли количество пропущенных тиков нужного значения
        if period > Resource.Recource[0].Item.PassTicks then
        begin

           // тикаем за этот вызов таймера...
           Inc(Resource.Recource[0].Item.PassTicks);

           // если достигли конча периода
           if period = Resource.Recource[0].Item.PassTicks
           // сбрасываем счетчик и идем на обработку ресурса
           then Resource.Recource[0].Item.PassTicks := 0
           // иначе выходим. еще не время...
           else exit;

        end;

        // персчитываем ресурс и получаем текущее значение
        TargetResCount( Resource.Recource[0], mode, _increment );

        // радуем игрока появлением нового ресурса (теперь он будет отображаться на панели)
        if virgin and ( Resource.Recource[0].Item.Count.current > 0 ) and visible then
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
    layer, index: integer;
    obj: TBaseObject;
begin

    // перебираем все имеющиеся глобальные ресурсы
    for I := 0 to High(fResources) do ResCount( CALC_MODE_AUTO, i );

    // перебираем все объекты имеющие ресурсы и пересчитываем их, при необходимости
    for layer := 0 to mngObject.GetLayerCount do
    begin

        obj := mngObject.GetFirstOnLayer( layer );

        while Assigned( obj ) do
        begin

            if obj is TResourcedObject then
            for index := 0 to High((obj as TResourcedObject).Recource) do
            begin

                mResManager.TargetResCount(
                    (obj as TResourcedObject).Recource[index],                                                // изменяемый ресурс
                    CALC_MODE_VALUE,                                        // изменяем на указанное количество

                    (obj as TResourcedObject).Recource[index].Item.Delta.current +
                    (obj as TResourcedObject).Recource[index].Item.Delta.bonus     // количество на изменение
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

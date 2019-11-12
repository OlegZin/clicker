unit uGameObjectManager;
{ модуль менеджера объектов.
  описывает и содержит все типы объектов (здания, исследования, ландшафт и т.д),
  а так же предоставляет интерфейс для манипулирования ими.

  каждый объект обладает всеми возможными характеристиками, позволяющими
  использовать его в любых игровых режимах (здоровье, положение, состояния и т.д.)

}
interface

const

    // максимальное количество слоев
    LAYER_COUNT = 99;

    // слоты для имен отображений в массиве  TVisualization.Name / TVisualization.Id
    VISUAL_TILE = 0;
    VISUAL_ICON = 1;

    // поведение при выходе за нижнюю или верхнюю границу количества ресурса
    BOUND_MODE_CUT     = 0;                    // разрешить с выравниванием итога по границе
    BOUND_MODE_BLOCK   = 1;                    // блокировать данное изменение

type

    TBaseObject = class;

    // отвечает за позиционирование в 2d/3d окружении
    TPosition = record
        Х, Y, Z: real;
    end;

    // некий определяющий набор признаков
    TIdentity = record
        Common                       // общий идентификационный класс (природный ландшафт, городской,.. )
       ,Rare                         // уточненный подкласс (лес, горы, больница, станция,.. )
       ,Unique                       // уникальный тип (кровавый лес, флагман Моралиса,.. )
                : integer;

        CommonTag                    // по смыслу аналогично предыдущему, но содержит одну
       ,RareTag                      // или несколько текстовых меток (тэгов) с разделением
       ,UniqueTag                    // через запятую
                : string;
    end;

    TRelations = record
        Parent  : array of integer;  // родитель(-и), к которым привязан
        Child   : array of integer;  // потомок(-ки), которые на него ссылаются
        Together: array of integer;  // находящиеся в той же плоскости иерархии соседи
    end;

    TVisualization = record
        Name: array [0..99] of string[20];  // набор имен картинок для различных игровых режимов
        Id  : array [0..99] of integer; // набор индексов отображения для различных режимов
    end;

    TFloatValue = record
        current                      // текущее значение
       ,delta                        // величина разового изменения (+/-) при прокачке
       ,bonus                        // текущий временный бонус
       ,bonusPeriod                  // оставшееся врямя временного бонуса в тиках
                : real;
    end;

    // описывает текущее состояние и модель поведения отдельного значения
    TCount = record
        Count                        // текущее значение
       ,Period                       // период в тиках таймера обновления значения

       ,Delta                        // размер базового разового изменения при тике.
       ,Once                         // размер базового разового изменения при участии игрока.
                                     // например, при клике по лесу сколько будет добыто древисины

       ,Max                          // максимально возможное базовое значение

       ,Min                          // минимально возможное базовое значение
                : TFloatValue;

        PassTicks                    // счетчик пропущенных тиков. когда сравнивается с
                                     // Period.current, сбрасывается на 0 и производится
                                     // применение Delta.current к Count.current
       ,LowBoundMode                 // что делать при выходе за нижнюю границу
                                     // одно из значений флагов BOUND_MODE_XXX
       ,HighBoundMode                // что делать при выходе за верхнюю границу
                                     // одно из значений флагов BOUND_MODE_XXX
                : integer;
    end;

    // объект с набором базовых свойств
    TBaseObject = class
        id: integer;                   // уникальный в рамках всего мира идентификатор
        visible: boolean;              // глобальный признак видимости. например,
                                       // при сброшенном, флаге объект не будет отображаться на поле, если является тайлом
        Name : string;
        Description : string;

        Identity: TIdentity;           // определяющий набор признаков
        Relation: TRelations;          // набор связей с прочими объектами
        Position: TPosition;           // положение в общем игровом пространстве
        Dependence: TRelations;        // набор зависимостей объектов. например,
                                       // дерево технологий, набор ресурсов для крафта
        Visualization: TVisualization; // ссылки на способы отображения в разных состояниях

        constructor Create; overload;
    end;

    TResource = class(TBaseObject)
        Item: TCount;
        constructor Create(kind: integer); overload;
    end;

    // объект, отображающий элемент/область игрового мира с характерной экосистемой
    // может содержать несколько ресурсов
    TResourcedObject = class(TBaseObject)
        Recource: array of TResource;
    end;

    TObjectManager = class
      private
        fObjects: array [0..LAYER_COUNT] of array of TBaseObject;
        ///    все имеющиеся в игре объекты.
        ///    первый индекс - слой, на котором находится объект
        ///    второй индекс - очередность в массиве всех объектов на данном слое
        ///
        ///    слои полезны во многих аспектах. например, для очередности отрисовки объектов
        ///    на игровом поле для корректного перекрытия.
        ///    или для возможности массовых операций над объектами слоя: скрыть/показать,
        ///    модифицировать, анимировать.
        ///    в данном случае, они позволяют правильно отобразить объектвы относитьельно друг друга
        ///    сначала ландшафт, потом объекты, потом туман войны. где объекты
        ///    перекрывают ландшафт, пока существуют, а туман перекрывает все.

        fLayerIndex: array [0..LAYER_COUNT] of integer;
        ///    массив индексов текущих выбранных объектов на каждом слое
        ///    по одному на слой.
        ///    используется для механизма перебора объектов слоя методами
        ///    GetFirstOnLayer и GetNextOnLayer
        ///    что применяется, например, при отрисовке поля, коргда слои обрабатываются
        ///    в очередности увеличения индекса

        function GetId( layer: integer ): integer;
        ///    возвращает уникальный id для нового объекта.
        ///    генерится на основе номера слоя и индексе объекта в массиве данного слоя.
        ///    что позволяет по самому id определить требуемый элмент массива
        ///    не применяя перебор слоев и объектов.
        ///    подразумевается, что положение объектов в массиве статично и
        ///    обнуляемые экземпляры не изымаются из массива, а просто становятся nil

        procedure AddObjectToArray( obj: TBaseObject; layer: integer );
        ///    добавляет объект в конец массива указанного слоя

      public

        function GetLayerCount: integer;
        ///    возвращает максимальный возможный индекс слоя

        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;
        ///    методы, позволяющие последовательно перебрать все объекты
        ///    указанного слоя, что полезно, на пример, при отрисовке поля

        function CreateTile( Kind, X, Y, layer: integer ): integer;
        ///    создает тайла объекта без ресурса и возвращает его id

        procedure RemoveTile(id : integer);

        procedure SetResource( id, Kind: integer; Count, Once, Delta, Period: real );
        ///    инициализирует и привязывает ресурс к указанному объекту, который
        ///    может содержать ресурсы

        function FindObject( id : integer ): TBaseObject;
        ///    раскладывает полученный id на индексы в массиве fObjects и
        ///    возвращают соответсвующий объект

        function PosIsFree( x, y: real; layer: integer ): boolean;
        ///    проверка, свободна ли указанная позиция на указанном слое
        ///    используется для избежания наслоения объектов на слое
    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB, SysUtils;

procedure TObjectManager.AddObjectToArray(obj: TBaseObject; layer: integer);
///    добавление объекта в конец массива объектов указанного слоя
begin
    SetLength(fObjects[layer], Length(fObjects[layer]) + 1 );
    fObjects[layer][High(fObjects[layer])] := obj;
end;

function TObjectManager.CreateTile(Kind, X, Y, layer: integer): integer;
///    создает тайловую локацию указанного типа и добавляет ее в массив объектов
///    kind - тип объекта
///    x, y - положение на карте
///    layer - слой расположения, объекты более высокого слоя будут перекрывать его
///    в качестве данных используется заранее определенный массив из модуля DB
var
    location: TResourcedObject;
begin
    result := -1;

    if not PosIsFree(x, y, layer) then exit;

    // создаем объект локации, определяем тип и положение
    location := TResourcedObject.Create;
    location.id := GetId( layer );
    location.Identity.Common := Kind;
    location.Position.Х := X;
    location.Position.Y := Y;

    // задаем имя, имя компонента, картинку для данного типа объекта
    location.Visualization.Name[ VISUAL_TILE ]  := TableObjects[ Kind, TABLE_FIELD_TILE_IMAGE ];
    location.Name := TableObjects[ Kind, TABLE_FIELD_NAME ];

    // добавляем в общий массив
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
///    создание в указанной локации ресурса.
///    id - идентификатор объекта в массиве fObjects
///    kind - тип ресурса
///    count - начальное количество
///    once - количество полученного ресурса при клике по объекту с ним
///    delta - получение ресурса по таймеру
///    period - сколько тиков пропускать перед вычислением изменения количества
///             так же влияет на скорость получения при кликах, пока период не
///             закончится, начисление за последующие клики игнорируются
var
    location : TResourcedObject;
    resource : TResource;
    obj : TBaseObject;
begin
    if id < 0 then exit;

    // находим объект, которому нужно добавить ресурс
    obj := FindObject( id );

    // проверяем наличие нужного типа его/предков, поддерживающих
    // привязку ресурсов
    if not (obj is TResourcedObject) then exit;

    // берем его в работу
    location := obj as TResourcedObject;

    // добавляем новый ресурс в массив ресурсов данного объекта
    resource := TResource.Create( kind );
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := resource;

    // инициализируем параметры ресурса
    resource.Item.Count.current  := Count;       // стартовое значение объема ресурса
    resource.Item.Once.current   := Once;        // добыча при клике
    resource.Item.Delta.current  := Delta;       // изменение по таймеру (прирост/убытие)
    resource.Item.Period.current := Period;      // через сколько тиков применять Delta
    resource.Item.PassTicks      := 0;           // инициализация счетчика пропущенных тиков
    resource.Item.Max.current    := MaxCurrency; // максимальный предел

end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ поиск объекта по его id }
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
        if (obj.Position.Х = x) and ( obj.Position.Y = y ) then
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
{ по указанному типу заполняет базовые поля }
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

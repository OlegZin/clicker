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
        Name: array [0..9] of string;  // набор имен отображений для различных игровых режимов
        Id  : array [0..9] of integer; // набор индексов отображения для различных режимов
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

        PassTicks: integer;          // счетчик пропущенных тиков. когда сравнивается с
                                     // Period.current, сбрасывается на 0 и производится
                                     // применение Delta.current к Count.current
    end;

    // объект с набором базовых свойств
    TBaseObject = class
        id: integer;                   // уникальный в рамках всего мира идентификатор
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

        procedure SetResource( id, Kind: integer; Count, Once, Delta, Period: real );
        ///    инициализирует и привязывает ресурс к указанному объекту, который
        ///    может содержать ресурсы

        function FindObject( id : integer ): TBaseObject;
        ///    раскладывает полученный id на индексы в массиве fObjects и
        ///    возвращают соответсвующий объект

    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB;

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
    result := 0;

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

procedure TObjectManager.SetResource(id, Kind: integer; Count,
  Once, Delta, Period: real);
///    создание в указанной локации ресурса.
///    id - идентификатор объекта в массиве fObjects
///    kind - тип ресурса
var
    location : TResourcedObject;
    resource : TResource;
    obj : TBaseObject;
begin
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
    resource.Item.Count.current  := Count;     // стартовое значение объема ресурса
    resource.Item.Once.current   := Once;      // добыча при клике
    resource.Item.Delta.current  := Delta;     // изменение по таймеру (прирост/убытие)
    resource.Item.Period.current := Period;    // через сколько тиков применять Delta
    resource.Item.PassTicks      := 0;         // инициализация счетчика пропущенных тиков

end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ поиск объекта по его id }
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
end;

function TObjectManager.GetLayerCount: integer;
begin
    result := LAYER_COUNT ;
end;

{ TBaseObject }

constructor TBaseObject.Create;
begin
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

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

    /// типы возможных действий с объектом/ресурсом
    ACT_CLICK  = 0;  // обычный клик, без использования панели действий
    ACT_HAND   = 1;  // базовая операция без инструментов
    ACT_SPEAR  = 2;  // использование оружия (атака/взлом/запугивание/...)
    ACT_AXE    = 3;  // использование топора (атака/рубка/...)
    ACT_PICK   = 4;  // использование кирки (добыча/копка/...)
    ACT_SHOVEL = 5;  // использование лопаты (земледелие/копка/...)
    ACT_TALK   = 6;  // использование речи (разговор/приручение/заклинание/...)
    ACT_GROW   = 7;  // земледелие (уход/посадка/...)
    ACT_EXAME  = 8;  // изучение объекта (туман/артефакт/...)
    ACT_KNIFE  = 9;  // использование ножа (снятие шкуры/...)


    // поведение при выходе за нижнюю или верхнюю границу количества ресурса
//    BOUND_MODE_CUT     = 0;                    // разрешить с выравниванием итога по границе
//    BOUND_MODE_BLOCK   = 1;                    // блокировать данное изменение

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

    /// описание модификатора, наложенного на какое-либо значение
    TBonus = record
        field: integer;  /// поле значения из TCount. Индексируется набором констант uResourceManager.FIELD_XXX
        name: string;    /// идентификатор типа бонуса. по нему отсекаются повторные наложения, если не допустимы и проводится поиск в наложенных бонусаъ
        value: real;     /// величина изменения. при наложении модификатора, количество в указанном поле
                         /// сразу меняется на это значение через (+). при снятии, прозводится
                         /// обратное изменение через (-).
        period: real;    /// период существования данного модификатора в тиках, после чего будет автоматически удален
                         /// при значении -1 - постоянный
        active: boolean; /// является ли активным. false - не учитывается в расчетах, но и не удаляется, period не изменяется.
                         /// true - в обычном режиме. используется для эффектов временного отключения модификаторов
        deleted: boolean;/// флаг того, что данный бонус в массиве не используется и может быть перезаписан новым
    end;

    // описывает текущее состояние и модель поведения отдельного значения
    TCount = record
       Count                        // текущее значение (базовое)
      ,Period                       // период в тиках таймера обновления значения (базовое)

       ,Delta                        // размер базового разового изменения при тике. (базовое)
       ,Once                         // размер базового разового изменения при участии игрока.
                                     // например, при клике по лесу сколько будет добыто древисины

       ,Max                          // максимально возможное базовое значение (базовое)

       ,Min                          // минимально возможное базовое значение (базовое)

        /// значения измененные с учетом всех активных на данный момент бонусов
       ,bCount                       // текущее значение
       ,bPeriod                      // период в тиках таймера обновления значения
       ,bDelta                       // размер базового разового изменения при тике.
       ,bOnce                        // размер базового разового изменения при участии игрока.
       ,bMax                         // максимально возможное базовое значение
       ,bMin                         // минимально возможное базовое значение
                : real;

        PassTicks                    // счетчик пропущенных тиков. когда сравнивается с
                                     // Period.current, сбрасывается на 0 и производится
                                     // применение Delta.current к Count.current
       ,LowBoundMode                 // что делать при выходе за нижнюю границу
                                     // одно из значений флагов BOUND_MODE_XXX
       ,HighBoundMode                // что делать при выходе за верхнюю границу
                                     // одно из значений флагов BOUND_MODE_XXX
                : integer;

        Bonus : array of TBonus;
    end;

    // действие над объектом или ресурсом
    TObjAction = record
        Kind : integer;     // тип действия (иконка на панели действий). привязан к имеющимся знаниям и ресурсам)
        Cost: TCount;       // стоимость действия в единицах производства. влияет на скорость завершения действия.
                            // например, если у игрока всего одна единица производства, а стиомость действия 10, то
                            // действие завершится через 10 тиков таймера
        Exp: TCount;        // базовое количество опыта за успешное завершение действия
        Item : TCount;      // количественное изменение ресурса при завершения действия
    end;

    // объект с набором базовых свойств
    TBaseObject = class
        id: integer;                   // уникальный в рамках всего мира идентификатор
        visible: boolean;              // глобальный признак видимости. например,
                                       // при сброшенном, флаге объект не будет отображаться на поле, если является тайлом
        Image: TObject;                // объект-картинка, которой отображается
        FullY: real;                   // положение по Y нижнего края картинки
        Name : string;
        Description : string;
        Identity: TIdentity;           // определяющий набор признаков
        Position: TPosition;           // положение в общем игровом пространстве
        Visualization: TVisualization; // ссылки на способы отображения в разных состояниях
        constructor Create; overload;
    end;

    TResource = class(TBaseObject)
        Item: TCount;
        Valued: boolean;               // не имеющие "ценности" ресурсы не учитываются при проверке
                                       // на истощение всех источников на объекте для его уничтожения
        Actions: array of TObjAction;  // массив действий, которые можно совершать с этим ресурсом.
                                       // Влияет на формирование панели выбранного объекта

        constructor Create(kind: integer; Count: real; valued: boolean = true ); overload;

        function Maximum( max: real ):TResource;
        /// установка максимума ресурса

        function Growing( Delta, Period: real ): TResource;
        /// дает ресурсу возможность автоматического прироста/истощения с течением времени

        function Action( Kind: integer; Count, Exp: real; Cost: real = 0 ): TResource;
        /// привязывает к ресурсу какое-либо действие

        function GetAction( Kind: integer ): TObjAction;
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

        procedure ClearField;
        /// метод обнуляет массив объектоа, а заодно и все созданные для них объекты-картинки

        function GetLayerCount: integer;
        ///    возвращает максимальный возможный индекс слоя

        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;
        ///    методы, позволяющие последовательно перебрать все объекты
        ///    указанного слоя, что полезно, на пример, при отрисовке поля

        function CreateTile( Kind, X, Y, layer: integer; H: real ): integer;
        ///    создает тайла объекта без ресурса и возвращает его id

        procedure RemoveTile(id : integer);

        procedure SetResource( id: integer; res: TResource );
        ///    инициализирует и привязывает ресурс к указанному объекту (id), который
        ///    может содержать ресурсы. возвращает созданный ресурс для возможной более тонкой настройки

        function FindObject( id : integer ): TBaseObject;
        ///    раскладывает полученный id на индексы в массиве fObjects и
        ///    возвращают соответсвующий объект

        function PosIsFree( x, y: real; layer: integer ): boolean;
        ///    проверка, свободна ли указанная позиция на указанном слое
        ///    используется для избежания наслоения объектов на слое

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
///    добавление объекта в конец массива объектов указанного слоя
begin
    SetLength(fObjects[layer], Length(fObjects[layer]) + 1 );
    fObjects[layer][High(fObjects[layer])] := obj;
end;

procedure TObjectManager.CalcBonus(var item: TCount);
var
    i : integer;
begin
    ///обнуляем текущий расчет бонусов
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
/// полностью вычищаем память ранее созданной игровойц сесии
var
    layer, i, j: integer;
begin
    for layer := 0 to High(fObjects) do
    begin
        /// грохаем картинки
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

        /// удаляем элементы слоя
        SetLength(fObjects[layer], 0);
    end;
end;

function TObjectManager.CreateTile(Kind, X, Y, layer: integer; H: real): integer;
///    создает тайловую локацию указанного типа и добавляет ее в массив объектов
///    kind - тип объекта
///    x, y - положение на карте
///    layer - слой расположения, объекты более высокого слоя будут перекрывать его
///    в качестве данных используется заранее определенный массив из модуля DB
var
    location: TResourcedObject;
begin
    result := -1;

//    if not PosIsFree(x, y, layer) then exit;

    // создаем объект локации, определяем тип и положение
    location := TResourcedObject.Create;
    location.id := GetId( layer );
    location.Identity.Common := Kind;
    location.Position.Х := X;
    location.Position.Y := Y;
    location.FullY := Y + H;

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

procedure TObjectManager.SetResource(id: integer; res: TResource);
///    создание в указанной локации ресурса.
///    id - идентификатор объекта в массиве fObjects
///    kind - тип ресурса
///    count - начальное количество
///    once - количество полученного ресурса при клике по объекту с ним
///    delta - получение ресурса по таймеру, если значение не нулевое, то
///            количество ресурса будет постепенно прирастать до максимума
///    period - сколько тиков пропускать перед вычислением изменения количества
///    vaued - признак, нужно ли будет учитывать данный ресурс при проверке
///            на исчерпание всех источников ресурсов объекта. незначимые ресурсы
///            используются для постоянного эффекта до истощения всех значимых ресурсов.
///            например, в качестве снижения здоровья при стражении с монстрами
var
    location : TResourcedObject;
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
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := res;
end;

function TObjectManager.FindObject(id: integer): TBaseObject;
{ поиск объекта по его id }
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
/// механизм выравнивания глубины объектов
/// проблема: после рандомной генерации объектов в динамическом массиве объектов
/// координата Y идет в перемешку. При генерации игрового поля эта чехорда
/// приведет к тому, что "ближние" к игроку объекты (с большим Y) будут
/// перекрываться "дальними" объектами, поскольку они находятся дальше к концу
/// массива объектов.
/// решение - сортировкой пузырьком на всех слоях раскладываем объекты в порядке
/// возрастания координаты Y (с учетом высоты объекта)
///
/// поскольку id объектов, это их координаты в массиве всех объектов, то при
/// обмене объектов местами в массиве, id нужно переставить обратно, на правильные места
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
{ по указанному типу заполняет базовые поля }
begin

    self.Identity.Common := kind;
    self.Name := TableResource[ kind, TABLE_FIELD_NAME ];
    self.Visualization.Name[ VISUAL_ICON ] := TableResource[ kind, TABLE_FIELD_ICON_IMAGE ];

    // инициализируем параметры ресурса
    /// базовые значения, без учета бонусов
    self.Item.Count  := Count;       // стартовое значение объема ресурса
    self.Item.Once   := 0;           // добыча при клике
    self.Item.Delta  := 0;           // изменение по таймеру (прирост/убытие)
    self.Item.Period := 0;           // через сколько тиков применять Delta

    /// значения, с учетом бонусов
    self.Item.bCount  := Count;       // стартовое значение объема ресурса
    self.Item.bOnce   := 0;           // добыча при клике
    self.Item.bDelta  := 0;           // изменение по таймеру (прирост/убытие)
    self.Item.bPeriod := 0;           // через сколько тиков применять Delta

    self.Item.PassTicks      := 0;           // инициализация счетчика пропущенных тиков
    self.Item.Max    := MaxCurrency; // максимальный предел
    self.Item.Min    := 0;           // минимальный предел
    self.Valued              := valued;      // признак важного ресурса для проверки на истощение (будет ли учитываться)
end;

function TResource.GetAction(Kind: integer): TObjAction;
/// получаем данные действия по его типу
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
    Item.Delta  := Delta;           // изменение по таймеру (прирост/убытие)
    Item.Period := Period;           // через сколько тиков применять Delta

    Item.bDelta  := Delta;           // изменение по таймеру (прирост/убытие)
    Item.bPeriod := Period;           // через сколько тиков применять Delta
end;

function TResource.Maximum(max: real): TResource;
begin
    result := self;
    Item.Max := max;
end;

function TResource.Action(Kind: integer; Count, Exp: real; Cost: real = 0 ): TResource;
/// привязывает действие к ресурсу
///    kind - тип действия. константа ACT_XXX
///    count - количественное изменение ресурса при завершении действия
///    exp - базовое количество опыта за завершенное действие
///    cost - стоимость в единицах производства для завершения действия
begin
    result := self;
    SetLength(Actions, Length(Actions) + 1);
    Actions[High(Actions)].Kind := Kind;

    /// выставляем базовые значения (которые неизменны)
    Actions[High(Actions)].Item.Count := Count;
    Actions[High(Actions)].Exp.Count := Exp;
    Actions[High(Actions)].Cost.Count := Cost;

    /// выставляем значения с учетом бонусов (если они появятся, будут пересчитываться)
    Actions[High(Actions)].Item.bCount := Count;
    Actions[High(Actions)].Exp.bCount := Exp;
    Actions[High(Actions)].Cost.bCount := Cost;
end;

initialization
    mngObject := TObjectManager.Create;

finalization
    mngObject.Free;

end.

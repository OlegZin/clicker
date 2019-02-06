unit uGameObjectManager;
{ модуль менеджера объектов.
  описывает и содержит все типы объектов (здания, исследования, ландшафт и т.д),
  а так же предоставляет интерфейс для манипулирования ими.

  каждый объект обладает всеми возможными характеристиками, позволяющими
  использовать его в любых игровых режимах (здоровье, положение, состояния и т.д.)

}
interface

const

    // определение типов тайлов
    // типы местности
    LAND_FOREST = 0;     // лес
    LAND_PLAIN  = 1;     // равнина
    LAND_MOUNT  = 2;     // горы
    LAND_SAND   = 3;     // пустыня
    LAND_ICE    = 4;     // ледник
    LAND_CANYON = 5;     // разлом
    LAND_LAVA   = 6;     // лавовое поле
    LAND_FOG    = 7;     // лавовое поле

    // типы объектов
    OBJ_NONE        =  0;  // нет объекта
    OBJ_FOG         =  1;  // тайл еще не исследован (туман войны)
    OBJ_TOWN_SMALL  =  2;  // маленькое поселение
    OBJ_TOWN_MEDIUM =  3;  // среднее поселение
    OBJ_TOWN_BIG    =  4;  // большое поселение
    OBJ_TOWN_GREAT  =  5;  // огромное поселение
    OBJ_PREDATOR    =  6;  // хищник
    OBJ_MAMONT      =  7;  // мамонт (временный)
    OBJ_ATTACKER    =  8;  // атакующее племя (временный)
    OBJ_CAVE        =  9;  // пещера
    OBJ_HERD        = 10;  // стадо (временный)

    // типы тесурсов
    RESOURCE_IQ     = 0;
    RESOURCE_HEALTH = 1;
    RESOURCE_MAN    = 2;
    RESOURCE_WOMAN  = 3;

    RESOURCE_WOOD   = 4;
    RESOURCE_GRASS  = 5;
    RESOURCE_STONE  = 6;
    RESOURCE_ICE    = 7;
    RESOURCE_LAVA   = 8;

    RESOURCE_FOOD   = 9;
    RESOURCE_BONE   = 10;

    LAYER_COUNT = 99;

    // слоты для имен отображений в массиве  TVisualization.Name / TVisualization.Id
    VISUAL_TILE = 0;

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
        Res: TCount;
    end;

    // объект, отображающий элемент/область игрового мира с характерной экосистемой
    // может содержать несколько ресурсов
    TLocation = class(TBaseObject)
        Recource: array of TResource;
    end;

    TObjectManager = class
      private
        ID: integer;                        // id-счетчик для очередного создаваемого объекта
        fObjects: array [0..LAYER_COUNT] of array of TBaseObject;     // все имеющиеся в игре объекты
        fLayerIndex: array [0..LAYER_COUNT] of integer;

        function GetId( layer: integer ): integer;            // возвращает уникальный id для нового объекта
        function FindObject( id : integer ): TBaseObject;
        procedure AddObjectToArray( obj: TBaseObject; layer: integer );
      public

        function GetLayerCount: integer;
        function GetFirstOnLayer( layer: integer ): TBaseObject;
        function GetNextOnLayer( layer: integer ): TBaseObject;

        function CreateLocationTile( Kind, X, Y, Z: integer ): integer;
        // создает базовую локацию в виде тайла без ресурса и возвращает его id

        procedure SetLocationResource( id, Kind: integer; Count, Once, Delta, Period: real );
        // привязывает ресурс к указанной локации

    end;

var
    mngObject : TObjectManager;

implementation

{ TObjectManager }

uses
    DB;

procedure TObjectManager.AddObjectToArray(obj: TBaseObject; layer: integer);
begin
    SetLength(fObjects[layer], Length(fObjects[layer]) + 1 );
    fObjects[layer][High(fObjects[layer])] := obj;
end;

function TObjectManager.CreateLocationTile(Kind, X, Y, Z: integer): integer;
{
}
var
    location: TLocation;
begin
    result := 0;

    location := TLocation.Create;
    location.id := GetId( Z );
    location.Identity.Common := Kind;
    location.Position.Х := X;
    location.Position.Y := Y;

    // заполняем имя и имя компонента с картинкой для данного типа месности
    location.Visualization.Name[ VISUAL_TILE ]  := TableLocations[ Kind, LAND_FIELD_IMAGE ];
    location.Name := TableLocations[ Kind, LAND_FIELD_NAME];

    AddObjectToArray( location, Z );

    // добавляем источник ресурса при клике
//    SetLocationResource( location.id, RESOURCE_WOOD, 1000, 1, 0.01, 1 );

    result := location.id;
end;

procedure TObjectManager.SetLocationResource(id, Kind: integer; Count,
  Once, Delta, Period: real);
{ создание в указанной локации ресурса }
var
    location : TLocation;
    resource : TResource;
begin
    location := FindObject( id ) as TLocation;

    // добавляем новый ресурс в массив
    resource := TResource.Create;
    SetLength(location.Recource, Length(location.Recource)+1);
    location.Recource[ High(location.Recource) ] := resource;

    resource.Res.Count.current  := Count;     // стартовое значение объема ресурса
    resource.Res.Once.current   := Once;      // добыча при клике
    resource.Res.Delta.current  := Delta;     // изменение по таймеру (прирост/убытие)
    resource.Res.Period.current := Period;    // сколько тиков на одну Delta
    resource.Res.PassTicks      := 0;         // инициализация счетчика пропущенных тиков
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

//    Result := self.ID;
//    Inc(self.ID);
end;

function TObjectManager.GetLayerCount: integer;
begin
    result := LAYER_COUNT ;
end;

{ TBaseObject }

constructor TBaseObject.Create;
begin
end;

initialization
    mngObject := TObjectManager.Create;
    mngObject.ID := 1;

finalization
    mngObject.Free;

end.

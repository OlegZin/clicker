unit uGameManager;

///    МЕНЕДЖЕР ИГРОВОЙ ЛОГИКИ
///    следит за игровым сюжетом:
///      - выполнение условий для открытия новых возможностей (бафы, науки, юниты и т.д.)
///      - переключение эпох
///      - сообщения на важные игровые события

interface

const
    FILE_RESOURCES_SAVE = 'resources.dat';
    FILE_GAMESTATE_SAVE = 'gamestate.dat';

    ///    КОНСТАНТЫ ТЭГОВ
    ///    - временнЫе (в какие эпохи доступен ресурс)
    ///    - режимы (в каких игровых режимах доступен ресурс)
    ///
    ERA_PRIMAL     = 1;         // первобытное общество (каменный век)
    ERA_ANCIENT    = 2;         // древний мир (античность)
    ERA_MEDIVAL    = 4;         // средние века
    ERA_TECHNICAL  = 8;         // новая эра (техническая революция)
    ERA_ELECTRONIC = 16;        // новейшая эра (современность с электроникой)
    ERA_COSMIC     = 32;        // космическая эра (начало покорения космоса)
    ERA_EXPANSE    = 64;        // эра покорения глубокого космоса (начало покорения космоса)
    ERA_SINGULAR   = 128;       // эра сингулярности (полного технического всемогущества)

    ///    ТЭГИ РЕЖИМОВ
    ///    в зависимости от текущей эры дают доступ к разным по функционалу,
    ///    но одинаковым по масштабу и смыслу режимам
    MODE_LOCAL     = 1;         // режим минимальной локации (постройка города, исследование территории)
    MODE_COUNTRY   = 2;         // режим управления сообществом (страна, сектор)
    MODE_PLANET    = 4;         // режим управления сообществом (страна, сектор)

    /// набор флагов, показывающий объекту, вызывающему ProcessObjectClick
    /// какие состояния и элементы игры подвергуты изменениям, чтобы это обработать
    /// например, изменилась конфигурация или видимость объектов на поле

    PROCESS_CHANGE_FIELD = 1;  // изменилось состояние объекта на поле

type
    TGameState = record
        Potential: Currency;          // текущий потенциал, который не теряется при начале новой игры
                                       // и является одним из ресурсов
        Era      : Integer;           // текущая игровая эра. соответсвует константе TAG_ERA_XXX
        Mode     : Integer;            // текущий игровой режим. соответсвует константе TAG_MODE_XXX
        CurSelObjectId: integer;      // текущий выбранный на игровом поле объект. 0 - не выбран

        isHungry : boolean;           // флаг отсекает лишние вычисления при неизменности статуса голода:
                                      // запас еды нулевой. позволяет произвоить действия перехода из/в состояние только один
                                      // раз в момент изменения условий

        isGameInProcess : boolean;    // флаг указывает, что игра начата и в процессе. учитывается в главном меню
                                      // при определении доступности кнопок
    end;

    TGameManager = class
      private
        procedure SetIsHungry(val: boolean);
        procedure SetIsGameInProcess(val: boolean);
      public
        GameState : TGameState;

        property isHungry: boolean read GameState.isHungry write SetIsHungry;
        property isGameInProcess: boolean read GameState.isGameInProcess write SetIsGameInProcess;

        function ProcessObjectClick( id : integer ): integer;
        procedure InitGame;
        procedure CalcGameState;

    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager, uTiledModeManager, DB, uToolPanelManager, uMain;

procedure TGameManager.CalcGameState;
///    логическое ядро.
///    метод вызывается таймером, кликом игрока, при инициализации игры.

///    при изменении состояния ресурсов или иных значимых объектов производит
///    переоценку состояния игры и вносит изменения в процесс, если выполняются
///    прописанные условия.
///    например, при накоплении нужно количества ресурса, может открыться возможность
///    крафта нового предмета

begin
    ////////////////////////////////////////////////////////////////////////////
    /// перераспределение ресурсов
    ////////////////////////////////////////////////////////////////////////////
    /// контроль по количеству еды:
    ///    при нулевом или ниже количестве - накладывается штраф на скорость прироста здоровья
    ///    при нелулевом - снимается штраф на скорость прироста здоровья

    if (mResManager.GetAttr(RESOURCE_FOOD, FIELD_COUNT) <= 0) and not isHungry then
    begin
        mResManager.AddBonus( RESOURCE_HEALTH, FIELD_DELTA, 'hungry', FUNGRY_VALUE );
        isHungry := true;
    end;

    if (mResManager.GetAttr(RESOURCE_FOOD, FIELD_COUNT) > 0) and isHungry then
    begin
        mResManager.DelBonus( RESOURCE_HEALTH, FIELD_DELTA, 'hungry' );
        isHungry := false;
    end;



    /// проверка на выполнение условий завершения игры - ПОРАЖЕНИЕ.
    /// к ним относится сочетние парметров: текущее здоровье = 0, количество людей = 0, еда = 0
//    if True then


end;

procedure TGameManager.InitGame;
var
   fResFile: File of TResource;
   rResRec : TResource;

   fStateFile: File of TGameState;

   resLoaded          // удалось ли загрузить данные ресурсов из автосейва
  ,stateLoaded        // удалось ли загрузить данные состояния игры из автосейва
           : boolean;
begin
    // пытаемся считать данные предыдущей сессии игры (автосейв при выходе из игры)
{    if FileExists( FILE_RESOURCES_SAVE ) then
    begin
        try
            AssignFile( fResFile, FILE_RESOURCES_SAVE );

            while not EOF( fResFile ) do
            begin
                Read( fResFile, rResRec );
                mResManager.SetResData( rResRec );
            end;

            resLoaded := true;
            CloseFile( fResFile );
        except
        end;
    end;

    // пытаемся считать данные предыдущей сессии игры (автосейв при выходе из игры)
    if FileExists( FILE_GAMESTATE_SAVE ) then
    begin
        try
            AssignFile( fStateFile, FILE_GAMESTATE_SAVE );

            Read( fStateFile, mGameManager.GameSatate );

            stateLoaded := true;
            CloseFile( fStateFile );
        except
        end;
    end;
 }


    // при неудачной загрузке инициализируем новую игру
    // в этом случае создаем все типы ресурсов из всех эпох, чтобы далее к этому не возвращаться
//    if not ( resLoaded and stateLoaded ) then
    with mResManager, mGameManager do
    begin

        // создаем ресурсы: тип, начальное количество, изменение за тик таймера
        CreateRecource( RESOURCE_IQ,      0,   0  );
        CreateRecource( RESOURCE_HEALTH, 29,  0.1 );
        CreateRecource( RESOURCE_MAN,     1,   0  );
        CreateRecource( RESOURCE_WOMAN,   0,   0  );
        CreateRecource( RESOURCE_WOOD,    0,   0  );
        CreateRecource( RESOURCE_GRASS,   0,   0  );
        CreateRecource( RESOURCE_STONE,   0,   0  );
        CreateRecource( RESOURCE_ICE,     0,   0  );
        CreateRecource( RESOURCE_LAVA,    0,   0  );
        CreateRecource( RESOURCE_FOOD,   50, -0.1 );
        CreateRecource( RESOURCE_BONE,    0,   0  );
        CreateRecource( RESOURCE_PRODUCT, 1,   0  );
        CreateRecource( RESOURCE_SPEAR,   5,   0  );
        CreateRecource( RESOURCE_SKIN,    3,   0  );
        CreateRecource( RESOURCE_HIDE,    8,   0  );


        SetAttr(RESOURCE_HEALTH, FIELD_MAXIMUM, 100);

//        GameState.Potential := 0;
//        GameState.Era := ERA_PRIMAL;
//        GameState.Mode := MODE_LOCAL;

        isHungry := false;
        isGameInProcess := false;
    end;

end;

function TGameManager.ProcessObjectClick(id: integer): integer;
/// обработка клика мышкой/тапа по объекту
var
    obj : TBaseObject;
    i: integer;
    resTile: uGameObjectManager.TResource;

    deltaSource
   ,deltaTarget
            : real;

    actClick : TObjAction;

    hasChanges : boolean;

   ResPresent    /// при обработке ресурсов проверяем какое количество из них
                  /// еще не закончилось
            : integer;
begin


    hasChanges := false;
    ResPresent := 0;
    result := 0;

    // получаем ссылку на объекта из массива
    obj := mngObject.FindObject( id );

    /// текущий выделенный объект не совпадает с предыдущим
    if   mGameManager.GameState.CurSelObjectId <> id then
    begin
        // выделяем кликнутый объект, если до сих пор не выбран
        mTileDrive.SetSelection( obj as TResourcedObject );
        // показываем его на панели свойств/действий
        mToolPanel.ObjectSelect( obj as TResourcedObject );
    end;

    // будем обрабатывать, если он может содержать и содержит ресурсы
    if obj is TResourcedObject then
    if   Length((obj as TResourcedObject).Recource) > 0 then

    // перебираем все имеющиеся в локации ресурсы и отправляем на пересчет
    for I := 0 to High((obj as TResourcedObject).Recource) do
    begin

        Inc(ResPresent);    // найденный ресурс заведомо считаем не истощившимся

        // получаем лаконичное имя
        resTile := (obj as TResourcedObject).Recource[i];

        ///    логика пересчета следующая. при клике по локации ее Once
        ///    (списание за клик) имеет отрицательное значение, что
        ///    уменьшает запас в локации ( Count ), но при этом, в общем
        ///    хранилище запас должен увеличиваться. т.е. прирост с обратным знаком
        ///    и на оборот, что делает клик по локации ресурсопотребляющим
        ///    например, это монстр и для его атаки расходуется что-то из ресурсов

        /// проверяем наличие привязанного действия ACT_CLICK. если нет - пропускаем ресурс
        actClick := resTile.GetAction( ACT_CLICK );

        if actClick.Item.bCount <> 0 then
        begin
            // проверяем возможность взятия ресурса
            // персчитываем ресурс в локации. не факт, что удастся изменить
            // ресурс на величину actClick.Item.Count. например пытаемся отнять 10 от 1 или
            // ресурс достиг своего нижнего предела
            deltaSource :=
            mResManager.TargetResCount(
                resTile,                           // изменяемый ресурс
                CALC_MODE_VALUE,                   // изменяем на указанное количество
                actClick.Item.bCount                // количество на изменение
            );

            // если изменения локального ресурса не произошло (достигнут верхний или нижний лимит)
            // в глобальном хранилише менять тоже не будем
            if deltaSource <> 0 then

            // пересчитываем в глобальном хранилище
            mResManager.ResCount(
                CALC_MODE_VALUE,                                        // изменяем на указанное количество
                resTile.Identity.Common,                                // тип изменяемого ресурса
                -(deltaSource)                                          // количество на изменение
            );
            ///    при клике можно запустить пересчет в режиме CALC_MODE_CLICK,
            ///    но при этом буддет использована настройка разового изменения
            ///    самого ресурса из хранилища, а не индивидуальные параметры
            ///    самой локации.
            ///    потому используется режим CALC_MODE_VALUE, чтобы учитивать
            ///    индивидуальные особенности локаций

            // ставим флаг изменений, чтобы запустить пересчет состояния игры
            hasChanges := true;



            /// если данный ресурс исчерпан или не имеет значения, игнорируем его
            /// в количестве неисчерпавшихся
            if ( resTile.Item.Count <= resTile.Item.Min ) and
               ( resTile.Valued )
            then Dec(ResPresent)
            else
            if not resTile.Valued then Dec(ResPresent);
        end;
    end;

    /// если не осталось значимых ресурсов - удаляем объект
    if ResPresent = 0 then
    begin
        /// некоторые типы объектов при этом должны быть разрушены или заменены другими
        /// например, дерево становится пеньком, куст с ягодами - обычным кустом
{        case obj.Identity.Common of
            /// простые источники ресурса просто удаляются
            OBJ_BUSH,
            OBJ_TREE,
            OBJ_BIGTREE,
            OBJ_DEADTREE,

            OBJ_SMALLGRASS,
            OBJ_PAPOROTNIK,

            OBJ_BROVNSTONE,
            OBJ_GRAYSTONE,

            OBJ_MUSH,

            OBJ_BIZON
            :
                mngObject.RemoveTile( obj.id );
            else mngObject.RemoveTile( obj.id );
        end;
}
        /// пока что уничтожаются все объекты, кроме ландшафта
        if obj.Identity.Common > OBJ_DEAD then
        begin
           mngObject.RemoveTile( obj.id );
           mTileDrive.DropSelection;
           mToolPanel.ObjectUnselect;
           hasChanges := true;
        end;

        result := result or PROCESS_CHANGE_FIELD;
    end;

    // пересчитываем состояние игры
    if hasChanges then CalcGameState;

end;

procedure TGameManager.SetIsGameInProcess(val: boolean);
begin
    GameState.isGameInProcess := val;
    fMain.iContinue.Enabled := val;
end;

procedure TGameManager.SetIsHungry(val: boolean);
begin
    GameState.isHungry := val;
end;

end.

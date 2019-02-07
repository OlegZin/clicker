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

type
    TGameState = record
        Potential: Currency;          // текущий потенциал, который не теряется при начале новой игры
                                       // и является одним из ресурсов
        Era      : Integer;           // текущая игровая эра. соответсвует константе TAG_ERA_XXX
        Mode     : Integer            // текущий игровой режим. соответсвует константе TAG_MODE_XXX
    end;

    TGameManager = class
        GameSatate : TGameState;

        procedure ProcessObjectClick( id : integer );
        procedure InitGame;
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager, DB;

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

        // создаем ресурсы
        CreateRecource( RESOURCE_IQ, 0, 0, 1 );
        CreateRecource( RESOURCE_HEALTH, 90, 1, 1 );
        CreateRecource( RESOURCE_MAN, 1, 0, 1 );
        CreateRecource( RESOURCE_WOMAN, 0, 0, 1 );
        CreateRecource( RESOURCE_WOOD, 0, 0, 1 );
        CreateRecource( RESOURCE_GRASS, 0, 0, 1 );
        CreateRecource( RESOURCE_STONE, 0, 0, 1 );
        CreateRecource( RESOURCE_ICE, 0, 0, 1 );
        CreateRecource( RESOURCE_LAVA, 0, 0, 1 );
        CreateRecource( RESOURCE_FOOD, 10, -1, 1 );
        CreateRecource( RESOURCE_BONE, 0, 0, 1 );

        SetAttr(RESOURCE_HEALTH, FIELD_MAXIMUM, 100);

        GameSatate.Potential := 0;
        GameSatate.Era := ERA_PRIMAL;
        GameSatate.Mode := MODE_LOCAL;
    end;

end;

procedure TGameManager.ProcessObjectClick(id: integer);
var
    obj : TBaseObject;
begin
    obj := mngObject.FindObject( id );
    if obj is TResourcedObject then
    begin
        // если привязан хотя бы один ресурс
        if   Length((obj as TResourcedObject).Recource) > 0
        then mResManager.ResCount( RESOURCE_WOOD, (obj as TResourcedObject).Recource[0].Item.Once.current );
    end;

end;

end.

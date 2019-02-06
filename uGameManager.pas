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
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager;

procedure TGameManager.ProcessObjectClick(id: integer);
var
    obj : TBaseObject;
begin
    obj := mngObject.FindObject( id );
    if obj is TResoursed then
    begin
        // если привязан хотя бы один ресурс
        if   Length((obj as TResoursed).Recource) > 0
        then mResManager.ResCount(RES_WOOD, 1);
    end;

end;

end.

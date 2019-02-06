unit DB;

interface

const
    TABLE_FIELD_NAME       = 0;
    TABLE_FIELD_ICON_IMAGE = 1;
    TABLE_FIELD_TILE_IMAGE = 1;

    // типы объектов
    OBJ_FOREST      =  0;  // лес
    OBJ_PLAIN       =  1;  // равнина
    OBJ_MOUNT       =  2;  // горы
    OBJ_SAND        =  3;  // пустыня
    OBJ_ICE         =  4;  // ледник
    OBJ_CANYON      =  5;  // разлом
    OBJ_LAVA        =  6;  // лавовое поле
    OBJ_FOG         =  7;  // лавовое поле
    OBJ_TOWN_SMALL  =  8;  // маленькое поселение
    OBJ_TOWN_MEDIUM =  9;  // среднее поселение
    OBJ_TOWN_BIG    = 10;  // большое поселение
    OBJ_TOWN_GREAT  = 11;  // огромное поселение
    OBJ_PREDATOR    = 12;  // хищник
    OBJ_MAMONT      = 13;  // мамонт (временный)
    OBJ_ATTACKER    = 14;  // атакующее племя (временный)
    OBJ_CAVE        = 15;  // пещера
    OBJ_HERD        = 16;  // стадо (временный)

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

var
    TableObjects : array [0..7, 0..2] of string = (
      ('Лес',     'tile_forest', ''),
      ('Равнина', 'tile_plane',  ''),
      ('Горы',    'tile_mount',  ''),
      ('Пустыня', 'tile_sand',   ''),
      ('Ледник',  'tile_ice',    ''),
      ('Разлом',  'tile_canyon', ''),
      ('Лава',    'tile_lava',   ''),
      ('Туман',   'tile_fog',    '')
    );

    TableResource : array [0..10, 0..2] of string = (
      ('Интеллект', 'icon_iq',     ''),
      ('Здоровье',  'icon_health', ''),
      ('Мужчины',   'icon_man',    ''),
      ('Женщины',   'icon_woman',  ''),
      ('Древесина', 'icon_wood',   ''),
      ('Трава',     'icon_grass',  ''),
      ('Камень',    'icon_stone',  ''),
      ('Лед',       'icon_ice',    ''),
      ('Лава',      'icon_lava',   ''),
      ('Еда',       'icon_food',   ''),
      ('Кости',     'icon_bone',   '')
    );

implementation

end.

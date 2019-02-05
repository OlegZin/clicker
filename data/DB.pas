unit DB;

interface

const
    LAND_FIELD_IMAGE = 0;
    LAND_FIELD_NAME  = 1;

var
    TableLocations : array [0..6, 0..2] of string = (
      ('tile_forest', 'Лес',     ''),
      ('tile_plane',  'Равнина', ''),
      ('tile_mount',  'Горы',    ''),
      ('tile_sand',   'Пустыня', ''),
      ('tile_ice',    'Ледник',  ''),
      ('tile_canyon', 'Разлом',  ''),
      ('tile_lava',   'Лава',    '')
    );

implementation

end.

unit DB;

interface

const
    LAND_FIELD_IMAGE = 0;
    LAND_FIELD_NAME  = 1;

var
    TableLocations : array [0..6, 0..2] of string = (
      ('tile_forest', '���',     ''),
      ('tile_plane',  '�������', ''),
      ('tile_mount',  '����',    ''),
      ('tile_sand',   '�������', ''),
      ('tile_ice',    '������',  ''),
      ('tile_canyon', '������',  ''),
      ('tile_lava',   '����',    '')
    );

implementation

end.

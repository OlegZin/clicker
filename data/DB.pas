unit DB;

interface

const
    TABLE_FIELD_NAME       = 0;
    TABLE_FIELD_ICON_IMAGE = 1;
    TABLE_FIELD_TILE_IMAGE = 1;

    // ���� ��������
    OBJ_FOREST      =  0;  // ���
    OBJ_PLAIN       =  1;  // �������
    OBJ_MOUNT       =  2;  // ����
    OBJ_SAND        =  3;  // �������
    OBJ_ICE         =  4;  // ������
    OBJ_CANYON      =  5;  // ������
    OBJ_LAVA        =  6;  // ������� ����
    OBJ_FOG         =  7;  // ������� ����
    OBJ_DEAD        =  8;  // ����� (���������)
    OBJ_TOWN_SMALL  =  9;  // ��������� ���������
    OBJ_TOWN_MEDIUM = 10;  // ������� ���������
    OBJ_TOWN_BIG    = 11;  // ������� ���������
    OBJ_TOWN_GREAT  = 12;  // �������� ���������
    OBJ_PREDATOR    = 13;  // ������
    OBJ_MAMONT      = 14;  // ������ (���������)
    OBJ_ATTACKER    = 15;  // ��������� ����� (���������)
    OBJ_CAVE        = 16;  // ������
    OBJ_HERD        = 17;  // ����� (���������)

    // ���� ��������
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
    TableObjects : array [0..8, 0..2] of string = (
      ('���',     'tile_forest', ''),
      ('�������', 'tile_plane',  ''),
      ('����',    'tile_mount',  ''),
      ('�������', 'tile_sand',   ''),
      ('������',  'tile_ice',    ''),
      ('������',  'tile_canyon', ''),
      ('����',    'tile_lava',   ''),
      ('�����',   'tile_fog',    ''),
      ('������� �����', 'tile_dead',    '')
    );

    TableResource : array [0..10, 0..2] of string = (
      ('���������', 'icon_iq',     '��������� ��� ����������� ����� ����������. ����������� ��� ������ ����� ����.'),
      ('��������',  'icon_health', '�������� ������ ������� ������������� �������. ��� ������� �� ���� - ���� �� ������ ������� �������.'),
      ('�������',   'icon_man',    '������� ������ �������. ���������� ������ � ���������� � ������� ���������. ��� ������ ���� - ����� ��������.'),
      ('�������',   'icon_woman',  '������� ������ �������. ���� ������� � �����������, ���������� ������ � ���������.'),
      ('���������', 'icon_wood',   '������� ���������. ������������ � �������������, ������������ ������������.'),
      ('�����',     'icon_grass',  ''),
      ('������',    'icon_stone',  '������� ������. ������������ � �������������, ������������ ������������.'),
      ('���',       'icon_ice',    ''),
      ('����',      'icon_lava',   ''),
      ('���',       'icon_food',   '��� ������� ������ �������� ������ �������� �������.'),
      ('�����',     'icon_bone',   '')
    );

implementation

end.

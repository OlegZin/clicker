unit uImgMap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TfImgMap = class(TForm)
    tile_fog: TImage;
    icon_iq: TImage;
    icon_food: TImage;
    icon_health: TImage;
    icon_man: TImage;
    icon_wood: TImage;
    icon_stone: TImage;
    icon_woman: TImage;
    tile_dead: TImage;
    tile_plane: TImage;
    tile_bush: TImage;
    tile_tree: TImage;
    tile_bigtree: TImage;
    tile_deadtree: TImage;
    tile_paporotnik: TImage;
    tile_appletree: TImage;
    tile_graystone: TImage;
    tile_brovnstone: TImage;
    tile_smallgrass: TImage;
    tile_wolf: TImage;
    tile_bizon: TImage;
    tile_bear: TImage;
    tile_mush: TImage;
    tile_blackwolf: TImage;
    icon_prod: TImage;
    icon_grass: TImage;
    icon_spear: TImage;
    icon_skin: TImage;
    icon_hide: TImage;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    tile_b_mush: TImage;
    Image8: TImage;
    tile_w_flover: TImage;
    tile_y_flower: TImage;
    tile_b_flower: TImage;
    iObjectActive: TImage;
    iObjectUnactive: TImage;
    iScienceUnactive: TImage;
    iScienceActive: TImage;
    iProductionActive: TImage;
    iProductionUnactive: TImage;
    iOperationActive: TImage;
    iOperationUnactive: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fImgMap: TfImgMap;

implementation

{$R *.fmx}

end.

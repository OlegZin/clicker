unit uToolPanelManager;

interface

uses
    FMX.TabControl, FMX.Layouts, FMX.Objects, FMX.StdCtrls,

    uGameObjectManager, DB;

type
    TImageArr = array of TImage;

    TToolPanelManager = class
      private
        fTabButtonPanel
               : TLayout;
        fTabPanel
               : TTabControl;
        fButtons,
        fButtonsActive,
        fButtonsUnactive
               : TImageArr;

        fObjectPreview : TImage;

        fCurrObject: TResourcedObject;
        fObjectName: TLabel;
        /// текущий выбранный на карте объект, на каждый тик его данные будут обновляться

      public
        procedure ObjectSelect( obj: TResourcedObject );
        procedure ObjectUnselect;

        procedure SetupComponents( tabButtonPanel: TLayout; tabPanel: TTabControl; buttons, active, unactive: TImageArr );
        procedure SetupObjectPanelComponents( preview: TImage; objectName: TLabel );
        procedure Init;
    end;

var

   mToolPanel: TToolPanelManager;

implementation

{ TToolPanelManager }

procedure TToolPanelManager.SetupComponents(tabButtonPanel: TLayout;
  tabPanel: TTabControl; buttons, active,
  unactive: TImageArr);
/// настройка основных компонент панели управления
///    tabButtonPanel - слой на котором находятся кнопки переключения панелей
///    tabPanel - сам компонент со страницами-панелями. их содержимое привязывается отдельно
///    buttons - набор кнопок в интерфейсе, которые будут переключать панели. их порядок должен
///              соответствовать порядку страниц tabPanel. т.е. 1 кнопка будет открывать 1 страницу и т.д.
///    active - набор картинок, содержащих картинки активного состояния для buttons
///    unactive - набор картинок, содержащих картинки неактивного состояния для buttons
begin
    fTabButtonPanel := tabButtonPanel;
    fTabPanel := tabPanel;
    fButtons := buttons;
    fButtonsActive := active;
    fButtonsUnactive := unactive;
end;

procedure TToolPanelManager.SetupObjectPanelComponents(preview: TImage; objectName: TLabel);
begin
    fObjectPreview := preview;
    fObjectName := objectName;
end;

procedure TToolPanelManager.Init;
/// первоначальная настройка вида панели
var
    i: integer;
begin
    fTabPanel.ActiveTab := fTabPanel.Tabs[0];

    for I := 0 to High(fButtons) do
    if i = 0
    then fButtons[i].bitmap.Assign( fButtonsActive[i].MultiResBitmap.Bitmaps[1.0] )
    else fButtons[i].bitmap.Assign( fButtonsUnactive[i].MultiResBitmap.Bitmaps[1.0] );

    fObjectName.Text := '';

end;

procedure TToolPanelManager.ObjectSelect(obj: TResourcedObject);
begin
    if not Assigned(obj.Image) or not (obj.Image is TImage) then exit;
    fObjectPreview.bitmap.Assign( TImage(obj.Image).MultiResBitmap.Bitmaps[1.0] );

    fCurrObject := obj;
    fObjectName.Text := TableObjects[obj.Identity.Common, OBJECTS_FIELD_NAME];
end;

procedure TToolPanelManager.ObjectUnselect;
/// сбрасывает выделение текущего объекта, очищая панели от данных
begin
    fCurrObject := nil;
    fObjectPreview.Bitmap := nil;
end;

initialization
   mToolPanel := TToolPanelManager.Create;

finalization
   mToolPanel.Free;

end.

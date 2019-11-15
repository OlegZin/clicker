unit uToolPanelManager;

interface

uses
    FMX.TabControl, FMX.Layouts, FMX.Objects, FMX.StdCtrls, SysUtils,

    uGameObjectManager, DB, uImgMap;

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

        /// панель выделенного объекта
        fObjectPreview : TImage;   // предпросмотр
        fObjectName: TLabel;       // имя объекта
        fObjActions : TImageArr;   // картинки для отображения доступных действий


        fCurrObject: TResourcedObject;
        /// текущий выбранный на карте объект, на каждый тик его данные будут обновляться

      public
        procedure ObjectSelect( obj: TResourcedObject );
        procedure ObjectUnselect;

        procedure SetupComponents( tabButtonPanel: TLayout; tabPanel: TTabControl; buttons, active, unactive: TImageArr );
        procedure SetupObjectPanelComponents( preview: TImage; objectName: TLabel; actImages: TImageArr );
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

procedure TToolPanelManager.SetupObjectPanelComponents(preview: TImage; objectName: TLabel; actImages: TImageArr);
begin
    fObjectPreview := preview;
    fObjectName := objectName;
    fObjActions := actImages;
end;

procedure TToolPanelManager.Init;
/// первоначальная настройка вида панели
var
    i: integer;
begin
    fTabPanel.ActiveTab := fTabPanel.Tabs[0];

    for I := 0 to High(fButtons) do
    begin
        if i = 0
        then fButtons[i].bitmap.Assign( fButtonsActive[i].MultiResBitmap.Bitmaps[1.0] )
        else fButtons[i].bitmap.Assign( fButtonsUnactive[i].MultiResBitmap.Bitmaps[1.0] );
    end;

    fObjectName.Text := '';
    for I := 0 to High(fObjActions) do
    fObjActions[i].Visible := false;
end;

procedure TToolPanelManager.ObjectSelect(obj: TResourcedObject);
/// наполняем панель параметрами выделленого объекта
var
    res, act, curActImg : integer;
    img : TImage;
begin
    fCurrObject := obj;

    /// предпросмотр
    if not Assigned(obj.Image) or not (obj.Image is TImage) then exit;
    fObjectPreview.bitmap.Assign( TImage(obj.Image).MultiResBitmap.Bitmaps[1.0] );

    /// имя
    fObjectName.Text := TableObjects[obj.Identity.Common, OBJECTS_FIELD_NAME];

    /// доступные действия
    for res := 0 to High(fObjActions) do
    fObjActions[res].Visible := false;

    curActImg := 0;
    for res := 0 to High(obj.Recource) do
    for act := 0 to High(obj.Recource[res].Actions) do
    if obj.Recource[res].Actions[act].Kind <> 0 then
    begin
        img := fObjActions[curActImg];
        img.Tag := obj.Recource[res].Actions[act].Kind;
        img.bitmap.Assign( TImage( fImgMap.FindComponent( 'action_' + IntToStr(img.Tag) )).MultiResBitmap.Bitmaps[1.0] );
        img.visible := true;

        Inc(curActImg);
    end;
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

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

        /// ������ ����������� �������
        fObjectPreview : TImage;   // ������������
        fObjectName: TLabel;       // ��� �������
        fObjActions : TImageArr;   // �������� ��� ����������� ��������� ��������


        fCurrObject: TResourcedObject;
        /// ������� ��������� �� ����� ������, �� ������ ��� ��� ������ ����� �����������

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
/// ��������� �������� ��������� ������ ����������
///    tabButtonPanel - ���� �� ������� ��������� ������ ������������ �������
///    tabPanel - ��� ��������� �� ����������-��������. �� ���������� ������������� ��������
///    buttons - ����� ������ � ����������, ������� ����� ����������� ������. �� ������� ������
///              ��������������� ������� ������� tabPanel. �.�. 1 ������ ����� ��������� 1 �������� � �.�.
///    active - ����� ��������, ���������� �������� ��������� ��������� ��� buttons
///    unactive - ����� ��������, ���������� �������� ����������� ��������� ��� buttons
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
/// �������������� ��������� ���� ������
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
/// ��������� ������ ����������� ����������� �������
var
    res, act, curActImg : integer;
    img : TImage;
begin
    fCurrObject := obj;

    /// ������������
    if not Assigned(obj.Image) or not (obj.Image is TImage) then exit;
    fObjectPreview.bitmap.Assign( TImage(obj.Image).MultiResBitmap.Bitmaps[1.0] );

    /// ���
    fObjectName.Text := TableObjects[obj.Identity.Common, OBJECTS_FIELD_NAME];

    /// ��������� ��������
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
/// ���������� ��������� �������� �������, ������ ������ �� ������
begin
    fCurrObject := nil;
    fObjectPreview.Bitmap := nil;
end;

initialization
   mToolPanel := TToolPanelManager.Create;

finalization
   mToolPanel.Free;

end.

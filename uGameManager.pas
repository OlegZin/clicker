unit uGameManager;

///    �������� ������� ������
///    ������ �� ������� �������:
///      - ���������� ������� ��� �������� ����� ������������ (����, �����, ����� � �.�.)
///      - ������������ ����
///      - ��������� �� ������ ������� �������

interface

const
    FILE_RESOURCES_SAVE = 'resources.dat';
    FILE_GAMESTATE_SAVE = 'gamestate.dat';

    ///    ��������� �����
    ///    - ��������� (� ����� ����� �������� ������)
    ///    - ������ (� ����� ������� ������� �������� ������)
    ///
    ERA_PRIMAL     = 1;         // ����������� �������� (�������� ���)
    ERA_ANCIENT    = 2;         // ������� ��� (����������)
    ERA_MEDIVAL    = 4;         // ������� ����
    ERA_TECHNICAL  = 8;         // ����� ��� (����������� ���������)
    ERA_ELECTRONIC = 16;        // �������� ��� (������������� � ������������)
    ERA_COSMIC     = 32;        // ����������� ��� (������ ��������� �������)
    ERA_EXPANSE    = 64;        // ��� ��������� ��������� ������� (������ ��������� �������)
    ERA_SINGULAR   = 128;       // ��� ������������� (������� ������������ �������������)

    ///    ���� �������
    ///    � ����������� �� ������� ��� ���� ������ � ������ �� �����������,
    ///    �� ���������� �� �������� � ������ �������
    MODE_LOCAL     = 1;         // ����� ����������� ������� (��������� ������, ������������ ����������)
    MODE_COUNTRY   = 2;         // ����� ���������� ����������� (������, ������)
    MODE_PLANET    = 4;         // ����� ���������� ����������� (������, ������)

    /// ����� ������, ������������ �������, ����������� ProcessObjectClick
    /// ����� ��������� � �������� ���� ���������� ����������, ����� ��� ����������
    /// ��������, ���������� ������������ ��� ��������� �������� �� ����

    PROCESS_CHANGE_FIELD = 1;  // ���������� ��������� ������� �� ����

type
    TCallback = procedure( result: variant ) of object;

    TGameState = record
        Potential: Currency;          // ������� ���������, ������� �� �������� ��� ������ ����� ����
                                       // � �������� ����� �� ��������
        Era      : Integer;           // ������� ������� ���. ������������ ��������� TAG_ERA_XXX
        Mode     : Integer;            // ������� ������� �����. ������������ ��������� TAG_MODE_XXX
        CurSelObjectId: integer;      // ������� ��������� �� ������� ���� ������. 0 - �� ������

        fisHungry : boolean;           // ���� �������� ������ ���������� ��� ������������ ������� ������:
                                      // ����� ��� �������. ��������� ���������� �������� �������� ��/� ��������� ������ ����
                                      // ��� � ������ ��������� �������

        fisGameInProcess : boolean;    // ���� ���������, ��� ���� ������ � � ��������. ����������� � ������� ����
                                      // ��� ����������� ����������� ������
        fisGameOver : integer;        // ���� ���������� ����. �������� - ���������. 0 - ��������� (��������� �������� �������)
    end;

    TGameManager = class
      private
        fMessCallback : TCallback;
        procedure SetIsHungry(val: boolean);
        procedure SetIsGameInProcess(val: boolean);
      public
        GameState : TGameState;

        property isHungry: boolean read GameState.fisHungry write SetIsHungry;
        property isGameInProcess: boolean read GameState.fisGameInProcess write SetIsGameInProcess;
        property isGameOver: integer read GameState.fisGameOver write GameState.fisGameOver;

        function ProcessObjectClick( id : integer ): integer;
        procedure InitGame;
        procedure CalcGameState;

        procedure ShowMessage(icon, text : string; callback: TCallback = nil);

        procedure OnOkClick(Sender: TObject);

        procedure OnGameOver( result: variant );
    end;

var
   mGameManager : TGameManager;

implementation

{ TGameManager }

uses
    uGameObjectManager, uResourceManager, uTiledModeManager, DB, uToolPanelManager, uMain, uImgMap, FMX.Types;

procedure TGameManager.CalcGameState;
///    ���������� ����.
///    ����� ���������� ��������, ������ ������, ��� ������������� ����.

///    ��� ��������� ��������� �������� ��� ���� �������� �������� ����������
///    ���������� ��������� ���� � ������ ��������� � �������, ���� �����������
///    ����������� �������.
///    ��������, ��� ���������� ����� ���������� �������, ����� ��������� �����������
///    ������ ������ ��������

begin
    ////////////////////////////////////////////////////////////////////////////
    /// ����������������� ��������
    ////////////////////////////////////////////////////////////////////////////
    /// �������� �� ���������� ���:
    ///    ��� ������� ��� ���� ���������� - ������������� ����� �� �������� �������� ��������
    ///    ��� ��������� - ��������� ����� �� �������� �������� ��������

    if (mResManager.GetAttr(RESOURCE_FOOD, FIELD_COUNT) <= 0) and not isHungry then
    begin
        mResManager.AddBonus( RESOURCE_HEALTH, FIELD_DELTA, 'hungry', FUNGRY_VALUE );
        isHungry := true;
    end;

    if (mResManager.GetAttr(RESOURCE_FOOD, FIELD_COUNT) > 0) and isHungry then
    begin
        mResManager.DelBonus( RESOURCE_HEALTH, FIELD_DELTA, 'hungry' );
        isHungry := false;
    end;



    /// �������� �� ���������� ������� ���������� ���� - ���������.
    /// � ��� ��������� �������� ���������: ������� �������� = 0, ���������� ����� = 0, ��� = 0
    if (mResManager.GetAttr(RESOURCE_FOOD, FIELD_COUNT) <= 0) and
       (mResManager.GetAttr(RESOURCE_HEALTH, FIELD_COUNT) <= 0) and
       (mResManager.GetAttr(RESOURCE_MAN, FIELD_COUNT) <= 1)
    then
    begin
        isGameOver := 0; // ��������� - ��������� �������� �������
        isGameInProcess := false;
        ShowMessage(MESS_ICON_DEAD ,'�������� ����� � ���� �������� ����� ����� �������...', OnGameOver);
    end;

end;

procedure TGameManager.InitGame;
var
   fResFile: File of TResource;
   rResRec : TResource;

   fStateFile: File of TGameState;

   resLoaded          // ������� �� ��������� ������ �������� �� ���������
  ,stateLoaded        // ������� �� ��������� ������ ��������� ���� �� ���������
           : boolean;
begin
    // �������� ������� ������ ���������� ������ ���� (�������� ��� ������ �� ����)
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

    // �������� ������� ������ ���������� ������ ���� (�������� ��� ������ �� ����)
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


    // ��� ��������� �������� �������������� ����� ����
    // � ���� ������ ������� ��� ���� �������� �� ���� ����, ����� ����� � ����� �� ������������
//    if not ( resLoaded and stateLoaded ) then
    with mResManager, mGameManager do
    begin

        // ������� �������: ���, ��������� ����������, ��������� �� ��� �������
        // ���� ��� ������� - ���������� �������� �� ���������
        CreateRecource( RESOURCE_IQ,      0,   0  );
        CreateRecource( RESOURCE_HEALTH, 25,  0.1 );
        CreateRecource( RESOURCE_MAN,     1,   0  );
        CreateRecource( RESOURCE_WOMAN,   0,   0  );
        CreateRecource( RESOURCE_WOOD,    0,   0  );
        CreateRecource( RESOURCE_GRASS,   0,   0  );
        CreateRecource( RESOURCE_STONE,   0,   0  );
        CreateRecource( RESOURCE_ICE,     0,   0  );
        CreateRecource( RESOURCE_LAVA,    0,   0  );
        CreateRecource( RESOURCE_FOOD,   50, -0.1 );
        CreateRecource( RESOURCE_BONE,    0,   0  );
        CreateRecource( RESOURCE_PRODUCT, 1,   0  );
        CreateRecource( RESOURCE_SPEAR,   5,   0  );
        CreateRecource( RESOURCE_SKIN,    3,   0  );
        CreateRecource( RESOURCE_HIDE,    8,   0  );


        SetAttr(RESOURCE_HEALTH, FIELD_MAXIMUM, 100);

//        GameState.Potential := 0;
//        GameState.Era := ERA_PRIMAL;
//        GameState.Mode := MODE_LOCAL;

        isHungry := false;
        isGameOver := -1; // ����� ����� ���������� ����
    end;

end;


function TGameManager.ProcessObjectClick(id: integer): integer;
/// ��������� ����� ������/���� �� �������
var
    obj : TBaseObject;
    i: integer;
    resTile: uGameObjectManager.TResource;

    deltaSource
   ,deltaTarget
            : real;

    actClick : TObjAction;

    hasChanges : boolean;

   ResPresent    /// ��� ��������� �������� ��������� ����� ���������� �� ���
                  /// ��� �� �����������
            : integer;
begin


    hasChanges := false;
    ResPresent := 0;
    result := 0;

    // �������� ������ �� ������� �� �������
    obj := mngObject.FindObject( id );

    /// ������� ���������� ������ �� ��������� � ����������
    if   mGameManager.GameState.CurSelObjectId <> id then
    begin
        // �������� ��������� ������, ���� �� ��� ��� �� ������
        mTileDrive.SetSelection( obj as TResourcedObject );
        // ���������� ��� �� ������ �������/��������
        mToolPanel.ObjectSelect( obj as TResourcedObject );
    end;

    // ����� ������������, ���� �� ����� ��������� � �������� �������
    if obj is TResourcedObject then
    if   Length((obj as TResourcedObject).Recource) > 0 then

    // ���������� ��� ��������� � ������� ������� � ���������� �� ��������
    for I := 0 to High((obj as TResourcedObject).Recource) do
    begin

        Inc(ResPresent);    // ��������� ������ �������� ������� �� ������������

        // �������� ���������� ���
        resTile := (obj as TResourcedObject).Recource[i];

        ///    ������ ��������� ���������. ��� ����� �� ������� �� Once
        ///    (�������� �� ����) ����� ������������� ��������, ���
        ///    ��������� ����� � ������� ( Count ), �� ��� ����, � �����
        ///    ��������� ����� ������ �������������. �.�. ������� � �������� ������
        ///    � �� ������, ��� ������ ���� �� ������� �������������������
        ///    ��������, ��� ������ � ��� ��� ����� ����������� ���-�� �� ��������

        /// ��������� ������� ������������ �������� ACT_CLICK. ���� ��� - ���������� ������
        actClick := resTile.GetAction( ACT_CLICK );

        if actClick.Item.bCount <> 0 then
        begin
            // ��������� ����������� ������ �������
            // ������������ ������ � �������. �� ����, ��� ������� ��������
            // ������ �� �������� actClick.Item.Count. �������� �������� ������ 10 �� 1 ���
            // ������ ������ ������ ������� �������
            deltaSource :=
            mResManager.TargetResCount(
                resTile,                           // ���������� ������
                CALC_MODE_VALUE,                   // �������� �� ��������� ����������
                actClick.Item.bCount                // ���������� �� ���������
            );

            // ���� ��������� ���������� ������� �� ��������� (��������� ������� ��� ������ �����)
            // � ���������� ��������� ������ ���� �� �����
            if deltaSource <> 0 then
            begin
              // ������������� � ���������� ���������
              mResManager.ResCount(
                  CALC_MODE_VALUE,                                        // �������� �� ��������� ����������
                  resTile.Identity.Common,                                // ��� ����������� �������
                  -(deltaSource)                                          // ���������� �� ���������
              );
              ///    ��� ����� ����� ��������� �������� � ������ CALC_MODE_CLICK,
              ///    �� ��� ���� ������ ������������ ��������� �������� ���������
              ///    ������ ������� �� ���������, � �� �������������� ���������
              ///    ����� �������.
              ///    ������ ������������ ����� CALC_MODE_VALUE, ����� ���������
              ///    �������������� ����������� �������


              /// ��������� ���������� �����
              mResManager.ResCount(
                  CALC_MODE_VALUE,                            // �������� �� ��������� ����������
                  RESOURCE_IQ,                                // ��� ����������� �������
                  actClick.Exp.bCount                         // ���������� �� ���������
              );


              // ������ ���� ���������, ����� ��������� �������� ��������� ����
              hasChanges := true;



              /// ���� ������ ������ �������� ��� �� ����� ��������, ���������� ���
              /// � ���������� ���������������
              if ( resTile.Item.Count <= resTile.Item.Min ) and
                 ( resTile.Valued )
              then Dec(ResPresent)
              else
              if not resTile.Valued then Dec(ResPresent);
            end;
        end;
    end;

    /// ���� �� �������� �������� �������� - ������� ������
    if ResPresent = 0 then
    begin
        /// ��������� ���� �������� ��� ���� ������ ���� ��������� ��� �������� �������
        /// ��������, ������ ���������� �������, ���� � ������� - ������� ������
{        case obj.Identity.Common of
            /// ������� ��������� ������� ������ ���������
            OBJ_BUSH,
            OBJ_TREE,
            OBJ_BIGTREE,
            OBJ_DEADTREE,

            OBJ_SMALLGRASS,
            OBJ_PAPOROTNIK,

            OBJ_BROVNSTONE,
            OBJ_GRAYSTONE,

            OBJ_MUSH,

            OBJ_BIZON
            :
                mngObject.RemoveTile( obj.id );
            else mngObject.RemoveTile( obj.id );
        end;
}
        /// ���� ��� ������������ ��� �������, ����� ���������
        if obj.Identity.Common > OBJ_DEAD then
        begin
           mngObject.RemoveTile( obj.id );
           mTileDrive.DropSelection;
           mToolPanel.ObjectUnselect;
           hasChanges := true;
        end;

        result := result or PROCESS_CHANGE_FIELD;
    end;

    // ������������� ��������� ����
    if hasChanges then CalcGameState;

end;

procedure TGameManager.SetIsGameInProcess(val: boolean);
begin
    GameState.fisGameInProcess := val;
    fMain.iContinue.Enabled := val;
end;

procedure TGameManager.SetIsHungry(val: boolean);
begin
    GameState.fisHungry := val;
end;

procedure TGameManager.ShowMessage(icon, text: string; callback: TCallback = nil);
begin
    fMain.tResTimer.Enabled := false;

    fImgMap.rOkButton.OnClick := self.OnOkClick;
    fMessCallback := callback;

    fImgMap.rMessScreenBackground.Parent := fMain;
    fImgMap.rMessScreenBackground.Align := TAlignLayout.Client;
    fImgMap.rMessScreenBackground.OnClick := self.OnOkClick;
    fImgMap.rMessScreenBackground.BringToFront;

    fImgMap.lMessage.Parent := fMain;
    fImgMap.lMessage.BringToFront;


    if not fImgMap.AssignImage( fImgMap.iImg, icon )
    then fImgMap.AssignImage( fImgMap.iImg, MESS_ICON_NEUTRAL );


    if fImgMap.lMessage.Width > fMain.Width
    then fImgMap.lMessage.Width := fMain.Width;

    fImgMap.lMessage.Position.X := (fMain.Width - fImgMap.lMessage.Width) / 2;
    fImgMap.lMessage.Align := TAlignLayout.Center;
    fImgMap.lMess.Text := text;
end;

procedure TGameManager.OnGameOver(result: variant);
begin
    fMain.tabsScreen.ActiveTab := fMain.tabMenu;
end;

procedure TGameManager.OnOkClick(Sender: TObject);
begin
    fImgMap.rMessScreenBackground.Parent := nil;
    fImgMap.lMessage.Parent := nil;

    fMain.tResTimer.Enabled := true;

    if Assigned(fMessCallback) then fMessCallback('ok');
end;

end.

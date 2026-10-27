// Original C&W resources. FR-003/004/007. Base map styles come from the runtime.
class RscMapControl {};
class CWR_Text
{
    type=0; idc=-1; style=0; lineSpacing=1; x=0; y=0; w=1; h=0.05;
    text=""; font="cwrBodyB24"; sizeEx=0.025;
    colorText[]={0.88,0.9,0.84,1}; colorBackground[]={0,0,0,0};
};
class CWR_Background: CWR_Text
{
    style=48; x=0; y=0; w=1; h=1; text="";
    colorText[]={1,1,1,1};
};
class CWR_Button: CWR_Text
{
    type=1; style=2; w=0.23; h=0.06;
    colorText[]={0.94,0.77,0.36,1}; colorDisabled[]={0.35,0.38,0.33,1};
    colorBackground[]={0.10,0.14,0.11,1}; colorBackgroundActive[]={0.22,0.28,0.18,1};
    colorFocused[]={0.22,0.28,0.18,1}; colorShadow[]={0,0,0,0}; colorBorder[]={0.48,0.44,0.26,1};
    offsetX=0; offsetY=0; offsetPressedX=0; offsetPressedY=0.002; borderSize=0.001;
    soundEnter[]={"",0,1}; soundPush[]={"",0,1}; soundClick[]={"",0,1}; soundEscape[]={"",0,1};
};
class CWR_Main
{
    idd=0; movingEnable=0;
    controlsBackground[]={"Background","Shade"};
    controls[]={"Title","Subtitle","Slice","Missions","Mods","Options","Quit","Notice"};
    class Background: CWR_Background {};
    class Shade: CWR_Text { x=0.04; y=0.12; w=0.43; h=0.77; colorBackground[]={0.025,0.035,0.03,0.92}; };
    class Title: CWR_Text { idc=7391; x=0.07; y=0.17; w=0.38; h=0.09; sizeEx=0.052; text="CONFLICT & WAR"; colorText[]={0.94,0.77,0.36,1}; };
    class Subtitle: CWR_Text { idc=7393; x=0.075; y=0.27; w=0.36; text="REAL-TIME STRATEGY / FIRST SLICE"; sizeEx=0.019; };
    class Slice: CWR_Button { idc=7390; x=0.075; y=0.40; w=0.35; text="EVERON / ESTABLISH BASE"; };
    class Missions: CWR_Button { idc=117; x=0.075; y=0.48; w=0.35; text="MISSIONS"; };
    class Mods: CWR_Button { idc=119; x=0.075; y=0.56; w=0.35; text="MODS"; };
    class Options: CWR_Button { idc=102; x=0.075; y=0.64; w=0.35; text="SETTINGS"; };
    class Quit: CWR_Button { idc=106; x=0.075; y=0.72; w=0.35; text="EXIT"; };
    class Notice: CWR_Text { idc=7392; x=0.075; y=0.81; w=0.35; h=0.10; style=16; sizeEx=0.018; text="C&W / Modified fork\nBased on Bohemia Interactive source.\nNot an official Bohemia Interactive product."; };
};
class RscTitles
{
    class CWR_Startup
    {
        idd=-1; movingEnable=0; duration=2; fadeIn=0.25; fadeOut=0.25;
        name="Conflict & War"; controls[]={"Background","Title","Notice"};
        class Background: CWR_Background {};
        class Title: CWR_Text { x=0.06; y=0.35; w=0.75; h=0.12; sizeEx=0.075; text="CONFLICT & WAR"; colorText[]={0.94,0.77,0.36,1}; };
        class Notice: CWR_Text { x=0.065; y=0.49; w=0.70; h=0.12; style=16; text="Command. Build. Deploy.\nA modified fork based on Bohemia Interactive source."; };
    };
};
// Original C&W sidebar composition: minimap, blue tabs, two-column production grid.
class CWR_Card: CWR_Text
{
    type=0; style=48; color[]={1,1,1,1}; colorActive[]={0.55,0.85,1,1};
    soundEnter[]={"",0,1}; soundPush[]={"",0,1}; soundClick[]={"",0,1}; soundEscape[]={"",0,1};
    x=0.782; y=0.39; w=0.096; h=0.13;
};
class CWR_BarracksArt: CWR_Text { type=0; style=48; x=0.782; y=0.39; w=0.096; h=0.13; colorText[]={1,1,1,1}; text=""; };
class CWR_InfantryArt: CWR_Text { type=0; style=48; x=0.782; y=0.39; w=0.096; h=0.13; colorText[]={1,1,1,1}; text=""; };
class CWR_Slot: CWR_Text
{
    x=0.782; y=0.55; w=0.096; h=0.13; colorBackground[]={0.025,0.035,0.045,1};
    colorText[]={0.22,0.26,0.29,1}; style=2; sizeEx=0.018; text="";
};
class CWR_Command
{
    idd=7300; movingEnable=0;
    controlsBackground[]={"Steel","Panel","Edge","BlueTop","MapFrame","Slot1","Slot2","Slot3","Slot4","Slot5","Slot6","Slot7","Slot8"};
    controls[]={"World","Map","Header","Theatre","Credits","Status","TabBuild","TabInfantry","BuildArt","TrainArt","Build","Train","BuildLabel","TrainLabel","Other","Production","Home","Exit","Help"};
    class World: CWR_Text { type=102; idc=7301; x=0; y=0; w=0.76; h=1; onWorldClick="call CWR_WorldClick"; onCameraInput="call CWR_CameraInput"; selectionPosition="call CWR_SelectionPosition"; };
    class Steel: CWR_Text { x=0.76; y=0; w=0.24; h=1; colorBackground[]={0.40,0.44,0.47,1}; };
    class Panel: CWR_Text { x=0.775; y=0.02; w=0.215; h=0.96; colorBackground[]={0.055,0.075,0.10,1}; };
    class Edge: CWR_Text { x=0.76; y=0; w=0.003; h=1; colorBackground[]={0.03,0.10,0.18,1}; };
    class BlueTop: CWR_Text { x=0.775; y=0.02; w=0.215; h=0.045; colorBackground[]={0.02,0.24,0.55,1}; };
    class Header: CWR_Text { x=0.788; y=0.022; w=0.19; h=0.04; sizeEx=0.029; text="CONFLICT & WAR"; colorText[]={0.72,0.88,1,1}; };
    class MapFrame: CWR_Text { x=0.78; y=0.075; w=0.205; h=0.188; colorBackground[]={0.65,0.71,0.74,1}; };
    class Map: RscMapControl { type=100; idc=7304; x=0.784; y=0.08; w=0.197; h=0.178; scaleMin=0.05; scaleMax=0.5; scaleDefault=0.5; };
    class Theatre: CWR_Text { x=0.784; y=0.265; w=0.09; h=0.03; text="EVERON"; sizeEx=0.021; };
    class Credits: CWR_Text { idc=7302; x=0.87; y=0.26; w=0.11; h=0.04; text="$ 3000"; sizeEx=0.026; colorText[]={0.95,0.80,0.36,1}; };
    class TabBuild: CWR_Button { idc=7320; x=0.782; y=0.305; w=0.096; h=0.045; text="BUILD"; sizeEx=0.023; action="call CWR_TabBuild"; };
    class TabInfantry: CWR_Button { idc=7321; x=0.885; y=0.305; w=0.096; h=0.045; text="INFANTRY"; sizeEx=0.023; action="call CWR_TabInfantry"; };
    class Production: CWR_Text { idc=7305; x=0.785; y=0.353; w=0.19; h=0.03; sizeEx=0.019; text="PRODUCTION 0 / 5"; colorText[]={0.38,0.73,1,1}; };
    class BuildArt: CWR_BarracksArt { type=0; style=48; idc=7340; };
    class Build: CWR_Card { type=11; style=2; text=""; idc=7310; action="call CWR_Build"; };
    class TrainArt: CWR_InfantryArt { type=0; style=48; idc=7341; };
    class Train: CWR_Card { type=11; style=2; text=""; idc=7311; action="call CWR_Train"; };
    class BuildLabel: CWR_Text { idc=7330; x=0.782; y=0.49; w=0.096; h=0.04; style=2; sizeEx=0.018; text="BARRACKS / 1000"; colorBackground[]={0,0,0,0.8}; };
    class TrainLabel: CWR_Text { idc=7331; x=0.782; y=0.49; w=0.096; h=0.04; style=2; sizeEx=0.018; text="RIFLEMAN / 100"; colorBackground[]={0,0,0,0.8}; };
    class Other: CWR_Slot { x=0.885; y=0.39; text="HQ\nONLINE"; colorText[]={0.42,0.58,0.69,1}; style=18; };
    class Slot1: CWR_Slot {};
    class Slot2: CWR_Slot { x=0.885; };
    class Slot3: CWR_Slot { y=0.69; };
    class Slot4: CWR_Slot { x=0.885; y=0.69; };
    class Slot5: CWR_Slot { y=0.83; h=0.05; };
    class Slot6: CWR_Slot { x=0.885; y=0.83; h=0.05; };
    class Slot7: CWR_Slot { x=0.765; y=0.39; w=0.007; h=0.49; colorBackground[]={0.1,0.35,0.55,1}; };
    class Slot8: CWR_Slot { x=0.765; y=0.7; w=0.007; h=0.18; colorBackground[]={0.13,0.65,0.85,1}; };
    class Status: CWR_Text { idc=7303; x=0.02; y=0.87; w=0.70; h=0.10; style=16; sizeEx=0.023; text="HQ online"; colorBackground[]={0.02,0.03,0.04,0.8}; };
    class Home: CWR_Button { idc=7315; x=0.782; y=0.9; w=0.096; h=0.04; text="HQ"; action="call CWR_Home"; };
    class Exit: CWR_Button { idc=7316; x=0.885; y=0.9; w=0.096; h=0.04; text="MENU"; action="call CWR_Stop"; };
    class Help: CWR_Text { x=0.02; y=0.02; w=0.70; h=0.04; sizeEx=0.020; text="EVERON / WASD PAN / WHEEL ZOOM / CLICK UNIT, THEN GROUND TO MOVE"; colorText[]={0.8,0.9,1,1}; colorBackground[]={0.02,0.03,0.04,0.7}; };
};

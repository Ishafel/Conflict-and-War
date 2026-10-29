// FR-029..032: native C&W presentation, stable IDs and mission-owned commands.
class RscMapControl {};
class CWR_Text
{
    type=0; idc=-1; style=0; lineSpacing=1; x=0; y=0; w=1; h=0.05;
    text=""; font="cwrBody24"; sizeEx=0.022;
    colorText[]={0.86,0.87,0.83,1}; colorBackground[]={0,0,0,0};
};
class CWR_Title: CWR_Text { font="cwrTitle48"; colorText[]={0.94,0.93,0.87,1}; };
class CWR_Label: CWR_Text { font="cwrBody24"; sizeEx=0.019; colorText[]={0.66,0.72,0.70,1}; };
class CWR_Background: CWR_Text { style=48; x=0; y=0; w=1; h=1; text=""; colorText[]={1,1,1,1}; };
class CWR_Button: CWR_Text
{
    type=1; style=2; flatStyle=1; w=0.23; h=0.06;
    colorText[]={0.88,0.88,0.82,1}; colorDisabled[]={0.38,0.42,0.40,1};
    colorBackground[]={0.105,0.13,0.13,1}; colorBackgroundActive[]={0.23,0.25,0.21,1};
    colorFocused[]={0.23,0.25,0.21,1}; colorShadow[]={0,0,0,0}; colorBorder[]={0.26,0.30,0.28,1};
    offsetX=0; offsetY=0; offsetPressedX=0; offsetPressedY=0.0015; borderSize=0.001;
    soundEnter[]={"",0,1}; soundPush[]={"",0,1}; soundClick[]={"",0,1}; soundEscape[]={"",0,1};
};
class CWR_Main
{
    idd=0; movingEnable=0;
    controlsBackground[]={"Background","Shade","ShadeEdge","Rule","PrimaryRule"};
    controls[]={"Title","Eyebrow","Subtitle","Operation","Slice","Missions","Mods","Options","Quit","Notice","Version"};
    class Background: CWR_Background {};
    class Shade: CWR_Text { x=0; y=0; w=1; h=1; colorBackground[]={0.025,0.04,0.04,0.20}; };
    class ShadeEdge: CWR_Text { x=0.46; y=0; w=0.06; h=1; colorBackground[]={0,0,0,0}; };
    class Rule: CWR_Text { x=0.067; y=0.296; w=0.047; h=0.003; colorBackground[]={0.75,0.61,0.34,1}; };
    class PrimaryRule: CWR_Text { x=0.067; y=0.47; w=0.003; h=0.065; colorBackground[]={0.82,0.67,0.37,1}; };
    class Eyebrow: CWR_Label { x=0.068; y=0.105; w=0.37; text="C&W  /  FIELD COMMAND"; sizeEx=0.020; colorText[]={0.80,0.68,0.43,1}; };
    class Title: CWR_Title { idc=7391; x=0.065; y=0.145; w=0.43; h=0.145; sizeEx=0.13; text="CONFLICT & WAR"; };
    class Subtitle: CWR_Text { idc=7393; x=0.068; y=0.33; w=0.37; text="A foothold becomes a frontline."; sizeEx=0.028; };
    class Operation: CWR_Label { x=0.068; y=0.385; w=0.35; h=0.06; style=528; sizeEx=0.018; text="EVERON ISLAND / 1985\nEstablish your forward operating base."; };
    class Slice: CWR_Button { idc=7390; x=0.072; y=0.47; w=0.30; h=0.065; text="DEPLOY TO EVERON"; sizeEx=0.027; colorText[]={0.96,0.88,0.68,1}; colorBackground[]={0.24,0.22,0.15,0.94}; colorBackgroundActive[]={0.36,0.31,0.20,1}; colorFocused[]={0.36,0.31,0.20,1}; };
    class Missions: CWR_Button { idc=117; x=0.072; y=0.555; w=0.30; h=0.05; text="MISSIONS"; };
    class Mods: CWR_Button { idc=119; x=0.072; y=0.617; w=0.30; h=0.05; text="MODIFICATIONS"; };
    class Options: CWR_Button { idc=102; x=0.072; y=0.679; w=0.30; h=0.05; text="SETTINGS"; };
    class Quit: CWR_Button { idc=106; x=0.072; y=0.741; w=0.30; h=0.05; text="EXIT GAME"; };
    class Notice: CWR_Text { idc=7392; x=0.068; y=0.865; w=0.39; h=0.085; style=528; sizeEx=0.017; colorText[]={0.59,0.66,0.64,1}; text="C&W is a modified fork based on Bohemia Interactive source.\nNot an official Bohemia Interactive product."; };
    class Version: CWR_Label { x=0.77; y=0.925; w=0.20; style=1; text="EVERON / COMMAND SANDBOX"; sizeEx=0.017; colorText[]={0.85,0.86,0.78,1}; };
};
class RscTitles
{
    class CWR_Startup
    {
        idd=-1; movingEnable=0; duration=2; fadeIn=0.25; fadeOut=0.35;
        name="Conflict & War"; controls[]={"Background","Shade","Rule","Eyebrow","Title","Notice"};
        class Background: CWR_Background {};
        class Shade: CWR_Text { colorBackground[]={0.02,0.035,0.035,0.48}; h=1; };
        class Rule: CWR_Text { x=0.075; y=0.34; w=0.055; h=0.004; colorBackground[]={0.80,0.66,0.38,1}; };
        class Eyebrow: CWR_Label { x=0.075; y=0.285; w=0.6; text="C&W / FIELD COMMAND"; sizeEx=0.022; };
        class Title: CWR_Title { x=0.071; y=0.38; w=0.82; h=0.14; sizeEx=0.12; text="CONFLICT & WAR"; };
        class Notice: CWR_Text { x=0.075; y=0.56; w=0.63; h=0.12; style=528; sizeEx=0.023; text="Command. Build. Deploy.\nA modified fork based on Bohemia Interactive source."; };
    };
};
class CWR_Card: CWR_Text
{
    type=11; style=2; color[]={1,1,1,1}; colorActive[]={0.98,0.86,0.60,1}; colorFocusBg[]={0.78,0.66,0.40,0.10};
    soundEnter[]={"",0,1}; soundPush[]={"",0,1}; soundClick[]={"",0,1}; soundEscape[]={"",0,1};
    x=0.785; y=0.49; w=0.096; h=0.205;
};
class CWR_BarracksArt: CWR_Text { type=0; style=48; x=0.785; y=0.49; w=0.096; h=0.17; colorText[]={1,1,1,1}; text=""; };
class CWR_InfantryArt: CWR_BarracksArt {};
class CWR_Command
{
    idd=7300; movingEnable=0;
    controlsBackground[]={"Steel","Panel","Edge","HeaderPlate","HeaderRule","MapFrame","EconomyPlate","SectionRule","CardFrame","ContextPlate","BottomRule","WorldTitlePlate","HelpPlate"};
    controls[]={"World","Map","Header","Identity","Theatre","Credits","ResourceLabel","Status","TabBuild","TabInfantry","BuildArt","TrainArt","Build","Train","BuildLabel","TrainLabel","BuildSweep","TrainSweep","Production","Home","Exit","Help","WorldTitle","WorldSubtitle","BuildActive","TrainActive","DetailTitle","DetailBody","ContextTitle","TrainLock"};
    class World: CWR_Text { type=102; idc=7301; x=0; y=0; w=0.76; h=1; onWorldClick="call CWR_WorldClick"; onCameraInput="call CWR_CameraInput"; cameraResetToken="CWR_RTS select 19"; selectionPosition="call CWR_SelectionPosition"; selectableUnits="call CWR_SelectableUnits"; onBoxSelect="_units call CWR_SetSelection"; placementActive="(CWR_RTS select 7)==1"; placementClass="Barracks"; placementValid="call CWR_PreviewSite"; onPreviewHidden="CWR_RTS set [17,[]]"; };
    class Steel: CWR_Text { x=0.76; y=0; w=0.24; h=1; colorBackground[]={0.18,0.21,0.20,1}; };
    class Panel: CWR_Text { x=0.764; y=0; w=0.236; h=1; colorBackground[]={0.045,0.065,0.065,1}; };
    class Edge: CWR_Text { x=0.76; y=0; w=0.002; h=1; colorBackground[]={0.52,0.46,0.31,1}; };
    class HeaderPlate: CWR_Text { x=0.764; y=0; w=0.236; h=0.095; colorBackground[]={0.09,0.115,0.11,1}; };
    class HeaderRule: CWR_Text { x=0.785; y=0.087; w=0.19; h=0.0015; colorBackground[]={0.34,0.36,0.29,1}; };
    class Header: CWR_Text { x=0.784; y=0.018; w=0.20; h=0.045; sizeEx=0.026; text="CONFLICT & WAR"; };
    class Identity: CWR_Label { x=0.785; y=0.062; w=0.20; h=0.025; sizeEx=0.0165; text="FIELD COMMAND  /  01"; colorText[]={0.72,0.64,0.44,1}; };
    class MapFrame: CWR_Text { x=0.783; y=0.112; w=0.194; h=0.182; colorBackground[]={0.29,0.33,0.29,1}; };
    class Map: RscMapControl { type=100; idc=7304; x=0.785; y=0.115; w=0.19; h=0.176; scaleMin=0.05; scaleMax=0.5; scaleDefault=0.5; };
    class Theatre: CWR_Label { x=0.785; y=0.298; w=0.19; h=0.025; text="EVERON  /  OPERATIONS MAP"; sizeEx=0.0165; };
    class EconomyPlate: CWR_Text { x=0.785; y=0.336; w=0.19; h=0.055; colorBackground[]={0.105,0.13,0.115,1}; };
    class ResourceLabel: CWR_Label { x=0.793; y=0.349; w=0.085; h=0.025; text="RESERVES"; sizeEx=0.017; };
    class Credits: CWR_Label { font="cwrMono24"; idc=7302; x=0.867; y=0.343; w=0.10; h=0.04; style=1; text="3000"; sizeEx=0.032; colorText[]={0.93,0.79,0.49,1}; };
    class TabBuild: CWR_Button { idc=7320; x=0.785; y=0.413; w=0.091; h=0.043; text="STRUCTURES"; sizeEx=0.018; action="call CWR_TabBuild"; };
    class TabInfantry: CWR_Button { idc=7321; x=0.884; y=0.413; w=0.091; h=0.043; text="INFANTRY"; sizeEx=0.018; action="call CWR_TabInfantry"; };
    class BuildActive: CWR_Text { idc=7360; x=0.785; y=0.458; w=0.091; h=0.003; colorBackground[]={0.83,0.68,0.39,1}; };
    class TrainActive: CWR_Text { idc=7361; x=0.884; y=0.458; w=0.091; h=0.003; colorBackground[]={0.83,0.68,0.39,1}; };
    class SectionRule: CWR_Text { x=0.785; y=0.715; w=0.19; h=0.0015; colorBackground[]={0.24,0.28,0.25,1}; };
    class CardFrame: CWR_Text { x=0.783; y=0.487; w=0.100; h=0.211; colorBackground[]={0.35,0.34,0.26,1}; };
    class BuildArt: CWR_BarracksArt { idc=7340; };
    class Build: CWR_Card { text=""; idc=7310; action="call CWR_Build"; };
    class TrainArt: CWR_InfantryArt { idc=7341; };
    class Train: CWR_Card { text=""; idc=7311; action="call CWR_Train"; };
    class BuildLabel: CWR_Text { idc=7330; x=0.785; y=0.66; w=0.096; h=0.035; style=2; sizeEx=0.0165; text="BARRACKS / 1000"; colorText[]={0.92,0.85,0.68,1}; colorBackground[]={0.075,0.095,0.09,1}; };
    class TrainLabel: BuildLabel { idc=7331; text="RIFLEMAN / 100"; };
    class BuildSweep: CWR_Text { type=103; idc=7350; x=0.785; y=0.49; w=0.096; h=0.17; productionState="call CWR_BuildCardState"; sizeEx=0.021; };
    class TrainSweep: BuildSweep { idc=7351; productionState="call CWR_TrainCardState"; };
    class DetailTitle: CWR_Text { idc=7362; x=0.894; y=0.49; w=0.084; h=0.055; style=528; text="BARRACKS"; sizeEx=0.022; };
    class DetailBody: CWR_Text { idc=7363; x=0.894; y=0.554; w=0.084; h=0.15; style=528; sizeEx=0.019; colorText[]={0.65,0.72,0.68,1}; text="1000 credits\n15 sec\n\nInfantry facility"; };
    class Production: CWR_Label { idc=7305; x=0.785; y=0.731; w=0.19; h=0.03; sizeEx=0.018; text="FORCES 0  /  QUEUE 0"; };
    class TrainLock: CWR_Text { idc=7366; x=0.785; y=0.49; w=0.096; h=0.17; style=528; sizeEx=0.018; text="REQUIRES\nBARRACKS"; colorText[]={0.78,0.77,0.67,1}; colorBackground[]={0.025,0.04,0.035,0.75}; };
    class ContextPlate: CWR_Text { x=0.785; y=0.775; w=0.19; h=0.105; colorBackground[]={0.075,0.10,0.095,1}; };
    class ContextTitle: CWR_Label { idc=7364; x=0.793; y=0.783; w=0.174; h=0.025; text="COMMAND STATUS"; sizeEx=0.0165; colorText[]={0.77,0.69,0.49,1}; };
    class Status: CWR_Text { idc=7303; x=0.793; y=0.813; w=0.174; h=0.063; style=528; sizeEx=0.019; text="Order barracks to establish your base."; };
    class BottomRule: CWR_Text { x=0.785; y=0.901; w=0.19; h=0.0015; colorBackground[]={0.24,0.28,0.25,1}; };
    class Home: CWR_Button { idc=7315; x=0.785; y=0.923; w=0.091; h=0.042; text="CENTER HQ"; sizeEx=0.017; action="call CWR_Home"; };
    class Exit: CWR_Button { idc=7316; x=0.884; y=0.923; w=0.091; h=0.042; text="MENU"; sizeEx=0.017; action="call CWR_Stop"; };
    class WorldTitlePlate: CWR_Text { x=0.02; y=0.025; w=0.24; h=0.079; colorBackground[]={0.025,0.045,0.04,0.73}; };
    class WorldTitle: CWR_Text { x=0.031; y=0.03; w=0.20; h=0.042; text="EVERON"; sizeEx=0.032; };
    class WorldSubtitle: CWR_Label { x=0.032; y=0.075; w=0.20; h=0.024; text="FORWARD OPERATING BASE"; sizeEx=0.0165; colorText[]={0.76,0.70,0.53,1}; };
    class HelpPlate: CWR_Text { x=0.02; y=0.934; w=0.56; h=0.040; colorBackground[]={0.025,0.045,0.04,0.73}; };
    class Help: CWR_Text { idc=7365; x=0.03; y=0.943; w=0.54; h=0.027; sizeEx=0.018; colorText[]={0.72,0.78,0.73,1}; text="Select / drag     Move / ground click     Pan / WASD     Zoom / wheel"; };
};

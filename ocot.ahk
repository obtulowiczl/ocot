#NoEnv
#InstallKeybdHook
#InstallMouseHook
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetTitleMatchMode, 2
#MaxThreadsPerHotkey 00
#SingleInstance Force
CoordMode, Mouse, Client
Coordmode, pixel, Client
Thread, interrupt, 0
FileEncoding, UTF-8
#Persistent
global CarModel =
global CarPlate =
global dataOC =
global dataBT =
global setDniOC =
global settingsOC =
global settingsBT =
global setDniBT =
SetTimer, _TrayInfo, 28800000
IfExist, ocot.ini
{
	IniRead, setDniOC, ocot.ini, config, setDniOC, 45
	IniRead, setDniBT, ocot.ini, config, setDniBT, 7
}
else
{
	setDniOC = 45
	setDniBT = 7
IniWrite, 45, ocot.ini, config, setDniOC
IniWrite, 7, ocot.ini, config, setDniBT
}
Menu, Tray, NoStandard
Menu, Tray, Add, Pokaż OCOT, restore
Menu, Tray, Default, Pokaż OCOT
Menu, Tray, Click, 1
Menu, Tray, Tip, Przypominacz OCOT - OC/Przeglądy pojazdów

Gui, Main: New, , Przypominacz OCOT
Gui, Add, StatusBar,,
Gui, Font, s10
Gui, Add, ListView, w580 h380 vReminderListView g_ReminderList, Samochód|Rejestracja|OC wazne do:|BT ważne do:
LV_ModifyCol(1, "+center 265")
LV_ModifyCol(2, "+center 90")
LV_ModifyCol(3, "+center 110")
LV_ModifyCol(4, "+center 110")
Gui, Font, Normal
Gui, Add, Button, h25 w140 x5 y400 vButtonDelete g_DeleteRow, Usuń wybrany pojazd
Gui, Add, Button, h25 w140 x+7 yp vButtonAdd g_AddCar, Dodaj nowy pojazd
Gui, Font, Bold s10
Gui, Add, Button, h25 w225 x+7 yp vButtonUpcoming g_GetUpcoming, Pokaż nadchodzące terminy
Gui, Font, Normal s7
Gui, Add, Button, h25 w60 x+10 yp vButtonOptions g_Settings , Ustawienia
SB_SetParts(300,300)
getList()
Gui, Main: Show, w600 h460, Przypominacz OCOT

_TrayInfo()
return


_TrayInfo() {
	global
if (incoming3 <= SetDniOC) OR (incoming4 <= SetDniBT)
{
	TrayTip,UWAGA!,Wkrótce trzeba przedłużyć OC/BT. `nSzczegóły w komunikacie., 5, 2
	_GetUpcoming()
}
}

_AddCar() {
Gui, Dodaj: New, ,Dodawanie nowego pojazdu
Gui, Add, Text, x10 yp+10, Samochód:
Gui, Font, Bold
Gui, Add, Edit, +center x+100 yp-5 w250 h20 vCarModel,
Gui, Font, Normal
Gui, Add, Text, x10 yp+36, Numer rejestracyjny:
Gui, Font, Bold
Gui, Add, Edit, +center yp-5  x+60 w250 h20 vCarPlate,
Gui, Font, Normal
Gui, Add, Text, x10 yp+40, Polisa OC ważna do:
Gui, Font, Bold
Gui, Add, DateTime, x+58 yp-5 w280 vdataOC ChooseNone , dddd dd/MM/yyyy 'roku'
Gui, Add, Button, x10 yp+30 w435 g_CopyDateOCtoBT, Koniec BT wtedy co koniec OC.
Gui, Font, Normal
Gui, Add, Text, x10 yp+35, Badanie techniczne ważne do:
Gui, Font, Bold
Gui, Add, DateTime, x+10 yp-5 w280 vdataBT ChooseNone , dddd dd/MM/yyyy 'roku'
Gui, Add, Button, h25 w350 x10 yp+35 g_AddCarSave +Default, Zapisz
Gui, Add, Button, h25 w80  x+5 yp g_AnulujCarAdd, Anuluj
Gui, Dodaj: Show, w450 h200
}

_CopyDateOCtoBT() {
global
GuiControlGet, dataOCtoBT,, dataOC
GuiControl,,dataBT,%dataOCtoBT%
}

_AnulujCarAdd() {
Gui, Dodaj: Destroy
Gui, Main: Default
}

_Settings() {
	global
Gui, OCOTSetting: Destroy
Gui, OCOTSetting: Font, s10
Gui, OCOTSetting: Add, Text, x10 y10 ,Informuj o kończących się OC:
Gui, OCOTSetting: Add, Edit, yp-2 x+5 w35 +center vSettingsOC , %SetDniOC%
Gui, OCOTSetting: Add, Text, yp+2 x+2 , dni wcześniej.

Gui, OCOTSetting: Add, Text, x10 y+20 ,Informuj o kończących się BT:
Gui, OCOTSetting: Add, Edit, yp-2 x+5 w35 +center vSettingsBT , %SetDniBT%
Gui, OCOTSetting: Add, Text, yp+2 x+2 , dni wcześniej.
Gui, OCOTSetting: Add, Button, x10 yp+30 w330 g_SaveSettings Default,ZAPISZ USTAWIENIA
Gui, OCOTSetting: Add, Button, x10 yp+30 w330 g_Exit,ZAKOŃCZ PROGRAM (wyłącza powiadomienia!)
Gui, OCOTSetting: Show, AutoSize
}

_Exit() {
ExitApp
}

_SaveSettings() {
global
GuiControlGet, SetDniOC, ,SettingsOC
GuiControlGet, SetDniBT, ,SettingsBT
IniWrite, %SetDniOC%, ocot.ini, config, SetDniOC
IniWrite, %SetDniBT%, ocot.ini, config, SetDniBT
Gui, Main: Default
Gui, OCOTSetting: Destroy
}

_updateDB() {
global
linia =
FileDelete, ocot.dat
Gui, Main: Default
ilosc := LV_GetCount()
n = 1
Loop %ilosc% {
LV_GetText(OutputCol1, n, 1)
LV_GetText(OutputCol2, n, 2)
LV_GetText(OutputCol3, n, 3)
LV_GetText(OutputCol4, n, 4)
linia =`n%OutputCol1%|%OutputCol2%|%OutputCol3%|%OutputCol4%
FileAppend, %linia%, ocot.dat
n+=1
}
}

_AddCarSave() {
global
Gui, Dodaj: Submit
If dataOC !=
	dataOC := SubStr(dataOC, 1, 4) "/" SubStr(dataOC, 5, 2) "/" SubStr(dataOC, 7, 2)
If dataBT !=
	dataBT := SubStr(dataBT, 1, 4) "/" SubStr(dataBT, 5, 2) "/" SubStr(dataBT, 7, 2)
Gui, Main:Default
LV_Add("Vis +select",CarModel,CarPlate,dataOC,dataBT)
_updateDB()
_sortList()
}

_ModifyCarSave() {
Gui, Main:Default
	numerLinii := LV_GetNext()
Gui, Edytuj: Submit
If dataOC !=
	dataOC := SubStr(dataOC, 1, 4) "/" SubStr(dataOC, 5, 2) "/" SubStr(dataOC, 7, 2)
If dataBT !=
	dataBT := SubStr(dataBT, 1, 4) "/" SubStr(dataBT, 5, 2) "/" SubStr(dataBT, 7, 2)
Gui, Main:Default
LV_Modify(numerLinii, "Vis +select",CarModel,CarPlate,dataOC,dataBT)
_updateDB()
_sortList()
}

_DeleteRow() {
RowNumber := 0  ; This causes the first loop iteration to start the search at the top of the list.
Loop
{
    RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        break
	MsgBox, 292, Potwierdź usunięcie, Czy na pewno chcesz usunąć zaznaczony pojazd?
		IfMsgBox, Yes
			LV_Delete(RowNumber)
}
_updateDB()
_sortList()
}

_ReminderList() {
global
if A_GuiEvent = ColClick
	return

if (A_EventInfo > 0)
{
LV_GetText(CarModelRow, A_EventInfo, 1)
LV_GetText(CarPlateRow, A_EventInfo, 2)
LV_GetText(OCdataRow, A_EventInfo, 3)
OCdataRow := StrReplace(OCdataRow, "/")
LV_GetText(BTdataRow, A_EventInfo, 4)
BTdataRow := StrReplace(BTdataRow, "/")
Gui, Edytuj: New, ,Edytowanie pojazdu
Gui, Add, Text, x10 yp+10, Samochód:
Gui, Font, Bold
Gui, Add, Edit, +center x+100 yp-5 w250 h20 vCarModel, %CarModelRow%
Gui, Font, Normal
Gui, Add, Text, x10 yp+36 , Numer rejestracyjny:
Gui, Font, Bold
Gui, Add, Edit, +center yp-5  x+60 w250 h20 vCarPlate, %CarPlateRow%
Gui, Font, Normal
Gui, Add, Text, x10 yp+40, Polisa OC ważna do:
Gui, Font, Bold
Gui, Add, DateTime, +center x+58 yp-5 w280 vdataOC Choose%OCdataRow% , dddd	dd/MM/yyyy 'roku'
Gui, Add, Button, x10 yp+30 w435 g_CopyDateOCtoBT, Koniec BT wtedy co koniec OC.
Gui, Font, Normal
Gui, Add, Text, x10 yp+35, Badanie techniczne ważne do:
Gui, Font, Bold
Gui, Add, DateTime, x+10 yp-5 w280 vdataBT Choose%BTdataRow% , dddd	dd/MM/yyyy 'roku'
Gui, Add, Button, h25 w350 x10 yp+35 g_ModifyCarSave +Default, Zapisz
Gui, Add, Button, h25 w80  x+5 yp g_ModifyCarCancel, Anuluj
Gui, Edytuj: Show, w450 h200
}

}

_ModifyCarCancel() {
	Gui, Edytuj: Destroy
	Gui, Main: Default
}

getList() {

FileRead, ReminderList, %A_ScriptDir%\ocot.dat
Loop, Parse, ReminderList, `n, `r
	{
		If A_Loopfield !=
		{
		ReminderRow := StrSplit(A_LoopField, "|")
		LV_Add(, ReminderRow[1], ReminderRow[2], ReminderRow[3], ReminderRow[4])
		}
}
_sortList()
}

_SetStatusBar() {

}

_GetUpcoming() {
global
Gui, Upcoming: Destroy
Gui, Upcoming: Font, s10 bold
Gui, Upcoming: Add, Text, , Wygasające polisy OC w najbliżyszym czasie (%SetDniOC% dni):

LV_ModifyCol(3, "Sort")
listOC =
listBT = Badanie techniczne kończy się w:
m := 1
Gui, Upcoming: Font, normal
Loop % LV_GetCount() {
	LV_GetText(ModelRow, m, 1)
	LV_GetText(PlateRow, m, 2)
	LV_GetText(OCdataRowTemp, m, 3)
	OCdataRowTemp := StrReplace(OCdataRowTemp, "/")
	FormatTime, OClongDate, %OCdataRowTemp%, dddd dd MMMM yyyy
	czas := A_YYYY A_MM A_DD
	EnvSub, OCdataRowTemp, %czas%, days
	if (OCdataRowTemp > setDniOC)
	{
		break
	}
Gui, Upcoming: Add, Text, x10 y+5 , %m%. %ModelRow%
Gui, Upcoming: Add, Text, x170 yp , %PlateRow%
Gui, Upcoming: Add, Text, yp x250 , %OClongDate% (%OCdataRowTemp% dni)
;listOC .= "`n" m ". " ModelRow  A_Space  PlateRow  " /" A_Tab OClongDate  A_Space "(" OCdataRowTemp " dni)"
m+=1
	}

Gui, Upcoming: Font, s10 bold
Gui, Upcoming: Add, Text, x10 yp+45, Kończące się badania techniczne (najbliższe %SetDniBT% dni):
Gui, Upcoming: Font, s10 normal

LV_ModifyCol(4, "Sort")
m := 1
Loop % LV_GetCount() {
	LV_GetText(ModelRow, m, 1)
	LV_GetText(PlateRow, m, 2)
	LV_GetText(BTdataRowTemp, m, 4)
	BTdataRowTemp := StrReplace(BTdataRowTemp, "/")
	FormatTime, BTlongDate, %BTdataRowTemp%, dddd dd MMMM yyyy
	czas := A_YYYY A_MM A_DD
	EnvSub, BTdataRowTemp, %czas%, days
	if (BTdataRowTemp > setDniBT)
	{
		break
	}
	Gui, Upcoming: Add, Text, x10 y+5 , %m%. %ModelRow%
	Gui, Upcoming: Add, Text, x170 yp , %PlateRow%
	Gui, Upcoming: Add, Text, yp x250 , %BTlongDate% (%BTdataRowTemp% dni)
	m+=1
	}
Gui, Upcoming: -MinimizeBox
Gui, Upcoming: Show, AutoSize, Wygasające polisy / kończące się badania:
_sortList()
}



_sortList() {
	global
	czas := A_YYYY A_MM A_DD

	LV_ModifyCol(3, "Sort")
		SB_SetText("Brak wprowadzonych samochodów.", 1)
		SB_SetText("Dodaj pojazdy do bazy aby program działał prawidłowo.", 2)
if (LV_GetCount() > 0)
{
	LV_GetText(OCSort, 1, 3)
	LV_GetText(incomingOC1, 1, 1)
	LV_GetText(incomingOC2, 1, 2)
	LV_GetText(incomingOC3, 1, 3)
	incoming3 := StrReplace(incomingOC3, "/")
	EnvSub, incoming3, %czas%, days
		SB_SetText("Najbliższa płatność OC za " incoming3 " dni ("incomingOC1 A_Space incomingOC2 ")", 1)
}

	LV_ModifyCol(4, "Sort")
if (LV_GetCount() > 0)
{
	LV_GetText(incomingBT1, 1, 1)
	LV_GetText(incomingBT2, 1, 2)
	LV_GetText(incomingBT3, 1, 4)
	LV_GetText(BTSort, 1, 4)
	incoming4 := StrReplace(incomingBT3, "/")
	EnvSub, incoming4, %czas%, days
	SB_SetText("Najbliższe BT za " incoming4 " dni ("incomingBT1 A_Space incomingBT2 ")", 2)
}

If (OCSort < BTSort)
	LV_ModifyCol(3, "Sort")
else
	LV_ModifyCol(4, "Sort")

}
OCOTSettingGuiClose:
OCOTSettingGuiEscape:
	Gui, OCOTSetting: Destroy
return
EdytujGuiClose:
EdytujGuiEscape:
	Gui, Edytuj: Destroy
return
UpcomingGuiClose:
UpcomingGuiEscape:
	Gui, Upcoming: Destroy
return

DodajGuiClose:
DodajGuiEscape:
	Gui, Dodaj: Destroy
return

MainGuiClose:
MainGuiEscape:
 Gui, Main: hide
return

MainGuiSize:
  if A_EventInfo = 1
    Gui, Main: hide
  return

restore:
	gui, Main: show
return

OnExit(_updateDB())
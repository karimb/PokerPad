/*  PokerPad v0.1.24 by Xander
 *  
 *	This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */
 
; ( [] )..( [] )   Auto-Execute   ( [] )..( [] ) 

#NoEnv
#SingleInstance Force
#Include Includes\Functions.ahk
Critical, On
OnMessage(0x5555, "HandleMessage")
SendMode Play
CheckIniVersion()
SetTitleMatchMode, RegEx
IniRead, UseMouse, PokerPad.ini, General, UseMouse, 0
IniRead, Rounding, PokerPad.ini, General, Rounding, -1
IniRead, Increment, PokerPad.ini, General, Increment, -1
IniRead, Increment2, PokerPad.ini, General, Increment2, -3
SetHotkeys()
Menu, Tray, DeleteAll
Menu, Tray, NoStandard
Menu, Tray, Add, &Settings..., Settings
Menu, Tray, Default, &Settings...
if FullTilt_GameWindow
	Menu, Open, Add, Full Tilt Poker, FullTilt
if PokerStars_GameWindow
	Menu, Open, Add, Poker Stars, PokerStars
if IPoker_GameWindow
	Menu, Open, Add, iPoker, IPoker
if PartyPoker_GameWindow
	Menu, Open, Add, Party Poker, PartyPoker
if EverestPoker_GameWindow
	Menu, Open, Add, Everest Poker, EverestPoker
if Ongame_GameWindow
	Menu, Open, Add, Ongame, Ongame
if CakePoker_GameWindow
	Menu, Open, Add, Cake Poker, CakePoker
if Microgaming_GameWindow
	Menu, Open, Add, Microgaming, Microgaming
if Pacific_GameWindow
	Menu, Open, Add, Pacific, Pacific
Menu, Tray, Add, &Open, :Open
Menu, Tray, Add
Menu, Tray, Add, &Pause/Unpause, PauseScript
Menu, Tray, Add, &Suspend Hotkeys, SuspendHotkeys
Menu, Tray, Add, View &License, ViewLicense
Menu, Tray, Add
Menu, Tray, Add, E&xit, Exit
Critical, Off
AutoLoad()
;ListVars
return ; End Auto-Execute



;#Include Debug.ahk ; contains println(), see http://www.autohotkey.com/forum/topic23678.html
;^q:: Reload
;^p::Pause



HandleMessage(action, pid) {
	global
	GoSub, HandleMessage%action%
	return
	HandleMessage0:
		ListRemoveAll(OnFold, pid)
		ListRemoveAll(OnCall, pid)
		ListRemoveAll(OnRaise, pid)
		return
	HandleMessage1:
		ListAdd(OnFold, pid)
		return
	HandleMessage2:
		ListAdd(OnCall, pid)
		return
	HandleMessage3:
		ListAdd(OnRaise, pid)
		return
}



; ( [] )..( [] )  Generic Functions   ( [] )..( [] ) 


#Include Includes\TableLayout.ahk
#Include Includes\List.ahk
#Include Includes\Gui.ahk

PauseScript:
	Pause
	return
SuspendHotkeys:
	Suspend
	Menu, Tray, % A_IsSuspended ? "Check" : "Uncheck", &Suspend Hotkeys
	return
Settings:
	Settings()
	return
ViewLicense:
	Run, license.txt
	return
Exit:
	AutoClose()
	ExitApp

OpenClient(name) {
	IniRead, path, PokerPad.ini, %name%, Path, %A_Space%
	if path {
		if (SubStr(path, 1, 1) == "\") {
			path := A_ProgramFiles . path
		}
		StringGetPos, i, path, \, R
		dir := SubStr(path, 1, i)
		Run, % path, % dir
	}
}
FullTilt:
PokerStars:
IPoker:
PartyPoker:
EverestPoker:
Ongame:
CakePoker:
Microgaming:
Pacific:
	OpenClient(A_ThisLabel)
	return
	
AutoLoad() {
	IniRead, load, PokerPad.ini, General, AutoLoad, %A_Space%
	if load
		Load(load)
}

AutoClose() {
	IniRead, load, PokerPad.ini, General, AutoLoad, %A_Space%
	if load
		Unload(load)
}

#Include Includes\Tile.ahk

Tile:
	if !Tile_Monitors {
		IniRead, Tile_Monitors, PokerPad.ini, Tile, Monitors, 1
		IniRead, Tile_Tables, PokerPad.ini, Tile, Tables, 36
	}
	Tile("ahk_group GameWindows", Tile_Monitors, Tile_Tables)
	return

#Include Includes\NextWindow.ahk

NextWindow_Right:
	NextWindow_Right("ahk_group GameWindows")
	return
NextWindow_Left:
	NextWindow_Left("ahk_group GameWindows")
	return
NextWindow_Up:
	NextWindow_Up("ahk_group GameWindows")
	return
NextWindow_Down:
	NextWindow_Down("ahk_group GameWindows")
	return

#Include Includes\Display.ahk

SetFactor(var) {
	local factor
	IniRead, factor, PokerPad.ini, Bets, %var%, %A_Space%
	if factor {
		local i := InStr(factor, "/")
		if i {
			local num := SubStr(factor, 1, i-1)
			local den := SubStr(factor, i+1)
			%var% := num / den
			return true
		} else
			%var% := factor
	}
	return false
}

SetHotkey(label, modifier = "", modifierLabel = "") {
	IniRead, hotkey, PokerPad.ini, Hotkeys, %label%, %A_Space%
	Loop, Parse, hotkey, |, %A_Space%
	{
		Hotkey, %A_LoopField%, %label%
		if (modifier && !InStr(A_LoopField, modifier)) {
			hotkey := modifier . A_LoopField
			Hotkey, %hotkey%, % modifierLabel ? modifierLabel : label
		}
	}
}

SetHotkeys() {
	local load
	IniRead, load, PokerPad.ini, General, FullTilt, 1
	if load
		FullTilt()
	IniRead, load, PokerPad.ini, General, PokerStars, 1
	if load
		PokerStars()
	IniRead, load, PokerPad.ini, General, IPoker, 1
	if load
		IPoker()
	IniRead, load, PokerPad.ini, General, PartyPoker, 1
	if load
		PartyPoker()
	IniRead, load, PokerPad.ini, General, EverestPoker, 1
	if load
		EverestPoker()
	IniRead, load, PokerPad.ini, General, Ongame, 1
	if load
		Ongame()
	IniRead, load, PokerPad.ini, General, CakePoker, 1
	if load
		CakePoker()
	IniRead, load, PokerPad.ini, General, Microgaming, 1
	if load
		Microgaming()
	IniRead, load, PokerPad.ini, General, Pacific, 1
	if load
		Pacific()
		
	Hotkey, IfWinActive, ahk_group GameWindows
	local hotkey, names
	IniRead, hotkey, PokerPad.ini, Hotkeys, TypeBet, 0
	if hotkey {
		Hotkey, Numpad0, NumpadDigit
		Hotkey, Numpad1, NumpadDigit
		Hotkey, Numpad2, NumpadDigit
		Hotkey, Numpad3, NumpadDigit
		Hotkey, Numpad4, NumpadDigit
		Hotkey, Numpad5, NumpadDigit
		Hotkey, Numpad6, NumpadDigit
		Hotkey, Numpad7, NumpadDigit
		Hotkey, Numpad8, NumpadDigit
		Hotkey, Numpad9, NumpadDigit
	}
	RandomMin = 0.25
	RandomMax = 1
	SetFactor("RandomMin")
	SetFactor("RandomMax")
	Relative1 = 0.25
	Relative2 = 0.333
	Relative3 = 0.5
	Relative4 = 0.667
	Relative5 = 0.75
	Relative6 = 0.9
	Relative7 = 1
	Relative8 = 1.5
	Relative9 = 2
	Fixed1 = 2
	Fixed2 = 3
	Fixed3 = 4
	Fixed4 = 5
	Fixed5 = 6
	Fixed6 = 7
	Fixed7 = 8
	Fixed8 = 9
	Fixed9 = 10
	local i, map0 := "Ins", map1 := "End", map2 := "Down", map3 := "PgDn", map4 := "Left", map5 := "Clear", map6 := "Right", map7 := "Home", map8 := "Up", map9 := "PgUp"
	local match, match0, match1, match2
	Loop, 9 {
		SetHotkey("Relative" . A_Index)
		SetFactor("Relative" . A_Index)
		local label := "Fixed" . A_Index
		IniRead, hotkey, PokerPad.ini, Hotkeys, Fixed%A_Index%, %A_Space%
		Loop, Parse, hotkey, |, %A_Space%
		{
			Hotkey, %A_LoopField%, %label%
			if RegExMatch(A_LoopField, "^([\^\!\+\#]+Numpad)(\d)$", match) {
				hotkey := match1 . map%match2%
				Hotkey, %hotkey%, %label%
			}
		}
		SetFactor("Fixed" . A_Index)
	}
	Loop, 3 {
		SetFactor("Preflop" . A_Index)
		SetFactor("Flop" . A_Index)
		SetFactor("Turn" . A_Index)
		SetFactor("River" . A_Index)
	}
	names := "LastHand,ToggleAutoMuck,ClearBetBox,FoldAny,AutoPost,SitOut,RandomBet,AllIn,IncreaseBet,DecreaseBet,"
	names .= "NextWindow_Left,NextWindow_Right,NextWindow_Up,NextWindow_Down,IncreaseBet2,DecreaseBet2,Street1,Street2,Street3"
	Loop, Parse, names, `,
		SetHotkey(A_LoopField)
	names = Fold,Call,Raise,FastFold
	Loop, Parse, names, `,
		SetHotkey(A_LoopField, "^")
	SetHotkey("Lobby", "+")
	SetHotkey("Reload", "^")
	SetHotkey("AllInThisHand", "+", "CancelAllInQueue")
	Hotkey, IfWinActive
	names = SitInAll,SitOutAll,LeaveAll,Tile,AutoPostOnAll,AutoPostOffAll,SuspendHotkeys,Debug
	Loop, Parse, names, `,
		SetHotkey(A_LoopField)
	SetHotkey("ActivateTable", "^", "ToggleActivateTable")
}

SetClientHotkey(name, hotkey, label) {
	local window := %name%
	if window {
		Hotkey, IfWinActive, %window%
		IniRead, hotkey, PokerPad.ini, Hotkeys, %hotkey%, %A_Space%
		Loop, Parse, hotkey, |, %A_Space%
			Hotkey, %A_LoopField%, %label%
	}
}

SetClientHotkeys(client) {
	SetClientHotkey(client . "_LastHandWindow", "LastHand", "CloseWindow")
	SetClientHotkey(client . "_TournamentLobbyWindow", "Lobby", "CloseWindow")
	SetClientHotkey(client . "_LobbyWindow", "Lobby", client . "_Activate")
	Hotkey, IfWinActive
}

CloseWindow:
	Send, !{F4}
	return

Notify(action, id) {
	local listeners := On%action%
	static Fold := 1, Call := 2, Raise := 3
	if listeners {
		DetectHiddenWindows, On
		local a := %action%
		Loop, Parse, listeners, `,
			SendMessage, 0x5555, a, id, , ahk_pid %A_LoopField%
		DetectHiddenWindows, Off
	}
}

InvokeHotkey(action) {
	local id, title
	if UseMouse {
		MouseGetPos, , , id
	} else {
		WinGet, id, ID
		if WinExist("blue_bar ahk_class AutoHotkeyGUI") {
			SendMessage, 0x5555
			id := ErrorLevel
		}
	}
	WinGet, aid, ID, A
	if !(aid == id) {
		WinActivate, ahk_id %id%
		WinWaitActive, ahk_id %id%, , 1
		if ErrorLevel
			return
	} else
		IfWinNotExist, ahk_id %id%
			return
	Notify(action, id)
	local class
	WinGetClass, class
	StringReplace, class, class, .
	local s := Site%class%
	; PartyPoker and Pacific have the same ahk class so we use a dirty hack :(
	if (class == "#32770") {
		WinGetTitle title, ` -`  ahk_id %id%
		if !title
			s := "Pacific"
	}
	local label := s . "_" . action
	if IsLabel(label)
		GoSub, %label%
}
Fold:
Call:
Raise:
FastFold:
NumpadDigit:
ClearBetBox:
Relative1:
Relative2:
Relative3:
Relative4:
Relative5:
Relative6:
Relative7:
Relative8:
Relative9:
Fixed1:
Fixed2:
Fixed3:
Fixed4:
Fixed5:
Fixed6:
Fixed7:
Fixed8:
Fixed9:
Street1:
Street2:
Street3:
RandomBet:
AllIn:
LastHand:
IncreaseBet:
DecreaseBet:
IncreaseBet2:
DecreaseBet2:
FoldAny:
AutoPost:
ToggleAutoMuck:
Reload:
AllInThisHand:
Lobby:
SitOut:
	Critical, On
	InvokeHotkey(A_ThisLabel)
	return

	
	
AddCurrentIDToQueue(queue, interval = 1000) {
	local id
	Critical, On ; this must be synchronized
	WinGet, id, ID
	local list := %queue%
	if list {
		if id not int %list%
			%queue% .= "," . id
	} else {
		%queue% := id
		SetTimer, %queue%, %interval%
	}
	Critical, Off
}
	

ActivateTable() {
	local window
	WinActivate, ahk_group GameWindows
	WinGetClass, window, A
	window := "OnActivate_" . window
	if IsLabel(window)
		GoSub, %window%
}	
	
ActivateTable:
	ActivateTable()
	return

ToggleActivateTable:
	Hotkey, IfWinActive
	Hotkey, NumpadAdd, Toggle
	return

CancelAllInQueue:
	FullTilt_AllInQueue := PokerStars_AllInQueue := PartyPoker_AllInQueue := Ongame_AllInQueue := ""
	return
	
SitInAll:
	SitInAll(true)
	return
SitOutAll:
	SitInAll(false)
	return
AutoPostOnAll:
	AutoPostAll(true)
	return
AutoPostOffAll:
	AutoPostAll(false)
	return
	
AutoPostAll(on) {
	global
	if FullTilt_GameWindow
		FullTilt_AutoPostAll(on)
	if PokerStars_GameWindow
		PokerStars_AutoPostAll(on)
	if IPoker_GameWindow
		IPoker_AutoPostAll(on)
	if PartyPoker_GameWindow
		PartyPoker_AutoPostAll(on)
	if EverestPoker_GameWindow
		EverestPoker_AutoPostAll(on)
	if Ongame_GameWindow
		Ongame_AutoPostAll(on)
	if CakePoker_GameWindow
		CakePoker_AutoPostAll(on)
	if Microgaming_GameWindow
		Microgaming_AutoPostAll(on)
	if Pacific_GameWindow
		Pacific_AutoPostAll(on)
}

SitInAll(in) {
	global
	if FullTilt_GameWindow
		FullTilt_SitInAll(in)
	if PokerStars_GameWindow
		PokerStars_SitInAll(in)
	if IPoker_GameWindow
		IPoker_SitInAll(in)
	if PartyPoker_GameWindow
		PartyPoker_SitInAll(in)
	if EverestPoker_GameWindow
		EverestPoker_SitInAll(in)
	if Ongame_GameWindow
		Ongame_SitInAll(in)
	if CakePoker_GameWindow
		CakePoker_SitInAll(in)
	if Microgaming_GameWindow
		Microgaming_SitInAll(in)
	if Pacific_GameWindow
		Pacific_SitInAll(in)
}

LeaveAll:
	if FullTilt_GameWindow
		FullTilt_CloseGameWindows(FullTilt_GameWindow)
	if PokerStars_GameWindow
		PokerStars_CloseGameWindows(PokerStars_GameWindow)
	if IPoker_GameWindow
		IPoker_CloseGameWindows(IPoker_GameWindow)
	if PartyPoker_GameWindow
		PartyPoker_CloseGameWindows(PartyPoker_GameWindow)
	if EverestPoker_GameWindow
		EverestPoker_CloseGameWindows(EverestPoker_GameWindow)
	if Ongame_GameWindow
		Ongame_CloseGameWindows(Ongame_GameWindow)
	if CakePoker_GameWindow
		CakePoker_CloseGameWindows(CakePoker_GameWindow)
	if Microgaming_GameWindow
		Microgaming_CloseGameWindows(Microgaming_GameWindow)
	if Pacific_GameWindow
		Pacific_CloseGameWindows(Pacific_GameWindow)
	return

Debug() {
	WinGet, id, ID, A
	Loop {
		file = Debug-%A_Index%.txt
		if !FileExist(file)
			break
	}
	WinGetClass, class, ahk_id %id%
	WinGetPos, , , width, height, ahk_id %id%
	WinGetTitle, title, ahk_id %id%
	FileAppend, %class%`t[%width%`,%height%]`t%title%`n, % file
	WinGet, controls, ControlList, ahk_id %id%
	Loop, Parse, controls, `n
	{
		ControlGet, visible, Visible, , % A_LoopField, ahk_id %id%
		if visible {
			ControlGetText, text, % A_LoopField, ahk_id %id%
			FileAppend, %A_LoopField%`t%text%`n, % file
		} else {
			FileAppend, (%A_LoopField%)`n, % file
		}
	}
	
	FileAppend, `n`nPokerPad.ini Settings`n, % file
	Loop, Read, PokerPad.ini
		FileAppend, %A_LoopReadLine%`n, % file
}

;%

Debug:
	Critical, On
	Debug()
	return

IsChecked(ByRef area, relative = 1, color = 0x000000, ByRef id = "") {
	GetWindowArea(x, y, w, h, area, relative, id)
	return Display_PixelSearch(x, y, h, h, color, 16, id)
}

GetBet(factor, pot, call, raise, blind) {
	if call {
		pot += call
		if (call < blind) { ; small blind
			bet := blind
		} else { ; raise or open bet preflop
			/* bet := raise - call
			if (call > bet)
			*/
				bet := call
		}
	} else if (raise > blind) { ; big blind
		bet := blind
	} else { ; open bet postflop
		bet := 0
	}
	pot *= factor
	return bet + pot
}

GetPot(ByRef pot, call, raise, blind) {
	if call {
		if (call < blind) {
			pot -= blind
		} else {
			pot -= call
			bet := raise - call
			if (bet < call)
				bet := call
			pot -= bet
		}
	} else if (raise != blind) {
		pot -= blind
	}
}

Bet(ByRef bet) {
	BlockInput, On
	Send, {Home}+{End}{Backspace}
	if bet
		Send, %bet%
	BlockInput, Off
}

LoadCurrencyFormat(client) {
	IniRead, %client%_Currency, PokerPad.ini, %client%, Currency, $
	IniRead, %client%_Separator, PokerPad.ini, %client%, Separator, `,
	if (%client%_Separator = "")
		%client%_Separator := A_Space
	IniRead, %client%_Decimal, PokerPad.ini, %client%, Decimal, %A_Space%
}
	
GetFactor(var, ByRef factor) {
	global
	factor := %var%
	if InStr(factor, "b") {
		StringTrimRight, factor, factor, 1
		return true
	}
	return false
}



	
	


	

; ( [] )..( [] )   Full Tilt Implementation   ( [] )..( [] ) 

#Include Includes/FullTilt.ahk

FullTilt() {
	global
	; Windows
	FullTilt_LobbyWindow = ahk_class FTCLobby
	FullTilt_TournamentLobbyWindow = ahk_class FTCLTourney
	FullTilt_GameWindow = ahk_class FTC_TableViewFull
	SiteFTC_TableViewFull = FullTilt
	Tile_WidthFTC_TableViewFull := 472
	Tile_RatioFTC_TableViewFull := 472/325
	FullTilt_LastHandWindow = ahk_class FTCLastHand
	; Table Controls
	FullTilt_FoldBox = FTCSkinButton29
	FullTilt_FoldBox2 = FTCSkinButton30
	FullTilt_CallBox = FTCSkinButton31
	FullTilt_CallBox2 = FTCSkinButton32
	FullTilt_RaiseBox = FTCSkinButton33
	FullTilt_RaiseBox2 = FTCSkinButton34
	
	FullTilt_Check = FTCSkinButton11
	FullTilt_Call = FTCSkinButton12
	FullTilt_Raise = FTCSkinButton13
	FullTilt_SitOut = FTCSkinButton36
	FullTilt_FoldAny = FTCSkinButton35
	FullTilt_Max = FTCSkinButton24
	FullTilt_Pot = FTCSkinButton25
	FullTilt_Pot2 = FTCSkinButton27
	FullTilt_Min = FTCSkinButton23
	FullTilt_BetAmount = Edit1
	FullTilt_Time = FTCSkinButton19
	FullTilt_Chat = Edit2
	FullTilt_DealMeIn = FTCSkinButton15
	; Ring Table Specific
	FullTilt_LastHandRing = FTCSkinButton3
	FullTilt_Lobby = FTCSkinButton8
	FullTilt_StandUp = FTCSkinButton6
	FullTilt_AutoPost = FTCSkinButton37
	; Tourny Table Specific
	FullTilt_LastHandTourny = FTCSkinButton4
	
	SetClientHotkeys("FullTilt")
	GroupAdd, GameWindows, ahk_class FTC_TableViewFull
	return true
}


FullTilt_AllInQueue:
	FullTilt_AllInQueue()
	return
FullTilt_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, FullTilt_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(FullTilt_Call, id)
			visible := 1
		if IsControlVisible(FullTilt_Raise, id)
			visible := 2
		if IsControlVisible(FullTilt_BetAmount, id) {
			ClickControl(FullTilt_Max, id)
			Sleep, 400
			Notify("Raise", id)
			ClickControl(FullTilt_Raise, id)
		} else if visible
			if (visible == 1) {
				Notify("Call", id)
				ClickControl(FullTilt_Call, id)
			} else {
				Notify("Raise", id)
				ClickControl(FullTilt_Raise, id)
			}
		else
			continue
		ListRemove(FullTilt_AllInQueue, A_Index-1)
	}
	if !FullTilt_AllInQueue
		SetTimer, FullTilt_AllInQueue, Off
	Critical, Off
}

FullTilt_BetRelativePot(factor) {
	local control
	if IsControlVisible(FullTilt_Pot)
		control := FullTilt_Pot
	else if IsControlVisible(FullTilt_Pot2) ; pot limit
		control := FullTilt_Pot2
	else {
		if IsControlVisible(FullTilt_Max)
			ClickControl(FullTilt_Max)
		return
	}
	ControlSetText, %FullTilt_BetAmount%
	local x, y, w, h
	GetControlArea(x, y, w, h, FullTilt_Raise, 0.2, 0.6, 0.6, 0)
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context
	local width
	WinGetPos, , , width
	width := width < 570 ? 4 : 0
	Display_FindText(x, y, w, h, "BlueBackground", 0, context)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, "BlueBackground", 0, c, width, "GreenForeground", "FullTilt_"))
	ClickControl(control)
	Sleep, 20
	local pot
	ControlGetText, pot, %FullTilt_BetAmount%
	local call := 0
	local blind := FullTilt_GetBlind(true)
	if IsControlVisible(FullTilt_Call) {
		GetControlArea(x, y, w, h, FullTilt_Call, 0.2, 0.6, 0.6, 0)
		Display_FindText(x, y, w, h, "BlueBackground", 0, context)
		call := CurrencyToFloat(Display_ReadArea(x, y, w, h, "BlueBackground", 0, c, width, "GreenForeground", "FullTilt_"))
	}
	Display_DeleteWindowCapture(device, context, pixels)
	GetPot(pot, call, raise, blind)
	ControlSetText, % FullTilt_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, blind), FullTilt_GetRound(Rounding, Rounding))
}

FullTilt_FixedBet(factor) {
	global
	if !IsControlVisible(FullTilt_BetAmount)
		return
	ControlSetText, % FullTilt_BetAmount, % GetDollarRound(factor * FullTilt_GetBlind(true))
	Sleep, 400
	ClickControl(FullTilt_Raise)
}


FullTilt_SitInAll(in) {
	local windows, id
	WinGet windows, List, %FullTilt_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlVisible(FullTilt_DealMeIn, id) == in) {
			ClickControl(in ? FullTilt_DealMeIn : FullTilt_SitOut, id)
		}
	}
}

FullTilt_IsChecked(ByRef control, ByRef id) {
	ControlGetPos, x, y, w, h, %control%, ahk_id %id%
	x += 2
	y += Ceil(h * 0.25)
	h := Floor(h * 0.5)
	return Display_PixelSearch(x, y, h, h, 0x000000, 16, id)
}

FullTilt_AutoPostAll(on) {
	local windows, id
	WinGet windows, List, %FullTilt_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (FullTilt_IsChecked(FullTilt_AutoPost, id) != on) {
			ClickControl(FullTilt_AutoPost, id)
		}
	}
}

FullTilt_CloseGameWindows(ByRef title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsControlVisible(FullTilt_DealMeIn, id) && IsControlEnabled(SitOut, id)) {
			ClickControl(FullTilt_SitOut, id)
		}
		WinClose, ahk_id %id%
	}
}


FullTilt_GetRound(rounding, default) {
	if (rounding < -1) 
		return FullTilt_GetBlind(rounding+2)
	return default
}


FullTilt_Activate:
	WinActivate, %FullTilt_GameWindow%
OnActivate_FTC_TableViewFull:
	ControlFocus, %FullTilt_Chat%, A
	return
FullTilt_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, FullTilt_BetAmount)
	return
FullTilt_Fold:
	if IsControlVisible(FullTilt_Check)
		ClickControl(FullTilt_Check)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_FoldBox))
		ClickControl(FullTilt_FoldBox)
	else if IsControlVisible(FullTilt_FoldBox2)
		ClickControl(FullTilt_FoldBox2)
	else if IsControlVisible(FullTilt_DealMeIn)
		ClickControl(FullTilt_DealMeIn)
	return
FullTilt_Call:
	if IsControlVisible(FullTilt_Call)
		ClickControl(FullTilt_Call)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_CallBox))
		ClickControl(FullTilt_CallBox)
	else if IsControlVisible(FullTilt_CallBox2)
		ClickControl(FullTilt_CallBox2)
	else if IsControlVisible(FullTilt_Check)
		ClickControl(FullTilt_Check)
	return
FullTilt_Raise:
	if IsControlVisible(FullTilt_Raise)
		ClickControl(FullTilt_Raise)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_RaiseBox))
		ClickControl(FullTilt_RaiseBox)
	else if IsControlVisible(FullTilt_RaiseBox2)
		ClickControl(FullTilt_RaiseBox2)
	else if IsControlVisible(FullTilt_Call)
		ClickControl(FullTilt_Call)
	return
FullTilt_Relative1:
	FullTilt_BetRelativePot(Relative1)
	return
FullTilt_Relative2:
	FullTilt_BetRelativePot(Relative2)
	return
FullTilt_Relative3:
	FullTilt_BetRelativePot(Relative3)
	return
FullTilt_Relative4:
	FullTilt_BetRelativePot(Relative4)
	return
FullTilt_Relative5:
	FullTilt_BetRelativePot(Relative5)
	return
FullTilt_Relative6:
	FullTilt_BetRelativePot(Relative6)
	return
FullTilt_Relative7:
	FullTilt_BetRelativePot(Relative7)
	return
FullTilt_Relative8:
	FullTilt_BetRelativePot(Relative8)
	return
FullTilt_Relative9:
	FullTilt_BetRelativePot(Relative9)
	return
FullTilt_Fixed1:
	FullTilt_FixedBet(Fixed1)
	return
FullTilt_Fixed2:
	FullTilt_FixedBet(Fixed2)
	return
FullTilt_Fixed3:
	FullTilt_FixedBet(Fixed3)
	return
FullTilt_Fixed4:
	FullTilt_FixedBet(Fixed4)
	return
FullTilt_Fixed5:
	FullTilt_FixedBet(Fixed5)
	return
FullTilt_Fixed6:
	FullTilt_FixedBet(Fixed6)
	return
FullTilt_Fixed7:
	FullTilt_FixedBet(Fixed7)
	return
FullTilt_Fixed8:
	FullTilt_FixedBet(Fixed8)
	return
FullTilt_Fixed9:
	FullTilt_FixedBet(Fixed9)
	return
FullTilt_RandomBet:
	FullTilt_BetRelativePot(GetRandomBet())
	return
FullTilt_AllIn:
	if IsControlVisible(FullTilt_BetAmount)
		ClickControl(FullTilt_Max)
	return
FullTilt_LastHand:
	ClickControl(IsControlVisible(FullTilt_LastHandRing) ? FullTilt_LastHandRing : FullTilt_LastHAndTourny)
	return
FullTilt_IncreaseBet:
	ControlIncreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment, 0))
	return
FullTilt_DecreaseBet:
	ControlDecreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment, 0))
	return
FullTilt_IncreaseBet2:
	ControlIncreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment2, 0))
	return
FullTilt_DecreaseBet2:
	ControlDecreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment2, 0))
	return
FullTilt_FoldAny:
	ClickControl(FullTilt_FoldAny)
	return
FullTilt_AutoPost:
	ClickControl(FullTilt_AutoPost)
	return
FullTilt_ToggleAutoMuck:
	WinMenuSelectItem, %FullTilt_LobbyWindow%, , Options, Auto Muck Hands
	return
FullTilt_AllInThisHand:
	AddCurrentIDToQueue("FullTilt_AllInQueue", 5000)
	return
FullTilt_Reload:
	FullTilt_Reload(InStr(A_ThisHotkey, "^") ? 0 : -1)
	return
FullTilt_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %FullTilt_LobbyWindow%
	else
		ClickControl(FullTilt_Lobby)
	return
FullTilt_SitOut:
	ClickControl(FullTilt_SitOut)
	return

	
FullTilt_2AB2AB1D1D:
FullTilt_2BB2BB1D1D:
	ErrorLevel = $
	return
FullTilt_2BC2AC1D1D:
	ErrorLevel = 2
	return
FullTilt_2AB2BC1B1C:
	ErrorLevel = 3
	return
FullTilt_1B1D1B1C:
FullTilt_1B1D1C1D:
	ErrorLevel = 4
	return
FullTilt_2BB2AB1C1B:
FullTilt_2AC2AB1C1D:
FullTilt_3ABC2AC1D1D:
	ErrorLevel = 5
	return
FullTilt_1B2BC1B1C:
FullTilt_1D2AC1C1C:
FullTilt_1D2AC1C1D:
FullTilt_1B2BC1D1D:
	ErrorLevel = 6
	return
FullTilt_2AC1A1D1A:
	ErrorLevel = 7
	return
FullTilt_1D1B1A1D:
	ErrorLevel = 8
	return
FullTilt_2AC1B1A1B:
FullTilt_2AC1D1A1D:
FullTilt_2AC1B1D1D:
FullTilt_1A1A1D1C:
	ErrorLevel = 9
	return
FullTilt_1D1D1C1D:
	ErrorLevel = 0
	return
FullTilt_1D1D1A1D: ; 0 8
FullTilt_2AC1D1D1D: ; 0 3 8 9
	ErrorLevel = ZeroThreeFourEightNine
	return
FullTilt_2BC2AC1C1D: ; 2 5
FullTilt_2AC2BC1D1D:
FullTilt_2AC2AC1D1D: ; 2 3 5 8
	ErrorLevel = TwoThreeFiveEight
	return
FullTilt_2BB1B1B1B: ; 3 9
	ErrorLevel = ThreeNine
	return






	
; ( [] )..( [] )   Poker Stars Implementation   ( [] )..( [] ) 

#Include Includes\PokerStars.ahk
	
PokerStars() {
	local theme, area, width, height
	width := PokerStars_Read("Width", theme)
	height := PokerStars_Read("Height", theme)
	local names := "Pot,Fold,Call,Raise,FoldAny,SitOut,AutoPost,LastHand,StandUp,Lobby,Options"
	Loop, Parse, names, `,
	{
		area := PokerStars_Read(A_LoopField, theme)
		if (area == "")
			return false
		PokerStars_%A_LoopField% := CreateArea(area, width, height)
	}
	PokerStars_ExcludeActionColor := PokerStars_Read("ExcludeActionColor")
	if !ReadColor(theme, "PokerStars", "ActionColor")
		return false
	if !ReadColor(theme, "PokerStars", "ButtonColor")
		return false
	if !ReadColor(theme, "PokerStars", "BoxColor")
		return false
	if !ReadColor(theme, "PokerStars", "PotBackground")
		return false
		
	PokerStars_FoldBoxX := 412/792
	PokerStars_CallBoxX := 539/792
	PokerStars_RaiseBoxX := 646/792
	PokerStars_BoxTop := 473/546
	PokerStars_BoxBottom := 495/546
	PokerStars_BoxWidth := 100/792
	PokerStars_BoxHeight := 10/546
	
	; windows
	PokerStars_GameWindow = ahk_class PokerStarsTableFrameClass
	SitePokerStarsTableFrameClass = PokerStars
	Tile_WidthPokerStarsTableFrameClass := 475
	Tile_RatioPokerStarsTableFrameClass := 475/328
	Tile_DragPokerStarsTableFrameClass := true
	PokerStars_LobbyWindow = ^PokerStars Lobby
	PokerStars_TournamentLobbyWindow = ^Tournament
	PokerStars_LastHandWindow = ^Instant Hand History ahk_class #32770
	
	; table controls
	PokerStars_BetAmount = PokerStarsSliderEditorClass1
	PokerStars_Chat = PokerStarsChatEditorClass1

	SetClientHotkeys("PokerStars")
	GroupAdd, GameWindows, ahk_class PokerStarsTableFrameClass
	return true
}

PokerStars_ClickButton(button) {
	local boxX := PokerStars_%button%BoxX, x, y, w, h, bgr, area
	if !InStr(A_ThisHotkey, "^") {
		area = %boxX% %PokerStars_BoxTop% %PokerStars_BoxWidth% %PokerStars_BoxHeight%
		GetWindowArea(x, y, w, h, area)
		PixelSearch, , , x, y, x+5, y+5, PokerStars_BoxColor, PokerStars_BoxColorVariation
		if !ErrorLevel {
			ClickWindowRect(x, y, w, h)
			return
		}
	}
	area = %boxX% %PokerStars_BoxBottom% %PokerStars_BoxWidth% %PokerStars_BoxHeight%
	GetWindowArea(x, y, w, h, area)
	PixelSearch, , , x, y, x+5, y+5, PokerStars_BoxColor, PokerStars_BoxColorVariation
	if !ErrorLevel {
		ClickWindowRect(x, y, w, h)
		return
	}
	area := PokerStars_%button%
	ClickWindowArea(area)
}

	
PokerStars_GetReadParameters(ByRef h, byRef v, ByRef maxWidth, ByRef exclude) {
	if (h < 12)
		h := 12
	v := Round((6 - h/2) * 6)
	if (v >= 0)
		v := 32
	else if (v > 16)
		v := 16
	else
		v += 32
	maxWidth := Round(h/2)
	exclude := h < 16 ? "0x326464,52" : "0x326464,100"
}

PokerStars_BetRelativePot(factor, round = 0) {
	global
	if !IsControlVisible(PokerStars_BetAmount)
		return
	ControlSetText, %PokerStars_BetAmount%
	local x, y, w, h, device, context, pixels
	GetWindowArea(x, y, w, h)
	x += Round(w/2)
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, limit := 1
	Display_FindPixelHorizontal(x, y, limit, h, PokerStars_PotBackground, 16, context)
	local potY := y
	local bgr, black := 0x303030, variation := 64
	Loop, %w% {
		bgr := Display_GetPixel(context, --x, y)
		if Display_CompareColors(bgr, black, variation)
			break
	}
	x++
	Display_FindPixelHorizontal(x, y, limit := 20, h, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; P
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; O
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; T
	local potX := x
	Display_FindPixelHorizontal(x, y, limit := 1, h, black, variation, context)
	local potH := y - potY - 1
	Display_FindPixelHorizontal(x, potY, w, limit := 1, black, variation, context)
	local potW := x - potX - 1
	local pot := CurrencyToFloat(Display_ReadArea(potX, potY, potW, potH, black, variation, c))
	GetWindowArea(x, y, w, h, PokerStars_Call, true)
	local call := 0, maxWidth
	if Display_PixelSearch(x, y, w, 1, PokerStars_ActionColor, 32, c) {
		y += Round(h * 0.75)
		Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
		PokerStars_GetReadParameters(h, v, maxWidth, exclude)
		call := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	}
	GetWindowArea(x, y, w, h, PokerStars_Raise, true)
	y += Round(h * 0.75)
	Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
	PokerStars_GetReadParameters(h, v, maxWidth, exclude)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	Display_DeleteWindowCapture(device, context, pixels)
	ControlSetText, % PokerStars_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, PokerStars_GetBlind(true)), PokerStars_GetRound(Rounding, Rounding))
}

PokerStars_FixedBet(factor) {
	global
	if !IsControlVisible(PokerStars_BetAmount)
		return
	ControlSetText, % PokerStars_BetAmount, % GetDollarRound(factor * PokerStars_GetBlind(true))
	Sleep, 400
	ClickWindowArea(PokerStars_Raise)
}


PokerStars_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsChecked(PokerStars_SitOut, true, 0x000000, id)) {
			ClickWindowArea(PokerStars_SitOut, true, id)
		}
		WinClose, ahk_id %id%
	}
}

PokerStars_ReloadQueue:
	PokerStars_ReloadQueue()
	return
PokerStars_ReloadQueue() {
	Critical, On ; this must be synchronized
	Loop, Parse, PokerStars_ReloadQueue, `,
	{
		id := ListGet(PokerStars_ReloadQueue, A_Index-1)
	}
	if !PokerStars_ReloadQueue
		SetTimer, PokerStars_ReloadQueue, Off
	Critical, Off

}


PokerStars_SitInAll(in) {
	global
	PokerStars_CheckAll(PokerStars_SitOut, !in)
}

PokerStars_AutoPostAll(on) {
	global
	PokerStars_CheckAll(PokerStars_AutoPost, on)
}

PokerStars_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %PokerStars_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, true, 0x000000, id) != checked) {
			ClickWindowArea(checkbox, true, id)
		}
	}
}

PokerStars_GetRound(rounding, default) {
	if (rounding < -1) 
		return PokerStars_GetBlind(rounding+2)
	return default
}

PokerStars_AllInQueue:
	PokerStars_AllInQueue()
	return
PokerStars_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, PokerStars_AllInQueue, `,
	{
		id := A_LoopField
		if IsControlVisible(PokerStars_BetAmount, id) {
			ControlSetText, % PokerStars_BetAmount, 999999, ahk_id %id%
			Notify("Raise", id)
			ClickWindowArea(PokerStars_Raise, true, id)
		} else {
			local x, y, w, h
			GetWindowArea(x, y, w, h, PokerStars_Raise, true)
			local device, context, pixels
			Display_CreateWindowCapture(device, context, pixels, id)
			local bgr := Display_GetPixel(context, x, y)
			visible := Display_CompareColors(bgr, PokerStars_ButtonColor, PokerStars_ButtonColorVariation)
			Display_DeleteWindowCapture(device, context, pixels, id)
			if visible {
				if IsControlVisible(PokerStars_BetAmount, id) {
					ControlSetText, % PokerStars_BetAmount, 999999, ahk_id %id%
				}
				Notify("Raise", id)
				ClickWindowArea(PokerStars_Raise, true, id)
			} else
				continue
		}
		ListRemove(PokerStars_AllInQueue, A_Index-1)
	}
	if !PokerStars_AllInQueue
		SetTimer, PokerStars_AllInQueue, Off
	Critical, Off
}

PokerStars_Activate:
	WinActivate, %PokerStars_GameWindow%
	return
PokerStars_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, PokerStars_BetAmount)
	return
PokerStars_Fold:
	PokerStars_ClickButton("Fold")
	return
PokerStars_Call:
	PokerStars_ClickButton("Call")
	return
PokerStars_Raise:
	PokerStars_ClickButton("Raise")
	return
PokerStars_Relative1:
	PokerStars_BetRelativePot(Relative1)
	return
PokerStars_Relative2:
	PokerStars_BetRelativePot(Relative2)
	return
PokerStars_Relative3:
	PokerStars_BetRelativePot(Relative3)
	return
PokerStars_Relative4:
	PokerStars_BetRelativePot(Relative4)
	return
PokerStars_Relative5:
	PokerStars_BetRelativePot(Relative5)
	return
PokerStars_Relative6:
	PokerStars_BetRelativePot(Relative6)
	return
PokerStars_Relative7:
	PokerStars_BetRelativePot(Relative7)
	return
PokerStars_Relative8:
	PokerStars_BetRelativePot(Relative8)
	return
PokerStars_Relative9:
	PokerStars_BetRelativePot(Relative9)
	return
PokerStars_Fixed1:
	PokerStars_FixedBet(Fixed1)
	return
PokerStars_Fixed2:
	PokerStars_FixedBet(Fixed2)
	return
PokerStars_Fixed3:
	PokerStars_FixedBet(Fixed3)
	return
PokerStars_Fixed4:
	PokerStars_FixedBet(Fixed4)
	return
PokerStars_Fixed5:
	PokerStars_FixedBet(Fixed5)
	return
PokerStars_Fixed6:
	PokerStars_FixedBet(Fixed6)
	return
PokerStars_Fixed7:
	PokerStars_FixedBet(Fixed7)
	return
PokerStars_Fixed8:
	PokerStars_FixedBet(Fixed8)
	return
PokerStars_Fixed9:
	PokerStars_FixedBet(Fixed9)
	return
PokerStars_RandomBet:
	PokerStars_BetRelativePot(GetRandomBet())
	return
PokerStars_AllIn:
	if IsControlVisible(PokerStars_BetAmount)
		ControlSetText, % PokerStars_BetAmount, 999999
	return
PokerStars_LastHand:
	ClickWindowArea(PokerStars_LastHand)
	return
PokerStars_IncreaseBet:
	ControlIncreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment, 0))
	return
PokerStars_DecreaseBet:
	ControlDecreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment, 0))
	return
PokerStars_IncreaseBet2:
	ControlIncreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment2, 0))
	return
PokerStars_DecreaseBet2:
	ControlDecreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment2, 0))
	return
PokerStars_FoldAny:
	ClickWindowArea(PokerStars_FoldAny)
	return
PokerStars_AutoPost:
	ClickWindowArea(PokerStars_AutoPost)
	return
PokerStars_ToggleAutoMuck:
	WinMenuSelectItem, %PokerStars_LobbyWindow%, , Options, Muck Losing Hand
	WinMenuSelectItem, %PokerStars_LobbyWindow%, , Options, Don't Show Winning Hand
	return
PokerStars_AllInThisHand:
	AddCurrentIDToQueue("PokerStars_AllInQueue", 5000)
	return
PokerStars_Reload:
	PokerStars_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
PokerStars_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %PokerStars_LobbyWindow%
	else
		ClickWindowArea(PokerStars_Lobby)
	return
PokerStars_SitOut:
	ClickWindowArea(PokerStars_SitOut)
	return

PokerStars_2AC2BC1A1A: ; $ 2
	ErrorLevel = TwoDollar
	return
PokerStars_2BB2BB2BC2BC:
PokerStars_2AB2AB1D1A:
	ErrorLevel = $
	return
PokerStars_2BC1D1A1D:
PokerStars_2BC1C1B1C:
PokerStars_2BC1C1B1D:
PokerStars_2BC2BC2BC1D:
PokerStars_2BC1D1B1D:
PokerStars_2BC1D1D1D:
	ErrorLevel = 1
	return
PokerStars_1C2BC1B1D:
PokerStars_2BC2AC1B1D:
PokerStars_2AC1C1A1A:
PokerStars_2BC2AC1C1D:
	ErrorLevel = 2
	return
PokerStars_2BC2BB1B2AB:
PokerStars_1C2BB1B1A:
PokerStars_2BC2BB1B1A:
PokerStars_2AC1B1A2AB:
PokerStars_2AC2BB1A2AB:
PokerStars_2AC2BB1A1A:
PokerStars_3ABC1B1A2AB:
PokerStars_3ABC2AB1A2AB:
PokerStars_2BC1D1C2AC:
	ErrorLevel = 3
	return
PokerStars_3BBB1D1B1B:
PokerStars_2BB1D1B1B:
PokerStars_2BB1D1C1C:
	ErrorLevel = 4
	return
PokerStars_3ABC1B1B1A:
PokerStars_3ABC2AB1B1A:
	ErrorLevel = 5
	return
PokerStars_1B1C1B2BC:
PokerStars_1C2AC1B1C:
PokerStars_1C2AC1B1A:
PokerStars_1C2AC1B1B:
PokerStars_1C2AC2BC1C:
	ErrorLevel = 6
	return
PokerStars_1A1A1C1B:
	ErrorLevel = 7
	return
PokerStars_2BC2BB2BB1B:
PokerStars_2BC2BC1C1D:
PokerStars_1D1D1A1D:
PokerStars_1D1C1A1D:
PokerStars_1C2BC1D1D:
	ErrorLevel = 8
	return
PokerStars_2AC1B2AC1B:
PokerStars_2AC1B2AB1B:
PokerStars_1A1A1B1B:
	ErrorLevel = 9
	return
PokerStars_1D1B2BB2AC:
PokerStars_1D1B2AB1A:
PokerStars_1C1B2BB1B:
PokerStars_1D1C1A1A:
PokerStars_1C1C1B1B:
PokerStars_1C1D1C1C:
	ErrorLevel = 0
	return
PokerStars_1B1B2BB1B: ; 0 9
	if !ErrorLevel
		ErrorLevel = Display_IsFirstColumnNearBottom
	else
		ErrorLevel := ErrorLevel < 0 ? 9 : 0
	return
PokerStars_1B1B1B1B: ; 0 3 9
PokerStars_2BB1B1B1B: ; 4 9
	ErrorLevel = ZeroThreeFourEightNine
	return
PokerStars_2BC2AB1B2AB: ; 3 5
PokerStars_2AC1B1A1A: ; 3 5 $
	if !ErrorLevel
		ErrorLevel = Display_IsMiddle3Seq
	else
		ErrorLevel := ErrorLevel < 0 ? 3 : "ThreeFiveDollar"
	return
	
;HyperSimple
PokerStars_2AC2BC2AC1D:
PokerStars_2BC2AC1B1C:
PokerStars_2BC2AC1D1D:
	ErrorLevel = 1
	return
PokerStars_2AC1B1A2AC:
PokerStars_2AC2BC1B1D:
	ErrorLevel = 2
	return
PokerStars_3ABC2AB1A1A:
PokerStars_2AC2AC1B1A: ; 3 5
	ErrorLevel = ThreeFive
	return
PokerStars_3ABC1B1A1A:
PokerStars_2BC2AB1B1A:
PokerStars_3ABC2AC1A1A:
PokerStars_ABC2AC1A1A:
PokerStars_2BC1D1C1D:
	ErrorLevel = 3
	return
PokerStars_2AC2AB1C1A:
PokerStars_2AC2AC1A1A:
	ErrorLevel = 5
	return
PokerStars_1C2AB1B1A:
PokerStars_1B2AC1C1C:
PokerStars_1C2AC1C1C:
	ErrorLevel = 6
	return
PokerStars_1D2AC1D1D: ; 6 8
PokerStars_2AC1D1B1D:
PokerStars_1C1D1C1D:
	ErrorLevel = 8
	return
PokerStars_1B1A1C1B:
PokerStars_2AC1A1B1B:
PokerStars_2AC1A1C1B:
	ErrorLevel = 9
	return
PokerStars_1D1D1A1A:
PokerStars_1D1D1B1B:
	ErrorLevel = 0
	return
PokerStars_1B1D1B1B: ; 0 4
	ErrorLevel = ZeroThreeFourEightNine
	return
PokerStars_1B1A1B1B: ; 0 9
	if !ErrorLevel
		ErrorLevel = Display_IsFirstColumnNearBottom
	else
		ErrorLevel := ErrorLevel < 0 ? 9 : 0
	return
PokerStars_2BC2BC1B1D:
PokerStars_2AC2AC1A1D: ; 1 2
	if !ErrorLevel
		ErrorLevel = Display_IsMiddle3Seq
	else
		ErrorLevel := ErrorLevel < 0 ? 1 : 2
	return


/*
#Include Debug.ahk

F1::
	Run := false
	return
	
F2::
	Run := true
	if WinExist(PokerStars_GameWindow) {
		Loop {
			if !Run
				return
			Random, bet, 10, 99
			bet *= 10
			Random, bet, 1000, 2000
			ControlSetText, %PokerStars_BetAmount%, %bet%
			Sleep, -1
			raise := PokerStars_GetRaise()
			if (raise != bet)
				FileAppend, %Display_Signature%%raise%`n%bet%`n, Mappings.txt
		}
	}
	return


PokerStars_GetRaise() {
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, x, y, w, h, v, maxWidth, exclude
	GetWindowArea(x, y, w, h, PokerStars_Raise, true)
	y += Round(h * 0.75)
	Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
	PokerStars_GetReadParameters(h, v, maxWidth, exclude)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	Display_DeleteWindowCapture(device, context, pixels)
	return raise	
}



F3::
	if WinExist(PokerStars_GameWindow) {
		println(PokerStars_GetPot())
;		println(Display_Signature)
	}
	return

PokerStars_GetPot() {
	local x, y, w, h, device, context, pixels
	GetWindowArea(x, y, w, h)
	x += Round(w/2)
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, limit := 1
	Display_FindPixelHorizontal(x, y, limit, h, PokerStars_PotBackground, 16, context)
	local potY := y
	local bgr, black := 0x303030, variation := 64
	Loop, %w% {
		bgr := Display_GetPixel(context, --x, y)
		if Display_CompareColors(bgr, black, variation)
			break
	}
	x++
	Display_FindPixelHorizontal(x, y, limit := 20, h, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; P
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; O
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; T
	local potX := x
	Display_FindPixelHorizontal(x, y, limit := 1, h, black, variation, context)
	local potH := y - potY - 1
	Display_FindPixelHorizontal(x, potY, w, limit := 1, black, variation, context)
	local potW := x - potX - 1
	local pot := CurrencyToFloat(Display_ReadArea(potX, potY, potW, potH, black, variation, c))
	Display_DeleteWindowCapture(device, context, pixels)
	return pot
}
*/
	
	
	
	
	
	
	
	
	
	

	
	
; ( [] )..( [] )   iPoker Implementation   ( [] )..( [] ) 

#Include Includes\IPoker.ahk

IPoker() {


	local theme
	IniRead, theme, PokerPad.ini, IPoker, Theme, A_Space
	if (theme = "")
		return false
	if !ReadColor(theme, "IPoker", "PotColor")
		return false
	if !ReadColor(theme, "IPoker", "ActionColor")
		return false
	if !ReadColor(theme, "IPoker", "CheckColor")
		return false
	if !ReadColor(theme, "IPoker", "BoxColor")
		return false
	
	; These dimensions only work for a window which is 798x600 in size
    IPoker_Fold = 442 536 80 10
	IPoker_CheckFold = 442 560 80 10
	IPoker_Call = 555 535 60 24
	IPoker_Raise = 665 530 60 24
	IPoker_FastFold = 332 535 10 24

	IPoker_AutoPost = 720 590 70 10
	IPoker_FoldAny = 589 586 70 10
	IPoker_SitOut = 525 585 50 10

	IPoker_AutoMuck = 634 545 70 12
	IPoker_AllIn = 710 480 100 24
	IPoker_LastHand = 235 485 70 9

	IPoker_Pot = 378 80 60 22
	IPoker_BetBox = 715 512 40 6
	
	IPoker_PotButton = 660 483 30 7
	; the pot button has different coords for NL and PL
	IPoker_PotButton_NL = 660 483 20 7
	IPoker_PotButton_PL = 700 483 60 7
	
	IPoker_ChatBox := CreateArea("16,534,360,60", 780, 557)
	
	IPoker_GameWindow = / ahk_class PTIODEVICE
	SitePTIODEVICE = IPoker
	IPoker_LobbyWindow = Nickname ahk_class PTIODEVICE
	IPoker_LastHandWindow = Hand history ahk_class PTIODEVICE
	SetClientHotkeys("IPoker")
	GroupAdd, GameWindows, / ahk_class PTIODEVICE
	return true
}

IPoker_AdjustSize(box) {
	local box0, box1, box2, box3, box4, w, h
	WinGetPos, , , w, h
	w /= 800.0
	h /= 600.0
	StringSplit, box, box, %A_Space%
	box1 *= w
	box2 *= h
	box3 *= w
	box4 *= h
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}
;%

/* AdjustClick clicks to the area of the screen indicated by x and y
   with mouse button c (c=0 moves without click) 
*/
IPoker_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w /= 800.0
	h /= 600.0
	x := Round(x * w)
	y := Round(y * h)
	;ControlClick, x%x% y%y%, , , , %c% , NA Pos
	MouseGetPos, px, py
	Click %x% %y% %c%
	Click %px% %py% 0
}

; Return true if the chat window is maximized 
IPoker_ChatMaximized() {
/*	
	local w,h,x,y,dx,bgr,bgr2
	;x := 265
	x := 380
	y := 509
	dy := 10
	WinGetPos, , , w, h
	w /= 800.0
	h /= 600.0
	x := Round(x * w)
	y := Round(y * h)
	dy := Round(dy * h)
	PixelGetColor, bgr, x, y
	PixelGetColor, bgr2, x, y+dy
	;MsgBox %bgr%, %bgr2%
	return Display_CompareColors(bgr, bgr2) 
*/
	return true
}

; We use the window handle when several fold are done in a row to make sure 
;they reach only one window
IPoker_ClickButton(button, id = "") {
	local x, y, w, h, bgr, dx, dy, dy2, box

	button := IPoker_%button%
	dx := 4
	dy := 6
	dy2 := 15

	;MsgBox % "Before: " . button .  " After: " . IPoker_AdjustSize(button)
	box := IPoker_AdjustSize(button)
	GetWindowArea(x, y, w, h, box, false, id)

;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	if IPoker_ChatMaximized() {
		ClickWindowRect(x, y, w, h, id)
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
}

IPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, IPoker_TableTitle
	
	; we check if the active table is pot-limit or no-limit,
	; set the coords of the pot button accordingly
	; and click it to get the pot size

	WinGetTitle,IPoker_TableTitle,A

	IfInString,IPoker_TableTitle,Pot limit
		box := IPoker_AdjustSize(IPoker_PotButton_PL)
	else
		box := IPoker_AdjustSize(IPoker_PotButton_NL)

	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	Sleep, 200
	;select and copy
	IPoker_AdjustClick(715, 512)
	Send, {Home}+{End}^c
	pot := Clipboard
	return (factor * pot)
}


/*IPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot
	
	;we click on the pot button to get the pot size
	box := IPoker_AdjustSize(IPoker_PotButton)
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	Sleep, 200
	;select and copy
	IPoker_AdjustClick(715, 512)
	Send, {Home}+{End}^c
	pot := Clipboard
	return (factor * pot)
}
*/
	
Ipoker_CheckBet(bet) {
	IPoker_AdjustClick(715, 512)
	Send, {Home}+{End}^c
	if (Clipboard == bet)
		return 1
	else
		return 0
}
	

IPoker_Bet(ByRef betbox, bet = "") {
	IPoker_AdjustClick(715, 512)
	Send, {Home}+{End}
	;SendInput %bet%
	Bet(bet)

}
	


IPoker_BetRelativePot(factor) {

local box, pot, round := IPoker_GetRound(Rounding, Rounding)

;mypot1 := GetRoundedAmount(IPoker_GetPot(factor), round)
;mypot2 := IPoker_GetPot(factor)
;MsgBox, roundpot: %mypot1%, rawpot: %mypot2%, pot: %pot%

	if IPoker_ChatMaximized() {
		;MsgBox % IPoker_GetPot(factor)
		bet := GetRoundedAmount(IPoker_GetPot(factor), round)
		;box := IPoker_AdjustSize(IPoker_BetBox)
		;IPoker_Bet(box, bet)
		Bet(bet)
;   	Click 720 515 2
;		Sleep, 600


		if (GetHotKey("Rtick") && Ipoker_CheckBet(bet))
		{
			IPoker_ClickButton("Raise")
		}
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
}



IPoker_FixedBet(factor) {
	local pot
	if IPoker_ChatMaximized() {
		pot := GetAmount(GetDollarRound(factor * IPoker_GetBlind(true)), IPoker_Decimal)
		IPoker_Bet(IPoker_BetBox, pot)
		if (GetHotKey("Ftick") && Ipoker_CheckBet(pot))
		{
			IPoker_ClickButton("Raise")
		}
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
}


IPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (!IsChecked(IPoker_SitOut, false, IPoker_CheckColor, id)) {
			ClickWindowArea(IPoker_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

IPoker_SitInAll(in) {
	global
	if !WinExist(IPoker_GameWindow)
		return
	IPoker_CheckAll(IPoker_SitOut, !in)
}

IPoker_AutoPostAll(on) {
	global
	if !WinExist(IPoker_GameWindow)
		return
	IPoker_CheckAll(IPoker_AutoPost, on)
}

IPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %IPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, IPoker_CheckColor, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}


IPoker_GetRound(rounding, default) {
	if (rounding < -1) 
		return IPoker_GetBlind(rounding+2)
	return default
}

IPoker_Activate:
	WinActivate, %IPoker_GameWindow%
	return
IPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
IPoker_Fold:
	IPoker_ClickButton("Fold", id)
	IPoker_ClickButton("CheckFold", id)
	return
IPoker_Call:
	IPoker_ClickButton("Call")
	return
IPoker_Raise:
	IPoker_ClickButton("Raise")
	return
IPoker_FastFold:
	IPoker_ClickButton("FastFold", id)
	IPoker_ClickButton("Fold", id)
	IPoker_ClickButton("CheckFold", id)
	return
IPoker_Relative1:
	IPoker_BetRelativePot(Relative1)
	return
IPoker_Relative2:
	IPoker_BetRelativePot(Relative2)
	return
IPoker_Relative3:
	IPoker_BetRelativePot(Relative3)
	return
IPoker_Relative4:
	IPoker_BetRelativePot(Relative4)
	return
IPoker_Relative5:
	IPoker_BetRelativePot(Relative5)
	return
IPoker_Relative6:
	IPoker_BetRelativePot(Relative6)
	return
IPoker_Relative7:
	IPoker_BetRelativePot(Relative7)
	return
IPoker_Relative8:
	IPoker_BetRelativePot(Relative8)
	return
IPoker_Relative9:
	IPoker_BetRelativePot(Relative9)
	return
IPoker_Fixed1:
	IPoker_FixedBet(Fixed1)
	return
IPoker_Fixed2:
	IPoker_FixedBet(Fixed2)
	return
IPoker_Fixed3:
	IPoker_FixedBet(Fixed3)
	return
IPoker_Fixed4:
	IPoker_FixedBet(Fixed4)
	return
IPoker_Fixed5:
	IPoker_FixedBet(Fixed5)
	return
IPoker_Fixed6:
	IPoker_FixedBet(Fixed6)
	return
IPoker_Fixed7:
	IPoker_FixedBet(Fixed7)
	return
IPoker_Fixed8:
	IPoker_FixedBet(Fixed8)
	return
IPoker_Fixed9:
	IPoker_FixedBet(Fixed9)
	return
IPoker_RandomBet:
	IPoker_BetRelativePot(GetRandomBet())
	return
IPoker_AllIn:
	ClickWindowArea(IPoker_IsMiniWindow() ? IPoker_MiniAllIn : IPoker_AllIn, false)
	return
IPoker_LastHand:
	ClickWindowArea(IPoker_IsMiniWindow() ? IPoker_MiniLastHand : IPoker_LastHand, false)
	return
IPoker_IncreaseBet:
IPoker_IncreaseBet2:
	IPoker_AdjustClick(440,510)
	Send, {Right}
	return
IPoker_DecreaseBet:
IPoker_DecreaseBet2:
	IPoker_AdjustClick(440,510)
	Send, {Left}
	return
IPoker_FoldAny:
	ClickWindowArea(IPoker_FoldAny, false)
	return
IPoker_AutoPost:
	ClickWindowArea(IPoker_AutoPost, false)
	return
IPoker_ToggleAutoMuck:
	ClickWindowArea(IPoker_AutoMuck, false)
	return
IPoker_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for iPoker.
	return
IPoker_Reload:
	IPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
IPoker_Lobby:
	WinActivate, %IPoker_LobbyWindow%
	return
IPoker_SitOut:
	ClickWindowArea(IPoker_SitOut, false)
	return
IPoker_ClearBetBox:
	IPoker_Bet(IPoker_BetBox)
	return





	
	
	
	
; ( [] )..( [] )   Party Poker Implementation   ( [] )..( [] ) 

#Include Includes\PartyPoker.ahk

PartyPoker() {
	global
	LoadCurrencyFormat("PartyPoker")

	
	PartyPoker_LobbyWindow = PartyPoker.com ahk_class #32770
	PartyPoker_TournamentLobbyWindow = Tournament lobby ahk_class #32770
	PartyPoker_GameWindow = / ahk_class #32770
	Site#32770 = PartyPoker
	Tile_AbsoluteWidth#32770 := 486
	Tile_Ratio#32770 := 486 / 363
	PartyPoker_LastHandWindow = HH ahk_class #32770
	; Table Controls
	PartyPoker_Fold = AfxWnd90u21
	PartyPoker_Call = AfxWnd90u22
	PartyPoker_Raise = AfxWnd90u23
	
	PartyPoker_FoldBox = AfxWnd90u27
	PartyPoker_FoldBox2 = AfxWnd90u26
	PartyPoker_CallBox = AfxWnd42u22
	PartyPoker_CallBox2 = AfxWnd42u25
	PartyPoker_CallRaise = AfxWnd42u26
	PartyPoker_CallRaise2 = AfxWnd42u27
	
	PartyPoker_SitOut = Button5
	PartyPoker_BetAmount = Edit2
	PartyPoker_Chat = Edit1
	PartyPoker_FoldAny = AfxWnd90u37
	PartyPoker_AutoMuck = Button2
	PartyPoker_Pot = Static12
	PartyPoker_Lobby = AfxWnd90u48
	PartyPoker_LastHand = AfxWnd90u50
	PartyPoker_Time = AfxWnd42u37
	; Ring Table Specific
	PartyPoker_StandUp = Button4
	PartyPoker_AutoPost = Button1
	
	SetClientHotkeys("PartyPoker")
	GroupAdd, GameWindows, "- ahk_class #32770"
	return true
}

	
PartyPoker_BetRelativePot(factor) {
	local pot, call, raise, s
	if !IsControlVisible(PartyPoker_BetAmount)
		return
		
	ControlGetText, pot, %PartyPoker_Pot%
	StringGetPos, s, pot, %A_Space%, R
	pot := CurrencyToFloat(SubStr(pot, s+2), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	local call
	ControlGetText, call, %PartyPoker_Call%
	s := InStr(call, "(")
	if s {
		s += 1
		call := CurrencyToFloat(SubStr(call, s, StrLen(call)-s-1), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	} else
		call := 0
	local raise, r
	local blind := PartyPoker_GetBlind(true)
	/*Loop {
		ControlGetText, raise, %PartyPoker_Raise%
		if (r == raise) {
			break
		}
		r := raise
		raise -= blind
		ControlSetText, %PartyPoker_BetAmount%, %raise%
	}
	*/
	ControlGetText, raise, %PartyPoker_Raise%
	s := InStr(raise, "to `n")
	if s {
		s += 4
		raise := CurrencyToFloat(SubStr(raise, s, StrLen(raise)-s), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	} else
		raise := 0
	;MsgBox pot %pot% call %call% raise %raise%
	ControlSetText, % PartyPoker_BetAmount, % GetAmount(GetRoundedAmount(GetBet(factor, pot, call, raise, PartyPoker_GetBlind(true)), PartyPoker_GetRound(Rounding, Rounding)), PartyPoker_Decimal)
}
	
PartyPoker_FixedBet(factor) {
	global
	local y, z
	if !IsControlVisible(PartyPoker_BetAmount)
		return
	ControlGetText, y, % PartyPoker_BetAmount 
	z := GetAmount(GetDollarRound(factor * PartyPoker_GetBlind(true)), PartyPoker_Decimal)
	if (z >= y) {
		ControlSetText, % PartyPoker_BetAmount, % z
		Sleep, 400
		ClickControl(PartyPoker_Raise)
	}
}

PartyPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsControlChecked(PartyPoker_SitOut, id) && IsControlVisible(PartyPoker_SitOut, id))
			ClickControl(PartyPoker_SitOut, id)
		WinClose, ahk_id %id%
	}
}

PartyPoker_SitInAll(in) {
	global
	PartyPoker_CheckAll(PartyPoker_SitOut, !in)
}

PartyPoker_AutoPostAll(on) {
	global
	PartyPoker_CheckAll(PartyPoker_AutoPost, on)
}

PartyPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %PartyPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlChecked(checkbox, id) != checked && IsControlVisible(checkbox, id))
			ClickControl(checkbox, id)
	}
}


PartyPoker_GetRound(rounding, default) {
	if (rounding < -1) 
		return PartyPoker_GetBlind(rounding+2)
	return default
}

PartyPoker_AllInQueue:
	PartyPoker_AllInQueue()
	return
PartyPoker_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, PartyPoker_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(PartyPoker_Call, id)
			visible := 1
		if IsControlVisible(PartyPoker_Raise, id)
			visible := 2
		if IsControlVisible(PartyPoker_BetAmount, id) {
			ControlSetText, % PartyPoker_BetAmount, 999999, ahk_id %id%
			Notify("Raise", id)
			ClickControl(PartyPoker_Raise, id)
		} else if visible {
			if (visible == 1) {
				Notify("Call", id)
				ClickControl(PartyPoker_Call, id)
			} else {
				Notify("Raise", id)
				ClickControl(PartyPoker_Raise, id)
			}
			visible := 0
		} else
			continue
		ListRemove(PartyPoker_AllInQueue, A_Index-1)
	}
	if !PartyPoker_AllInQueue
		SetTimer, PartyPoker_AllInQueue, Off
	Critical, Off
}
	


PartyPoker_Activate:
	WinActivate, %PartyPoker_GameWindow%
	return
PartyPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, PartyPoker_BetAmount)
	return
PartyPoker_Fold:
	if IsControlVisible(PartyPoker_Fold)
		ClickControl(PartyPoker_Fold)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_FoldBox))
		ClickControl(PartyPoker_FoldBox)
	else if IsControlVisible(PartyPoker_FoldBox2)
		ClickControl(PartyPoker_FoldBox2)
	return
PartyPoker_Call:
	if IsControlVisible(PartyPoker_Call)
		ClickControl(PartyPoker_Call)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_CallBox))
		ClickControl(PartyPoker_CallBox)
	else if IsControlVisible(PartyPoker_CallBox2)
		ClickControl(PartyPoker_CallBox2)
	return
PartyPoker_Raise:
	if IsControlVisible(PartyPoker_Raise)
		ClickControl(PartyPoker_Raise)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_RaiseBox))
		ClickControl(PartyPoker_RaiseBox)
	else if IsControlVisible(PartyPoker_RaiseBox2)
		ClickControl(PartyPoker_RaiseBox2)
	return
PartyPoker_Relative1:
	PartyPoker_BetRelativePot(Relative1)
	return
PartyPoker_Relative2:
	PartyPoker_BetRelativePot(Relative2)
	return
PartyPoker_Relative3:
	PartyPoker_BetRelativePot(Relative3)
	return
PartyPoker_Relative4:
	PartyPoker_BetRelativePot(Relative4)
	return
PartyPoker_Relative5:
	PartyPoker_BetRelativePot(Relative5)
	return
PartyPoker_Relative6:
	PartyPoker_BetRelativePot(Relative6)
	return
PartyPoker_Relative7:
	PartyPoker_BetRelativePot(Relative7)
	return
PartyPoker_Relative8:
	PartyPoker_BetRelativePot(Relative8)
	return
PartyPoker_Relative9:
	PartyPoker_BetRelativePot(Relative9)
	return
PartyPoker_Fixed1:
	PartyPoker_FixedBet(Fixed1)
	return
PartyPoker_Fixed2:
	PartyPoker_FixedBet(Fixed2)
	return
PartyPoker_Fixed3:
	PartyPoker_FixedBet(Fixed3)
	return
PartyPoker_Fixed4:
	PartyPoker_FixedBet(Fixed4)
	return
PartyPoker_Fixed5:
	PartyPoker_FixedBet(Fixed5)
	return
PartyPoker_Fixed6:
	PartyPoker_FixedBet(Fixed6)
	return
PartyPoker_Fixed7:
	PartyPoker_FixedBet(Fixed7)
	return
PartyPoker_Fixed8:
	PartyPoker_FixedBet(Fixed8)
	return
PartyPoker_Fixed9:
	PartyPoker_FixedBet(Fixed9)
	return
PartyPoker_RandomBet:
	PartyPoker_BetRelativePot(GetRandomBet())
	return
PartyPoker_AllIn:
	if IsControlVisible(PartyPoker_BetAmount)
		ControlSetText, % PartyPoker_BetAmount, 999999
	return
;%
PartyPoker_LastHand:
	ClickControl(PartyPoker_LastHand)
	return
PartyPoker_IncreaseBet:
	ControlIncreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment, 0), PartyPoker_Decimal)
	return
PartyPoker_DecreaseBet:
	ControlDecreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment, 0), PartyPoker_Decimal)
	return
PartyPoker_IncreaseBet2:
	ControlIncreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment2, 0), PartyPoker_Decimal)
	return
PartyPoker_DecreaseBet2:
	ControlDecreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment2, 0), PartyPoker_Decimal)
	return
PartyPoker_FoldAny:
	if IsControlVisible(PartyPoker_FoldAny)
		ClickControl(PartyPoker_FoldAny)
	return
PartyPoker_AutoPost:
	if IsControlVisible(PartyPoker_AutoPost)
		ClickControl(PartyPoker_AutoPost)
	return
PartyPoker_ToggleAutoMuck:
	if IsControlVisible(PartyPoker_AutoMuck)
		ClickControl(PartyPoker_AutoMuck)
	return
PartyPoker_AllInThisHand:
	AddCurrentIDToQueue("PartyPoker_AllInQueue", 5000)
	return
PartyPoker_Reload:
	PartyPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
PartyPoker_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %PartyPoker_LobbyWindow%
	else
		ClickControl(PartyPoker_Lobby)
	return
	return
PartyPoker_SitOut:
	if IsControlVisible(PartyPoker_SitOut)
		ClickControl(PartyPoker_SitOut)
	return


	
	
	
	
	
; ( [] )..( [] )   Everest Poker Implementation   ( [] )..( [] ) 

#Include Includes\EverestPoker.ahk

EverestPoker() {
	global
	EverestPoker_LobbyWindow = Everest Poker ahk_class CasinoWndClass
	EverestPoker_TournamentLobbyWindow = Tournament: ahk_class CasinoWndClass
	EverestPoker_GameWindow = Table ahk_class CasinoWndClass
	Tile_WidthCasinoWndClass := 640
	Tile_RatioCasinoWndClass := 640 / 480
	EverestPoker_LastHandWindow = History: ahk_class CasinoWndClass

	LoadCurrencyFormat("EverestPoker")
	
	EverestPoker_Lobby := CreateArea("7,6,50,9", 640, 480)
	EverestPoker_LastHand := CreateArea("558,46,50,9", 640, 480)
	EverestPoker_SitOut := CreateArea("8,443,50,9", 640, 480)
	EverestPoker_StandUp := CreateArea("8,463,50,9", 640, 480)
	EverestPoker_Fold := CreateArea("6,368,72,24", 640, 480)
	EverestPoker_Call := CreateArea("91,368,72,24", 640, 480)
	EverestPoker_CallAny := CreateArea("91,403,72,24", 640, 480)
	EverestPoker_MinRaise := CreateArea("176,368,72,24", 640, 480)
	EverestPoker_PotRaise := CreateArea("262,368,72,24", 640, 480)
	EverestPoker_Raise := CreateArea("262,403,72,24", 640, 480)
	EverestPoker_BetAmount := CreateArea("349,389,60,9", 640, 480)
	EverestPoker_AutoPost := CreateArea("121,463,60,9", 640, 480)
	EverestPoker_AutoMuck := CreateArea("230,463,60,9", 640, 480)
	EverestPoker_IncreaseBet := CreateArea("416,400,8,8", 640, 480)
	EverestPoker_DecreaseBet := CreateArea("416,415,8,8", 640, 480)
	
	EverestPoker_Flop := CreateArea("335,150,9,1", 640, 480)
	EverestPoker_Turn := CreateArea("380,150,9,1", 640, 480)
	EverestPoker_River := CreateArea("428,150,9,1", 640, 480)
	
	SetClientHotkeys("EverestPoker")
	GroupAdd, GameWindows, Table ahk_class CasinoWndClass
	return true
}

EverestPoker_CurrencyToFloat(amount) {
	global
	return CurrencyToFloat(SubStr(amount, 2, StrLen(amount)-2), EverestPoker_Currency, EverestPoker_Separator, EverestPoker_Decimal)
}


EverestPoker_BetRelativePot(factor) {
	local x, y, w, h
	If !EverestPoker_IsButtonVisible(EverestPoker_PotRaise, x, y, w, h) 
		return
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, v, maxWidth
	h := Round(h/2) + 3
	w += 3
	local pot
	if Display_FindPixelVertical(x, y, w, h, "LightForeground", 0, context) {
		Display_FindText(x, y, w, h, "LightForeground", 0, context)
		v := h > 14 ? 8 : -4
		maxWidth := Floor(h/2)
		pot := EverestPoker_CurrencyToFloat(Display_ReadArea(x, y, w, h, "LightForeground", v, c, maxWidth, "", "EverestPoker_"))
	} else {
		Display_DeleteWindowCapture(device, context, pixels)
		return
	}
	local call := 0
	If EverestPoker_IsButtonVisible(EverestPoker_Call, x, y, w, h) {
		h := Round(h/2) + 3
		w += 3
		Display_FindPixelVertical(x, y, w, h, "LightForeground", 0, context)
		Display_FindText(x, y, w, h, "LightForeground", 0, context)
		v := h > 14 ? 8 : -4
		maxWidth := Floor(h/2)
		call := EverestPoker_CurrencyToFloat(Display_ReadArea(x, y, w, h, "LightForeground", v, c, maxWidth, "", "EverestPoker_"))
	}
	GetWindowArea(x, y, w, h, EverestPoker_MinRaise)
	y += Round(h/2)
	h := Round(h/2) + 3
	w += 3
	Display_FindPixelVertical(x, y, w, h, "LightForeground", 0, context)
	Display_FindText(x, y, w, h, "LightForeground", 0, context)
	v := h > 14 ? 8 : -4
	maxWidth := Floor(h/2)
	local raise := EverestPoker_CurrencyToFloat(Display_ReadArea(x, y, w, h, "LightForeground", v, c, maxWidth, "", "EverestPoker_"))
	Display_DeleteWindowCapture(device, context, pixels)
	local blind := EverestPoker_GetBlind(true)
	GetPot(pot, call, raise, blind)
	pot := GetRoundedAmount(GetBet(factor, pot, call, raise, blind), EverestPoker_GetRound(Rounding, Rounding))
	EverestPoker_Bet(pot)
}
	
EverestPoker_FixedBet(factor) {
	global
	If !EverestPoker_IsButtonVisible(EverestPoker_PotRaise) 
		return
	EverestPoker_Bet(factor * EverestPoker_GetBlind(true))
	Sleep, 400
	ClickWindowArea2(EverestPoker_Raise)
}

EverestPoker_FocusBetBox() {
	local x, y, w, h, adjust
	GetWindowArea(x, y, w, h, EverestPoker_BetAmount)
	WinGetPos, , , adjust
	y -= Round((adjust - 640) / 50)
	ClickWindowRect2(x, y, w, h)
}

EverestPoker_Bet(bet = "") {
	EverestPoker_FocusBetBox()
	Bet(bet)
}

EverestPoker_ChangeBet(ByRef button) {
	local x, y, w, h, adjust
	GetWindowArea(x, y, w, h, button)
	WinGetPos, , , adjust
	y -= Round((adjust - 640) / 50)
	ClickWindowRect2(x, y, w, h)
}

EverestPoker_GetRound(rounding, default) {
	if (rounding < -1) {
		return EverestPoker_GetBlind(rounding+2)
	}
	return default
}

EverestPoker_IsButtonVisible(button, ByRef x = "", ByRef y = "", ByRef w = "", ByRef h = "") {
	GetWindowArea(x, y, w, h, button)
	y += Round(h/2)
	PixelGetColor, bgr, x, y
	color := 0x147814
	variation := 16
	return Display_CompareColors(bgr, color, variation)
}


EverestPoker_SitInAll(in) {
	global
	EverestPoker_CheckAll(EverestPoker_SitOut, !in)
}

EverestPoker_AutoPostAll(on) {
	global
	EverestPoker_CheckAll(EverestPoker_AutoPost, on)
}

EverestPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id, x, y, w, h
	WinGet windows, List, %EverestPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (EverestPoker_IsButtonOn(checkbox, id) != checked) {
			ClickWindowArea2(checkbox, true, id)
		}
	}
}

EverestPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if !EverestPoker_IsButtonOn(EverestPoker_SitOut, id) {
			ClickWindowArea2(EverestPoker_SitOut, true, id)
		}
		WinClose
	}
}

EverestPoker_IsButtonOn(ByRef button, ByRef id = "") {
	GetWindowArea(x, y, w, h, button, true, id)
	h := Round(h/2)
	y -= h
	return Display_PixelSearch(x, y, 1, h, 0x15FCFB, 16, id)
}

EverestPoker_GetStreet(c) {
	local x, y, w, h
	GetWindowArea(x, y, w, h, EverestPoker_Flop)
	if !Display_PixelSearch(x, y, w, h, 0xFFFFFF, 0, c)
		return "Preflop"
	GetWindowArea(x, y, w, h, EverestPoker_Turn)
	if !Display_PixelSearch(x, y, w, h, 0xFFFFFF, 0, c)
		return "Flop"
	GetWindowArea(x, y, w, h, EverestPoker_River)
	if !Display_PixelSearch(x, y, w, h, 0xFFFFFF, 0, c)
		return "Turn"
	return "River"
}

EverestPoker_StreetBet(n) {
	local factor, device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local street := EverestPoker_GetStreet("c" . context)
	Display_DeleteWindowCapture(device, context, pixels)
	if GetFactor(street . n, factor)
		EverestPoker_FixedBet(factor)
	else
		EverestPoker_BetRelativePot(factor)
}

EverestPoker_Activate:
	WinActivate, %EverestPoker_GameWindow%
	return
EverestPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
EverestPoker_FoldAny:
EverestPoker_Fold:
	ClickWindowArea2(EverestPoker_Fold)
	return
EverestPoker_Call:
	if InStr(A_ThisHotkey, "^")
		ClickWindowArea2(EverestPoker_CallAny)
	else
		ClickWindowArea2(EverestPoker_Call)
	return
EverestPoker_Raise:
	if InStr(A_ThisHotkey, "^")
		ClickWindowArea2(EverestPoker_PotRaise)
	else if EverestPoker_IsButtonVisible(EverestPoker_Raise)
		ClickWindowArea2(EverestPoker_Raise)
	else
		ClickWindowArea2(EverestPoker_MinRaise)
	return
EverestPoker_Relative1:
	EverestPoker_BetRelativePot(Relative1)
	return
EverestPoker_Relative2:
	EverestPoker_BetRelativePot(Relative2)
	return
EverestPoker_Relative3:
	EverestPoker_BetRelativePot(Relative3)
	return
EverestPoker_Relative4:
	EverestPoker_BetRelativePot(Relative4)
	return
EverestPoker_Relative5:
	EverestPoker_BetRelativePot(Relative5)
	return
EverestPoker_Relative6:
	EverestPoker_BetRelativePot(Relative6)
	return
EverestPoker_Relative7:
	EverestPoker_BetRelativePot(Relative7)
	return
EverestPoker_Relative8:
	EverestPoker_BetRelativePot(Relative8)
	return
EverestPoker_Relative9:
	EverestPoker_BetRelativePot(Relative9)
	return
EverestPoker_RandomBet:
	EverestPoker_BetRelativePot(GetRandomBet())
	return
EverestPoker_Fixed1:
	EverestPoker_FixedBet(Fixed1)
	return
EverestPoker_Fixed2:
	EverestPoker_FixedBet(Fixed2)
	return
EverestPoker_Fixed3:
	EverestPoker_FixedBet(Fixed3)
	return
EverestPoker_Fixed4:
	EverestPoker_FixedBet(Fixed4)
	return
EverestPoker_Fixed5:
	EverestPoker_FixedBet(Fixed5)
	return
EverestPoker_Fixed6:
	EverestPoker_FixedBet(Fixed6)
	return
EverestPoker_Fixed7:
	EverestPoker_FixedBet(Fixed7)
	return
EverestPoker_Fixed8:
	EverestPoker_FixedBet(Fixed8)
	return
EverestPoker_Fixed9:
	EverestPoker_FixedBet(Fixed9)
	return
EverestPoker_Street1:
	EverestPoker_StreetBet(1)
	return
EverestPoker_Street2:
	EverestPoker_StreetBet(2)
	return
EverestPoker_Street3:
	EverestPoker_StreetBet(3)
	return
EverestPoker_AllIn:
	EverestPoker_Bet(999999)
	return
EverestPoker_LastHand:
	ClickWindowArea2(EverestPoker_LastHand)
	return
EverestPoker_IncreaseBet:
EverestPoker_IncreaseBet2:
	EverestPoker_ChangeBet(EverestPoker_IncreaseBet)
;	ClickWindowArea2(EverestPoker_IncreaseBet)
	return
EverestPoker_DecreaseBet:
EverestPoker_DecreaseBet2:
	EverestPoker_ChangeBet(EverestPoker_DecreaseBet)
;	ClickWindowArea2(EverestPoker_DecreaseBet)
	return
EverestPoker_AutoPost:
	ClickWindowArea2(EverestPoker_AutoPost)
	return
EverestPoker_ToggleAutoMuck:
	ClickWindowArea2(EverestPoker_AutoMuck)
	return
EverestPoker_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for Everest Poker.
	return
EverestPoker_Reload:
	EverestPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
EverestPoker_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %EverestPoker_LobbyWindow%
	else
		ClickWindowArea2(EverestPoker_Lobby)
	return
EverestPoker_SitOut:
	ClickWindowArea2(EverestPoker_SitOut)
	return
EverestPoker_ClearBetBox:
	EverestPoker_Bet()
	return
	
EverestPoker_2BB2BB1C1B:
EverestPoker_2BB2AB1D1D:
EverestPoker_2BB2BB1C1C:
	ErrorLevel = $
	return
EverestPoker_1B1A1D1C:
EverestPoker_1B1A1D1B:
EverestPoker_1B1C1D1C:
EverestPoker_1B1B1D1B:
EverestPoker_1B1B1D1C:
	ErrorLevel = 1
	return
EverestPoker_2AC2BC1B1D:
EverestPoker_2AC2AC1C1D:
EverestPoker_2AC2BB1A1D:
EverestPoker_2AC2BC1A1A:
	ErrorLevel = 2
	return
EverestPoker_2AC2BB1B1A:
EverestPoker_2AC1A1D1D:
EverestPoker_2AC2BB1D1D:
EverestPoker_3ABC1A1C1D:
EverestPoker_3ABC2BB1A1A:
EverestPoker_3ABC2AB1B1A:
EverestPoker_3ABC1D1D1D:
EverestPoker_2AC1D1C1D:
EverestPoker_2AC1A1C1D:
EverestPoker_3ABC1A1D1A:
EverestPoker_3ABC1B1B1A:
EverestPoker_2BB2BB1D1D:
EverestPoker_3ABC1B1A1A:
EverestPoker_3BBC2BB1D1D:
	ErrorLevel = 3
	return
EverestPoker_1B1D1C1B:
EverestPoker_1B1C1C1D:
	ErrorLevel = 4
	return
EverestPoker_2BC2AB1B1A:
EverestPoker_2AC2AB1C1A:
EverestPoker_2AC2AB1C1D:
EverestPoker_2BB2AB1C1D:
EverestPoker_2BC2BB1D1A:
	ErrorLevel = 5
	return
EverestPoker_1D2AB1B1A:
EverestPoker_1B2AB1B1D:
EverestPoker_1D2AC1B1D:
EverestPoker_1B2AC1B1C:
EverestPoker_1D2AB1B1D:
EverestPoker_1A2AB1B1A:
EverestPoker_1B2AB1C1D:
EverestPoker_1B2AB1B1C:
EverestPoker_1B2AB1B1A:
EverestPoker_1B2AB1B1B:
EverestPoker_1B2AB1D1D:
EverestPoker_1C2AB1B1A:
EverestPoker_1B2AC1C1C:
	ErrorLevel = 6
	return
EverestPoker_1A1A1D1B:
	ErrorLevel = 7
	return
EverestPoker_1D2BB1D1D:
EverestPoker_2AB1A1C1C:
EverestPoker_1A1D1C1C:
EverestPoker_2BB1B1B1B:
EverestPoker_1A1A1C1C:
EverestPoker_2BB1D1C1C:
EverestPoker_1C1C1C1D:
EverestPoker_1A1D1D1D:
EverestPoker_1A1A1A1A:
EverestPoker_1A1A1A1B:
EverestPoker_1A1A1C1B:
EverestPoker_1D1A1D1D:
EverestPoker_1B1B1B1C:
EverestPoker_1B1B1C1D:
EverestPoker_1C1B1A1D:
EverestPoker_1B2BB1D1D:
EverestPoker_1A1A1B1A:
	ErrorLevel = 8
	return
EverestPoker_2BC1A1B1B:
EverestPoker_2AC1A1A1A:
EverestPoker_2AC1B1A1B:
EverestPoker_2AC1A1C1B:
EverestPoker_2BC1B1D1A:
EverestPoker_2BC1B1A1B:
	ErrorLevel = 9
	return
EverestPoker_1B1A1C1B:
EverestPoker_1A1B1B1B:
EverestPoker_1C1B1A1A:
EverestPoker_1A1A1D1C:
EverestPoker_1A1A1D1A:
EverestPoker_1A1A1B1B:
EverestPoker_1B1B1A1A:
	ErrorLevel = 0
	return
EverestPoker_1A1B1A1B: ; . 0
EverestPoker_1A1D1D1C: ; . 0 1
	ErrorLevel = PeriodZeroOne
	return
EverestPoker_1B1A1C1C:
EverestPoker_1D1B1A1A:
EverestPoker_1D1A1D1A: ; . 0 8
	ErrorLevel = SeparatorZeroEight
	return
EverestPoker_1B1D1C1C: ; . 4 8
	if !ErrorLevel
		ErrorLevel = Display_IsSeparator
	else
		ErrorLevel := ErrorLevel < 0 ? "ZeroFourSixEightNine" : "."
	return
EverestPoker_1C1A1C1A: ; , 8
	if !ErrorLevel
		ErrorLevel = Display_IsSeparator
	else
		ErrorLevel := ErrorLevel < 0 ? 8 : ","
	return
EverestPoker_1D1A1A1A:
	ErrorLevel = ZeroEight
	return
EverestPoker_1B1D1C1D: ; 4 8
EverestPoker_3ABC1A1A1A:
EverestPoker_3ABC1A1D1D:
EverestPoker_1C1B1C1D: ; 3 8
EverestPoker_2BB1B1D1D: ; 3 8
	ErrorLevel = ZeroThreeFourEightNine
	return
EverestPoker_2AC2BB1A1A: ; 2 3
EverestPoker_2AC2AB1B1A:
EverestPoker_2BC2BB1D1D:
EverestPoker_2AC2AB1D1D: ; 3 5
	ErrorLevel = TwoThreeFive
	return
EverestPoker_1B1A1B1B: ; 0 4
EverestPoker_1B1B1B1A: ; 4 6
	ErrorLevel = ZeroFourSixEightNine
	return
EverestPoker_2BC1B1B1B: ; 5 9
EverestPoker_2AC1B1A1A: ; 5 9
	ErrorLevel = FiveNine
	return
EverestPoker_1D2AB1A1A: ; 6 8
	ErrorLevel = ZeroFourSixEightNine
	return
EverestPoker_2AC1A1D1A: ; 7 9
	ErrorLevel = SevenNine
	return
EverestPoker_3ABC2AB1A1A: ; 7 3
	if !ErrorLevel
		ErrorLevel = Display_IsMiddle3Seq
	else
		ErrorLevel := ErrorLevel < 0 ? 7 : 3
	return










	
	
; ( [] )..( [] )   Ongame Implementation   ( [] )..( [] ) 

#Include Includes\Ongame.ahk

Ongame() {
	global
	Ongame_LobbyWindow = Welcome ahk_class AfxFrameOrView70u
	Ongame_GameWindow = \$ ahk_class AfxFrameOrView70u
	SiteAfxFrameOrView70u = Ongame

	Ongame_OK = button48
	
	Ongame_Lobby = Button11
	Ongame_GetChips = Button10
	
	LoadCurrencyFormat("Ongame")
	
	Ongame_SitIn = Button6
	Ongame_SitOut = Button7
	Ongame_StandUp = Button9
	
	Ongame_Fold = Button29
	Ongame_Call = Button28
	Ongame_Check = Button27
	Ongame_Raise = Button30
	Ongame_Bet = Button26
	Ongame_CheckBox = Button47
	Ongame_FoldBox = Button46
	Ongame_CallBox = Button48
	Ongame_CallAnyBox = Button49
	Ongame_RaiseBox = Button50
	Ongame_RaiseAnyBox = Button51

	Ongame_BetAmount = RichEdit20W3
	Ongame_Bet = AfxWnd70u53
	Ongame_Pot = AfxWnd70u54
	Ongame_Cost = AfxWnd70u58
	
	
	SetClientHotkeys("Ongame")
	GroupAdd, GameWindows, \$ ahk_class AfxFrameOrView70u
	return true
}

Ongame_OpenPreferences() {
	local gameplay := "AfxWnd70u3"
	WinMenuSelectItem, %Ongame_LobbyWindow%, , Options, Preferences
	if ErrorLevel
		return false
	WinWaitActive, Preference ahk_class AfxFrameOrView70u, , 5
	if ErrorLevel
		return false
	ClickControl(gameplay)
	return true
}

Ongame_Bet(bet = "") {
	global
	ControlFocus, %Ongame_BetAmount%
	if (Ongame_Decimal && bet)
		StringReplace, bet, bet, ., % Ongame_Decimal
	Bet(bet)
}


Ongame_ToggleAutoMuck() {
	local mucklosing := "Button21", muckuncalled := "Button22"
	Ongame_OpenPreferences()
	ClickControl(mucklosing)
	ClickControl(muckuncalled)
	ClickControl(Ongame_OK)
}

Ongame_LastHand() {
	local x, y, w, h
	WinGetPos, x, y, w, h
	x += w - Border - 140
	y += Caption + Border + 5
	h := 10
	w := 130
	ClickWindowRect(x, y, w, h)
}

Ongame_CurrencyToFloat(amount) {
	local s := InStr(amount, A_Space) + 1
	amount := SubStr(amount, s)
	return CurrencyToFloat(amount, Ongame_Currency, Ongame_Separator, Ongame_Decimal)
}


Ongame_BetRelativePot(factor) {
	local pot
	if !IsControlVisible(Ongame_BetAmount)
		return
	ControlGetText, pot, % Ongame_Pot
	pot := Ongame_CurrencyToFloat(pot)
	local cost := 0
	if IsControlVisible(Ongame_Cost) {
		ControlGetText, cost, %Ongame_Cost%
		cost := Ongame_CurrencyToFloat(cost)
	}
	pot += cost
	pot *= factor
	pot += cost
	pot := GetRoundedAmount(pot, Ongame_GetRound(Rounding, Rounding))
	Ongame_Bet(pot)
}

Ongame_FixedBet(factor) {
	local b
	if !IsControlVisible(Ongame_BetAmount)
		return
	local bet := factor * Ongame_GetBlind(true)
	ControlGetText, b, % Ongame_Bet
	local c := 0
	if IsControlVisible(Ongame_Cost) {
		ControlGetText, c, % Ongame_Cost
		c := Ongame_CurrencyToFloat(c)
	}
	bet -= b - c
	Ongame_Bet(bet)
	Sleep, 400
	Send, {F3}
}

Ongame_GetRound(rounding, default) {
	if (rounding < -1) {
		return Ongame_GetBlind(rounding+2)
	}
	return default
}

Ongame_SitInAll(in) {
	local windows, id, x, y, w, h
	WinGet windows, List, %Ongame_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlVisible(Ongame_SitIn, id) == in)
			ClickControl(in ? Ongame_SitIn : Ongame_SitOut, id)
	}
}

Ongame_AutoPostAll(on) {
	local autopost := "Button20"
	if !Ongame_OpenPreferences()
		return
	if (IsControlChecked(autopost) != on)
		ClickControl(autopost)
	ClickControl(Ongame_OK)
}

Ongame_ToggleAutoPost() {
	static autopost := "Button21"
	sitin := Ongame_SitOut()
	Sleep, 100
	ClickControl(autopost)
	Sleep, 100
	if sitin
		Ongame_SitIn()
}


Ongame_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (IsControlVisible(Ongame_SitOut, id))
			ClickControl(Ongame_SitOut, id)
		WinClose, ahk_id %id%
	}
}


Ongame_AllInQueue:
	Ongame_AllInQueue()
	return
	
Ongame_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, Ongame_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(Ongame_Call, id)
			visible := 1
		if IsControlVisible(Ongame_Raise, id)
			visible := 2
		if IsControlVisible(Ongame_BetAmount, id) {
			WinActivate, ahk_id %id%
			WinWaitActive, ahk_id %id%, , 1
			if ErrorLevel
				continue
			Ongame_Bet(999999)
			Notify("Raise", id)
			Send, {F3}{F3}
		} else if visible {
			WinActivate, ahk_id %id%
			WinWaitActive, ahk_id %id%, , 1
			if (visible == 1) {
				Notify("Call", id)
				Send, {F2}
			} else {
				Notify("Raise", id)
				Send, {F3}
			}
		} else
			continue
		ListRemove(Ongame_AllInQueue, A_Index-1)
	}
	if !Ongame_AllInQueue
		SetTimer, Ongame_AllInQueue, Off
	Critical, Off
}


Ongame_Activate:
	WinActivate, %Ongame_GameWindow%
	return
Ongame_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
Ongame_FoldAny:
Ongame_Fold:
	if IsControlVisible(Ongame_Check)
		Send, {F2}
	else if IsControlVisible(Ongame_Fold)
		Send, {F1}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_CheckBox) && IsControlEnabled(Ongame_CheckBox)))
		Send, {F2} ;	ClickControl(Ongame_CheckBox)
	else if (IsControlVisible(Ongame_FoldBox) && IsControlEnabled(Ongame_FoldBox))
		Send, {F1} ;	ClickControl(Ongame_FoldBox)
	return
Ongame_Call:
	if (IsControlVisible(Ongame_Check) || IsControlVisible(Ongame_Call))
		Send, {F2}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_CallBox) && IsControlEnabled(Ongame_CallBox)))
		Send, {F2} ;	ClickControl(Ongame_CallBox)
	else if (IsControlVisible(Ongame_CallAnyBox) && IsControlEnabled(Ongame_CallAnyBox))
		ClickControl(Ongame_CallAnyBox)
	return
Ongame_Raise:
	if (IsControlVisible(Ongame_Raise) || IsControlVisible(Ongame_Bet))
		Send, {F3}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_RaiseBox) && IsControlEnabled(Ongame_RaiseBox)))
		ClickControl(Ongame_RaiseBox)
	else if (IsControlVisible(Ongame_RaiseAnyBox) && IsControlEnabled(Ongame_RaiseAnyBox))
		ClickControl(Ongame_RaiseAnyBox)
	return
Ongame_Relative1:
	Ongame_BetRelativePot(Relative1)
	return
Ongame_Relative2:
	Ongame_BetRelativePot(Relative2)
	return
Ongame_Relative3:
	Ongame_BetRelativePot(Relative3)
	return
Ongame_Relative4:
	Ongame_BetRelativePot(Relative4)
	return
Ongame_Relative5:
	Ongame_BetRelativePot(Relative5)
	return
Ongame_Relative6:
	Ongame_BetRelativePot(Relative6)
	return
Ongame_Relative7:
	Ongame_BetRelativePot(Relative7)
	return
Ongame_Relative8:
	Ongame_BetRelativePot(Relative8)
	return
Ongame_Relative9:
	Ongame_BetRelativePot(Relative9)
	return
Ongame_RandomBet:
	Ongame_BetRelativePot(GetRandomBet())
	return
Ongame_Fixed1:
	Ongame_FixedBet(Fixed1)
	return
Ongame_Fixed2:
	Ongame_FixedBet(Fixed2)
	return
Ongame_Fixed3:
	Ongame_FixedBet(Fixed3)
	return
Ongame_Fixed4:
	Ongame_FixedBet(Fixed4)
	return
Ongame_Fixed5:
	Ongame_FixedBet(Fixed5)
	return
Ongame_Fixed6:
	Ongame_FixedBet(Fixed6)
	return
Ongame_Fixed7:
	Ongame_FixedBet(Fixed7)
	return
Ongame_Fixed8:
	Ongame_FixedBet(Fixed8)
	return
Ongame_Fixed9:
	Ongame_FixedBet(Fixed9)
	return
Ongame_AllIn:
	Ongame_Bet(999999)
	return
Ongame_LastHand:
	Ongame_LastHand()
	return
Ongame_IncreaseBet:
Ongame_IncreaseBet2:
	ControlFocus, %Ongame_BetAmount%
	Send, {Up}
	return
Ongame_DecreaseBet:
Ongame_DecreaseBet2:
	ControlFocus, %Ongame_BetAmount%
	Send, {Down}
	return
Ongame_AutoPost:
	Ongame_ToggleAutoPost()
	return
Ongame_ToggleAutoMuck:
	Ongame_ToggleAutoMuck()
	return
Ongame_AllInThisHand:
	AddCurrentIDToQueue("Ongame_AllInQueue", 5000)
	return
Ongame_Reload:
	Ongame_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
Ongame_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %Ongame_LobbyWindow%
	else
		ClickControl(Ongame_Lobby)
	return
Ongame_SitOut:
	ClickControl(Ongame_SitOut)
	return
Ongame_ClearBetBox:
	Send, {Enter}
	return
	
















	
; ( [] )..( [] )   Cake Poker Implementation   ( [] )..( [] ) 

#Include Includes\CakePoker.ahk

CakePoker() {
	local theme
	
	IniRead, theme, PokerPad.ini, CakePoker, Theme, %A_Space%
	if !theme
		return false
	if !ReadColor(theme, "CakePoker", "Background")
		return false
	if !ReadColor(theme, "CakePoker", "ButtonColor")
		return false
		
	CakePoker_Fold = 420 438 100 28
	CakePoker_Call = 544 438 100 28
	CakePoker_Raise = 670 438 100 28
	
	CakePoker_FoldBox = 424 490 100 18
	CakePoker_FoldAny = 424 524 100 18
	CakePoker_CallBox = 550 490 100 18
	CakePoker_CallAny = 550 524 100 18
	CakePoker_RaiseBox = 676 490 100 18
	CakePoker_RaiseAny = 676 524 100 18
	
	CakePoker_SitOut = 774 340 7 7
	CakePoker_AutoMuck = 774 368 7 7
	CakePoker_AutoPost = 774 402 7 7
	
	CakePoker_Pot = 615 481 30 10
	CakePoker_AllIn = 666 481 30 10
	CakePoker_LastHand = 9 22 40 10
	
	CakePoker_StandUp = 682 5 40 10
	CakePoker_Lobby = 740 24 40 10

	CakePoker_BetAmount = TTntEdit.UnicodeClass1
	
	CakePoker_GameWindow = ahk_class TfrmTable\.UnicodeClass
	SiteTfrmTableUnicodeClass = CakePoker
	CakePoker_LobbyWindow = ahk_class TfrmMainLobby\.UnicodeClass
	CakePoker_LastHandWindow = ahk_class TfrmWebBrowse
	SetClientHotkeys("CakePoker")
	GroupAdd, GameWindows, ahk_class TfrmTable\.UnicodeClass
	return true
}

CakePoker_ClickButton(button) {
	local x, y, w, h, bgr, area
	area := CakePoker_%button%
	GetWindowArea(x, y, w, h, area, false)
	PixelGetColor, bgr, x, y
	if !Display_CompareColors(bgr, CakePoker_Background, CakePoker_BackgroundVariation) {
		ClickWindowRect(x, y, w, h)
		return
	}
	if !InStr(A_ThisHotkey, "^") {
		area := CakePoker_%button%Box
		GetWindowArea(x, y, w, h, area, false)
		PixelGetColor, bgr, x, y
		if Display_CompareColors(bgr, CakePoker_ButtonColor, CakePoker_ButtonColorVariation) {
			ClickWindowRect(x, y, w, h)
			return
		}
	}
	area := CakePoker_%button%Any
	GetWindowArea(x, y, w, h, area, false)
	PixelGetColor, bgr, x, y
	if Display_CompareColors(bgr, CakePoker_ButtonColor, CakePoker_ButtonColorVariation)
		ClickWindowRect(x, y, w, h)
}


CakePoker_BetRelativePot(factor) {
	global
	if !IsControlVisible(CakePoker_BetAmount)
		return
	ControlSetText, %CakePoker_BetAmount%
	local x, y, w, h
	GetWindowArea(x, y, w, h, CakePoker_Raise, false)
	y += 16
	h := 12
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, 0xFFFFFF, 16, c))
	ClickWindowArea(CakePoker_Pot, false)
	Sleep, 20
	GetWindowArea(x, y, w, h, CakePoker_Call, false)
	y += 16
	h := 12
	local call := CurrencyToFloat(Display_ReadArea(x, y, w, h, 0xFFFFFF, 16, c))
	Display_DeleteWindowCapture(device, context, pixels)
	local pot
	ControlGetText, pot, % CakePoker_BetAmount
	local blind := CakePoker_GetBlind(true)
	GetPot(pot, call, raise, blind)
	ControlSetText, % CakePoker_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, blind), CakePoker_GetRound(Rounding, Rounding))
}
	
CakePoker_FixedBet(factor) {
	global
	if !IsControlVisible(CakePoker_BetAmount)
		return
	ControlSetText, % CakePoker_BetAmount, % GetDollarRound(factor * CakePoker_GetBlind(true))
	Sleep, 400
	CakePoker_ClickButton("Raise")
}

CakePoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsChecked(CakePoker_SitOut, false, 0x000000, id)) {
			ClickWindowArea(CakePoker_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

CakePoker_SitInAll(in = true) {
	global
	CakePoker_CheckAll(CakePoker_SitOut, !in)
}

CakePoker_AutoPostAll(on) {
	global
	CakePoker_CheckAll(CakePoker_AutoPost, on)
}

CakePoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %CakePoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, 0x000000, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}

CakePoker_GetRound(rounding, default) {
	if (rounding < -1) 
		return CakePoker_GetBlind(rounding+2)
	return default
}

CakePoker_Activate:
	WinActivate, %CakePoker_GameWindow%
	return
CakePoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
CakePoker_Fold:
	CakePoker_ClickButton("Fold")
	return
CakePoker_Call:
	CakePoker_ClickButton("Call")
	return
CakePoker_Raise:
	CakePoker_ClickButton("Raise")
	return
CakePoker_Relative1:
	CakePoker_BetRelativePot(Relative1)
	return
CakePoker_Relative2:
	CakePoker_BetRelativePot(Relative2)
	return
CakePoker_Relative3:
	CakePoker_BetRelativePot(Relative3)
	return
CakePoker_Relative4:
	CakePoker_BetRelativePot(Relative4)
	return
CakePoker_Relative5:
	CakePoker_BetRelativePot(Relative5)
	return
CakePoker_Relative6:
	CakePoker_BetRelativePot(Relative6)
	return
CakePoker_Relative7:
	CakePoker_BetRelativePot(Relative7)
	return
CakePoker_Relative8:
	CakePoker_BetRelativePot(Relative8)
	return
CakePoker_Relative9:
	CakePoker_BetRelativePot(Relative9)
	return
CakePoker_RandomBet:
	CakePoker_BetRelativePot(GetRandomBet())
	return
CakePoker_Fixed1:
	CakePoker_FixedBet(Fixed1)
	return
CakePoker_Fixed2:
	CakePoker_FixedBet(Fixed2)
	return
CakePoker_Fixed3:
	CakePoker_FixedBet(Fixed3)
	return
CakePoker_Fixed4:
	CakePoker_FixedBet(Fixed4)
	return
CakePoker_Fixed5:
	CakePoker_FixedBet(Fixed5)
	return
CakePoker_Fixed6:
	CakePoker_FixedBet(Fixed6)
	return
CakePoker_Fixed7:
	CakePoker_FixedBet(Fixed7)
	return
CakePoker_Fixed8:
	CakePoker_FixedBet(Fixed8)
	return
CakePoker_Fixed9:
	CakePoker_FixedBet(Fixed9)
	return
CakePoker_AllIn:
	ClickWindowArea(CakePoker_AllIn, false)
	return
CakePoker_LastHand:
	ClickWindowArea(CakePoker_LastHand, false)
	return
CakePoker_IncreaseBet:
	ControlIncreaseAmount(CakePoker_BetAmount, CakePoker_GetRound(Increment, 0))
	return
CakePoker_DecreaseBet:
	ControlDecreaseAmount(CakePoker_BetAmount, CakePoker_GetRound(Incrmenet, 0))
	return
CakePoker_IncreaseBet2:
	ControlIncreaseAmount(CakePoker_BetAmount, CakePoker_GetRound(Increment2, 0))
	return
CakePoker_DecreaseBet2:
	ControlDecreaseAmount(CakePoker_BetAmount, CakePoker_GetRound(Incrmenet2, 0))
	return
CakePoker_FoldAny:
	ClickWindowArea(CakePoker_FoldAny, false)
	return
CakePoker_AutoPost:
	ClickWindowArea(CakePoker_AutoPost, false)
	return
CakePoker_ToggleAutoMuck:
	ClickWindowArea(CakePoker_AutoMuck, false)
	return
CakePoker_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for Cake Poker.
	return
CakePoker_Reload:
	CakePoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
CakePoker_Lobby:
	WinActivate, %CakePoker_LobbyWindow%
	return
CakePoker_SitOut:
	ClickWindowArea(CakePoker_SitOut, false)
	return







; ( [] )..( [] )   Microgaming Implementation   ( [] )..( [] ) 

#Include Includes\Microgaming.ahk

Microgaming() {
	local theme
	IniRead, theme, PokerPad.ini, Microgaming, Theme, %A_Space%
	if !theme
		return false
	if !ReadColor(theme, "Microgaming", "BoxColor")
		return false
	if !ReadColor(theme, "Microgaming", "ActionColor")
		return false
	if !ReadColor(theme, "Microgaming", "ButtonColor")
		return false
		
	Microgaming_MiniAutoMuck = 9 9 100 10
	Microgaming_MiniAutoPost = 173 9 100 10
	Microgaming_MiniSitOut = 337 9 100 10
	Microgaming_MiniMenu = 9 307 40 11
	Microgaming_MiniLobby = 9 345 40 11
	Microgaming_MiniCheck = 100 332 70 22
	Microgaming_MiniCall = 204 332 70 22
	Microgaming_MiniRaise = 308 332 70 22
	Microgaming_MiniFold = 412 332 70 22
	Microgaming_MiniBetBox = 256 296 100 10
	Microgaming_MiniPot = 424 147 70 11
	Microgaming_MiniFoldBox = 81 310 90 12
	Microgaming_MiniCheckBox = 81 328 90 12
	Microgaming_MiniCallAny = 189 310 90 12
	Microgaming_MiniCallBox = 189 328 90 12
	Microgaming_MiniBetCallBox = 297 310 90 12
	Microgaming_MiniRaiseAny = 297 328 90 12
	Microgaming_MiniRaiseBox = 297 346 90 12
	Microgaming_MiniFoldAny = 405 310 90 12
	Microgaming_MiniAllIn = 472 279 30 10
	
	Microgaming_SitOut = 3 493 100 9
	Microgaming_AutoPost = 3 521 100 9
	Microgaming_MuckWin = 3 507 100 9
	Microgaming_MuckLose = 3 535 100 9
	Microgaming_Lobby = 5 555 40 11
	Microgaming_Menu = 5 467 40 11
	Microgaming_Pot = 694 471 85 10
	Microgaming_Check = 587 496 80 22
	Microgaming_Fold = 693 496 80 22
	Microgaming_Call = 587 540 80 22
	Microgaming_Raise = 693 540 80 22
	Microgaming_FoldBox = 572 486 100 12
	Microgaming_FoldAny = 684 486 100 12
	Microgaming_CallBox = 572 559 100 12
	Microgaming_CallAny = 572 541 100 12
	Microgaming_RaiseBox = 684 559 100 12
	Microgaming_RaisAny = 684 541 100 12
	Microgaming_AllIn = 758 414 30 10

	Microgaming_BetAmount = Edit1
	
	Microgaming_GameWindow = ahk_class POPUP_INT_DLG_WINDOW
	Microgaming_LobbyWindow = ahk_class GFX_INT_DLG_WINDOW_MAIN_PrimaPokerNetwork
	SitePOPUP_INT_DLG_WINDOW = Microgaming
	SetClientHotkeys("Microgaming")
	GroupAdd, GameWindows, ahk_class POPUP_INT_DLG_WINDOW
}


Microgaming_ClickButton(button) {
	local x, y, w, h, bgr, v := 0, isMini := Microgaming_IsMiniWindow()
	if !InStr(A_ThisHotkey, "^") {
		if isMini
			Microgaming_GetArea(x, y, w, h, Microgaming_Mini%button%Box)
		else
			GetWindowArea(x, y, w, h, Microgaming_%button%Box, false)
		PixelGetColor, bgr, x-1, y-1
		if Display_CompareColors(bgr, Microgaming_BoxColor, v) {
			ClickWindowRect(x, y, w, h)
			return
		}
	}
	if isMini
		Microgaming_GetArea(x, y, w, h, Microgaming_Mini%button%Any)
	else
		GetWindowArea(x, y, w, h, Microgaming_%button%Any, false)
	PixelGetColor, bgr, x-1, y-1
	if Display_CompareColors(bgr, Microgaming_BoxColor, v) {
		ClickWindowRect(x, y, w, h)
		return
	}
	if (button == "Fold" || button == "Call") {
		if isMini
			Microgaming_GetArea(x, y, w, h, Microgaming_MiniCheck)
		else
			GetWindowArea(x, y, w, h, Microgaming_Check, false)
		PixelGetColor, bgr, x, y
		if Display_CompareColors(bgr, Microgaming_ButtonColor, Microgaming_ButtonColorVariation)
			button = Check
	}
	if isMini {
		Microgaming_ClickArea(Microgaming_Mini%button%)
	} else
		ClickWindowArea(Microgaming_%button%, false)
}

Microgaming_BetRelativePot(factor) {
	local x, y, w, h, v := 0, isMini := Microgaming_IsMiniWindow()
	if isMini
		Microgaming_GetArea(x, y, w, h, Microgaming_MiniPot)
	else 
		GetWindowArea(x, y, w, h, Microgaming_Pot, false)
	local pot := CurrencyToFloat(Display_ReadArea(x, y, w, h, Microgaming_PotColor))
	if isMini
		Microgaming_GetArea(x, y, w, h, Microgaming_MiniCall)
	else 
		GetWindowArea(x, y, w, h, Microgaming_Call, false)
	PixelSearch, , , x, y+2, x+w, y+3, Microgaming_ActionColor
	local call := 0
	if !ErrorLevel {
		h := Floor(h/2)
		y += h
		call := CurrencyToFloat(Display_ReadArea(x, y, w, h, Microgaming_ActionColor))
	}
	if isMini {
		Microgaming_GetArea(x, y, w, h, Microgaming_MiniRaise)
		Microgaming_ClickArea(Microgaming_MiniPot)
	} else {
		GetWindowArea(x, y, w, h, Microgaming_Raise, false)
		ClickWindowArea(Microgaming_Pot)
	}
	h := Floor(h/2)
	y += h
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, Microgaming_ActionColor))
	ControlSetText, % Microgaming_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, Microgaming_GetBlind(true)), Microgaming_GetRound(Rounding, Rounding))
}

Microgaming_FixedBet(factor) {
	ControlSetText, % Microgaming_BetAmount, % GetDollarRound(factor * Microgaming_GetBlind(true))
	Sleep, 500
	if Microgaming_IsMiniWindow() {
		Microgaming_ClickArea(Microgaming_MiniRaise)
	} else
		ClickWindowArea(Microgaming_Raise, false)
}

Microgaming_GetRound(rounding, default) {
	if (rounding < -1)
		return Microgaming_GetBlind(rounding+2)
	return default
}

Microgaming_IsChecked(ByRef area, color, ByRef id = "") {
	Microgaming_GetArea(x, y, w, h, area)
	return Display_PixelSearch(x, y, h, h, color, 16, id)
}

Microgaming_CheckAll(checkbox, checked) {
	local windows, id
	WinGet windows, List, %Microgaming_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if !WinExist("ahk_id " . id)
			continue
		if Microgaming_IsMiniWindow() {
			local box := Microgaming_Mini%checkbox%
			if (Microgaming_IsChecked(box, 0x000000, id) != checked)
				Microgaming_ClickArea(box, id)
		} else {
			local box := Microgaming_%checkbox%
			if (IsChecked(box, false, 0x000000, id) != checked)
				ClickWindowArea(box, false, id)
		}
	}
}

Microgaming_AutoPostAll(on) {
	Microgaming_CheckAll("AutoPost", on)
}

Microgaming_SitInAll(in) {
	Microgaming_CheckAll("SitOut", !in)
}

Microgaming_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if !WinExist("ahk_id " . id)
			continue
		if Microgaming_IsMiniWindow() {
			if (!Microgaming_IsChecked(Microgaming_MiniSitOut, 0x000000, id))
				Microgaming_ClickArea(Microgaming_MiniSitOut, id)
		} else {
			if (!IsChecked(Microgaming_SitOut, false, 0x000000, id))
				ClickWindowArea(Microgaming_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}


Microgaming_Activate:
	WinActivate, %Microgaming_GameWindow%
	return
Microgaming_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
Microgaming_Fold:
	Microgaming_ClickButton("Fold")
	return
Microgaming_Call:
	Microgaming_ClickButton("Call")
	return
Microgaming_Raise:
	Microgaming_ClickButton("Raise")
	return
Microgaming_Relative1:
	Microgaming_BetRelativePot(Relative1)
	return
Microgaming_Relative2:
	Microgaming_BetRelativePot(Relative2)
	return
Microgaming_Relative3:
	Microgaming_BetRelativePot(Relative3)
	return
Microgaming_Relative4:
	Microgaming_BetRelativePot(Relative4)
	return
Microgaming_Relative5:
	Microgaming_BetRelativePot(Relative5)
	return
Microgaming_Relative6:
	Microgaming_BetRelativePot(Relative6)
	return
Microgaming_Relative7:
	Microgaming_BetRelativePot(Relative7)
	return
Microgaming_Relative8:
	Microgaming_BetRelativePot(Relative8)
	return
Microgaming_Relative9:
	Microgaming_BetRelativePot(Relative9)
	return
Microgaming_RandomBet:
	Microgaming_BetRelativePot(GetRandomBet())
	return
Microgaming_Fixed1:
	Microgaming_FixedBet(Fixed1)
	return
Microgaming_Fixed2:
	Microgaming_FixedBet(Fixed2)
	return
Microgaming_Fixed3:
	Microgaming_FixedBet(Fixed3)
	return
Microgaming_Fixed4:
	Microgaming_FixedBet(Fixed4)
	return
Microgaming_Fixed5:
	Microgaming_FixedBet(Fixed5)
	return
Microgaming_Fixed6:
	Microgaming_FixedBet(Fixed6)
	return
Microgaming_Fixed7:
	Microgaming_FixedBet(Fixed7)
	return
Microgaming_Fixed8:
	Microgaming_FixedBet(Fixed8)
	return
Microgaming_Fixed9:
	Microgaming_FixedBet(Fixed9)
	return
Microgaming_AllIn:
	if Microgaming_IsMiniWindow() {
		Microgaming_ClickArea(Microgaming_MiniAllIn)
	} else {
		ClickWindowArea(Microgaming_AllIn, false)
	}
	return
Microgaming_LastHand:
	return
Microgaming_IncreaseBet:
	ControlIncreaseAmount(Microgaming_BetAmount, Microgaming_GetRound(Increment, 0))
	return
Microgaming_DecreaseBet:
	ControlDecreaseAmount(Microgaming_BetAmount, Microgaming_GetRound(Incrmenet, 0))
	return
Microgaming_IncreaseBet2:
	ControlIncreaseAmount(Microgaming_BetAmount, Microgaming_GetRound(Increment2, 0))
	return
Microgaming_DecreaseBet2:
	ControlDecreaseAmount(Microgaming_BetAmount, Microgaming_GetRound(Incrmenet2, 0))
	return
Microgaming_FoldAny:
	if Microgaming_IsMiniWindow()
		Microgaming_ClickArea(Microgaming_MiniFoldAny)
	else
		ClickWindowArea(Microgaming_FoldAny, false)
	return
Microgaming_AutoPost:
	if Microgaming_IsMiniWindow()
		Microgaming_ClickArea(Microgaming_MiniAutoPost)
	else
		ClickWindowArea(Microgaming_AutoPost, false)
	return
Microgaming_ToggleAutoMuck:
	if Microgaming_IsMiniWindow()
		Microgaming_ClickArea(Microgaming_MiniAutoMuck)
	else
		ClickWindowArea(Microgaming_AutoMuck, false)
	return
Microgaming_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for Microgaming.
	return
Microgaming_Reload:
	Microgaming_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
Microgaming_Lobby:
	WinActivate, %Microgaming_LobbyWindow%
	return
Microgaming_SitOut:
	if Microgaming_IsMiniWindow()
		Microgaming_ClickArea(Microgaming_MiniSitOut)
	else
		ClickWindowArea(Microgaming_SitOut, false)
	return







;%
; ( [] )..( [] )   Pacific Implementation   ( [] )..( [] ) 

#Include Includes\Pacific.ahk

Pacific() {
	global
	; All boxes assumes a window dimension of 800x579
	Pacific_Fold = 335 475 135 12
	Pacific_CheckFold = 335 510 135 10
	Pacific_Call = 490 475 135 12
	Pacific_Raise = 645 475 135 12
	Pacific_FoldAny = 643 559 5 5
	
	Pacific_AutoPost = 486 558 5 5
	Pacific_SitOut = 332 558 5 5
	
	Pacific_AutoMuck = 
	Pacific_Lobby = 662 58 120 12
	;Pacific_LastHand = 
	;Pacific_Options =
	;Pacific_Settings
	Pacific_TimeBank = 680 430 105 10
	Pacific_Chat = 16 551 155 12
	
	Pacific_IncreaseBet = 700 535 5 5
	Pacific_DecreaseBet = 495 535 5 5
	
	Pacific_Pot = 661 511 45 5
	Pacific_BetBox = 720 532 55 12
	
	Pacific_GameWindow = / ahk_class #32770
	Pacific_LobbyWindow = Lobby ahk_class #32770
	Pacific_LastHandWindow = ^Instant Replay ahk_class DxWndClass
	; Same as Party :(
	;Site#32770 = Pacific
	SetClientHotkeys("Pacific")
	GroupAdd, GameWindows, / ahk_class #32770
	SetTimer Pacific_AutoTimeBank, 4000
}

Pacific_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, pot2

	box := Pacific_AdjustSize(Pacific_Pot)
	
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	Sleep, 200
	;select and copy
	Pacific_AdjustClick(722, 537)
	Send, {Home}+{End}^c
	pot := Clipboard
/*	local title
	WinGetTitle, title
	FileAppend
	(
	%title% - %A_Hour%:%A_Min%:%A_Sec% - %pot%
	
	),log.txt
*/
	return (factor * pot)
}
	
Pacific_CheckBet(bet) {
	Pacific_AdjustClick(722, 537)
	Send, {Home}+{End}^c
	if (Clipboard == bet)
		return 1
	else
		return 0
}
	
Pacific_Bet(ByRef betbox, bet = "") {
	Pacific_AdjustClick(722, 537)
	Send, {Home}+{End}
	Bet(bet)
}

Pacific_BetRelativePot(factor) {
	local box, pot, round := Pacific_GetRound(Rounding, Rounding)
	bet := GetRoundedAmount(Pacific_GetPot(factor), round)
	Bet(bet)
	if (GetHotKey("Rtick") && Pacific_CheckBet(bet)) {
		Pacific_ClickButton("Raise")
	}
}

Pacific_FixedBet(factor) {
	local pot
	pot := GetAmount(GetDollarRound(factor * Pacific_GetBlind(true)), Pacific_Decimal)
	Pacific_Bet(Pacific_BetBox, pot)
	if (GetHotKey("Ftick") && Pacific_CheckBet(pot)) {
		Pacific_ClickButton("Raise")
	}
}


Pacific_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (!IsChecked(Pacific_SitOut, false, Pacific_CheckColor, id)) {
			ClickWindowArea(Pacific_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

Pacific_SitInAll(in) {
	global
	if !WinExist(Pacific_GameWindow)
		return
	Pacific_CheckAll(Pacific_SitOut, !in)
}

Pacific_AutoPostAll(on) {
	global
	if !WinExist(Pacific_GameWindow)
		return
	Pacific_CheckAll(Pacific_AutoPost, on)
}

Pacific_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %Pacific_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, Pacific_CheckColor, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}


Pacific_GetRound(rounding, default) {
	if (rounding < -1)
		return Pacific_GetBlind(rounding+2)
	return default
}

Pacific_AdjustSize(box, id = "") {
	local box0, box1, box2, box3, box4, w, h
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
		
	w /= 800.0
	h /= 579.0
	StringSplit, box, box, %A_Space%
	box1 *= w
	box2 *= h
	box3 *= w
	box4 *= h
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}

;%

;AdjustClick clicks to the area of the screen indicated by x and y
;with mouse button c (c=0 moves without click) 
Pacific_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w /= 800.0
	h /= 579.0
	x := Round(x * w)
	y := Round(y * h)
	MouseGetPos, px, py
	Click %x% %y% %c%
	Click %px% %py% 0
}

Pacific_ClickButton(button, id = "") {
	local x, y, w, h, box
	button := Pacific_%button%
;MsgBox % "Before: " . button .  " After: " . Pacific_AdjustSize(button)
	box := Pacific_AdjustSize(button, id)
	GetWindowArea(x, y, w, h, box, false, id)
;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	ClickWindowRect(x, y, w, h, id)	
}


Pacific_IsChecked(ByRef checkbox, ByRef x = "", ByRef y = "", ByRef w = "", ByRef h = "") {
	GetWindowArea(x, y, w, h, checkbox, true)
	Display_CreateWindowCapture(device, context, pixels, id)
	bgr := Display_GetPixel(context, x + w, y + 1)
	Display_DeleteWindowCapture(device, context, pixels, id)
	return Display_IsRed(bgr)
}




Pacific_Activate:
	WinActivate, %Pacific_GameWindow%
	return
Pacific_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
Pacific_Fold:
	Pacific_ClickButton("Fold")
	Pacific_ClickButton("CheckFold")
	return
Pacific_Call:
	Pacific_ClickButton("Call")
	return
Pacific_Raise:
	Pacific_ClickButton("Raise")
	return
Pacific_Relative1:
	Pacific_BetRelativePot(Relative1)
	return
Pacific_Relative2:
	Pacific_BetRelativePot(Relative2)
	return
Pacific_Relative3:
	Pacific_BetRelativePot(Relative3)
	return
Pacific_Relative4:
	Pacific_BetRelativePot(Relative4)
	return
Pacific_Relative5:
	Pacific_BetRelativePot(Relative5)
	return
Pacific_Relative6:
	Pacific_BetRelativePot(Relative6)
	return
Pacific_Relative7:
	Pacific_BetRelativePot(Relative7)
	return
Pacific_Relative8:
	Pacific_BetRelativePot(Relative8)
	return
Pacific_Relative9:
	Pacific_BetRelativePot(Relative9)
	return
Pacific_RandomBet:
	Pacific_BetRelativePot(GetRandomBet())
	return
Pacific_Fixed1:
	Pacific_FixedBet(Fixed1)
	return
Pacific_Fixed2:
	Pacific_FixedBet(Fixed2)
	return
Pacific_Fixed3:
	Pacific_FixedBet(Fixed3)
	return
Pacific_Fixed4:
	Pacific_FixedBet(Fixed4)
	return
Pacific_Fixed5:
	Pacific_FixedBet(Fixed5)
	return
Pacific_Fixed6:
	Pacific_FixedBet(Fixed6)
	return
Pacific_Fixed7:
	Pacific_FixedBet(Fixed7)
	return
Pacific_Fixed8:
	Pacific_FixedBet(Fixed8)
	return
Pacific_Fixed9:
	Pacific_FixedBet(Fixed9)
	return
Pacific_AllIn:
	Send, {F8}
	return
Pacific_LastHand:
	ClickWindowArea2(Pacific_LastHand)
	return
Pacific_IncreaseBet:
Pacific_IncreaseBet2:
	Pacific_ClickButton("IncreaseBet")
	return
Pacific_DecreaseBet:
Pacific_DecreaseBet2:
	Pacific_ClickButton("DecreaseBet")
	return
Pacific_FoldAny:
	ClickWindowArea2(Pacific_FoldAny)
	return
Pacific_AutoPost:
	ClickWindowArea2(Pacific_AutoPost)
	return
Pacific_ToggleAutoMuck:
	ClickWindowArea2(Pacific_AutoMuck)
	return
Pacific_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for Pacific.
	return
Pacific_Reload:
	; do nothing
	return
Pacific_Lobby:
	ClickWindowArea2(Pacific_Lobby)
	return
Pacific_SitOut:
	ClickWindowArea2(Pacific_SitOut)
	return
Pacific_AutoTimeBank:
	WinGet Wnd, List, / ahk_class #32770,,` -` ,
	Loop, %Wnd% {
		id := Wnd%A_Index%
		Display_CreateWindowCapture(device, context, pixels, id)
		if (Pacific_CheckTimeBank(id, context)) {
			Pacific_ClickButton("TimeBank", id)
		}
		Display_DeleteWindowCapture(device, context, pixels, id)
		ControlGet,visible,Visible,,,ahk_id %id%
		if visible
			DllCall("RedrawWindow","UInt",id,"UInt",0,"UInt",0,"UInt", 1|4|64|1024)
	}
	return
	

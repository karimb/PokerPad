/*  PokerPad v0.1.34 by Xander and al.
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
;SendMode Event
SetControlDelay, -1
SetKeyDelay, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
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
/*
if FullTilt_GameWindow
	Menu, Open, Add, Full Tilt Poker, FullTilt
*/
if PokerStars_GameWindow
	Menu, Open, Add, Poker Stars, PokerStars
if IPoker_GameWindow
	Menu, Open, Add, iPoker, IPoker
if PartyPoker_GameWindow
	Menu, Open, Add, Party Poker, PartyPoker
/*
if EverestPoker_GameWindow
	Menu, Open, Add, Everest Poker, EverestPoker
if Ongame_GameWindow
	Menu, Open, Add, Ongame, Ongame
if CakePoker_GameWindow
	Menu, Open, Add, Cake Poker, CakePoker
if Microgaming_GameWindow
	Menu, Open, Add, Microgaming, Microgaming
*/
if Pacific_GameWindow
	Menu, Open, Add, Pacific, Pacific
if SkyPoker_GameWindow
	Menu, Open, Add, Sky Poker, SkyPoker
if SwCPoker_GameWindow
	Menu, Open, Add, SwC Poker, SwCPoker
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
;FullTilt:
PokerStars:
IPoker:
PartyPoker:
/*
EverestPoker:
Ongame:
CakePoker:
Microgaming:
*/
Pacific:
SkyPoker:
SwCPoker:
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
	/*
	IniRead, load, PokerPad.ini, General, FullTilt, 1
	if load
		FullTilt()
	*/
	IniRead, load, PokerPad.ini, General, PokerStars, 1
	if load
		PokerStars()
	IniRead, load, PokerPad.ini, General, IPoker, 1
	if load
		IPoker()
	IniRead, load, PokerPad.ini, General, PartyPoker, 1
	if load
		PartyPoker()
	/*
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
	*/
	IniRead, load, PokerPad.ini, General, Pacific, 1
	if load
		Pacific()
	IniRead, load, PokerPad.ini, General, SkyPoker, 1
	if load
		SkyPoker()
	IniRead, load, PokerPad.ini, General, SwCPoker, 1
	if load
		SwCPoker()
		
	Hotkey, IfWinExist, ahk_group GameWindows
	local hotkey, names
	IniRead, hotkey, PokerPad.ini, Hotkeys, TypeBet, 0
	IniRead, rtick, PokerPad.ini, Hotkeys, Rtick, 0
	IniRead, ftick, PokerPad.ini, Hotkeys, Ftick, 1
	IniRead, pot_ipoker, PokerPad.ini, iPoker, PotButton, Button 3
	IniRead, pot_pacific, PokerPad.ini, Pacific, PotButton, Button 4
	IniRead, pot_swcpoker, PokerPad.ini, SwcPoker, PotButton, Button 3
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

id := 0

InvokeHotkey(action) {
	local title, class, s
	Notify(action, id)
	WinGetClass, class
	StringReplace, class, class, .
	; Is the content of %class% can be used as a variable name?  #_@$?[] and words are accepted
	If (!RegExMatch(class, "[^\w#@$\?\[\]]", match))
		s := Site%class%

	local label := s . "_" . action
	if IsLabel(label) {
		GoSub, %label%
		; Strange Win 10 bug means we must send a MButton click if pressed anyway
		if (%A_ThisHotkey% = MButton)
			Send, {MButton}
	}
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
	
	if UseMouse {
		MouseGetPos, , , id
	} else {
		WinGet, id, ID
		if WinExist("blue_bar ahk_class AutoHotkeyGUI") {
			SendMessage, 0x5555
			id := ErrorLevel
		}
	}
	WinGet, ingroup, ID,  ahk_id %id% ahk_group GameWindows
	
	if (ingroup) {
		WinGet, aid, ID, A
		if !(aid == id) {
			WinActivate, ahk_id %id%
			WinWaitActive, ahk_id %id%, , 1
			if ErrorLevel {
				send, {%A_ThisHotkey%}
				return
			}
		} else if (IfWinNotExist, ahk_id %id%) {
			send, {%A_ThisHotkey%}
			return
		}
		Critical, On
		InvokeHotkey(A_ThisLabel)
		Critical, Off
	}
	else
		send, {%A_ThisHotkey%}
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
	/*
	if FullTilt_GameWindow
		FullTilt_AutoPostAll(on)
	*/
	if PokerStars_GameWindow
		PokerStars_AutoPostAll(on)
	if IPoker_GameWindow
		IPoker_AutoPostAll(on)
	if PartyPoker_GameWindow
		PartyPoker_AutoPostAll(on)
	/*
	if EverestPoker_GameWindow
		EverestPoker_AutoPostAll(on)
	if Ongame_GameWindow
		Ongame_AutoPostAll(on)
	if CakePoker_GameWindow
		CakePoker_AutoPostAll(on)
	if Microgaming_GameWindow
		Microgaming_AutoPostAll(on)
	*/
	if Pacific_GameWindow
		Pacific_AutoPostAll(on)
	if SkyPoker_GameWindow
		SkyPoker_AutoPostAll(on)
	if SwCPoker_GameWindow
		SwCPoker_AutoPostAll(on)
}

SitInAll(in) {
	global
	/*
	if FullTilt_GameWindow
		FullTilt_SitInAll(in)
	if PokerStars_GameWindow
		PokerStars_SitInAll(in)
	*/
	if IPoker_GameWindow
		IPoker_SitInAll(in)
	if PartyPoker_GameWindow
		PartyPoker_SitInAll(in)
	/*
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
	*/
	if SkyPoker_GameWindow
		SkyPoker_SitInAll(in)
	if SwCPoker_GameWindow
		SwCPoker_SitInAll(in)
}

LeaveAll:
	/*
	if FullTilt_GameWindow
		FullTilt_CloseGameWindows(FullTilt_GameWindow)
	*/
	if PokerStars_GameWindow
		PokerStars_CloseGameWindows(PokerStars_GameWindow)
	if IPoker_GameWindow
		IPoker_CloseGameWindows(IPoker_GameWindow)
	if PartyPoker_GameWindow
		PartyPoker_CloseGameWindows(PartyPoker_GameWindow)
	/*
	if EverestPoker_GameWindow
		EverestPoker_CloseGameWindows(EverestPoker_GameWindow)
	if Ongame_GameWindow
		Ongame_CloseGameWindows(Ongame_GameWindow)
	if CakePoker_GameWindow
		CakePoker_CloseGameWindows(CakePoker_GameWindow)
	if Microgaming_GameWindow
		Microgaming_CloseGameWindows(Microgaming_GameWindow)
	*/
	if Pacific_GameWindow
		Pacific_CloseGameWindows(Pacific_GameWindow)
	if SkyPoker_GameWindow
		Skypoker_CloseGameWindows(SkyPoker_GameWindow)
	if SwCPoker_GameWindow
		SwCPoker_CloseGameWindows(SwCPoker_GameWindow)
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

Debug:
	Critical, On
	Debug()
	return

IsChecked(ByRef area, relative = 1, color = 0x000000, ByRef id = "") {
	GetWindowArea(x, y, w, h, area, relative, id)
	return Display_PixelSearch(x, y, w, h, color, 16, id)
}

/*
BB = call*2 + b or (no call and raise > blind)
- raise = call*2+b then fpot = (pot+call) * factor + call + blind <- particular
- no call and raise > blind fpot = pot*factor + blind <- particular


preflop non blind = call*2 - b  then fpot = (pot+call) * factor + call

SB = (call*2 and call < pot) or call < blind
- call*2 and call < pot then fpot = (pot+call) * factor + call + small blind <- particular
- call < blind then fpot = (pot+call) * factor + call

postflop = (call*2 and call = pot) or (no call and raise = blind)
- post = call*2 and call = pot then fpot = (pot+call)*factor+call
- no call and raise = blind fpot = pot * factor 
*/
GetBet(factor, pot, call, raise, blind, sblind = 0) {
	local fpot, bet
	fpot := pot * factor
	bet := 0
	if call {
		fpot := (pot + call) * factor + call
		if (raise  = call * 2 + blind) ;big blind opened
			bet := blind
		else if (raise = call * 2 and call < pot) ; small blind opened
			bet := sblind
	} else if (raise > blind) ; big blind check
		bet := blind
	return bet + fpot
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
	Sleep, 50
	if bet
		Send, %bet%
	Sleep, 50
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

;#Include Includes\FullTilt.ahk
#Include Includes\PokerStars.ahk
#Include Includes\IPoker.ahk
#Include Includes\PartyPoker.ahk
;#Include Includes\EverestPoker.ahk
;#Include Includes\Ongame.ahk
;#Include Includes\CakePoker.ahk
;#Include Includes\Microgaming.ahk
#Include Includes\Pacific.ahk
#Include Includes\SkyPoker.ahk
#Include Includes\SwCPoker.ahk

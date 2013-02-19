

Absolute_Reload(max) {
	static GetChips := "Button20", Maximum := "Button1", OK := "Button3"
	ClickWindowArea2(Absolute_Options)
	time := A_TickCount
	WinWaitActive, ^Options ahk_class DXPopupWnd, , 5
	Sleep(time, 400)
	ClickControl(Absolute_GetChips)
	time := A_TickCount
	WinWaitActive, ^Buy chips ahk_class DXPopupWnd, , 5
	Sleep(time, 400)
	if (max && IsControlVisible(Absolute_Maximum) && IsControlEnabled(Absolute_Maximum)) {
		ClickControl(Absolute_Maximum)
		Sleep, 400
	}
	ClickControl(Absolute_OK)
}

Absolute_GetBlind(big) {
	WinGetTitle, title
	s := InStr(title, "Big Blind:")
	if s {
		s += 12
		e := InStr(title, A_Space, true, s)
	} else {
		return Absolute_GetTournamentBlind(big, SubStr(title, 1, InStr(title, ",") - 1))
	}
	blind := CurrencyToFloat(SubStr(title, s, e-s))
	return big ? blind : Absolute_GetSmallBlind(blind)
}

Absolute_GetSmallBlind(blind) {
	blind := Round(blind*100)
	if Mod(blind, 2) {
		label := "Absolute_GetSmallBlind" . blind
		if IsLabel(label) {
			GoSub, %label%
			return blind
		}
	}
	blind := blind/200
	DollarRound(blind)
	return blind
	Absolute_GetSmallBlind25:
		blind := 0.10
		return
}

Absolute_GetTournamentBlind(big, n) {
	static Lobby
	if !Lobby
		Lobby := CreateArea("10,10,40,10", 780, 557)
	activate := false
	WinGet, id, ID
	if !WinExist("^#" . n . " ahk_class #32770") {
		if !WinExist("ahk_id " . id)
			return 0
		ClickWindowArea2(Lobby)
		WinWaitActive, ^#%n% ahk_class #32770, , 5
		if ErrorLevel
			return 0
		activate := true
	}
	Display_CreateWindowCapture(device, context, pixels)
	c = c%context%
	blinds := Display_ReadArea(137, 177, 200, 12, 0x000000, 0, c)
	Display_DeleteWindowCapture(device, context, pixels)
	s := InStr(blinds, "/")
	if big {
		s += 1
		e := InStr(blinds, ",")
	} else {
		e := s
		s := 1
	}
	if (WinExist("ahk_id " . id) && activate) ; WinExist sets the Last Found Window back to the game table
		WinActivate, ahk_id %id%
	return CurrencyToFloat(SubStr(blinds, s, e-s))
}


; ( [] )..( [] )   Everest Poker Implementation   ( [] )..( [] ) 

EverestPoker_Reload(max) {
	static GetChips
	if !GetChips
		GetChips := CreateArea("558,6,50,9", 640, 480)
	ClickWindowArea2(GetChips, true)
	Sleep, 400
	GetWindowArea(x, y, w, h)
	x += Round(w / 2) - 157
	y += Round(h / 2) - 160
	if max {
		maxX := x + 130, maxY := y + 102, maxW := 160, maxH := 30
		ClickWindowRect2(maxX, maxY, maxW, maxH)
		Sleep, 400
	}
	okX := x + 62, okY := y + 291, okW := 80, okH := 10
	ClickWindowRect2(okX, okY, okW, okH)
}

EverestPoker_GetBlind(big) {
	local title, s, e, blind
	WinGetTitle, title
	e := InStr(title, "/")
	StringGetPos, s, title, %A_Space%, R, StrLen(title)-e
	s += 2
	blind := CurrencyToFloat(SubStr(title, s, e-s), EverestPoker_Currency, EverestPoker_Separator, EverestPoker_Decimal)
	return big ? blind : EverestPoker_GetSmallBlind(blind)
}


EverestPoker_GetSmallBlind(blind) {
	blind := Round(blind*100)
	if Mod(blind, 2) {
		if IsLabel(EverestPoker_GetSmallBlind%blind%) {
			GoSub, EverestPoker_GetSmallBlind%blind%
			return blind
		}
	}
	blind := blind/200
	DollarRound(blind)
	return blind
	EverestPoker_GetSmallBlind25:
		blind := 0.15
		return
}

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

; ( [] )..( [] )   Microgaming Implementation   ( [] )..( [] ) 

Microgaming_IsMiniWindow() {
	WinGetPos, , , width
	return width < 700
}

Microgaming_GetArea(ByRef x, ByRef y, ByRef w, ByRef h, ByRef area) {
	StringSplit, array, area, %A_Space%
	x := array1
	y := array2
	w := array3
	h := array4
}

Microgaming_ClickArea(ByRef area, ByRef id = "") {
	Microgaming_GetArea(x, y, w, h, area)
	ClickWindowRect(x, y, w, h, id)
}

Microgaming_Reload(max) {
	static MiniChips := "9 326 40 11", Chips := "59 467 40 11", Maximum := "Button3", OK := "Button1"
	isMini := Microgaming_IsMiniWindow()
	if isMini
		Microgaming_ClickArea(MiniChips)
	else
		ClickWindowArea(Chips, false)
	time := A_TickCount
	WinWaitActive, Bring More Chips ahk_class #32770, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	if max {
		ClickControl(Maximum)
		Sleep, 400
	}
	ClickControl(OK)
	WinWaitActive, Chips Received ahk_class #32770, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	ClickControl(OK)
}

Microgaming_GetBlind(big) {
	static MiniBlinds := "5 181 70 11"
	if Microgaming_IsMiniWindow() {
		Microgaming_GetArea(x, y, w, h, MiniBlinds)
		blinds := Display_ReadArea(x, y, w, h, 0xFFFFFF)
		s := InStr(blinds, "N")
		if !s
			s := InStr(blinds, "P")
		if s
			blinds := SubStr(blinds, 1, s-1)
		s := InStr(blinds, "/")
		if big {
			s += 1
		} else {
			e := s
			s := 1
		}
	} else {
		WinGetTitle, blinds
		StringGetPos, s, blinds, /, R
		if big {
			s += 2
			e := InStr(blinds, " ", true, s)
		} else {
			e := s + 1
			StringGetPos, s, blinds, %A_Space%, R, StrLen(blinds) - s
			s += 2
		}
	}
	return CurrencyToFloat(e ? SubStr(blinds, s, e-s) : SubStr(blinds, s))
}

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

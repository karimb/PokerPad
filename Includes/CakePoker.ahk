; ( [] )..( [] )   Cake Poker Implementation   ( [] )..( [] ) 

CakePoker_Reload(max) {
	static GetChips := "360 122 70 20", AddChips := "TTntButton.UnicodeClass3", MaximumBuyin := "TTntRadioButton.UnicodeClass2", OK := "TTntButton.UnicodeClass2"
	ClickWindowArea(GetChips, false)
	time := A_TickCount
	WinWaitActive, ahk_class TfrmOptions\.UnicodeClass, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	ClickControl(AddChips)
	time := A_TickCount
	WinWaitActive, ahk_class TfrmBuyIn\.UnicodeClass, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	if max {
		ClickControl(MaximumBuyin)
		Sleep, 500
	}
	ClickControl(OK)
}

CakePoker_GetBlind(big) {
	WinGetTitle, title
	StringGetPos, s, title, /, R
	if big {
		s += 2
		e := InStr(title, " ", true, s)
	} else {
		e := s + 1
		StringGetPos, s, title, %A_Space%, R, StrLen(title) - s
		s += 2
	}
	return CurrencyToFloat(e ? SubStr(title, s, e-s) : SubStr(title, s))
}

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

; ( [] )..( [] )   iPoker Implementation   ( [] )..( [] ) 

/*IPoker_Reload(max = true) {
	static MiniMenu := "466 6 40 10", MiniBuyChips := "435 53 50 9", GetChips := "242 576 80 14"
	if IPoker_IsMiniWindow() {
		ClickWindowArea(IPoker_MiniMenu, false)
		Sleep, 400
		ClickWindowArea(IPoker_MiniBuyChips, false)
	} else {
		ClickWindowArea(IPoker_GetChips, false)
	}
	Sleep, 400
	if max {
		Random, x, 35, 135
		Random, y, 174, 184
		ControlClick, x%x% y%y%, A, , , , Pos
		Sleep, 400
	}
	Random, x, 132, 182
	Random, y, 238, 250
	ControlClick, x%x% y%y%, A, , , , Pos
}
*/

/*IPoker_IsMiniWindow() {
	WinGetPos, , , width
	return width < 600
}
*/

IPoker_UseBB() {
  IniRead, usebb, PokerPad.ini, IPoker, UseBB, 0
  return usebb
}

IPoker_GetBlind(big) {
	WinGetTitle, title
	if (IPoker_UseBB())
		blind := big ? 1.0 : 0.5
	else {
	  RegExMatch(title, "€(\d+\.?\d*)\/€(\d+\.?\d*)", match)
	  blind := big ? match2 : match1
	}
	return CurrencyToFloat(blind)
}

/* 
 * All boxes assume a window dimension of 1024x726. 
 * No window decorations worth considering.
 */

 
 IPoker() {
	global
	; The standard size for our coordinate
	IPoker_StdX := 1024.0
	IPoker_StdY := 726.0
	
	/*
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
	*/
	; These dimensions only work for a window which is 798x600 in size
    IPoker_Fold := "680 680 60 20"
	IPoker_CheckFold := "665 645 2 2"
	IPoker_Call := "800 680 60 20"
	IPoker_Raise := "920 680 60 20"
	;IPoker_FastFold = 328 531 10 24

	;IPoker_AutoPost = 720 590 5 5
	IPoker_FoldAny := "130 704 2 2"
	;IPoker_SitOut = 629 574 5 5

	;IPoker_AutoMuck = 634 545 70 12
	;IPoker_AllIn = 710 480 100 24
	;IPoker_LastHand = 228 482 50 9

	;IPoker_Pot = 374 76 60 22
	; BetBox is for reading the pot while BetBox2 is for clicking in the bet box
	IPoker_BetBox := "690 640 55 15"
	IPoker_BetBox2 := "710 645 10 5"
	
	IPoker_PotButton1 := "680 610 45 7"
	IPoker_PotButton2 := "770 610 45 7"
	IPoker_PotButton3 := "860 610 45 7"
	IPoker_PotButton4 := "950 610 45 7"
	
	;IPoker_ChatBox := CreateArea("16,534,360,60", 780, 557)
	
	IPoker_GameWindow = / ahk_class Qt693QWindowIcon
	SiteQt693QWindowIcon = IPoker
	IPoker_LobbyWindow = Nickname ahk_class Qt693QWindowIcon
	IPoker_LastHandWindow = Hand history ahk_class Qt693QWindowIcon
	SetClientHotkeys("IPoker")
	GroupAdd, GameWindows, / ahk_class Qt693QWindowIcon
}

IPoker_AdjustSize(box) {
	local box0, box1, box2, box3, box4, w, h
	WinGetPos, , , w, h
	w /= IPoker_StdX
	h /= IPoker_StdY
	StringSplit, box, box, %A_Space%
	box1 *= w
	box2 *= h
	box3 *= w
	box4 *= h
	WriteLog("IPoker - AdjustSize to x: " Round(box1) " y: " Round(box2))
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


/* AdjustClick clicks to the area of the screen indicated by x and y
   with mouse button c (c=0 moves without click) 
*/
IPoker_AdjustClick(c = 1) {
	local px, py, box
	box := IPoker_AdjustSize(IPoker_BetBox2)
	StringSplit, box, box, %A_Space%
	MouseGetPos, px, py
	Click %box1% %box2% %c%
	Click %px% %py% 0
	WriteLog("IPoker - AdjustClick to x: " box1 " y: " box2)
	Sleep, 20
}


; We use the window handle when several fold are done in a row to make sure 
;they reach only one window
IPoker_ClickButton(button, id = "") {
	local x, y, w, h, bgr, box, name
	name := button
	button := IPoker_%button%
	;MsgBox % name . " - Before: " . button .  " After: " . IPoker_AdjustSize(button)
	box := IPoker_AdjustSize(button)
	GetWindowArea(x, y, w, h, box, false, id)
	;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	ClickWindowRect(x, y, w, h, id)
	Sleep, 100
	WriteLog(name " - x: " x ", y: " y ", id: " id )
}

IPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, btn
	btn := SubStr(pot_ipoker, 8, 1)
	box := IPoker_ClickButton("PotButton" . btn)
	;WriteLog("IPoker - Pot Button - x: " x ", y:" y ", width: " w ", height:" h)
	;Copy
	if (factor != 1) {
	    box := IPoker_AdjustSize(IPoker_BetBox)
		StringSplit, box, box, %A_Space%
		GetCapturedText(box1, box2, box3, box4)
		pot := Clipboard
		WriteLog("IPoker - Clipboard amount: " pot)
	}
	return (factor * pot)
}

IPoker_CheckBet(bet) {
	local box
	box := IPoker_AdjustSize(IPoker_BetBox)
	StringSplit, box, box, %A_Space%
	GetCapturedText(box1, box2, box3, box4)
	if (Clipboard == bet)
		return 1
	else
		return 0
}

IPoker_Bet(ByRef betbox, bet = "") {
	IPoker_AdjustClick()
	Bet(bet)
}

IPoker_BetRelativePot(factor) {
	local box, pot, round := IPoker_GetRound(Rounding, Rounding)
	bet := GetRoundedAmount(IPoker_GetPot(factor), round)
	if (factor != 1 and bet != "")
		IPoker_Bet(box, bet)
	if (rtick && IPoker_CheckBet(bet))
		IPoker_ClickButton("Raise")
}

IPoker_FixedBet(factor) {
	local pot, box
	pot := GetAmount(GetDollarRound(factor * IPoker_GetBlind(true)), IPoker_Decimal)
	IPoker_Bet(box, pot)
	if (ftick && IPoker_CheckBet(pot) && factor < 200)
		IPoker_ClickButton("Raise")
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
	;Send, F1
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
	;IPoker_ClickButton("FastFold", id)
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
	IPoker_Bet(IPoker_BetBox, 100000)
	return
IPoker_LastHand:
	;IPoker_ClickButton("LastHand")
	return
IPoker_IncreaseBet:
IPoker_IncreaseBet2:
	;IPoker_AdjustClick(436,506)
	Send, {WheelUp}
	return
IPoker_DecreaseBet:
IPoker_DecreaseBet2:
	;IPoker_AdjustClick(436,506)
	Send, {WheelDown}
	return
IPoker_FoldAny:
	ClickWindowArea(IPoker_FoldAny, false)
	return
IPoker_AutoPost:
	;ClickWindowArea(IPoker_AutoPost, false)
	return
IPoker_ToggleAutoMuck:
	;ClickWindowArea(IPoker_AutoMuck, false)
	return
IPoker_AllInThisHand:
	IPoker_Bet(IPoker_BetBox, 100000)
	;TrayTip, Not Supported!, All In*** is not supported for iPoker.
	return
IPoker_Reload:
	;IPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
IPoker_Lobby:
	WinActivate, %IPoker_LobbyWindow%
	return
IPoker_SitOut:
	;ClickWindowArea(IPoker_SitOut, false)
	return
IPoker_ClearBetBox:
	IPoker_Bet(IPoker_BetBox)
	return

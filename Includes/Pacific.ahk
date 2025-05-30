; ( [] )..( [] )   Pacific Implementation   ( [] )..( [] ) 

Pacific_GetBlind(big) {
	WinGetTitle, title
	if (Pacific_UseBB())
		blind := big ? 1.0 : 0.5
	else {
	  RegExMatch(title, " \D?(\d+).?/\D?(\d+)", match)
	  if (InStr(title, "�")) {
		  match1 /= 100.0
		  match2 /= 100.0
	  }
	  blind := big ? match2 : match1
	}
	return CurrencyToFloat(blind)
}

Pacific_FormatAmount(amnt) {
	local pot
	if (Pacific_UseBB())
	  pot := amnt
	else if (InStr(amnt, "�")) 
		pot := SubStr(amnt, 1, StrLen(amnt) - 1)  / 100.0
	else if (InStr(amnt, "$"))
		pot := SubStr(amnt, 2)
    else
      pot := amnt
	return pot
}

Pacific_UseBB() {
  IniRead, usebb, PokerPad.ini, Pacific, UseBB, 0
  return usebb
}

Pacific_CheckTimeBank(id, context) {
	local bgr,box,box0,box1,box2,box3,box4,color,diff, adjusted
	
	;the color is the orange used by the timebank button in BGR
	color := 0x20B5FC
	diff := 20
	adjusted := Pacific_AdjustSize(Pacific_TimeBank, id)
	StringSplit, box, adjusted, %A_Space%
	bgr := Display_GetPixel(context, box1, box2)
	;WriteLog("CheckTimeBank - box1: " box1 ", box2: " box2)
	;PixelGetColor, bgr, x, y
	return Display_CompareColors(bgr, color, diff)
}


/* 
 * To get the "client" coordinates, all values must be reduced by 
 * Win 2000 Theme: 4 pixels in x and 23 in y
 * Windows 10: 8 pixels in x and 31 in y (in screenshots, it is 1 and 31)
 * The window client size must be 640x480
 * The functions AdjustClick and AdjustSize then make adjustments for different window sizes and borders
 */
Pacific() {
	global
	; The standard size for our coordinate
	Pacific_StdX := 640.0
	Pacific_StdY := 480.0
	; So even if the window is too wide, the buttons stop growing beyond the Aspect Ratio
	Pacific_AspectRatio := Pacific_StdX / Pacific_StdY
	
	Pacific_Fold := "410 454 40 10"
	Pacific_CheckFold := "410 454 40 10"
	Pacific_Call := "485 454 40 10"
	Pacific_Raise := "570 454 40 10"
	;;Pacific_FoldAny = 635 536 5 5

	;;Pacific_AutoPost = 482 535 5 5
	;Pacific_SitOut = 14 512 2 2

	;;Pacific_AutoMuck = 
	;Pacific_Lobby = 680 27 80 5
	;Pacific_LastHand = 
	;Pacific_Options =
	;Pacific_Settings
	;Pacific_TimeBank = 751 563 2 2
	;;Pacific_Chat = 12 538 155 12
	
	;Just wheel up for now
	;Pacific_IncreaseBet = 542 680 2 2
	;Pacific_DecreaseBet = 308 680 2 2

	Pacific_Pot := "552 415 5 3"
	Pacific_PotButton2 := "450 415 5 3"
	Pacific_PotButton3 := "503 415 5 3"
	Pacific_PotButton4 := "552 415 5 3"
	Pacific_PotButton5 := "605 415 5 3"
	
	Pacific_BetBox := "610 434 10 3"

	Pacific_GameWindow = / ahk_class Qt650QWindowOwnDC
	Pacific_LobbyWindow = 888poker ahk_class Qt5152QWindowIcon
	Pacific_LastHandWindow = : ahk_class Qt650QWindowOwnDC
	; Same as Party :(
	SiteQt650QWindowOwnDC = Pacific
	SetClientHotkeys("Pacific")
	GroupAdd, GameWindows, / ahk_class Qt650QWindowOwnDC
	; Timebank is automated - disabled
	;IniRead, timebank_pacific, PokerPad.ini, Pacific, Timebank, 0
	; if (timebank_pacific)
	;	SetTimer Pacific_AutoTimeBank, 4000
}

Pacific_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, pot2, btn
	btn := SubStr(pot_pacific, 8, 1)
	box := Pacific_AdjustSize(Pacific_PotButton%btn%)
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	WriteLog("Pacific - Pot Button - x: " x ", y:" y ", width: " w ", height:" h)
	Sleep, 100
	;select and copy
	pot := 1
	if (factor != 1) {
		Pacific_AdjustClick()
		Send, {Home}+{End}^c
		Sleep, 50
		pot := Clipboard
		WriteLog("Clipboard amount: " pot)
		pot := Pacific_FormatAmount(pot)
	}
	return (factor * pot)
}
	
Pacific_CheckBet(bet) {
	Pacific_AdjustClick()
	Send, {Home}+{End}^c
	Sleep, 50
	if (Clipboard == bet)
		return 1
	else
		return 0
}
	
Pacific_Bet(ByRef betbox, bet = "") {
	Pacific_AdjustClick()
	Bet(bet)
}

Pacific_BetRelativePot(factor) {
	local press, c, box, pot, round := Pacific_GetRound(Rounding, Rounding)
	pot := Pacific_GetPot(factor)
	if (pot != 1) {
		bet := GetRoundedAmount(pot, round)
		Pacific_Bet(Pacific_BetBox, bet)
		c:= Pacific_CheckBet(bet)
	}
	press := rtick && c
	if (press) {
		Pacific_ClickButton("Raise")
	}
    ; removing the highlight around bet amount
	if (!press && pot != 1)
		Pacific_AdjustClick()
}

Pacific_FixedBet(factor) {
	local pot
	pot := GetAmount(GetDollarRound(factor * Pacific_GetBlind(true)), Pacific_Decimal)
	Pacific_Bet(Pacific_BetBox, pot)
	local c := Pacific_CheckBet(pot)
	if (ftick && c) {
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
	local box0, box1, box2, box3, box4, w, h, r
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
	StringSplit, box, box, %A_Space%
	
	w -= 2 * ResizeBorder
	h -= (2 * ResizeBorderY + Caption)
	
	r := (h * Pacific_AspectRatio) / Pacific_StdX
	box1 := Pacific_StdX - box1
	box1 *= r
	box1 := w - box1
	box1 += ResizeBorder
	box3 *= r
	
	r := h / Pacific_StdY
	box2 := Pacific_StdY - box2
	box2 *= r
	box2 := h - box2
	box2 += (ResizeBorderY + Caption)
	box4 *= r
	WriteLog("AdjustSize to x: " Round(box1) " y: " Round(box2) " r: " r)
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


Pacific_AdjustClick(c = 1) {
	local px, py, w, h, r, box
	box := Pacific_AdjustSize(Pacific_BetBox)
	StringSplit, box, box, %A_Space%
	MouseGetPos, px, py
	Click %box1% %box2% %c%
	Click %px% %py% 0
	WriteLog("Pacific - AdjustClick to x: " x " y: " y)
	Sleep, 20
}

Pacific_ClickButton(button, id = "") {
	local x, y, w, h, box, name
	name := button
	button := Pacific_%button%
	box := Pacific_AdjustSize(button, id)
	GetWindowArea(x, y, w, h, box, false, id)
	ClickWindowRect(x, y, w, h, id)	
	WriteLog(name " - x: " x ", y: " y ", id: " id )
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
	Pacific_ClickButton("Fold", id)
	;Pacific_ClickButton("CheckFold")
	return
Pacific_Call:
	Pacific_ClickButton("Call", id)
	return
Pacific_Raise:
	Pacific_ClickButton("Raise", id)
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
	SendEvent, {WheelUp 1000}
	return
Pacific_LastHand:
	ClickWindowArea2(Pacific_LastHand)
	return
Pacific_IncreaseBet:
Pacific_IncreaseBet2:
	SendEvent, {WheelUp}
	;Pacific_ClickButton("IncreaseBet")
	return
Pacific_DecreaseBet:
Pacific_DecreaseBet2:
    SendEvent, {WheelDown}
	;Pacific_ClickButton("DecreaseBet")
	return
Pacific_FoldAny:
	;ClickWindowArea2(Pacific_FoldAny)
	return
Pacific_AutoPost:
	;ClickWindowArea2(Pacific_AutoPost)
	return
Pacific_ToggleAutoMuck:
	;ClickWindowArea2(Pacific_AutoMuck)
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
	/*WinGet Wnd, List, / ahk_class Qt5152QWindowOwnDC,,Lobby
	Loop, %Wnd% {
		id := Wnd%A_Index%
		Display_CreateWindowCapture(device, context, pixels, id)
		if (Pacific_CheckTimeBank(id, context)) {
			;ClickWindowArea2(Pacific_TimeBank,0, id)
			Pacific_ClickButton("TimeBank", id)
		}
		Display_DeleteWindowCapture(device, context, pixels, id)
		ControlGet,visible,Visible,,,ahk_id %id%
		if visible
			DllCall("RedrawWindow","UInt",id,"UInt",0,"UInt",0,"UInt", 1|4|64|1024)
	}
	*/
	return
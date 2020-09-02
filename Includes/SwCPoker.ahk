; ( [] )..( [] )   SwCPoker Implementation   ( [] )..( [] ) 

SwCPoker_GetBlind(big) {
	WinGetTitle, title
	RegExMatch(title, " \D?(\d+\.?\d*).?/\D?(\d+\.?\d*)", match)
	blind := big ? match2 : match1
	return CurrencyToFloat(blind)
}


/* Not supported yet
SwCPoker_CheckTimeBank(id, context) {
	local bgr,box,box0,box1,box2,box3,box4,color,diff
	
	;the color is the orange used by the timebank button in BGR
	color := 0x20B5FC
	diff := 20
	SwCPoker_TimeBank = 751 563 2 2
	SwCPoker_TimeBank := SwCPoker_AdjustSize(SwCPoker_TimeBank, id)
	StringSplit, box, SwCPoker_TimeBank, %A_Space%
	bgr := Display_GetPixel(context, box1, box2)
	;MsgBox % box1 "-" box2 "-" bgr
	;PixelGetColor, bgr, x, y
	return Display_CompareColors(bgr, color, diff)
}
*/

/* 
 * All boxes assume a window dimension of 824x590. The Windows theme MUST be Win2000 (also called "Windows Classic" in Personalise)
 * so change the the theme in WinXP/Win7 to Win2000 before proceeding
 * all values must be reduced by 4 pixels in x and 23 in y (border width/height in Win2000)
 * (also called "client" coordinate in AHK 1.1)
 * For example, 600 300 10 5 becomes 596 277 10 5
 * The functions AdjustClick and AdjustSize then make adjustments for different window sizes and borders
 */
SwCPoker() {
	global
	SwCPoker_Fold = 418 544 20 2
	SwCPoker_CheckFold = 418 514 20 2
	SwCPoker_Call = 560 530 20 12
	SwCPoker_Raise = 695 530 20 12
	;;SwCPoker_FoldAny = 635 536 5 5

	;;SwCPoker_AutoPost = 482 535 5 5
	SwCPoker_SitOut = 16 403 2 2

	;;SwCPoker_AutoMuck = 
	;SwCPoker_Lobby = 680 27 80 5
	;SwCPoker_LastHand = 
	;SwCPoker_Options =
	;SwCPoker_Settings
	;SwCPoker_TimeBank = 751 563 2 2
	SwCPoker_Chat = 20 546 155 12

	;Just wheel up for now
	;SwCPoker_IncreaseBet = 542 680 2 2
	;SwCPoker_DecreaseBet = 308 680 2 2

	SwCPoker_Pot = 470 660 10 2
	SwCPoker_PotButton1 = 546 455 10 5
	SwCPoker_PotButton2 = 619 455 10 5
	SwCPoker_PotButton3 = 676 455 10 5
	SwCPoker_PotButton4 = 746 455 10 5
	
	SwCPoker_BetBox = 547 490 20 5

	SwCPoker_GameWindow = / ahk_class Qt5QWindowIcon
	SwCPoker_LobbyWindow = SwC Poker ahk_class Qt5QWindowIcon
	;SwCPoker_LastHandWindow = : ahk_class Qt5QWindowOwnDC
	; Same as Party :(
	SiteQt5QWindowIcon = SwCPoker
	SetClientHotkeys("SwCPoker")
	GroupAdd, GameWindows, / ahk_class Qt5QWindowIcon
/*  Not supported yet
	IniRead, timebank_SwCPoker, PokerPad.ini, Hotkeys, Timebank, 1
	if (timebank_SwCPoker)
		SetTimer SwCPoker_AutoTimeBank, 4000
*/
}

SwCPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, pot2, btn
	btn := SubStr(pot_swcpoker, 8, 1)
	box := SwCPoker_AdjustSize(SwCPoker_PotButton%btn%)
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	WriteLog("Pacific - Pot Button - x: " x ", y:" y ", width: " w ", height:" h)
	Sleep, 400
	;select and copy
	SwCPoker_AdjustClick(553, 490)
	Send, {Home}+{End}^c
	Sleep, 200
	pot := Clipboard
	return (factor * pot)
}
	
SwCPoker_CheckBet(bet) {
	SwCPoker_AdjustClick(553, 490)
	Send, {Home}+{End}^c
	Sleep, 200
	if (Clipboard == bet)
		return 1
	else
		return 0
}
	
SwCPoker_Bet(ByRef betbox, bet = "") {
	SwCPoker_AdjustClick(553, 490)
	Bet(bet)
}

SwCPoker_BetRelativePot(factor) {
	local box, pot, round := SwCPoker_GetRound(Rounding, Rounding)
	bet := GetRoundedAmount(SwCPoker_GetPot(factor), round)
	SwCPoker_Bet(SwCPoker_BetBox, bet)
	local c:= SwCPoker_CheckBet(bet)
	if (rtick && c) {
		SwCPoker_ClickButton("Raise")
	}
}

SwCPoker_FixedBet(factor) {
	local pot
	pot := GetAmount(GetDollarRound(factor * SwCPoker_GetBlind(true)), SwCPoker_Decimal)
	SwCPoker_Bet(SwCPoker_BetBox, pot)
	local c := SwCPoker_CheckBet(pot)
	if (ftick && c) {
		SwCPoker_ClickButton("Raise")
	}
}


SwCPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (!IsChecked(SwCPoker_SitOut, false, SwCPoker_CheckColor, id)) {
			ClickWindowArea(SwCPoker_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

SwCPoker_SitInAll(in) {
	global
	if !WinExist(SwCPoker_GameWindow)
		return
	SwCPoker_CheckAll(SwCPoker_SitOut, !in)
}

SwCPoker_AutoPostAll(on) {
	global
	if !WinExist(SwCPoker_GameWindow)
		return
	SwCPoker_CheckAll(SwCPoker_AutoPost, on)
}

SwCPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %SwCPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, SwCPoker_CheckColor, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}


SwCPoker_GetRound(rounding, default) {
	if (rounding < -1)
		return SwCPoker_GetBlind(rounding+2)
	return default
}

;824x590 is the dimensions of the visible area of the default 816x563 window in Windows 2000
SwCPoker_AdjustSize(box, id = "") {
	local box0, box1, box2, box3, box4, w, h
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 816.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 563.0
	StringSplit, box, box, %A_Space%
	box1 *= w
	box1 += ResizeBorder
	box2 *= h
	box2 += (ResizeBorderY + Caption)
	box3 *= w
	box4 *= h
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


;AdjustClick clicks to the area of the screen indicated by x and y
;with mouse button c (c=0 moves without click) 
SwCPoker_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 816.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 563.0
	x := Round(x * w)
	x += ResizeBorder
	y := Round(y * h)
	y += (ResizeBorderY + Caption)
	MouseGetPos, px, py
	Click %x% %y% %c%
	Click %px% %py% 0
	WriteLog("SwCPoker - AdjustClick to x: " x " y: " y)
	Sleep, 50
}

SwCPoker_ClickButton(button, id = "") {
	local x, y, w, h, box, name
	name := button
	button := SwCPoker_%button%
;MsgBox % "Before: " . button .  " After: " . SwCPoker_AdjustSize(button)
	box := SwCPoker_AdjustSize(button, id)
	GetWindowArea(x, y, w, h, box, false, id)
	ClickWindowRect(x, y, w, h, id)	
	;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	WriteLog("SwCPoker - " name " - x: " x ", y:" y ", width: " w ", height:" h)
}


SwCPoker_IsChecked(ByRef checkbox, ByRef x = "", ByRef y = "", ByRef w = "", ByRef h = "") {
	GetWindowArea(x, y, w, h, checkbox, true)
	Display_CreateWindowCapture(device, context, pixels, id)
	bgr := Display_GetPixel(context, x + w, y + 1)
	Display_DeleteWindowCapture(device, context, pixels, id)
	return Display_IsRed(bgr)
}




SwCPoker_Activate:
	WinActivate, %SwCPoker_GameWindow%
	return
SwCPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
SwCPoker_Fold:
	SwCPoker_ClickButton("Fold")
	Sleep, 100
	SwCPoker_ClickButton("CheckFold")
	return
SwCPoker_Call:
	SwCPoker_ClickButton("Call")
	return
SwCPoker_Raise:
	SwCPoker_ClickButton("Raise")
	return
SwCPoker_Relative1:
	SwCPoker_BetRelativePot(Relative1)
	return
SwCPoker_Relative2:
	SwCPoker_BetRelativePot(Relative2)
	return
SwCPoker_Relative3:
	SwCPoker_BetRelativePot(Relative3)
	return
SwCPoker_Relative4:
	SwCPoker_BetRelativePot(Relative4)
	return
SwCPoker_Relative5:
	SwCPoker_BetRelativePot(Relative5)
	return
SwCPoker_Relative6:
	SwCPoker_BetRelativePot(Relative6)
	return
SwCPoker_Relative7:
	SwCPoker_BetRelativePot(Relative7)
	return
SwCPoker_Relative8:
	SwCPoker_BetRelativePot(Relative8)
	return
SwCPoker_Relative9:
	SwCPoker_BetRelativePot(Relative9)
	return
SwCPoker_RandomBet:
	SwCPoker_BetRelativePot(GetRandomBet())
	return
SwCPoker_Fixed1:
	SwCPoker_FixedBet(Fixed1)
	return
SwCPoker_Fixed2:
	SwCPoker_FixedBet(Fixed2)
	return
SwCPoker_Fixed3:
	SwCPoker_FixedBet(Fixed3)
	return
SwCPoker_Fixed4:
	SwCPoker_FixedBet(Fixed4)
	return
SwCPoker_Fixed5:
	SwCPoker_FixedBet(Fixed5)
	return
SwCPoker_Fixed6:
	SwCPoker_FixedBet(Fixed6)
	return
SwCPoker_Fixed7:
	SwCPoker_FixedBet(Fixed7)
	return
SwCPoker_Fixed8:
	SwCPoker_FixedBet(Fixed8)
	return
SwCPoker_Fixed9:
	SwCPoker_FixedBet(Fixed9)
	return
SwCPoker_AllIn:
	SendEvent, {WheelUp 1000}
	return
SwCPoker_LastHand:
	;ClickWindowArea2(SwCPoker_LastHand)
	return
SwCPoker_IncreaseBet:
SwCPoker_IncreaseBet2:
	SendEvent, {WheelUp}
	;SwCPoker_ClickButton("IncreaseBet")
	return
SwCPoker_DecreaseBet:
SwCPoker_DecreaseBet2:
    SendEvent, {WheelDown}
	;SwCPoker_ClickButton("DecreaseBet")
	return
SwCPoker_FoldAny:
	;ClickWindowArea2(SwCPoker_FoldAny)
	return
SwCPoker_AutoPost:
	;ClickWindowArea2(SwCPoker_AutoPost)
	return
SwCPoker_ToggleAutoMuck:
	;ClickWindowArea2(SwCPoker_AutoMuck)
	return
SwCPoker_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for SwCPoker.
	return
SwCPoker_Reload:
	; do nothing
	return
SwCPoker_Lobby:
	ClickWindowArea2(SwCPoker_Lobby)
	return
SwCPoker_SitInAll:
SwCPoker_SitOut:
	ClickWindowArea2(SwCPoker_SitOut)
	return
/* not supported yet
SwCPoker_AutoTimeBank:
	WinGet Wnd, List, / ahk_class Qt5QWindowOwnDC,,Lobby
	Loop, %Wnd% {
		id := Wnd%A_Index%
		Display_CreateWindowCapture(device, context, pixels, id)
		if (SwCPoker_CheckTimeBank(id, context)) {
			ClickWindowArea2(SwCPoker_TimeBank,0, id)
			;SwCPoker_ClickButton("TimeBank", id)
		}
		Display_DeleteWindowCapture(device, context, pixels, id)
		ControlGet,visible,Visible,,,ahk_id %id%
		if visible
			DllCall("RedrawWindow","UInt",id,"UInt",0,"UInt",0,"UInt", 1|4|64|1024)
	}
	return
*/
; ( [] )..( [] )   Pacific Implementation   ( [] )..( [] ) 

Pacific_GetBlind(big) {
	WinGetTitle, title
	RegExMatch(title, " \D?(\d+).?/\D?(\d+)", match)
	if (InStr(title, "¢")) {
		match1 /= 100.0
		match2 /= 100.0
	}
	blind := big ? match2 : match1
	return CurrencyToFloat(blind)
}

Pacific_CheckTimeBank(id, context) {
	local w,h,x,y,bgr,color,diff
	x := 681
	y := 439
	;the color is the orange used by the timebank button in BGR
	color := 0x037FFE
	diff := 10
	WinGetPos, , , w, h, ahk_id %id%
	w /= 800.0
	h /= 579.0
	x := Round(x * w)
	y := Round(y * h)
	bgr := Display_GetPixel(context, x, y) 
	;PixelGetColor, bgr, x, y
	return Display_CompareColors(bgr, color, diff)
}

/* 
 * All boxes assume a window dimension of 800x578. The Windows theme MUST be Win2000
 * so change the the theme in WinXP/Win7 to Win2000 before proceeding
 * all values must be reduced by 4 pixels in x and 23 in y (border width/height in Win2000)
 * For example, 600 300 10 5 becomes 596 277 10 5
 * The functions AdjustClick and AdjustSize then make adjustments for different window sizes and borders
 */
Pacific() {
	global
	Pacific_Fold = 331 452 135 12
	Pacific_CheckFold = 331 487 135 10
	Pacific_Call = 486 452 135 12
	Pacific_Raise = 641 452 135 12
	Pacific_FoldAny = 635 536 5 5

	Pacific_AutoPost = 482 535 5 5
	Pacific_SitOut = 328 535 5 5

	Pacific_AutoMuck = 
	Pacific_Lobby = 658 35 120 12
	;Pacific_LastHand = 
	;Pacific_Options =
	;Pacific_Settings
	Pacific_TimeBank = 676 407 105 10
	Pacific_Chat = 12 538 155 12

	Pacific_IncreaseBet = 696 512 5 5
	Pacific_DecreaseBet = 491 512 5 5

	Pacific_Pot = 661 488 35 5
	Pacific_BetBox = 726 512 45 5

	Pacific_GameWindow = / ahk_class #32770
	Pacific_LobbyWindow = Lobby ahk_class #32770
	Pacific_LastHandWindow = ^Instant Replay ahk_class DxWndClass
	; Same as Party :(
	;Site#32770 = Pacific
	SetClientHotkeys("Pacific")
	GroupAdd, GameWindows, / ahk_class #32770
	if (timebank_pacific)
		SetTimer Pacific_AutoTimeBank, 4000
}

Pacific_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, pot2

	Pacific_ClickButton("Pot")
	Sleep, 400
	;select and copy
	Pacific_AdjustClick(736, 514)
	Send, {Home}+{End}^c
	Sleep, 50
	pot := Clipboard
	return (factor * pot)
}
	
Pacific_CheckBet(bet) {
	Pacific_AdjustClick(736, 514)
	Send, {Home}+{End}^c
	Sleep, 50
	if (Clipboard == bet)
		return 1
	else
		return 0
}
	
Pacific_Bet(ByRef betbox, bet = "") {
	Pacific_AdjustClick(736, 514)
	Bet(bet)
}

Pacific_BetRelativePot(factor) {
	local box, pot, round := Pacific_GetRound(Rounding, Rounding)
	bet := GetRoundedAmount(Pacific_GetPot(factor), round)
	Pacific_Bet(Pacific_BetBox, bet)
	local c:= Pacific_CheckBet(bet)
	if (rtick && c) {
		Pacific_ClickButton("Raise")
	}
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

;792x551 is the dimensions of the visible area of the default 800x578 window in Windows 2000
Pacific_AdjustSize(box, id = "") {
	local box0, box1, box2, box3, box4, w, h
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 792.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 551.0
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
Pacific_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 792.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 551.0
	x := Round(x * w)
	x += ResizeBorder
	y := Round(y * h)
	y += (ResizeBorderY + Caption)
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
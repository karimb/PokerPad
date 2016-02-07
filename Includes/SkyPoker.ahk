; ( [] )..( [] )   SkyPoker Implementation   ( [] )..( [] ) 

SkyPoker_Reload(max = true) {
	static MiniMenu := "466 6 40 10", MiniBuyChips := "435 53 50 9", GetChips := "242 576 80 14"
	if SkyPoker_IsMiniWindow() {
		ClickWindowArea(SkyPoker_MiniMenu, false)
		Sleep, 400
		ClickWindowArea(SkyPoker_MiniBuyChips, false)
	} else {
		ClickWindowArea(SkyPoker_GetChips, false)
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

SkyPoker_IsMiniWindow() {
	
	return width < 600
}

SkyPoker_GetBlind(big) {
	WinGetTitle, title
	RegExMatch(title, "\D?(\d+\.?\d*) / \D?(\d+\.?\d*)", match)
	blind := big ? match2 : match1
	return CurrencyToFloat(blind)
}

/* 
 * All boxes assume a window dimension of 808x627. The Windows theme MUST be Win2000
 * so change the the theme in WinXP/Win7 to Win2000 (sometimes called "Windows classic") before proceeding
 * all values must be reduced by 4 pixels in x and 23 in y (border width/height in Win2000)
 * For example, 600 300 10 5 becomes 596 277 10 5
 * The functions AdjustClick and AdjustSize then make adjustments for different window sizes and borders
 */
 
SkyPoker_CanBet(id = "") {
	local x, y, w, h, box
	box := SkyPoker_AdjustSize(SkyPoker_BetBox, id)
	GetWindowArea(x, y, w, h, box, false, id)
	Display_CreateWindowCapture(device, context, pixels, id)
	bgr := Display_GetPixel(context, x + w, y + 1)
	Display_DeleteWindowCapture(device, context, pixels, id)
	return (bgr = SkyPoker_CheckColor)
}

SkyPoker_CallBox(id = "") {
	local x, y, w, h, box
	box := SkyPoker_AdjustSize(SkyPoker_CheckorCallBox, id)
	GetWindowArea(x, y, w, h, box, false, id)
	return (Display_PixelSearch(x, y, w, h, SkyPoker_CheckColor, 0, id))
}
 
 SkyPoker() {
	global
	; These dimensions only work for a window which is 808x627 in size
    SkyPoker_Fold = 434 526 100 30
	SkyPoker_CheckFold = 434 526 100 30
	SkyPoker_Call = 554 526 100 30	
	SkyPoker_Raise = 661 526 100 30
	SkyPoker_FastFold = 434 526 100 30

	SkyPoker_AutoPost = 782 391 3 3
	SkyPoker_FoldAny = 434 526 100 30
	SkyPoker_SitOut = 10 407 3 3

	SkyPoker_AutoMuck = 782 411 3 3
	SkyPoker_AllIn = 700 526 70 15
	SkyPoker_LastHand = 305 15 40 5

	SkyPoker_Pot = 612 445 70 15
	SkyPoker_BetBox = 766 490 5 5
	SkyPoker_CheckColor = 0xFFFFFF
	
	; This is used to determine if the second button is a check button or a call button
	SkyPoker_CheckorCallBox = 558 557 100 25
	
	SkyPoker_GameWindow = / ahk_class ApolloRuntimeContentWindow
	SiteApolloRuntimeContentWindow = SkyPoker
	SkyPoker_LobbyWindow = Sky Poker ahk_class ApolloRuntimeContentWindow
	SkyPoker_LastHandWindow = Sky Poker ahk_class ApolloRuntimeContentWindow
	SetClientHotkeys("SkyPoker")
	GroupAdd, GameWindows, / ahk_class ApolloRuntimeContentWindow
	debug = 1
	return true
}

; is the second button a check button? If so, we click on it when we want to check fold.
SkyPoker_CheckFold(id = "") {
	if (!SkyPoker_CanBet(id))
		SkyPoker_ClickButton("CheckFold", id)
	else
		if (SkyPoker_CallBox(id))
			SkyPoker_ClickButton("CheckFold", id)
		else
			SkyPoker_ClickButton("Call",id)
}

;800x600 is the dimensions of the visible area of the default 808x627 window in Windows 2000
SkyPoker_AdjustSize(box, id = "") {
	local box0, box1, box2, box3, box4, w, h
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 800.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 600.0
	StringSplit, box, box, %A_Space%
	box1 *= w
	box1 += ResizeBorder
	box2 *= h
	box2 += (ResizeBorderY + Caption)
	box3 *= w
	box4 *= h
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


/* AdjustClick clicks to the area of the screen indicated by x and y
   with mouse button c (c=0 moves without click) 
*/
SkyPoker_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 800.0
	h -= (2 * ResizeBorderY + Caption)
	h /= 600.0
	x := Round(x * w)
	x += ResizeBorder
	y := Round(y * h)
	y += (ResizeBorderY + Caption)
	MouseGetPos, px, py
	Click %x% %y% %c%
	Click %px% %py% 0
	Sleep, 50
}


; We use the window handle when several fold are done in a row to make sure 
;they reach only one window
SkyPoker_ClickButton(button, id = "") {
	local x, y, w, h, bgr, box
	temp := button
	button := SkyPoker_%button%
	;MsgBox % "Before: " . button .  " After: " . SkyPoker_AdjustSize(button)
	box := SkyPoker_AdjustSize(button, id)
	GetWindowArea(x, y, w, h, box, false, id)
	;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	ClickWindowRect(x, y, w, h, id)
}

SkyPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, pot2
	
	SkyPoker_ClickButton("Pot")
	Sleep, 400
	;copy
	;SkyPoker_AdjustClick(749, 495)
	Send, {Home}+{End}^c
	Sleep, 200
	pot := Clipboard
	if !(factor * pot) 
		FileAppend, GetPot failed`n, PokerPad.log 
	return (factor * pot)
}

SkyPoker_CheckBet(bet) {
	Send, {Home}+{End}^c
	Sleep, 200
	if (Clipboard == bet)
		return 1
	else {
		FileAppend, Checking of the pot failed`n, PokerPad.log 
		return 0
	}
}

SkyPoker_Bet(ByRef betbox, bet = "") {
	SkyPoker_AdjustClick(749, 495)
	Bet(bet)
}

SkyPoker_BetRelativePot(factor) {
	local box, pot, round := SkyPoker_GetRound(Rounding, Rounding)
	if (SkyPoker_CanBet()) {
		bet := GetRoundedAmount(SkyPoker_GetPot(factor), round)
		SkyPoker_Bet(SkyPoker_BetBox, bet)
		local c:= SkyPoker_CheckBet(bet)
		if (c) {
			if (rtick)
				SkyPoker_ClickButton("Raise")
		}
		else
			SkyPoker_Bet(SkyPoker_BetBox, bet)
	}
}

SkyPoker_FixedBet(factor) {
	local pot
	if (SkyPoker_CanBet()) {
		pot := GetAmount(GetDollarRound(factor * SkyPoker_GetBlind(true)), SkyPoker_Decimal)
		SkyPoker_Bet(SkyPoker_BetBox, pot)
		local c := SkyPoker_CheckBet(pot)
		if (c) { 
			if (ftick)
				SkyPoker_ClickButton("Raise")
		}
		else
			SkyPoker_Bet(SkyPoker_BetBox, pot)
	}
}

SkyPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (!IsChecked(SkyPoker_SitOut, false, SkyPoker_CheckColor, id)) {
			ClickWindowArea(SkyPoker_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

SkyPoker_SitInAll(in) {
	global
	if !WinExist(SkyPoker_GameWindow)
		return
	SkyPoker_CheckAll(SkyPoker_SitOut, !in)
}

SkyPoker_AutoPostAll(on) {
	global
	if !WinExist(SkyPoker_GameWindow)
		return
	SkyPoker_CheckAll(SkyPoker_AutoPost, on)
}

SkyPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %SkyPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, SkyPoker_CheckColor, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}

SkyPoker_GetRound(rounding, default) {
	if (rounding < -1) 
		return SkyPoker_GetBlind(rounding+2)
	return default
}

SkyPoker_Activate:
	WinActivate, %SkyPoker_GameWindow%
	return
SkyPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
SkyPoker_Fold:
	SkyPoker_CheckFold(id)
	return
SkyPoker_Call:
	SkyPoker_ClickButton("Call")
	return
SkyPoker_Raise:
	SkyPoker_ClickButton("Raise")
	return
SkyPoker_FastFold:
	SkyPoker_CheckFold(id)
	return
SkyPoker_Relative1:
	SkyPoker_BetRelativePot(Relative1)
	return
SkyPoker_Relative2:
	SkyPoker_BetRelativePot(Relative2)
	return
SkyPoker_Relative3:
	SkyPoker_BetRelativePot(Relative3)
	return
SkyPoker_Relative4:
	SkyPoker_BetRelativePot(Relative4)
	return
SkyPoker_Relative5:
	SkyPoker_BetRelativePot(Relative5)
	return
SkyPoker_Relative6:
	SkyPoker_BetRelativePot(Relative6)
	return
SkyPoker_Relative7:
	SkyPoker_BetRelativePot(Relative7)
	return
SkyPoker_Relative8:
	SkyPoker_BetRelativePot(Relative8)
	return
SkyPoker_Relative9:
	SkyPoker_BetRelativePot(Relative9)
	return
SkyPoker_Fixed1:
	SkyPoker_FixedBet(Fixed1)
	return
SkyPoker_Fixed2:
	SkyPoker_FixedBet(Fixed2)
	return
SkyPoker_Fixed3:
	SkyPoker_FixedBet(Fixed3)
	return
SkyPoker_Fixed4:
	SkyPoker_FixedBet(Fixed4)
	return
SkyPoker_Fixed5:
	SkyPoker_FixedBet(Fixed5)
	return
SkyPoker_Fixed6:
	SkyPoker_FixedBet(Fixed6)
	return
SkyPoker_Fixed7:
	SkyPoker_FixedBet(Fixed7)
	return
SkyPoker_Fixed8:
	SkyPoker_FixedBet(Fixed8)
	return
SkyPoker_Fixed9:
	SkyPoker_FixedBet(Fixed9)
	return
SkyPoker_RandomBet:
	SkyPoker_BetRelativePot(GetRandomBet())
	return
SkyPoker_AllIn:
	SkyPoker_ClickButton("AllIn", id)
	return
SkyPoker_LastHand:
	SkyPoker_ClickButton("LastHand")
	return
SkyPoker_IncreaseBet:
SkyPoker_IncreaseBet2:
	SkyPoker_AdjustClick(665,497)
	Send, {Right}
	return
SkyPoker_DecreaseBet:
SkyPoker_DecreaseBet2:
	SkyPoker_AdjustClick(443,497)
	Send, {Left}
	return
SkyPoker_FoldAny:
	ClickWindowArea(SkyPoker_FoldAny, false)
	return
SkyPoker_AutoPost:
	ClickWindowArea(SkyPoker_AutoPost, false)
	return
SkyPoker_ToggleAutoMuck:
	ClickWindowArea(SkyPoker_AutoMuck, false)
	return
SkyPoker_AllInThisHand:
	SkyPoker_ClickButton("AllIn", id)
	;TrayTip, Not Supported!, All In*** is not supported for SkyPoker.
	return
SkyPoker_Reload:
	SkyPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
SkyPoker_Lobby:
	WinActivate, %SkyPoker_LobbyWindow%
	return
SkyPoker_SitOut:
	ClickWindowArea(SkyPoker_SitOut, false)
	return
SkyPoker_ClearBetBox:
	SkyPoker_Bet(SkyPoker_BetBox)
	return

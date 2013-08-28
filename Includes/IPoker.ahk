; ( [] )..( [] )   iPoker Implementation   ( [] )..( [] ) 

IPoker_Reload(max = true) {
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

IPoker_IsMiniWindow() {
	WinGetPos, , , width
	return width < 600
}

IPoker_GetBlind(big) {
	WinGetTitle, title
	StringGetPos, s, title, -, R1
	s += 3
	blind := SubStr(title, s)
	e := InStr(blind, "/")
	if !e {
		StringGetPos, s, title, -, R2
		s += 3
		e := InStr(title, " ", true, s)
		blind := SubStr(title, s, e-s)
		e := InStr(blind, "/")
	}
	blind := big ? SubStr(blind, e+1) : SubStr(blind, 1, e-1)

;remove euro and pound characters from blind
euro := Chr(128)
pound := Chr(163)
;StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?] 
StringReplace, blind, blind, %euro%, ,
StringReplace, blind, blind, %pound%, ,

return CurrencyToFloat(blind)

;MsgBox [, Options, Title, Text, Timeout]
; MsgBox ,,blind: %blind%, 1
; MsgBox blind: %blind%
}

/* 
 * All boxes assume a window dimension of 798x600. The Windows theme MUST be Win2000
 * so change the the theme in WinXP/Win7 to Win2000 before proceeding
 * all values must be reduced by 4 pixels in x and 4 in y (border width/height in Win2000)
 * For example, 600 300 10 5 becomes 596 296 10 5
 * The functions AdjustClick and AdjustSize then make adjustments for different window sizes and borders
 */

 
 IPoker() {
	local theme
	
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
	
	; These dimensions only work for a window which is 798x600 in size
    IPoker_Fold = 432 525 80 10
	IPoker_CheckFold = 432 550 80 10
	IPoker_Call = 551 531 60 24
	IPoker_Raise = 661 526 60 24
	IPoker_FastFold = 328 531 10 24

	IPoker_AutoPost = 720 590 5 5
	IPoker_FoldAny = 444 574 5 5
	IPoker_SitOut = 629 574 5 5

	IPoker_AutoMuck = 634 545 70 12
	IPoker_AllIn = 710 480 100 24
	IPoker_LastHand = 228 482 50 9

	IPoker_Pot = 374 76 60 22
	IPoker_BetBox = 711 508 40 6
	
	IPoker_PotButton1 = 435 475 80 7
	IPoker_PotButton2 = 548 475 80 7
	IPoker_PotButton3 = 660 475 80 7
	
	IPoker_ChatBox := CreateArea("16,534,360,60", 780, 557)
	
	IPoker_GameWindow = / ahk_class PTIODEVICE
	SitePTIODEVICE = IPoker
	IPoker_LobbyWindow = Nickname ahk_class PTIODEVICE
	IPoker_LastHandWindow = Hand history ahk_class PTIODEVICE
	SetClientHotkeys("IPoker")
	GroupAdd, GameWindows, / ahk_class PTIODEVICE
	return true
}

IPoker_AdjustSize(box) {
	local box0, box1, box2, box3, box4, w, h
	WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 790.0
	h -= 2 * ResizeBorderY
	h /= 592.0
	StringSplit, box, box, %A_Space%
	box1 *= w
	box1 += ResizeBorder
	box2 *= h
	box2 += ResizeBorderY
	box3 *= w
	box4 *= h
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


/* AdjustClick clicks to the area of the screen indicated by x and y
   with mouse button c (c=0 moves without click) 
*/
IPoker_AdjustClick(x, y, c = 1) {
	local px,py,w, h
	WinGetPos, , , w, h
	w -= 2 * ResizeBorder	
	w /= 790.0
	h -= 2 * ResizeBorderY
	h /= 592.0
	x := Round(x * w)
	x += ResizeBorder
	y := Round(y * h)
	y += ResizeBorderY
	MouseGetPos, px, py
	Click %x% %y% %c%
	Click %px% %py% 0
}

; Return true if the chat window is maximized 
IPoker_ChatMaximized() {
/*	
	local w,h,x,y,dx,bgr,bgr2
	;x := 265
	x := 380
	y := 509
	dy := 10
	WinGetPos, , , w, h
	w /= 800.0
	h /= 600.0
	x := Round(x * w)
	y := Round(y * h)
	dy := Round(dy * h)
	PixelGetColor, bgr, x, y
	PixelGetColor, bgr2, x, y+dy
	;MsgBox %bgr%, %bgr2%
	return Display_CompareColors(bgr, bgr2) 
*/
	return true
}

; We use the window handle when several fold are done in a row to make sure 
;they reach only one window
IPoker_ClickButton(button, id = "") {
	local x, y, w, h, bgr, box
	button := IPoker_%button%
	;MsgBox % "Before: " . button .  " After: " . IPoker_AdjustSize(button)
	box := IPoker_AdjustSize(button)
	GetWindowArea(x, y, w, h, box, false, id)
	;MsgBox, x: %x%, y: %y%, width: %w%, height: %h%
	if IPoker_ChatMaximized() {
		ClickWindowRect(x, y, w, h, id)
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
}

IPoker_GetPot(factor) {
	local x, y, w, h, device, context, pixels, box, pot, btn
	btn := SubStr(pot_ipoker, 8, 1)
	box := IPoker_AdjustSize(IPoker_PotButton%btn%)
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	Sleep, 400
	;select and copy
	IPoker_AdjustClick(711, 508)
	Send, {Home}+{End}^c
	Sleep, 50
	pot := Clipboard
	return (factor * pot)
}

Ipoker_CheckBet(bet) {
	IPoker_AdjustClick(711, 508)
	Send, {Home}+{End}^c
	Sleep, 50
	if (Clipboard == bet)
		return 1
	else
		return 0
}

IPoker_Bet(ByRef betbox, bet = "") {
	IPoker_AdjustClick(711, 508)
	Bet(bet)
}

IPoker_BetRelativePot(factor) {
	local box, pot, round := IPoker_GetRound(Rounding, Rounding)
	if IPoker_ChatMaximized() {
		bet := GetRoundedAmount(IPoker_GetPot(factor), round)
		if (factor != 1)
			IPoker_Bet(box, bet)
		if (rtick && Ipoker_CheckBet(bet))
		{
			IPoker_ClickButton("Raise")
		}
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
}

IPoker_FixedBet(factor) {
	local pot, box
	if IPoker_ChatMaximized() {
		pot := GetAmount(GetDollarRound(factor * IPoker_GetBlind(true)), IPoker_Decimal)
		IPoker_Bet(box, pot)
		if (ftick && Ipoker_CheckBet(pot) && factor < 200)
		{
			IPoker_ClickButton("Raise")
		}
	}
	else
		MsgBox PokerPad will not work if the chat window is not maximized.
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
	IPoker_ClickButton("FastFold", id)
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
	IPoker_ClickButton("LastHand")
	return
IPoker_IncreaseBet:
IPoker_IncreaseBet2:
	IPoker_AdjustClick(436,506)
	Send, {Right}
	return
IPoker_DecreaseBet:
IPoker_DecreaseBet2:
	IPoker_AdjustClick(436,506)
	Send, {Left}
	return
IPoker_FoldAny:
	ClickWindowArea(IPoker_FoldAny, false)
	return
IPoker_AutoPost:
	ClickWindowArea(IPoker_AutoPost, false)
	return
IPoker_ToggleAutoMuck:
	ClickWindowArea(IPoker_AutoMuck, false)
	return
IPoker_AllInThisHand:
	IPoker_Bet(IPoker_BetBox, 100000)
	;TrayTip, Not Supported!, All In*** is not supported for iPoker.
	return
IPoker_Reload:
	IPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
IPoker_Lobby:
	WinActivate, %IPoker_LobbyWindow%
	return
IPoker_SitOut:
	ClickWindowArea(IPoker_SitOut, false)
	return
IPoker_ClearBetBox:
	IPoker_Bet(IPoker_BetBox)
	return

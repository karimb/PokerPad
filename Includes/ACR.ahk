; ( [] )..( [] )   ACR Implementation   ( [] )..( [] ) 

ACR_GetBlind(big) {
	WinGetTitle, title
	if (ACR_UseBB())
		blind := big ? 1.0 : 0.5
	else {
	  RegExMatch(title, " \D?(\d+).?/\D?(\d+)", match)
	  if (InStr(title, "¢")) {
		  match1 /= 100.0
		  match2 /= 100.0
	  }
	  blind := big ? match2 : match1
	}
	return CurrencyToFloat(blind)
}

ACR_FormatAmount(amnt) {
	local pot
	if (ACR_UseBB())
	  pot := amnt
	else if (InStr(amnt, "¢")) 
		pot := SubStr(amnt, 1, StrLen(amnt) - 1)  / 100.0
	else if (InStr(amnt, "$"))
		pot := SubStr(amnt, 2)
    else
      pot := amnt
	return pot
}

ACR_UseBB() {
  IniRead, usebb, PokerPad.ini, ACR, UseBB, 0
  return usebb
}

ACR_CheckTimeBank(id, context) {
	local bgr,box,box0,box1,box2,box3,box4,color,diff, adjusted
	
	;the color is the orange used by the timebank button in BGR
	color := 0x20B5FC
	diff := 20
	adjusted := ACR_AdjustSize(ACR_TimeBank, id)
	StringSplit, box, adjusted, %A_Space%
	bgr := Display_GetPixel(context, box1, box2)
	;WriteLog("CheckTimeBank - box1: " box1 ", box2: " box2)
	;PixelGetColor, bgr, x, y
	return Display_CompareColors(bgr, color, diff)
}


/* 
 * All boxes assume a window dimension of 904x696. 
 * ACR doesn't use the system theme so we have to manually calculate the size of their decoration
 * Titlebar: 26 pixels 
 * Bottom padding: 2 pixels
 * Left padding: 0 pixels
 * Right padding: 0 pixels
 * The buttons stop growing in size once the resolution goes over 958x738
 */
ACR() {
	global
	; See above
	ACR_TopPadding := 26
	ACR_BottomPadding := 2
	ACR_MaxResX := 958
	ACR_MaxResY := 710 ; 738 - 26 - 2
	ACR_StdX := 904.0
	ACR_StdY := 668.0 ; 696 - 26 - 2 
	
	ACR_Fold := "440 630 80 20"
	ACR_CheckFold := "440 630 80 20"
	ACR_Call := "600 630 80 20"
	ACR_Raise := "770 630 80 20"
	;;ACR_FoldAny = 635 536 5 5

	;;ACR_AutoPost = 482 535 5 5
	;ACR_SitOut = 14 512 2 2

	;;ACR_AutoMuck = 
	;ACR_Lobby = 680 27 80 5
	;ACR_LastHand = 
	;ACR_Options =
	;ACR_Settings
	;ACR_TimeBank = 751 563 2 2
	;;ACR_Chat = 12 538 155 12
	
	;Just wheel up for now
	;ACR_IncreaseBet = 542 680 2 2
	;ACR_DecreaseBet = 308 680 2 2

	ACR_Pot := "860 575 5 2"
	ACR_PotButton2 := "660 575 5 2"
	ACR_PotButton3 := "725 575 5 2"
	ACR_PotButton4 := "790 575 5 2"
	ACR_PotButton5 := "860 575 5 2"
	
	ACR_BetBox := "860 600 10 5"

	ACR_GameWindow = / ahk_class Chrome_WidgetWin_1
	ACR_LobbyWindow = ACR Poker Lobby ahk_class Chrome_WidgetWin_1
	ACR_LastHandWindow = : ahk_class Chrome_WidgetWin_1
	; Same as Party :(
	SiteChrome_WidgetWin_1 = ACR
	SetClientHotkeys("ACR")
	GroupAdd, GameWindows, / ahk_class Chrome_WidgetWin_1
	; Timebank is automated - disabled
	;IniRead, timebank_pacific, PokerPad.ini, ACR, Timebank, 0
	; if (timebank_pacific)
	;	SetTimer ACR_AutoTimeBank, 4000
}


ACR_GetPot(factor) 
{
	local x, y, w, h, device, context, pixels, box, pot, pot2, btn
	btn := SubStr(pot_acr, 8, 1)
	box := ACR_AdjustSize(ACR_PotButton%btn%)
	GetWindowArea(x, y, w, h, box, false)
	ClickWindowRect(x, y, w, h)
	WriteLog("ACR - Pot Button - x: " x ", y:" y ", width: " w ", height:" h)
	Sleep, 100
	;select and copy
	pot := 1
	if (factor != 1) {
		ACR_AdjustClick()
		Send, {Home}+{End}^c
		Sleep, 50
		pot := Clipboard
		WriteLog("Clipboard amount: " pot)
		pot := ACR_FormatAmount(pot)
	}
	return (factor * pot)
}
	
ACR_CheckBet(bet) {
	ACR_AdjustClick()
	Send, {Home}+{End}^c
	Sleep, 50
	if (Clipboard == bet) {
		WriteLog("ACR - check bet successful")
		return 1
	}
	else {
		WriteLog("ACR - check bet failed")
		return 0
	}
}
	
ACR_Bet(bet = "") {
	ACR_AdjustClick()
	Bet2(bet)
}

ACR_BetRelativePot(factor) {
/*
	local press, c := 0, box, pot, round := ACR_GetRound(Rounding, Rounding)
	pot := ACR_GetPot(factor)
	if pot is not number 
		return
	if (pot != 1) {
		bet := GetRoundedAmount(pot, round)
		ACR_Bet(bet)
		c:= ACR_CheckBet(bet)
	}
	press := rtick && c
	if (press) {
		ACR_ClickButton("Raise")
	}
    ; removing the highlight around bet amount
	if (!press && pot != 1)
		ACR_AdjustClick()
*/
}

ACR_FixedBet(factor) {
	local pot, n
	pot := GetAmount(GetDollarRound(factor * ACR_GetBlind(true)), ACR_Decimal)
	ACR_Bet(pot)
	WriteLog("ACR - FixedBet with checkbet: " c " pot: " pot " n: " n)
	/* local c := ACR_CheckBet(pot)
	WriteLog("ACR - FixedBet with checkbet: " c " pot: " pot)
	if c is not number
		return
	if (ftick && c) {
		ACR_ClickButton("Raise")
	} 
	*/
}


ACR_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (!IsChecked(ACR_SitOut, false, ACR_CheckColor, id)) {
			ClickWindowArea(ACR_SitOut, false, id)
		}
		WinClose, ahk_id %id%
	}
}

ACR_SitInAll(in) {
	global
	if !WinExist(ACR_GameWindow)
		return
	ACR_CheckAll(ACR_SitOut, !in)
}

ACR_AutoPostAll(on) {
	global
	if !WinExist(ACR_GameWindow)
		return
	ACR_CheckAll(ACR_AutoPost, on)
}

ACR_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %ACR_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, false, ACR_CheckColor, id) != checked) {
			ClickWindowArea(checkbox, false, id)
		}
	}
}


ACR_GetRound(rounding, default) {
	if (rounding < -1)
		return ACR_GetBlind(rounding+2)
	return default
}

;952x735 is the dimensions of the visible area of the default 944x708 window in Windows 2000
;buttons increase in size proportionally up to resolution limit of x=1366
ACR_AdjustSize(box, id = "") {
	local box0, box1, box2, box3, box4, w, h, r
	if (id != "")
		WinGetPos, , , w, h, ahk_id %id%
	else
		WinGetPos, , , w, h
	WriteLog("ACR - AdjustSize Origin to Box: " box " w: " w " h: " h) 
	StringSplit, box, box, %A_Space%
	
	r := Min(ACR_MaxResX, w) / ACR_StdX
	box1 := ACR_StdX - box1
	box1 *= r
	box1 := w - box1
	box3 *= r
	
	h := h - (ACR_TopPadding + ACR_BottomPadding)
	r := Min(ACR_MaxResY, h) / ACR_StdY
	box2 := ACR_StdY - box2
	box2 *= r
	box2 := h - box2
	box2 += ACR_TopPadding
	box4 *= r
	WriteLog("ACR - AdjustSize to x: " Round(box1) " y: " Round(box2) " r: " r)
	return % Round(box1) . " " . Round(box2) . " " . Round(box3) . " " . Round(box4)
}


;AdjustClick clicks to the area of the screen indicated by x and y
;with mouse button c (c=0 moves without click)
;buttons increase in size proportionally up to resolution limit of 1366x768
ACR_AdjustClick(c = 1) {
	local px, py, w, h, r, box
	box := ACR_AdjustSize(ACR_BetBox)
	StringSplit, box, box, %A_Space%
	MouseGetPos, px, py
	Click %box1% %box2% %c%
	Click %px% %py% 0
	WriteLog("ACR - AdjustClick to x: " box1 " y: " box2 " click: " c)
	Sleep, 20
}

ACR_ClickButton(button, id = "") {
	local x, y, w, h, box, name
	name := button
	button := ACR_%button%
	box := ACR_AdjustSize(button, id)
	GetWindowArea(x, y, w, h, box, false, id)
	ClickWindowRect(x, y, w, h, id)	
	WriteLog(name " - x: " x ", y: " y ", id: " id )
}


ACR_IsChecked(ByRef checkbox, ByRef x = "", ByRef y = "", ByRef w = "", ByRef h = "") {
	GetWindowArea(x, y, w, h, checkbox, true)
	Display_CreateWindowCapture(device, context, pixels, id)
	bgr := Display_GetPixel(context, x + w, y + 1)
	Display_DeleteWindowCapture(device, context, pixels, id)
	return Display_IsRed(bgr)
}


ACR_Activate:
	WinActivate, %ACR_GameWindow%
	return
ACR_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
ACR_Fold:
	ACR_ClickButton("Fold", id)
	;ACR_ClickButton("CheckFold")
	return
ACR_Call:
	ACR_ClickButton("Call", id)
	return
ACR_Raise:
	ACR_ClickButton("Raise", id)
	return
ACR_Relative1:
	ACR_BetRelativePot(Relative1)
	return
ACR_Relative2:
	ACR_BetRelativePot(Relative2)
	return
ACR_Relative3:
	ACR_BetRelativePot(Relative3)
	return
ACR_Relative4:
	ACR_BetRelativePot(Relative4)
	return
ACR_Relative5:
	ACR_BetRelativePot(Relative5)
	return
ACR_Relative6:
	ACR_BetRelativePot(Relative6)
	return
ACR_Relative7:
	ACR_BetRelativePot(Relative7)
	return
ACR_Relative8:
	ACR_BetRelativePot(Relative8)
	return
ACR_Relative9:
	ACR_BetRelativePot(Relative9)
	return
ACR_RandomBet:
	ACR_BetRelativePot(GetRandomBet())
	return
ACR_Fixed1:
	ACR_FixedBet(Fixed1)
	return
ACR_Fixed2:
	ACR_FixedBet(Fixed2)
	return
ACR_Fixed3:
	ACR_FixedBet(Fixed3)
	return
ACR_Fixed4:
	ACR_FixedBet(Fixed4)
	return
ACR_Fixed5:
	ACR_FixedBet(Fixed5)
	return
ACR_Fixed6:
	ACR_FixedBet(Fixed6)
	return
ACR_Fixed7:
	ACR_FixedBet(Fixed7)
	return
ACR_Fixed8:
	ACR_FixedBet(Fixed8)
	return
ACR_Fixed9:
	ACR_FixedBet(Fixed9)
	return
ACR_AllIn:
	SendEvent, {WheelUp 1000}
	return
ACR_LastHand:
	ClickWindowArea2(ACR_LastHand)
	return
ACR_IncreaseBet:
ACR_IncreaseBet2:
	SendEvent, {WheelUp}
	;ACR_ClickButton("IncreaseBet")
	return
ACR_DecreaseBet:
ACR_DecreaseBet2:
    SendEvent, {WheelDown}
	;ACR_ClickButton("DecreaseBet")
	return
ACR_FoldAny:
	;ClickWindowArea2(ACR_FoldAny)
	return
ACR_AutoPost:
	;ClickWindowArea2(ACR_AutoPost)
	return
ACR_ToggleAutoMuck:
	;ClickWindowArea2(ACR_AutoMuck)
	return
ACR_AllInThisHand:
	TrayTip, Not Supported!, All In*** is not supported for ACR.
	return
ACR_Reload:
	; do nothing
	return
ACR_Lobby:
	ClickWindowArea2(ACR_Lobby)
	return
ACR_SitOut:
	ClickWindowArea2(ACR_SitOut)
	return
ACR_AutoTimeBank:
	/*WinGet Wnd, List, / ahk_class Qt5152QWindowOwnDC,,Lobby
	Loop, %Wnd% {
		id := Wnd%A_Index%
		Display_CreateWindowCapture(device, context, pixels, id)
		if (ACR_CheckTimeBank(id, context)) {
			;ClickWindowArea2(ACR_TimeBank,0, id)
			ACR_ClickButton("TimeBank", id)
		}
		Display_DeleteWindowCapture(device, context, pixels, id)
		ControlGet,visible,Visible,,,ahk_id %id%
		if visible
			DllCall("RedrawWindow","UInt",id,"UInt",0,"UInt",0,"UInt", 1|4|64|1024)
	}
	*/
	return
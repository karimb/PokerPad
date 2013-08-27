; ( [] )..( [] )   Poker Stars Implementation   ( [] )..( [] ) 

PokerStars_Read(key, ByRef theme = "") {
	if !theme {
		IniRead, theme, PokerPad.ini, PokerStars, Theme, %A_Space%
		theme = PokerStars%theme%
	}
	IniRead, option, PokerPad.ini, %theme%, %key%, %A_Space%
	return option
}


PokerStars_Reload(max = true) {
	local time
	static AddMoreChips := "Button4", MaximumBuyin := "Button1", OK := "Button3", Options
	if !Options {
		local theme
		Options := CreateArea(PokerStars_Read("Options", theme), PokerStars_Read("Width", theme), PokerStars_Read("Height", theme))
	}
	ClickWindowArea(Options)
	time := A_TickCount
	WinWaitActive, ^Options ahk_class #32770, , 5
	if ErrorLevel
		return

;	Sleep(time, 400)
;	ClickControl(AddMoreChips)
	ControlSend, %AddMoreChips%, {SPACE}

	time := A_TickCount
	WinWaitActive, ^Buy-in ahk_class #32770, , 5
	if ErrorLevel
		return
;	Sleep(time, 400)
	if max {
		ControlSend, %MaximumBuyin%, {SPACE}
;		ClickControl(MaximumBuyin)
;		Sleep, 400
	}
	ControlSend, %OK%, {SPACE}

;	if IsControlVisible(OK)
;		ClickControl(OK)
	/*
	WinWaitActive, PokerStars ahk_class #32770, , 5
	if !ErrorLevel
		AddCurrentIDToQueue("PokerStars_ReloadQueue")
	*/
}

PokerStars_GetBlind(big) {
	WinGetTitle, title
	if InStr(title, "Tournament")
		s := InStr(title, "- Blinds", true) + 9
	else
		s := InStr(title, " - ", true) + 3
	if big {
		s := InStr(title, "/", true, s) + 1
		e := InStr(title, " ", true, s)
	} else
		e := InStr(title, "/", true, s)
	blind := CurrencyToFloat(SubStr(title, s, e-s))
	return blind
}

PokerStars() {
	local theme, area, width, height
	width := PokerStars_Read("Width", theme)
	height := PokerStars_Read("Height", theme)
	local names := "Pot,Fold,Call,Raise,FoldAny,SitOut,AutoPost,LastHand,StandUp,Lobby,Options"
	Loop, Parse, names, `,
	{
		area := PokerStars_Read(A_LoopField, theme)
		if (area == "")
			return false
		PokerStars_%A_LoopField% := CreateArea(area, width, height)
	}
	PokerStars_ExcludeActionColor := PokerStars_Read("ExcludeActionColor")
	if !ReadColor(theme, "PokerStars", "ActionColor")
		return false
	if !ReadColor(theme, "PokerStars", "ButtonColor")
		return false
	if !ReadColor(theme, "PokerStars", "BoxColor")
		return false
	if !ReadColor(theme, "PokerStars", "PotBackground")
		return false
		
	PokerStars_FoldBoxX := 412/792
	PokerStars_CallBoxX := 539/792
	PokerStars_RaiseBoxX := 646/792
	PokerStars_BoxTop := 473/546
	PokerStars_BoxBottom := 495/546
	PokerStars_BoxWidth := 100/792
	PokerStars_BoxHeight := 10/546
	
	; windows
	PokerStars_GameWindow = ahk_class PokerStarsTableFrameClass
	SitePokerStarsTableFrameClass = PokerStars
	Tile_WidthPokerStarsTableFrameClass := 475
	Tile_RatioPokerStarsTableFrameClass := 475/328
	Tile_DragPokerStarsTableFrameClass := true
	PokerStars_LobbyWindow = ^PokerStars Lobby
	PokerStars_TournamentLobbyWindow = ^Tournament
	PokerStars_LastHandWindow = ^Instant Hand History ahk_class #32770
	
	; table controls
	PokerStars_BetAmount = PokerStarsSliderEditorClass1
	PokerStars_Chat = PokerStarsChatEditorClass1

	SetClientHotkeys("PokerStars")
	GroupAdd, GameWindows, ahk_class PokerStarsTableFrameClass
	return true
}

PokerStars_ClickButton(button) {
	local boxX := PokerStars_%button%BoxX, x, y, w, h, bgr, area
	if !InStr(A_ThisHotkey, "^") {
		area = %boxX% %PokerStars_BoxTop% %PokerStars_BoxWidth% %PokerStars_BoxHeight%
		GetWindowArea(x, y, w, h, area)
		PixelSearch, , , x, y, x+5, y+5, PokerStars_BoxColor, PokerStars_BoxColorVariation
		if !ErrorLevel {
			ClickWindowRect(x, y, w, h)
			return
		}
	}
	area = %boxX% %PokerStars_BoxBottom% %PokerStars_BoxWidth% %PokerStars_BoxHeight%
	GetWindowArea(x, y, w, h, area)
	PixelSearch, , , x, y, x+5, y+5, PokerStars_BoxColor, PokerStars_BoxColorVariation
	if !ErrorLevel {
		ClickWindowRect(x, y, w, h)
		return
	}
	area := PokerStars_%button%
	ClickWindowArea(area)
}

	
PokerStars_GetReadParameters(ByRef h, byRef v, ByRef maxWidth, ByRef exclude) {
	if (h < 12)
		h := 12
	v := Round((6 - h/2) * 6)
	if (v >= 0)
		v := 32
	else if (v > 16)
		v := 16
	else
		v += 32
	maxWidth := Round(h/2)
	exclude := h < 16 ? "0x326464,52" : "0x326464,100"
}

PokerStars_BetRelativePot(factor, round = 0) {
	global
	if !IsControlVisible(PokerStars_BetAmount)
		return
	ControlSetText, %PokerStars_BetAmount%
	local x, y, w, h, device, context, pixels
	GetWindowArea(x, y, w, h)
	x += Round(w/2)
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, limit := 1
	Display_FindPixelHorizontal(x, y, limit, h, PokerStars_PotBackground, 16, context)
	local potY := y
	local bgr, black := 0x303030, variation := 64
	Loop, %w% {
		bgr := Display_GetPixel(context, --x, y)
		if Display_CompareColors(bgr, black, variation)
			break
	}
	x++
	Display_FindPixelHorizontal(x, y, limit := 20, h, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; P
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; O
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; T
	local potX := x
	Display_FindPixelHorizontal(x, y, limit := 1, h, black, variation, context)
	local potH := y - potY - 1
	Display_FindPixelHorizontal(x, potY, w, limit := 1, black, variation, context)
	local potW := x - potX - 1
	local pot := CurrencyToFloat(Display_ReadArea(potX, potY, potW, potH, black, variation, c))
	GetWindowArea(x, y, w, h, PokerStars_Call, true)
	local call := 0, maxWidth
	if Display_PixelSearch(x, y, w, 1, PokerStars_ActionColor, 32, c) {
		y += Round(h * 0.75)
		Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
		PokerStars_GetReadParameters(h, v, maxWidth, exclude)
		call := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	}
	GetWindowArea(x, y, w, h, PokerStars_Raise, true)
	y += Round(h * 0.75)
	Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
	PokerStars_GetReadParameters(h, v, maxWidth, exclude)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	Display_DeleteWindowCapture(device, context, pixels)
	ControlSetText, % PokerStars_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, PokerStars_GetBlind(true)), PokerStars_GetRound(Rounding, Rounding))
}

PokerStars_FixedBet(factor) {
	global
	if !IsControlVisible(PokerStars_BetAmount)
		return
	ControlSetText, % PokerStars_BetAmount, % GetDollarRound(factor * PokerStars_GetBlind(true))
	Sleep, 400
	ClickWindowArea(PokerStars_Raise)
}


PokerStars_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsChecked(PokerStars_SitOut, true, 0x000000, id)) {
			ClickWindowArea(PokerStars_SitOut, true, id)
		}
		WinClose, ahk_id %id%
	}
}

PokerStars_ReloadQueue:
	PokerStars_ReloadQueue()
	return
PokerStars_ReloadQueue() {
	Critical, On ; this must be synchronized
	Loop, Parse, PokerStars_ReloadQueue, `,
	{
		id := ListGet(PokerStars_ReloadQueue, A_Index-1)
	}
	if !PokerStars_ReloadQueue
		SetTimer, PokerStars_ReloadQueue, Off
	Critical, Off

}


PokerStars_SitInAll(in) {
	global
	PokerStars_CheckAll(PokerStars_SitOut, !in)
}

PokerStars_AutoPostAll(on) {
	global
	PokerStars_CheckAll(PokerStars_AutoPost, on)
}

PokerStars_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %PokerStars_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsChecked(checkbox, true, 0x000000, id) != checked) {
			ClickWindowArea(checkbox, true, id)
		}
	}
}

PokerStars_GetRound(rounding, default) {
	if (rounding < -1) 
		return PokerStars_GetBlind(rounding+2)
	return default
}

PokerStars_AllInQueue:
	PokerStars_AllInQueue()
	return
PokerStars_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, PokerStars_AllInQueue, `,
	{
		id := A_LoopField
		if IsControlVisible(PokerStars_BetAmount, id) {
			ControlSetText, % PokerStars_BetAmount, 999999, ahk_id %id%
			Notify("Raise", id)
			ClickWindowArea(PokerStars_Raise, true, id)
		} else {
			local x, y, w, h
			GetWindowArea(x, y, w, h, PokerStars_Raise, true)
			local device, context, pixels
			Display_CreateWindowCapture(device, context, pixels, id)
			local bgr := Display_GetPixel(context, x, y)
			visible := Display_CompareColors(bgr, PokerStars_ButtonColor, PokerStars_ButtonColorVariation)
			Display_DeleteWindowCapture(device, context, pixels, id)
			if visible {
				if IsControlVisible(PokerStars_BetAmount, id) {
					ControlSetText, % PokerStars_BetAmount, 999999, ahk_id %id%
				}
				Notify("Raise", id)
				ClickWindowArea(PokerStars_Raise, true, id)
			} else
				continue
		}
		ListRemove(PokerStars_AllInQueue, A_Index-1)
	}
	if !PokerStars_AllInQueue
		SetTimer, PokerStars_AllInQueue, Off
	Critical, Off
}

PokerStars_Activate:
	WinActivate, %PokerStars_GameWindow%
	return
PokerStars_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, PokerStars_BetAmount)
	return
PokerStars_Fold:
	PokerStars_ClickButton("Fold")
	return
PokerStars_Call:
	PokerStars_ClickButton("Call")
	return
PokerStars_Raise:
	PokerStars_ClickButton("Raise")
	return
PokerStars_Relative1:
	PokerStars_BetRelativePot(Relative1)
	return
PokerStars_Relative2:
	PokerStars_BetRelativePot(Relative2)
	return
PokerStars_Relative3:
	PokerStars_BetRelativePot(Relative3)
	return
PokerStars_Relative4:
	PokerStars_BetRelativePot(Relative4)
	return
PokerStars_Relative5:
	PokerStars_BetRelativePot(Relative5)
	return
PokerStars_Relative6:
	PokerStars_BetRelativePot(Relative6)
	return
PokerStars_Relative7:
	PokerStars_BetRelativePot(Relative7)
	return
PokerStars_Relative8:
	PokerStars_BetRelativePot(Relative8)
	return
PokerStars_Relative9:
	PokerStars_BetRelativePot(Relative9)
	return
PokerStars_Fixed1:
	PokerStars_FixedBet(Fixed1)
	return
PokerStars_Fixed2:
	PokerStars_FixedBet(Fixed2)
	return
PokerStars_Fixed3:
	PokerStars_FixedBet(Fixed3)
	return
PokerStars_Fixed4:
	PokerStars_FixedBet(Fixed4)
	return
PokerStars_Fixed5:
	PokerStars_FixedBet(Fixed5)
	return
PokerStars_Fixed6:
	PokerStars_FixedBet(Fixed6)
	return
PokerStars_Fixed7:
	PokerStars_FixedBet(Fixed7)
	return
PokerStars_Fixed8:
	PokerStars_FixedBet(Fixed8)
	return
PokerStars_Fixed9:
	PokerStars_FixedBet(Fixed9)
	return
PokerStars_RandomBet:
	PokerStars_BetRelativePot(GetRandomBet())
	return
PokerStars_AllIn:
	if IsControlVisible(PokerStars_BetAmount)
		ControlSetText, % PokerStars_BetAmount, 999999
	return
PokerStars_LastHand:
	ClickWindowArea(PokerStars_LastHand)
	return
PokerStars_IncreaseBet:
	ControlIncreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment, 0))
	return
PokerStars_DecreaseBet:
	ControlDecreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment, 0))
	return
PokerStars_IncreaseBet2:
	ControlIncreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment2, 0))
	return
PokerStars_DecreaseBet2:
	ControlDecreaseAmount(PokerStars_BetAmount, PokerStars_GetRound(Increment2, 0))
	return
PokerStars_FoldAny:
	ClickWindowArea(PokerStars_FoldAny)
	return
PokerStars_AutoPost:
	ClickWindowArea(PokerStars_AutoPost)
	return
PokerStars_ToggleAutoMuck:
	WinMenuSelectItem, %PokerStars_LobbyWindow%, , Options, Muck Losing Hand
	WinMenuSelectItem, %PokerStars_LobbyWindow%, , Options, Don't Show Winning Hand
	return
PokerStars_AllInThisHand:
	AddCurrentIDToQueue("PokerStars_AllInQueue", 5000)
	return
PokerStars_Reload:
	PokerStars_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
PokerStars_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %PokerStars_LobbyWindow%
	else
		ClickWindowArea(PokerStars_Lobby)
	return
PokerStars_SitOut:
	ClickWindowArea(PokerStars_SitOut)
	return

PokerStars_2AC2BC1A1A: ; $ 2
	ErrorLevel = TwoDollar
	return
PokerStars_2BB2BB2BC2BC:
PokerStars_2AB2AB1D1A:
	ErrorLevel = $
	return
PokerStars_2BC1D1A1D:
PokerStars_2BC1C1B1C:
PokerStars_2BC1C1B1D:
PokerStars_2BC2BC2BC1D:
PokerStars_2BC1D1B1D:
PokerStars_2BC1D1D1D:
	ErrorLevel = 1
	return
PokerStars_1C2BC1B1D:
PokerStars_2BC2AC1B1D:
PokerStars_2AC1C1A1A:
PokerStars_2BC2AC1C1D:
	ErrorLevel = 2
	return
PokerStars_2BC2BB1B2AB:
PokerStars_1C2BB1B1A:
PokerStars_2BC2BB1B1A:
PokerStars_2AC1B1A2AB:
PokerStars_2AC2BB1A2AB:
PokerStars_2AC2BB1A1A:
PokerStars_3ABC1B1A2AB:
PokerStars_3ABC2AB1A2AB:
PokerStars_2BC1D1C2AC:
	ErrorLevel = 3
	return
PokerStars_3BBB1D1B1B:
PokerStars_2BB1D1B1B:
PokerStars_2BB1D1C1C:
	ErrorLevel = 4
	return
PokerStars_3ABC1B1B1A:
PokerStars_3ABC2AB1B1A:
	ErrorLevel = 5
	return
PokerStars_1B1C1B2BC:
PokerStars_1C2AC1B1C:
PokerStars_1C2AC1B1A:
PokerStars_1C2AC1B1B:
PokerStars_1C2AC2BC1C:
	ErrorLevel = 6
	return
PokerStars_1A1A1C1B:
	ErrorLevel = 7
	return
PokerStars_2BC2BB2BB1B:
PokerStars_2BC2BC1C1D:
PokerStars_1D1D1A1D:
PokerStars_1D1C1A1D:
PokerStars_1C2BC1D1D:
	ErrorLevel = 8
	return
PokerStars_2AC1B2AC1B:
PokerStars_2AC1B2AB1B:
PokerStars_1A1A1B1B:
	ErrorLevel = 9
	return
PokerStars_1D1B2BB2AC:
PokerStars_1D1B2AB1A:
PokerStars_1C1B2BB1B:
PokerStars_1D1C1A1A:
PokerStars_1C1C1B1B:
PokerStars_1C1D1C1C:
	ErrorLevel = 0
	return
PokerStars_1B1B2BB1B: ; 0 9
	if !ErrorLevel
		ErrorLevel = Display_IsFirstColumnNearBottom
	else
		ErrorLevel := ErrorLevel < 0 ? 9 : 0
	return
PokerStars_1B1B1B1B: ; 0 3 9
PokerStars_2BB1B1B1B: ; 4 9
	ErrorLevel = ZeroThreeFourEightNine
	return
PokerStars_2BC2AB1B2AB: ; 3 5
PokerStars_2AC1B1A1A: ; 3 5 $
	if !ErrorLevel
		ErrorLevel = Display_IsMiddle3Seq
	else
		ErrorLevel := ErrorLevel < 0 ? 3 : "ThreeFiveDollar"
	return
	
;HyperSimple
PokerStars_2AC2BC2AC1D:
PokerStars_2BC2AC1B1C:
PokerStars_2BC2AC1D1D:
	ErrorLevel = 1
	return
PokerStars_2AC1B1A2AC:
PokerStars_2AC2BC1B1D:
	ErrorLevel = 2
	return
PokerStars_3ABC2AB1A1A:
PokerStars_2AC2AC1B1A: ; 3 5
	ErrorLevel = ThreeFive
	return
PokerStars_3ABC1B1A1A:
PokerStars_2BC2AB1B1A:
PokerStars_3ABC2AC1A1A:
PokerStars_ABC2AC1A1A:
PokerStars_2BC1D1C1D:
	ErrorLevel = 3
	return
PokerStars_2AC2AB1C1A:
PokerStars_2AC2AC1A1A:
	ErrorLevel = 5
	return
PokerStars_1C2AB1B1A:
PokerStars_1B2AC1C1C:
PokerStars_1C2AC1C1C:
	ErrorLevel = 6
	return
PokerStars_1D2AC1D1D: ; 6 8
PokerStars_2AC1D1B1D:
PokerStars_1C1D1C1D:
	ErrorLevel = 8
	return
PokerStars_1B1A1C1B:
PokerStars_2AC1A1B1B:
PokerStars_2AC1A1C1B:
	ErrorLevel = 9
	return
PokerStars_1D1D1A1A:
PokerStars_1D1D1B1B:
	ErrorLevel = 0
	return
PokerStars_1B1D1B1B: ; 0 4
	ErrorLevel = ZeroThreeFourEightNine
	return
PokerStars_1B1A1B1B: ; 0 9
	if !ErrorLevel
		ErrorLevel = Display_IsFirstColumnNearBottom
	else
		ErrorLevel := ErrorLevel < 0 ? 9 : 0
	return
PokerStars_2BC2BC1B1D:
PokerStars_2AC2AC1A1D: ; 1 2
	if !ErrorLevel
		ErrorLevel = Display_IsMiddle3Seq
	else
		ErrorLevel := ErrorLevel < 0 ? 1 : 2
	return


/*
#Include Debug.ahk

F1::
	Run := false
	return
	
F2::
	Run := true
	if WinExist(PokerStars_GameWindow) {
		Loop {
			if !Run
				return
			Random, bet, 10, 99
			bet *= 10
			Random, bet, 1000, 2000
			ControlSetText, %PokerStars_BetAmount%, %bet%
			Sleep, -1
			raise := PokerStars_GetRaise()
			if (raise != bet)
				FileAppend, %Display_Signature%%raise%`n%bet%`n, Mappings.txt
		}
	}
	return


PokerStars_GetRaise() {
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, x, y, w, h, v, maxWidth, exclude
	GetWindowArea(x, y, w, h, PokerStars_Raise, true)
	y += Round(h * 0.75)
	Display_FindText(x, y, w, h, PokerStars_ActionColor, 32, context)
	PokerStars_GetReadParameters(h, v, maxWidth, exclude)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, PokerStars_ActionColor, v, c, maxWidth, PokerStars_ExcludeActionColor, "PokerStars_"))
	Display_DeleteWindowCapture(device, context, pixels)
	return raise	
}



F3::
	if WinExist(PokerStars_GameWindow) {
		println(PokerStars_GetPot())
;		println(Display_Signature)
	}
	return

PokerStars_GetPot() {
	local x, y, w, h, device, context, pixels
	GetWindowArea(x, y, w, h)
	x += Round(w/2)
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context, limit := 1
	Display_FindPixelHorizontal(x, y, limit, h, PokerStars_PotBackground, 16, context)
	local potY := y
	local bgr, black := 0x303030, variation := 64
	Loop, %w% {
		bgr := Display_GetPixel(context, --x, y)
		if Display_CompareColors(bgr, black, variation)
			break
	}
	x++
	Display_FindPixelHorizontal(x, y, limit := 20, h, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; P
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; O
	Display_FindPixelHorizontal(x, y, w, limit := 1, black, variation, context)
	Display_FindPixelHorizontal(x, y, w, limit := 1, PokerStars_PotBackground, variation, context) ; T
	local potX := x
	Display_FindPixelHorizontal(x, y, limit := 1, h, black, variation, context)
	local potH := y - potY - 1
	Display_FindPixelHorizontal(x, potY, w, limit := 1, black, variation, context)
	local potW := x - potX - 1
	local pot := CurrencyToFloat(Display_ReadArea(potX, potY, potW, potH, black, variation, c))
	Display_DeleteWindowCapture(device, context, pixels)
	return pot
}
*/
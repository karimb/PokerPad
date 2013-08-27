; ( [] )..( [] )   Full Tilt Implementation   ( [] )..( [] ) 

FullTilt_Reload(amount) {
	static GetChips := "FTCSkinButton42", MaximumBuyin := "Button2", OK := "FTCSkinButton1", Cancel := "FTCSkinButton2"
	if !IsControlVisible(GetChips)
		return
	ClickControl(GetChips)
	WinWaitActive, Get Chips ahk_class #32770, , 5
	if ErrorLevel
		return
	if amount {
		if (amount < 0) {
			if (IsControlVisible(MaximumBuyin) && IsControlEnabled(MaximumBuyin))
				ControlSend, %MaximumBuyin%, {Space}
		} else
			ControlSetText, Edit1, %amount%
	}
	if (IsControlVisible(OK) && IsControlEnabled(OK))
		ControlSend, %OK%, {Space}
	else if IsControlVisible(Cancel)
		ControlSend, %Cancel%, {Space}
}


FullTilt_GetBlind(big) {
	WinGetTitle, title
	s := InStr(title, " - ", true)
	if big {
		s := InStr(title, "/", true, s) + 1
		e := InStr(title, "-", true, s) - 1
	} else {
		s += 3
		e := InStr(title, "/", true, s)
	}
	blind := CurrencyToFloat(SubStr(title, s, e-s))
	return blind
}

FullTilt_IsRaceTrack() {
	WinGetPos, , , w
	ControlGetPos, x, , , , FTCSkinButton35
	return x > w/4
}

FullTilt() {
	global
	; Windows
	FullTilt_LobbyWindow = ahk_class FTCLobby
	FullTilt_TournamentLobbyWindow = ahk_class FTCLTourney
	FullTilt_GameWindow = ahk_class FTC_TableViewFull
	SiteFTC_TableViewFull = FullTilt
	Tile_WidthFTC_TableViewFull := 472
	Tile_RatioFTC_TableViewFull := 472/325
	FullTilt_LastHandWindow = ahk_class FTCLastHand
	; Table Controls
	FullTilt_FoldBox = FTCSkinButton29
	FullTilt_FoldBox2 = FTCSkinButton30
	FullTilt_CallBox = FTCSkinButton31
	FullTilt_CallBox2 = FTCSkinButton32
	FullTilt_RaiseBox = FTCSkinButton33
	FullTilt_RaiseBox2 = FTCSkinButton34
	
	FullTilt_Check = FTCSkinButton11
	FullTilt_Call = FTCSkinButton12
	FullTilt_Raise = FTCSkinButton13
	FullTilt_SitOut = FTCSkinButton36
	FullTilt_FoldAny = FTCSkinButton35
	FullTilt_Max = FTCSkinButton24
	FullTilt_Pot = FTCSkinButton25
	FullTilt_Pot2 = FTCSkinButton27
	FullTilt_Min = FTCSkinButton23
	FullTilt_BetAmount = Edit1
	FullTilt_Time = FTCSkinButton19
	FullTilt_Chat = Edit2
	FullTilt_DealMeIn = FTCSkinButton15
	; Ring Table Specific
	FullTilt_LastHandRing = FTCSkinButton3
	FullTilt_Lobby = FTCSkinButton8
	FullTilt_StandUp = FTCSkinButton6
	FullTilt_AutoPost = FTCSkinButton37
	; Tourny Table Specific
	FullTilt_LastHandTourny = FTCSkinButton4
	
	SetClientHotkeys("FullTilt")
	GroupAdd, GameWindows, ahk_class FTC_TableViewFull
	return true
}


FullTilt_AllInQueue:
	FullTilt_AllInQueue()
	return
FullTilt_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, FullTilt_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(FullTilt_Call, id)
			visible := 1
		if IsControlVisible(FullTilt_Raise, id)
			visible := 2
		if IsControlVisible(FullTilt_BetAmount, id) {
			ClickControl(FullTilt_Max, id)
			Sleep, 400
			Notify("Raise", id)
			ClickControl(FullTilt_Raise, id)
		} else if visible
			if (visible == 1) {
				Notify("Call", id)
				ClickControl(FullTilt_Call, id)
			} else {
				Notify("Raise", id)
				ClickControl(FullTilt_Raise, id)
			}
		else
			continue
		ListRemove(FullTilt_AllInQueue, A_Index-1)
	}
	if !FullTilt_AllInQueue
		SetTimer, FullTilt_AllInQueue, Off
	Critical, Off
}

FullTilt_BetRelativePot(factor) {
	local control
	if IsControlVisible(FullTilt_Pot)
		control := FullTilt_Pot
	else if IsControlVisible(FullTilt_Pot2) ; pot limit
		control := FullTilt_Pot2
	else {
		if IsControlVisible(FullTilt_Max)
			ClickControl(FullTilt_Max)
		return
	}
	ControlSetText, %FullTilt_BetAmount%
	local x, y, w, h
	GetControlArea(x, y, w, h, FullTilt_Raise, 0.2, 0.6, 0.6, 0)
	local device, context, pixels
	Display_CreateWindowCapture(device, context, pixels)
	local c := "c" . context
	local width
	WinGetPos, , , width
	width := width < 570 ? 4 : 0
	Display_FindText(x, y, w, h, "BlueBackground", 0, context)
	local raise := CurrencyToFloat(Display_ReadArea(x, y, w, h, "BlueBackground", 0, c, width, "GreenForeground", "FullTilt_"))
	ClickControl(control)
	Sleep, 20
	local pot
	ControlGetText, pot, %FullTilt_BetAmount%
	local call := 0
	local blind := FullTilt_GetBlind(true)
	if IsControlVisible(FullTilt_Call) {
		GetControlArea(x, y, w, h, FullTilt_Call, 0.2, 0.6, 0.6, 0)
		Display_FindText(x, y, w, h, "BlueBackground", 0, context)
		call := CurrencyToFloat(Display_ReadArea(x, y, w, h, "BlueBackground", 0, c, width, "GreenForeground", "FullTilt_"))
	}
	Display_DeleteWindowCapture(device, context, pixels)
	GetPot(pot, call, raise, blind)
	ControlSetText, % FullTilt_BetAmount, % GetRoundedAmount(GetBet(factor, pot, call, raise, blind), FullTilt_GetRound(Rounding, Rounding))
}

FullTilt_FixedBet(factor) {
	global
	if !IsControlVisible(FullTilt_BetAmount)
		return
	ControlSetText, % FullTilt_BetAmount, % GetDollarRound(factor * FullTilt_GetBlind(true))
	Sleep, 400
	ClickControl(FullTilt_Raise)
}


FullTilt_SitInAll(in) {
	local windows, id
	WinGet windows, List, %FullTilt_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlVisible(FullTilt_DealMeIn, id) == in) {
			ClickControl(in ? FullTilt_DealMeIn : FullTilt_SitOut, id)
		}
	}
}

FullTilt_IsChecked(ByRef control, ByRef id) {
	ControlGetPos, x, y, w, h, %control%, ahk_id %id%
	x += 2
	y += Ceil(h * 0.25)
	h := Floor(h * 0.5)
	return Display_PixelSearch(x, y, h, h, 0x000000, 16, id)
}

FullTilt_AutoPostAll(on) {
	local windows, id
	WinGet windows, List, %FullTilt_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (FullTilt_IsChecked(FullTilt_AutoPost, id) != on) {
			ClickControl(FullTilt_AutoPost, id)
		}
	}
}

FullTilt_CloseGameWindows(ByRef title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsControlVisible(FullTilt_DealMeIn, id) && IsControlEnabled(SitOut, id)) {
			ClickControl(FullTilt_SitOut, id)
		}
		WinClose, ahk_id %id%
	}
}


FullTilt_GetRound(rounding, default) {
	if (rounding < -1) 
		return FullTilt_GetBlind(rounding+2)
	return default
}


FullTilt_Activate:
	WinActivate, %FullTilt_GameWindow%
OnActivate_FTC_TableViewFull:
	ControlFocus, %FullTilt_Chat%, A
	return
FullTilt_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, FullTilt_BetAmount)
	return
FullTilt_Fold:
	if IsControlVisible(FullTilt_Check)
		ClickControl(FullTilt_Check)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_FoldBox))
		ClickControl(FullTilt_FoldBox)
	else if IsControlVisible(FullTilt_FoldBox2)
		ClickControl(FullTilt_FoldBox2)
	else if IsControlVisible(FullTilt_DealMeIn)
		ClickControl(FullTilt_DealMeIn)
	return
FullTilt_Call:
	if IsControlVisible(FullTilt_Call)
		ClickControl(FullTilt_Call)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_CallBox))
		ClickControl(FullTilt_CallBox)
	else if IsControlVisible(FullTilt_CallBox2)
		ClickControl(FullTilt_CallBox2)
	else if IsControlVisible(FullTilt_Check)
		ClickControl(FullTilt_Check)
	return
FullTilt_Raise:
	if IsControlVisible(FullTilt_Raise)
		ClickControl(FullTilt_Raise)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(FullTilt_RaiseBox))
		ClickControl(FullTilt_RaiseBox)
	else if IsControlVisible(FullTilt_RaiseBox2)
		ClickControl(FullTilt_RaiseBox2)
	else if IsControlVisible(FullTilt_Call)
		ClickControl(FullTilt_Call)
	return
FullTilt_Relative1:
	FullTilt_BetRelativePot(Relative1)
	return
FullTilt_Relative2:
	FullTilt_BetRelativePot(Relative2)
	return
FullTilt_Relative3:
	FullTilt_BetRelativePot(Relative3)
	return
FullTilt_Relative4:
	FullTilt_BetRelativePot(Relative4)
	return
FullTilt_Relative5:
	FullTilt_BetRelativePot(Relative5)
	return
FullTilt_Relative6:
	FullTilt_BetRelativePot(Relative6)
	return
FullTilt_Relative7:
	FullTilt_BetRelativePot(Relative7)
	return
FullTilt_Relative8:
	FullTilt_BetRelativePot(Relative8)
	return
FullTilt_Relative9:
	FullTilt_BetRelativePot(Relative9)
	return
FullTilt_Fixed1:
	FullTilt_FixedBet(Fixed1)
	return
FullTilt_Fixed2:
	FullTilt_FixedBet(Fixed2)
	return
FullTilt_Fixed3:
	FullTilt_FixedBet(Fixed3)
	return
FullTilt_Fixed4:
	FullTilt_FixedBet(Fixed4)
	return
FullTilt_Fixed5:
	FullTilt_FixedBet(Fixed5)
	return
FullTilt_Fixed6:
	FullTilt_FixedBet(Fixed6)
	return
FullTilt_Fixed7:
	FullTilt_FixedBet(Fixed7)
	return
FullTilt_Fixed8:
	FullTilt_FixedBet(Fixed8)
	return
FullTilt_Fixed9:
	FullTilt_FixedBet(Fixed9)
	return
FullTilt_RandomBet:
	FullTilt_BetRelativePot(GetRandomBet())
	return
FullTilt_AllIn:
	if IsControlVisible(FullTilt_BetAmount)
		ClickControl(FullTilt_Max)
	return
FullTilt_LastHand:
	ClickControl(IsControlVisible(FullTilt_LastHandRing) ? FullTilt_LastHandRing : FullTilt_LastHAndTourny)
	return
FullTilt_IncreaseBet:
	ControlIncreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment, 0))
	return
FullTilt_DecreaseBet:
	ControlDecreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment, 0))
	return
FullTilt_IncreaseBet2:
	ControlIncreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment2, 0))
	return
FullTilt_DecreaseBet2:
	ControlDecreaseAmount(FullTilt_BetAmount, FullTilt_GetRound(Increment2, 0))
	return
FullTilt_FoldAny:
	ClickControl(FullTilt_FoldAny)
	return
FullTilt_AutoPost:
	ClickControl(FullTilt_AutoPost)
	return
FullTilt_ToggleAutoMuck:
	WinMenuSelectItem, %FullTilt_LobbyWindow%, , Options, Auto Muck Hands
	return
FullTilt_AllInThisHand:
	AddCurrentIDToQueue("FullTilt_AllInQueue", 5000)
	return
FullTilt_Reload:
	FullTilt_Reload(InStr(A_ThisHotkey, "^") ? 0 : -1)
	return
FullTilt_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %FullTilt_LobbyWindow%
	else
		ClickControl(FullTilt_Lobby)
	return
FullTilt_SitOut:
	ClickControl(FullTilt_SitOut)
	return

	
FullTilt_2AB2AB1D1D:
FullTilt_2BB2BB1D1D:
	ErrorLevel = $
	return
FullTilt_2BC2AC1D1D:
	ErrorLevel = 2
	return
FullTilt_2AB2BC1B1C:
	ErrorLevel = 3
	return
FullTilt_1B1D1B1C:
FullTilt_1B1D1C1D:
	ErrorLevel = 4
	return
FullTilt_2BB2AB1C1B:
FullTilt_2AC2AB1C1D:
FullTilt_3ABC2AC1D1D:
	ErrorLevel = 5
	return
FullTilt_1B2BC1B1C:
FullTilt_1D2AC1C1C:
FullTilt_1D2AC1C1D:
FullTilt_1B2BC1D1D:
	ErrorLevel = 6
	return
FullTilt_2AC1A1D1A:
	ErrorLevel = 7
	return
FullTilt_1D1B1A1D:
	ErrorLevel = 8
	return
FullTilt_2AC1B1A1B:
FullTilt_2AC1D1A1D:
FullTilt_2AC1B1D1D:
FullTilt_1A1A1D1C:
	ErrorLevel = 9
	return
FullTilt_1D1D1C1D:
	ErrorLevel = 0
	return
FullTilt_1D1D1A1D: ; 0 8
FullTilt_2AC1D1D1D: ; 0 3 8 9
	ErrorLevel = ZeroThreeFourEightNine
	return
FullTilt_2BC2AC1C1D: ; 2 5
FullTilt_2AC2BC1D1D:
FullTilt_2AC2AC1D1D: ; 2 3 5 8
	ErrorLevel = TwoThreeFiveEight
	return
FullTilt_2BB1B1B1B: ; 3 9
	ErrorLevel = ThreeNine
	return

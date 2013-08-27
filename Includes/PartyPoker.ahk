; ( [] )..( [] )   Party Poker Implementation   ( [] )..( [] ) 

PartyPoker_Reload(max = true) {
	static GetChips := "AfxWnd90u8"
	ClickControl(GetChips)
	;WinWaitActive, Buy-In ahk_class #32770, , 5
	/*if ErrorLevel
		return
	*/
	;ControlSend, Button2, {SPACE}
	ControlSend, AfxWnd90u4, {SPACE}
}

	
PartyPoker_GetBlind(big) {
	local blind, title
	WinGetTitle, title
	RegExMatch(title, " \D?(\d+\.?\d*)/\D?(\d+\.?\d*)", match)
	blind := big ? match2 : match1
	return CurrencyToFloat(blind)
	;return CurrencyToFloat(SubStr(blind, s, e-s), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
}

PartyPoker() {
	global
	LoadCurrencyFormat("PartyPoker")

	
	PartyPoker_LobbyWindow = PartyPoker.com ahk_class #32770
	PartyPoker_TournamentLobbyWindow = Tournament lobby ahk_class #32770
	PartyPoker_GameWindow = / ahk_class #32770
	Site#32770 = PartyPoker
	Tile_AbsoluteWidth#32770 := 486
	Tile_Ratio#32770 := 486 / 363
	PartyPoker_LastHandWindow = HH ahk_class #32770
	; Table Controls
	PartyPoker_Fold = AfxWnd90u21
	PartyPoker_Call = AfxWnd90u22
	PartyPoker_Raise = AfxWnd90u23
	
	PartyPoker_FoldBox = AfxWnd90u27
	PartyPoker_FoldBox2 = AfxWnd90u26
	PartyPoker_CallBox = AfxWnd42u22
	PartyPoker_CallBox2 = AfxWnd42u25
	PartyPoker_CallRaise = AfxWnd42u26
	PartyPoker_CallRaise2 = AfxWnd42u27
	
	PartyPoker_SitOut = Button5
	PartyPoker_BetAmount = Edit2
	PartyPoker_Chat = Edit1
	PartyPoker_FoldAny = AfxWnd90u37
	PartyPoker_AutoMuck = Button2
	PartyPoker_Pot = Static12
	PartyPoker_Lobby = AfxWnd90u48
	PartyPoker_LastHand = AfxWnd90u50
	PartyPoker_Time = AfxWnd42u37
	; Ring Table Specific
	PartyPoker_StandUp = Button4
	PartyPoker_AutoPost = Button1
	
	SetClientHotkeys("PartyPoker")
	GroupAdd, GameWindows, "- ahk_class #32770"
	return true
}

	
PartyPoker_BetRelativePot(factor) {
	local pot, call, raise, s
	if !IsControlVisible(PartyPoker_BetAmount)
		return
		
	ControlGetText, pot, %PartyPoker_Pot%
	StringGetPos, s, pot, %A_Space%, R
	pot := CurrencyToFloat(SubStr(pot, s+2), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	local call
	ControlGetText, call, %PartyPoker_Call%
	s := InStr(call, "(")
	if s {
		s += 1
		call := CurrencyToFloat(SubStr(call, s, StrLen(call)-s-1), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	} else
		call := 0
	local raise, r
	local blind := PartyPoker_GetBlind(true)
	/*Loop {
		ControlGetText, raise, %PartyPoker_Raise%
		if (r == raise) {
			break
		}
		r := raise
		raise -= blind
		ControlSetText, %PartyPoker_BetAmount%, %raise%
	}
	*/
	ControlGetText, raise, %PartyPoker_Raise%
	s := InStr(raise, "to `n")
	if s {
		s += 4
		raise := CurrencyToFloat(SubStr(raise, s, StrLen(raise)-s), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
	} else
		raise := 0
	;MsgBox pot %pot% call %call% raise %raise%
	ControlSetText, % PartyPoker_BetAmount, % GetAmount(GetRoundedAmount(GetBet(factor, pot, call, raise, PartyPoker_GetBlind(true)), PartyPoker_GetRound(Rounding, Rounding)), PartyPoker_Decimal)
	if (rtick) {
		Sleep, 400
		ClickControl(PartyPoker_Raise)
	}
}
	
PartyPoker_FixedBet(factor) {
	global
	local y, z
	if !IsControlVisible(PartyPoker_BetAmount)
		return
	ControlGetText, y, % PartyPoker_BetAmount 
	z := GetAmount(GetDollarRound(factor * PartyPoker_GetBlind(true)), PartyPoker_Decimal)
	if (z >= y) {
		ControlSetText, % PartyPoker_BetAmount, % z
		if (ftick) {
			Sleep, 400
			ClickControl(PartyPoker_Raise)
		}
	}
}

PartyPoker_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (!IsControlChecked(PartyPoker_SitOut, id) && IsControlVisible(PartyPoker_SitOut, id))
			ClickControl(PartyPoker_SitOut, id)
		WinClose, ahk_id %id%
	}
}

PartyPoker_SitInAll(in) {
	global
	PartyPoker_CheckAll(PartyPoker_SitOut, !in)
}

PartyPoker_AutoPostAll(on) {
	global
	PartyPoker_CheckAll(PartyPoker_AutoPost, on)
}

PartyPoker_CheckAll(ByRef checkbox, checked) {
	local windows, id
	WinGet windows, List, %PartyPoker_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlChecked(checkbox, id) != checked && IsControlVisible(checkbox, id))
			ClickControl(checkbox, id)
	}
}


PartyPoker_GetRound(rounding, default) {
	if (rounding < -1) 
		return PartyPoker_GetBlind(rounding+2)
	return default
}

PartyPoker_AllInQueue:
	PartyPoker_AllInQueue()
	return
PartyPoker_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, PartyPoker_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(PartyPoker_Call, id)
			visible := 1
		if IsControlVisible(PartyPoker_Raise, id)
			visible := 2
		if IsControlVisible(PartyPoker_BetAmount, id) {
			ControlSetText, % PartyPoker_BetAmount, 999999, ahk_id %id%
			Notify("Raise", id)
			ClickControl(PartyPoker_Raise, id)
		} else if visible {
			if (visible == 1) {
				Notify("Call", id)
				ClickControl(PartyPoker_Call, id)
			} else {
				Notify("Raise", id)
				ClickControl(PartyPoker_Raise, id)
			}
			visible := 0
		} else
			continue
		ListRemove(PartyPoker_AllInQueue, A_Index-1)
	}
	if !PartyPoker_AllInQueue
		SetTimer, PartyPoker_AllInQueue, Off
	Critical, Off
}
	


PartyPoker_Activate:
	WinActivate, %PartyPoker_GameWindow%
	return
PartyPoker_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey, PartyPoker_BetAmount)
	return
PartyPoker_Fold:
	if IsControlVisible(PartyPoker_Fold)
		ClickControl(PartyPoker_Fold)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_FoldBox))
		ClickControl(PartyPoker_FoldBox)
	else if IsControlVisible(PartyPoker_FoldBox2)
		ClickControl(PartyPoker_FoldBox2)
	return
PartyPoker_Call:
	if IsControlVisible(PartyPoker_Call)
		ClickControl(PartyPoker_Call)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_CallBox))
		ClickControl(PartyPoker_CallBox)
	else if IsControlVisible(PartyPoker_CallBox2)
		ClickControl(PartyPoker_CallBox2)
	return
PartyPoker_Raise:
	if IsControlVisible(PartyPoker_Raise)
		ClickControl(PartyPoker_Raise)
	else if (!InStr(A_ThisHotkey, "^") && IsControlVisible(PartyPoker_RaiseBox))
		ClickControl(PartyPoker_RaiseBox)
	else if IsControlVisible(PartyPoker_RaiseBox2)
		ClickControl(PartyPoker_RaiseBox2)
	return
PartyPoker_Relative1:
	PartyPoker_BetRelativePot(Relative1)
	return
PartyPoker_Relative2:
	PartyPoker_BetRelativePot(Relative2)
	return
PartyPoker_Relative3:
	PartyPoker_BetRelativePot(Relative3)
	return
PartyPoker_Relative4:
	PartyPoker_BetRelativePot(Relative4)
	return
PartyPoker_Relative5:
	PartyPoker_BetRelativePot(Relative5)
	return
PartyPoker_Relative6:
	PartyPoker_BetRelativePot(Relative6)
	return
PartyPoker_Relative7:
	PartyPoker_BetRelativePot(Relative7)
	return
PartyPoker_Relative8:
	PartyPoker_BetRelativePot(Relative8)
	return
PartyPoker_Relative9:
	PartyPoker_BetRelativePot(Relative9)
	return
PartyPoker_Fixed1:
	PartyPoker_FixedBet(Fixed1)
	return
PartyPoker_Fixed2:
	PartyPoker_FixedBet(Fixed2)
	return
PartyPoker_Fixed3:
	PartyPoker_FixedBet(Fixed3)
	return
PartyPoker_Fixed4:
	PartyPoker_FixedBet(Fixed4)
	return
PartyPoker_Fixed5:
	PartyPoker_FixedBet(Fixed5)
	return
PartyPoker_Fixed6:
	PartyPoker_FixedBet(Fixed6)
	return
PartyPoker_Fixed7:
	PartyPoker_FixedBet(Fixed7)
	return
PartyPoker_Fixed8:
	PartyPoker_FixedBet(Fixed8)
	return
PartyPoker_Fixed9:
	PartyPoker_FixedBet(Fixed9)
	return
PartyPoker_RandomBet:
	PartyPoker_BetRelativePot(GetRandomBet())
	return
PartyPoker_AllIn:
	if IsControlVisible(PartyPoker_BetAmount)
		ControlSetText, % PartyPoker_BetAmount, 999999
	return
PartyPoker_LastHand:
	ClickControl(PartyPoker_LastHand)
	return
PartyPoker_IncreaseBet:
	ControlIncreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment, 0), PartyPoker_Decimal)
	return
PartyPoker_DecreaseBet:
	ControlDecreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment, 0), PartyPoker_Decimal)
	return
PartyPoker_IncreaseBet2:
	ControlIncreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment2, 0), PartyPoker_Decimal)
	return
PartyPoker_DecreaseBet2:
	ControlDecreaseAmount(PartyPoker_BetAmount, PartyPoker_GetRound(Increment2, 0), PartyPoker_Decimal)
	return
PartyPoker_FoldAny:
	if IsControlVisible(PartyPoker_FoldAny)
		ClickControl(PartyPoker_FoldAny)
	return
PartyPoker_AutoPost:
	if IsControlVisible(PartyPoker_AutoPost)
		ClickControl(PartyPoker_AutoPost)
	return
PartyPoker_ToggleAutoMuck:
	if IsControlVisible(PartyPoker_AutoMuck)
		ClickControl(PartyPoker_AutoMuck)
	return
PartyPoker_AllInThisHand:
	AddCurrentIDToQueue("PartyPoker_AllInQueue", 5000)
	return
PartyPoker_Reload:
	PartyPoker_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
PartyPoker_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %PartyPoker_LobbyWindow%
	else
		ClickControl(PartyPoker_Lobby)
	return
	return
PartyPoker_SitOut:
	if IsControlVisible(PartyPoker_SitOut)
		ClickControl(PartyPoker_SitOut)
	return

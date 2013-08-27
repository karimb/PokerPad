; ( [] )..( [] )   Ongame Implementation   ( [] )..( [] ) 

Ongame_SitOut() {
	static out := "Button7"
	if IsControlVisible(out) {
		ClickControl(out)
		return true
	}
	return false
}

Ongame_SitIn() {
	static in := "Button6"
	if IsControlVisible(in)
		ClickControl(in)
}

Ongame_Reload(max) {
	static Cashier := "Button10", OK := "Button12"
	sitin := Ongame_SitOut()
	ClickControl(Cashier)
	Sleep, 100
	ClickControl(OK)
	Sleep, 100
	if sitin
		Ongame_SitIn()
}

Ongame_GetBlind(big) {
	local title, s, e
	WinGetTitle, title
	StringGetPos, s, title, -, R
	if InStr(title, "Tournament:") {
		if big {
			s += 3
			StringGetPos, e, title, %A_Space%, L, s
			e++
		} else {
			e := s
			StringGetPos, s, title, %A_Space%, R, StrLen(title)-e+1
			s += 2
		}
	} else {
		if big {
			s += 2
			StringGetPos, e, title, %A_Space%, L, s
			e++
		} else {
			e := s+1
			StringGetPos, s, title, %A_Space%, R, StrLen(title)-s
			s += 2
		}
	}
	return CurrencyToFloat(SubStr(title, s, e-s), Ongame_Currency, Ongame_Separator, Ongame_Decimal)
}

Ongame() {
	global
	Ongame_LobbyWindow = Welcome ahk_class AfxFrameOrView70u
	Ongame_GameWindow = \$ ahk_class AfxFrameOrView70u
	SiteAfxFrameOrView70u = Ongame

	Ongame_OK = button48
	
	Ongame_Lobby = Button11
	Ongame_GetChips = Button10
	
	LoadCurrencyFormat("Ongame")
	
	Ongame_SitIn = Button6
	Ongame_SitOut = Button7
	Ongame_StandUp = Button9
	
	Ongame_Fold = Button29
	Ongame_Call = Button28
	Ongame_Check = Button27
	Ongame_Raise = Button30
	Ongame_Bet = Button26
	Ongame_CheckBox = Button47
	Ongame_FoldBox = Button46
	Ongame_CallBox = Button48
	Ongame_CallAnyBox = Button49
	Ongame_RaiseBox = Button50
	Ongame_RaiseAnyBox = Button51

	Ongame_BetAmount = RichEdit20W3
	Ongame_Bet = AfxWnd70u53
	Ongame_Pot = AfxWnd70u54
	Ongame_Cost = AfxWnd70u58
	
	
	SetClientHotkeys("Ongame")
	GroupAdd, GameWindows, \$ ahk_class AfxFrameOrView70u
	return true
}

Ongame_OpenPreferences() {
	local gameplay := "AfxWnd70u3"
	WinMenuSelectItem, %Ongame_LobbyWindow%, , Options, Preferences
	if ErrorLevel
		return false
	WinWaitActive, Preference ahk_class AfxFrameOrView70u, , 5
	if ErrorLevel
		return false
	ClickControl(gameplay)
	return true
}

Ongame_Bet(bet = "") {
	global
	ControlFocus, %Ongame_BetAmount%
	if (Ongame_Decimal && bet)
		StringReplace, bet, bet, ., % Ongame_Decimal
	Bet(bet)
}


Ongame_ToggleAutoMuck() {
	local mucklosing := "Button21", muckuncalled := "Button22"
	Ongame_OpenPreferences()
	ClickControl(mucklosing)
	ClickControl(muckuncalled)
	ClickControl(Ongame_OK)
}

Ongame_LastHand() {
	local x, y, w, h
	WinGetPos, x, y, w, h
	x += w - Border - 140
	y += Caption + Border + 5
	h := 10
	w := 130
	ClickWindowRect(x, y, w, h)
}

Ongame_CurrencyToFloat(amount) {
	local s := InStr(amount, A_Space) + 1
	amount := SubStr(amount, s)
	return CurrencyToFloat(amount, Ongame_Currency, Ongame_Separator, Ongame_Decimal)
}


Ongame_BetRelativePot(factor) {
	local pot
	if !IsControlVisible(Ongame_BetAmount)
		return
	ControlGetText, pot, % Ongame_Pot
	pot := Ongame_CurrencyToFloat(pot)
	local cost := 0
	if IsControlVisible(Ongame_Cost) {
		ControlGetText, cost, %Ongame_Cost%
		cost := Ongame_CurrencyToFloat(cost)
	}
	pot += cost
	pot *= factor
	pot += cost
	pot := GetRoundedAmount(pot, Ongame_GetRound(Rounding, Rounding))
	Ongame_Bet(pot)
}

Ongame_FixedBet(factor) {
	local b
	if !IsControlVisible(Ongame_BetAmount)
		return
	local bet := factor * Ongame_GetBlind(true)
	ControlGetText, b, % Ongame_Bet
	local c := 0
	if IsControlVisible(Ongame_Cost) {
		ControlGetText, c, % Ongame_Cost
		c := Ongame_CurrencyToFloat(c)
	}
	bet -= b - c
	Ongame_Bet(bet)
	Sleep, 400
	Send, {F3}
}

Ongame_GetRound(rounding, default) {
	if (rounding < -1) {
		return Ongame_GetBlind(rounding+2)
	}
	return default
}

Ongame_SitInAll(in) {
	local windows, id, x, y, w, h
	WinGet windows, List, %Ongame_GameWindow%
	Loop, %windows%	{
		id := windows%A_Index%
		if (IsControlVisible(Ongame_SitIn, id) == in)
			ClickControl(in ? Ongame_SitIn : Ongame_SitOut, id)
	}
}

Ongame_AutoPostAll(on) {
	local autopost := "Button20"
	if !Ongame_OpenPreferences()
		return
	if (IsControlChecked(autopost) != on)
		ClickControl(autopost)
	ClickControl(Ongame_OK)
}

Ongame_ToggleAutoPost() {
	static autopost := "Button21"
	sitin := Ongame_SitOut()
	Sleep, 100
	ClickControl(autopost)
	Sleep, 100
	if sitin
		Ongame_SitIn()
}


Ongame_CloseGameWindows(title) {
	local windows, id
	WinGet windows, List, %title%
	Loop, %windows%	{
 		id := windows%A_Index%
		if (IsControlVisible(Ongame_SitOut, id))
			ClickControl(Ongame_SitOut, id)
		WinClose, ahk_id %id%
	}
}


Ongame_AllInQueue:
	Ongame_AllInQueue()
	return
	
Ongame_AllInQueue() {
	local id, visible
	Critical, On ; this is a synchronized function
	Loop, Parse, Ongame_AllInQueue, `,
	{
		id := A_LoopField
		visible := 0
		if IsControlVisible(Ongame_Call, id)
			visible := 1
		if IsControlVisible(Ongame_Raise, id)
			visible := 2
		if IsControlVisible(Ongame_BetAmount, id) {
			WinActivate, ahk_id %id%
			WinWaitActive, ahk_id %id%, , 1
			if ErrorLevel
				continue
			Ongame_Bet(999999)
			Notify("Raise", id)
			Send, {F3}{F3}
		} else if visible {
			WinActivate, ahk_id %id%
			WinWaitActive, ahk_id %id%, , 1
			if (visible == 1) {
				Notify("Call", id)
				Send, {F2}
			} else {
				Notify("Raise", id)
				Send, {F3}
			}
		} else
			continue
		ListRemove(Ongame_AllInQueue, A_Index-1)
	}
	if !Ongame_AllInQueue
		SetTimer, Ongame_AllInQueue, Off
	Critical, Off
}


Ongame_Activate:
	WinActivate, %Ongame_GameWindow%
	return
Ongame_NumpadDigit:
	ForwardNumpadKey(A_ThisHotkey)
	return
Ongame_FoldAny:
Ongame_Fold:
	if IsControlVisible(Ongame_Check)
		Send, {F2}
	else if IsControlVisible(Ongame_Fold)
		Send, {F1}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_CheckBox) && IsControlEnabled(Ongame_CheckBox)))
		Send, {F2} ;	ClickControl(Ongame_CheckBox)
	else if (IsControlVisible(Ongame_FoldBox) && IsControlEnabled(Ongame_FoldBox))
		Send, {F1} ;	ClickControl(Ongame_FoldBox)
	return
Ongame_Call:
	if (IsControlVisible(Ongame_Check) || IsControlVisible(Ongame_Call))
		Send, {F2}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_CallBox) && IsControlEnabled(Ongame_CallBox)))
		Send, {F2} ;	ClickControl(Ongame_CallBox)
	else if (IsControlVisible(Ongame_CallAnyBox) && IsControlEnabled(Ongame_CallAnyBox))
		ClickControl(Ongame_CallAnyBox)
	return
Ongame_Raise:
	if (IsControlVisible(Ongame_Raise) || IsControlVisible(Ongame_Bet))
		Send, {F3}
	else if (!InStr(A_ThisHotkey, "^") && (IsControlVisible(Ongame_RaiseBox) && IsControlEnabled(Ongame_RaiseBox)))
		ClickControl(Ongame_RaiseBox)
	else if (IsControlVisible(Ongame_RaiseAnyBox) && IsControlEnabled(Ongame_RaiseAnyBox))
		ClickControl(Ongame_RaiseAnyBox)
	return
Ongame_Relative1:
	Ongame_BetRelativePot(Relative1)
	return
Ongame_Relative2:
	Ongame_BetRelativePot(Relative2)
	return
Ongame_Relative3:
	Ongame_BetRelativePot(Relative3)
	return
Ongame_Relative4:
	Ongame_BetRelativePot(Relative4)
	return
Ongame_Relative5:
	Ongame_BetRelativePot(Relative5)
	return
Ongame_Relative6:
	Ongame_BetRelativePot(Relative6)
	return
Ongame_Relative7:
	Ongame_BetRelativePot(Relative7)
	return
Ongame_Relative8:
	Ongame_BetRelativePot(Relative8)
	return
Ongame_Relative9:
	Ongame_BetRelativePot(Relative9)
	return
Ongame_RandomBet:
	Ongame_BetRelativePot(GetRandomBet())
	return
Ongame_Fixed1:
	Ongame_FixedBet(Fixed1)
	return
Ongame_Fixed2:
	Ongame_FixedBet(Fixed2)
	return
Ongame_Fixed3:
	Ongame_FixedBet(Fixed3)
	return
Ongame_Fixed4:
	Ongame_FixedBet(Fixed4)
	return
Ongame_Fixed5:
	Ongame_FixedBet(Fixed5)
	return
Ongame_Fixed6:
	Ongame_FixedBet(Fixed6)
	return
Ongame_Fixed7:
	Ongame_FixedBet(Fixed7)
	return
Ongame_Fixed8:
	Ongame_FixedBet(Fixed8)
	return
Ongame_Fixed9:
	Ongame_FixedBet(Fixed9)
	return
Ongame_AllIn:
	Ongame_Bet(999999)
	return
Ongame_LastHand:
	Ongame_LastHand()
	return
Ongame_IncreaseBet:
Ongame_IncreaseBet2:
	ControlFocus, %Ongame_BetAmount%
	Send, {Up}
	return
Ongame_DecreaseBet:
Ongame_DecreaseBet2:
	ControlFocus, %Ongame_BetAmount%
	Send, {Down}
	return
Ongame_AutoPost:
	Ongame_ToggleAutoPost()
	return
Ongame_ToggleAutoMuck:
	Ongame_ToggleAutoMuck()
	return
Ongame_AllInThisHand:
	AddCurrentIDToQueue("Ongame_AllInQueue", 5000)
	return
Ongame_Reload:
	Ongame_Reload(InStr(A_ThisHotkey, "^") ? false : true)
	return
Ongame_Lobby:
	if InStr(A_ThisHotkey, "+")
		WinActivate, %Ongame_LobbyWindow%
	else
		ClickControl(Ongame_Lobby)
	return
Ongame_SitOut:
	ClickControl(Ongame_SitOut)
	return
Ongame_ClearBetBox:
	Send, {Enter}
	return
	

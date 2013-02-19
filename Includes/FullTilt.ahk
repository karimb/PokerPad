

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
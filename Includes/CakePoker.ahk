
CakePoker_Reload(max) {
	static GetChips := "360 122 70 20", AddChips := "TTntButton.UnicodeClass3", MaximumBuyin := "TTntRadioButton.UnicodeClass2", OK := "TTntButton.UnicodeClass2"
	ClickWindowArea(GetChips, false)
	time := A_TickCount
	WinWaitActive, ahk_class TfrmOptions\.UnicodeClass, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	ClickControl(AddChips)
	time := A_TickCount
	WinWaitActive, ahk_class TfrmBuyIn\.UnicodeClass, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	if max {
		ClickControl(MaximumBuyin)
		Sleep, 500
	}
	ClickControl(OK)
}

CakePoker_GetBlind(big) {
	WinGetTitle, title
	StringGetPos, s, title, /, R
	if big {
		s += 2
		e := InStr(title, " ", true, s)
	} else {
		e := s + 1
		StringGetPos, s, title, %A_Space%, R, StrLen(title) - s
		s += 2
	}
	return CurrencyToFloat(e ? SubStr(title, s, e-s) : SubStr(title, s))
}

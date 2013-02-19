
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


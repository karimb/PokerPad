
EverestPoker_Reload(max) {
	static GetChips
	if !GetChips
		GetChips := CreateArea("558,6,50,9", 640, 480)
	ClickWindowArea2(GetChips, true)
	Sleep, 400
	GetWindowArea(x, y, w, h)
	x += Round(w / 2) - 157
	y += Round(h / 2) - 160
	if max {
		maxX := x + 130, maxY := y + 102, maxW := 160, maxH := 30
		ClickWindowRect2(maxX, maxY, maxW, maxH)
		Sleep, 400
	}
	okX := x + 62, okY := y + 291, okW := 80, okH := 10
	ClickWindowRect2(okX, okY, okW, okH)
}

EverestPoker_GetBlind(big) {
	local title, s, e, blind
	WinGetTitle, title
	e := InStr(title, "/")
	StringGetPos, s, title, %A_Space%, R, StrLen(title)-e
	s += 2
	blind := CurrencyToFloat(SubStr(title, s, e-s), EverestPoker_Currency, EverestPoker_Separator, EverestPoker_Decimal)
	return big ? blind : EverestPoker_GetSmallBlind(blind)
}


EverestPoker_GetSmallBlind(blind) {
	blind := Round(blind*100)
	if Mod(blind, 2) {
		if IsLabel(EverestPoker_GetSmallBlind%blind%) {
			GoSub, EverestPoker_GetSmallBlind%blind%
			return blind
		}
	}
	blind := blind/200
	DollarRound(blind)
	return blind
	EverestPoker_GetSmallBlind25:
		blind := 0.15
		return
}


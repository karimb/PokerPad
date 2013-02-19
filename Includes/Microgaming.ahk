
Microgaming_IsMiniWindow() {
	WinGetPos, , , width
	return width < 700
}

Microgaming_GetArea(ByRef x, ByRef y, ByRef w, ByRef h, ByRef area) {
	StringSplit, array, area, %A_Space%
	x := array1
	y := array2
	w := array3
	h := array4
}

Microgaming_ClickArea(ByRef area, ByRef id = "") {
	Microgaming_GetArea(x, y, w, h, area)
	ClickWindowRect(x, y, w, h, id)
}

Microgaming_Reload(max) {
	static MiniChips := "9 326 40 11", Chips := "59 467 40 11", Maximum := "Button3", OK := "Button1"
	isMini := Microgaming_IsMiniWindow()
	if isMini
		Microgaming_ClickArea(MiniChips)
	else
		ClickWindowArea(Chips, false)
	time := A_TickCount
	WinWaitActive, Bring More Chips ahk_class #32770, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	if max {
		ClickControl(Maximum)
		Sleep, 400
	}
	ClickControl(OK)
	WinWaitActive, Chips Received ahk_class #32770, , 5
	if ErrorLevel
		return
	Sleep(time, 400)
	ClickControl(OK)
}

Microgaming_GetBlind(big) {
	static MiniBlinds := "5 181 70 11"
	if Microgaming_IsMiniWindow() {
		Microgaming_GetArea(x, y, w, h, MiniBlinds)
		blinds := Display_ReadArea(x, y, w, h, 0xFFFFFF)
		s := InStr(blinds, "N")
		if !s
			s := InStr(blinds, "P")
		if s
			blinds := SubStr(blinds, 1, s-1)
		s := InStr(blinds, "/")
		if big {
			s += 1
		} else {
			e := s
			s := 1
		}
	} else {
		WinGetTitle, blinds
		StringGetPos, s, blinds, /, R
		if big {
			s += 2
			e := InStr(blinds, " ", true, s)
		} else {
			e := s + 1
			StringGetPos, s, blinds, %A_Space%, R, StrLen(blinds) - s
			s += 2
		}
	}
	return CurrencyToFloat(e ? SubStr(blinds, s, e-s) : SubStr(blinds, s))
}

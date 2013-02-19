IPoker_Reload(max = true) {
	static MiniMenu := "466 6 40 10", MiniBuyChips := "435 53 50 9", GetChips := "242 576 80 14"
	if IPoker_IsMiniWindow() {
		ClickWindowArea(IPoker_MiniMenu, false)
		Sleep, 400
		ClickWindowArea(IPoker_MiniBuyChips, false)
	} else {
		ClickWindowArea(IPoker_GetChips, false)
	}
	Sleep, 400
	if max {
		Random, x, 35, 135
		Random, y, 174, 184
		ControlClick, x%x% y%y%, A, , , , Pos
		Sleep, 400
	}
	Random, x, 132, 182
	Random, y, 238, 250
	ControlClick, x%x% y%y%, A, , , , Pos
}

IPoker_IsMiniWindow() {
	WinGetPos, , , width
	return width < 600
}

IPoker_GetBlind(big) {
	WinGetTitle, title
	StringGetPos, s, title, -, R1
	s += 3
	blind := SubStr(title, s)
	e := InStr(blind, "/")
	if !e {
		StringGetPos, s, title, -, R2
		s += 3
		e := InStr(title, " ", true, s)
		blind := SubStr(title, s, e-s)
		e := InStr(blind, "/")
	}
	blind := big ? SubStr(blind, e+1) : SubStr(blind, 1, e-1)

;remove euro and pound characters from blind
euro := Chr(128)
pound := Chr(163)
;StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?] 
StringReplace, blind, blind, %euro%, ,
StringReplace, blind, blind, %pound%, ,

return CurrencyToFloat(blind)

;MsgBox [, Options, Title, Text, Timeout]
; MsgBox ,,blind: %blind%, 1
; MsgBox blind: %blind%
}

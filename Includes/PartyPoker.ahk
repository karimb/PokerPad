
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
	local blind, s, e
	/*
	ControlGetText, blind, Static6
	if blind {
		;MsgBox Static6: %blind%
		if big {
			s := InStr(blind, "(") + 1
			e := InStr(blind, "/", true, s)
		} else {
			s := InStr(blind, "/") + 1
			e := StrLen(blind)
		}
	} else {
	*/
	WinGetTitle, blind
	;MsgBox Title: %blind%
	StringGetPos, s, blind, /, R
	if big {
		s += 2
		e := StrLen(blind)+1
	} else {
		e := s + 1
		StringGetPos, s, blind, %A_Space%, R, % StrLen(blind)-s
		s += 2
	}
	;}
	return CurrencyToFloat(SubStr(blind, s, e-s), PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal)
}


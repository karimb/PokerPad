
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


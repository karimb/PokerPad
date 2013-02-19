


PokerStars_Read(key, ByRef theme = "") {
	if !theme {
		IniRead, theme, PokerPad.ini, PokerStars, Theme, %A_Space%
		theme = PokerStars%theme%
	}
	IniRead, option, PokerPad.ini, %theme%, %key%, %A_Space%
	return option
}


PokerStars_Reload(max = true) {
	local time
	static AddMoreChips := "Button4", MaximumBuyin := "Button1", OK := "Button3", Options
	if !Options {
		local theme
		Options := CreateArea(PokerStars_Read("Options", theme), PokerStars_Read("Width", theme), PokerStars_Read("Height", theme))
	}
	ClickWindowArea(Options)
	time := A_TickCount
	WinWaitActive, ^Options ahk_class #32770, , 5
	if ErrorLevel
		return

;	Sleep(time, 400)
;	ClickControl(AddMoreChips)
	ControlSend, %AddMoreChips%, {SPACE}

	time := A_TickCount
	WinWaitActive, ^Buy-in ahk_class #32770, , 5
	if ErrorLevel
		return
;	Sleep(time, 400)
	if max {
		ControlSend, %MaximumBuyin%, {SPACE}
;		ClickControl(MaximumBuyin)
;		Sleep, 400
	}
	ControlSend, %OK%, {SPACE}

;	if IsControlVisible(OK)
;		ClickControl(OK)
	/*
	WinWaitActive, PokerStars ahk_class #32770, , 5
	if !ErrorLevel
		AddCurrentIDToQueue("PokerStars_ReloadQueue")
	*/
}

PokerStars_GetBlind(big) {
	WinGetTitle, title
	if InStr(title, "Tournament")
		s := InStr(title, "- Blinds", true) + 9
	else
		s := InStr(title, " - ", true) + 3
	if big {
		s := InStr(title, "/", true, s) + 1
		e := InStr(title, " ", true, s)
	} else
		e := InStr(title, "/", true, s)
	blind := CurrencyToFloat(SubStr(title, s, e-s))
	return blind
}

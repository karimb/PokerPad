/*  Generic Common Functions
 *
 *  License:
 *  	Functions v0.2 by Xander
 *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
 */

 
SysGet, Caption, 4
SysGet, Border, 45
SysGet, ResizeBorder, 32

 
 
 
/*  If round is -1, an appropriate amount will be determined to round based on the size of the bet.
 *  The rules behave precisely as described for ControlIncreaseAmount.
 *  If round is 0, no rounding will occur.
 *  Otherwise the amount will be rounded to the nearest factor of the round value specified.
 */
GetRoundedAmount(amount, round) {
	if round < 0
		RelativeRound(amount, ++round)
	else if round
		RelativeRound(amount, round)
	else
		DollarRound(amount)
	return amount
}

/*  If amount is 0, an appropriate amount will be determined for the increment
 *  This amount is determined by precise boundaries, which in theory go to infinity.
 *  The increase behaves in the following manner:
 *  1 1.10 1.20 1.30 ... 2.40 2.50 2.75 3.00 3.25 ... 4.75 5.00 5.50 6.00 ... 9.50 10 11 12 ... 24 25 27.50 30 ... 47.50 50 55 ... etc
 */
ControlIncreaseAmount(ByRef control, amount = 0, decimal = "") {
	if !IsControlVisible(control)
		return
	ControlGetText, bet, %control%
	if decimal
		StringReplace, bet, bet, % decimal, .
	RelativeIncrement(bet, amount)
	if decimal
		StringReplace, bet, bet, ., % decimal
	ControlSetText, %control%, %bet%
}

ControlDecreaseAmount(ByRef control, amount = 0, decimal = "") {
	if !IsControlVisible(control)
		return
	ControlGetText, bet, %control%
	if decimal
		StringReplace, bet, bet, % decimal, .
	RelativeDecrement(bet, amount)
	if decimal
		StringReplace, bet, bet, ., % decimal
	ControlSetText, %control%, %bet%
}

GetIncrement(value) {
	if (value < 1) {
		return 0.05
	}
	i := value/10
	n := 0
	Loop {
		if i < 1
			break
		i /= 10
		n++
	}
	if i < 0.25
		i := 0.1 * 10 ** n
	else if (i < 0.5)
		i := 0.25 * 10 ** n
	else
		i := 0.5 * 10 ** n
	return i
}

DollarRound(ByRef value) {
	if (Mod(value, 1) = 0)
		value := Round(value)
	else
		value := Round(value, 2)
}

GetDollarRound(value) {
	DollarRound(value)
	return value
}

RelativeRound(ByRef value, i = 0) {
	if !i
		i := GetIncrement(value)
	value *= 100
	i *= 100
	r := Mod(value, i)
	if (r > i/2)
		value += i-r
	else
		value -= r
	value /= 100
	DollarRound(value)
}

RelativeIncrement(ByRef value, amount = "") {
	if !amount
		amount := GetIncrement(value)
	value *= 100
	amount *= 100
	mod := Mod(value, amount)
	if mod
		value += amount-mod
	else
		value += amount
	value /= 100
	DollarRound(value)
}

RelativeDecrement(ByRef value, amount = "") {
	if !amount
		amount := GetIncrement(value-1)
	value *= 100
	amount *= 100
	mod := Mod(value, amount)
	if mod
		value -= mod
	else
		value -= amount
	value /= 100
	if (value < 0)
		value = 0
	else
		DollarRound(value)
}

GetRandomBet() {
	Random, factor, 25, 100
	return factor/100
}


ClickWindowArea(ByRef area, relative = 1, ByRef id = "") {
	GetWindowArea(x, y, w, h, area, relative, id)
	ClickWindowRect(x, y, w, h, id)
}

RectContains(ByRef posX, ByRef posY, ByRef x, ByRef y, ByRef w, ByRef h) {
	return posX >= x && && posY >= y && posX <= x+w posY <= y+h
}

ClickWindowRect(ByRef x, ByRef y, ByRef w, ByRef h, ByRef id = "") {
	MouseGetPos, mouseX, mouseY
	if !RectContains(mouseX, mouseY, x, y, w, h) {
		Random, x, x, x+w
		Random, y, y, y+h
	} else {
		x := mouseX
		y := mouseY
	}
	if id
		ControlClick, x%x% y%y%, ahk_id %id%, , , , NA Pos
	else
		ControlClick, x%x% y%y%, , , , , NA Pos
}

ClickWindowArea2(ByRef area, relative = 1, ByRef id = "") {
	if id {
		WinActivate, ahk_id %id%
		WinWaitActive, ahk_id %id%
	}
	GetWindowArea(x, y, w, h, area, relative, id)
	ClickWindowRect2(x, y, w, h)
}


ClickWindowRect2(ByRef x, ByRef y, ByRef w, ByRef h) {
	MouseGetPos, mouseX, mouseY
	if !RectContains(mouseX, mouseY, x, y, w, h) {
		Random, x, x, x+w
		Random, y, y, y+h
		Click, %x% %y%
		MouseMove, mouseX, mouseY
	} else
		Click
}


GetWindowArea(ByRef x, ByRef y, ByRef w, ByRef h, ByRef subarea = "", relative = 1, ByRef id = "") {
	;local b := relative ? ResizeBorder : Border
	local b =0
	if (relative) {
		if id
			WinGetPos, , , w, h, ahk_id %id%
		else
			WinGetPos, , , w, h
		;w -= b * 2
		;h -= Caption + b * 2
	}
	;x := b
	;y := Caption + b
	if subarea {
		local subarea0, subarea1, subarea2, subarea3, subarea4
		StringSplit, subarea, subarea, %A_Space%
		if relative {
			; remove += for x and y
			x := Round(subarea1 * w)
			y := Round(subarea2 * h)
			w := Round(subarea3 * w)
			h := Round(subarea4 * h)
		} else {
			x += subarea1
			y += subarea2
			w := subarea3
			h := subarea4
		}
	}
}


GetControlArea(ByRef x, ByRef y, ByRef w, ByRef h, ByRef control, px = 0, py = 0, pw = 1, ph = 1) {
	ControlGetPos, x, y, w, h, %control%
	x += Ceil(w * px)
	y += Ceil(h * py)
	w := Round(w * pw)
	h := Round(h * pw)
}


ClickControl(ByRef control, ByRef id = "") {
	if id
		ControlGetPos, x, y, w, h, %control%, ahk_id %id%
	else
		ControlGetPos, x, y, w, h, %control%
	x := Floor(w/5)
	y := Floor(h/5)
	Random, x, x, w-x
	Random, y, y, h-y
	if id
		ControlClick, %control%, ahk_id %id%, , , , X%x% Y%y%
	else
		ClickCoord(control, x, y)
}

ClickArea(ByRef control, ByRef area) {
	StringSplit, area, area, %A_Space%
	Random, x, area1, area1+area3
	Random, y, area2, area2+area4
	ClickCoord(control, x, y)
}

ClickCoord(ByRef control, ByRef x, ByRef y) {
	ControlClick, %control%, , , , , X%x% Y%y%
}


ForwardNumpadKey(numpadkey, ByRef control = "") {
	StringRight, numpadkey, numpadkey, 1
	if (control && IsControlVisible(control)) {
		ControlGetFocus, c
		if (c != control) {
			ControlSetText, %control%
			ControlClick, %control%
		}
		ControlSend, %control%, %numpadkey%
	} else
		Send, %numpadkey%
}


IsControlVisible(ByRef control, ByRef id = "") {
	local v
	if id
		ControlGet, v, Visible, , %control%, ahk_id %id%
	else
		ControlGet, v, Visible, , %control%
	return v
}

IsControlEnabled(ByRef control, ByRef id = "") {
	local e
	if id
		ControlGet, e, Enabled, , %control%, ahk_id %id%
	else
		ControlGet, e, Enabled, , %control%
	return e
}

IsControlChecked(ByRef control, ByRef id = "") {
	local e
	if id
		ControlGet, e, Checked, , %control%, ahk_id %id%
	else
		ControlGet, e, Checked, , %control%
	return e
}

Load(ByRef names) {
	Loop, Parse, names, `,
		if FileExist(A_LoopField)
			Run, %A_LoopField%
}

Unload(ByRef names) {
	DetectHiddenWindows, On
	WinGet, list, List, ahk_class AutoHotkey
	Loop, %list% {
		id := 	list%A_Index%
		WinGetTitle, title, ahk_id %id%
		StringGetPos, s, title, \, R
		s += 2
		StringGetPos, e, title, %A_Space%, L, s
		title := SubStr(title, s, e+1-s)
		if title in %names%
		{
			WinGet, pid, PID, ahk_id %id%
			Process, Close, %pid%
		}
	}
	DetectHiddenWindows, Off
}

CreateArea(a, w, h) {
	StringSplit, a, a, `,
	return (a1/w) . " " . (a2/h) . " " . (a3/w) . " " (a4/h)
}



CurrencyToFloat(amount, ByRef currency = "$", ByRef separator = ",", ByRef decimal = "") {
	StringReplace, amount, amount, % currency
	StringReplace, amount, amount, % separator, , All
	if decimal
		StringReplace, amount, amount, % decimal, .
	return amount
}

GetAmount(amount, ByRef decimal) {
	if decimal
		StringReplace, amount, amount, ., % decimal
	return amount
}

/*
CurrencyToFloat(amount) {
	StringReplace, amount, amount, $
	StringReplace, amount, amount, `,, , All
	return amount
}
*/

CreateIni() {
	FileAppend,
		( LTrim
		[FullTilt]
		Path=\Full Tilt Poker\FullTiltPoker.exe
		[PartyPoker]
		Path=\PartyGaming\PartyPoker\RunApp.exe
		[EverestPoker]
		Path=\Everest Poker\CStart.exe
		[Ongame]
		Path=\PokerRoom.com\StartPokerRoom.exe
		[Absolute]
		Path=\Absolute Poker\mainclient.exe
		[CakePoker]
		Path=\Cake Poker\cake.exe
		Themes=CakePoker
		Theme=CakePoker
		Background=0x5F8187
		ButtonColor=BlueForeground
		[PokerStars]
		Path=\PokerStars\PokerStarsUpdate.exe
		Themes=Classic|HyperSimple
		Theme=Classic
		[PokerStarsClassic]
		Width=792
		Height=546
		FoldAny=8,349,90,6
		SitOut=8,373,90,6
		AutoPost=8,393,90,6
		Fold=420,498,100,30
		Call=547,498,100,30
		Raise=675,498,100,30
		StandUp=688,11,90,10
		Lobby=688,42,90,10
		LastHand=5,24,110,6
		Pot=320,16,160,16
		Options=350,40,100,40
		Time=510,406,50,40
		ButtonColor=0x0A3782,8
		ActionColor=YellowForeground,32
		ExcludeActionColor=0x326E6E,50
		PotBackground=0xC1EAF2
		BoxColor=0xFFFFFF
		[PokerStarsHyperSimple]
		Width=792
		Height=546
		FoldAny=8,349,90,6
		SitOut=8,373,90,6
		AutoPost=8,393,90,6
		Fold=420,498,100,30
		Call=547,498,100,30
		Raise=675,498,100,30
		StandUp=688,11,90,10
		Lobby=688,42,90,10
		LastHand=5,24,110,6
		Pot=320,16,160,16
		Options=370,42,60,16
		Time=510,406,50,40
		ButtonColor=0xCDC3B2,8
		ActionColor=DarkForeground,8
		PotBackground=0xEED7BB
		BoxColor=0xE7D4CE,8
		[IPoker]
		Path=\Titan Poker\casino.exe
		Themes=Titan|CDPoker
		Theme=Titan
		[Titan]
		PotColor=0xFFFFFF,16
		ActionColor=0xFFFFFF,16
		CheckColor=0x000000
		BoxColor=0xFB8583,32
		[CDPoker]
		PotColor=0xD5EAF9,16
		ActionColor=0xFCFDFF,16
		CheckColor=0x2DC2FA
		BoxColor=0x3AFFE1,32
		[Microgaming]
		Path=\PokerTimeMPP\MPPoker.exe
		Themes=PokerTime
		Theme=PokerTime
		[PokerTime]
		BoxColor=0x404040
		ActionColor=0xFFFFFF
		ButtonColor=0x141EBB,16
		[Hotkeys]
		SuspendHotkeys=^Delete
		LastHand=NumpadAdd
		ActivateTable=NumpadAdd
		Reload=Home
		Lobby=^Right
		AllInThisHand=^End
		Fold=NumpadDiv
		Call=NumpadMult
		Raise=NumpadSub
		ClearBetBox=NumpadEnter
		FoldAny=^PgUp
		AutoPost=^PgDn
		SitOut=^+PgDn
		NextWindow_Left=Left
		NextWindow_Right=Right
		NextWindow_Up=Up
		NextWindow_Down=Down
		TypeBet=1
		RandomBet=NumpadIns
		AllIn=NumpadDel
		IncreaseBet=PgUp
		DecreaseBet=PgDn
		IncreaseBet2=WheelUp
		DecreaseBet2=WheelDown
		Relative1=NumpadEnd
		Relative2=NumpadDown
		Relative3=NumpadPgDn
		Relative4=NumpadLeft
		Relative5=NumpadClear
		Relative6=NumpadRight
		Relative7=NumpadHome
		Relative8=NumpadUp
		Relative9=NumpadPgUp
		Rtick=1
		Fixed1=^Numpad2
		Fixed2=^Numpad3
		Fixed3=^Numpad4
		Fixed4=^Numpad5
		Fixed5=^Numpad6
		Fixed6=^Numpad7
		Fixed7=^Numpad8
		Fixed8=^Numpad9
		Fixed9=^Numpad0
		Ftick=1
		SitInAll=^Down
		SitOutAll=^Up
		AutoPostOnAll=^+Down
		AutoPostOffAll=^+Up
		LeaveAll=^Left
		Tile=Pause
		ToggleAutoMuck=End
		[General]
		Version=1
	), PokerPad.ini
}
CheckIniVersion() {
	if FileExist("PokerPad.ini") {
		IniRead, version, PokerPad.ini, General, Version, 0
		if (version < 1.03) {
			if (version < 1.03) {
				if (version < 1) {
					FileRead, ini, PokerPad.ini
					FileMove, PokerPad.ini, PokerPad-v%version%.ini
					CreateIni()
					i := InStr(ini, "[Hotkeys]")
					j := InStr(ini, "[", true, i+1)
					if i {
						i := InStr(ini, "`n", true, i) + 1
						ini := j ? SubStr(ini, i, j-i) : SubStr(ini, i)
						Loop, Parse, ini, `n, `r
						{
							StringSplit, array, A_LoopField, =
							IniWrite, %array2%, PokerPad.ini, Hotkeys, %array1%
						}
						IniWrite, ^+PgDn, PokerPad.ini, Hotkeys, SitOut
					}
				}
				if (version < 1.01) {
					IniWrite, \Absolute Poker\mainclient.exe, PokerPad.ini, Absolute, Path
					IniWrite, 0xD5EAF9`,16, PokerPad.ini, CDPoker, PotColor
					IniWrite, 0xFCFDFF`,16, PokerPad.ini, CDPoker, ActionColor
					IniWrite, 0x2DC2FA, PokerPad.ini, CDPoker, CheckColor
					IniWrite, 0x3AFFE1`,32, PokerPad.ini, CDPoker, BoxColor
				}
				if (version < 1.02) {
					IniDelete, PokerPad.ini, Ongame , Separator
				}
				IniWrite, PokerTime|RedNines, PokerPad.ini, Microgaming, Themes
				IniWrite, 0x000000, PokerPad.ini, RedNines, BoxColor
				IniWrite, 0x4F4BBB`,16, PokerPad.ini, RedNines, ButtonColor
				IniWrite, 0xFFFFFF, PokerPad.ini, RedNines, ActionColor
			}
			IniWrite, 1.03, PokerPad.ini, General, Version
			/*
			IniWrite, Titan|CDPoker|VCPoker, PokerPad.ini, IPoker, Themes
			IniWrite, 0xD5EAF9`,16, PokerPad.ini, VCPoker, PotColor
			IniWrite, 0xFFFFFF`,16, PokerPad.ini, VCPoker, ActionColor
			IniWrite, 0x000000`,16, PokerPad.ini, VCPoker, CheckColor
			IniWrite, 0x0F0F0F`,32, PokerPad.ini, VCPoker, BoxColor
			IniWrite, 1.035, PokerPad.ini, General, Version
			*/
		}
	} else
		CreateIni()
}


Sleep(time, length) {
	time := A_TickCount - time
	if (time < 400)
		Sleep, 400 - time
}


ReadColor(theme, client, key) {
	local v, i
	IniRead, v, PokerPad.ini, %theme%, %key%, %A_Space%
	if (v == "")
		return false
	i := InStr(v, ",")
	if i {
		%client%_%key% := SubStr(v, 1, i-1)
		%client%_%key%Variation := SubStr(v, i+1)
	} else {
		%client%_%key% := v
		%client%_%key%Variation := 0
	}
	return true
}

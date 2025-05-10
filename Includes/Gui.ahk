

ActivateWindow(title) {
	id := WinExist(title)
	if id {
		WinActivate, ahk_id %id%
		return true
	}
	return false
}


TreeTableLayout(ByRef ctrls, ctrlCounts, rules, spacing, marginX, marginY, treeSpacing, ByRef w = "", ByRef h = "", resizeRules = "") {
	tree := ListGet(ctrls, 0, "`n")
	index := 1
	rSize := ListSize(rules)
	ControlGetPos, x, y, treeW, , %tree%
	x += treeW + treeSpacing
	w := h := 0
	Loop, Parse, ctrlCounts, `,
	{
		j := index
		tabCtrls := ListSegment(ctrls, j, index += A_LoopField, "`n")
		if (A_Index <= rSize) {
			rule := ListGet(rules, A_Index - 1)
			if rule
				tabRules := rule
		}
		tabW := tabH := ""
		TableLayout(tabCtrls, tabRules, spacing, marginX, marginY, x, y, tabW, tabH)
		if (tabW > w)
			w := tabW
		if (tabH > h)
			h := tabH
	}
	if resizeRules {
		index := 1
		Loop, Parse, ctrlCounts, `,
		{
			j := index
			resizeW := w
			resizeH := h
			tabCtrls := ListSegment(ctrls, j, index += A_LoopField, "`n")
			if (A_Index <= rSize) {
				rule := ListGet(rules, A_Index - 1)
				if rule
					tabRules := rule
			}
			TableLayout(tabCtrls, tabRules, spacing, marginX, marginY, x, y, resizeW, resizeH, resizeRules)
		}
	}
	w += treeW + treeSpacing
	GuiControl, Move, %tree%, h%h%
}



GetHotkey(name) {
	IniRead, hotkey, PokerPad.ini, Hotkeys, %name%, %A_Space%
	return hotkey
}
GetPath(name) {
	IniRead, path, PokerPad.ini, %name%, Path, %A_Space%
	return path
}
GetSetting(section, key, default) {
	IniRead, value, PokerPad.ini, % section, % key, % default
	return value
}
Settings() {
	static tree, table_hotkeys, actions, betting, pot, street, global_hotkeys, options, options_betting, options_sites, options_autoload, options_reload
	static sitInAll, sitOutAll, leaveAll, tile, activateTable, autoPostOnAll, autoPostOffAll, suspendHotkeys, debug
	static lastHand, autoMuck, reload, lobby, allInThisHand
	static fold, call, raise, ffold, clear, foldAny, autoPost, sitOut, left, right, up, down
	static typeBet, randomBet, allIn, incBet, decBet, incBet2, decBet2
	static factor1, factor2, factor3, factor4, factor5, factor6, factor7, factor8, factor9
	static relative1, relative2, relative3, relative4, relative5, relative6, relative7, relative8, relative9, rtick
	static ffactor1, ffactor2, ffactor3, ffactor4, ffactor5, ffactor6, ffactor7, ffactor8, ffactor9
	static fixed, fixed1, fixed2, fixed3, fixed4, fixed5, fixed6, fixed7, fixed8, fixed9, ftick
	static preflop1, flop1, turn1, river1, street1, preflop2, flop2, turn2, river2, street2, preflop3, flop3, turn3, river3, street3
	static betRounding, betIncrement, betIncrement2, minRandom, maxRandom, monitors, tables, mouse
	static fulltilt, stars, ipoker, party, everest, ongame, cake, micro, pacific, sky, swc, acr
	static sites_fulltilt, sites_stars, sites_ipoker, sites_party, sites_everest, sites_ongame, sites_cake, sites_micro, sites_pacific, sites_sky, sites_swc, sites_acr
	static path_fulltilt, path_stars, path_ipoker, path_party, path_everest, path_ongame, path_cake, path_micro, path_pacific, path_sky, path_swc, path_acr
	static theme_stars, theme_cake, theme_micro
	static preflop_ipoker, postflop_ipoker, pot_ipoker
	static timebank_pacific, pot_pacific, usebb_pacific
	static pot_swcpoker
	static usebb_acr, pot_acr
	static format_ongame, format_party, format_everest
	static autoLoad, available, autoLoadInitial, availableInitial
	static muck, max, blinds
	static ctrls, ctrlCounts, selected
	if ActivateWindow("Settings ahk_class AutoHotkeyGUI")
		return
	Critical, On
	Gui, 1:Default
	Gui, +LastFound +ToolWindow
	Gui, Margin, 5, 5
	Gui, Add, TreeView, w160 gSettings_Event vtree
	global_hotkeys := TV_Add("Global Hotkeys", 0, "Bold")
	table_hotkeys := TV_Add("Table Hotkeys", 0, "Expand Bold")
	actions := TV_Add("Actions", table_hotkeys)
	betting := TV_Add("Betting", table_hotkeys)
	pot := TV_Add("Pot Bets", table_hotkeys)
	fixed := TV_Add("Fixed Bets", table_hotkeys)
	;street := TV_Add("Street Bets", table_hotkeys)
	options := TV_Add("Options", 0, "Expand Bold")
	options_betting := TV_Add("Betting", options)
	options_sites := TV_Add("Sites", options)
	;sites_fulltilt := TV_Add("Full Tilt", options_sites)
	;sites_stars := TV_Add("Poker Stars", options_sites)
	sites_ipoker := TV_Add("iPoker", options_sites)
	sites_party := TV_Add("Party Poker", options_sites)
	;sites_everest := TV_Add("Everest Poker", options_sites)
	;sites_ongame := TV_Add("Ongame", options_sites)
	;sites_cake := TV_Add("Cake Poker", options_sites)
	;sites_micro := TV_Add("Microgaming", options_sites)
	sites_pacific := TV_Add("888/Pacific Poker", options_sites)
	sites_sky := TV_Add("Sky Poker", options_sites)
	;options_reload := TV_Add("Reload", options)
	;options_autoload := TV_Add("Auto Load", options)
	sites_swc := TV_Add("SwC Poker", options_sites)

	rules := "a2 v1|w120"
	ctrlCounts := "18"
	Gui, Add, Text, , Sit In All:
	Gui, Add, Edit, vsitInAll, % GetHotkey("SitInAll")
	Gui, Add, Text, , Sit Out All:
	Gui, Add, Edit, vsitOutAll, % GetHotkey("SitOutAll")
	Gui, Add, Text, , Auto Post All:
	Gui, Add, Edit, vautoPostOnAll, % GetHotkey("AutoPostOnAll")
	Gui, Add, Text, , Auto Post Off All:
	Gui, Add, Edit, vautoPostOffAll, % GetHotkey("AutoPostOffAll")
	Gui, Add, Text, , Leave All:
	Gui, Add, Edit, vleaveAll, % GetHotkey("LeaveAll")
	Gui, Add, Text, , Tile:
	Gui, Add, Edit, vtile, % GetHotkey("Tile")
	Gui, Add, Text, , Activate Table:
	Gui, Add, Edit, vactivateTable, % GetHotkey("ActivateTable")
	Gui, Add, Text, , Suspend Hotkeys:
	Gui, Add, Edit, vsuspendHotkeys, % GetHotkey("SuspendHotkeys")
	Gui, Add, Text, , Debug:
	Gui, Add, Edit, vdebug, % GetHotkey("Debug")
	
	rules .= ","
	ctrlCounts .= ",12"
	Gui, Add, Text, Hidden, Reload:
	Gui, Add, Edit, Hidden vreload, % GetHotkey("Reload")
	Gui, Add, Text, Hidden, Open/Close Last Hand:
	Gui, Add, Edit, Hidden vlastHand, % GetHotkey("LastHand")
	Gui, Add, Text, Hidden, Lobby:
	Gui, Add, Edit, Hidden vlobby, % GetHotkey("Lobby")
	Gui, Add, Text, Hidden, Sit In/Out:
	Gui, Add, Edit, Hidden vsitOut, % GetHotkey("SitOut")
	Gui, Add, Text, Hidden, Auto Post Blinds/Antes:
	Gui, Add, Edit, Hidden vautoPost, % GetHotkey("AutoPost")
	Gui, Add, Text, Hidden, Toggle Auto Muck:
	Gui, Add, Edit, Hidden vautoMuck, % GetHotkey("ToggleAutoMuck")
	
	rules .= ","
	ctrlCounts .= ",18"
	Gui, Add, Text, Hidden, First Button (Fold):
	Gui, Add, Edit, Hidden vfold, % GetHotkey("Fold")
	Gui, Add, Text, Hidden, Second Button (Call):
	Gui, Add, Edit, Hidden vcall, % GetHotkey("Call")
	Gui, Add, Text, Hidden, Third Button (Raise):
	Gui, Add, Edit, Hidden vraise, % GetHotkey("Raise")
	Gui, Add, Text, Hidden, FastFold:
	Gui, Add, Edit, Hidden vffold, % GetHotkey("FastFold")
	Gui, Add, Text, Hidden, Fold To Any Bet:
	Gui, Add, Edit, Hidden vfoldAny, % GetHotkey("FoldAny")
	Gui, Add, Text, Hidden, Activate Table Left:
	Gui, Add, Edit, Hidden vleft, % GetHotkey("NextWindow_Left")
	Gui, Add, Text, Hidden, Activate Table Right:
	Gui, Add, Edit, Hidden vright, % GetHotkey("NextWindow_Right")
	Gui, Add, Text, Hidden, Activate Table Up:
	Gui, Add, Edit, Hidden vup, % GetHotkey("NextWindow_Up")
	Gui, Add, Text, Hidden, Activate Table Down:
	Gui, Add, Edit, Hidden vdown, % GetHotkey("NextWindow_Down")

	
	rules .= ",c2 t3 b3__a2 v1|w120"
	ctrlCounts .= ",17"
	IniRead, checked, PokerPad.ini, Hotkeys, TypeBet
	Gui, Add, CheckBox, Hidden vtypeBet Checked%checked%, Forward Numpad Digits to the Bet Box.
	Gui, Add, Text, Hidden, Focus/Clear Bet Box:
	Gui, Add, Edit, Hidden vclear, % GetHotkey("ClearBetBox")
	Gui, Add, Text, Hidden, Increase Bet:
	Gui, Add, Edit, Hidden vincBet, % GetHotkey("IncreaseBet")
	Gui, Add, Text, Hidden,
	Gui, Add, Edit, Hidden vincBet2, % GetHotkey("IncreaseBet2")
	Gui, Add, Text, Hidden, Decrease Bet:
	Gui, Add, Edit, Hidden vdecBet, % GetHotkey("DecreaseBet")
	Gui, Add, Text, Hidden,
	Gui, Add, Edit, Hidden vdecBet2, % GetHotkey("DecreaseBet2")
	Gui, Add, Text, Hidden, Random Bet:
	Gui, Add, Edit, Hidden vrandomBet, % GetHotkey("RandomBet")
	Gui, Add, Text, Hidden, All In:
	Gui, Add, Edit, Hidden vallIn, % GetHotkey("AllIn")
	Gui, Add, Text, Hidden, Unconditional All In:
	Gui, Add, Edit, Hidden vallInThishand, % GetHotkey("AllInThisHand")
	
	rules .= ",w80|w120"
	ctrlCounts .= ",19"
	IniRead, factor, PokerPad.ini, Bets, Relative1, 1/4
	Gui, Add, Edit, Hidden Right vfactor1, %factor%
	Gui, Add, Edit, Hidden vrelative1, % GetHotkey("Relative1")
	IniRead, factor, PokerPad.ini, Bets, Relative2, 1/3
	Gui, Add, Edit, Hidden Right vfactor2, %factor%
	Gui, Add, Edit, Hidden vrelative2, % GetHotkey("Relative2")
	IniRead, factor, PokerPad.ini, Bets, Relative3, 1/2
	Gui, Add, Edit, Hidden Right vfactor3, %factor%
	Gui, Add, Edit, Hidden vrelative3, % GetHotkey("Relative3")
	IniRead, factor, PokerPad.ini, Bets, Relative4, 2/3
	Gui, Add, Edit, Hidden Right vfactor4, %factor%
	Gui, Add, Edit, Hidden vrelative4, % GetHotkey("Relative4")
	IniRead, factor, PokerPad.ini, Bets, Relative5, 3/4
	Gui, Add, Edit, Hidden Right vfactor5, %factor%
	Gui, Add, Edit, Hidden vrelative5, % GetHotkey("Relative5")
	IniRead, factor, PokerPad.ini, Bets, Relative6, 0.9
	Gui, Add, Edit, Hidden Right vfactor6, %factor%
	Gui, Add, Edit, Hidden vrelative6, % GetHotkey("Relative6")
	IniRead, factor, PokerPad.ini, Bets, Relative7, 1
	Gui, Add, Edit, Hidden Right vfactor7, %factor%
	Gui, Add, Edit, Hidden vrelative7, % GetHotkey("Relative7")
	IniRead, factor, PokerPad.ini, Bets, Relative8, 1.5
	Gui, Add, Edit, Hidden Right vfactor8, %factor%
	Gui, Add, Edit, Hidden vrelative8, % GetHotkey("Relative8")
	IniRead, factor, PokerPad.ini, Bets, Relative9, 2
	Gui, Add, Edit, Hidden Right vfactor9, %factor%
	Gui, Add, Edit, Hidden vrelative9, % GetHotkey("Relative9")
	IniRead, checked, PokerPad.ini, HotKeys, Rtick, 1
	Gui, Add, Checkbox, Hidden vrtick Checked%checked%, Auto-bet

	rules .= ","
	ctrlCounts .= ",19"
	IniRead, factor, PokerPad.ini, Bets, Fixed1, 2
	Gui, Add, Edit, Hidden Right vffactor1, %factor%
	Gui, Add, Edit, Hidden vfixed1, % GetHotkey("Fixed1")
	IniRead, factor, PokerPad.ini, Bets, Fixed2, 3
	Gui, Add, Edit, Hidden Right vffactor2, %factor%
	Gui, Add, Edit, Hidden vfixed2, % GetHotkey("Fixed2")
	IniRead, factor, PokerPad.ini, Bets, Fixed3, 4
	Gui, Add, Edit, Hidden Right vffactor3, %factor%
	Gui, Add, Edit, Hidden vfixed3, % GetHotkey("Fixed3")
	IniRead, factor, PokerPad.ini, Bets, Fixed4, 5
	Gui, Add, Edit, Hidden Right vffactor4, %factor%
	Gui, Add, Edit, Hidden vfixed4, % GetHotkey("Fixed4")
	IniRead, factor, PokerPad.ini, Bets, Fixed5, 6
	Gui, Add, Edit, Hidden Right vffactor5, %factor%
	Gui, Add, Edit, Hidden vfixed5, % GetHotkey("Fixed5")
	IniRead, factor, PokerPad.ini, Bets, Fixed6, 7
	Gui, Add, Edit, Hidden Right vffactor6, %factor%
	Gui, Add, Edit, Hidden vfixed6, % GetHotkey("Fixed6")
	IniRead, factor, PokerPad.ini, Bets, Fixed7, 8
	Gui, Add, Edit, Hidden Right vffactor7, %factor%
	Gui, Add, Edit, Hidden vfixed7, % GetHotkey("Fixed7")
	IniRead, factor, PokerPad.ini, Bets, Fixed8, 9
	Gui, Add, Edit, Hidden Right vffactor8, %factor%
	Gui, Add, Edit, Hidden vfixed8, % GetHotkey("Fixed8")
	IniRead, factor, PokerPad.ini, Bets, Fixed9, 10
	Gui, Add, Edit, Hidden Right vffactor9, %factor%
	Gui, Add, Edit, Hidden vfixed9, % GetHotkey("Fixed9")
	IniRead, checked, PokerPad.ini, HotKeys, Ftick, 1
	Gui, Add, Checkbox, Hidden vftick Checked%checked%, Auto-bet
	

/*
	rules .= ",c5 b10_n0 w10|a1|a1|a1|a1__n0|w60|w60|w60|w60_c3 a2 v1 b10|c2 w120 b10"
	ctrlCounts .= ",23"
	Gui, Add, Text, Hidden, Enter fraction/decimal value for pot bets.`nEnter integer follwed by b for fixed bets (e.g. 4b).
	Gui, Add, Text, Hidden, Preflop
	Gui, Add, Text, Hidden, Flop
	Gui, Add, Text, Hidden, Turn
	Gui, Add, Text, Hidden, River
	Gui, Add, Edit, Hidden vpreflop1, % GetSetting("Bets", "Preflop1", 1)
	Gui, Add, Edit, Hidden vflop1, % GetSetting("Bets", "Flop1", 1)
	Gui, Add, Edit, Hidden vturn1, % GetSetting("Bets", "Turn1", "3/4")
	Gui, Add, Edit, Hidden vriver1, % GetSetting("Bets", "River1", "2/3")
	Gui, Add, Text, Hidden, Hotkey:
	Gui, Add, Edit, Hidden vstreet1, % GetHotkey("Street1")
	
	Gui, Add, Edit, Hidden vpreflop2, % GetSetting("Bets", "Preflop2", A_Space)
	Gui, Add, Edit, Hidden vflop2, % GetSetting("Bets", "Flop2", A_Space)
	Gui, Add, Edit, Hidden vturn2, % GetSetting("Bets", "Turn2", A_Space)
	Gui, Add, Edit, Hidden vriver2, % GetSetting("Bets", "River2", A_Space)
	Gui, Add, Text, Hidden, Hotkey:
	Gui, Add, Edit, Hidden vstreet2, % GetHotkey("Street2")
	
	Gui, Add, Edit, Hidden vpreflop3, % GetSetting("Bets", "Preflop3", A_Space)
	Gui, Add, Edit, Hidden vflop3, % GetSetting("Bets", "Flop3", A_Space)
	Gui, Add, Edit, Hidden vturn3, % GetSetting("Bets", "Turn3", A_Space)
	Gui, Add, Edit, Hidden vriver3, % GetSetting("Bets", "River3", A_Space)
	Gui, Add, Text, Hidden, Hotkey:
	Gui, Add, Edit, Hidden vstreet3, % GetHotkey("Street3")
*/

	
	rules .= ",c2 t3 b3__a2 v1|w40||n0 c2"
	ctrlCounts .= ",7"
	global Rounding, Increment, Increment2, UseMouse
	Gui, Add, CheckBox, Hidden Checked%UseMouse% vmouse, Act on the table under the mouse pointer.
	Gui, Add, Text, Hidden, Monitors:
	Gui, Add, Edit, Hidden w40 Number Right
	IniRead, monitors, PokerPad.ini, Tile, Monitors, 1
	Gui, Add, UpDown, Hidden vmonitors Range1-10, %monitors%
	Gui, Add, Text, Hidden, Tables per Monitor:
	Gui, Add, Edit, Hidden w40 Number Right
	IniRead, tables, PokerPad.ini, Tile, Tables, 36
	Gui, Add, UpDown, Hidden vtables Range1-36, %tables%

	rules .= ",a2 v1|c4 w120_2_a2 v1|w40|a1 v1|w40|n0 w20"
	ctrlCounts .= ",10"
	Gui, Add, Text, Hidden, Bet Rounding:
	r := -Rounding + 1
	Gui, Add, DropDownList, Hidden vbetRounding Choose%r% AltSubmit, None|Relative|Small Blind|Big Blind
	Gui, Add, Text, Hidden, Increment/Decrement:
	r := -Increment
	Gui, Add, DropDownList, Hidden vbetIncrement Choose%r% AltSubmit, Relative|Small Blind|Big Blind
	Gui, Add, Text, Hidden
	r := -Increment2
	Gui, Add, DropDownList, Hidden vbetIncrement2 Choose%r% AltSubmit, Relative|Small Blind|Big Blind	
	Gui, Add, Text, Hidden, Random Bet:
	IniRead, minRandom, PokerPad.ini, Bets, RandomMin, 0.25
	Gui, Add, Edit, Hidden vminRandom w40 Right, %minRandom%
	Gui, Add, Text, Hidden, :
	IniRead, maxRandom, PokerPad.ini, Bets, RandomMax, 1
	Gui, Add, Edit, Hidden vmaxRandom w40, %maxRandom%
	
	rules .= ",b5 c2__l20 p5 w130|l5 p5 w130"
	ctrlCounts .= ",6"
	Gui, Add, Text, Hidden, Enable PokerPad for these sites:
	/*
	IniRead, load, PokerPad.ini, General, FullTilt, 1
	Gui, Add, CheckBox, Hidden Checked%load% vfulltilt, Full Tilt Poker
	IniRead, load, PokerPad.ini, General, PokerStars, 1
	Gui, Add, CheckBox, Hidden Checked%load% vstars, Poker Stars
	*/
	IniRead, load, PokerPad.ini, General, iPoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% vipoker, iPoker
	IniRead, load, PokerPad.ini, General, PartyPoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% vparty, Party Poker
	/*
	IniRead, load, PokerPad.ini, General, EverestPoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% veverest, Everest Poker
	IniRead, load, PokerPad.ini, General, OnGame, 1
	Gui, Add, CheckBox, Hidden Checked%load% vongame, Ongame
	IniRead, load, PokerPad.ini, General, CakePoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% vcake, Cake Poker
	IniRead, load, PokerPad.ini, General, Microgaming, 1
	Gui, Add, CheckBox, Hidden Checked%load% vmicro, Microgaming
	*/
	IniRead, load, PokerPad.ini, General, Pacific, 1
	Gui, Add, CheckBox, Hidden Checked%load% vpacific, Pacific Poker
	IniRead, load, PokerPad.ini, General, SkyPoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% vsky, Sky Poker
	IniRead, load, PokerPad.ini, General, SwCPoker, 1
	Gui, Add, CheckBox, Hidden Checked%load% vswc, SwC Poker
	IniRead, acr, PokerPad.ini, General, ACR, 0
	
	rules .= ",a2 v1|w200"
/*
	ctrlCounts .= ",2"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_fulltilt, % GetPath("FullTilt")

	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_stars, % GetPath("PokerStars")
	Gui, Add, Text, Hidden, Theme:
	IniRead, themes, PokerPad.ini, PokerStars, Themes, %A_Space%
	IniRead, theme, PokerPad.ini, PokerStars, Theme, %A_Space%
	r := ListIndexOf(themes, theme, "|") + 1
	Gui, Add, DropDownList, Hidden vtheme_stars Choose%r%, % themes
*/
	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_ipoker, % GetPath("IPoker")
	Gui, Add, Text, Hidden, Pot Button:
	IniRead, pot_ipoker, PokerPad.ini, IPoker, PotButton, Button 3
	r := SubStr(pot_ipoker, 8, 1)
	Gui, Add, DropDownList, Hidden vpot_ipoker Choose%r%, Button 1|Button 2|Button 3
	;Gui, Add, Text, Hidden, Pot Button Preflop:
	;IniRead, preflop_ipoker, PokerPad.ini, IPoker, Preflop, Button 3
	;r := SubStr(preflop_ipoker, 8, 1)
	;Gui, Add, DropDownList, Hidden vpreflop_ipoker Choose%r%, Button 1|Button 2|Button 3
	;Gui, Add, Text, Hidden, Pot Button Postflop:
	;IniRead, postflop_ipoker, PokerPad.ini, IPoker, Postflop, Button 3
	;r := SubStr(postflop_ipoker, 8, 1)
	;Gui, Add, DropDownList, Hidden vpostflop_ipoker Choose%r%, Button 1|Button 2|Button 3

	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_party, % GetPath("PartyPoker")
	Gui, Add, Text, Hidden, Format:
	global PartyPoker_Currency, PartyPoker_Separator, PartyPoker_Decimal
	decimal := PartyPoker_Decimal ? PartyPoker_Decimal : "."
	Gui, Add, Edit, Hidden vformat_party, %PartyPoker_Currency%1%PartyPoker_Separator%000%decimal%00

/*
	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_everest, % GetPath("EverestPoker")
	Gui, Add, Text, Hidden, Format:
	global EverestPoker_Currency, EverestPoker_Separator, EverestPoker_Decimal
	decimal := EverestPoker_Decimal ? EverestPoker_Decimal : "."
	Gui, Add, Edit, Hidden vformat_everest, %EverestPoker_Currency%1%EverestPoker_Separator%000%decimal%00

	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_ongame, % GetPath("Ongame")
	Gui, Add, Text, Hidden, Format:
	global Ongame_Currency, Ongame_Separator, Ongame_Decimal
	decimal := Ongame_Decimal ? Ongame_Decimal : "."
	Gui, Add, Edit, Hidden vformat_ongame, %Ongame_Currency%1%Ongame_Separator%000%decimal%00

	
	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_cake, % GetPath("CakePoker")
	Gui, Add, Text, Hidden, Theme:
	IniRead, themes, PokerPad.ini, CakePoker, Themes, %A_Space%
	IniRead, theme, PokerPad.ini, CakePoker, Theme, %A_Space%
	r := ListIndexOf(themes, theme, "|") + 1
	Gui, Add, DropDownList, Hidden vtheme_cake Choose%r%, % themes

	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_micro, % GetPath("Microgaming")
	Gui, Add, Text, Hidden, Theme:
	IniRead, themes, PokerPad.ini, Microgaming, Themes, %A_Space%
	IniRead, theme, PokerPad.ini, Microgaming, Theme, %A_Space%
	r := ListIndexOf(themes, theme, "|") + 1
	Gui, Add, DropDownList, Hidden vtheme_micro Choose%r%, % themes
*/
	rules .= ","
	ctrlCounts .= ",5"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_pacific, % GetPath("Pacific")
	Gui, Add, Text, Hidden, Pot Button:
	IniRead, pot_pacific, PokerPad.ini, Pacific, PotButton, Button 4
	r := SubStr(pot_pacific, 8, 1) - 1
	Gui, Add, DropDownList, Hidden vpot_pacific Choose%r%, Button 2|Button 3|Button 4|Button 5
	;IniRead, checked, PokerPad.ini, Pacific, Timebank, 1
	;Gui, Add, Checkbox, Hidden vtimebank_pacific Checked%checked%, Auto-click Timebank`n(Restart required)
	IniRead, checked, PokerPad.ini, Pacific, UseBB, 0
	Gui, Add, Checkbox, Hidden y+20 vusebb_pacific Checked%checked%, Amounts in BB
	
	rules .= ","
	ctrlCounts .= ",2"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_sky, % GetPath("SkyPoker")
	
	rules .= ","
	ctrlCounts .= ",4"
	Gui, Add, Text, Hidden, Path:
	Gui, Add, Edit, Hidden vpath_swc, % GetPath("SwCPoker")
	Gui, Add, Text, Hidden, Pot Button:
	IniRead, pot_swcpoker, PokerPad.ini, SwCPoker, PotButton, Button 3
	r := SubStr(pot_swcpoker, 8, 1)
	Gui, Add, DropDownList, Hidden vpot_swcpoker Choose%r%, Button 1|Button 2|Button 3|Button 4
	
	IniRead, pot_acr, PokerPad.ini, ACR, PotButton, Button 4
	IniRead, usebb_acr, PokerPad.ini, ACR, UseBB, 0
	
	/*
	rules .= ",c3 t3 b3_1_a2 v1|w40||v1"
	ctrlCounts .= ",6"
	IniRead, muck, PokerPad.ini, Reload, AutoMuck, 1
	Gui, Add, CheckBox, Hidden Checked%muck% vmuck, Auto muck hands.
	IniRead, max, PokerPad.ini, Reload, Maximum, 1
	Gui, Add, CheckBox, Hidden Checked%max% vmax, Reload to maximum.
	Gui, Add, Text, Hidden, Reload when under
	Gui, Add, Edit, Hidden w40 Number Right
	IniRead, blinds, PokerPad.ini, Reload, BigBlinds, 100
	Gui, Add, UpDown, Hidden vblinds Range1-100, % blinds
	Gui, Add, Text, Hidden, `% maximum buy-in.
	

	rules .= ",a1 t5|n0 c2|a1 t5_r2 h190|c2 p2 v2|r2 h190_c2 p2 v0"
	ctrlCounts .= ",6"
	Gui, Add, Text, Hidden, Auto Load
	Gui, Add, Text, Hidden, Available
	available =
	Loop, *.ahk
		if available {
			available .= "|" . A_LoopFileName
		} else {
			available := A_LoopFileName
		}
	autoLoad := A_ScriptName
	ListRemoveAll(available, autoLoad, "|")
	IniRead, autoLoad, PokerPad.ini, General, AutoLoad, %A_Space%
	StringReplace, autoLoad, autoLoad, `,, |
	if autoLoad
		ListRemoveAll(available, autoLoad, "|", "|")
	autoLoadInitial := autoLoad
	availableInitial := available
	Gui, Add, ListBox, Hidden r10 AltSubmit, %autoLoad%
	Gui, Add, Button, Hidden gSettings_Remove, >
	Gui, Add, ListBox, Hidden r10 AltSubmit, %available%
	Gui, Add, Button, Hidden gSettings_Add, <
*/
	

	
	Gui, Add, Button, , OK
	Gui, Add, Button, gGuiClose, Cancel
	Gui, Add, Hotkey, gSettings_ChangeHotkey, ^Right
	Gui, Add, Text, , =
	Gui, Add, Edit, gSettings_ChangeHotkeyEdit, ^Right
	
	WinGet, ctrls, ControlList

	TreeTableLayout(ctrls, ctrlCounts, rules, 2, 0, 0, 8, w, h, "r c2 c3 c4 c5")
	
	selected := 1
	bottomCtrls := ListSegment(ctrls, -5, 0, "`n")
	
	global Border, Caption
	ControlGetPos, x, y, , , % ListGet(ctrls, 0, "`n")
	y += h+5
	width := w
	rules := "a1 w60|a1 w60|n0 w40|w100|v1|w120"
	resizeRules := "r c1 c2 c3 c5 c6"
	spacing := 2
	margin := 0

	TableLayout(bottomCtrls, rules, spacing, margin, margin, x, y, width, height, resizeRules)
	
	w += 10
	h += height + 15
	SysGet, area, MonitorWorkArea
	x := areaRight - w - Caption
	y := areaBottom - h - Caption

	Gui, Show, x%x% y%y% w%w% h%h%, Settings
	
	Critical, Off
	
	return
	Settings_ChangeHotkey:
		GuiControlGet, h, , % ListGet(ctrls, -3, "`n")
		GuiControl, , % ListGet(ctrls, -1, "`n"), %h%
		return
	Settings_ChangeHotkeyEdit:
		GuiControlGet, h, , % ListGet(ctrls, -1, "`n")
		GuiControl, , % ListGet(ctrls, -3, "`n"), %h%
		return
	ButtonOK:
		Gui, Submit
		if InStr(reload, "^") {
			MsgBox, Reload cannot contain that modifier CTRL as this is used internally to denote a Default Reload.
			TV_Modify(table_hotkeys)
			Gui, Show
			return
		}
		if InStr(activateTable, "^") {
			MsgBox, Activate Table cannot contain that modifier CTRL as this is used internally to toggle the hotkey on/off.
			TV_Modify(global_hotkeys)
			Gui, Show
			return
		}
		if InStr(allInThisHand, "+") {
			MsgBox, Unconditional All In cannot contain that modifier SHIFT as this is used internally to cancel all Unconditional All Ins.
			TV_Modify(betting)
			Gui, Show
			return
		}
		if InStr(lobby, "+") {
			MsgBox, Lobby cannot contain that modifier SHIFT as this is used internally to active the main lobby.
			TV_Modify(table_hotkeys)
			Gui, Show
			return
		}
		
		IniWrite, %lastHand%, Pokerpad.ini, Hotkeys, LastHand
		IniWrite, %reload%, Pokerpad.ini, Hotkeys, Reload
		IniWrite, %lobby%, Pokerpad.ini, Hotkeys, Lobby
		IniWrite, %autoMuck%, Pokerpad.ini, Hotkeys, ToggleAutoMuck
		IniWrite, %allInThisHand%, Pokerpad.ini, Hotkeys, AllInThisHand
		IniWrite, %fold%, Pokerpad.ini, Hotkeys, Fold
		IniWrite, %call%, Pokerpad.ini, Hotkeys, Call
		IniWrite, %raise%, Pokerpad.ini, Hotkeys, Raise
		IniWrite, %ffold%, Pokerpad.ini, Hotkeys, FastFold
		IniWrite, %clear%, Pokerpad.ini, Hotkeys, ClearBetBox
		IniWrite, %foldAny%, Pokerpad.ini, Hotkeys, FoldAny
		IniWrite, %autoPost%, Pokerpad.ini, Hotkeys, AutoPost
		IniWrite, %sitOut%, Pokerpad.ini, Hotkeys, SitOut
		IniWrite, %left%, Pokerpad.ini, Hotkeys, NextWindow_Left
		IniWrite, %right%, Pokerpad.ini, Hotkeys, NextWindow_Right
		IniWrite, %up%, Pokerpad.ini, Hotkeys, NextWindow_Up
		IniWrite, %down%, Pokerpad.ini, Hotkeys, NextWindow_Down
		IniWrite, %typeBet%, Pokerpad.ini, Hotkeys, TypeBet
		IniWrite, %randomBet%, Pokerpad.ini, Hotkeys, RandomBet
		IniWrite, %allIn%, Pokerpad.ini, Hotkeys, AllIn
		IniWrite, %incBet%, Pokerpad.ini, Hotkeys, IncreaseBet
		IniWrite, %incBet2%, Pokerpad.ini, Hotkeys, IncreaseBet2
		IniWrite, %decBet%, Pokerpad.ini, Hotkeys, DecreaseBet
		IniWrite, %decBet2%, Pokerpad.ini, Hotkeys, DecreaseBet2
		IniWrite, %factor1%, Pokerpad.ini, Bets, Relative1
		IniWrite, %factor2%, Pokerpad.ini, Bets, Relative2
		IniWrite, %factor3%, Pokerpad.ini, Bets, Relative3
		IniWrite, %factor4%, Pokerpad.ini, Bets, Relative4
		IniWrite, %factor5%, Pokerpad.ini, Bets, Relative5
		IniWrite, %factor6%, Pokerpad.ini, Bets, Relative6
		IniWrite, %factor7%, Pokerpad.ini, Bets, Relative7
		IniWrite, %factor8%, Pokerpad.ini, Bets, Relative8
		IniWrite, %factor9%, Pokerpad.ini, Bets, Relative9
		IniWrite, %ffactor1%, Pokerpad.ini, Bets, Fixed1
		IniWrite, %ffactor2%, Pokerpad.ini, Bets, Fixed2
		IniWrite, %ffactor3%, Pokerpad.ini, Bets, Fixed3
		IniWrite, %ffactor4%, Pokerpad.ini, Bets, Fixed4
		IniWrite, %ffactor5%, Pokerpad.ini, Bets, Fixed5
		IniWrite, %ffactor6%, Pokerpad.ini, Bets, Fixed6
		IniWrite, %ffactor7%, Pokerpad.ini, Bets, Fixed7
		IniWrite, %ffactor8%, Pokerpad.ini, Bets, Fixed8
		IniWrite, %ffactor9%, Pokerpad.ini, Bets, Fixed9
		IniWrite, %ftick%, PokerPad.ini, HotKeys, Ftick
		IniWrite, %relative1%, Pokerpad.ini, Hotkeys, Relative1
		IniWrite, %relative2%, Pokerpad.ini, Hotkeys, Relative2
		IniWrite, %relative3%, Pokerpad.ini, Hotkeys, Relative3
		IniWrite, %relative4%, Pokerpad.ini, Hotkeys, Relative4
		IniWrite, %relative5%, Pokerpad.ini, Hotkeys, Relative5
		IniWrite, %relative6%, Pokerpad.ini, Hotkeys, Relative6
		IniWrite, %relative7%, Pokerpad.ini, Hotkeys, Relative7
		IniWrite, %relative8%, Pokerpad.ini, Hotkeys, Relative8
		IniWrite, %relative9%, Pokerpad.ini, Hotkeys, Relative9
		IniWrite, %rtick%, PokerPad.ini, Hotkeys, Rtick
		IniWrite, %fixed1%, Pokerpad.ini, Hotkeys, Fixed1
		IniWrite, %fixed2%, Pokerpad.ini, Hotkeys, Fixed2
		IniWrite, %fixed3%, Pokerpad.ini, Hotkeys, Fixed3
		IniWrite, %fixed4%, Pokerpad.ini, Hotkeys, Fixed4
		IniWrite, %fixed5%, Pokerpad.ini, Hotkeys, Fixed5
		IniWrite, %fixed6%, Pokerpad.ini, Hotkeys, Fixed6
		IniWrite, %fixed7%, Pokerpad.ini, Hotkeys, Fixed7
		IniWrite, %fixed8%, Pokerpad.ini, Hotkeys, Fixed8
		IniWrite, %fixed9%, Pokerpad.ini, Hotkeys, Fixed9
		
		IniWrite, % preflop1, PokerPad.ini, Bets, Preflop1
		IniWrite, % preflop2, PokerPad.ini, Bets, Preflop2
		IniWrite, % preflop3, PokerPad.ini, Bets, Preflop3
		IniWrite, % flop1, PokerPad.ini, Bets, Flop1
		IniWrite, % flop2, PokerPad.ini, Bets, Flop2
		IniWrite, % flop3, PokerPad.ini, Bets, Flop3
		IniWrite, % turn1, PokerPad.ini, Bets, Turn1
		IniWrite, % turn2, PokerPad.ini, Bets, Turn2
		IniWrite, % turn3, PokerPad.ini, Bets, Turn3
		IniWrite, % river1, PokerPad.ini, Bets, River1
		IniWrite, % river2, PokerPad.ini, Bets, River2
		IniWrite, % river3, PokerPad.ini, Bets, River3
		IniWrite, % street1, PokerPad.ini, Hotkeys, Street1
		IniWrite, % street2, PokerPad.ini, Hotkeys, Street2
		IniWrite, % street3, PokerPad.ini, Hotkeys, Street3
		
		IniWrite, %sitInAll%, Pokerpad.ini, Hotkeys, SitInAll
		IniWrite, %sitOutAll%, Pokerpad.ini, Hotkeys, SitOutAll
		IniWrite, %autoPostOnAll%, Pokerpad.ini, Hotkeys, AutoPostOnAll
		IniWrite, %autoPostOffAll%, Pokerpad.ini, Hotkeys, AutoPostOffAll
		IniWrite, %leaveAll%, Pokerpad.ini, Hotkeys, LeaveAll
		IniWrite, %tile%, Pokerpad.ini, Hotkeys, Tile
		IniWrite, %activateTable%, Pokerpad.ini, Hotkeys, ActivateTable
		IniWrite, %SuspendHotkeys%, Pokerpad.ini, Hotkeys, SuspendHotkeys
		IniWrite, %debug%, Pokerpad.ini, Hotkeys, Debug
		

		IniWrite, %ipoker%, Pokerpad.ini, General, iPoker
		IniWrite, %party%, Pokerpad.ini, General, PartyPoker
		IniWrite, %pacific%, Pokerpad.ini, General, Pacific
		IniWrite, %sky%, Pokerpad.ini, General, SkyPoker
		IniWrite, %swc%, Pokerpad.ini, General, SwCPoker
		IniWrite, %acr%, Pokerpad.ini, General, ACR
		;IniWrite, 1, Pokerpad.ini, General, ACR
		

		IniWrite, %path_ipoker%, Pokerpad.ini, IPoker, Path
		IniWrite, %path_party%, Pokerpad.ini, PartyPoker, Path
		IniWrite, %path_pacific%, Pokerpad.ini, Pacific, Path
		IniWrite, %path_swc%, Pokerpad.ini, SwCPoker, Path
		IniWrite, %path_acr%, Pokerpad.ini, ACR, Path
		
		
		IniWrite, %pot_ipoker%, PokerPad.ini, Ipoker, PotButton
		IniWrite, %pot_pacific%, PokerPad.ini, Pacific, PotButton
		IniWrite, %pot_swcpoker%, PokerPad.ini, SwCPoker, PotButton
		IniWrite, %pot_acr%, PokerPad.ini, ACR, PotButton
		;IniWrite, %preflop_ipoker%, PokerPad.ini, Ipoker, Preflop
		;IniWrite, %postflop_ipoker%, PokerPad.ini, Ipoker, Postflop
		
		IniWrite, %timebank_pacific%, PokerPad.ini, Pacific, Timebank
		IniWrite, %usebb_pacific%, PokerPad.ini, Pacific, UseBB
		
		IniWrite, %usebb_acr%, PokerPad.ini, ACR, UseBB

		;SetCurrencyFormat(format_ongame, "Ongame")
		SetCurrencyFormat(format_party, "PartyPoker")
		;SetCurrencyFormat(format_everest, "EverestPoker")
		
		r := -betRounding + 1
		IniWrite, %r%, Pokerpad.ini, General, Rounding
		r := -betIncrement
		IniWrite, %r%, Pokerpad.ini, General, Increment
		r := -betIncrement2
		IniWrite, %r%, Pokerpad.ini, General, Increment2
		IniWrite, %minRandom%, Pokerpad.ini, Bets, RandomMin
		IniWrite, %maxRandom%, Pokerpad.ini, Bets, RandomMax
		
		IniWrite, %monitors%, Pokerpad.ini, Tile, Monitors
		IniWrite, %tables%, Pokerpad.ini, Tile, Tables
		IniWrite, %mouse%, Pokerpad.ini, General, UseMouse
		
		IniWrite, %muck%, PokerPad.ini, Reload, AutoMuck
		IniWrite, %max%, PokerPad.ini, Reload, Maximum
		IniWrite, %blinds%, PokerPad.ini, Reload, BigBlinds
		
		if available {
			ListRemoveAll(available, availableInitial, "|", "|")
			if available {
				StringReplace, available, available, |, `,
				Unload(available)
			}
		}
		StringReplace, autoLoad, autoLoad, |, `,
		IniWrite, %autoLoad%, PokerPad.ini, General, AutoLoad

		Reload
	GuiClose:
		Gui, Destroy
		return
	Settings_Event:
		if InStr(A_GuiEvent, "S", true) {
			Settings_SetVisibility(ctrls, ctrlCounts, selected, "Hide")
			if (A_EventInfo == global_hotkeys)
				selected := 1
			else if (A_EventInfo == table_hotkeys)
				selected := 2
			else if (A_EventInfo == actions)
				selected := 3
			else if (A_EventInfo == betting)
				selected := 4
			else if (A_EventInfo == pot)
				selected := 5
			else if (A_EventInfo == fixed)
				selected := 6
			;else if (A_EventInfo == street)
			;	selected := 7 
			else if (A_EventInfo == options)
				selected := 7
			else if (A_EventInfo == options_betting)
				selected := 8
			else if (A_EventInfo == options_sites)
				selected := 9
			/* 
			else if (A_EventInfo == options_reload)
				selected := 19
			else if (A_EventInfo == options_autoload)
				selected := 20
			else if (A_EventInfo == sites_fulltilt)
				selected := 10
			else if (A_EventInfo == sites_stars)
				selected := 11
			*/
			else if (A_EventInfo == sites_ipoker)
				selected := 10
			
			else if (A_EventInfo == sites_party)
				selected := 11 
			/*
			else if (A_EventInfo == sites_everest)
				selected := 14
			else if (A_EventInfo == sites_ongame)
				selected := 15
			else if (A_EventInfo == sites_cake)
				selected := 16
			else if (A_EventInfo == sites_micro)
				selected := 17
			*/
			else if (A_EventInfo == sites_pacific)
				selected := 12
			else if (A_EventInfo == sites_sky)
				selected := 13
			else if (A_EventInfo == sites_swc)
				selected := 14
			Settings_SetVisibility(ctrls, ctrlCounts, selected, "Show")
		}
		return
	Settings_Remove:
		Settings_Swap(ListGet(ctrls, -9, "`n"), ListGet(ctrls, -7, "`n"), autoLoad, available)
		return
	Settings_Add:
		Settings_Swap(ListGet(ctrls, -7, "`n"), ListGet(ctrls, -9, "`n"), available, autoLoad)
		return

}
Settings_SetVisibility(ByRef ctrls, ByRef ctrlCounts, index, visibility) {
	i := 1
	Loop, Parse, ctrlCounts, `,
	{
		j := i + A_Loopfield
		if (A_Index == index) {
			tabCtrls := ListSegment(ctrls, i, j, "`n")
			Loop, Parse, tabCtrls, `n
				GuiControl, %visibility%, %A_LoopField%
			return
		}
		i := j
	}
}
Settings_Swap(c1, c2, ByRef l1, ByRef l2) {
		GuiControlGet, index, , %c1%
		if !index
			return
		ListAdd(l2, ListRemove(l1, index-1, "|"), 0, "|")
		GuiControl, , %c2%, % "|" . l2
		GuiControl, , %c1%, % "|" . l1
		GuiControl, Choose, %c2%, % ListSize(l2, "|")
}

SetCurrencyFormat(format, client) {
	IniWrite, % SubStr(format, 1, 1), PokerPad.ini, % client, Currency
	separator := SubStr(format, 3, 1)
	if separator is number
		separator := ""
	IniWrite, % separator, PokerPad.ini, % client, Separator
	decimal := SubStr(format, 7, 1)
	if (decimal == ".")
		decimal := ""
	IniWrite, % decimal, PokerPad.ini, % client, Decimal
}

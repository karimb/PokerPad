Pacific_GetBlind(big) {
	WinGetTitle, title
	RegExMatch(title, " \D?(\d+).?/\D?(\d+)", match)
	if (InStr(title, "¢")) {
		match1 /= 100.0
		match2 /= 100.0
	}
	blind := big ? match2 : match1
	return CurrencyToFloat(blind)
}

Pacific_CheckTimeBank(id, context) {
	local w,h,x,y,bgr,color,diff
	x := 681
	y := 439
	;the color is the orange used by the timebank button in BGR
	color := 0x037FFE
	diff := 10
	WinGetPos, , , w, h, ahk_id %id%
	w /= 800.0
	h /= 579.0
	x := Round(x * w)
	y := Round(y * h)
	bgr := Display_GetPixel(context, x, y) 
	;PixelGetColor, bgr, x, y
	return Display_CompareColors(bgr, color, diff)
}
/*  Functions for searching/reading what is displayed by a window.
 *  
 *  License:
 *  	Display v0.2 by Xander, contributions from Dave (CreateWindowCapture, DeleteWindowCapture, GetPixel)
 *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
 */

 
/*  Usage:
 *  	Creates an offscreen capture of a window. The window cannot be minimized but may be invisible.
 *  Parameters:
 *  	id: The window's id of which to create a capture
 *  	device, context, pixels: Blank variables, see Releasing Memory below.
 *  Releasing Memory:
 *  	After the capture is no longer needed, it's memory must be freed by calling Display_DeleteWindowCapture(device, context, pixels)
 *      where the 3 parameters are those that was passed to create the window capture.
 */
Display_CreateWindowCapture(ByRef device, ByRef context, ByRef pixels, ByRef id = "") {	
	if !id
		WinGet, id, ID
	device := DllCall("GetDC", UInt, id)
	context := DllCall("gdi32.dll\CreateCompatibleDC", UInt, device)
	WinGetPos, , , w, h, ahk_id %id%
	pixels := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt, device, Int, w, Int, h)
	DllCall("gdi32.dll\SelectObject", UInt, context, UInt, pixels)
	DllCall("PrintWindow", "UInt", id, UInt, context, UInt, 0)
}

Display_DeleteWindowCapture(ByRef device, ByRef context, ByRef pixels, ByRef id = "") {
	if !id
		WinGet, id, ID
	DllCall("gdi32.dll\ReleaseDC", UInt, id, UInt, device)
	DllCall("gdi32.dll\DeleteDC", UInt, context)
	DllCall("gdi32.dll\DeleteObject", UInt, pixels)
}


/*  Usage:
 *  	Gets the pixel from a window capture created from Display_CreateWindowCapture
 *  Parameters:
 *  	context: the device context as given by Display_CreateWindowCapture
 *  	x, y: the coordinate parameters
 *  Return:
 *  	The pixel in BGR format.
 */
Display_GetPixel(ByRef context, x, y) {
	return DllCall("GetPixel", UInt, context, Int, x, Int, y)
}


/*  Usage:
 *  	Searches for the specifed color in the given rectangle of a window capture created from Display_CreateWindowCapture
 *  Parameters:
 *  	x, y, w, h: the rectangle parameters to search
 *  	color: the color in BGR format or one of:
 *  		BlueBackground, BlueForeground, GreenBackground, GreenForeground, RedBackground, RedForeground
 *  		CyanBackground, CyanForeground, YellowBackground, YellowForeground, VioletBackground, VioletForeground
 *  		DarkBackground, DarkForeground, LightBackground, LightForeground
 *  	variation: the allowed variation from the specified color
 *  	id: either a window id or the letter c followed by the device context handle as given by Display_CreateWindowCapture
 *  		if no id is specified, the Last Found Window will be used.
 *  Return:
 *  	Returns true if the specified color/variation is found within the given area, false otherwise.
 */
Display_PixelSearch(x, y, w, h, color, variation = 0, ByRef id = "") {
	Display_GetContext(device, context, pixels, id)
	if color is not integer
		isPixel = Display_%color%
	Loop, %w% {
		j := y
		Loop, %h% {
			bgr := Display_GetPixel(context, x, j++)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if device
					Display_DeleteWindowCapture(device, context, pixels)
				return true
			}
		}
		x++
	}
	if device
		Display_DeleteWindowCapture(device, context, pixels, id)
	return false
}


Display_GetContext(ByRef device, ByRef context, ByRef pixels, ByRef id) {
	if !id
		Display_CreateWindowCapture(device, context, pixels)
	else if (SubStr(id, 1, 1) = "c")
		context := SubStr(id, 2)
	else
		Display_CreateWindowCapture(device, context, pixels, id)
}


Display_CompareColors(ByRef bgr1, ByRef bgr2, variation = 0) {
	c1 := bgr1 & 0xff
	c2 := bgr2 & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (bgr1 >> 8) & 0xff
	c2 := (bgr2 >> 8) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (bgr1 >> 16) & 0xff
	c2 := (bgr2 >> 16) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	return true
}


Display_CompareRGBToBGR(ByRef rgb, ByRef bgr, ByRef variation) {
	c1 := (rgb >> 16) & 0xff
	c2 := bgr & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (rgb >> 8) & 0xff
	c2 := (bgr >> 8) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := rgb & 0xff
	c2 := (bgr >> 16) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	return true
}

Display_IsBlue(ByRef bgr, ByRef variation) {
	r := bgr & 0xff
	g := (bgr >> 8) & 0xff
	b := ((bgr >> 16) & 0xff) - variation
	return b > r && b > g
}

Display_IsGreen(ByRef bgr, ByRef variation = 0) {
	r := bgr & 0xff
	g := ((bgr >> 8) & 0xff) - variation
	b := (bgr >> 16) & 0xff
	return g > r && g > b
}

Display_IsRed(ByRef bgr, ByRef variation = 0) {
	r := (bgr & 0xff) - variation
	g := (bgr >> 8) & 0xff
	b := (bgr >> 16) & 0xff
	return r > b && r > g
}

Display_IsCyan(ByRef bgr, ByRef variation = 0) {
	g := (bgr >> 8) & 0xff
	if (r < 120)
		return false
	b := (bgr >> 16) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += (bgr & 0xff) + 16
	return r > d && g > d
}

Display_IsViolet(ByRef bgr, ByRef variation = 0) {
	r := bgr & 0xff
	if (r < 120)
		return false
	b := (bgr >> 16) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += ((bgr >> 8) & 0xff) + 16
	return r > d && g > d
}

Display_IsYellow(ByRef bgr, ByRef variation = 0) {
	r := bgr & 0xff
	if (r < 120)
		return false
	g := (bgr >> 8) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += ((bgr >> 16) & 0xff) + 16
	return r > d && g > d
}

Display_IsLight(ByRef bgr, ByRef variation = 0) {
	c := (bgr & 0xff) - variation
	if (c < 200)
		return false
	c := ((bgr >> 8) & 0xff) - variation
	if (c < 200)
		return false
	c := ((bgr >> 16) & 0xff) - variation
	return c >= 200
}

Display_IsDark(ByRef bgr, ByRef variation = 0) {
	c := (bgr & 0xff) - variation
	if (c < 100)
		return true
	c := ((bgr >> 8) & 0xff) - variation
	if (c < 100)
		return true
	c := ((bgr >> 16) & 0xff) - variation
	return c < 100
}




Display_FindPixelHorizontal(ByRef x, ByRef y, ByRef w, ByRef h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	j := y
	Loop, %h% {
		i := x
		Loop, %w% {
			bgr := Display_GetPixel(context, i++, j)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				w -= i - x
				h -= j - y
				x := i
				y := j
				return true
			}
		}
		j++
	}
	return false
}

Display_FindPixelVertical(ByRef x, ByRef y, ByRef w, ByRef h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	i := x
	Loop, %w% {
		j := y
		Loop, %h% {
			bgr := Display_GetPixel(context, i, j)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				w -= i - x
				h -= j - y
				x := i
				y := j
				return true
			}
			j++
		}
		i++
	}
	return false
}


/*	Usage:
 *  	Updates the variables y and h based on the vertical position and height of the text found at x,y
 *  Parameters:
 *  	x: x position to start searching for text
 *  	y: y position where text will be found
 *  	w: maximum width to search
 *  	h: blank variable, will be updated with the correct height
 *  	color: a color in BGR format or one of the following:
 *  		BlueBackground - any color that is not a shade of blue will be recognized as text
 */
Display_FindText(ByRef x, ByRef y, ByRef w, ByRef h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	minX := x + w
	row := y
	GoSub, Display_FTFindTop
	top := row
	row := y+1
	column := x
	GoSub, Display_FTFindBottom
	y := top
	h := row - top + 2
	if (x != minX)
		minX -= 2
	w -= minX - x
	x := minX
	return
	Display_FTFindTop:
		column := x
		Loop, %w% {
			bgr := Display_GetPixel(context, column, row)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if (column < minX)
					minX := column
				row--
				GoTo, Display_FTFindTop
			}
			column++
		}
		return
	Display_FTFindBottom:
		column := x
		Loop, %w% {
			bgr := Display_GetPixel(context, column, row)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if (column < minX)
					minX := column
				row++
				GoTo, Display_FTFindBottom
			}
			column++
		}
		return
}

Display_IsPixel(ByRef label, ByRef bgr, ByRef variation) {
	GoSub, %label%
	return isPixel
	Display_BlueForeground:
		isPixel := Display_IsBlue(bgr, variation)
		return
	Display_BlueBackground:
		isPixel := !Display_IsBlue(bgr, variation)
		return
	Display_GreenForeground:
		isPixel := Display_IsGreen(bgr, variation)
		return
	Display_GreenBackground:
		isPixel := !Display_IsGreen(bgr, variation)
		return
	Display_RedForeground:
		isPixel := Display_IsRed(bgr, variation)
		return
	Display_RedBackground:
		isPixel := !Display_IsRed(bgr, variation)
		return
	Display_CyanForeground:
		isPixel := Display_IsCyan(bgr, variation)
		return
	Display_CyanBackground:
		isPixel := !Display_IsCyan(bgr, variation)
		return
	Display_YellowForeground:
		isPixel := Display_IsYellow(bgr, variation)
		return
	Display_YellowBackground:
		isPixel := !Display_IsYellow(bgr, variation)
		return
	Display_VioletForeground:
		isPixel := Display_IsViolet(bgr, variation)
		return
	Display_VioletBackground:
		isPixel := !Display_IsViolet(bgr, variation)
		return
	Display_DarkForeground:
		isPixel := Display_IsDark(bgr, variation)
		return
	Display_DarkBackground:
		isPixel := !Display_IsDark(bgr, variation)
		return
	Display_LightForeground:
		isPixel := Display_IsLight(bgr, variation)
		return
	Display_LightBackground:
		isPixel := !Display_IsLight(bgr, variation)
		return
}






















/*
  	Gui, +LastFound
  	Gui, Add, Text, w100 HwndTextID, $123,456.7890
  	Gui, Show
  	ControlGetPos, x, y, w, h, , ahk_id %TextID%
	WinGet, id, ID
	t0 := A_TickCount
  	text := Display_ReadArea(x, y, w, h, 0x000000, 8, id)
	t := A_TickCount - t0
  	MsgBox, Read text area as: %text%`n%t%
*/





















/*  Usage:
 *  	Reads a portion of the screen assuming that the only characters are $.,0123456789
 *  Parameters:
 *  	x: The x position to start reading.
 *  	y: The y position to start reading.
 *  	w: The width to read from x.
 *  	h: The height to read from y.
 *  	color: The color to read in BGR format or one of the following:
 *  		BlueBackground, BlueForeground, GreenBackground, GreenForeground, RedBackground, RedForeground
 *  		CyanBackground, CyanForeground, YellowBackground, YellowForeground, VioletBackground, VioletForeground
 *  		DarkBackground, DarkForeground, LightBackground, LightForeground
 *  	variation: The variation allowed from the specified color to be considered part of the text.
 *  	id: The window id to read or alternatively, the letter c followed by the device context handle of an already created window capture.
 *  		If blank, the specified area will be read from the screen. Otherwise the area will be read from an offscreen capture of the window - this method is more reliable and usually faster than the former.
 *  Note:
 *  	Not all fonts will be recognized properly. To test a font, use the example below, but change the font.
 *  	Supporting other fonts can be done by using the same example and uncommenting the println(signature) line and providing the output function of println(str).
 *  Example:
 *  	Gui, +LastFound
 *  	Gui, Add, Text, w100 HwndTextID, $123,456.7890
 *  	Gui, Show
 *  	ControlGetPos, x, y, w, h, , ahk_id %TextID%
 *  	text := Display_ReadArea(x, y, w, h)
 *  	MsgBox, Read text area as: %text%
 */
Display_ReadArea(x, y, w, h, color = "", variation = 0, ByRef id = "", maxwidth = 0, exclude = "", callback = "") {
;global Display_Signature := ""
	if !maxwidth
		maxwidth := h
	h2 := h * 2
	text := ""
	width := 0
	column := 1
	spaces := 0
	xi := x
	if exclude {
		prevPixel := true
		i := InStr(exclude, ",")
		if i
			StringSplit, exclude, exclude, `,
		else {
			exclude1 := exclude
			exclude2 := 0
		}
		if exclude1 is not integer
			isNotPixel = Display_%exclude1%
	}
	if id {
		if (SubStr(id, 1, 1) = "c") {
			context := SubStr(id, 2)
		} else {
			Display_CreateWindowCapture(device, context, pixels, id)
		}
		GoSub, Display_SetPixels
		if device
			Display_DeleteWindowCapture(device, context, pixels, id)
	} else {
		GoSub, Display_SetPixels
	}
;Display_Signature .= text . "`n"
	return text
	Display_SetPixels:
		if (color = "") {
			if context
				bgr := DllCall("GetPixel", UInt, context, Int, x, Int, y)
			else
				PixelGetColor, bgr, x, y
			isPixel = Display_LightBackground
			if Display_IsPixel(isPixel, bgr, variation)
				isPixel = Display_DarkBackground
		} else if color is not integer
			isPixel = Display_%color%
		Loop, %w% {
			yi := y
			Loop, %h% {
				if context
					bgr := DllCall("GetPixel", UInt, context, Int, xi, Int, yi++)
				else
					PixelGetColor, bgr, xi, yi++
				;row := A_Index
				pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
				if exclude {
					if (pixel && !prevPixel) {
						pixel := !(isNotPixel ? Display_IsPixel(isNotPixel, bgr, exclude2) : Display_CompareColors(bgr, exclude1, exclude2))
					}
					prevPixel := pixel
				}
				pixels%column%_%A_Index% := pixel
			}
			xi++
			; Check if column has any pixels or if the pixels are not continuous with the previous column
			row = 0
			GoSub, Display_NextSetPixel
			if !row {
				isBreak := 1
			} else if !width {
				isBreak := 0
			} else {
				Loop {
					c := column - 1
					if (pixels%c%_%row%
							|| (--row >= 0 && pixels%c%_%row%)
							|| ((row+=2) <= h && pixels%c%_%row%)) {
						isBreak := 0
						break
					}
					row--
					GoSub, Display_NextSetPixel
					if !row {
						xi--
						isBreak := 1
						break
					}
				}
			}
			if isBreak {
				if width {
					if checkSpaces {
						text .= spaces ? "I" : "l"
						checkSpaces := false
					}
					GoSub, Display_ReadDigit
					spaces := 0
				} else {
					if (text && ++spaces > h2) {
						return
					}
				}
				width := 0
				column := 1
			} else {
				if (++width >= maxwidth) {
					GoSub, Display_ReadDigit
					spaces := 0
					width := 0
					column := 1
				} else {
					column++
				}
			}
		}
		return
	Display_ReadDigit:
		top := h
		bottom := 0
		Loop, %h% {
			r := A_Index
			Loop, %width% {
				if pixels%A_Index%_%r% {
					top := r
					GoTo, Display_FoundTop
				}
			}
		}
		Display_FoundTop:
		r := h
		Loop, %h% {
			Loop, %width% {
				if pixels%A_Index%_%r% {
					bottom := r
					GoTo, Display_FoundBottom
				}
			}
			r--
		}
		Display_FoundBottom:
		signature =
		ht := Round((bottom - top) / 10)
		wh := Round(width / 10)
		c := 1
		GoSub, Display_SetColumnSequences
		c := width - wh
		GoSub, Display_SetColumnSequences
		r := top
		GoSub, Display_SetRowSequences
		r := bottom - ht
		GoSub, Display_SetRowSequences
;Display_Signature .= signature . " " . width . " " . spaces . "`n"
		if callback {
			label = %callback%%signature%
			if IsLabel(label) {
; println("`t" . label)
				ErrorLevel =
				GoSub, %label%
				Display_InterpretAction:
				if (StrLen(ErrorLevel) > 1) {
					if IsLabel(ErrorLevel) {
						GoSub, %ErrorLevel%
						ErrorLevel := isTrue ? isTrue : -1
						GoSub, %label%
						GoTo, Display_InterpretAction
					} else {
						label = Display_%ErrorLevel%
						if IsLabel(label)
							GoSub, %label%
						else
							text .= ErrorLevel
						return
					}
				} else {
					text .= ErrorLevel
					return
				}
			}
		}
		label = Display_%signature%
		if IsLabel(label)
			GoSub, %label%
		else
			text .= " "
		return
	Display_SetColumnSequences:
		sequences := 0
		last := false
		set := 0
		sig = 
		Loop, %h% {
			i := A_Index
			isSet := pixels%c%_%i%
			if (!isSet && wh) {
				c2 := c
				Loop {
					c2++
					isSet := pixels%c2%_%i%
					if (isSet || A_Index >= wh)
						break
				}
			}
			if (isSet != last) {
				last := isSet
				if (isSet) {
					set := i
				} else {
					sequences += 1
					clear := i - 1
					sig .= set == top ? (clear == bottom ? "D" : "A") : clear == bottom ? "C" : "B"
				}
			}
		}
		if (last) {
			sequences += 1
			sig .= set == top ? "D" : "C"
		}
		signature .= sequences . sig
		return
	Display_SetRowSequences:
		sequences := 0
		last := false
		set := 0
		sig = 
		t := width
		Loop, %width% {
			i := A_Index
			isSet := pixels%i%_%r%
			if (!isSet && ht) {
				r2 := r
				Loop {
					r2++
					isSet := pixels%i%_%r2%
					if (isSet || A_Index >= ht)
						break
				}
			}
			if (isSet != last) {
				last := isSet
				if (isSet) {
					set := i
				} else {
					sequences += 1
					clear := i - 1
					sig .= set == 1 ? (clear == t ? "D" : "A") : clear == t ? "C" : "B"
				}
			}
		}
		if (last) {
			sequences += 1
			sig .= set == 1 ? "D" : "C"
		}
		signature .= sequences . sig
		return
	Display_NextSetPixel:
		Loop {
			if (++row > h)
				break
			if pixels%column%_%row%
				return
		}
		row = 0
		return
	Display_NextClearPixel:
		Loop {
			if (++row > h)
				break
			if !pixels%column%_%row%
				return
		}
		row = 0
		return
	Display_NextSetPixelH:
		Loop {
			if (++column > width)
				break
			if pixels%column%_%row%
				return
		}
		column = 0
		return
	Display_NextClearPixelH:
		Loop {
			if (++column > width)
				break
			if !pixels%column%_%row%
				return
		}
		column = 0
		return
	Display_2BB2BB1C1B:
	Display_2BB2BB1B1A:
	Display_2AB2AB1D1B:
	Display_2BB2BB1B1B:
		text .= "$"
		return
	Display_1C1A1C1A: ; , /
		if (top < h/2) {
			text .= "/"
			return
		}
	Display_1A1D1D1C:
		text .= ","
		return
	Display_2BC1C1A1D:
	Display_1B1D1D1C:
		text .= 1
		return
	Display_2AC2BC1D1D:
	Display_2AC2AC1B1D:
	Display_2AC2AC1A1D:
	Display_2AC2BC1A1D:
	Display_2BC2BC1B1D:
	Display_2BC2BC1D1D:
		text .= 2
		return
	Display_2AC2BB1D1D:
		text .= 3
		return
	Display_1B1D1B1D:
	Display_1B1D1B1B:
	Display_1B1B1B1D:
		text .= 4
		return
	Display_2BC2AB1D1D:
	Display_2AC2AB1A1A:
	Display_2AC2AB1B1A:
	Display_2AC2AB1D1A:
	Display_2AC2AC1C1D:
	Display_2AB2AB1D1D:
	Display_2AC2AB1D1D:
		text .= 5
		return
	Display_1D2AC1A1D:
	Display_1C1B1B1A:
	Display_1C1C1B1D:
	Display_1C2AC1B1D:
	Display_1B2BB1B1B:
	Display_1C2AC1C1D:
	Display_1D2AC1D1D:
	Display_1B2BB1D1D:
	Display_1B1B1A1D:
		text .= 6
		return
	Display_1A1A1D1B:
		text .= 7
		return
	Display_2AC1D1D1C:
	Display_1B1B1D1C:
	Display_2BC1A1C1B:
	Display_2BB1B1B1B:
	Display_2BB1B1D1D:
		text .= 9
		return
	Display_1B1B1D1D:
		text .= 0
		return
	Display_1D1A1D1A: ; , P
		text .= top > h/2 ? "," : "P"
		return
	Display_1D1D2AC2AC:
		text .= "N"
		return
	Display_ThreeEight:
	Display_2BB2BB1D1D: ; $ 3 8
		row = 0
		column := Round(width/2)
		d := "$"
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		if row {
			GoSub, Display_NextSetPixel
			if row { ; 3 8
				d := "3"
				GoSub, Display_NextClearPixel
				GoSub, Display_NextSetPixel
				if row
					d := "8"
			}
		}
		text .= d
		return
	Display_PeriodZeroOne: ; . 0 1
		if (top > h/2) {
			text .= "."
			return
		}
		row := Round((top + bottom) / 2)
		column = 0
		GoSub, Display_NextSetPixelH
		GoSub, Display_NextClearPixelH
		if !column {
			text .= 1
			return
		}
		GoSub, Display_NextSetPixelH
		text .= column ? 0 : 1
		return
	Display_SeparatorZeroEight:
	Display_1D1D1D1D: ; . , 0 8
		if (top > h/2) {
;			replaceColon := true
;			text .= ";"
			text .= bottom - top > width ? "," : "."
			return
		} ; 0 8
	Display_ZeroEight:
	Display_1D1B1A1A: ; 0 8
		GoSub, Display_IsMiddle3Seq
		text .= isTrue ? "8" : "0"
		return
	Display_2AC1A1D1A: ; , 7 9
		if (top > h/2) {
			text .= ","
			return
		}
		GoSub, Display_SevenNine
		return
	Display_EightOrNine:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		column = 0
		GoSub, Display_NextSetPixelH
		text .= column < width/2 ? 8 : 9
		return
	Display_ZeroFourSixEightNine:
	Display_1B1B1B1B: ; . 0 4 6 8 9
		if (top > h/2) {
			text .= "."
			return
		}
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		if !row {
			text .= 4
			return
		}
		row--
		i := column
		column = 0
		GoSub, Display_NextSetPixelH
		GoSub, Display_NextClearPixelH
		GoSub, Display_NextSetPixelH
		if !column {
			text .= 6
			return
		}
		row++
		column := i
		GoSub, Display_NextClearPixel
		i := row
		GoSub, Display_NextSetPixel
		if !row { ; 0 4
			text .= i > bottom ? 0 : 4
			return
		} ; 8 9
		row := i
		column = 0
		GoSub, Display_NextSetPixelH
		text .= column < width/2 ? 8 : 9
		return
	Display_ZeroThreeFourEightNine: ; 0 3 4 8 9
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		i := row
		GoSub, Display_NextSetPixel
		if !row {
			text .= i < bottom ? "4" : "0"
			return
		}
		j := row
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		if !row {
			text .= j < bottom ? "4" : "0"
			return
		} ; 3 8 9
		row := Ceil((i + j)/2)
		Loop, %column% {
			if pixels%A_Index%_%row% {
				GoSub, Display_NextClearPixel
				Loop, %column% {
					if pixels%A_Index%_%row% {
						text .= "8"
						return
					}
				}
				text .= "9"
				return
			}
		}
		text .= "3"
		return
	Display_1B1D1C1C: ; 1 4
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		text .= row ? 4 : 1
		return
	Display_TwoThreeFiveEight:
		GoSub, Display_IsEight
		if isTrue {
			text .= 8
			return
		}
	Display_TwoThreeFive:
	Display_2AC2AC1D1D: ; 2 3 5
		GoSub, Display_IsTopRightClosed
		if !isTrue {
			text .= 5
			return
		} ; 2 3
	Display_TwoOrThree:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		if (row == bottom) {
			text .= 3
			return
		}
		GoSub, Display_NextClearPixel
		if (row > bottom) {
			text .= 2
			return
		}
		i := width
		Loop, %column% {
			if pixels%i%_%row% {
				text .= 3
				return
			}
		}
		text .= 2
		return
	Display_TwoDollar:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		i := row
		row = 0
		column := width > 6 ? 2 : 1
		GoSub, Display_NextSetPixel
		text .= row == i ? 2 : "$"
		return
	Display_ThreeFiveDollar:
		GoSub, Display_IsTopLeftClosed
		if isTrue {
			row = 0
			column := Round(width/2)
			GoSub, Display_NextSetPixel
			i := row
			row = 0
			column := width > 6 ? 2 : 1
			GoSub, Display_NextSetPixel
			text .= row == i ? 5 : "$"
			return
		}
		text .= 3
		return
	Display_ThreeFive:
	Display_2AC1B1A1A: ; 3 5
		GoSub, Display_IsTopLeftClosed
		text .= isTrue ? 5 : 3
		return
	Display_ThreeNine:
	Display_2AC1D1D1D: ; 3 9
		GoSub, Display_IsTopLeftClosed
		text .= isTrue ? 9 : 3
		return
	Display_FiveNine:
		GoSub, Display_IsTopRightClosed
		text .= isTrue ? 9 : 5
		return
	Display_SevenNine:
	Display_2AC1A1A1B:
	Display_2AC1A1D1B: ; 7 9
		GoSub, Display_IsMiddle3Seq
		text .= isTrue ? 9 : 7
		return
	Display_IsTopRightClosed:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		if !row {
			isTrue := false
			return
		}
		row--
		Loop, %column% {
			column++
			if pixels%column%_%row% {
				isTrue := true
				return
			}
		}
		isTrue := false
		return
	
	Display_GetWidth:
		isTrue := width
		return
	Display_IsTopLeftClosed:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		row--
		i := Round(column / 2)
		column = 0
		GoSub, Display_NextSetPixelH
		isTrue := column <= i
		return
	Display_IsMiddle2Seq:
		d = 1
		GoSub, Display_IsMiddleNSeq
		return
	Display_IsMiddle3Seq:
		d = 2
	Display_IsMiddleNSeq:
		row = 0
		column := Round(width/2)
		Loop, %d% {
			GoSub, Display_NextSetPixel
			if !row {
				isTrue := false
				return
			}
			GoSub, Display_NextClearPixel
			if !row {
				isTrue := false
				return
			}
			lastRow := row - 1
		}
		GoSub, Display_NextSetPixel
		if !row {
			isTrue := false
			return
		}
		isTrue := true
		return
	Display_IsFirstColumnNearBottom:
		row = 0
		column = 1
		Loop {
			GoSub, Display_NextSetPixel
			if !row
				break
			GoSub, Display_NextClearPixel
			lastRow := row - 1
		}
		isTrue := lastRow > top + (bottom - top) * 0.5
		return
	Display_IsMiddleBottom:
		Loop {
			GoSub, Display_NextSetPixel
			if !row
				break
			GoSub, Display_NextClearPixel
			if !row {
				isTrue := true
				return
			}
			lastRow := row - 1
		}
		isTrue := lastRow == bottom
		return
	Display_IsEight:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		column = 0
		GoSub, Display_NextSetPixelH
		GoSub, Display_NextClearPixelH
		if column {
			GoSub, Display_NextSetPixelH
			if column {
				isTrue := true
				return
			}
		}
		isTrue := false
		return
	Display_IsSeparator:
		isTrue := top > h/2
		return
		
		
		
	Display_ZeroDollar:
		row = 0
		column := Round(width/2)
		GoSub, Display_NextSetPixel
		GoSub, Display_NextClearPixel
		GoSub, Display_NextSetPixel
		if !row {
			text .= "$"
			return
		}
		text .= 0
		return
}


/*  License:
 *  	NextWindow v0.1 by Xander
 *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
 * 
 *  Usage:
 *  	Navigate windows that match the specified title.
 *  
 *  Listeners:
 *  	Supports Listening for a specific class that has been activated by defining an OnActivate_%class% subroutine.
 *  
 *  Example:
 *  	#IfWinActive ahk_class Notepad
 *  	Left:: NextWindow_Left("ahk_class Notepad")
 *  	Right:: NextWindow_Right("ahk_class Notepad")
 *  	Up:: NextWindow_Up("ahk_class Notepad")
 *  	Down:: NextWindow_Down("ahk_class Notepad")
 *  
 *  Listener Example:
 *  	GroupAdd, Windows, ahk_class Notepad
 *  	GroupAdd, Windows, ahk_class TfPSPad
 *  	#IfWinActive ahk_group Windows
 *  	Left:: NextWindow_Left("ahk_group Windows")
 *  	Right:: NextWindow_Right("ahk_group Windows")
 *  	Up:: NextWindow_Up("ahk_group Windows")
 *  	Down:: NextWindow_Down("ahk_group Windows")
 *  	OnActivate_TfPSPad:
 *  		MsgBox, PSPad was activated
 *  		return
 */

NextWindow_Calc(ByRef perp, ByRef parallel, ByRef id, ByRef min, ByRef minID) {
	parallel /= 2
	d := Sqrt(parallel*parallel+perp*perp)
	if (d < min) {
		min := d
		minID := id
	}
}

NextWindow_Activate(Byref id1, ByRef id2, Byref id3) {
	local id := id1 ? id1 : id2 ? id2 : id3 ? id3 : ""
	if !id
		return
	WinActivate, ahk_id %id%
	local window
	WinGetClass, window, ahk_id %id%
	window := "OnActivate_" . window
	if IsLabel(window)
		GoSub, %window%
}

NextWindow_Left(title) {
	WinGet, cId, ID, A
	WinGetPos, cX, cY, , cH
	cH_half := cH/2
	min := A_ScreenWidth
	minRight := min
	maxY := 0
	maxX := 0
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (id == cID)
			continue
		WinGetPos, x, y, w, , ahk_id %id%
		dx := cX - x
		if (dx < 0) {
			dx := A_ScreenWidth - x - w
			if (dx < 0)
				dx := 0
			dy := y - cY
			if (dy < 0)
				NextWindow_Calc(dy, dx, id, minRight, minRightID)
		} else if (dx > 9) {
			dy := abs(cY - y)
			if (dy < cH_half)
				NextWindow_Calc(dy, dx, id, min, minID)
		}
		if (y >= maxY) {
			if (x >= maxX || y > maxY + cH) {
				maxX := x
				maxY := y
				oppID := id
			}
		}
	}
	NextWindow_Activate(minId, minRightID, oppID)
}

NextWindow_Right(title) {
	WinGet, cId, ID
	WinGetPos, cX, cY, , cH
	cH_half := cH/2
	min := A_ScreenWidth
	minLeft := min
	minY := min
	minX := min
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (id == cID)
			continue
		WinGetPos, x, y, w, , ahk_id %id%
		dx := x - cX
		if (dx < 0) {
			dx := x
			if (dx < 0)
				dx := 0
			dy := cY - y
			if (dy < 0)
				NextWindow_Calc(dy, dx, id, minLeft, minLeftID)
		} else if (dx > 9) {
			dy := abs(cY - y)
			if (dy < cH_half)
				NextWindow_Calc(dy, dx, id, min, minID)
		}
		if (y <= minY) {
			if (x <= minX || y < minY - cH_half) {
				minX := x
				minY := y
				oppID := id
			}
		}
	}
	NextWindow_Activate(minId, minLeftID, oppID)
}

NextWindow_Up(title) {
	WinGet, cID, ID
	WinGetPos, cX, cY, cW
	cW_half := cW/2
	min := A_ScreenHeight
	minDown := min
	minX := min
	maxY := 0
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (id == cID)
			continue
		WinGetPos, x, y, , h, ahk_id %id%
		dy := cY - y
		if (dy < 0) {
			dy := A_ScreenHeight - y - h
			if (dy < 0)
				dy := 0
			dx := cX - x
			if (dx < 0)
				NextWindow_Calc(dx, dy, id, minDown, minDownId)
		} else if (dy > 9) {
			dx := abs(cX - x)
			if (dx < cW_half)
				NextWindow_Calc(dx, dy, id, min, minID)
		}
		if (x <= minX) {
			if (y >= maxY || x < minX - cW_half) {
					minX := x
					maxY := y
					oppID := id
			}
		}
	}
	NextWindow_Activate(minId, minDownID, oppID)
}

NextWindow_Down(title) {
	WinGet, cID, ID
	WinGetPos, cX, cY, cW
	cW_half := cW/2
	min := A_ScreenWidth
	minUp := min
	maxX := 0
	minY := min
	WinGet windows, List, %title%
	Loop, %windows%	{
		id := windows%A_Index%
		if (id == cID)
			continue
		WinGetPos, x, y, , , ahk_id %id%
		dy := y - cY
		dx := x - cX
		if (dy < 0) {
			dy := y
			if (dy < 0)
				dy := 0
			dx := x - cX
			if (dx < 0)
				NextWindow_Calc(dx, dy, id, minUp, minUpID)
		} else if (dy > 9) {
			dx := abs(cX - x)
			if (dx < cW_half)
				NextWindow_Calc(dx, dy, id, min, minID)
		}
		if (x >= maxX) {
			if (y <= minY || x > maxX + cW_half) {
				maxX := x
				minY := y
				oppID := id
			}
		}
	}
	NextWindow_Activate(minId, minUpID, oppID)
}

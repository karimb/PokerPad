/*  Tiles all of the windows matching the specified title.
 *
 *  License:
 *  	Tile v0.1 by Xander
 *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
 */

Tile(title, monitors, tiles) {
	local windows
	WinGet windows, List, %title%
	if !windows
		return
	local xSlots, ySlots, x, y, w, h, wh, ht, i, id, class
	local area, areaTop, areaBottom, areaLeft, areaRight, width, height, tables, offset := 0
	Loop, %monitors% {
		if !windows
			break
		if (windows > tiles) {
			tables := tiles
			windows -= tiles
		} else {
			tables := windows
			windows := 0
		}
		SysGet, area, MonitorWorkArea, %A_Index%
		width := areaRight - areaLeft
		height := areaBottom - areaTop
		if (tables < 7) {
			ySlots := 2
			xSlots := tables < 5 ? 2 : 3
		} else if (tables < 13) {
			ySlots := 3
			xSlots := tables < 10 ? 3 : 4
		} else if (tables < 21) {
			ySlots := 4
			xSlots := tables < 17 ? 4 : 5
		} else if (tables < 31) {
			ySlots := 5
			xSlots := tables < 26 ? 5 : 6
		} else {
			ySlots := 6
			xSlots := 6
		}
		w := width / xSlots
		h := height / ySlots
		Loop, %tables%	{
			x := Mod(A_Index, xSlots)
			if x
				x--
			else
				x := xSlots - 1
			y := Floor((A_Index-1)/xSlots)
			i := offset + A_Index
			id := windows%i%
			WinGetClass, class, ahk_id %id%
			wh := Tile_Width%class%
			if wh {
				wh += 2 * ResizeBorder
				if (w > wh)
					wh := w
				ht := Round((wh - 2 * ResizeBorder) / Tile_Ratio%class%) + 2 * ResizeBorder + Caption
			} else {
				wh := Tile_AbsoluteWidth%class%
				if wh {
					ht := Round(wh / Tile_Ratio%class%)
				} else {
					class := RegExReplace(class, "\d+")
					wh := Tile_Width%class%
					if wh {
						wh += 2 * ResizeBorder
						if (w > wh)
							wh := w
						ht := Round((wh - 2 * ResizeBorder) / Tile_Ratio%class%) + 2 * ResizeBorder + Caption
					} else {
						WinGetPos, , , wh, ht, ahk_id %id%
					}
				}
			}
			if x {
				if (wh > w) {
					if (x == xSlots - 1) {
						x := areaLeft + w * x - (wh-w)
					} else
						x := Round(areaLeft + w * x - (wh-w)/2)
				} else
					x := areaLeft + w * x
			} else
				x := areaLeft
			if y {
				if (ht > h) {
					if (y == ySlots - 1)
						y := areaTop + h * y - (ht-h)
					else
						y := Round(areaTop + h * y - (ht-h)/2)
				} else
					y := areaTop + h * y
			} else
				y := areaTop
			WinMove, ahk_id %id%, , x, y, wh, ht
			if Tile_Drag%class% {
				WinActivate, ahk_id %id%
				MouseClickDrag, Left, wh-3, ht-3, wh-2, ht-2 
			}
		}
		offset += tables
	}
}












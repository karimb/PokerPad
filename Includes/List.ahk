/*  Basic List Functions.
 *  
 *  License:
 *  	List v0.2 by Xander
 *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
 */
 
 
/*  Retreives a segment or subList of list from start index to end position
 *  index values: 0 corresponds to the first element, -1 corresponds to the last, etc..
 *  position values: 1 corresponds to the first element, 0 corresponds to the last, -1 corresponds to the second to last..
 *  Semantically the same as from start index (inclusive) to end index (exclusive)
 */
ListSegment(ByRef list, start, end = 0, del = ",") {
	if start {
		if (start < 0) {
			start := -start
			StringGetPos, s, list, %del%, R%start%
		} else
			StringGetPos, s, list, %del%, L%start%
		s += 2
	} else
		s = 1
	if end {
		if (end < 0) {
			end := -end
			StringGetPos, end, list, %del%, R%end%
		} else {
			end -= start
			StringGetPos, end, list, %del%, L%end%, s
		}
		if (end > s) {
			end -= s - 1
			StringMid, segment, list, s, end
			return segment
		}
	}
	StringMid, segment, list, s
	return segment
}


/*  Retrieves the element at the specified index.
 *  0 corresponds to the first element, -1 corresponds to the last element
 */
ListGet(ByRef list, index, del = ",", ByRef s = "", ByRef e = "") {
	if index {
		if (index < 0) {
			dir = R
			index := -index
		} else
			dir = L
		StringGetPos, s, list, %del%, %dir%%index%
		StringGetPos, e, list, %del%, L, s+1
		s += 2
	} else {
		s = 1
		StringGetPos, e, list, %del%
	}
	if (!e || e < 0)
		return SubStr(list, s)
	e -= s - 1
	return SubStr(list, s, e)
}

/*  Sets the specified index to the specified element.
 *  See ListGet for index rules.
 */
ListSet(ByRef list, index, element, del = ",") {
	ListRemove(list, index, del)
	ListAdd(list, element, index+1, del)
}

/*  Retreives the number of elements in the list or 0 if the list is empty.
 */
ListSize(ByRef list, del = "`,") {
	size = 0
	if list
		Loop, Parse, list, %del%
			size++
	return size
}

/*  Adds the specified element to the list at the specified position.
 *  Note that position is different from index!
 *  1 corresponds the first element, 0 corresponds to the last element, -1 corresponds to the element before the last..
 */
ListAdd(ByRef list, element, pos = 0, del = ",") {
	if pos {
		if (pos < 0) {
			pos = -pos
			dir = R
		} else if (pos = 1) {
			list := element . del . list
			return
		} else {
			dir = L
			pos--
		}
		StringGetPos, pos, list, %del%, %dir%%pos%
		StringLeft, left, list, pos
		StringRight, right, list, StrLen(list) - pos
		list := left . del . element . right
	} else if list
		list := list . del . element
	else
		list := element
}

/*  Removes the element at the specified index and returns that element
 */
ListRemove(ByRef list, index, del = ",") {
	e := ListGet(list, index, del, start, length)
	if (start > 1)
		StringLeft, left, list, start - 2
	if (length >= 0) {
		if left
			list := left . SubStr(list, start+length)
		else
			list := SubStr(list, start+length+1)
	} else
		list := left
	return e
}


/*  Returns true if the list contains the specified element, false otherwise.
 */
ListContains(ByRef list, element, del = ",") {
	if !list
		return false
	if (ListGet(list, 0) = element)
		return true
	if (ListGet(list, -1) = element)
		return true
	element := del . element . del
	return InStr(list, element)
}

/*  Returns true if the elements in list are the same as the elements in otherList and they
 *  are in the same order, false otherwise.
 */
ListEquals(ByRef list, ByRef otherList, del = ",", otherDel = ",") {
	if (del = otherDel)
		return list = otherList
	StringSplit, l, list, %del%
	StringSplit, o, otherList, %otherDel%
	if l0 != o0
		return false
	Loop, %l0%
		if l%A_Index% != o%A_Index%
			return false
	return true
}

/*  Returns the first index of the specified element in the list.
 */
ListIndexOf(ByRef list, element, del = ",") {
	Loop, Parse, list, %del%
		if (A_LoopField == element)
			return A_Index - 1
	return -1
}

/*  Returns the last index of the specified element in the list.
 */
ListLastIndexOf(ByRef list, element, del = ",") {
	StringSplit, array, list, %del%
	Loop, %array0% {
		pos := array0 - A_Index + 1
		if (array%pos% == element)
			return pos - 1
	}
}



ListIsEmpty(ByRef list) {
	return (list = "")
}

ListClear(ByRef list) {
	list := ""
}


ListRemoveAll(ByRef list, ByRef fromList, del = ",", fromDel = ",") {
	Loop, Parse, fromList, %fromDel%
	{
		index := ListIndexOf(list, A_LoopField, del)
		if (index >= 0)
			ListRemove(list, index, del)
	}
}


/*

ListContainsAll(ByRef list, ByRef fromList, del = ",") {

}
ListAddAll(ByRef list, ByRef fromList, index = -1, del = ",") {

}
ListRetainAll(ByRef list, ByRef fromList, del = ",") {

}
ListHashCode(ByRef list, del = "`,") {
	
}

*/	
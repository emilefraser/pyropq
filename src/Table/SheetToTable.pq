/*

Copyright 2020 - 2020 getkks, getkks@live.in

Unlicense

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http: //unlicense.org>

Project			: Power Query Library @ d:\Development\M\Power-Query

File			: SheetToTable.pq @ d:\Development\M\Power-Query\SheetToTable.pq
File Created	: Saturday, 9th May 2020 3:20:38 pm

Author			: getkks (getkks@live.in)

Change History:

*/
(Source as table,
	optional ColumnNumber as number,
	optional NoNullandBlank,
	optional SkipRows) =>

let
	BlankandNull = (Value,
		optional NullandBlank) =>

		let
			NullandBlank =
				if NullandBlank = null then
					true
				else
					NullandBlank,

			Result =
				if NullandBlank then
					Value <> null and Value <> ""
				else
					Value <> null
		in
			Result,

	Selected = if SkipRows = null then
			Table.SelectRows(Source, each
				BlankandNull(Record.Field(_, "Column" & (
					if ColumnNumber = null then
						"4"
					else
						Number.ToText(ColumnNumber)))
					,NoNullandBlank))
		else
			if SkipRows = 0 then
				if Comparer.Equals(Comparer.OrdinalIgnoreCase, Table.FirstValue(Source), "UTF8") then
					Table.Skip(Source, 1)
				else
					Source
			else
				Table.Skip(Source, SkipRows),

	Promoted = Table.PromoteHeaders(Selected, [PromoteAllScalars=true])
in
	Promoted

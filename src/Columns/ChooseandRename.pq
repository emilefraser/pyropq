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

Project			: Power-Query @ d:\Development\M\Power-Query

File			: ChooseandRename.pq @ d:\Development\M\Power-Query\ChooseandRename.pq
File Created	: Saturday, 9th May 2020 3:20:38 pm

Author			: getkks (getkks@live.in)

Change History:

*/
(
	Source as table,
	OldColumnNames as list,
	NewColumnNames as list) =>
let
	#"Reordered Columns" = F[ReorderColumnsSubset](Source, OldColumnNames, 0),
	ColumnCount=List.Count(OldColumnNames),
	#"Filtered Columns" = Table.SelectColumns(#"Reordered Columns", OldColumnNames),//List.FirstN(Table.ColumnNames(#"Reordered Columns"), ColumnCount)),
	#"Renamed Columns" = F[RenameColumnsByIndices](#"Filtered Columns", List.Numbers(0, ColumnCount),NewColumnNames)
in
	#"Renamed Columns"

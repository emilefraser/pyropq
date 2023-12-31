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

File			: LoadFile.old.pq @ d:\Development\M\Power-Query\LoadFile.old.pq
File Created	: Saturday, 9th May 2020 3:20:38 pm

Author			: getkks (getkks@live.in)

Change History:

*/
(
	optional FolderName as text,
	optional Options as record
	) as table =>
/*
Parameters
----------
FolderName -> Folder path for traversing.
Data Path -> Default folder path for traversing
File Name -> Full or Partial Name of the file to locate.
Recursive -> Default value is false. True will force the folder to be traversed recursively (all sub directories).
tblColumnMapping -> Mapping for Rename operations. Consists of three stages.
Extension -> List to filter into required file extensions.
Filter -> Filters the Folder Contents using a function which operates on table. This is post stage 1 rename and sorting. By default, recent file will be selected
Buffer -> Enables buffer before opening the file contents. By default, the file contents will not be buffered
*/
let
	Source = if FolderName = null then Record.FieldOrDefault(Options, "Data Path", false) else FolderName,

	OpenFolder =
		if Record.FieldOrDefault(Options, "Recursive", false) then
			Folder.Files(Source)
		else
			Folder.Contents(Source),

	#"Choose and Rename Columns In" = F[RenameColumnsByMapping](
		OpenFolder,
		Record.FieldOrDefault(
			Options,
			"Column Mapping",
			F[tblColumnMapping]),
		"In"),

	tblExtension = Table.FromColumns({
		Record.FieldOrDefault(Options, "Extension", F[lstExtension])},
		type table[Extension = text]),

	#"Filtered Known Extensions" = F[RemoveMatchingRows](
		#"Choose and Rename Columns In",
		tblExtension,
		{"Extension"}),
/*
	#"Filtered Known Extensions" = Table.FuzzyJoin(
		#"Choose and Rename Columns In", {"Extension"},
		tblExtension, {"Extension"},
		JoinKind.Inner, [
			NumberOfMatches = 1,
			Threshold = 1,
			ConcurrentRequests = 4]),
*/
	FileName = Record.FieldOrDefault(Options, "File Name"),

	FilterOpenFiles = Table.SelectRows(#"Filtered Known Extensions", each
			(if FileName <> null then
				Text.Contains([File Name], FileName, Comparer.OrdinalIgnoreCase)
			else
				true)
		and
			(not Text.StartsWith([File Name], "~$"))),

	#"Sort by Import Date" = Table.Sort(FilterOpenFiles,{{"Import Date", Order.Descending}}),

	#"Apply PreFilter" = if Record.FieldOrDefault(Options, "Filter") <> null then
			Record.FieldOrDefault(Options, "Filter")(#"Sort by Import Date")
		else
			Table.FirstN(#"Sort by Import Date",1),

	#"Expanded Attributes" = Table.ExpandRecordColumn(#"Apply PreFilter",
		"Attributes",
		{"Content Type", "Kind", "Size", "ReadOnly", "Hidden", "System", "Directory", "Archive", "Device", "Normal", "Temporary", "SparseFile", "ReparsePoint", "Compressed", "Offline", "NotContentIndexed", "Encrypted"}),

	#"Choose and Rename Columns In2" = F[RenameColumnsByMapping](
		#"Expanded Attributes",
		Record.FieldOrDefault(
			Options,
			"Column Mapping",
			F[tblColumnMapping]),
		"In2"),

	#"Added is Excel" = Table.AddColumn(#"Choose and Rename Columns In2", "Excel", each
		Text.StartsWith([File Type], "Excel"),
		type logical),

	#"Added is CSV" = Table.AddColumn(#"Added is Excel", "CSV", each
			Text.StartsWith([File Type], "CSV")
		or
			Text.StartsWith([File Type], "Text"),
		type logical),

	ToBuffer = Record.FieldOrDefault(Options, "Buffer", false),

	#"Load WorkBook" = Table.AddColumn(#"Added is CSV", "WorkBook", (rec) =>
			let
				BufferedFile = if ToBuffer then Binary.Buffer(rec[Content]) else rec[Content],
				LoadedFile =
					if rec[Excel] then
						Excel.Workbook(BufferedFile)
					else if rec[CSV] then
						try
							#table(
								type table
								[
									Name = text,
									Data = table,
									Item = text,
									Kind = text,
									Hidden = logical
								],
								{
									{null, Csv.Document(BufferedFile), null, "Text Document", false}
								})
						otherwise
							null
					else
						null
			in
				LoadedFile,
		type table),

	#"Expanded WorkBook" = Table.ExpandTableColumn(#"Load WorkBook",
		"WorkBook",
		{"Name", "Data", "Item", "Kind", "Hidden"},
		{"Name", "Data", "Item", "Kind", "Hidden Sheet"}),

	#"Choose and Rename Columns Out" = F[RenameColumnsByMapping](
		#"Expanded WorkBook",
		Record.FieldOrDefault(
			Options,
			"Column Mapping",
			F[tblColumnMapping]),
		"Out"),

	Result = if ToBuffer then Table.Buffer(#"Choose and Rename Columns Out") else #"Choose and Rename Columns Out"
in
	Result

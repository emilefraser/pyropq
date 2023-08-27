section Date;

shared Date.GetHolidays = (PRM_FirstYear as number) =>

let
  Source = {PRM_FirstYear .. Date.Year(DateTime.FixedLocalNow())}, 
  ConvertedtoTable = Table.FromList(
    Source, 
    Splitter.SplitByNothing(), 
    null, 
    null, 
    ExtraValues.Error
  ), 
  RenamedColumns = Table.RenameColumns(ConvertedtoTable, {{"Column1", "Year"}}), 
  InvokedCustomFunction = Table.AddColumn(
    RenamedColumns, 
    "fngetHolidays", 
    each try fnGetHolidays([Year]) otherwise null
  ), 
  ExpandedHolidaysText = Table.ExpandTableColumn(
    InvokedCustomFunction, 
    "fngetHolidays", 
    {"Attribute:id", "Attribute:title"}, 
    {"Attribute:id", "Attribute:title"}
  ), 
  ChangedType = Table.TransformColumnTypes(
    ExpandedHolidaysText, 
    {{"Year", Int64.Type}, {"Attribute:id", Int64.Type}, {"Attribute:title", type text}}
  )
in
  ChangedType;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetHolidays2 = (PRM_FirstYear as number, PRM_LastYear as number) =>

let
  Source = #date(PRM_FirstYear, 1, 1),
  ListDatesFromStart = List.Dates(
    Source,
    Number.From(#date(PRM_LastYear, 12, 31)) - Number.From(Source),
    #duration(1, 0, 0, 0)
  ),
  ConvertedToTable = Table.FromList(
    ListDatesFromStart,
    Splitter.SplitByNothing(),
    null,
    null,
    ExtraValues.Ignore
  ),
  ChangedType = Table.TransformColumnTypes(ConvertedToTable, {{"Column1", type date}}),
  InsertedDayOfWeek = Table.AddColumn(
    Table.RenameColumns(ChangedType, {{"Column1", "Дата"}}),
    "Номер дня недели",
    each Date.DayOfWeek([Дата]),
    Int64.Type
  ),
  InsertedDayOfMonth = Table.AddColumn(
    InsertedDayOfWeek,
    "День месяца",
    each Date.Day([Дата]),
    Int64.Type
  ),
  InsertedDaysInMonth = Table.AddColumn(
    InsertedDayOfMonth,
    "Дней в месяце",
    each Date.DaysInMonth([Дата]),
    Int64.Type
  ),
  InsertedDayName = Table.AddColumn(
    Table.AddColumn(InsertedDaysInMonth, "День года", each Date.DayOfYear([Дата]), Int64.Type),
    "Название дня недели",
    each Date.DayOfWeekName([Дата]),
    type text
  ),
  CapitalizedDayName = Table.TransformColumns(
    InsertedDayName,
    {{"Название дня недели", Text.Proper, type text}}
  ),
  DaysShortName = {"пн", "вт", "ср", "чт", "пт", "сб", "вс"},
  AddedDayNameShort = Table.AddColumn(
    CapitalizedDayName,
    "День недели",
    each DaysShortName{[Номер дня недели]},
    type text
  ),
  InsertedMonth = Table.AddColumn(
    AddedDayNameShort,
    "Номер месяца",
    each Date.Month([Дата]),
    Int64.Type
  ),
  InsertedMonthName = Table.AddColumn(
    InsertedMonth,
    "Месяц",
    each Date.MonthName([Дата]),
    type text
  ),
  InsertedYear = Table.AddColumn(InsertedMonthName, "Год", each Date.Year([Дата]), Int64.Type),
  InsertedQuarter = Table.AddColumn(
    InsertedYear,
    "Номер квартала",
    each Date.QuarterOfYear([Дата]),
    Int64.Type
  ),
  QuarterName = {"Не присвоено", "Первый", "Второй", "Третий", "Четвертый"},
  AddedQuarterName = Table.AddColumn(
    InsertedQuarter,
    "Квартал",
    each QuarterName{[Номер квартала]},
    type text
  ),
  MergedQueryHolidays = Table.NestedJoin(
    InsertedQuarter,
    {"Дата"},
    Holidays,
    {"Date"},
    "SRC_RollingHolidays",
    JoinKind.LeftOuter
  ),
  ExpandedHolidays = Table.ExpandTableColumn(
    MergedQueryHolidays,
    "SRC_RollingHolidays",
    {"Holiday"},
    {"Праздник"}
  ),
  InsertedDayTypeID = Table.AddColumn(
    ExpandedHolidays,
    "Рабочий день ID",
    each if [Номер дня недели] <= 4 and [Праздник] = null then 1 else 0,
    Int64.Type
  ),
  InsertedDayType = Table.AddColumn(
    InsertedDayTypeID,
    "Рабочий день",
    each if [Рабочий день ID] = 1 then "Рабочий" else "Выходной",
    type text
  ),
  AddedWeekNumber = Table.AddColumn(
    InsertedDayType,
    "Номер недели",
    each fnDateToISOWeek([Дата]),
    type text
  ),
  AddedYYMM = Table.AddColumn(
    AddedWeekNumber,
    "YYMM",
    each ([Год] - 2000) * 100 + [Номер месяца],
    Int64.Type
  ),
  AddedDateID = Table.AddColumn(
    AddedYYMM,
    "Дата ID",
    each (Date.Year([Дата]) - Date.Year(Source)) * 12 + Date.Month([Дата]),
    Int64.Type
  ),
  SortedRows = Table.Sort(AddedDateID, {{"Дата", Order.Descending}}),
  RemovedDuplicates = Table.Distinct(SortedRows, {"Дата"}),
  ReorderedColumns = Table.ReorderColumns(
    RemovedDuplicates,
    {
      "Дата",
      "Номер недели",
      "Рабочий день",
      "Название дня недели",
      "День недели",
      "Месяц",
      "Год",
      "Номер месяца",
      "Номер дня недели",
      "День месяца",
      "Дней в месяце",
      "День года",
      "Номер квартала",
      "Рабочий день ID",
      "YYMM",
      "Дата ID",
      "Праздник"
    }
  )
in
  ReorderedColumns;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Function gets list of non-working days (weekends and official holidays) 
// from official source "Open Data" managed by Analytical Center of Russian Federation
//
// Function has two arguments - From_Year, To_Year
// which allows to restrict period of time that you need for your data model.
//
// Usage:
//  List.Dates.HolidaysRU( 2015, 2016 )
// Response:
//   List of non-working days in Russian Federations for years 2015 and 2016

shared Date.GetHolidays3 = (from_year as number, to_year as number) =>
	let
		fGetLatestURL = 
			let
				Source = Table.FromColumns({Lines.FromBinary(Web.Contents("http://data.gov.ru/node/19107/code-passport"))}),
				#"Filtered Rows" = Table.SelectRows(Source, each Text.Contains([Column1], "Гиперссылка (URL) на набор")),
				#"Get Text with URL" = #"Filtered Rows"{0}[Column1],
				#"Position of HTTP" = Text.PositionOf(#"Get Text with URL", "http"),
				#"Position of CSV" = Text.PositionOf( #"Get Text with URL", ".csv" ),
				URL = Text.Range( #"Get Text with URL", #"Position of HTTP", #"Position of CSV" - #"Position of HTTP" + 4 )
			in
				URL,

		Source = Csv.Document(Web.Contents( fGetLatestURL ),[Delimiter=",", Columns=13, Encoding=65001, QuoteStyle=QuoteStyle.None]),		
		#"Promoted Headers" = Table.PromoteHeaders( Source ),
		#"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Год/Месяц", Int64.Type}}),
		#"Filtered Rows1" = Table.SelectRows(#"Changed Type", each [#"Год/Месяц"] >= from_year and [#"Год/Месяц"] <= to_year ),
		#"Renamed Columns1" = Table.RenameColumns(#"Filtered Rows1",{{"Январь", "1"}, {"Февраль", "2"}, {"Март", "3"}, {"Апрель", "4"}, {"Май", "5"}, {"Июнь", "6"}, {"Июль", "7"}, {"Август", "8"}, {"Сентябрь", "9"}, {"Октябрь", "10"}, {"Ноябрь", "11"}, {"Декабрь", "12"}, {"Год/Месяц", "Год"}}),
		#"Unpivoted Other Columns" = Table.UnpivotOtherColumns(#"Renamed Columns1", {"Год"}, "Attribute", "Value"),
		#"Split Column by Delimiter" = Table.SplitColumn(#"Unpivoted Other Columns","Value",Splitter.SplitTextByDelimiter(",", QuoteStyle.Csv) ),
		#"Unpivoted Other Columns1" = Table.UnpivotOtherColumns(#"Split Column by Delimiter", {"Год", "Attribute"}, "Attribute.1", "Value"),
		#"Removed Columns" = Table.RemoveColumns(#"Unpivoted Other Columns1",{"Attribute.1"}),
		#"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Attribute", "Месяц"}, {"Value", "День"}}),
		#"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each not Text.Contains([День], "*")),
		#"Changed Type1" = Table.TransformColumnTypes(#"Filtered Rows",{{"Месяц", Int64.Type}, {"День", Int64.Type}}),
		#"Added Custom" = Table.AddColumn(#"Changed Type1", "Date", each #date( [Год], [Месяц], [День] ), type date),
		#"Removed Other Columns1" = Table.SelectColumns(#"Added Custom",{"Date"})

	in
		#"Removed Other Columns1";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetEasterDates = let
    outputEster =
        (EasterYear as number) as date =>
            let
                FirstDig = Number.RoundDown(EasterYear / 100),
                Remain19 = Number.Mod(EasterYear, 19),
                Temp1 =
                    Number.Mod(
                        Number.RoundDown((FirstDig - 15) / 2)
                        + 202
                        - 11
                        * Remain19,
                        30
                    ),
                tA =
                    Temp1
                    + 21
                    + (
                        if
                            (Temp1 = 29)
                            or ((Temp1 = 28) and (Remain19 > 10))
                        then
                            -1
                        else
                            0
                    ),
                tB = Number.Mod(tA - 19, 7),
                tCpre = Number.Mod(40 - FirstDig, 4),
                tC =
                    tCpre
                    + (
                        if tCpre = 3 then
                            1
                        else
                            0
                    )
                    + (
                        if tCpre > 1 then
                            1
                        else
                            0
                    ),
                Temp2 = Number.Mod(EasterYear, 100),
                tD =
                    Number.Mod(
                        Temp2 + Number.RoundDown(Temp2 / 4),
                        7
                    ),
                tE = Number.Mod(20 - tB - tC - tD, 7) + 1,
                d = tA + tE,
                EasterDay =
                    if d > 31 then
                        d - 31
                    else
                        d,
                EasterMonth =
                    if d > 31 then
                        4
                    else
                        3,
                Result =
                    #date(
                        EasterYear,
                        EasterMonth,
                        EasterDay
                    )
            in
                Result,
    documentation = [
        Documentation.Name = " get-EasterDate.pq ",
        Documentation.Description = " Returning Date of Easter Sunday for inputed Year. ",
        Documentation.Source = "https://www.jaknapowerbi.cz . ",
        Documentation.Version = " 1.0 ",
        Documentation.Author = " Štěpán Rešl "
    ]
in
    Value.ReplaceType(
        outputEster,
        Value.ReplaceMetadata(
            Value.Type(outputEster),
            documentation
        )
    );

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
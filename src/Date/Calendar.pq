section Date;

// Basic calendar
shared Date.CreateCalendar =
   Document(
        "Date.Calendar",
        "Generate a calendar table for a given date span - can be text or proper dates. Current columns are Date, DayOfWeek, Month, MonthNum, WeekStartData, WeekStart, Year, YearMonth",
        {[ Description = "2016 calendar", Code ="PBI[Date.Calendar](""1/1/2016"", ""12/31/2016""", Result = "2016 calendar"]},
        (start as any, end as any) => 
            let
                StartDate = Date.From(start),
                EndDate = Date.From(end),
                Source = Date.DatesBetween(StartDate, EndDate),
                FromList = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                Date = Table.RenameColumns(FromList,{{"Column1", "Date"}}),
                DayOfWeek = Table.AddColumn(Date, "Day of Week", each Date.DayName([Date])),
                Month = Table.AddColumn(DayOfWeek, "Month", each Date.MonthName([Date])),
                MonthNum = Table.AddColumn(Month, "MonthNumber", each Date.Month([Date])),
                WeekStartDate = Table.AddColumn(MonthNum, "WeekStartDate", each Date.StartOfWeek([Date])),
                WeekStart = Table.AddColumn(WeekStartDate, "Week Start", each [Month] & " " & Text.From(Date.Day([WeekStartDate]))),
                Year = Table.AddColumn(WeekStart, "Year", each Date.Year([Date])),
                YearMonth = Table.AddColumn(Year, "YearMonth", each Number.From(Text.From([Year]) & (if [MonthNumber] < 10 then "0" else "") & Text.From([MonthNumber]))),
                Result = YearMonth
           in
                Result
    );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Document = (name as text, description as text, valueOrExample as any, optional valueIfExample as any) =>
    let
        value = if valueIfExample is null then valueOrExample else valueIfExample,
        examples = if valueIfExample is null then {} else valueOrExample
    in
        Value.ReplaceType(value, Value.Type(value) meta [
            Documentation.Name = name, 
            Documentation.Description = description,  
            // [Description = "", Code="", Result =""]
            Documentation.Examples = examples
        ]);

Switch = 
    Document(
        "Switch", 
        "Given a value, find it's paired item <br>"&
            "Switch(value as any, cases as list, results as list, optional default as any) <br>" &
            "Switch(value as any, pairs as list, optional default as any)",
        { 
            [ Description = "Using separate lists", Code = "Switch(1, {1, 2, 3}, {""A"", ""B"", ""C""})", Result = "A"],
            [ Description = "Using one paired list", Code = "Switch(1, {{1, ""A""}, {2, ""B""}, {3, ""C""}})", Result = "A"]
        },
        (value as any, casesOrPairs as list, optional resultsOrDefault as any, optional default as any) =>
            let
               hasPairs = List.First(casesOrPairs) is list,
               usingPairs = 
                   let
                       targetPosition = List.PositionOf(casesOrPairs, value, Occurrence.First, (case, theValue) => theValue = case{0})
                   in
                       if targetPosition = -1 then resultsOrDefault else casesOrPairs{targetPosition}{1},
               usingCases = 
                   let
                       cases = casesOrPairs,
                       results = resultsOrDefault
                   in
                       if List.IsEmpty(cases) or List.IsEmpty(results) then default else if value = List.First(cases) then List.First(results) else @Switch(value, List.Skip(cases, 1), List.Skip(results, 1), default)
            in
                if hasPairs then usingPairs else usingCases
    );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.CreateCalendar2 =
(StartDate as date, EndDate as date, optional Culture as nullable text) as table =>
let
    DayCount =
        Duration.TotalDays(EndDate - StartDate)
        + 1,
    Source =
        List.Dates(
            StartDate,
            DayCount,
            #duration(1, 0, 0, 0)
        ),
    // I added the optional metadata header for the third argument - type table [Date = date] removing some unnecessary M
    TableFromList =
        Table.FromList(
            Source,
            Splitter.SplitByNothing(),
            type table [Date = date]
        ),
    InsertYear =
        Table.AddColumn(
            TableFromList,
            "Year",
            each Date.Year([Date]),
            Int64.Type
        ),
    InsertQuarter =
        Table.AddColumn(
            InsertYear,
            "Quarter",
            each Date.QuarterOfYear([Date]),
            Int8.Type
        ),
    InsertMonth =
        Table.AddColumn(
            InsertQuarter,
            "MonthNr",
            each Date.Month([Date]),
            Int8.Type
        ),
    InsertYearMonth =
        Table.AddColumn(
            InsertMonth,
            "YearMonth",
            each Date.ToText([Date], "yyyyMM"),
            type text
        ),
    InsertDay =
        Table.AddColumn(
            InsertYearMonth,
            "Day",
            each Date.Day([Date]),
            Int8.Type
        ),
    InsertDayInt =
        Table.AddColumn(
            InsertDay,
            "DateInt",
            each [Year] * 10000 + [MonthNr] * 100 + [Day],
            Int64.Type
        ),
    InsertMonthName =
        Table.AddColumn(
            InsertDayInt,
            "Month",
            each Date.ToText([Date], "MMMM", Culture),
            type text
        ),
    InsertMonthNameShort =
        Table.AddColumn(
            InsertMonthName,
            "Month short",
            each Date.ToText([Date], "MMM", Culture),
            type text
        ),
    InsertDayWeek =
        Table.AddColumn(
            InsertMonthNameShort,
            "DayInWeek",
            each Date.DayOfWeek([Date], Day.Monday) + 1,
            Int8.Type
        ),
    InsertDayName =
        Table.AddColumn(
            InsertDayWeek,
            "DayOfWeekName",
            each Date.ToText([Date], "dddd", Culture),
            type text
        ),
    InsertYearWeek =
        Table.AddColumn(
            InsertDayName,
            "YearWeek",
            each
                Text.From([Year])
                & Text.PadStart(
                    Text.From(Date.WeekOfYear([Date])),
                    2,
                    "0"
                ),
            type text
        ),
    InsertWeekStarting =
        Table.AddColumn(
            InsertYearWeek,
            "WeekStart",
            each Date.StartOfWeek([Date]),
            type date
        ),
    InsertWeekEnding =
        Table.AddColumn(
            InsertWeekStarting,
            "WeekEnding",
            each Date.EndOfWeek([Date]),
            type date
        ),
    InsertWeekofYear =
        Table.AddColumn(
            InsertWeekEnding,
            "WeekofYear",
            each Date.WeekOfYear([Date]),
            Int8.Type
        )
in
    InsertWeekofYear;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.CreateCalendar2 =

(vFirstYear as number, optional vLastYear as nullable number, optional vCulture as nullable text) =>
let
	LastYear = if vLastYear = null or vLastYear = "" then Date.Year(DateTime.FixedLocalNow()) else vLastYear,
	Culture = if vCulture = null or vCulture = "" then "en-us" else vCulture,
	Source = List.Dates,
	#"Invoked FunctionSource" = Source(#date(vFirstYear, 1, 1), Duration.Days(#date(LastYear+1,1,1) - #date(vFirstYear,1,1)), #duration(1, 0, 0, 0)),
	#"Table from List" = Table.FromList(#"Invoked FunctionSource", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
	//#"Added Index" = Table.AddIndexColumn(#"Table from List", "Index", 1, 1),
	#"Renamed Columns" = Table.RenameColumns(#"Table from List",{{"Column1", "Date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date", type date}}),
	#"Added Year" = Table.AddColumn(#"Changed Type", "Year", each Date.Year([Date]), type number),
	#"Added Month Number" = Table.AddColumn(#"Added Year", "Month Number", each Date.Month([Date]), type number),
    #"Added Month Name" = Table.AddColumn(#"Added Month Number", "Month Name", each Date.ToText([Date],"MMMM", Culture), type text),
    #"Added Month Short Name" = Table.AddColumn(#"Added Month Name", "Month", each Date.ToText([Date],"MMM", Culture), type text),
	#"Added Day in month" = Table.AddColumn(#"Added Month Short Name", "Day of month", each Date.Day([Date]), type number),
    #"Added Day Name" = Table.AddColumn(#"Added Day in month", "Day Name", each Date.ToText([Date],"dddd", Culture), type text),
    #"Added Day Short Name" = Table.AddColumn(#"Added Day Name", "Day", each Date.ToText([Date],"ddd", Culture), type text),
    #"Added Day of Week" = Table.AddColumn(#"Added Day Short Name", "Day of week", each Date.DayOfWeek([Date]), type number),
	#"Added Quarter Number" = Table.AddColumn(#"Added Day of Week", "Quarter Number", each Date.QuarterOfYear([Date]), type number),
	#"Added Year Quarter" = Table.AddColumn(#"Added Quarter Number", "Year Quarter", each Number.ToText([Year]) & "Q" & Number.ToText([Quarter Number],"00"), type text),
	#"Added Year Month" = Table.AddColumn(#"Added Year Quarter", "Year Month", each Number.ToText([Year]) & Number.ToText([Month Number],"00"), type text),
	#"Reordered Columns" = Table.ReorderColumns(#"Added Year Month",{"Date", "Year", "Year Quarter", "Quarter Number", "Month Number", "Month Name", "Month", "Year Month", "Day of month", "Day Name", "Day", "Day of week"})
in
    #"Reordered Columns";

    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.CreateCalendar3 =
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
    Int64.Type
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

shared Date.CreateCalendar4 =

/**
* Creates a calendar table in power query.
* 
* @name Date_GenerateCalendarTable
* @categories date, 
* @license MIT (c) 2021 mogular
* @author https://github.com/mogulargmbh
* @version 20210121-3
* @example if you omit startDate/endDate the table starts 3 years before today until last day of current year
*/
(startDate as nullable date, endDate as nullable date) =>
   let
      
    // ISO 8601 Kalenderwoche bestimmen
    getISOCalendarWeekInfo = (myDate as nullable date) =>
      let
        internalFunc = () =>
          let
            weekdayNo = Date.DayOfWeek(myDate, Day.Monday) + 1,
            isoWeekYear = Date.Year(Date.AddDays(myDate, 4 - weekdayNo)),
            IsoWeekNrCol = (
              Duration.Days(
                Date.AddDays(myDate, 4 - weekdayNo)
                  - #date(isoWeekYear, 1, 7 - Date.DayOfWeek(#date(isoWeekYear, 1, 4), Day.Monday))
              )
                / 7
            )
              + 1,
            yearOfWeek = 
              if IsoWeekNrCol >= 52 and Date.Month(myDate) = 1 then
                Date.Year(myDate) - 1
              else if IsoWeekNrCol = 1 and Date.Month(myDate) = 12 then
                Date.Year(myDate) + 1
              else
                Date.Year(myDate),
            isoWeekInfo = [weekNoISO8601 = IsoWeekNrCol, yearOfWeekNoISO8601 = yearOfWeek]
          in
            isoWeekInfo,
        result = if myDate = null then null else internalFunc()
      in
        result,


    // KW Index erzeuen
    createWeekIndex = (t as table) =>
    let
        #"Andere entfernte Spalten" = Table.SelectColumns(t,{"YYYY/WW ISO8601"}),
        #"Entfernte Duplikate" = Table.Distinct(#"Andere entfernte Spalten"),
        #"Hinzugefügter Index" = Table.AddIndexColumn(#"Entfernte Duplikate", "KW Index", 0, 1, Int64.Type),
        join = Table.NestedJoin(t, {"YYYY/WW ISO8601"}, #"Hinzugefügter Index", {"YYYY/WW ISO8601"}, "joinColumns", JoinKind.LeftOuter),
        #"expanded" = Table.ExpandTableColumn(join, "joinColumns", {"KW Index"}, {"KW Index"})
    in
        #"expanded",

    currentYear = Date.Year(DateTime.Date(DateTime.FixedLocalNow())),
    sd = if startDate = null then #date(currentYear - 3, 1, 1) else startDate,
    ed = if endDate = null then #date(currentYear, 12, 31) else endDate,
    #"Anzahl Tage" = Duration.Days(ed - sd) + 1,
    Quelle = List.Dates(sd, #"Anzahl Tage", #duration(1, 0, 0, 0)),
    #"In Tabelle konvertiert" = Table.FromList(
      Quelle,
      Splitter.SplitByNothing(),
      null,
      null,
      ExtraValues.Error
    ),
    #"Umbenannte Spalten" = Table.RenameColumns(#"In Tabelle konvertiert", {{"Column1", "Datum"}}),
    #"Geänderter Typ" = Table.TransformColumnTypes(#"Umbenannte Spalten", {{"Datum", type date}}),
    #"Add Jahr" = Table.AddColumn(#"Geänderter Typ", "Jahr", each Date.Year([Datum])),
    #"Add Monat" = Table.AddColumn(#"Add Jahr", "Monat", each Date.Month([Datum])),
    #"Add Monatsname" = Table.AddColumn(
      #"Add Monat",
      "Monatsname",
      each Date.ToText([Datum], "MMMM")
    ),
    #"Add MonatsnameKurz" = Table.AddColumn(
      #"Add Monatsname",
      "Monatsname kurz",
      each Date.ToText([Datum], "MMM")
    ),
    #"Add YYYYMM" = Table.AddColumn(
      #"Add MonatsnameKurz",
      "YYYYMM",
      each Number.ToText([Jahr]) & Date.ToText([Datum], "MM")
    ),
    #"Add YYYY/MMMM" = Table.AddColumn(
      #"Add YYYYMM",
      "YYYY/MMMM",
      each Number.ToText([Jahr]) & "/" & [Monatsname]
    ),
    #"Add YYYY/MMM" = Table.AddColumn(
      #"Add YYYY/MMMM",
      "YYYY/MMM",
      each Number.ToText([Jahr]) & "/" & [Monatsname kurz]
    ),
    #"Add Quartal" = Table.AddColumn(#"Add YYYY/MMM", "Quartal", each Date.QuarterOfYear([Datum])),
    #"Add Quartalname" = Table.AddColumn(
      #"Add Quartal",
      "Quartalname",
      each "Q" & Number.ToText([Quartal])
    ),
    #"Add YYYYQ" = Table.AddColumn(
      #"Add Quartalname",
      "YYYYQ",
      each Number.ToText([Jahr]) & Number.ToText([Quartal])
    ),
    #"Add YYYY/Q" = Table.AddColumn(
      #"Add YYYYQ",
      "YYYY/Q",
      each Number.ToText([Jahr]) & "/" & [Quartalname]
    ),
    #"Add KW ISO 8601" = Table.AddColumn(
      #"Add YYYY/Q",
      "KW ISO8601",
      each getISOCalendarWeekInfo([Datum])[weekNoISO8601]
    ),
    #"Add Jahr KW ISO 8601" = Table.AddColumn(
      #"Add KW ISO 8601",
      "Jahr KW ISO8601",
      each getISOCalendarWeekInfo([Datum])[yearOfWeekNoISO8601]
    ),
    #"Add KWName" = Table.AddColumn(
      #"Add Jahr KW ISO 8601",
      "KW Name",
      each "KW" & Text.PadStart(Text.From([KW ISO8601]), 2, "0")
    ),
    #"Add YYYY/WW ISO 8601" = Table.AddColumn(
      #"Add KWName",
      "YYYY/WW ISO8601",
      each Text.From([Jahr KW ISO8601]) & "/" & Text.PadStart(Text.From([KW ISO8601]), 2, "0")
    ),

    #"AddKWIndex" = createWeekIndex(#"Add YYYY/WW ISO 8601"),

    #"Add Wochentag" = Table.AddColumn(
      #"AddKWIndex",
      "Wochentag",
      each Date.DayOfWeek([Datum], Day.Monday)
    ),
    #"Add WochentagName" = Table.AddColumn(
      #"Add Wochentag",
      "Wochentag Name",
      each Date.DayOfWeekName([Datum])
    ),
    #"Add WochentagNameKurz" = Table.AddColumn(
      #"Add WochentagName",
      "Wochentag Name kurz",
      each Date.ToText([Datum], "ddd")
    ),
    #"Add Day of Month" = Table.AddColumn(
      #"Add WochentagNameKurz",
      "Tag im Monat",
      each Date.Day([Datum])
    ),
    #"Add Day of Year" = Table.AddColumn(
      #"Add Day of Month",
      "Tag im Jahr",
      each Date.DayOfYear([Datum])
    ),
    #"Add Is Leap Year" = Table.AddColumn(
      #"Add Day of Year",
      "Ist Schaltjahr",
      each Date.IsLeapYear([Datum])
    ),
    #"Geänderter Typ1" = Table.TransformColumnTypes(
      #"Add Is Leap Year",
      {
        {"Jahr", Int64.Type},
        {"Monat", Int64.Type},
        {"Monatsname", type text},
        {"Monatsname kurz", type text},
        {"YYYYMM", Int64.Type},
        {"YYYY/MMMM", type text},
        {"YYYY/MMM", type text},
        {"Quartal", Int64.Type},
        {"Quartalname", type text},
        {"YYYYQ", Int64.Type},
        {"YYYY/Q", type text},
        {"KW ISO8601", Int64.Type},
        {"Jahr KW ISO8601", Int64.Type},
        {"Wochentag", Int64.Type},
        {"Wochentag Name", type text},
        {"Wochentag Name kurz", type text},
        {"Tag im Monat", Int64.Type},
        {"Tag im Jahr", Int64.Type},
        {"Ist Schaltjahr", type logical},
        {"KW Name", type text},
        {"YYYY/WW ISO8601", type text}
      }
    )
  in
    #"Geänderter Typ1";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetCalendarWith2MonthWith5Weeks =

let
    output = (startYear as number, endYear as number) =>
        let
            Source = List.Select(
                {startYear..endYear},
                (y) =>
                    List.Count(
                        List.Select(
                            {1..12},
                            (m) =>
                                let
                                    innerSelection = List.Dates(
                                        #date(y, m, 1),
                                        Date.Day(Date.EndOfMonth(#date(y, m, 1))),
                                        #duration(1, 0, 0, 0)
                                    ),
                                    fct = (vl as number) =>
                                        if List.Count(List.Select(innerSelection, each Date.DayOfWeek(_, 1) = vl)) >= 5 then
                                            true
                                        else
                                            false
                                in
                                    List.Count(
                                        List.Select(
                                            List.Generate(
                                                () => [vl = 6, res = fct(vl)],
                                                each (_[vl] ?? 1) > 3,
                                                each [vl = _[vl] - 1, res = fct(vl)],
                                                each [res]
                                            ),
                                            each _
                                        )
                                    ) = 3
                        )
                    ) > 1
            )
        in
            Source,
    documentation = [
        Documentation.Name = " get-ExtractYearsWithTwoMonthsWith5FIDAYSSATURDAYSSUDAYS.pq ",
        Documentation.Description = " Returns a list of years with two months with 5 Fridays, Saturdays and Sundays. ",
        Documentation.Source = "https://www.datameerkat.com . ",
        Documentation.Version = " 1.0 ",
        Documentation.Author = " Štěpán Rešl "
    ]
in
    Value.ReplaceType(output, Value.ReplaceMetadata(Value.Type(output), documentation));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


shared Date.CrteateExactDivergentValueByMonth = 

let
    output = (startDate as date, endDate as date, value as number) as number =>
        let
            startOfMonthStartDate = Date.StartOfMonth(startDate),
            startOfMonthEndDate = Date.StartOfMonth(endDate),
            endOfMonthStartDate = Date.EndOfMonth(startDate),
            endOfMonthEndDate = Date.EndOfMonth(endDate),
            singleResult = (singleStart as date, singleEnd as date) as number =>
                Value.Divide(value, Date.StartOfMonth(Date.EndOfMonth(singleStart) - singleStart)) * Number.From(
                    singleEnd - singleStart
                ),
            result =
                if endOfMonthStartDate = endOfMonthEndDate then
                    singleResult(startDate, endDate)
                else
                    let
                        innerListOfDates = List.Buffer(
                            List.Select(
                                List.Dates(
                                    Date.StartOfMonth(startDate), 
                                    Number.From(endDate - startDate), 
                                    #duration(1, 0, 0, 0)
                                ),
                                each Date.Day(_) = 1
                            )
                        ),
                        tranformator = List.Sum(
                            List.Transform(
                                innerListOfDates,
                                each
                                    if _ = startOfMonthStartDate then
                                        singleResult(startDate, Date.EndOfMonth(_))
                                    else if _ = startOfMonthEndDate then
                                        singleResult(endDate, Date.EndOfMonth(_))
                                    else
                                        value
                            )
                        )
                    in
                        tranformator
        in
            result,
            documentation = [
                Documentation.Name = " get-ExactDivergenceValueByMonth.pq ",
                Documentation.Description = " Calculate exact value for each month and part of month on the edges of interval. ",
                Documentation.Source = " https://www.jaknapowerbi.cz . ",
                Documentation.Version = " 1.0 ",
                Documentation.Author = " Štěpán Rešl "
            ]
in
     Value.ReplaceType(
        output,
        Value.ReplaceMetadata(
            Value.Type(output),
            documentation
        )
    );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

section Date;

shared Date.GetIsoWeekNumber =

/*
based on <https://en.wikipedia.org/wiki/ISO_week_date#Calculating_the_week_number_of_a_given_date>

M / Power Query doesn't have a native ISO8601 Week Number function, and DAX's
`weeknum(x, 21)` doesn't give the correct ISO Week-Year.

homepage: <https://gist.github.com/r-k-b/18d898e5eed786c9240e3804b167a5ca>
*/

let
    getISO8601Week = (someDate as date) =>
        let
            getDayOfWeek = (d as date) =>
                let
                    result = 1 + Date.DayOfWeek(d, Day.Monday)
                in
                    result,

            getNaiveWeek = (inDate as date) =>
                let
                    // monday = 1, sunday = 7
                    weekday = getDayOfWeek(inDate),

                    weekdayOfJan4th = getDayOfWeek(#date(Date.Year(inDate), 1, 4)),

                    ordinal = Date.DayOfYear(inDate),

                    naiveWeek = Number.RoundDown(
                        (ordinal - weekday + 10) / 7
                    )
                in
                    naiveWeek,

            thisYear = Date.Year(someDate),

            priorYear = thisYear - 1,

            nwn = getNaiveWeek(someDate),

            lastWeekOfPriorYear =
                getNaiveWeek(#date(priorYear, 12, 28)),

            // http://stackoverflow.com/a/34092382/2014893
            lastWeekOfThisYear =
                getNaiveWeek(#date(thisYear, 12, 28)),

            weekYear =
                if
                    nwn < 1
                then
                    priorYear
                else
                    if
                        nwn > lastWeekOfThisYear
                    then
                        thisYear + 1
                    else
                        thisYear,

            weekNumber =
                if
                    nwn < 1
                then
                    lastWeekOfPriorYear
                else
                    if
                        nwn > lastWeekOfThisYear
                    then
                        1
                    else
                        nwn,

            week_dateString =
                Text.PadStart(
                    Text.From(
                        Number.RoundDown(weekNumber)
                    ),
                    2,
                    "0"
                )
        in
            Text.From(weekYear) & "-W" & week_dateString & "-" & Text.From(getDayOfWeek(someDate))
in
    getISO8601Week;



    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetIsoWeekDate = 

/*
based on https://en.wikipedia.org/wiki/ISO_week_date#Calculating_a_date_given_the_year.2C_week_number_and_weekday

format input like: `2017-W02-7`

homepage: <https://gist.github.com/r-k-b/18d898e5eed786c9240e3804b167a5ca>
*/

let
    getDateFromISO8601Week = (inputIsoWeek as text) as date =>
        let
            getDayOfWeek = (d as date) =>
                let
                    result = 1 + Date.DayOfWeek(d, Day.Monday)
                in
                    result,

            isoWeekYear = Number.FromText(
                Text.Range(inputIsoWeek, 0, 4)
            ),

            isoWeek = Number.FromText(
                Text.Range(inputIsoWeek, 6, 2)
            ),

            isoWeekDay = Number.FromText(
                Text.Range(inputIsoWeek, 9, 1)
            ),

            // this doesn't seem right...
            weekdayOfJan4th = getDayOfWeek(#date(isoWeekYear, 1, 4)),

            // this doesn't seem right...
            daysInYear = Date.DayOfYear(#date(isoWeekYear, 12, 31)),

            // this doesn't seem right...
            daysInPriorYear = Date.DayOfYear(#date(isoWeekYear - 1, 12, 31)),

            correction = weekdayOfJan4th + 3,

            ordinal = isoWeek * 7 + isoWeekDay - correction,

            adjustedOrdinal =
                if
                    ordinal < 1
                then
                    ordinal + daysInPriorYear
                else
                    if
                        ordinal > daysInYear
                    then
                        ordinal - daysInYear
                    else
                        ordinal,

            calendarYear =
                if
                    ordinal < 1
                then
                    isoWeekYear - 1
                else
                    if
                        ordinal > daysInYear
                    then
                        isoWeekYear + 1
                    else
                        isoWeekYear,

            theDate = Date.AddDays(#date(calendarYear, 1, 1), adjustedOrdinal - 1)
        in
            theDate
in
    getDateFromISO8601Week;


    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


shared Date.GetCalendarWeekIso = 

/**
* Returns the weeknumber and year as defined in ISO 8601
* 
* @name Date_GetCalendarweekInfoISO8601
* @categories Date, 
* @license MIT (c) 2021 mogular
* @author https://github.com/mogulargmbh
* @version 20210910-1

*/ 

(myDate as nullable date) =>
         let
            internalFunc = () =>
               let
                  weekdayNo = Date.DayOfWeek(myDate, Day.Monday) + 1, 
                  isoWeekYear = Date.Year(Date.AddDays(myDate, 4 - weekdayNo)), 
                  IsoWeekNrCol = (
                     Duration.Days(
                        Date.AddDays(myDate, 4 - weekdayNo)
                           - #date(isoWeekYear, 1, 7 - Date.DayOfWeek(#date(isoWeekYear, 1, 4), Day.Monday))
                     )
                        / 7
                  )
                     + 1, 
                  yearOfWeek = 
                     if IsoWeekNrCol >= 52 and Date.Month(myDate) = 1 then
                        Date.Year(myDate) - 1
                     else if IsoWeekNrCol = 1 and Date.Month(myDate)=12 then
                        Date.Year(myDate) + 1
                     else
                        Date.Year(myDate), 
                  isoWeekInfo = [weekNoISO8601 = IsoWeekNrCol, yearOfWeekNoISO8601 = yearOfWeek]
               in
                  isoWeekInfo, 
            result = if myDate = null then null else internalFunc()
         in
            result;


    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



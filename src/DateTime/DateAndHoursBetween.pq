/**
 
* @name DateTime
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828
*
**/ 

section DateTime;

/**
* Returns Get Hours Between Start and End DateTime
* 
* @name GetHoursBetween
* @section DateTime, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828

*/ 
shared DateTime.GetHoursBetween = (
  sDT as datetime, 
  eDT as datetime, 
  sH as time,
  eH as time
 ) as number =>
            let
                startDateTime = sDT,
                startDate = Date.From(startDateTime),
                startTime = Time.From(startDateTime),
                startHour = Time.Hour(startTime),
                startWorkHour = sH,
                endDateTime = eDT,
                endDate = Date.From(endDateTime),
                endTime = Time.From(endDateTime),
                endHour = Time.Hour(endTime),
                endWorkHour = eH,
                maxHoursPerDay = endWorkHour - startWorkHour,
                realStartTime =
                    if startTime < startWorkHour then
                        startWorkHour
                    else if startTime > endWorkHour then
                        endWorkHour
                    else
                        startTime,
                realEndTime =
                    if endTime < startWorkHour then
                        startWorkHour
                    else if endTime > endWorkHour then
                        endWorkHour
                    else
                        endTime,
                diversionOfTime = realEndTime - realStartTime,
                output =
                    if startDate = endDate then
                        if diversionOfTime > maxHoursPerDay then
                            maxHoursPerDay
                        else
                            diversionOfTime
                    else
                        let
                            dt =
                                Table.Buffer(
                                    Table.SelectRows(
                                        #table(
                                            type table [
                                                Date = date,
                                                Weekend = logical
                                            ],
                                            List.Transform(
                                                List.Dates(
                                                    startDate,
                                                    (
                                                        Number.From(endDate)
                                                        - Number.From(startDate)
                                                    )
                                                    + 1,
                                                    #duration(1, 0, 0, 0)
                                                ),
                                                each
                                                    {
                                                        _,
                                                        if
                                                            Date.DayOfWeek(_, Day.Monday)
                                                            + 1
                                                            = 6
                                                            or Date.DayOfWeek(_, Day.Monday)
                                                            + 1
                                                            = 7
                                                        then
                                                            true
                                                        else
                                                            false
                                                    }
                                            )
                                        ),
                                        each [Weekend] = false
                                    )
                                ),
                            addon =
                                Table.AddColumn(
                                    dt,
                                    "Addon",
                                    each
                                        if [Date] = startDate then
                                            endWorkHour - realStartTime
                                        else if [Date] = endDate then
                                            endWorkHour - realEndTime
                                        else
                                            maxHoursPerDay,
                                    Int64.Type
                                ),
                            summarization = List.Sum(addon[Addon])
                        in
                            summarization
            in
                output,
    documentation = [
        Documentation.Name = " get-WorkingMDBetweenDatesAndByWorkingHours.pq ",
        Documentation.Description = "Returning Time between StartDateTime and EndDateTime by Working hours and working days (without weekends). ",
        Documentation.Source = "https://www.jaknapowerbi.cz . ",
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
 
/**
* Gets Hours List
* 
* @name GetHoursBetween
* @section DateTime, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828

*/ 
shared DateTime.GetDatesAndHourList = () =>

let
    startDateTime = #datetime(2018,1,1,0,0,0),
    endDateTime = #datetime(2019,12,31,23,0,0),
    totalHours = Duration.TotalHours(endDateTime - startDateTime) + 1,
    listHours = List.DateTimes(startDateTime, totalHours, #duration(0,1,0,0)),
    #"Converted to Table" = Table.FromList(listHours, Splitter.SplitByNothing(), type table [DateTime = datetime], null, ExtraValues.Error)
in
    #"Converted to Table"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
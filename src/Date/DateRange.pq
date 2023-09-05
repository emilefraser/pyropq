section Date;


// List_DatesBetween
// List_DatesBetween is an alternative for List.Dates function. It takes only two dates as arguments and creates a list of dates between given two dates. 
// Usage: List_DatesBetween(11/17/2016, 12/19/2016)

shared Date.GetDatesRange = (dateStart as date, dateFinish as date) =>

let

    countOfDays = Number.From(dateFinish - dateStart),
    output = if countOfDays > 0 
                then List.Dates(dateStart, countOfDays+1, #duration(1,0,0,0))
                else "Error! Your inputs are incorrect. Check the inputs." 
in
    output;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 

// List_DatesBetween
// List_DatesBetween is an alternative for List.Dates function. It takes only two dates as arguments and creates a list of dates between given two dates. 
// Usage: List_DatesBetween(11/17/2016, 12/19/2016)

shared Date.GetDatesFromStartForNumberOfDays = (dateStart as date, numberOfDays as number) =>

let
    output = if numberOfDays > 0 
                then List.Dates(dateStart, numberOfDays+1, #duration(1,0,0,0))
                else "Error! Your inputs are incorrect. Check the inputs." 
in
    output;



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
shared Date.GetDateRangeFull =  (From as date, To as date, optional Selection as text ) =>

let

// Create default-value "Day" if no selection for the 3rd parameter has been made
TimeInterval = if Selection = null then "Day" else Selection,

// Table with different values for each case
CaseFunctions = #table({"Case", "LastDateInTI", "TypeOfAddedTI", "NumberOfAddedTIs"},
		{   {"Day", Date.From, Date.AddDays, Number.From(To-From)+1},
		    {"Week", Date.EndOfWeek, Date.AddWeeks, Number.RoundUp((Number.From(To-From)+1)/7)},
		    {"Month", Date.EndOfMonth, Date.AddMonths, (Date.Year(To)*12+Date.Month(To))-(Date.Year(From)*12+Date.Month(From))+1},
		    {"Quarter", Date.EndOfQuarter, Date.AddQuarters, (Date.Year(To)*4+Date.QuarterOfYear(To))-(Date.Year(From)*4+Date.QuarterOfYear(From))+1},
		    {"Year", Date.EndOfYear, Date.AddYears,Date.Year(To)-Date.Year(From)+1} 
		} ),

// Filter table on selected case
		Case = CaseFunctions{[Case = TimeInterval]},
    
// Create list with dates: List with number of date intervals -> Add number of intervals to From-parameter -> shift dates at the end of each respective interval	
	DateFunction = List.Transform({0..Case[NumberOfAddedTIs]-1}, each Function.Invoke(Case[LastDateInTI], {Function.Invoke(Case[TypeOfAddedTI], {From, _})}))
in
    DateFunction;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetDateRangeAlternate = (From as date, To as date, optional Selection as text) =>
    let
      // Create default-value "Day" if no selection for the 3rd parameter has been made
      TimeInterval = if Selection = null then "Day" else Selection,
      // Table with different values for each case
      CaseFunctions = #table(
        {"Case", "LastDateInTI", "TypeOfAddedTI", "NumberOfAddedTIs"},
        {
          {"Day", Date.From, Date.AddDays, Number.From(To - From) + 1},
          {"Week", Date.EndOfWeek, Date.AddWeeks, Number.RoundUp((Number.From(To - From) + 1) / 7)},
          {
            "Month",
            Date.EndOfMonth,
            Date.AddMonths,
            (Date.Year(To) * 12 + Date.Month(To)) - (Date.Year(From) * 12 + Date.Month(From)) + 1
          },
          {
            "Quarter",
            Date.EndOfQuarter,
            Date.AddQuarters,
            (Date.Year(To) * 4 + Date.QuarterOfYear(To))
              - (Date.Year(From) * 4 + Date.QuarterOfYear(From))
              + 1
          },
          {"Year", Date.EndOfYear, Date.AddYears, Date.Year(To) - Date.Year(From) + 1}
        }
      ),
      // Filter table on selected case
      Case = CaseFunctions{[Case = TimeInterval]},
      // Create list with dates: List with number of date intervals -> Add number of intervals to From-parameter -> shift dates at the end of each respective interval	
      DateFunction = List.Transform(
        {0 .. Case[NumberOfAddedTIs] - 1},
        each Function.Invoke(Case[LastDateInTI], {Function.Invoke(Case[TypeOfAddedTI], {From, _})})
      )
    in
      DateFunction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


shared Date.DatesBetween = () => 
  Document(
    "Date.DatesBetween",
    "Returns a list of dates in a given span (inclusive). Start and end parameters can be any order",
    {[Description = "Date range", Code = "PBI[Date.DatesBetween](""1/1/2016"", ""1/3/2016"")", Result="{""1/1/2016"", ""1/2/2016"", ""1/3/2016""}" ]},
    (start as any, end as any) => 
      let 
        StartDate = Date.From(start), 
        EndDate = Date.From(end),
        adjustedStart = List.Min({StartDate, EndDate}),
        adjustedEnd = List.Max({StartDate, EndDate}),
        GetDates = (start as date, end as date, dates as list)=> if start > end then dates else @GetDates(Date.AddDays(start, 1), end, List.Combine({dates, {start}})),
        Dates = GetDates(adjustedStart, adjustedEnd, {})
      in Dates
);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


shared Date.GetLastNDays = (N as number) => 
	List.Dates(Date.AddDays(Date.From(DateTime.FixedLocalNow()), -N), N, #duration(1,0,0,0));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// last N years
shared Date.GetLastNYears = (N as number) =>
	let
		start = Date.StartOfYear(Date.AddYears(Date.From(DateTime.FixedLocalNow()), -N)),
		end = Date.EndOfYear(Date.AddYears(Date.From(DateTime.FixedLocalNow()), -1)),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// last N years and Current year
shared Date.GetLastNYearsAndCurrentYear = (N as number) =>
	let
		start = Date.StartOfYear(Date.AddYears(Date.From(DateTime.FixedLocalNow()), -N)),
		end = Date.EndOfYear(Date.From(DateTime.FixedLocalNow())),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

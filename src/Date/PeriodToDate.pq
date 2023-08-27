section Date;

shared Date.GetYearToDate = () =>
	let
		start = Date.StartOfYear(Date.From(DateTime.FixedLocalNow())),
		end = Date.From(DateTime.FixedLocalNow()),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetYearToDateLastYear = () =>
	let
		start = Date.StartOfYear(Date.AddYears(Date.From(DateTime.FixedLocalNow()), -1)),
		end = Date.AddYears(Date.From(DateTime.FixedLocalNow()), -1),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared GetR12MExcludingCurrentMonth = () =>
	let
		start = Date.StartOfMonth(Date.AddMonths(Date.From(DateTime.FixedLocalNow()), -11)),
		end = Date.From(DateTime.FixedLocalNow()),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared GetR12MExcludingCurrentMonthToDate() =>
	let
		start = Date.StartOfMonth(Date.AddMonths(Date.From(DateTime.FixedLocalNow()), -11)),
		end = Date.From(DateTime.FixedLocalNow()),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// N years to today
shared GetNYearsToDate = (N as number) =>
	let
		start = Date.StartOfYear(Date.AddYears(Date.From(DateTime.FixedLocalNow()), -N)),
		end = Date.From(DateTime.FixedLocalNow()),
		result = List.Dates(start, Duration.Days(end - start) + 1, #duration(1,0,0,0))
	in 
		result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
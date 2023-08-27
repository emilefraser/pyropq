section Date;

shared Date.GetEndOfLastMonth = 
() =>
	Date.EndOfMonth(Date.AddMonths(Date.From(DateTime.FixedLocalNow()), -1));

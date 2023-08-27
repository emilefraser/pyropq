   
section Date;


shared Date.MonthName = (date, optional culture as text) as nullable text => 
    DateTimeZone.ToText(DateTimeZone.From(date), "MMMM", culture);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.DayOfWeekName = (date, optional culture as text) as nullable text => 
    DateTimeZone.ToText(DateTimeZone.From(date), "dddd", culture);
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.DayName = Document(
    "Date.DayName",
    "Returns the English day of the week name for a date",
    {[ Description = "Get the day name", Code="Date.DayName(""9/9/2016"")", Result="Friday"]},
    (date as any) => Switch(Date.DayOfWeek(DateTime.From(date)), {0, 1, 2, 3, 4, 5, 6}, {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}, null)
);
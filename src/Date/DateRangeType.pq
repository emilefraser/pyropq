
section Date;

// ----------------------- New Function Type ----------------------- 

shared daterangetype = type function (
      From as (type date),
      To as (type date),
      optional Selection as (type text meta [
                            Documentation.FieldCaption = "Select Date Interval",
                            Documentation.FieldDescription = "Select Date Interval, if nothing selected, the default value will be ""Day""",
                            Documentation.AllowedValues = {"Day", "Week", "Month", "Quarter", "Year"}
                            ])
        )
    as table meta documentation_,

// Replace the extisting type of the function with the individually defined
Result =  Value.ReplaceType(function_, type_)
 
 in 

Result;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 
* @name DateTime
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828
*
**/ 

section DateTime;

/**
* Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>
* 
* @name GetHoursBetween
* @section DateTime, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828

*/ 
shared DateTime.GetHoursDifference = (
  Start as datetime, 
  End as datetime
) =>
let
  func =
    List.Transform(
      {0 .. Number.Round(Number.From(End - Start) * 24, 0)},
      each Start + #duration(0, _, 0, 0)
    ),
  documentation = [
    Documentation.Name = " DateTime.HoursBetween ",
    Documentation.Description
      = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
    Documentation.LongDescription
      = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
    Documentation.Category = " DateTime ",
    Documentation.Source = " . https://goo.gl/1mJHpP . ",
    Documentation.Version = " 1.0 ",
    Documentation.Author = " BillSzysz https://goo.gl/1mJHpP . ",
    Documentation.Examples = {
      [
        Description = "  ",
        Code
          = " DateTime.HoursBetween( #datetime(2018, 7, 8, 1, 0, 0), #datetime(2018, 7, 8, 4, 29, 0) ) ",
        Result
          = " {""08/07/2018 01:00:00"", ""08/07/2018 02:00:00"", ""08/07/2018 03:00:00"", ""08/07/2018 04:00:00""} "
      ]
    }
  ]
in
  Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 

 /**
* Returns hours between start and end datetimes
* 
* @name GetHoursBetween
* @section DateTime, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828

*/ 
shared DateTime.GetHoursBetween = (
  Start as datetime, 
  End as datetime
) =>

 let func =   
 (Start as datetime, End as datetime) =>
    List.Transform( {0..Number.Round(Number.From(End- Start)*24, 0)}, each Start + #duration(0, _, 0, 0)) ,
    documentation = [
    Documentation.Name =  " DateTime.HoursBetween ",
    Documentation.Description = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
    Documentation.LongDescription = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
    Documentation.Category = " DateTime ",
    Documentation.Source = " . https://goo.gl/1mJHpP . ",
    Documentation.Version = " 1.0 ",
    Documentation.Author = " BillSzysz https://goo.gl/1mJHpP . ",
    Documentation.Examples = {[Description =  "  ",
    Code = " DateTime.HoursBetween( #datetime(2018, 7, 8, 1, 0, 0), #datetime(2018, 7, 8, 4, 29, 0) ) ",
    Result = " {""08/07/2018 01:00:00"", ""08/07/2018 02:00:00"", ""08/07/2018 03:00:00"", ""08/07/2018 04:00:00""} "]}]
  
 in  
  Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation));
  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
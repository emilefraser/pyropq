/**
 
* @name DateTime
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20230828
*
**/ 

section DateTime;

/**a
*  Module Comments
* 
* @name GetDateTimeSqlFormat
* @section DateTime
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20210121-1

*/ 

shared DateTime.GetDateTimeSqlFormat = (
  DateTimeValue as any
) =>
  let 
    FormattedDate = DateTime.ToText(DateTime.From(DateTimeValue), "yyyy-MM-ddThh:mm:ss", "en-US")
  in 
    FormattedDate;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
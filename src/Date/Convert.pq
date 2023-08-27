section Date;

shared Date.ConvertFromText =

(
	Source as text,
	optional Positions as list/*list meta [
		Documentation.FieldCaption = "Positions",
		Documentation.FieldDescription = "List of positions for date splitter.",
		Documentation.SampleValues =  {"{0,2,4}"}]*/,
	optional Combiner as function/*list meta [
		Documentation.FieldCaption = "Combiner",
		Documentation.FieldDescription = "Function which can combine day month and year into date as required.",
		Documentation.SampleValues = (li) => #date(li{2},li{0},li{1})]*/) as date=>
let
	Splitter = Splitter.SplitTextByPositions(
		if Positions is null then
			{0,2,4}
		else
			Positions),

	Split = List.Transform(Splitter(Source), Int16.From)
in
	if Combiner is null then
			#date(Split{2},Split{0},Split{1})
		else
			Combiner(Split);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetDateFromEpoch =

/*
  convert date from SAP ByDesign into normal date
  SAP JSON response shows date as "/Date(1357084800000)/"
  can be used with 
  Table.TransformColumns(Expand,{{"Posting Date", EpochToDate}})
*/

let EpochToDateTime = (epoch as nullable text ) =>
let
    res = if epoch = null 
     then null
    else
    let
     remove_word = Text.Replace(epoch, "Date", ""),
     remove_slash = Text.Replace(remove_word, "/", ""),
     remove_left_par = Text.Replace(remove_slash, "(", ""),
     remove_right_par = Text.Replace(remove_left_par, ")", ""),
     calc = #datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, Number.FromText(Text.Start(remove_right_par,Text.Length(remove_right_par)-3)))
    in 
      calc
in
    res
in 
    EpochToDateTime;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

shared Date.GetDateFromEpoch2 =

/**
* Converts an epoch date to date. 
* 
* @name Date_FromEpoch
* @categories file, 
* @license MIT (c) 2021 mogular
* @author https://github.com/mogulargmbh
* @version 20210121-1

*/ 

(epochTS as number) as datetime=>
let
    res = #datetime(1970,1,1,0,0,0) + #duration(0,0,0,epochTS)
in
    res;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


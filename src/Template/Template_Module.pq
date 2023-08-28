/**
* Section Comments
* 
* @name {SectionName}
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20210121-1
*
**/ 

section SectionName;

/**a
*  Module Comments
* 
* @name {ModuleName}
* @section {SectionName, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20210121-1

*/ 

shared SectionName.ModuleName1 = (
    Source as text,
	optional Parameter as logical
) as date =>
let
	Source = Parameter
in
	Source;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
/**
*  Module Comments
* 
* @name {ModuleName}
* @section {SectionName, 
* @license MIT (c) 2023 emilefraser
* @author https://github.com/emilefraser
* @version 20210121-1

*/ 


shared SectionName.ModuleName2 = (
    Parameter as number,
	optional Parameter as date
) as table =>
let Output =
    let
        CodeOutput = Parameter
    in
        CodeOutput
in
    Output;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


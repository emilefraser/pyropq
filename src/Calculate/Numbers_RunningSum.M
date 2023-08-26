// Power Query / M function to add a Running Sum or Running Count. 
// Expects a numeric column named Input to exist in the table. To achieve a Running Count, set the value of Input to 1 on every row. 
// Call by using the UI to "Group By" with an "All Rows" operation. Then edit the generated "Grouped Rows" step to change: "each _" to: "each fnAddRunningSum ( _ )"
// Then expand the All Rows table-type column to get the added column named "Running Sum"

(MyTable as table) as table =>
let
    Source = Table.Buffer(MyTable),
    TableType = Value.Type(Table.AddColumn(Source, "Running Sum", each null, type number)),
    Cumulative = List.Skip(List.Accumulate(Source[Input],{0},(cumulative,Input) => cumulative & {List.Last(cumulative) + Input})),
    AddedRunningSum = Table.FromColumns(Table.ToColumns(Source)&{Cumulative},TableType)
in
    AddedRunningSum
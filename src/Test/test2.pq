let
    colNames = {"Clmn1", "Clmn2", "ClmnMultiplier"},
    Source = Table.FromColumns({{1, 1}, {2, 2}, {null, 0.5}}, colNames),
    
	
	transformRows = Table.TransformRows(Source, each Record.TransformFields(_, {
        {"Clmn1", (f)=>[Clmn1]*(if [ClmnMultiplier] is null then 1 else [ClmnMultiplier])}
    }))

		transformRows = Table.TransformRows(#"Expanded vc_Forex", each Record.TransformFields(_, {
        {"NetSalesValue", (f)=>[NetSalesValue]*(if [Company] = "ZAM" then 1 else [ClmnMultiplier])}
    }))
	
	
			transformRows = Table.TransformRows(#"Expanded vc_Forex", each Record.TransformFields(_, {
        {"NetSalesValue", (f)=>[NetSalesValue]*([ForexRate])}
    }))
	
	
	
	#"Expanded vc_Forex", 
	in
    Table.FromList(transformRows, Record.ToList, colNames)
	
	
	
	

let
    Source = MSSQL_CoreDW,
    dbo_v_Branches = Source{[Schema=pSchema,Item="v_Branches"]}[Data],
    #"Filtered Rows1" = Table.SelectRows(dbo_v_Branches, each ([Company] = "I" or [Company] = "MTN") and ([BranchName] <> "Gaborone" and [BranchName] <> "iStore Core On-Line" and [BranchName] <> "iStore Vodaworld" and [BranchName] <> "Other" and [BranchName] <> "Windhoek")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows1",{"Description"})
in
    #"Removed Columns"
	
	= Table.SelectRows(dbo_v_Branches, each ([Company] = "I" or [Company] = "MTN") and ([BranchName] <> "Gaborone" and [BranchName] <> "iStore Core On-Line" and [BranchName] <> "iStore Vodaworld" and [BranchName] <> "Other" and [BranchName] <> "Windhoek"))


#"Filtered Rows" = Table.SelectRows(Output, each ([Period] <> "Current Year To Date" and [Period] <> "Rolling Year"))


let
    // Var
    TodaysDate = Date.From(DateTimeZone.FixedUtcNow()),
    
    // Source
    Source = Sql.Database("172.22.1.22", "Core_DW"),
    v_AppleCalendar = Source{[Schema="dbo",Item="v_AppleCalendar_Alt"]}[Data],

	sss = DateTimeZone
	
	
    // Get Current Day and Corresponding Values (Q, Y, M)
    v_AppleCalendar_Current = Table.SingleRow(v_AppleCalendar, [Apple Date] = TodaysDate),

    // Year Dates
    CurrentAppleYear = Table.SelectColumns(Table.SelectRows(v_AppleCalendar, each [Apple Year] = v_AppleCalendar_Current{0} [Apple Year]),{"Apple Date"}),
    CurrentAppleYear_START = List.Min(CurrentAppleYear[Apple Date]),

    // Quarter Dates
    CurrentAppleQuarter = Table.SelectColumns(Table.SelectRows(v_AppleCalendar, each [Apple YearQuarter] = v_AppleCalendar_Current{0} [Apple YearQuarter]),{"Apple Date"}),
    CurrentAppleQuarter_START = List.Min(CurrentAppleQuarter[Apple Date]),

    // Month Dates
    CurrentAppleMonth = Table.SelectColumns(Table.SelectRows(v_AppleCalendar, each [Apple YearMonth] = v_AppleCalendar_Current{0} [Apple YearMonth]),{"Apple Date"}),
    CCurrentAppleMonth _START = List.Min(CurrentAppleMonth[Apple Date]),

    // Week Dates
    CurrentAppleWeek = Table.SelectColumns(Table.SelectRows(v_AppleCalendar, each [Apple YearWeek] = v_AppleCalendar_Current{0} [Apple YearWeek]),{"Apple Date"}),
    CurrentAppleWeek _START = List.Min(CurrentAppleWeek[Apple Date]),

    // Create Ranges for dates
    Ranges = {
                {"Today", 
                TodaysDate, 
                TodaysDate, 
                1},
                {"Apple WTD", 
                CurrentAppleYearWeek_START,
                TodaysDate, 
                2},
                {"Apple MTD", 
                CurrentAppleYearMonth_START,                
                TodaysDate, 
                3},
                {"Apple QTD", 
                CurrentAppleYearQuarter_START,                
                TodaysDate, 
                4},
                {"Apple QTD", 
                CurrentAppleYear_START,                
                TodaysDate, 
                5}  
             },
    GetTables = List.Transform(Ranges, each fCreateDateIntelligence(_{0}, _{1}, _{2}, _{3})),
    Output = Table.Combine(GetTables),
    #"Filtered Rows" = Table.SelectRows(Output, each ([Period] <> "Current Year To Date" and [Period] <> "Rolling Year"))
    
in
    #"Filtered Rows"
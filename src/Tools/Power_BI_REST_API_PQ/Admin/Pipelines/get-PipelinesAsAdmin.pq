let
    output =
        (generatedToken as text) =>
            let
                apiCall =
                    Json.Document(
                        Web.Contents(
                            "https://api.powerbi.com/v1.0/myorg",
                            [
                                RelativePath = "admin/pipelines",
                                Query = [
                                    #"$expand" = "stages,users"
                                ],
                                Headers = [
                                    #"Content-Type" = "application/json",
                                    Authorization = generatedToken
                                ]
                            ]
                        )
                    )
            in
                #table(
                    type table [
                        id = text,
                        displayName = text,
                        stages = table,
                        users = table
                    ],
                    List.Transform(
                        apiCall[value],
                        each
                            {
                                _[id]?,
                                _[displayName]?,
                                Table.AddColumn(
                                    Table.FromRecords(
                                        _[stages]?,
                                        type table [
                                            order,
                                            workspaceId,
                                            workspaceName
                                        ],
                                        MissingField.UseNull
                                    ),
                                    "Type",
                                    each
                                        if [order] = "0" then
                                            "Development"
                                        else if [order] = "1" then
                                            "Test"
                                        else
                                            "Production"
                                ),
                                Table.FromRecords(
                                    _[users]?,
                                    type table [
                                        accessRight,
                                        identifier,
                                        principalType
                                    ],
                                    MissingField.UseNull
                                )
                            }
                    )
                ),
    documentation = [
        Documentation.Name = " get-PipelinesAsAdmin.pq ",
        Documentation.Description = " Get pipelines as admin ",
        Documentation.Source = "https://www.jaknapowerbi.cz",
        Documentation.Version = " 1.0 ",
        Documentation.Author = " Štěpán Rešl "
    ]
in
    Value.ReplaceType(
        output,
        Value.ReplaceMetadata(
            Value.Type(output),
            documentation
        )
    )
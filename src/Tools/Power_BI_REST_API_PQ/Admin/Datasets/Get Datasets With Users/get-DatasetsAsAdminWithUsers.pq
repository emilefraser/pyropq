let
    output =
        (generatedToken as text) =>
            let
                apiCall =
                    Json.Document(
                        Web.Contents(
                            "https://api.powerbi.com/v1.0/myorg",
                            [
                                RelativePath = "admin/datasets",
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
                        name = text,
                        addRowsAPIEnabled = logical,
                        configuredBy = text,
                        isRefreshable = logical,
                        isEffectiveIdentityRequired = logical,
                        isEffectiveIdentityRolesRequired = logical,
                        isOnPremGatewayRequired = logical,
                        webUrl = text,
                        targetStorageMode = text,
                        createdDate = datetime,
                        createReportEmbedURL = text,
                        qnaEmbedURL = text,
                        upstreamDatasets = list,
                        users = table
                    ],
                    List.Transform(
                        apiCall[value],
                        each
                            {
                                _[id]?,
                                _[name]?,
                                _[addRowsAPIEnabled]?,
                                _[configuredBy]?,
                                _[isRefreshable]?,
                                _[isEffectiveIdentityRequired]?,
                                _[isEffectiveIdentityRolesRequired]?,
                                _[isOnPremGatewayRequired]?,
                                _[webUrl]?,
                                _[targetStorageMode]?,
                                DateTime.From(_[createdDate]?),
                                _[createReportEmbedURL]?,
                                _[qnaEmbedURL]?,
                                _[upstreamDatasets]?,
                                #"get-DatasetUsersAsAdmin"(generatedToken,_[id])
                            }
                    )
                ),
    documentation = [
        Documentation.Name = " get-Capacities.pq ",
        Documentation.Description = " Get all datasets with their users",
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
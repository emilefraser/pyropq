let
    output =
        (generatedToken as text) =>
            let
                callingPath = "https://api.powerbi.com/v1.0/myorg/admin/widelySharedArtifacts/publishedToWeb",
                callInitStructure = [
                    Headers = [
                        #"Content-Type" = "application/json",
                        Authorization = generatedToken
                    ]
                ],
                apiCalling = (uri as text, structure as record) => Json.Document(Web.Contents(uri, structure)),
                generator =
                    List.Buffer(
                        List.Generate(
                            () =>
                                [
                                    result =
                                        apiCalling(
                                            callingPath,
                                            callInitStructure
                                        ),
                                    uri = result[ArtifactAccessEntities]?
                                ],
                            each [uri] <> null,
                            each
                                [
                                    result = apiCalling(uri, callInitStructure),
                                    uri = _[result][continuationUri]?
                                ],
                            each [result][ArtifactAccessEntities]?
                        )
                    ),
                union = List.Union(generator)
            in
                #table(
                    type table [
                        artifactId = text,
                        displayName = text,
                        artifactType = text,
                        accessRight = text,
                        shareType = text,
                        sharer.emailAddress = text,
                        sharer.displayName = text,
                        sharer.identifier = text,
                        sharer.graphId = text,
                        sharer.principalType = text
                    ],
                    List.Transform(
                        List.RemoveNulls(union),
                        each
                            {
                                _[artifactId]?,
                                _[displayName]?,
                                _[artifactType]?,
                                _[accessRight]?,
                                _[shareType]?,
                                _[sharer]?[emailAddress]?,
                                _[sharer]?[displayName]?,
                                _[sharer]?[identifier]?,
                                _[sharer]?[graphId]?,
                                _[sharer]?[principalType]?
                            }
                    )
                ),
    documentation = [
        Documentation.Name = " get-PublishedToWeb.pq ",
        Documentation.Description = " Get all reports that are published to web ",
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
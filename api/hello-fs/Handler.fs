namespace AwsDotnetFsharp

open Amazon.Lambda.Core
open Amazon.Lambda.APIGatewayEvents

[<assembly:LambdaSerializer(typeof<Amazon.Lambda.Serialization.Json.JsonSerializer>)>]
do ()

module Handler =
    // open System
    // open System.IO
    // open System.Text

    let hello(request:APIGatewayProxyRequest): APIGatewayProxyResponse =
        APIGatewayProxyResponse(
            StatusCode = 200,
            Body = "hello",
            Headers = dict [ ("Content-Type", "text/plain") ]
        )

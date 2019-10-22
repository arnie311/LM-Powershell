#########################      API Function Script      #########################
#------------------------------------------------------------------------------------------------------------
# Prerequisites:
#
#Requires -Version 3
#------------------------------------------------------------------------------------------------------------
# Initialize Variables
<# account info #>
$accessId = ''
$accessKey = ''
$company = ''
#------------------------------------------------------------------------------------------------------------


# Functionize the reusable code that builds and executes the query
function Send-Request() {
    Param(
        [Parameter(position = 0, Mandatory = $true)]
        [string]$path,
        [Parameter(position = 1, Mandatory = $false)]
        [string]$httpVerb = 'GET',
        [Parameter(position = 2, Mandatory = $false)]
        [string]$queryParams,
        [Parameter(position = 3, Mandatory = $false)]
        [PSObject]$data

    )

    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    <# Construct URL #>
    $url = "https://$company.logicmonitor.com/santaba/rest$path$queryParams"

    <# Get current time in milliseconds #>
    $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

    <# Concatenate Request Details #>
    $requestVars = $httpVerb + $epoch + $data + $path

    <# Construct Signature #>
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
    $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
    $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
    $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

    <# Construct Headers #>
    $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $auth)
    $headers.Add("Content-Type", 'application/json')
    $headers.Add("X-version", '2')

    <# Make request & retry if failed due to rate limiting #>
    $Stoploop = $false
    do {
        try {
            <# Make Request #>
            $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
            $Stoploop = $true
        } catch {
            switch ($_) {
                { $_.Exception.Response.StatusCode.value__ -eq 429 } {
                    Write-Host "Request exceeded rate limit, retrying in 60 seconds..."
                    Start-Sleep -Seconds 60
                    $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
                }
                { $_.Exception.Response.StatusCode.value__ } {
                    Write-Host "Request failed, not as a result of rate limiting"
                    # Dig into the exception to get the Response details.
                    # Note that value__ is not a typo.
                    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
                    Write-Host "StatusDescription:" $_.Exception.Response.StatusCode
                    $_.ErrorDetails.Message -match '{"errorMessage":"([\d\S\s]+)","errorCode":(\d+),'
                    Write-Host "LM ErrorMessage" $matches[1]
                    Write-Host "LM ErrorCode" $matches[2]
                    $response = $null
                    $Stoploop = $true
                }
                default {
                    Write-Host "An Unknown Exception occurred:"
                    Write-Host $_ | Format-List -Force
                $response = $null
                $Stoploop = $true
            }
        }
    }
} While ($Stoploop -eq $false)
Return $response
}

<# response size and starting offset #>
$offset = 0
$size = 50

$httpVerb = 'GET'
$resourcePath = "/device/devices/"
$queryParams = "?fields=name,id&offset=$offset&size=$size"
$data = $null
$results = Send-Request $resourcePath $httpVerb $queryParams $data

<# Total number of items to be returned #>
$total = $results.total
$items = $results.items
$limit = [math]::ceiling($total / $size)
$chunk = 0

<# Paginate #>
if ($httpVerb -eq "GET") {
    if ($resourcePath -notmatch "alerts") {
        DO {
            $chunk ++
            $offset = $chunk * $size

            $chunkItems = Send-Request $resourcePath $httpVerb $queryParams $data
            $items += $chunkItems.items
        }While ($chunk -lt $limit)
    } else {
        DO {
            $chunk ++
            $offset = $chunk * $size

            $chunkDevices = Send-Request $resourcePath $httpVerb $queryParams $data
            $items += $chunkDevices.items
            $total = $chunkDevices.total
        }While ($total -lt 0)
    }
}

Write-Host $total

Write-Host $items

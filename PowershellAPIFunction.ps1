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
        [string]$accessId,
        [Parameter(position = 1, Mandatory = $true)]
        [string]$accessKey,
        [Parameter(position = 2, Mandatory = $true)]
        [string]$company,
        [Parameter(position = 3, Mandatory = $true)]
        [string]$path,
        [Parameter(position = 4, Mandatory = $false)]
        [string]$httpVerb = 'GET',
        [Parameter(position = 5, Mandatory = $false)]
        [string]$queryParams,
        [Parameter(position = 6, Mandatory = $false)]
        [PSObject]$data

    )

    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    <# Construct URL #>
    $url = "https://$company.logicmonitor.com/santaba/rest$resourcePath$queryParams"

    <# Get current time in milliseconds #>
    $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

    <# Concatenate Request Details #>
    $requestVars = $httpVerb + $epoch + $data + $resourcePath

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
        }
        catch {
            switch ($_) {
                {$_.Exception.Response.StatusCode.value__ -eq 429}
                {
                    Write-Host "Request exceeded rate limit, retrying in 60 seconds..."
                    Start-Sleep -Seconds 60
                }
                {$_.Exception.Response.StatusCode.value__}
                {
                    Write-Host "Request failed, not as a result of rate limiting"
                    # Dig into the exception to get the Response details.
                    # Note that value__ is not a typo.
                    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
                    Write-Host "StatusDescription:" $_.Exception.Response.StatusCode
                    $response = $null
                    $Stoploop = $true
                }
                default {
                    Write-Host "An Unknown Exception occured:"
                    Write-Host $_.Exception
                    $response = $null
                    $Stoploop = $true
                }
            }
        }
    } While ($Stoploop -eq $false)
    Return $response
}


$httpVerb = 'GET'
$resourcePath = '/device/devices/'
$queryParams = '?fields=name,id'
$data = $null
$results = Send-Request -accessId $accessId -accessKey $accessKey -company $company -httpVerb $httpVerb -path $resourcePath -queryParams $queryParams -data $data

$results

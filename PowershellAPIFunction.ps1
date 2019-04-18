#########################      API Function Script      #########################
#------------------------------------------------------------------------------------------------------------
# Prerequisites:
#
#Requires -Version 3
#------------------------------------------------------------------------------------------------------------
# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#------------------------------------------------------------------------------------------------------------
# Initialize Variables
<# account info #>
$accessId = ""
$accessKey = ''
$company = ""
#------------------------------------------------------------------------------------------------------------


# Functionize the reusable code that builds and executes the query
function Send-Request ($accessId, $accessKey, $company, $httpVerb, $resourcePath, $queryParams = $null, $data = $null) {
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

    <#
    How you should work around rate limiting with PowerShell depends on how you're making requests.
    The Invoke-RestMethod cmdlet throws out response headers unless an exception occurs, and as such we recommend
    attempting retries when an HTTP 429 is returned if using Invoke-RestMethod.
    For example, you could make the API request in a try catch loop, and retry if the resulting status is 429, like this:
    #>

    <# Make request & retry if failed due to rate limiting #>
    $Stoploop = $false
    do {
        try {
            <# Make Request #>
            $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
            $Stoploop = $true
        }
        catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 429) {
                Write-Host "Request exceeded rate limit, retrying in 60 seconds..."
                Start-Sleep -Seconds 60
            }
            else {
                Write-Host "Request failed, not as a result of rate limiting"
                # Dig into the exception to get the Response details.
                # Note that value__ is not a typo.
                Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
                Write-Host "StatusDescription:" $_.Exception.Response.StatusCode
                $response = $null
                $Stoploop = $true
            }
        }
    } While ($Stoploop -eq $false)
    Return $response
}


$httpVerb = 'GET'
$resourcePath = '/device/devices/'
$queryParams = '?fields=name,id'
$data = ''

$results = Send-Request -accessid $accessId -accessKey $accessKey -company $company -httpVerb $httpVerb -resourcePath $resourcePath -queryParams $queryParams -data $data
$results

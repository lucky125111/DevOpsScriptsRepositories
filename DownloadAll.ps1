#### Set variables
$url = "https://dev.azure.com/{organization}" # base url for organization
$username = "" # 
$password = "" # Personal Access Token
####

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
$headers = @{
    "Authorization" = ("Basic {0}" -f $base64AuthInfo)
    "Accept" = "application/json"
}

Add-Type -AssemblyName System.Web
$gitcred = ("{0}:{1}" -f  [System.Web.HttpUtility]::UrlEncode($username),$password)

$resp = Invoke-WebRequest -Headers $headers -Uri ("{0}/_apis/git/repositories?api-version=5.1" -f $url)
$json = convertFrom-JSON $resp.Content

$initpath = get-location
foreach ($entry in $json.value) { 
    $name = $entry.name 
    Write-Host $entry.remoteUrl

    $url = $entry.remoteUrl -replace "://.*@", ("://{0}@" -f $gitcred)
    
    if(!(Test-Path -Path $name)) {
        git clone $url
    } else {
        set-location $name
        git pull
        set-location $initpath
    }
}

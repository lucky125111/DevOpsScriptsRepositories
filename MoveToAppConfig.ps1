# Script read C# local.setting.json and transfer it to App Configuration Store
# {
#     "IsEncrypted": false,
#     "Values": {
#       "CircuitBreakerRetries": "5",
#       "BatchJobValidFileTimeMinutes": "180", 
#     }
#   }


$prefix = ""
$file = ""
$keyvault =  ""
$subscription = ""

$json = Get-Content $file -Raw 

Add-Type -AssemblyName System.Web.Extensions
$JS = New-Object System.Web.Script.Serialization.JavaScriptSerializer

$data = $JS.DeserializeObject($json)

az account set --subscription $subscription

$data.Values.GetEnumerator() | ForEach-Object {
        $appKey = $prefix,$_.Key -join ""
        $value = $_.Value

        Write-Host $appKey

        az appconfig kv set -n $keyvault --yes --key $appKey --value $value --tags staging

        az appconfig kv set -n $keyvault --yes --key $appKey --value $value --label staging
}

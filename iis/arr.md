# How to create a server farm with appcmd for blue green deployments
```
$baseUrl = <Base URL>
$farm = $baseUrl
$healthCheckUrl = "http://$baseUrl/api/ping"
$healthCheckResponse = 'pong'
$healthCheckInterval = '00:00:10' # 20 seconds

$servers = @(
    @{
        name=<blue-site>
        httpPort=<port1>
    },
    @{
        name=<green-site>
        httpPort=<port2>
    }
)

# Create the farm
appcmd.exe set config  -section:webFarms /+"[name='$farm']" /commit:apphost
# Add health check
appcmd.exe set config -section:webFarms /"[name='$farm']".applicationRequestRouting.healthCheck.url:$healthCheckUrl `
 /"[name='$farm']".applicationRequestRouting.healthCheck.responseMatch:"$healthCheckResponse" `
 /"[name='$farm']".applicationRequestRouting.healthCheck.interval:"$healthCheckInterval" /commit:apphost

ForEach($server in $servers) {
    # Add server to farm
    appcmd.exe set config  -section:webFarms /+"[name='$farm'].[address='$($server.name)']" /commit:apphost
    appcmd.exe set config  -section:webFarms /"[name='$farm'].[address='$($server.name)']".applicationRequestRouting.httpPort:$($server.httpPort) /commit:apphost
}
#display webfarm config
appcmd.exe list config  -section:webFarms


# URL Rewrite
$rule = "ARR_$farm`_lb"

appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='$rule',stopProcessing='True']" /commit:apphost
appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='$rule']".match.url:".*"  /commit:apphost
appcmd.exe set config -section:system.webServer/rewrite/globalrules /+"[name='$rule'].conditions.[input='{HTTP_HOST}',pattern='^$baseUrl$']" /commit:apphost
If ($Ssl) {
    appcmd.exe set config -section:system.webServer/rewrite/globalrules /+"[name='$rule'].conditions.[input='{HTTP_ON}',pattern='On']" /commit:apphost
} Else {
    appcmd.exe set config -section:system.webServer/rewrite/globalrules /+"[name='$rule'].conditions.[input='{SERVER_PORT}',pattern='^80$']" /commit:apphost
}
appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='$rule']".action.type:"Rewrite" `
 /"[name='$rule']".action.url:"http://$baseurl/{R:0}"  /commit:apphost
```

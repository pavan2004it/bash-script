$agw = Get-AzureRmApplicationGateway -Name dev.clinfeed.bioclinica.com -ResourceGroupName FLS-ClinFeed-DEV-RG
$match = New-AzureRmApplicationGatewayProbeHealth DEVeHealthResponseMatch -StatusCode "200-401"
$probeConfig = Get-AzureApplicationGatewayConfig -Name clinfeed-dev-multitenant-hprobe -ApplicationGateway $agw
Set-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $agw -Name $probeConfig.Name -Protocol $probeConfig.Protocol -HostName $probeConfig.Host -Path $probeConfig.Path -Interval $probeConfig.Interval -Timeout $probeConfig.Timeout -UnhealthyThreshold $probeConfig.UnhealthyThreshold -MinServers $probeConfig.MinServers -Match $match
Set-AzureRmApplicationGateway -ApplicationGateway $agw
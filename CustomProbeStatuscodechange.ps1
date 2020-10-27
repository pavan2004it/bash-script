$agw = Get-AzureRmApplicationGateway -Name clinfeed.bioclinica.com -ResourceGroupName ClinFeed-Prod-RG
$match = New-AzureRmApplicationGatewayProbeHealthResponseMatch -StatusCode "200-401"
$probeConfig = Get-AzureRmApplicationGatewayProbeConfig -Name clinfeed-prod-approvalservice-hprobe -ApplicationGateway $agw
Set-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $agw -Name $probeConfig.Name -Protocol $probeConfig.Protocol -HostName $probeConfig.Host -Path $probeConfig.Path -Interval $probeConfig.Interval -Timeout $probeConfig.Timeout -UnhealthyThreshold $probeConfig.UnhealthyThreshold -MinServers $probeConfig.MinServers -Match $match
Set-AzureRmApplicationGateway -ApplicationGateway $agw
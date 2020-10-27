$s = Get-ELB2LoadBalancer -Name ClinfeedVal -ProfileName pavan | select -Property DNSName
$n = Write-Output $s.DNSName
Add-DnsServerResourceRecordCName -Name "dev.clinfeed" -HostNameAlias $n -ZoneName "biodev.corp"
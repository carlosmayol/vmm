$ips = Get-SCIPAddress
Write-Host ""
Write-Host "IP, Name, LogicalNetwork, VirtualNetwork, VMNetwork," -ForegroundColor Magenta

foreach ($ip in $ips)
{
   if ($ip.ASsignedToType –eq “VirtualNetworkAdapter”)
  {
       $vnic = @(get-scvirtualNetworkAdapter -All | where {$_.ID -eq $ip.AssignedToID})
       
       Write-Host "$($ip.Name), $($vnic.Name), $($vnic.LogicalNetwork), $($vnic.VirtualNetwork), $($vnic.VMNetwork)"
    
   
 }
}

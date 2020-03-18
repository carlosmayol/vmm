$ips = Get-SCIPAddress
foreach ($ip in $ips) {
   if ($ip.ASsignedToType –eq “VirtualNetworkAdapter”)  {
       $vnic = @(get-scvirtualNetworkAdapter -All | where {$_.ID -eq $ip.AssignedToID})
       if ($vnic.Length –eq 0) {
            Write-Host “Revoking IP $($ip.Name)”
            Revoke-scipaddress $ip
       }
       else
       {
           Write-Host “IP $($ip.Name) is allocated to a vNIC that still exists"
        }
    }
}

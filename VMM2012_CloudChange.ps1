#Set all VM's for a specific host to a cloud1

$Cloud = Get-SCCloud -VMMServer scvmm2012.lab.local | where {$_.Name -eq "Cloud1"}
Get-SCVirtualMachine -VMMServer scvmm2012.lab.local | where {$_.VMHost.Name -eq "win2k8clu-lab2.lab.local"} | Set-SCVirtualMachine -Cloud $Cloud


#set Defaultowners to vmmservice

$UserRole = Get-SCUserRole -VMMServer scvmm2012.lab.local | where {$_.Name -eq "Cloud Master"}

Get-SCVirtualMachine -VMMServer scvmm2012.lab.local | where {$_.VMHost.Name -eq "win2k8clu-lab2.lab.local"} |Set-SCVirtualMachine -Owner "LAB\vmmsvc" -UserRole $userrole

#Grant Resource Access to role CloudMaster

Get-SCVirtualMachine -VMMServer scvmm2012.lab.local | where {$_.VMHost.Name -eq "win2k8clu-lab2.lab.local"} |Grant-SCResource -UserRoleName @("Cloud Master")


#List Owners and Resource access
Get-SCVirtualMachine | Sort-Object -Property Name | ft Name, owner, user* , cloud* , grant* -AutoSize

# revoke Resource Access
Get-SCVirtualMachine -VMMServer scvmm2012.lab.local | where {$_.GrantedtoList -match "Cloud 2 Users Dev"} | Revoke-SCResource -UserRoleName "Cloud 2 Users Dev"

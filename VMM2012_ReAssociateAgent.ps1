$cred=Get-Credential
Get-VMMManagedComputer -ComputerName "ws2012clu-lab4.lab.local" | Register-SCVMMManagedComputer  -Credential $cred
Get-VMMManagedComputer -ComputerName "ws2012clu-lab5.lab.local" | Register-SCVMMManagedComputer  -Credential $cred

#Obtain the iSCSI Target Server local administrator credentials as follows: 

$Cred = Get-Credential

#Note that any account that is part of the Local Administrators group is sufficient.

#Create a RunAs account in VMM as follows:

$Runas = New-SCRunAsAccount -Name "iSCSIRunas" -Credential $Cred

#Add the storage provider as follows:

Add-SCStorageProvider -Name "Microsoft iSCSI Target Provider" -RunAsAccount $Runas -ComputerName "<computername>" -AddSmisWmiProvider

#View storage properties

#Review the storage array attributes as follows:

$array = Get-SCStorageArray -Name “<computername>”

#View available storage pools as follows:

$array.StoragePools

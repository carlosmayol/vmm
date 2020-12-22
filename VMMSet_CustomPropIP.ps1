# Step 1
Get-SCIPAddress | Where-Object {$_.Description -eq "VM" } | ft Address, Description

# Step 2
If (-not (Get-Module VirtualMachineManager)) {
	Import-Module VirtualMachinManager }
 
$VMMServer = Read-Host "Please enter Virtual Machine Manager name (Default is localhost)"
If($VMMServer -eq ""){$VMMServer = "localhost"}
 
#Read all virtual machines
Get-SCVMMServer -ComputerName $VMMServer
$Property = Get-SCCustomProperty -Name "IP Address"
$VMResources = Get-SCVirtualMachine
 
ForEach ($VMs in $VMResources) {
	#Update custom properties with IP Address  
	$VM = Get-SCVirtualMachine -Name $VMs
	$VMIPAddress = Get-SCIPAddress | Where-Object {$_.Description -eq $VM }
	Set-SCCustomPropertyValue -InputObject $VM -CustomProperty $Property -Value $VMIPAddress 
	If($VMIPAddress -eq ""){
		Write-Host "Could not add IP Address for $VM to console" -f red
		}
		Write-Host "Successfully added IP Address for $VM to console" -f green

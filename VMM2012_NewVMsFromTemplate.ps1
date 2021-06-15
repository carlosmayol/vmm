<#
 Disclaimer:
 This sample script is not supported under any Microsoft standard support program or service. 
 The sample script is provided AS IS without warranty of any kind. Microsoft further disclaims 
 all implied warranties including, without limitation, any implied warranties of merchantability 
 or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
 the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
 or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
 damages whatsoever (including, without limitation, damages for loss of business profits, business 
 interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
 inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
 possibility of such damages
#>

#Requires -version 5
#Requires -module virtualmachinemanager

<#
.SYNOPSIS
  Creates a specified number of virtual machines from a template and then deploys them on a host.

.DESCRIPTION
  XXXXX

#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Supply the input values of the template.

Param(      
      [string]$VMHOSTGroupInput="HostGroups", #Parameter to define target location for VMM Host Group
      [string]$RequestorInput="UserRole", #Parameter to define who is the VMM User Role requesting the VM
      [string]$VMMSvc="scvmm.contoso.com", # Defining default VMM Service
      [string]$VMName="VMAuto_123456", # Defining input variable for VMNname and Windows Computername
      [string]$VMSize="Medium" # We use (small, medium or large in FE to match VMM Template name) 
      )
 
#Get current date/time
$Date = Get-Date -f yyyy_MM_dd_hhmmss

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
Set-StrictMode -version Latest

#Filling VMTemplate value based on VMSize from input parameter $VMSize
$VMTemplate = $null 

if ($VMSize -eq "Small") {$VMTemplate = "FULLWS2016STD-062017"}
if ($VMSize -eq "Medium") {$VMTemplate = "FULLWS2016STD-062017"}
if ($VMSize -eq "Large") {$VMTemplate = "FULLWS2016STD-062017"}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Connect to the VMM server.
Get-SCVMMServer -ComputerName $VMMSvc

$VMHostGroup = Get-SCVMHostGroup -vmmserver $VMMSvc -Name $VMHOSTGroupInput  

   # Get and sort the host ratings for all the hosts in the host group.
   $HostRatings = @(Get-SCVMHostRating -DiskSpaceGB 40 -Template $VMTemplate -VMHostGroup $VMHostGroup -VMName $VMName | where { $_.Rating -gt 0 } | Sort-Object -property Rating -descending)

   If($HostRatings.Count -eq "0") { throw "No hosts meet the requirements." }

   # If there is at least one host that will support the virtual machine,
   # create the virtual machine on the highest-rated host.
   If ($HostRatings.Count -ne 0)
    {

      $VMHost = $HostRatings[0].VMHost
      $VMPath = $HostRatings[0].VMHost.VMPaths[0]

      #Generate a new job group.
      $VMJobGroup = [System.Guid]::NewGuid()

      Get-SCVMTemplate -VMMServer $VMMSvc | where { $_.Name -eq $VMTemplate }

      # Create the virtual machine.
      $domainjoincredential = Get-SCRunAsAccount -VMMServer $VMMSvc -Name "VMM_DomainJoinUser"
      
      New-SCVirtualMachine -Template $VMTemplate -Name $VMName -Description "VM from Script" -VMHost $VMHost -Path $VMPath -JobGroup $VMJobGroup -RunAsynchronously -Owner "Contoso\vm.service" -ComputerName $VMName -OrgName "" -TimeZone 4 -Domain "contoso.com" -DomainJoinCredential $domainjoincredential -GuiRunOnceCommands "cmd.exe /c powershell c:\logs\lcmconfig.ps1" -StartVM -StartAction NeverAutoTurnOnVM -StopAction SaveVM
    }






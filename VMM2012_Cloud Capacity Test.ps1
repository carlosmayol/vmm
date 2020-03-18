param($VMMServer, $domain, $username, $pass)
$MBFactor = 1024 * 1024;
$GBFactor = $MBFactor * 1024;
function Cleanup
{
    param($vmm)
    $module = get-module -name "virtualmachinemanagercore"

    if ($module -ne $null)
    {
        remove-module -moduleInfo $module
    }
    if ($vmm -ne $null)
    {
        $vmm.Disconnect();
    }
}

function GetPercent
{
    param($numerator, $denominator)
    $percent = 0;
    if ($denominator -ne 0)
    {
        $percent = [Math]::Round(($numerator * 100) / $denominator);
    }

    $percent;
}

function GetHostMemory
{
    param ($hostObj)
    $memory = 0;

    if ($hostObj -ne $null)
    {
        $memory = $hostObj.TotalMemory / $MBFactor ;
    }

    $memory
}

function GetHostStorage
{
    param ($hostObj)
    $storage = 0;

    if ($hostObj -ne $null)
    {
        $storage  = $hostObj.TotalStorageCapacity / $GBFactor ;
    }

    $storage
}

function GetHostGroupsCapacity
{
    param($hostGroups)

    $memoryCapacityMBSum = 0;
    $storageCapacityGBSum = 0;
    if ($hostGroups -ne $null -and $hostGroups.Count -ne $null)
    {
        foreach ($hostGroup in $hostGroups)
        {
            if ($hostGroup -ne $null)
            {
                # workaround for AllChildHosts property not being populated
                # need to call Get-VMHost once per server connection        
                if ($hostGroup.AllChildHosts -eq $null -or $hostGroup.AllChildHosts.Count -eq 0)
                {
                    $tempHost = Get-SCVMHost -VMHostGroup $hostGroup
                    if ($hostGroup.AllChildHosts -eq $null  -or $hostGroup.AllChildHosts.Count -eq 0)    
                    {
                         $evt.WriteEntry("AllChildHosts property is null. Can't compute capacity, so monitor wouldn't work", $errevent, $GetVMMFailureCode);
                    }
                }

                if ($hostGroup.AllChildHosts -ne $null) 
                {
                    #AllChildHosts property contains a flatened list of all hosts under a host group
                    foreach ($h in $hostGroup.AllChildHosts)
                    {
                        $memoryCapacityMBSum += GetHostMemory $h;
                        $storageCapacityGBSum += GetHostStorage $h;
                    }
                }
            }
        }
    }
    $memoryCapacityMBSum;
    $storageCapacityGBSum;
}


function GetVMWareResourcePoolCapacity
{
    param($resourcePool)
    $memoryCapacityMBSum = 0;
    $storageCapacityGBSum = 0; # there are no storage limits in VMWare resource pool
    if ($resourcePool.IsMemoryReservationUnlimited -ne $true)
    {
        $memoryCapacityMBSum += $resourcePool.MemoryReservationLimitBytes  / $MBFactor;
    }

    $memoryCapacityMBSum;
    $storageCapacityGBSum;
}

function GetCloudFabricCapacity
{
    param($cloud)
    if ($cloud -ne $null)
    {
        if ($cloud.HostGroup -ne $null)
        {
            $fabcapacityHostGroups = GetHostGroupsCapacity -hostGroups $cloud.HostGroup
            $fabcapacityHostGroups
        }
        elseif ($cloud.VMWareResourcePool -ne $null)
        {
            $fabcapacityResourcePool = GetVMWareResourcePoolCapacity -resourcePool $cloud.VMWareResourcePool
            $fabcapacityResourcePool
        }
    }
}

function UpdateCloudPropertyBag
{
    param($cloud, $usage, $capacity, $propertyBag)

    if ($cloud -ne $null -and $usage -ne $null -and $capacity -ne $null)
    {
        $memoryUsageCapacityPercent = GetPercent $usage.MemoryUsageMB $capacity[0];
        $storageUsageCapacityPercent = GetPercent $usage.StorageUsageGB $capacity[1];

        $propertyBag.AddValue($cloud.Id.ToString() + "-Memory", $memoryUsageCapacityPercent);
        $propertyBag.AddValue($cloud.Id.ToString() + "-Storage", $storageUsageCapacityPercent);

    }
}


# FabricCloudCapacity.ps1 - calculates the ratio of cloud usage to its fabric capacity for all clouds in VMM

#error codes
$CredentialNullCode = 25934;
$GetVMMFailureCode = 25935;
$GetCloudFailureCode = 25936;
$ScriptSuccessCode = 25940;

$evt = New-Object System.Diagnostics.Eventlog("Application");
$evt.Source = "Microsoft.SystemCenter.VirtualMachineManager.2012.Monitor.FabricCloudMonitor";

$errevent = [System.Diagnostics.EventLogEntryType]::Error;
$infoevent = [System.Diagnostics.EventLogEntryType]::Information;

$oAPI = New-Object -comObject 'MOM.ScriptAPI'
$pBag = $oAPI.CreatePropertyBag()


$error.Clear();

$cred = $null;
if ($domain -AND $username -AND $pass)
{
  #Append domain to get domain\username
  $domainUser = $domain + "\" + $username;

  #Create Cred object
  $securePass = ConvertTo-SecureString -AsPlainText $pass -force
  $cred = New-Object System.Management.Automation.PSCredential $domainUser, $securePass;

}

# VMM Server is local
if ($cred -eq $null)
{
   $evt.WriteEntry("Credentials are null for user: " + $domainUser, $errevent, $CredentialNullCode);
   Cleanup
   return;
}

$error.Clear();
$module = get-module -name "virtualmachinemanagercore"
if ($module -eq $null)
{
    $modulePath = get-itemproperty -path "HKLM:\Software\Microsoft\Microsoft System Center Virtual Machine Manager Administrator Console\Setup";
    Import-Module ($modulePath.InstallPath + "bin\psModules\virtualmachinemanagercore\virtualmachinemanagercore.psd1");
}

$error.Clear();
$vmm = Get-SCVMMServer $VMMServer -Credential $cred;
if ($error.Count -ne 0)
{
    $evt.WriteEntry("Get VMM Server failed:" + $error[0].Exception.StackTrace, $errevent, $GetVMMFailureCode);
    Cleanup -vmm $vmm
    return;
}

$AllClouds = Get-SCCloud -VMMServer $vmm;

if ($error.Count -ne 0)
{
    $evt.WriteEntry($error, $errevent, $GetCloudFailureCode);
    Cleanup -vmm $vmm
    return;
}
else
{
    $error.Clear()
    if ($AllClouds -ne $null)
    {
        if ( $AllClouds.Count -ne $null)
        {
            foreach ($cloud in $AllClouds)
            {
                $usage =  Get-SCCloudUsage -Cloud $cloud
                $fabCapacity = GetCloudFabricCapacity -cloud $cloud

                UpdateCloudPropertyBag -cloud $cloud -usage $usage -capacity $fabCapacity -propertyBag $pBag
            }
            $pBag
        }
        else
        {
            $usage =  Get-SCCloudUsage -Cloud $cloud
            $fabCapacity = GetCloudFabricCapacity -cloud $AllClouds

            UpdateCloudPropertyBag -cloud $AllClouds -usage $usage -capacity $fabCapacity -propertyBag $pBag
            $pBag
        }
    }
}

Cleanup -vmm $vmm
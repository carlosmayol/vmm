
if($args.length -eq 0)
{
write-host "Use: .\reinicio_vhost listanodos.txt" -foreground red
}

else
{

$VMMServer=Get-VMMServer -ComputerName localhost
$nodes=get-content $args[0]
###Desalojamos los nodos

foreach($node in $nodes)
{write-host "Maintenance mode for " $node -foreground yellow
$disable=disable-vmhost $node -movewithincluster -runasynchronously 
}

write-host "All host are changing their state to Maintenance Mode" -foreground yellow

start-sleep 120

###miramos si todos los nodos están preparados al entrar en modo mantenimiento

do{

    $counter=0

	foreach($node in $nodes)
	{ $state=get-vmhost -computername $node 
		if($state.overallstate -eq 'MaintenanceMode')
		{
		$counter++
		}
		else
		{$counter=0
		}
	}
}
while($counter -ne $nodes.length)

write-host "All nodes are in maintenance mode and ready for reboot" -foreground green
}



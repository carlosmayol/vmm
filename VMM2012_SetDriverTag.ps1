$tags = @("DellTSeries")
Get-SCDriverPackage | ? {$_.Directory -match "Proxgb"} | Set-SCDriverPackage -Tag $tags
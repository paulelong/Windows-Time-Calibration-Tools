Get-WmiObject win32_process -Filter "name = 'MonitoringService.exe'"| foreach { 
    echo "------------------------------------------------------------------"
    echo $_.CommandLine
    $p = $_.CommandLine.Split()
    $regpath = "hklm:\system\currentcontrolset\services\" + $p[1] + "\servers" | sort
    get-item -path $regpath

}


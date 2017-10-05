<#
 
.SYNOPSIS
Generates a chart based on a data from collected with Collect-TimeData.ps1 or Colelct-W32TimeData.ps1.
 
.DESCRIPTION
Using data from w32tm or OsTimeSampler between a source and refecnce, the data is filtered and charted.  A summary is also printed for 3 percentiles.  The data can be collected manually using w32tm and OSTimeSampler, or the powershell scripts Collect-W32TimeData.ps1 and Collect-TimeData.ps1 can help automate the process.
 
.EXAMPLE
Scale-TimeChart.ps1 SUT#1 10

Using the SUT#1.gp file, increase the resolution x10.

.PARAMETER SystemName
Name of the System Undert Test (SUT) that you will compare to a reference.

.PARAMETER Scale
What factor to make more detiled, x10, x100, etc.

.LINK
https://github.com/Microsoft/Windows-Time-Calibration-Tools
 
#>

Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$SystemName,

   [Parameter(Mandatory=$True,Position=2)]
   [double]$Offset,

   [Parameter(Mandatory=$False,Position=3)]
   [string]$WorkingDir = ".\\"
)

#Create an extension string for the new chart.
$scaleext = "YAxis+" + $Offset

$DataFile = $WorkingDir + $SystemName + ".gp"
$NewFile = $SystemName + $scaleext
$NewFileOutput = $WorkingDir + $SystemName + $scaleext + ".gp"

echo ("Creating new file " + $NewFileOutput + " from " + $DataFile + " with scroll offset " + $scaleext + " for " + $SystemName)


if(test-path $NewFileOutput){ del $NewFileOutput }

type (dir $DataFile) | foreach {
    if($_.Contains("output"))
    {
        echo ("Replace: " + $SystemName + " with " + $NewFile + " = " + ($_.replace("$SystemName", "$NewFile")))
        echo ($_.replace("$SystemName", "$NewFile"))  | Out-file $NewFileOutput -Encoding ascii -Append
    }
    elseif($_.Contains("yrange")){
        $sa = $_.Split(" ")
        $range = $sa[2].substring(1, $sa[2].length - 2).Split(":")
        [double]$yrangeStart = $range[0]
        [double]$yrangeEnd = $range[1]
        

        echo ("set yrange [" + ($yrangeStart+$Offset) + ":" + ($yrangeEnd + $Offset) + "]") | Out-file $NewFileOutput -Encoding ascii -Append
    }
    else
    {
        echo $_ | Out-file $NewFileOutput -Encoding ascii -Append
    }
}

&gnuplot $NewFileOutput
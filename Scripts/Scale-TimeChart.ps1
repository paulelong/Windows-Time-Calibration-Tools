<#
 
.SYNOPSIS
Scales a chart by name, plus or minus.  Generates a new gnuplot gp file, and chart.
 
.DESCRIPTION
Scales a chart by name, plus or minus.  Generates a new gnuplot gp file, and chart.
 
.EXAMPLE
Scale-TimeChart.ps1 SUT#1 10

Using the SUT#1.gp file, increase the resolution x10.

.PARAMETER SystemName
Name of the System Undert Test (SUT) that you will compare to a reference.

.PARAMETER Scale
What factor to make more detiled, x10, x100, etc.

.PARAMETER WorkingDir
Where the .gp files reside.  If using the Create-MonitorTime charts, this is useful.

.LINK
https://github.com/Microsoft/Windows-Time-Calibration-Tools
 
#>

Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$SystemName,

   [Parameter(Mandatory=$True,Position=2)]
   [double]$Scale,

   [Parameter(Mandatory=$False,Position=3)]
   [string]$WorkingDir = ".\\"
)

#Create an extension string for the new chart.
if($Scale -lt 1)
{
    if($Scale -ge 0)
    {
        $scaleext = "x" + ($Scale * -1)
    }
    else
    {
       $scaleext = "x" + $Scale
       $Scale = -(1 / $Scale)
    }
}
else
{
    $scaleext = "x" + $Scale
}

$DataFile = $WorkingDir + $SystemName + ".gp"
$NewFile = $SystemName + $scaleext
$NewFileOutput = $WorkingDir + $SystemName + $scaleext + ".gp"

echo ("Creating new file " + $NewFileOutput + " from " + $DataFile + " with scale " + $scaleext + " for " + $SystemName)

if(test-path $NewFileOutput){ del $NewFileOutput }

type (dir $DataFile) | foreach {
    if($_.Contains("output"))
    {
        echo ("Replace: " + $SystemName + " with " + $NewFile + " = " + ($_.replace("$SystemName", "$NewFile")))
        echo ($_.replace("$SystemName", "$NewFile"))  | Out-file $NewFileOutput -Encoding ascii -Append
    }
    elseif($_.Contains("ytics nomirror")){
        $sa = $_.Split(" ")
        
        [double]$scalemajortics = $sa[5]
        [double]$scaleminortics = $sa[6]

        echo ("set ytics nomirror axis scale " + ($scalemajortics/$Scale) + " " + ($scaleminortics/$Scale)) | Out-file $NewFileOutput -Encoding ascii -Append
    }
    elseif($_.Contains("yrange")){
        $sa = $_.Split(" ")
        $range = $sa[2].substring(1, $sa[2].length - 2).Split(":")
        [double]$yrangeStart = $range[0]
        [double]$yrangeEnd = $range[1]
        

        echo ("set yrange [" + ($yrangeStart/$Scale) + ":" + ($yrangeEnd/$Scale) + "]") | Out-file $NewFileOutput -Encoding ascii -Append
    }
    else
    {
        echo $_ | Out-file $NewFileOutput -Encoding ascii -Append
    }
}

&gnuplot $NewFileOutput
$Folder = "c:\users\administrator\documents\crashdumps"

New-Item $Folder -Type Directory -ErrorAction SilentlyContinue
 
### Verify the folder the user specified was a valid folder. Else failback to c:\Crashdump
 
$validatepath=Test-Path $Folder
    if ($validatepath -eq $false)
    {
    New-Item C:\Crashdump -Type Directory
    Set-Variable -Name Folder -value C:\Crashdump -Scope Script
    }

$verifydumpkey = Test-Path "HKLM:\Software\Microsoft\windows\Windows Error Reporting\LocalDumps"
 
    if ($verifydumpkey -eq $false )
    {
    New-Item -Path "HKLM:\Software\Microsoft\windows\Windows Error Reporting\" -Name LocalDumps
    }

$Acl= get-acl $Folder
$machinename = hostname
$querydomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$domain = $querydomain.name
 
#Setting ACLs
 
$Acl.SetAccessRuleProtection($true, $false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Network","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Network Service","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Local Service","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("System","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
 
Set-Acl $folder $Acl
 
##### adding the values
 
$dumpkey = "HKLM:\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps"
 
New-ItemProperty $dumpkey -Name "DumpFolder" -Value $Folder -PropertyType "ExpandString" -Force
New-ItemProperty $dumpkey -Name "DumpCount" -Value 10 -PropertyType "Dword" -Force
New-ItemProperty $dumpkey -Name "DumpType" -Value 2 -PropertyType "Dword" -Force
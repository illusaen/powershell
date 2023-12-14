[CmdletBinding()]

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ( -not ($myWindowsPrincipal.IsInRole($adminRole))) {
   # We are not running "as Administrator" - so relaunch as administrator
   
  # Create a new process object that starts PowerShell
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
  # Specify the current script path and name as a parameter
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
  # Indicate that the process should be elevated
  $newProcess.Verb = "runas";
   
  # Start the new process
  [System.Diagnostics.Process]::Start($newProcess);
   
  # Exit from the current, unelevated, process
  exit
} else {
  clear-host
}

Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Enum\HID\*\*\Device` Parameters FlipFlopWheel -EA 0 | ForEach-Object { Set-ItemProperty $_.PSPath FlipFlopWheel 1 }
Write-Host "Mouse scroll flipped."
oh-my-posh init pwsh --config 'C:\Users\wendy\OneDrive\Documents\Posh\theme.omp.json' | Invoke-Expression

$PROJECT_DIRECTORY = "${HOME}\Documents\Projects"

Set-Alias -Name l -Value ls

function GoToUE {Set-Location -Path $HOME\Documents\UE5}
Set-Alias -Name ue -Value GoToUE

function GoToProjects {Set-Location -Path $PROJECT_DIRECTORY}
Set-Alias -Name proj -Value GoToProjects

function RemoveDirectory {Remove-Item -r}
Set-Alias -Name rmr -Value RemoveDirectory

function ConfigurationOpen {code $PROFILE}
function ConfigurationReload {. $PROFILE}
Set-Alias -Name config -Value ConfigurationOpen
Set-Alias -Name reload -Value ConfigurationReload

function TouchNewFile {New-Item $args}
Set-Alias -Name touch -Value TouchNewFile

$POWERSHELL_SCRIPT_DIRECTORY = Join-Path -Path $PROJECT_DIRECTORY -ChildPath "powershell"
foreach ($file in Get-ChildItem -Path $POWERSHELL_SCRIPT_DIRECTORY -Exclude "Microsoft*", "FlipScrollWheel*") {
  . $file
}

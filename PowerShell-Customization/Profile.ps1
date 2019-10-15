.$PSScriptRoot\Get-Weather.ps1
.$PSScriptRoot\Get-ChildItemColor.ps1
Get-Weather -City 'Bhubaneswar' -Country 'India'
$foregroundColor = 'white'
$psVersion= $host.Version.Major
$curUser= (Get-ChildItem Env:\USERNAME).Value
$curComp= (Get-ChildItem Env:\COMPUTERNAME).Value
Write-Host "Hi, $curUser!" -foregroundColor $foregroundColor
Write-Host "You're running PowerShell version: $psVersion" -foregroundColor Green
Write-Host "Your computer name is: $curComp" -foregroundColor Green
Write-Host "Happy scripting!" `n
#Turn off the stupid noise
Set-PSReadlineOption -BellStyle None
#More powerful auto-completion
Set-PSReadlineOption -EditMode Emacs
Set-Alias ls Get-ChildItemColor -option AllScope -Force
Set-Alias dir Get-ChildItemColor -option AllScope -Force
function Prompt {
  #$Host.UI.RawUI.WindowTitle = -join ($Host.UI.RawUI.WindowTitle, (Get-Date -UFormat '%y/%m/%d %R').Tostring())

  Write-Host '[' -NoNewline
  Write-Host (Get-Date -UFormat '%T') -ForegroundColor Green -NoNewline
  Write-Host ']:' -NoNewline
  Write-Host ((Get-Location)) -NoNewline
  return "> "
}
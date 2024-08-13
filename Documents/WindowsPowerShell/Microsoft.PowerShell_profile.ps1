
# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:\cd
Set-Alias -Name cd -Value z

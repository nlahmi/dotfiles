# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:\cd
Set-Alias -Name cd -Value z

# Starship
Invoke-Expression (&starship init powershell)

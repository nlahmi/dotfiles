# Standalone installer for kanata gui with the dotfiles keyboard config.
# No admin, no git, no chezmoi. In any PowerShell window:
#   irm https://raw.githubusercontent.com/nlahmi/dotfiles/main/install-kanata.ps1 | iex
# Safe to re-run: it upgrades the exe and refreshes the config in place.

# Wrapped in a script block so `irm | iex` doesn't leak variables or
# preference changes into the caller's shell.
& {
    $ErrorActionPreference = 'Stop'
    # The progress bar makes downloads crawl on Windows PowerShell 5.1
    $ProgressPreference = 'SilentlyContinue'
    # Windows PowerShell 5.1 can default to TLS 1.0, which GitHub rejects
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $version    = 'v1.11.0'
    $installDir = "$env:LOCALAPPDATA\Programs\Kanata"
    $configDir  = "$env:USERPROFILE\.config\kanata"
    $configUrl  = 'https://raw.githubusercontent.com/nlahmi/dotfiles/main/private_dot_config/kanata/kanata.kbd'
    $exe        = "$installDir\kanata_gui.exe"
    $config     = "$configDir\kanata.kbd"
    $kanataArgs = "-c `"$config`""

    # A running instance locks the exe, so stop it before overwriting
    $running = Get-Process kanata_gui -ErrorAction SilentlyContinue
    if ($running) {
        $running | Stop-Process -Force
        Wait-Process -InputObject $running
    }

    $tmp = Join-Path $env:TEMP "kanata-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Force -Path $tmp, $installDir, $configDir | Out-Null
    try {
        # -UseBasicParsing avoids the IE-engine error on fresh 5.1 installs
        Invoke-WebRequest -UseBasicParsing "https://github.com/jtroo/kanata/releases/download/$version/windows-binaries-x64.zip" -OutFile "$tmp\kanata.zip"
        Expand-Archive "$tmp\kanata.zip" -DestinationPath $tmp -Force
        # winIOv2 is the hook-based build, so it needs no driver and no admin
        Copy-Item "$tmp\kanata_windows_gui_winIOv2_x64.exe" $exe -Force
    } finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }

    Invoke-WebRequest -UseBasicParsing $configUrl -OutFile $config

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\kanata_gui.lnk")
    $shortcut.TargetPath = $exe
    $shortcut.Arguments = $kanataArgs
    $shortcut.WorkingDirectory = $configDir
    $shortcut.Save()

    Start-Process $exe -ArgumentList $kanataArgs -WorkingDirectory $configDir
    Write-Host "kanata gui $version installed to $installDir, running now and at every login."
}

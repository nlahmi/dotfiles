# Standalone installer for kanata gui with the dotfiles keyboard config.
# No admin, no git, no chezmoi. In any PowerShell window:
#   irm https://raw.githubusercontent.com/nlahmi/dotfiles/main/install-kanata.ps1 | iex
# Safe to re-run: it upgrades the exe and refreshes the config in place.

# Wrapped in a script block so `irm | iex` doesn't leak variables or
# preference changes into the caller's shell.
& {
    $ErrorActionPreference = 'Stop'
    # Windows PowerShell 5.1 can default to TLS 1.0, which GitHub rejects
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $version    = 'v1.11.0'
    # Ask Windows for the folders instead of reading $env:USERPROFILE etc.:
    # with a non-ASCII username those env vars can hold 8.3 short paths
    # (C:\Users\95FA~1) that PowerShell 5.1 cmdlets fail to resolve
    $home_      = [Environment]::GetFolderPath('UserProfile')
    $localData  = [Environment]::GetFolderPath('LocalApplicationData')
    $startup    = [Environment]::GetFolderPath('Startup')
    $installDir = "$localData\Programs\Kanata"
    $configDir  = "$home_\.config\kanata"
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

    # File work goes through .NET, not cmdlets: cmdlets resolve paths via
    # PowerShell's provider, which chokes on 8.3 short paths; .NET doesn't
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $web = New-Object Net.WebClient
    $tmp = "$localData\Temp\kanata-$([guid]::NewGuid())"
    foreach ($dir in $tmp, $installDir, $configDir) { [IO.Directory]::CreateDirectory($dir) | Out-Null }
    try {
        $web.DownloadFile("https://github.com/jtroo/kanata/releases/download/$version/windows-binaries-x64.zip", "$tmp\kanata.zip")
        [IO.Compression.ZipFile]::ExtractToDirectory("$tmp\kanata.zip", "$tmp\x")
        # winIOv2 is the hook-based build, so it needs no driver and no admin
        [IO.File]::Copy("$tmp\x\kanata_windows_gui_winIOv2_x64.exe", $exe, $true)
    } finally {
        # Cleanup must never throw: an error here would hide the real one
        try { [IO.Directory]::Delete($tmp, $true) } catch {}
    }

    $web.DownloadFile($configUrl, $config)

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$startup\kanata_gui.lnk")
    $shortcut.TargetPath = $exe
    $shortcut.Arguments = $kanataArgs
    $shortcut.WorkingDirectory = $configDir
    $shortcut.Save()

    $psi = New-Object Diagnostics.ProcessStartInfo $exe, $kanataArgs
    $psi.WorkingDirectory = $configDir
    [Diagnostics.Process]::Start($psi) | Out-Null
    Write-Host "kanata gui $version installed to $installDir, running now and at every login."
}

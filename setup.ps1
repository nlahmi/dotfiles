# Run as administrator

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install packages
choco install -y chezmoi wezterm git zoxide starship clink-maintained busybox

# Install busybox
busybox.exe --install
setx PATH "%PATH%;C:\ProgramData\chocolatey\lib\busybox\tools"

# Install uv
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Apply Chezmoi
chezmoi init --apply nlahmi

# Install Kanata
$kanataZip = "$env:TEMP\kanata.zip"
$kanataExtract = "$env:TEMP\kanata"
Invoke-WebRequest -Uri "https://github.com/jtroo/kanata/releases/download/v1.11.0/windows-binaries-x64.zip" -OutFile $kanataZip
Expand-Archive -Path $kanataZip -DestinationPath $kanataExtract -Force
New-Item -ItemType Directory -Force -Path "C:\Program Files\Kanata"
Copy-Item "$kanataExtract\kanata_windows_tty_winIOv2_x64.exe" "C:\Program Files\Kanata\kanata.exe"
Copy-Item "$kanataExtract\kanata_windows_gui_winIOv2_x64.exe" "C:\Program Files\Kanata\kanata_gui.exe"
Remove-Item $kanataZip, $kanataExtract -Recurse -Force

# Create startup shortcut for Kanata
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\kanata_gui.exe.lnk")
$shortcut.TargetPath = "C:\Program Files\Kanata\kanata_gui.exe"
$shortcut.Arguments = "-c `"$env:USERPROFILE\.config\kanata\kanata.kbd`""
$shortcut.Save()

# Install Neovim
git clone https://github.com/nlahmi/nvim-config $env:LOCALAPPDATA\nvim
cd $env:LOCALAPPDATA\nvim
.\setup.ps1

# Enable features for WSL
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /featurename:VirtualMachinePlatform /featurename:Microsoft-Windows-Subsystem-Linux /all

# Install Debian on wsl2
wsl --update
wsl --set-default-version 2
wsl --install -d Debian
#--no-launch

# Install everything inside WSL
wsl -d Debian --exec sh -c 'sudo apt update ; sudo apt install -y curl ; $(curl -fsLS https://raw.githubusercontent.com/nlahmi/dotfiles/main/setup.sh)'

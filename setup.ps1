# Run as administrator

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install packages
choco install -y chezmoi wezterm git zoxide starship clink-maintained

# Apply Chezmoi
chezmoi init --apply nlahmi

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

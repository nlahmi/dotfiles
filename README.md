# Installation
```
sudo apt update ; sudo apt install -y curl
sh -c "$(curl -fsLS https://raw.githubusercontent.com/nlahmi/dotfiles/main/setup.sh)"
```

## WSL
Recommended to install wslu, to handle opening links
```
sudo apt install gnupg2 apt-transport-https
wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg -o /usr/share/keyrings/wslu-archive-keyring.pgp --dearmor

echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.pgp] https://pkg.wslutiliti.es/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/wslu.list

sudo apt update
sudo apt install wslu
```

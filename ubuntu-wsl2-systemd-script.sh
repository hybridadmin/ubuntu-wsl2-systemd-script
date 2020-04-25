#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then 
  echo "Please run as root/sudo"
  exit
fi
apt-get update && sudo apt-get install -yqq daemonize dbus-user-session fontconfig
cp ./start-systemd-namespace /usr/sbin/.
cp ./enter-systemd-namespace /usr/sbin/.
chmod +x /usr/sbin/enter-systemd-namespace
echo 'Defaults        env_keep += WSLPATH' | EDITOR='tee -a' visudo
echo 'Defaults        env_keep += WSLENV' | EDITOR='tee -a' visudo
echo 'Defaults        env_keep += WSL_INTEROP' | EDITOR='tee -a' visudo
echo 'Defaults        env_keep += WSL_DISTRO_NAME' | EDITOR='tee -a' visudo
echo 'Defaults        env_keep += PRE_NAMESPACE_PATH' | EDITOR='tee -a' visudo
echo '%sudo ALL=(ALL) NOPASSWD: /usr/sbin/enter-systemd-namespace' | EDITOR='tee -a' visudo

DEFAULT_SHELL=$(cat /etc/passwd | grep $(whoami) | cut -d ':' -f7 | cut -d '/' -f3)
if [ "${DEFAULT_SHELL}" == "zsh" ]; then
        CONFIG_FILE="/etc/zsh/zshrc"
else
        CONFIG_FILE="/etc/bash.bashrc"
fi

sudo sed -i 2a"# Start or enter a PID namespace in WSL2\nsource /usr/sbin/start-systemd-namespace\n" ${CONFIG_FILE}

@echo off
cd /d "%~dp0"
msys2_shell.cmd -defterm -no-start -here -c "pacman -S --noconfirm binutils && bash sirev.sh setup"

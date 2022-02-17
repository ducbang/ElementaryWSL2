# First run script for ElementaryWSL

width=$(echo $COLUMNS)
height=$(echo $LINES)
if [ $width -lt 140 ]; then
  cmd.exe /C mode con:cols=140 lines=36
fi

ylw=$(tput setaf 3)
txtrst=$(tput sgr0)

figlet -w 140 Welcome to ElementaryWSL
echo -e "\033[33;7mDo not interrupt or close the terminal window till script finishes execution!!!\033[0m"
echo " "
echo -e "\033[32mDo you want to create a new user?\033[m"
select yn in "Yup" "Nope"; do
  case $yn in
    Yup)
      echo " "
      while read -p "Please enter the username you wish to create : " username; do
        if [ x$username = "x" ]; then
          echo -e "\033[31m Blank username entered. Try again\033[m"
          echo -en "\033[1A\033[1A\033[2K"
          username=""
        elif grep -q "$username" /etc/passwd; then
          echo -e "\033[31mUsername already exists. Try again\033[m"
          echo -en "\033[1A\033[1A\033[2K"
          username=""
        else
          useradd -m -g users -G sudo -s /bin/bash "$username"
          echo "%sudo ALL=(ALL) ALL" >/etc/sudoers.d/sudo
          echo -en "\033[1B\033[1A\033[2K"
          passwd $username
          sed -i "/\[user\]/a default = $username" /etc/wsl.conf >/dev/null
          echo " "
          secs=5
          while [ $secs -gt 0 ]; do
            printf ${ylw}"\r\033[KSystem needs to be restarted. Shutting down in %.d seconds."${txtrst} $((secs--))
            sleep 1
          done
          rm ~/.bash_profile
		  cmd.exe /C mode con:cols=$width lines=$height
          wsl.exe --terminate $WSL_DISTRO_NAME
        fi
      done
      ;;
    Nope)
      clear
	  cmd.exe /C mode con:cols=$width lines=$height
      rm ~/.bash_profile
      break
      ;;
  esac
done

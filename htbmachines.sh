#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c() {
  echo -e "\n${redColour}[!] Closing...${endColour}\n"
  tput cnorm
  exit 1
}

trap ctrl_c INT

# Variables
MACHINES_URL="https://htbmachines.github.io/bundle.js"

function helpPanel() {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Usage:${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Search by machine name${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Update machines${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Search by IP${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Get YouTube resolution video${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Show help${endColour}\n"
}


function updateMachines() {
  tput civis
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Updating machines...${endColour}"
    curl -s $MACHINES_URL > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines updated${endColour}"
  else
    echo -e "\n${yellowColour}[?]${endColour} ${grayColour}Checking for updates...${endColour}"
    curl -s $MACHINES_URL > bundle.tmp
    js-beautify bundle.tmp | sponge bundle.tmp
    MD5_CURRENT=$(md5sum bundle.js | awk '{print $1}')
    MD5_NEW=$(md5sum bundle.tmp | awk '{print $1}')

    if [ "$MD5_CURRENT" == "$MD5_NEW" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Everything up to date${endColour}"
      rm bundle.tmp
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}New updates found...${endColour}"
      rm bundle.js && mv bundle.tmp bundle.js 
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines updated${endColour}"
    fi
  fi
  tput cnorm
}

function searchMachine() {
  MACHINE_NAME="$1"

  CHECK_MACHINE_EXISTS="$(cat bundle.js | awk "/name: \"$MACHINE_NAME\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | sed 's/dificultad/dificulty/g' | tr -d ',' | sed 's/^ *//')"
  
  if [ ! $CHECK_MACHINE_EXISTS ]; then
    echo -e "\n${redColour}[!] Machine not found!${endColour}\n"
    exit 1
  fi

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Showing machine${endColour} ${blueColour}$MACHINE_NAME${endColour}\n"

  cat bundle.js | awk "/name: \"$MACHINE_NAME\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | sed 's/dificultad/dificulty/g' | tr -d ',' | sed 's/^ *//'
}

function searchByIP() {
  IP_ADDRESS=$1

  MACHINE_NAME=$( cat bundle.js | grep "ip: \"$IP_ADDRESS\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}The machine name is${endColour} ${blueColour}$MACHINE_NAME${endColour}\n"
}

function getYoutubeLink() {
  MACHINE_NAME="$1"

  YT_LINK="$(cat bundle.js | awk "/name: \"$MACHINE_NAME\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ ! $YT_LINK ]; then
    echo -e "\n${redColour}[!] Machine not found!${endColour}\n"
    exit 1
  fi

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}YouTube link:${endColour} ${blueColour}$YT_LINK${endColour}"

}

function getByDifficulty() {
  DIFFICULTY="$1"

  CHECK_DIFFICULTY="$(cat bundle.js | grep "dificultad: \"$DIFFICULTY\"" -B 5 | grep "name" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)"
  
  if [ ! $CHECK_DIFFICULTY ]; then
    echo -e "\n${redColour}[!] The provided difficulty does not exist${endColour}"
    exit 1
  fi
  
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines with difficulty${endColour} ${blueColour}$DIFFICULTY${endColour}:\n"

  cat bundle.js | grep "dificultad: \"$DIFFICULTY\"" -B 5 | grep "name" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
}

function getByOS() {
  OS="$1"

  CHECK_OS="$(cat bundle.js | grep "so: \"$OS\"" -B 5 | grep "name" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)"


  if [ ! $CHECK_OS ]; then
    echo -e "\n${redColour}[!] The provided OS does not exist${endColour}"
    exit 1
  fi

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines with OS${endColour} ${blueColour}$OS${endColour}:\n"

  cat bundle.js | grep "so: \"$OS\"" -B 5 | grep "name" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
}

# Indicators
declare -i PARAMETER_COUNTER=0

while getopts "m:ui:y:d:o:h" ARG; do
  case $ARG in
    m) MACHINE_NAME=$OPTARG; let PARAMETER_COUNTER+=1;;
    u) let PARAMETER_COUNTER+=2;;
    i) IP_ADDRESS=$OPTARG; let PARAMETER_COUNTER+=3;;
    y) MACHINE_NAME=$OPTARG; let PARAMETER_COUNTER+=4;;
    d) DIFFICULTY=$OPTARG; let PARAMETER_COUNTER+=5;;
    o) OS=$OPTARG; let PARAMETER_COUNTER+=6;;
    h) ;;
  esac
done

if [ $PARAMETER_COUNTER -eq 1 ]; then
  searchMachine $MACHINE_NAME
elif [ $PARAMETER_COUNTER -eq 2 ]; then
  updateMachines
elif [ $PARAMETER_COUNTER -eq 3 ]; then
  searchByIP $IP_ADDRESS
elif [ $PARAMETER_COUNTER -eq 4 ]; then
  getYoutubeLink $MACHINE_NAME
elif [ $PARAMETER_COUNTER -eq 5 ]; then
  getByDifficulty $DIFFICULTY
elif [ $PARAMETER_COUNTER -eq 6 ]; then
  getByOS $OS
else
  helpPanel
fi

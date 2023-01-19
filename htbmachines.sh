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

function ctrl_c(){
	echo -e "\n\n${redColour} [!] Saliendo...${endColour} \n"
	tput cnorm
	exit 1
}

#  Ctrl + C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"


#  Funciones
function helpPanel(){
	echo -e "\n ${yellowColour}[+]${endColour}${grayColour} Uso del script:   \n            ${endColour} "
	echo -e "\t ${purpleColour}m)${endColour}${greenColour} Buscar por un nombre de máquina${endColour}  "
	echo -e "\t ${purpleColour}i)${endColour}${greenColour} Buscar por dirección IP${endColour}  "
	echo -e "\t ${purpleColour}h)${endColour}${greenColour} Mostrar este panel de ayuda${endColour}"
	echo -e "\t ${purpleColour}u)${endColour}${greenColour} Descargar o actualizar archivos necesarios${endColour} "
	echo -e "\t ${purpleColour}d)${endColour}${greenColour} Buscar por la dificultad de la máquina (Fácil, Media, Difícil, Insane)${endColour}"
	echo -e "\t ${purpleColour}o)${endColour}${greenColour} Buscar por sistema operativo (Linux, Windows...)${endColour}"
	echo -e "\t ${purpleColour}s)${endColour}${greenColour} Buscar por skill (SQL, LFI, Wordpress, Tomcat, SUID, FTP, SMB, rbash...)${endColour}"
	echo -e "\t ${purpleColour}y)${endColour}${greenColour} Obtener enlace a youtube de la resolución de la máquina${endColour}\n"
}

function updateFiles(){

	echo -e "\n ${purpleColour}[+]${endColour} ${turquoiseColour}Comprobando archivos...${endColour}"

	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n ${purpleColour}[*]${endColour} ${yellowColour}Descargando archivos necesarios...${endColour}"
		curl -s $main_url > bundle.js
		js_beautify bundle.js | sponge bundle.js
		echo -e "\n ${purpleColour}[+]${endColour} ${yellowColour}Archivos descargados correctamente${endColour}"
		tput cnorm
	else
		tput civis
		echo -e "\n ${purpleColour}[+]${endColour} ${turquoiseColour}Comprobando si hay actualizaciones...${endColour}"
		curl -s $main_url > bundle_temp.js
		js_beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value="$(md5sum bundle_temp.js | awk '{print $1}')"
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')

		if [ "$md5_temp_value" == "$md5_original_value" ]; then

			echo -e "\n ${purpleColour}[+]${endColour} ${turquoiseColour}No hay actualizaciones, esta todo al día :)${endColour}"
			rm bundle_temp.js

		else
			echo -e "\n ${purpleColour}[+]${endColour} ${turquoiseColour}Hay actualizaciones${endColour}\n"
			echo -e " ${purpleColour}[+]${endColour} ${turquoiseColour}Realizando actualizaciones${endColour}\c"
			rm bundle.js
			mv bundle_temp.js bundle.js
			sleep 1
			echo -e "${yellowColour}.\c"; sleep 1; echo -e ".\c"; sleep 1; echo -e ".\c${endColour}"	echo -e "${yellowColour}.\c"; sleep 1; echo -e ".\c"; sleep 1; echo -e ".\c${endColour}"	echo -e "${yellowColour}.\c"; sleep 1; echo -e ".\c"; sleep 1; echo -e ".${endColour}"
			echo -e "\n ${purpleColour}[+]${endColour} ${greenColour}Se ha actualizado todo correctamente${endColour}"
		fi

		tput cnorm
	fi

}


function searchMachine(){
	machineName="$1"

	machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

	if [ "$machineName_checker" ]; then
		echo -e "${yellowColour}\n[+] ${endColour}${grayColour}Listando propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
	else
		echo -e "\n${redColour}[!] La máquina no existe ${endColour}"
	fi
}

function searchIP(){
	ipAddress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

	if [ "$machineName" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${blueColour}La máquina con la IP${endColour} ${grayColour}$ipAddress${endColour} ${blueColour}es la${endColour} ${purpleColour}$machineName${endColour}\n"
	else
		echo -e "\n${redColour}[!] La dirección IP no esta asociada a ninguna máquina ${endColour}"
	fi

}

function getYoutubeLink(){
	machineName="$1"
	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk '{print $2}')"

	if [ "$youtubeLink" ]; then
		echo -e "${yellowColour}\n[+]${endColour} ${blueColour}Puedes encontrar la resolución de la máquina en el siguiente enlace:${endColour} ${grayColour}$youtubeLink${endColour}\n"
	else
		echo -e "\n${redColour}[!] La máquina no existe ${endColour}"
fi
}

function getMachinesDifficulty() {
	difficulty="$1"
	results_check="$(cat bundle.js| grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column)"

	if [ "$results_check" ]; then
		echo -e "${yellowColour}\n[+]${endColour} ${blueColour}Las máquinas con dificultad${endColour}${grayColour} $difficulty${endColour}${blueColour} son: ${endColour}\n"
		cat bundle.js| grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column
	else
		echo -e "\n${redColour}[!] La dificultad $difficulty no es válida. Dificultades válidas: Fácil, Media, Difícil, Insane ${endColour}"
	fi
}

function getOSMachines(){
	os="$1"

	os_results="$(cat bundle.js| grep "so: \"$os\"" -B 5 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$os_results" ]; then
		echo -e "${yellowColour}\n[+]${endColour} ${blueColour}Las máquinas con sistema operativo${endColour}${grayColour} $os${endColour}${blueColour} son: ${endColour}\n"
		cat bundle.js| grep "so: \"$os\"" -B 5 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] El sistema operativo $os no es válido. Sistemas Operativos válidos: ${endColour}${yellowColour}Linux${endColour}${redColour},${endColour} ${blueColour}Windows ${endColour}\n"
	fi
}

function getOSDifficultyMachines(){
	difficulty="$1"
	os="$2"

	check_results="$(cat bundle.js| grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "\name: " | awk '{print $2}' | tr -d '"' | tr -d ',')"

	if [ "$check_results" ]; then
		echo -e "${yellowColour}\n[+]${endColour} ${blueColour}Las máquinas con sistema operativo${endColour}${purpleColour} $os${endColour}${blueColour} y con dificultad ${endColour}${greenColour}$difficulty ${endColour}${blueColour}son: ${endColour}\n"
		cat bundle.js| grep "so: \"Windows\"" -C 4 | grep "dificultad: \"Fácil\"" -B 5 | grep "\name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] El sistema operativo ${endColour}${grayColour}$os${endColour}${redColour} o la dificultad ${endColour}${grayColour}$difficulty${endColour}${redColour} no son válidos. Sistemas Operativos válidos: ${endColour}${yellowColour}Linux${endColour}${redColour},${endColour} ${blueColour}Windows.${endColour} ${redColour} Dificultades válidas: Fácil, Media, Difícil, Insane\n"
	fi

}

function getSkill(){
	skill="$1"
	check_skill="$(cat bundle.js| grep "skill" -B 6 | grep -i "$skill" -B 6 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check_skill" ]; then
		echo -e "${yellowColour}\n[+]${endColour} ${blueColour} Las máquinas con la skill ${endColour}${grayColour}$skill${endColour}${blueColour} son: ${endColour}\n"
		cat bundle.js| grep "skill" -B 6 | grep -i "$skill" -B 6 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] La skill $skill no ha sido encontrada${endColour}"
	fi

}



# Indicadores
declare -i parameter_counter=0

# Chivatos

declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress="$OPTARG"; let parameter_counter+=3;;
		y) machineName="$OPTARG"; let parameter_counter+=4;;
		d) difficulty="$OPTARG";chivato_difficulty=1; let parameter_counter+=5;;
		o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
		s) skill="$OPTARG"; let parameter_counter+=7 ;;
		h) ;;
	esac

done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 7 ];then
	getSkill "$skill"
else
	helpPanel
fi








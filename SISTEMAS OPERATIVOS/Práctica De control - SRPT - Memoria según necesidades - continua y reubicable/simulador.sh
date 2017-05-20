#!/bin/bash

#LICENCIA
#	Descripción: Simulador algoritmo de planificacion de procesos SRPT, con
# memoria según necesidades, continua y reubicable.
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.

# TRUNCADO DE MEMORIA
# Aquí se guarda la variable que determina la cantidad de memoria que aparece en
# cada linea, por defecto 0 (sin truncamiento)
{
	memTruncada=$1
	if [ -z "$memTruncada" ];then
	memTruncada=0
	fi
}

#CONSTANTES
MAX=9999
listTam=0

#Variables Colores
{
	coffe='\e[0;33m'
	yellow='\e[1;33m'
	green='\e[1;32m'
	purple='\e[1;35m'
	red='\e[1;31m'
	minusred='\e[0;31m'
	cyan='\e[1;36m'
	minuscyan='\e[0;36m'
	cyan_back='\e[1;44m'
	black='\e[1;30m'
	blue='\e[1;34m'
	white='\e[0;39m'
	inverted='\e[7m'
	NC='\e[0m' # No Color
	Li="${cyan}Li${NC}"
	info="${minuscyan}|${NC}"
	output="informe$(date +%d%m%y-%H%M).txt"
}

	########################### FUNCIONES ########################################
{
	#Funcion imprimeMemoria; imprime la memoria
	function imprimeMemoria {

		for (( jk=0; jk<mem_total; jk++ )) do

			if [ "${mem[$jk]}" = "$Li" ];then
				mem_print[$jk]="Li"
			else
				mem_print[$jk]=${mem[$jk]}
			fi

		done

		if [ "$auto" != "c" ];then
			echo -e "${purple}Memoria libre actual $mem_aux MB${NC}"
			echo -e "${green}Distribución actual de la memoria${NC}"
		fi

		echo "Memoria libre actual $mem_aux MB$" >> "$output"
		echo "Distribución actual de la memoria" >> "$output"


		if [ "$memTruncada" -eq 0 ] 2> /dev/null;then

			if [ "$auto" != "c" ];then
				echo -e "${mem[@]}"
			fi

			echo "${mem_print[@]}" >> "$output"
			auxiliar=0

		else
			auxiliarMemoria=0

			for (( jk=0; jk<mem_total; jk++ ))	do

				if [ $auxiliarMemoria -eq $memTruncada ] 2> /dev/null;then
					auxiliarMemoria=0
					printf "\n"
					printf "\n" >> "$output"
				fi

				if [ "$auto" != "c" ];then
					printf -- "%s " "${mem_print[$jk]}"
				fi

				printf -- "%s " "${mem_print[$jk]} >> $output"
				let auxiliarMemoria=auxiliarMemoria+1

			done

		fi
	}

	#Función Orden; ordena el vector arr según orden de menor a mayor
	#Creación de la lista según llegada
	function Orden {

		#Inicializo el vector de orden
		for (( p=0; p<$i; p++ )) do
			ordenDeLlegada[$p]=-1
		done

		for (( p=$(expr $i-1); p>=0; p-- )) do

			max=0

			for (( jk=0; jk<$i; jk++ )) do

				for (( z=$p, coin=0; z<=$(expr $i-1); z++ )) do

					if [ $jk -eq "${ordenDeLlegada[$z]}" ];then
						coin=1
					fi

				done

			if [ $coin -eq 0 ];then

				if [ ${tiemposDeLlegada[$jk]} -ge $max ];then
					aux=$jk
					max=${tiemposDeLlegada[$jk]}
				fi

			fi

			done

			ordenDeLlegada[$p]=$aux

		done
	}

	#Función validaNombre - comprueba que el nombre no tiene espacios ni se ha utilizado antes
	function validaNombre {

		local j
		local x=0

		for j in ${nombresProcesos[$(expr $i - 1)]}; do
			let x++
		done

		if [ $x -ne 1 ];then #Si es distinto significa que el nombre tiene espacios
			error=1
		elif [ $i -ne 1 ];then #En caso de que no tenga espacios miramos a ver si no se ha repetido el nombre

			#La comprobación solo se hace si no es el primer nombre
			for ((z=0 ; z<$(expr $i-1) ; z++ )) do

				if [ "${nombresProcesos[$(expr $i-1)]}" == "${nombresProcesos[$z]}" ];then
					error=1
				fi

			done

		fi
	}

	#Función Informacion que muestra al usuario la informacion de los datos introducidos
	function imprimeInformacion {

		Orden
		echo -e "${minuscyan} --------------------------------------------------------------- ${NC}"
		echo -e "$info    Proceso    $info    Llegada    $info     Ráfaga    $info    Memoria    $info"

		for (( y=0; y<$i; y++)) do
			l=${ordenDeLlegada[$y]}
			echo -e "${minuscyan} --------------------------------------------------------------- ${NC}"
			echo -e "$info	${nombresProcesos[$l]}	$info	${tiemposDeLlegada[$l]}	$info	${tiemposDeCpu[$l]}	$info	${memoriaNecesaria[$l]}	$info"
		done

		echo -e " ${minuscyan}---------------------------------------------------------------${NC} "
	}

	#Función imprimeInformacionAFichero guarda en un fichero la informacion
	function imprimeInformacionAFichero {

		echo "Los datos de los procesos son los siguientes" >> $output
		echo " --------------------------------------------------------------- "  >> $output
		echo "|    Proceso    |    Llegada    |     Ráfaga    |    Memoria    |"  >> $output

			for (( y=0; y<$proc; y++)) do
				l=${ordenDeLlegada[$y]}
				echo " --------------------------------------------------------------- "  >> $output
				echo "|	${nombresProcesos[$l]}	|	${tiemposDeLlegada[$l]}	|	${tiemposDeCpu[$l]}	|	${memoriaNecesaria[$l]}	|"  >> $output
			done

		echo " --------------------------------------------------------------- "  >> $output
	}

	#Función leeDatosDesdeFichero, lee datos de un fichero
	function leeDatosDesdeFichero {

		x=0
		r=0

		for y in $(cat InputRR.txt); do


				if [[ $x -eq 0 ]]; then

					mem_aux=$(echo $y)

				else

						nombresProcesos[$r]=$(echo $y | cut -f1 -d";")
						tiemposDeLlegada[$r]=$(echo $y | cut -f2 -d";")
						tiemposDeCpu[$r]=$(echo $y | cut -f3 -d";")
						memoriaNecesaria[$r]=$(echo $y | cut -f4 -d";")

						if [ -z ${memoriaNecesaria[$r]} ];then
							err "El fichero InputRR.txt está incompleto, se cargaran los datos por defecto"
							cat default.txt > InputRR.txt
							read -p "Pulse enter para reiniciar"
							exec $0
						fi

						let r=r+1
				fi

				let x=x+1

			done

			if [ $auto != "c" ];then
				echo "La memoria es de $mem_aux MB"
			fi

			echo "La memoria es de $mem_aux MB" >> $output

			proc=${#nombresProcesos[@]} #<--- total de procesos
	}

	#Función aumentaTiempoAcumuladoProceso; aumenta el tiempo de espera acumulado de cada proceso
	function aumentaTiempoAcumuladoProceso {

		for (( y=0; y<$proc; y++ )) do

				if [ "${tiemposDeCpu[$y]}" -ne 0 ] && ( [ "$y" -ne "$z" ] || [ "$1" -eq 1 ] );then
					let proc_waitA[$y]=proc_waitA[$y]+1
				fi

		done
	}

	#Función calculaMediaValoresVector; calcula la media de valores de un vector
	function calculaMediaValoresVector {

		local array=("${!1}")
		media=0
		tot=0

		for (( y=0; y<$proc; y++ )) do
				let media=media+array[$y]
				let tot=tot+1
		done

		media=$(expr $media / $tot)
		return $media
	}

	#Función asignaMemoria; llena la memoria del proceso pasado por parámetro. $1  nombre de proceso, $2 origen $3 fin $4 identificador vectorial del proceso
	function asignaMemoria {

		procesosEnMemoria[$4]=1

		for (( y=$2; y<=$3; y++ )) do
			mem[$y]=$1
			mem_dir[$y]=$4
		done

	}

	#Función desasignaMemoria; libera la memoria de un determinado sitio. $1 origen $2 final $3 id proceso
	function desasignaMemoria {

		for (( y="$1"; y <= $2; y++ )) do
			mem[$y]=${Li}
			mem_dir[$y]=-1
		done

	}

	#Función PartFree; calcula las distintas particiones libres, su tamaño y su posición
	function PartFree {

		for (( y=0; y<$MAX ; y++ )) do
			partition[$y]=0
		done

		part=0
		h=0

		for (( y=0; y<${#mem[@]}; y++ )) do

			value=${mem[$y]}

			if [ $value == $Li ];then

				if [ $h -eq 0 ];then
					part_init[$part]=$y
					h=1
				fi

				let partition[$part]=partition[$part]+1
			else

				if [ $h -eq 1 ];then
					h=0
					let part=part+1
				fi

			fi
		done
	}

	#Función AsignaMem; asigna la memoria a los procesos
	# $1 tiempo actual.
	function AsignaMem {

		auxiliar=0
		reubic=1
		salida=0

		for (( alpha=0; alpha<$proc && salida==0; alpha++ )) do
			zed=${ordenDeLlegada[$alpha]}

			if [ $1 -ge "${tiemposDeLlegada[$zed]}" ];then

				if [ $mem_aux -lt ${memoriaNecesaria[$zed]} ];then

					if [ ${procesosNoEjecutables[$zed]} -eq 0 ];then

						if [ $cola -eq $zed ]  2> /dev/null ;then

							if [ $auto != "c" ];then
								echo "El proceso ${nombresProcesos[$zed]} necesita más memoria de la disponible actualmente, se ejecutará más adelante"
							fi

							echo "El proceso ${nombresProcesos[$zed]} necesita más memoria de la disponible actualmente, se ejecutará más adelante" >> $output
							#Bloqueamos la cola
							cola=$zed
							salida=1

						fi

					fi

				else

					if [ $cola -eq $zed ] 2> /dev/null;then
						PartFree
						memoriaLibre=$MAX
						#Ahora debo buscar la particion de memoria que menos esté ocupada
						for (( ex=0; ex<=$part; ex++ )) do

							if [ ${memoriaNecesaria[$zed]} -le ${partition[$ex]} ];then
								if [ ${partition[$ex]} -lt $memoriaLibre ];then
									memoriaLibre=${partition[$ex]}
									memoriaNecesariaI[$zed]=${part_init[$ex]}
									reubic=0
								fi
							fi

						done

						if [ $reubic -eq 1 ];then
							reubicar
							memoriaNecesariaI[$zed]=$?
						fi

						let memoriaNecesariaF[$zed]=memoriaNecesariaI[$zed]+memoriaNecesaria[$zed]
						let memoriaNecesariaF[$zed]=memoriaNecesariaF[$zed]-1
						asignaMemoria ${nombresProcesos[$zed]} ${memoriaNecesariaI[$zed]} ${memoriaNecesariaF[$zed]} $zed
						auxiliar=1

						#Metemos el procenso en la cola de ejecución
						list[$listTam]=$zed
						let listTam++
						let total++
						let mem_aux=mem_aux-memoriaNecesaria[$zed]
						let next=alpha+1
						cola=${ordenDeLlegada[$next]}

						procesosEnMemoria[$zed]=1

						if [ $auto != "c" ];then
							echo -e "${yellow}El proceso ${nombresProcesos[$zed]} ha entrado en memoria${NC}"
						fi

						echo "El proceso ${nombresProcesos[$zed]} ha entrado en memoria" >> $output
					fi

				fi

			fi

			reubic=1

		done
	}

	#Funcion reubicar; reubica la memoria desplazandola hacia la izquierda todos los programas
	function reubicar {

		#echo "Entra a reubicar"

		before=0
		local aux
		local aux2=0
		local ret

		for (( w=0; w<$mem_total; w++)) do

			if [ ${mem_dir[$w]} -eq -1 -a $before -eq 0 ];then
					before=1
					aux_init=$w
			elif [ $before -eq 1 -a ${mem_dir[$w]} -ne -1 ];then
					aux=${mem_dir[$w]}
					aux2=1
					desasignaMemoria ${memoriaNecesariaI[$aux]} ${memoriaNecesariaF[$aux]} $aux
					memoriaNecesariaI[$aux]=$aux_init
					let memoriaNecesariaF[$aux]=memoriaNecesariaI[$aux]+memoriaNecesaria[$aux]
					let memoriaNecesariaF[$aux]=memoriaNecesariaF[$aux]-1
					asignaMemoria ${nombresProcesos[$aux]} ${memoriaNecesariaI[$aux]} ${memoriaNecesariaF[$aux]} $aux
					before=0
					w=memoriaNecesariaF[$aux]
			fi

		done

		if [ $aux2 -eq 1 ];then

			if [ $auto != "c" ];then
				echo -e "${inverted}La memoria se ha reubicado${NC}"
			fi

			echo "La memoria se ha reubicado" >> $output
		fi

		let ret=${memoriaNecesariaF[$aux]}+1
		return $ret
	}

	#Función validaSiNo; comprueba si se ha medito un si o un no
	#return 1 si se ha introducido s, S, n, N de lo contrario devuelve 0.
	function validaSiNo {

		local j=0

		if [ $1 = "s" -o $1 = "S" -o $1 = "n" -o $1 = "N" ] 2> /dev/null ;then
			j=1
		fi

		return $j
	}

	#Función lista: pone los procesos que esperan para ejecutarse en cola
	function lista {

		local cont
		local aux
		local fin
		proceso=${list[0]}

		#Cuando un proceso termina ya no vuelve a colocarse en la cola, y el tamaño de la cola se reduce
		if [ ${tiemposDeCpu[$proceso]} -eq 0 ];then
			let listTam--

			for (( cont=0;cont<$listTam;cont++ )) do
				list[$cont]=${list[$(expr $cont + 1)]}
			done

		else #La unica diferencia es que el proceso se pone al final de la lista y el tamaño se mantiene
			aux=${list[0]}
			fin=$(expr $listTam - 1)

			for (( cont=0;cont<$listTam;cont++ )) do
				case $cont in
					$fin)
						list[$cont]=$aux
						;;
					*)
						list[$cont]=${list[$(expr $cont + 1)]}
						;;
				esac
			done

		fi
	}

	#Función Estado: dice para el tiempo acual los datos actuales de los procesos
	function Estado {

		local restante
		local memIni
		local memFin

		if [ $auto != "c" ];then
			echo ""
			echo -e "${coffe}Al final de la ejecución de este tiempo los datos son:${NC}"
			echo -e "${minuscyan} -----------------------------------------------------------------------------------------------------------------------------------------------${NC} "
			echo -e "$info    Procesos   $info    Llegada    $info     Tiempo esp acumulado      $info      Ejecución restante       $info    Memoria    $info  Pos mem ini  $info  Pos mem fin  $info"
		fi

		echo "" >> $output
		echo "Al final de la ejecución de este tiempo los datos son:" >> $output
		echo " ----------------------------------------------------------------------------------------------------------------------------------------------- " >> $output
		echo "|    Procesos   |    Llegada    |     Tiempo esp acumulado      |      Ejecución restante       |    Memoria    |  Pos mem ini  |  Pos mem fin  |" >> $output

		for (( p=0; p<$proc;p++ )) do

			pp=${ordenDeLlegada[$p]}

			if [ ${tiemposDeCpu[$pp]} -eq 0 ];then
				restante="END"
			else
				restante=${tiemposDeCpu[$pp]}
			fi

			if [ ${memoriaNecesariaI[$pp]} = "-1" ] 2> /dev/null;then
				memIni="NA"
				memFin="NA"
			elif [ ${memoriaNecesariaI[$pp]} = "-2" ] 2> /dev/null ;then
				memIni="END"
				memFin="END"
			else
				memIni=${memoriaNecesariaI[$pp]}
				memFin=${memoriaNecesariaF[$pp]}
			fi

			if [ $auto != "c" ];then
				echo -e "${minuscyan} ----------------------------------------------------------------------------------------------------------------------------------------------- ${NC}"
				echo -e "$info	${nombresProcesos[$pp]}	$info	${tiemposDeLlegada[$pp]}	$info		${proc_waitA[$pp]}		$info		$restante		$info	${memoriaNecesaria[$pp]}	$info	$memIni	$info	$memFin	$info"
			fi

			echo " ----------------------------------------------------------------------------------------------------------------------------------------------- " >>$output
			echo "|	${nombresProcesos[$pp]}	|	${tiemposDeLlegada[$pp]}	|		${proc_waitA[$pp]}		|		$restante		|	${memoriaNecesaria[$pp]}	|	$memIni	|	$memFin	|" >>$output

		done

		if [ $auto != "c" ];then
			echo -e "${minuscyan} -----------------------------------------------------------------------------------------------------------------------------------------------${NC} "
		fi

		echo " ----------------------------------------------------------------------------------------------------------------------------------------------- " >>$output
	}

	#Función err, redirecciona el mensaje a stderr
	function err {

		echo -e "${red}Error: $1${NC}" >> /dev/stderr
		echo >> /dev/stderr
	}
}

	########################### CABECERA ########################################
{
	clear
	echo -e "${minuscyan} -------------------------------------------------------------------------------------------------- ${NC}"
	echo -e "$info		Práctica de Control - Sistemas Operativos - Grado en Ingeniería Informática	   $info"
	echo -e "$info                                               					       	   $info"
	echo -e "$info		   SRPT, memoria según necesidades,coninua y reubicable               	    	   $info"
	echo -e "$info                                                                                                  $info"
	echo -e "$info					    Programado por:					   $info"
	echo -e "$info			     Santiago Hoyos Zea <shz1001@alu.ubu.es>        			   $info"
	echo -e "$info                                                                                                  $info"
	echo -e "$info					      Licencias:					   $info"
	echo -e "$info				        CC-BY-SA (Documentación)				   $info"
	echo -e "$info					    GPLv3 (Código)					   $info"
	echo -e "${minuscyan} -------------------------------------------------------------------------------------------------- ${NC}"
	echo " -------------------------------------------------------------------------------------------------- "  > $output
	echo "|		Práctica de Control - Sistemas Operativos - Grado en Ingeniería Informática	   |" >> $output
	echo "|                                               					       	   |"  >> $output
	echo "|		   SRPT, memoria según necesidades,coninua y reubicable	    	   |"  >> $output
	echo "|                                                                                                  |"  >> $output
	echo "|					    Programado por:					   |"  >> $output
	echo "|			     Santiago Hoyos Zea <shz1001@alu.ubu.es>			   |"  >> $output
	echo "|                                                                                                  |"  >> $output
	echo "|					      Licencias:					   |"  >> $output
	echo "|				        CC-BY-SA (Documentación)				   |"  >> $output
	echo "|					    GPLv3 (Código)					   |"  >> $output
	echo " -------------------------------------------------------------------------------------------------- "  >> $output
}

	######################### PRE-PLANIFICADOR ###################################
{
	#Recogida de datos
	read -p "Meter lo datos de manera manual? [s,n] " manu
	validaSiNo $manu

	while [ $? -eq 0 ];do
		err "Valor incorrecto"
		read -p "Meter lo datos de manera manual? [s,n] " manu
		SiNo $manu
	done

	if [ $manu = "s" -o $manu = "S" ];then

		j=0 #variable a modo de bandera para los siguientes bucles.
		while [ $j -eq 0 ] 2> /dev/null ;do

			read -p "Introduzca al cantidad de memoria (MB): " mem_aux

			if [ \( $mem_aux -ge 0 \) -a \( $? -eq 0 \) ] 2> /dev/null;then
				j=1
			else
				err "Dato incorrecto"
			fi

		done

		echo "$mem_aux" > InputRR.txt

	else

		if [[ ! -f "InputRR.txt" || "$(wc -l InputRR.txt 2> /dev/null | cut -f1 -d" ")" -le 2 ]];then
			err "El fichero de entrada InputRR.txt no existe o está incompleto, se cargarán los valores por defecto"
			cat default.txt > InputRR.txt
			read -p "Pulse enter para reiniciar"
			exec $0
		fi

	fi

	#Se pide la forma de ejecución del script
	j=0
	while [ $j -eq 0 ]; do

		echo "Opciones de ejecución:"
		echo "[a] Transferencia manual entre tiempos"
		echo "[b] Transferencia automática entre tiempos (5s)"
		echo "[c] Ejecución completamente automática"
		read -p "Escoja una opción: " auto

			if [ $auto = "a" -o $auto = "b" -o $auto = "c" ];then
				j=1
			else
				err "Valor incorrecto"
			fi

	done

	#Vectores de información
	nombresProcesos={}	#Nombre de cada proceso
	tiemposDeLlegada={}		#Turno de llegada del proceso
	tiemposDeCpu={}		#Tiempo de ejecución o ráfaga; se reducirá en cada ciclo de reloj
	memoriaNecesaria={}		#Memoria que necesita cada proceso
	ordenDeLlegada={}	#Orden de llegada
	procesosNoEjecutables={}	#Procesos que no pueden ejecutarse porque no tienen memoria (1 = parado, 0 no parado)
	procesosEnMemoria={}

	clear

	i=1
	t=0
	mem_total=$mem_aux

	if [ $manu = "S" ] 2>/dev/null || [ $manu = "s" ] 2>/dev/null;then

		#bucle que recoge los procesos
		while [ $t -eq 0 ];do

			#Recogida de nombre proceso
			j=0
			while [ $j -eq 0 ];do
				error=0
				read -p "Introduzca el nombre del proceso $i (p$i): " nombresProcesos[$(expr $i-1)]
				validaNombre

				if [ -z "${nombresProcesos[$(expr $i-1)]}" ] 2> /dev/null ;then
					nombresProcesos[$(expr $i-1)]="p$i"
					error=0
					validaNombre # <--- Esta funcion hace uso de la variable error y la variable i en su body

					if [ $error -eq 0 ];then
						j=1
					fi

				elif [ $error -eq 0 ] ;then
					j=1
				else
					err "Nombre incorrecto o ya utilizado"
				fi

			done

			printf -- "%s;" ${nombresProcesos[$(expr $i-1)]} >> InputRR.txt
			j=0

			while [ $j -eq 0 ];do
				read -p "Introduzca el turno de llegada de ${nombresProcesos[$(expr $i-1)]}: " tiemposDeLlegada[$(expr $i-1)]

				if [ "${tiemposDeLlegada[$(expr $i-1)]}" -ge 0 ] 2> /dev/null ;then
					j=1
				else
					err "Dato incorrecto"
				fi

			done

			printf -- "%s;" ${tiemposDeLlegada[$(expr $i-1)]} >> InputRR.txt
			j=0

			while [ $j -eq 0 ];do
				read -p "Introduzca la ráfaga (tiempo de ejecución) de ${nombresProcesos[$(expr $i-1)]}: " tiemposDeCpu[$(expr $i-1)]

				if [ "${tiemposDeCpu[$(expr $i-1)]}" -gt 0 ] 2> /dev/null ;then
					j=1
				else
					err "Dato incorrecto"
				fi

			done

			printf -- "%s;" ${tiemposDeCpu[$(expr $i-1)]} >> InputRR.txt
			j=0

			while [ $j -eq 0 ];do
				read -p "Introduzca la memoria (MB) que necesita ${nombresProcesos[$(expr $i-1)]}: " memoriaNecesaria[$(expr $i-1)]

				if [ "${memoriaNecesaria[$(expr $i-1)]}" -le $mem_total -a "${memoriaNecesaria[$(expr $i-1)]}" -gt 0 ] 2> /dev/null ;then
					j=1
				else
					err "Dato incorrecto"
				fi

			done

			printf -- "%s\n" ${memoriaNecesaria[$(expr $i-1)]} >> InputRR.txt
			j=0

			while [ $j -eq 0 ];do
				read -p "¿Quiere incluir más procesos [S]i,[n]o " p

				if [ -z $p ] 2> /dev/null;then
					p="s"
					j=1
				else
					validaSiNo $p

					if [ $? -eq 1 ];then
						j=1
					else
						j=0
					fi

				fi

			done

			if [ $p = "n" -o $p = "N" ];then
				t=1
				proc=${#nombresProcesos[@]}
			fi

			clear
			imprimeInformacion
			let i=i+1

		done

	else

		clear
		leeDatosDesdeFichero
		i=$proc
		imprimeInformacion

	fi

	imprimeInformacionAFichero
	mem_total=$mem_aux

	if [ $auto != "c" ];then
		read -p "Pulse cualquier tecla para ver la secuencia de procesos"
	fi

	#Declaro las ultimas variables
	declare mem[$mem_aux] #Memoria de tamaño 1 MB por palabra

	#Inicializo la memoria a libre
	for (( y=0; y<$mem_aux; y++ )) do
		mem[$y]=${Li}
	done

	declare proc_waitA[$proc] 				#Tiempo de espera acumulado
	declare proc_waitR[$proc] 				#Tiempo de espera real
	declare memoriaNecesariaI[$proc]  #Palabra inicial
	declare memoriaNecesariaF[$proc]  #Palabra final

	for (( y=0; y<$proc; y++ )) do
		memoriaNecesariaI[$y]="-1"
	done

	declare partition[$MAX]	  					#Tamaño de las distintas particiones libres
	declare tiemposDeLlegada_aux[$proc] #Momento en el que el proceso puede ocupar memoria

	for (( y=0; y<$proc; y++ )) do
		tiemposDeLlegada_aux[$y]=${tiemposDeLlegada[$y]}
	done

	min=${ordenDeLlegada[0]}
	clock=${tiemposDeLlegada[$min]}	#Tiempo actual actual

	for (( i=0; i<$proc; i++ )) do
		proc_waitA[$i]=$clock
	done

	for (( y=0; y<$proc; y++ )) do
		procesosNoEjecutables[$y]=0
	done

	declare mem_dir[$mem_aux]

	for (( y=0; y<$mem_aux; y++ )) do
		mem_dir[$y]=-1
	done

	declare proc_ret[$proc] #Tiempo de retorno
	declare proc_retR[$proc] #Tiempo que ha estado el proceso desde entró hasta que terminó
	declare mem_print[$proc] #Memoria que se guardará en el fichero (sin colores)
	e=0 #e=0 aun no ha terminado, e=1 ya se terminó
	j=0
	exe=0	#Ejecuciones que ha habido en una vuelta de lista
	position=0 #Posición del porceso que se debe ejecutar ahora
	fin=0
	mot=0
	end=0 #Cantidad de procesos finalizados
	total=0 #Procesos introducidos a la memoria
	cola=${ordenDeLlegada[0]}


	for (( m = 0; m < ${#nombresProcesos[@]}; m++ )); do
		procesosEnMemoria[$m]=0
	done

}

	########################## PLANIFICADOR ######################################
{
	z=0
	finProcesado=0
	minimo=${tiemposDeCpu[0]}
	siguiente=$z
	anterior=0
	while [[ $finProcesado -ne 1 ]]; do

		clear

		#Intentamos cargar en memoria los procesos.
		AsignaMem ${clock}
		echo ${procesosEnMemoria[0]} ${procesosEnMemoria[1]} ${procesosEnMemoria[2]} ${procesosEnMemoria[3]}

		#imprime el tiempo actual, tanto en salida estandar como en fichero
		if [ $auto != "c" ];then
			echo -e "${green}Unidad de tiempo actual $clock${NC}"
		fi
		echo "" >> $output
		echo "Unidad de tiempo actual $clock" >> $output

		#Búsqueda de un proceso que tenga el menor tiempo restante necesario
		#de Cpu, es decir al que le falte menos para acabar, ha de haber llegado ya
		#ser el mas pequeño, mayor que 0 y estar en memoria.
		for (( g = 0; g < ${#tiemposDeCpu[@]}; g++ )); do

			echo "candidato:" $g " nombre=" ${nombresProcesos[$g]} "en memoria= " ${procesosEnMemoria[$g]}
			 if [ ${procesosEnMemoria[$g]} -eq 1 ] && [ ${tiemposDeLlegada[$g]} -le ${clock} ] && [ ${tiemposDeCpu[$g]} -lt ${minimo} ] && [ ${tiemposDeCpu[$g]} -ne 0 ]; then
				 minimo=${tiemposDeCpu[$g]}
				 anterior=$z
				 z=$g
				 echo "entra" $g " antes" $anterior
			 fi

		done

		echo "se va a ejecutar= " ${nombresProcesos[$z]}

		#pasamos un ciclo
		let clock++
		let tiemposDeCpu[$z]=tiemposDeCpu[$z]-1
		aumentaTiempoAcumuladoProceso 0
		exe=1

		#El proceso termina en este tiempo?
		if [ "${tiemposDeCpu[$z]}" -eq 0 ];then

			procesosEnMemoria[$z]=0
			let proc_ret[$z]=$clock-1	#El momento de retorno será igual al momento de salida en el reloj (este aumentó antes, por tanto -1)
			let proc_retR[$z]=proc_ret[$z]-tiemposDeLlegada[$z]
			fin=0
			mot=1
			let end++

			let mem_aux=mem_aux+memoriaNecesaria[$z]
			echo "desasignaMemoria ${memoriaNecesariaI[$z]} ${memoriaNecesariaF[$z]}"
			desasignaMemoria ${memoriaNecesariaI[$z]} ${memoriaNecesariaF[$z]} $z
			memoriaNecesariaI[$z]="-2"

			if [ $auto != "c" ];then
				echo -e "${blue}El proceso ${nombresProcesos[$z]} retorna al final de la ráfaga ${proc_ret[$z]}, la memoria asignada fue liberada${NC}"
			fi

			for (( i = 0; i < ${#tiemposDeCpu[@]}; i++ )); do
				if [[ ${tiemposDeCpu[$i]} -gt 0 ]]; then
					minimo=${tiemposDeCpu[$i]}
					z=$i
				fi
			done

			auxiliar=1
		fi

		#lista
		imprimeMemoria
		Estado

		#Esperar enter o no
		if [ $auto = "a" ];then

			if [ $exe -eq 1 -a $end -ne $proc ];then
				echo ""
				read -p "Pulse intro para continuar"
			fi
		elif [ $auto = "b" ];then
			sleep 5
		fi

		if [ ${tiemposDeCpu[$z]} -le 0 ] && [ $anterior -eq $z ] ;then
			finProcesado=1
		fi

	done
}

	######################### POST-PLANIFICADOR ##################################
{
	#Damos valor a proc_waitR
	for (( y=0; y<$proc; y++ )) do

		if [ "${procesosNoEjecutables[$y]}" -eq 0 ] 2> /dev/null ;then
			let proc_waitR[$y]=proc_waitA[$y]-tiemposDeLlegada[$y]
		fi

	done

	if [ $auto != "c" ];then
		read -p "Pulsa cualquier tecla para ver resumen."
	fi

	clear

	if [ $auto != "c" ];then
		echo -e " ${minuscyan}---------------------------------------------------------------------------------------------------------------${NC} "
		echo -e "$info    Proceso    $info        Tiempo Espera Acu      $info       Tiempo Espera Real      $info     Salida    $info  Retorno Real $info"
	fi

	echo "Resumen final" >> $output
	echo " --------------------------------------------------------------------------------------------------------------- "  >> $output
	echo "|    Proceso    |        Tiempo Espera Acu      |       Tiempo Espera Real      |     Salida    |  Retorno Real |"  >> $output

	for (( y=0; y<$proc; y++ )) do

		if [ $auto != "c" ];then
			echo -e " ${minuscyan}---------------------------------------------------------------------------------------------------------------${NC} "
			echo -e "$info	${nombresProcesos[$y]}	$info		${proc_waitA[$y]}		$info		${proc_waitR[$y]}		$info	${proc_ret[$y]}	$info	${proc_retR[$y]}	$info"
		fi

		echo " --------------------------------------------------------------------------------------------------------------- "  >> $output
		echo "|	${nombresProcesos[$y]}	|		${proc_waitA[$y]}		|		${proc_waitR[$y]}		|	${proc_ret[$y]}	|	${proc_retR[$y]}	|"  >> $output

	done

	if [ $auto != "c" ];then
		echo -e " ${minuscyan}---------------------------------------------------------------------------------------------------------------${NC} "
	fi

	echo " --------------------------------------------------------------------------------------------------------------- "  >> $output

	#Cálculo de valores medios
	calculaMediaValoresVector 'proc_waitR[@]'
	media_wait=$?
	calculaMediaValoresVector 'proc_retR[@]'
	media_ret=$?

	if [ $auto != "c" ];then
		echo "Los tiempos medio se calculan con los valores reales"
		echo "Tiempo de espera medio: $media_wait"
		echo "Tiempo de retorno medio: $media_ret"
	fi

	echo "Los tiempos medio se calculan con los valores reales" >> $output
	echo "Tiempo de espera medio: $media_wait" >> $output
	echo "Tiempo de retorno medio: $media_ret" >> $output
}

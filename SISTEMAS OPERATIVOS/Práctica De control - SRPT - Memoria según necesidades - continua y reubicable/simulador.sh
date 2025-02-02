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

#arrays para controlar los procesos
nombresProcesos={}
tiemposDeLlegada={}
tiemposDeCpu={}
tiemposDeCpuCopia={}
estados={}

#variables de memoria
memoria={}
totalMemoria=0
totalMemoriaOcupada=0
procesosEnMemoria={}
memoriaNecesaria={}

#variables del sistema
declare -i reloj
reloj=-1
auto=0 #indica si la ejecucion se hace sin intervención humana obcion b y c
instanteMayor=0

#constante de posibles estados
estados={"","",""}

#Variables Colores
{
  coffe='\e[0;33m'
  green='\e[1;32m'
  red='\e[1;31m'
  cyan='\e[1;36m'
  minuscyan='\e[0;36m'
  blue='\e[1;34m'
  NC='\e[0m' # No Color
  Li="${cyan}Li${NC}"
  info="${minuscyan}|${NC}" #legacy
  separadorVertical="${minuscyan}|${NC}"
  output="informe$(date +%d%m%y-%H%M).txt"
  outputColores="informe$(date +%d%m%y-%H%M)_Color.txt"
}

#Función validaRespuestaSiNo; comprueba si se ha medito un si o un no
#return 1 si se ha introducido s, S, n, N de lo contrario devuelve 0.
function validaRespuestaSiNo() {

  local j=0

  if [ $1 = "s" -o $1 = "S" -o $1 = "n" -o $1 = "N" ] 2>/dev/null; then
    j=1
  fi

  return $j
}

#Función err, redirecciona el mensaje a stderr
function imprimeError() {
  echo -e "${red}Error: $1${NC}" >>/dev/stderr
  echo >>/dev/stderr
}

#Pide y guarda todos los datos necesarios para la ejecución del script
function recogeDatos() {

  #preguntamos si se desea introducir los datos manualmente,
  #si la respuesta es no se cragn desde fichero
  local ok=0
  while [ $ok -eq 0 ]; do

    read -p "¿Desea introducir los datos de forma manual? [s,n] " isManual
    validaRespuestaSiNo $isManual

    if [[ $? -eq 0 ]]; then
      imprimeError "Valor incorrecto"
    else
      ok=1
    fi

  done

  #Pedimos el total de memoria
  if [ $isManual = "s" -o $isManual = "S" ]; then
    ok=0
    while [ $ok -eq 0 ] 2>/dev/null; do

      read -p "Introduzca al cantidad de memoria (MB): " totalMemoria

      if [ \( $totalMemoria -ge 0 \) -a \( $? -eq 0 \) ] 2>/dev/null; then
        ok=1
      else
        imprimeError "Valor de memoria no permitido!"
      fi

    done

    echo "$totalMemoria" >Input.txt
  else

    if [[ ! -f "Input.txt" || "$(wc -l Input.txt 2>/dev/null | cut -f1 -d" ")" -le 2 ]]; then
      imprimeError "!!El fichero de entrada Input.txt no existe o está incompleto... creado uno nuevo por default!"
      echo "12
      1;0;7;1
      p2;1;6;2
      p3;2;2;10
      p4;2;3;6
      p5;3;4;2" >>Input.txt
    fi

  fi

  #preguntamos la forma de ejecución del script
  ok=0
  while [ $ok -eq 0 ]; do

    echo "Opciones de ejecución:"
    echo "[a] Transferencia manual entre tiempos"
    echo "[b] Transferencia automática entre tiempos (5s)"
    echo "[c] Ejecución completamente automática"
    read -p "Escoja una opción: " auto

    if [ $auto = "a" -o $auto = "b" -o $auto = "c" ]; then
      ok=1
    else
      imprimeError "Elección no valida!"
    fi

  done

  i=1
  t=0
  mem_total=$mem_aux

  if [ $isManual = "S" ] 2>/dev/null || [ $isManual = "s" ] 2>/dev/null; then

    #bucle que recoge los procesos
    while [ $t -eq 0 ]; do

      #Recogida de nombre proceso
      j=0
      while [ $j -eq 0 ]; do

        error=0
        read -p "Introduzca el nombre del proceso $i (p$i): " nombresProcesos[$(expr $i-1)]

        iMenos1=$(expr $i - 1)
        if [ -z ${nombresProcesos[$iMenos1]} ] 2>/dev/null; then
          nombresProcesos[$(expr $i-1)]="p$i"
          error=0

          local j2
          local x2=0

          for j2 in ${nombresProcesos[$iMenos1]}; do
            let x2++
          done

          if [ $x2 -ne 1 ]; then #Si es distinto significa que el nombre tiene espacios
            error=1
          elif [ $i -ne 1 ]; then #En caso de que no tenga espacios miramos a ver si no se ha repetido el nombre

            #La comprobación solo se hace si no es el primer nombre
            for ((z = 0; z < $iMenos1; z++)); do

              if [ "${nombresProcesos[$iMenos1]}" == "${nombresProcesos[$z]}" ]; then
                error=1
              fi

            done

          fi

          if [ $error -eq 0 ]; then
            j=1
          fi

        elif [ $error -eq 0 ]; then
          j=1
        else
          imprimeError "Nombre incorrecto o ya utilizado"
        fi

      done

      printf -- "%s;" ${nombresProcesos[$iMenos1]} >>Input.txt
      j=0

      while [ $j -eq 0 ]; do
        read -p "Introduzca el turno de llegada de ${nombresProcesos[$iMenos1]}: " tiemposDeLlegada[$(expr $i-1)]

        if [ "${tiemposDeLlegada[$iMenos1]}" -ge 0 ] 2>/dev/null; then
          j=1
          if [[ ${tiemposDeLlegada[$iMenos1]} -gt $instanteMayor ]]; then
            instanteMayor=${tiemposDeLlegada[$iMenos1]}
          fi
        else
          imprimeError "Dato incorrecto"
        fi

      done

      printf -- "%s;" ${tiemposDeLlegada[$iMenos1]} >>Input.txt
      j=0

      while [ $j -eq 0 ]; do
        read -p "Introduzca la ráfaga (tiempo de ejecución) de ${nombresProcesos[$iMenos1]}: " tiemposDeCpu[$iMenos1]

        if [ "${tiemposDeCpu[$iMenos1]}" -gt 0 ] 2>/dev/null; then
          j=1
          tiemposDeCpuCopia[$iMenos1]=${tiemposDeCpu[$iMenos1]}
        else
          imprimeError "Dato incorrecto"
        fi

      done

      printf -- "%s;" ${tiemposDeCpu[$iMenos1]} >>Input.txt
      j=0

      while [ $j -eq 0 ]; do
        read -p "Introduzca la memoria (MB) que necesita ${nombresProcesos[$iMenos1]}: " memoriaNecesaria[$(expr $i-1)]

        if [ "${memoriaNecesaria[$iMenos1]}" -le $totalMemoria -a "${memoriaNecesaria[$iMenos1]}" -gt 0 ] 2>/dev/null; then
          j=1
        else
          imprimeError "Dato incorrecto"
        fi

      done

      printf -- "%s\n" ${memoriaNecesaria[$iMenos1]} >>Input.txt
      j=0

      while [ $j -eq 0 ]; do
        read -p "¿Quiere incluir más procesos [S]i,[n]o " p

        if [ -z $p ] 2>/dev/null; then
          p="s"
          j=1
        else
          validaRespuestaSiNo $p

          if [ $? -eq 1 ]; then
            j=1
          else
            j=0
          fi

        fi

      done

      if [ $p = "n" -o $p = "N" ]; then
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
    i=${#nombresProcesos[@]}
    imprimeInformacion
  fi

}

#Función Informacion que muestra al usuario la informacion de los datos introducidos
function imprimeInformacion() {

  echo "TOTAL DE MEMORIA DEL SISTEMA:" $totalMemoria"MB"
  echo -e "${minuscyan} --------------------------------------------------------------- ${NC}"
  echo -e "$info    Proceso    $info    Llegada    $info     Ráfaga    $info    Memoria    $info"

  for ((y = 0; y < ${#nombresProcesos[@]}; y++)); do
    echo -e "${minuscyan} --------------------------------------------------------------- ${NC}"
    echo -e "$info	${nombresProcesos[$y]}	$info	${tiemposDeLlegada[$y]}	$info	${tiemposDeCpu[$y]}	$info	${memoriaNecesaria[$y]}	$info"
  done

  echo -e " ${minuscyan}---------------------------------------------------------------${NC} "

  echo "Los datos de los procesos son los siguientes" >>$output
  echo " --------------------------------------------------------------- " >>$output
  echo "|    Proceso    |    Llegada    |     Ráfaga    |    Memoria    |" >>$output

  for ((y = 0; y < ${#nombresProcesos[@]}; y++)); do
    l=${ordenDeLlegada[$y]}
    echo " --------------------------------------------------------------- " >>$output
    echo "|	${nombresProcesos[$y]}	|	${tiemposDeLlegada[$y]}	|	${tiemposDeCpu[$y]}	|	${memoriaNecesaria[$y]}	|" >>$output
  done

  echo " --------------------------------------------------------------- " >>$output
}

#Función leeDatosDesdeFichero, lee datos de un fichero
function leeDatosDesdeFichero() {

  x=0
  r=0

  for y in $(cat Input.txt); do

    if [[ $x -eq 0 ]]; then

      totalMemoria=$(echo $y)

    else

      nombresProcesos[$r]=$(echo $y | cut -f1 -d";")
      tiemposDeLlegada[$r]=$(echo $y | cut -f2 -d";")
      tiemposDeCpu[$r]=$(echo $y | cut -f3 -d";")
      tiemposDeCpuCopia[$r]=${tiemposDeCpu[$r]}
      memoriaNecesaria[$r]=$(echo $y | cut -f4 -d";")

      if [[ ${tiemposDeLlegada[$r]} -gt $instanteMayor ]]; then
        instanteMayor=${tiemposDeLlegada[$r]}
      fi

      if [ -z ${memoriaNecesaria[$r]} ]; then
        imprimeError "!!!!!!!El fichero Input.txt está incompleto, se cargaran los datos por defecto"
        read -p "Pulse enter para reiniciar"
        exec $0
      fi

      let r=r+1
    fi

    let x=x+1

  done
}

#Esta funcion funciona a modo de recolector de basura, se llama cuando se queira
#liberar memoria del sistema. Java Like ;)
function recolectaBasura() {

  for ((i = 0; i < ${#nombresProcesos[@]}; i++)); do

    #procesos en memoria que han terminado
    if [ ${procesosEnMemoria[$i]} -eq 1 ] && [ ${tiemposDeCpu[$i]} -eq 0 ]; then

      for ((m = ${memoriaNecesariaI[$i]}; m <= ${memoriaNecesariaF[$i]}; m++)); do
        memoria[$m]=$Li
      done

      procesosEnMemoria[$i]=0
      memoriaNecesariaI[$i]=-1
      memoriaNecesariaF[$i]=-1
      totalMemoriaOcupada=$(expr $totalMemoriaOcupada - ${memoriaNecesaria[$i]})
    fi

  done
}

#Función que se encarga de la asignación de la memoria, reubica de ser necesario
function asignaMemoria() {

  for ((i = 0; i < ${#nombresProcesos[@]}; i++)); do

    #solo vamos a buscarles sitio a los procesos que ya hayan llegado y que no tengan
    #memoria asignada aún y nenecisten CPU.
    if [ ${procesosEnMemoria[$i]} -eq 0 ] && [ ${tiemposDeCpu[$i]} -gt 0 ] \
      && [ ${tiemposDeLlegada[$i]} -le ${reloj} ]; then

      #tenemos memoria para alojarlo?
      if [[ ${memoriaNecesaria[$i]} -le $(expr $totalMemoria - $totalMemoriaOcupada) ]]; then

        #recorremos toda la memoria buscando un particion donde alogar el proceso
        inicio=0
        contador=0
        for ((h = $inicio; h < $totalMemoria; h++)); do

          if [ ${memoria[$h]} != $Li ]; then
            contador=0
            inicio=$(expr $h + 1)
          else
            let contador++

            if [[ $contador -ge ${memoriaNecesaria[$i]} ]]; then

              memoriaNecesariaI[$i]=$inicio
              memoriaNecesariaF[$i]=$h
              procesosEnMemoria[$i]=1
              totalMemoriaOcupada=$(expr $totalMemoriaOcupada + ${memoriaNecesaria[$i]})

              for ((m = $inicio; m <= $h; m++)); do
                memoria[$m]=${nombresProcesos[$i]}
              done

              #marcamos el proceso en memoria si no esta en pausa,
              #ya ques is está en pausa es que esta en memoria
              if [ estados[$i]!="EN PAUSA" ] || [ estados[$i]!="EN EJECUCION" ]; then
                estados[$i]="EN MEMORIA"
              fi

              break
            fi
          fi

        done

        #no se han encontrado particiones con suficiente tamaño hay que reubicar
        if [[ ${procesosEnMemoria[$i]} -eq 0 ]]; then

          echo -e "${red}Reubucando memoria${NC}"

          #Borramos el array de memoria
          for ((m = 0; m < $totalMemoria; m++)); do
            memoria[$m]=${Li}
          done

          #Quitamos los procesos de memoria
          for ((p = 0; p < ${#nombresProcesos[@]}; p++)); do
            procesosEnMemoria[$p]=0
          done

          #marcamos memoria ocupada a 0 y llamamos a asignar memoria
          #que al ver que no hay proceso en memoria los asignara de forma contigua
          totalMemoriaOcupada=0
          asignaMemoria

        fi

      else
        echo -e "${red}Houston! tenemos un problema, no hay memoria para "${nombresProcesos[$i]}" se intentara alojar después :(${NC}"
        estados[$i]="SIN MEMO."
      fi

    fi

  done

}

#Función Estado: dice para el tiempo acual los datos actuales de los procesos
function Estado() {

  local restante
  local memIni
  local memFin

  #impresion consola
  if [ $auto != "c" ]; then
    echo " -----------------------------------------------------------------------------------------------------------------------------------"
    echo -e "|     Nombre	|  T. llegada  | T. Nec. | Mem. Nec. | T. Esp. Acu. | T. Ret. | T. rest. |   Mapa Mem.  |	Estado		"
  fi

  #impresion fichero sin color
  echo " -----------------------------------------------------------------------------------------------------------------------------------" >>$output
  echo "|     Nombre	|  T. llegada  | T. Nec. | Mem. Nec. | T. Esp. Acu. | T. Ret. | T. rest. |   Mapa Mem.  |	Estado		" >>$output

  #impresion fichero color
  echo " -----------------------------------------------------------------------------------------------------------------------------------" >>$outputColores
  echo "|     Nombre	|  T. llegada  | T. Nec. | Mem. Nec. | T. Esp. Acu. | T. Ret. | T. rest. |   Mapa Mem.  |	Estado		" >>$outputColores

  for ((p = 0; p <= $instanteMayor; p++)); do
    for ((n = 0; n < ${#nombresProcesos[@]}; n++)); do
      pp=$n

      if [[ ${tiemposDeLlegada[$pp]} -eq $p ]]; then

        if [ ${tiemposDeCpu[$pp]} -eq 0 ]; then
          restante="0"
        else
          restante=${tiemposDeCpu[$pp]}
        fi

        if [ ${memoriaNecesariaI[$pp]} = "-1" ] 2>/dev/null; then
          memIni="NA"
          memFin="NA"
        elif [ ${memoriaNecesariaI[$pp]} = "-2" ] 2>/dev/null; then
          memIni="END"
          memFin="END"
        else
          memIni=${memoriaNecesariaI[$pp]}
          memFin=${memoriaNecesariaF[$pp]}
        fi

        #salida consola
        if [ $auto != "c" ]; then
          echo -e "${minuscyan}------------------------------------------------------------------------------------------------------------------------------------${NC}"
          echo -e "$info	${nombresProcesos[$pp]}		${tiemposDeLlegada[$pp]}	   ${tiemposDeCpuCopia[$pp]}		${memoriaNecesaria[$pp]}	   ${proc_waitA[$pp]}		${proc_ret[$pp]}	   $restante	     {$memIni - $memFin}	     ${estados[$pp]}		"
        fi

        #fichero sin color
        echo "------------------------------------------------------------------------------------------------------------------------------------" >>$output
        echo "|	${nombresProcesos[$pp]}		${tiemposDeLlegada[$pp]}	   ${tiemposDeCpuCopia[$pp]}		${memoriaNecesaria[$pp]}	   ${proc_waitA[$pp]}		${proc_ret[$pp]}	   $restante	     {$memIni - $memFin}	     ${estados[$pp]}		" >>$output

        #fichero colores
        echo -e "${minuscyan}------------------------------------------------------------------------------------------------------------------------------------${NC}" >>$outputColores
        echo -e "$info	${nombresProcesos[$pp]}		${tiemposDeLlegada[$pp]}	   ${tiemposDeCpuCopia[$pp]}		${memoriaNecesaria[$pp]}	   ${proc_waitA[$pp]}		${proc_ret[$pp]}	   $restante	     {$memIni - $memFin}	     ${estados[$pp]}		" >>$outputColores

      fi

    done

  done

  #salida consola
  if [ $auto != "c" ]; then
    echo -e "${minuscyan}------------------------------------------------------------------------------------------------------------------------------------${NC} "
  fi

  #fichero sin color
  echo "------------------------------------------------------------------------------------------------------------------------------------" >>$output

  #fichero con color
  echo -e "${minuscyan}------------------------------------------------------------------------------------------------------------------------------------${NC} " >>$outputColores

}

#imprime las cabeceras en las salidas del sistema
function inprimeCabecera() {

  #impresion en la salida estadar
  echo -e "${minuscyan}..........................................................................................................................................${NC}"
  echo -e $separadorVertical Procesos $separadorVertical T. ejecución $separadorVertical Memoria $separadorVertical Llegada $separadorVertical T. esp. acumulado $separadorVertical T. retorno $separadorVertical T. eje. restante $separadorVertical Estado $separadorVertical Pos mem. ini $separadorVertical Pos mem. fin $separadorVertical
  echo -e "${minuscyan}..........................................................................................................................................${NC}"

  #impresion de la salida de fichero con color
  echo -e "${minuscyan}..........................................................................................................................................${NC}" >>$outputColores
  echo -e $separadorVertical Procesos $separadorVertical T. ejecución $separadorVertical Memoria $separadorVertical Llegada $separadorVertical T. esp. acumulado $separadorVertical T. retorno $separadorVertical T. eje. restante $separadorVertical Estado $separadorVertical Pos mem. ini $separadorVertical Pos mem. fin $separadorVertical >>$outputColores
  echo -e "${minuscyan}..........................................................................................................................................${NC}" >>$outputColores

  #impresión en la salida de fichero sin color
  echo "..........................................................................................................................................." >>$output
  echo "| Procesos | T. ejecución | Memoria | Llegada | T. esp. acumulado | T. retorno | T. eje. restante |  Estado | Pos mem. ini | Pos mem. fin  |" >>$output
  echo "..........................................................................................................................................." >>$output
}

#Función aumentaTiempoAcumuladoProceso; aumenta el tiempo de espera a los proceos
#que ya han llegado y que no hayan acabado y no este en cpu $1=ProcesoActual
function aumentaTiempoAcumuladoProcesos() {
  for ((y = 0; y < ${#nombresProcesos[@]}; y++)); do
    if [ "${tiemposDeCpu[$y]}" -ne 0 ] && [ ${tiemposDeLlegada[$y]} -le $reloj ] && [ $1 -ne $y ]; then
      proc_waitA[$y]=$(expr ${proc_waitA[$y]} + 1)
    fi
  done
}

#Función aumentaTiempoAcumuladoProceso; aumenta el tiempo de espera a los proceos
#que ya han llegado y que no hayan acabado  $1=ProcesoActual
function aumentaTiempoRetornoProcesos() {
  for ((y = 0; y < ${#nombresProcesos[@]}; y++)); do
    if [ "${tiemposDeCpu[$y]}" -ne 0 ] && [ ${tiemposDeLlegada[$y]} -le $reloj ]; then
      #Tiempo de retorno del proceso: momento actual - momento de llegada
      proc_ret[$procesoActual]=$(expr $reloj + 1 - ${tiemposDeLlegada[$procesoActual]})
    fi
  done
}

#imprime el estado actual de la memoria del sistema
function imprimeMemoria() {
  if [ $auto != "c" ]; then
    echo -n -e "${blue}Mapa de memoria en el instante $reloj {${NC}"
  fi

  echo -n "Mapa de memoria en el instante $reloj {" >>$output
  echo -n -e "${blue}Mapa de memoria en el instante $reloj {${NC}" >>$outputColores

  for ((memoPos = 0; memoPos < totalMemoria; memoPos++)); do

    if [ $auto != "c" ]; then
      echo -n -e " ${memoria[$memoPos]}"
    fi

    if [[ ${memoria[$memoPos]} == "$Li" ]]; then
      echo -n " Li" >>$output
    else
      echo -n " ${memoria[$memoPos]}" >>$output
    fi

    echo -n -e " ${memoria[$memoPos]}" >>$outputColores

  done
  if [ $auto != "c" ]; then
    echo -n -e " ${blue}}${NC}\n"
  fi

  echo -n -e " }\n" >>$output
  echo -n -e " ${blue}}${NC}\n" >>$outputColores
}

###################### INICIO DEL SCRIPT #################

#Impresión de cabeceras
{
  clear
  echo -e "${minuscyan} -------------------------------------------------------------------------------------------------- ${NC}"
  echo -e "$info		Práctica de Control - Sistemas Operativos - Grado en Ingeniería Informática	   $info"
  echo -e "$info                                               					       	   $info"
  echo -e "$info		   SRPT, memoria según necesidades,coninua y reubicable               	    	   $info"
  echo -e "$info                                                                                                  $info"
  echo -e "$info		              Antiguos programadores en R.R.:           		           $info"
  echo -e "$info			               Mario Juez Gil        			                   $info"
  echo -e "$info			             Luis Pedrosa Ruiz       			                   $info"
  echo -e "$info		                José Luis Garrido Labrador  			                   $info"
  echo -e "$info			           Omar Santos Bernabé       		                           $info"
  echo -e "$info                                                                                                  $info"
  echo -e "$info	                         Fork SRPT  Programado por:					   $info"
  echo -e "$info			   Santiago Hoyos Zea <shz1001@alu.ubu.es>                    		   $info"
  echo -e "$info                                                                                                  $info"
  echo -e "$info					  Licencias:					           $info"
  echo -e "$info				    CC-BY-SA (Documentación)				           $info"
  echo -e "$info					GPLv3 (Código)					           $info"
  echo -e "${minuscyan} -------------------------------------------------------------------------------------------------- ${NC}"
}

recogeDatos

declare proc_waitA[${#nombresProcesos[@]}] #Tiempo de espera acumulado
declare proc_ret[${#nombresProcesos[@]}]   #Tiempo de retorno
finDeLaPlanificacion=0
procesoActual=0
procesoAnterior=-1
onEventoDestacable=1
minimo=99999999
clear

#Rellenado de algunos arrays de datos
for ((i = 0; i < ${#nombresProcesos[@]}; i++)); do
  procesosEnMemoria[$i]=0
  estados[$i]="SIN LLEGAR"
  memoriaNecesariaI[$i]="NA"
  memoriaNecesariaF[$i]="NA"
  proc_ret[$i]=0
done

#Marcado del array de memoria como Li
for ((b = 0; b < $totalMemoria; b++)); do
  memoria[$b]=${Li}
done

for ((i = 0; i < ${#nombresProcesos[@]}; i++)); do
  proc_waitA[$i]=0
done

echo "${ordenarImpresion[*]}"

#Bucle de planificación
while [[ $finDeLaPlanificacion -eq 0 ]]; do

  clear
  let reloj++

  asignaMemoria

  #Elegimos el proceso a ejecutar: será el que menos cpu le quede para acabar que este en memoria y haya llegado
  for ((candidato = 0; candidato < ${#tiemposDeCpu[@]}; candidato++)); do

    if [ ${procesosEnMemoria[$candidato]} -eq 1 ] && [ ${tiemposDeLlegada[$candidato]} -le ${reloj} ] \
      && [ ${tiemposDeCpu[$candidato]} -lt ${minimo} ] && [ ${tiemposDeCpu[$candidato]} -ne 0 ]; then

      procesoAnterior=$procesoActual
      procesoActual=$candidato
      minimo=${tiemposDeCpu[$candidato]}
    fi

  done

  aumentaTiempoAcumuladoProcesos $procesoActual

  #si ha habido un cambio de contexto lo logueamos
  if [[ $procesoActual -ne $procesoAnterior ]]; then

    if [ $procesoAnterior -ge 0 ] && [ ${tiemposDeCpu[$procesoAnterior]} -gt 0 ] && [ ${tiemposDeLlegada[$procesoAnterior]} -le $reloj ] \
    && [ "${estados[$procesoAnterior]}" != "SIN MEMO." ] && [ "${estados[$procesoAnterior]}" != "EN MEMORIA"  ]; then


      estados[$procesoAnterior]="EN PAUSA"

      if [ $auto != "c" ]; then
        echo "Cambio de contexto"
      fi
      echo "Cambio de contexto" >>$output
      echo "Cambio de contexto" >>$outputColores

      onEventoDestacable=1
    fi
  else
    let minimo--
  fi

  #Diferenciamos entre entra y se ejecuta a en ejecución que simplemente indica que sigue ejecutandose
  if [ ${tiemposDeCpu[$procesoActual]} -eq ${tiemposDeCpuCopia[$procesoActual]} ]; then
    estados[$procesoActual]="ENTRA Y SE EJECUTA"
  else
    estados[$procesoActual]="EN EJECUCION"
  fi

  tiemposDeCpu[$procesoActual]= let tiemposDeCpu[$procesoActual]--

  aumentaTiempoRetornoProcesos $procesoActual

  #El proceso actual acaba en este tiempo
  if [[ ${tiemposDeCpu[$procesoActual]} -eq 0 ]]; then

    estados[$procesoActual]="FINALIZANDO"
    procesoAnterior=$procesoActual

    #Como el minimo es 0 en este momento tenemos que buscar un minimo comparable
    #para ello cogemos el primer proceso con necesidad > 0 y que este ya en memoria
    finDeLaPlanificacion=1
    for ((i = 0; i < ${#tiemposDeCpu[@]}; i++)); do
      if [ ${tiemposDeCpu[$i]} -gt 0 ] && [ ${tiemposDeLlegada[$i]} -le ${reloj} ]; then
        minimo=${tiemposDeCpu[$i]}
        procesoActual=$i
        finDeLaPlanificacion=0
        break
      fi
    done
  fi

  onEventoDestacable=1
  if [ $onEventoDestacable -eq 1 ] || [ $finDeLaPlanificacion -eq 1 ]; then

    if [ $onEventoDestacable -eq 1 ]; then

      if [ $auto != "c" ]; then
        echo -e "${green}Instante actual $(expr $reloj + 1) ${NC}"
      fi
      echo "Instante actual $reloj" >>$output
      echo -e "${green}Instante actual $reloj ${NC}" >>$outputColores
    fi

    imprimeMemoria
    Estado

    #Esperar enter o no
    if [ $auto = "a" ]; then
      if [ $finDeLaPlanificacion -ne 1 ]; then
        echo ""
        read -p "Pulse intro para continuar"
      fi
    elif [ $auto = "b" ]; then
      sleep 5
    fi

    onEventoDestacable=0
  fi

  recolectaBasura

done

#Post planificación
{

  if [ $auto != "c" ]; then
    read -p "Pulsa cualquier tecla para ver resumen..."
  fi

  clear

  echo -e "${green}En la sigueinte tabla se ve para cada proceso el tiempo que ha pasado esperando en la cola de listos.\nademás del tiempo que ha tardado en retornar una respuesta.${NC}"

  if [ $auto != "c" ]; then
    echo -e " ${minuscyan}----------------------------------------------------------------${NC} "
    echo -e "$info    Proceso    $info         Tiempo Espera Acu     $info Tiempo retorno $info"
  fi
  echo "Resumen final" >>$output
  echo " --------------------------------------------------------------------------------------- " >>$output
  echo "|    Proceso    |        Tiempo Espera Acu    |  Tiempo retorno |" >>$output

  for ((y = 0; y < ${#nombresProcesos[@]}; y++)); do

    if [ $auto != "c" ]; then
      echo -e " ${minuscyan}-----------------------------------------------------------------${NC} "
      echo -e "$info	${nombresProcesos[$y]}	$info		${proc_waitA[$y]}		$info	${proc_ret[$y]}\t $info"
    fi

    echo " -----------------------------------------------------------------" >>$output
    echo "|	${nombresProcesos[$y]}	|		${proc_waitA[$y]}		|	${proc_ret[$y]}	 |" >>$output

  done

  if [ $auto != "c" ]; then
    echo -e " ${minuscyan}-----------------------------------------------------------------${NC} "
  fi
  echo " ----------------------------------------------------------------- " >>$output

}

#INSTALACION

#VARIABLES DE AMBIENTE

#DIRECTORIO PADRE
GRUPO="$PWD"

#DIRECTORIOS DE CONFIGURACION
CONF="$GRUPO/conf"
LOG="$CONF/log"

#DIRECTORIOS

DIRECTORIOS_DEFAULT=("ejecutables" "maestros" "novedades" "aceptados" "rechazados" "procesados" "salida")
DIRECTORIOS=()


log ()
{
        date +"%x %X-$USER-$1-$2-$3" >> "$LOG/instalacion.log"
}


crear_tpconfig ()
{

        date +"GRUPO01-$GRUPO-$USER-%x %X" > "$CONF/tpconfig.txt"
        date +"CONF-$CONF-$USER-%x %X" >> "$CONF/tpconfig.txt"
        date +"LOG-$LOG-$USER-%x %X" >> "$CONF/tpconfig.txt"

        for i in {0..6}
        do
                date +"${DIRECTORIOS[$i]}-$GRUPO/${DIRECTORIOS[$i]}-%x %X" >> "$CONF/tpconfig.txt"
        done

        log "crear_tpconfig" "INF" "Creacion de tpconfig.txt"
}


crear_backup ()
{
        if [ ! -d "$GRUPO/backup" ]
	then
		mkdir "$GRUPO/backup"

	fi

        cp "instalacion.sh" "$GRUPO/backup/instalacion.sh"
        cp "inicializacion.sh" "$GRUPO/backup/inicializacion.sh"
        cp "daemon.sh" "$GRUPO/backup/daemon.sh"
        cp "START.sh" "$GRUPO/backup/START.sh"
        cp "STOP.sh" "$GRUPO/backup/STOP.sh"

        log "crear_backup" "INF" "Creo backup de los archivos .sh"
}


mover_archivos ()
{
        mv "inicializacion.sh" "$GRUPO/${DIRECTORIOS[0]}/"
        mv "daemon.sh" "$GRUPO/${DIRECTORIOS[0]}/"
        mv "START.sh" "$GRUPO/${DIRECTORIOS[0]}/"
        mv "STOP.sh" "$GRUPO/${DIRECTORIOS[0]}/"

        log "mover_archivos" "INF" "Muevo los archivos .sh a $GRUPO/${DIRECTORIOS[0]}/"

        if [ -f "$GRUPO/operadores.txt" ]
        then
                mv "operadores.txt" "$GRUPO/${DIRECTORIOS[1]}/"
                log "mover_archivos" "INF" "Muevo operadores.txt a $GRUPO/${DIRECTORIOS[1]}/"
        fi

        if [ -f "$GRUPO/sucursales.txt" ]
        then
                mv "sucursales.txt" "$GRUPO/${DIRECTORIOS[1]}/"
                log "mover_archivos" "INF" "Muevo sucursales.txt a $GRUPO/${DIRECTORIOS[1]}/"
        fi

        if [ ! -z "$(ls "$GRUPO" | grep 'Entregas_..')" ]
        then
                mv "Entregas"* "$GRUPO/${DIRECTORIOS[2]}/"
                log "mover_archivos" "INF" "Muevo los archivos de entregas a $GRUPO/${DIRECTORIOS[2]}/"
        fi
}



presentacion ()
{
	echo -e "TP N° 1 de Sistemas Operativos\n"
	echo -e "Grupo N° 1\n"
	echo -e "Miembros:\n"
	echo "Alvarez, Natalia 			| Padron: 90928"
	echo "Fernandez, Gonzalo 		| Padron: 94667"
	echo "Florez, Zoraida 			| Padron: 87039"
	echo "Fonzalida, Miguel 		| Padron: 86125"
	echo "Porras, Sherly 			| Padron: 91076"
}


crear_directorios_de_configuracion ()
{
	if [ ! -d "$CONF" ]
	then
		mkdir "$CONF"
		log "crear_directorios_de_configuracion" "INF" "Se creo el directorio $CONF"
	fi
	if [ ! -d "$LOG" ]
	then 
		mkdir "$LOG"
		log "crear_directorios_de_configuracion" "INF" "Se creo el directorio $LOG"
	fi
}


instalacion ()
{
	echo -e "Comenzando la instalacion...\n"
	echo -e "Directorios reservados:\n"
	echo "$(tput setaf 3)~/${GRUPO##*/}/${CONF##*/}$(tput sgr0)"
	echo "$(tput setaf 3)~/${GRUPO##*/}/${CONF##*/}/${LOG##*/}$(tput sgr0)"
	echo ""

	echo -e "Creacion de los directorios del sistema\n"
	echo -e "En caso de no ingresar ninguna ruta se tomara un valor por default como nombre del directorio\n"	
	
	for i in {0..6}
	do
		if [ -z ${DIRECTORIOS[$i]} ] #Si es la primera vez que ingresar la lista estara vacia, en caso de que no haya confirmado una instalacion ya estaran almacenados en la lista los directorios ingresados anteriormente
		then 
			echo ""
			echo -e "Directorio por default de ${DIRECTORIOS_DEFAULT[$i]}: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS_DEFAULT[$i]}$(tput sgr0)\n"
			echo -e "Ingrese otro nombre si desea cambiarlo"
		else
			echo ""
			echo -e "Directorio por default: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[$i]}$(tput sgr0)\n"
			echo -e "Ingrese otro nombre si desea cambiarlo"
		fi
	        read directorio INPUT
		validar_directorio "$directorio" "$i"
	done	

	echo ""
	echo ""
	echo ""
	echo ""
	mostrar_directorios_a_crear
}


directorio_duplicado () 
{
	for i in {0..6}
	do
		if [ "${DIRECTORIOS[$i]}" = "$1" ]
		then
			echo "Si"
			return 1
		fi
	done
	echo "No"
	return 0
}


validar_directorio () 
{
		if [ "$GRUPO/$1" = "$CONF" ]
		then
			echo -n "Directorio reservado. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
			log "validar_directorio" "INF" "Directorio reservado. Se toma el directorio por defecto: ${DIRECTORIOS[$2]} "
		elif [ "$CONF/$1" = "$LOG" ]
		then
			echo -n "Directorio reservado. Se tomara el  directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
			log "validar_directorio" "INF" "Directorio reservado. Se toma el directorio por defecto: ${DIRECTORIOS[$2]} "
		elif [ -z "$1" ]
		then
			echo -n "Directorio vacio. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
			log "validar_directorio" "INF" "Directorio vacio. Se toma el directorio por defecto: ${DIRECTORIOS[$2]} "
		elif [ $(directorio_duplicado "$1") = "Si" ]
		then	
			echo -n "Directorio ya existente. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
			log "validar_directorio" "INF" "Directorio ya existente. Se toma el directorio por defecto: ${DIRECTORIOS[$2]} "
		else
			echo -n "Se creara el directorio:"
			DIRECTORIOS[$2]="$1"
			DIRECTORIOS_DEFAULT[$2]="$1"
			log "validar_directorio" "INF" "Se ingreso el directorio: ${DIRECTORIOS[$2]} "
		fi

		echo -e "~/${GRUPO##*/}/${DIRECTORIOS[$i]}\n"
}


mostrar_directorios_a_crear () 
{
	echo -e "Estos son los directorios que se crearan\n"
	echo -e "Directorio padre: $(tput setaf 3)~/${GRUPO##*/}/$(tput sgr0)\n"
	echo -e "Directorio de configuracion: $(tput setaf 3)~/${GRUPO##*/}/${CONF##*/}$(tput sgr0)\n"
	echo -e "Archivos de log: $(tput setaf 3)~/${GRUPO##*/}/${CONF##*/}/${LOG##*/}$(tput sgr0)\n"
	echo -e "Libreria de ejecutables: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[0]}$(tput sgr0)\n"
	echo -e "Repositorios de maestros: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[1]}$(tput sgr0)\n"
	echo -e "Directorio para el arribo de archivos externos: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[2]}$(tput sgr0)\n"
	echo -e "Directorios para los archivos aceptados: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[3]}$(tput sgr0)\n"
	echo -e "Directorios para los archivos rechazados: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[4]}$(tput sgr0)\n"
	echo -e "Directorios para archivos procesados: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[5]}$(tput sgr0)\n"
	echo -e "Directorio paraa los archivos de salida: $(tput setaf 3)~/${GRUPO##*/}/${DIRECTORIOS[6]}$(tput sgr0)\n"
	echo -e "Estado de la instalacion: LISTA\n"
	
	echo -e "¿Confirma la instalacion? [s/n]:"
	read respuesta INPUT
	echo ""

	if [ "$respuesta" == "S" ] || [ "$respuesta" == "s" ]
	then
		crear_directorios
		log "mostrar_directorios_a_crear" "INF" "Se confirmo la configuracion"
	else
		echo -e "Confirmacion rechazada. Reiniciando el proceso de instalacion...\n"
		echo ""
		echo ""
		echo "" 
		echo ""
		log "mostrar_directorios_a_crear" "INF" "Se rechazo la configuracion"
		sleep 3s
		instalacion
	fi
}


crear_directorios ()
{
	for i in {0..6}
	do
		if [ ! -d "$GRUPO/${DIRECTORIOS[$i]}" ]
		then
			mkdir "$GRUPO/${DIRECTORIOS[$i]}"
			#Ver log
		fi
	done

	log "crear_directorios" "INF" "Se crearon los directorios del sistema"
}


#Main

presentacion
crear_directorios_de_configuracion
instalacion
crear_tpconfig
crear_backup
mover_archivos


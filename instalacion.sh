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


#Ver archivo Log (Registro de sucesos)


presentacion ()
{
	echo -e "TP N° 1 de Sistemas Operativos\n"
	echo -e "Grupo N° 1\n"
	echo -e "Miembros:\n"
	echo ""
	echo ""
	echo ""
	echo ""
}


crear_directorios_de_configuracion ()
{
	if [ ! -d "$CONF" ]
	then
		mkdir "$CONF"
	fi
	if [ ! -d "$LOG" ]
	then 
		mkdir "$LOG"
	fi
	#Ver log
}


instalacion ()
{
	echo -e "Comenzando la instalacion...\n"
	echo -e "Directorios reservados:\n"
	echo "~/$CONF"
	echo "~/$LOG"
	echo ""

	echo -e "Creacion de los directorios del sistema\n"
	echo -e "En caso de no ingresar ninguna ruta se tomara un valor por default como nombre del directorio\n"	
	
	for i in {0..6}
	do
		if [ -z ${DIRECTORIOS[$i]} ] #Si es la primera vez que ingresar la lista estara vacia, en caso de que no haya confirmado una instalacion ya estaran almacenados en la lista los directorios ingresados anteriormente
		then 
			echo ""
			echo -e "Directorio por default de ${DIRECTORIOS_DEFAULT[$i]}: $GRUPO/${DIRECTORIOS_DEFAULT[$i]}\n"
			echo -e "Ingrese otro nombre si desea cambiarlo"
		else
			echo ""
			echo -e "Directorio por default: $GRUPO/${DIRECTORIOS[$i]}\n"
			echo -e "Ingrese otro nombre si desea cambiarlo"
		fi
	        read directorio INPUT
		validar_directorio "$directorio" "$i"
	done	

	echo "${DIRECTORIOS[0]}"
	echo "${DIRECTORIOS[1]}"
	echo "${DIRECTORIOS[2]}"
	echo "${DIRECTORIOS[3]}"
	echo "${DIRECTORIOS[4]}"
	echo "${DIRECTORIOS[5]}"
	echo "${DIRECTORIOS[6]}"
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
	#if [ ! -z "$( ls "$GRUPO" | grep "$1")" ] || [ ! -z "$( ls "$CONF" | grep "$1")" ]
	#then
		if [ "$GRUPO/$1" = "$CONF" ]
		then
			echo "Directorio reservado. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
		elif [ "$CONF/$1" = "$LOG" ]
		then
			echo "Directorio reservado. Se tomara el  directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
		elif [ -z "$1" ]
		then
			echo "Directorio vacio. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
		
		elif [ $(directorio_duplicado "$1") = "Si" ]
		then	
			echo "Directorio ya existente. Se tomara el directorio por defecto:"
			DIRECTORIOS[$2]="${DIRECTORIOS_DEFAULT[$2]}"
		else
			echo "Se creara el directorio:"
			DIRECTORIOS[$2]="$1"
			DIRECTORIOS_DEFAULT[$2]="$1"
		fi

		echo -e "$GRUPO/${DIRECTORIOS[$i]}\n"	
	#fi
}


mostrar_directorios_a_crear () 
{
	echo -e "Estos son los directorios que se crearan\n"
	echo -e "Directorio padre: $GRUPO\n"
	echo -e "Directorio de configuracion: $CONF\n"
	echo -e "Archivos de log: $LOG\n"
	echo -e "Libreria de ejecutables: $GRUPO/${DIRECTORIOS[0]}\n"
	echo -e "Repositorios de maestros: $GRUPO/${DIRECTORIOS[1]}\n"
	echo -e "Directorio para el arribo de archivos externos: $GRUPO/${DIRECTORIOS[2]}\n"
	echo -e "Directorios para los archivos aceptados: $GRUPO/${DIRECTORIOS[3]}\n"
	echo -e "Directorios para los archivos rechazados: $GRUPO/${DIRECTORIOS[4]}\n"
	echo -e "Directorios para archivos procesados: $GRUPO/${DIRECTORIOS[5]}\n"
	echo -e "Directorio paraa los archivos de salida: $GRUPO/${DIRECTORIOS[6]}\n"
	echo -e "Estado de la instalacion: LISTA\n"
	
	echo -e "¿Confirma la instalacion? [s/n]:"
	read respuesta INPUT
	echo ""

	if [ "$respuesta" == "S" ] || [ "$respuesta" == "s" ]
	then
		crear_directorios
	else
		echo -e "Confirmacion rechazada. Reiniciando el proceso de instalacion...\n"
		echo ""
		echo ""
		echo "" 
		echo ""
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
}


#Main
	presentacion
	crear_directorios_de_configuracion
	instalacion




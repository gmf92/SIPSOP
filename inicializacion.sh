#INICIALIZACION
 
#VARIABLES DE AMBIENTE

#DIRECTORIO PADRE
GRUPO="$PWD"

#DIRECTORIOS DE CONFIGURACION
CONF="$GRUPO/conf"
LOG="$CONF/log"

#DIRECTORIOS
DIRECTORIOS=()


log ()
{
        date + "%x %X-$USER-$1-$2-$3" >> "$LOG/inicializador.log"
}


incrementar_inicializacion () 
{
	linea=$(cat incrementar_inicializacion.txt | tail -n1)
	((linea++))
	echo "$linea" >> "$GRUPO/incrementar_inicializacion.txt"
	echo -e " $linea veces"
}


inicializado () 
{
	if [ ! -e "$GRUPO/incrementar_inicializacion.txt" ]
	then
		echo "Es la primera vez que se inicializa el sistema"
		echo ""  > "$GRUPO/incrementar_inicializacion.txt"
		echo "0" >> "$GRUPO/incrementar_inicializacion.txt"
	else
		echo -n "El sistema ya fue inicializado:"
		incrementar_inicializacion
	fi
}


leer_tpconfig () 
{
	i=0 #Lo utilizo para incrementar las posiciones de la lista de directorios
	directorios_faltantes=0

	while read linea 
	do
		DIRECTORIOS[$i]=$(echo "$linea" | cut -d '-' -f 2)

		if [ ! -d "${DIRECTORIOS[$i]}" ]
		then
			echo "El directorio ${DIRECTORIOS[$i]} no existe"
			((directorios_faltantes++))
		else
			echo "El directorio ${DIRECTORIOS[$i]} existe"
		fi

		((i++))

	done < "$CONF/tpconfig.txt" 

	if [ "$directorios_faltantes" != 0 ]
	then
		echo
		echo "Se ha detectado que falta/n $directorios_faltantes directorio/s"
		echo "Para reparar la instalacion ingrese el comando: ./instalacion.sh -r"
	fi
}


mostrar () 
{
	for i in {0..9}
	do
		echo "${DIRECTORIOS[$i]}"
	done
}


setear_variables () 
{
	export GRUPO
	export CONF
	export LOG
	export EJECUTABLES="${DIRECTORIOS[3]}"
	export MAESTROS="${DIRECTORIOS[4]}"
	export NOVEDADES="${DIRECTORIOS[5]}"
	export ACEPTADOS="${DIRECTORIOS[6]}"
	export RECHAZADOS="${DIRECTORIOS[7]}"
	export PROCESADOS="${DIRECTORIOS[8]}"
	export SALIDA="${DIRECTORIOS[9]}"
}

dar_permisos ()
{
	if [ -d "$MAESTROS" ]
	then
		find "$MAESTROS" -type f -exec chmod +r {} +
		echo "Se dio permiso de lectura al directorio que contiene los archivos maestros"
		echo
	else
		echo "No se pudo dar permiso de lectura al directorio que contiene los archivos maestros ya que no existe"
		echo
	fi
	if [ -d "$EJECUTABLES" ]
	then
		find "$EJECUTABLES" -type f -exec chmod +rx {} +
		echo "Se dieron permisos de lectura y ejecucion al directorio que contiene los archivos ejecutables"
		echo
	else
		echo "No se pudieron dar permisos de lectura y ejecucion al directorio que contiene los archivos ejecutables ya que no existe"
		echo
	fi
}


echo "Inicializando el sistema..."
echo
inicializado
echo
leer_tpconfig
setear_variables
echo
dar_permisos
echo
#mostrar


#Arrancar el proceso
#Invocar al script PROCESO
#./"$EJECUTABLES/START.sh"

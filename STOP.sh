cd ..

#DIRECTORIO PADRE
GRUPO="$PWD"

#DIRECTORIOS DE CONFIGURACION
CONF="$GRUPO/conf"
LOG="$CONF/log"


log ()
{
        date +"%x %T-$1" >> "$LOG/STOP.log"
}

function getPID(){

	PROCESO=$1

	#Busco en la lista de procesos en ejecucion el proceso que deseo detener

        PID=`ps ax | grep bash | grep -v $$ | grep -v grep | grep -w $PROCESO`

	#Me quedo con el PID
	PID=`echo $PID | cut -f 1 -d ' '`

	echo $PID
}

PID_BUSCADO=`getPID daemon.sh`

if [ -z "$PID_BUSCADO" ]; 
then
    echo "Error: No se detuvo demonio por que no se encontraba corriendo"
    log "ERROR -No se detuvo demonio por que no se encontraba corriendo"
else
    kill  $PID_BUSCADO
    echo "El Demonio con PID $PID_BUSCADO se ha detenido"
    log "INFO - el demonio con PID $PID_BUSCADO se ha detenido"
fi


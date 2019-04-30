#STOP

log ()
{
        date +"%x %X-$USER-$1-$2-$3" >> "$LOG/STOP.log"
}


obtener_PID ()
{
        pid="$(ps aux | grep bash | grep daemon.sh | awk '{print $2}' | head -n1)"
        echo "$pid"
}


stop ()
{
	if [ -z "$(obtener_PID)" ]
        then
                echo "No se puede detener el proceso, ya que no existe"
                log "stop" "ERR" "No se puede detener un proceso que no existe"
        else
		kill  "$(obtener_PID)"
		echo "El proceso del tipo demonio con PID $(obtener_PID) se ha detenido"
		log "stop" "INF" "El demonio con PID $(obtener_PID) se ha detenido"
        fi
}


#Main

stop




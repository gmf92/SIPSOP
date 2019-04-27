#START


log ()
{
        date +"%x %X-$USER-$1-$2-$3" >> "$LOG/START.log"
}


verificar_variables_ambiente () 
{
	if [ ! -z "$GRUPO" ] && [ ! -z "$CONF" ] && [ ! -z "$LOG" ] && [ ! -z "$EJECUTABLES" ]
		[ ! -z "$EJECUTABLES" ] && [ ! -z "$MAESTROS" ] && [ ! -z "$NOVEDADES" ] && 
		[ ! -z "$ACEPTADOS" ] && [ ! -z "$RECHAZADOS" ] && [ ! -z "$PROCESADOS" ] && 
		[ ! -z "$SALIDA" ]
	then
		echo "1"
	else
		echo "0"
	fi	
}


existen_directorios () 
{
        if [ -d "$GRUPO" ] && [ -d "$CONF" ] && [ -d "$LOG" ] && [ -d "$EJECUTABLES" ]
                [ -d "$EJECUTABLES" ] && [ -d "$MAESTROS" ] && [ -d "$NOVEDADES" ] &&
                [ -d "$ACEPTADOS" ] && [ -d "$RECHAZADOS" ] && [ -d "$PROCESADOS" ] && [ -d "$SALIDA" ]
        then
                echo "1"
        else
                echo "0"
        fi
}


verificar_permisos_ejecutables ()
{
	START="$GRUPO/START.sh"
	STOP="$GRUPO/STOP.sh"
	INICIALIZACION="$GRUPO/inicializacion.sh"
	PROCESO="$GRUPO/daemon.sh"

        if [ -e "$START" ] && [ -e "$STOP" ] && [ -e "$INICIALIZACION" ] && [ -e "$PROCESO" ]
	then
		if [ -x "$START" ] && [ -x "$STOP" ] && [ -x "$INICIALIZACION" ] && [ -x "$PROCESO" ]
        	then
                	echo "1"
        	else
                	echo "0"
        	fi
	fi
}


verificar_permisos_maestros ()
{
	OPERADORES="$GRUPO/operadores.txt"
	SUCURSALES="$GRUPO/sucursales.txt"

        if [ -e "$OPERADORES" ] && [ -e "$SUCURSALES" ]
        then
        	if [ -r "$OPERADORES" ] && [ -r "$SUCURSALES" ]
                then
                        echo "1"
                else
                        echo "0"
                fi
        fi
}


obtener_PID () 
{
	pid="$(ps aux | grep bash | grep daemon.sh | awk '{print $2}' | head -n1)"
	echo "$pid"
}


arrancar_proceso () 
{
	if [ -z "$(obtener_PID)" ]
	then 
		#bash "$EJECUTABLES/daemon.sh" & #Agrego & ya que debe ser ejecutado en segundo plano
		bash "$GRUPO/daemon.sh" & #Agrego & ya que debe ser ejecutado en segundo plano
		echo "El proceso del tipo demonio fue lanzado con el PID: $(obtener_PID)"
	else 
		echo "No se puede lanzar otro proceso del tipo demonio, debido a que ya existe uno en funcionamiento con el PID: $(obtener_PID)" 
	fi
}


start () 
{
	if [ ! -z verificar_variables_ambiente ] && [ ! -z existen_directorios ] && 
		[ ! -z verificar_permisos_ejecutables ] && [ ! -z verificar_permisos_maestros ]
	then
		echo "Estan dadas las condiciones para arrancar los procesos"
		arrancar_proceso
	else
		echo "No estan dadas las condiciones para arrancar los procesos"
	fi
}


#Main

start

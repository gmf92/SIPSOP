#proceso.sh

# RAIZ
# GRUPO=$(pwd | sed "s-\(.*Grupo01\).*-\1-")

# DIRECTORIOS RESERVADOS
CONF="$GRUPO/conf"
LOG="$CONF/log"

PATH_NOVEDADES="$NOVEDADES"
PATH_ACEPTADOS="$ACEPTADOS"
PATH_RECHAZADOS="$RECHAZADOS"
PATH_SALIDA="$SALIDA"
PATH_PROCESADOS="$PROCESADOS"
ARCH_OPERADORES="$MAESTROS/operadores.txt"
ARCH_SUCURSALES="$MAESTROS/sucursales.txt"
CICLO=0


log ()
{
	#grabando log mientras se ejecuta el script
        date +"%x %X-$USER-$1-$2-$3" >> "$LOG/proceso.log" 
}


verificandoSystemInicializado()
{
	#verifico si los variables de ambiente no esten vacias("")
	
	if [ -n "$CONF" ] && [ -n "$LOG" ] && [ -n "$NOVEDADES" ] && [ -n "$ACEPTADOS" ] && [ -n "$RECHAZADOS" ] && [ -n "$SALIDA" ] && [ -n "$PROCESADOS" ] && [ -n "$MAESTROS" ] && [ -n "$EJECUTABLES" ];
	then
		echo 0
	else
		echo 1
	fi	
}


verificandoNombreDeArchExternos(){
	#verifico que el nombre de los archivos externos sea el correcto, "Entregas_nn"/ nn es un numero del 01 al 99. Los archivos imcorrectos lo envio a rechazados.
	
find "$PATH_NOVEDADES" -type f -not -name "Entregas_[0-9][1-9].txt"|
while read file
do
 	if [ -f "$file" ] 
	then
		log "EL NOMBRE DEL ARCHIVO" "$file" "ES INCORRECTA."
		mv "$file" "$PATH_RECHAZADOS"
	fi
done
}


validarArchivo(){
	for f in "$PATH_NOVEDADES"/*
	do
		ESVALIDO=true
		
		if [ ! -s "$f" ]
		then
		    log "$f" "el archivo está vacio" 
		    ESVALIDO=false
		fi
		
		if [ ! -f "$f" ]
		then
	            log "$f" "el archivo no es regular"
		    ESVALIDO=false
		fi
	
		if [ -f "$PATH_PROCESADOS/$(basename "$f")" ]
		then
		    log "$f" "el archivo fue procesado con anterioridad"
		    ESVALIDO=false
		fi

		#de acuerdo si esvalido se guardara en aceptados o de lo contrario se guardara en los rechazados.
		if [ "$ESVALIDO" ]
		then
		     mv "$f" "$PATH_ACEPTADOS"
		     log "El archivo "$f" ha sido aceptado"
		else
	             mv "$f" "$PATH_RECHAZADOS"
		     log "El archivo "$f" ha sido rechazado"
		fi
	
	done
}


verificandoTrailer()
{
#luego de verificar y obtener nuestros archivos aceptados,para arch_aceptados contaremos la cantidad de registros y hallaremos la sumatoria de los cod postales(CP)

	for f in "$PATH_ACEPTADOS"
	do
 	   #inicializo los contadores
	   cant_registro=0
	   total_suma_CP=0
	   sumatoria_postal_trailer=0
	   cant_registros_trailer=0
	    
		while IFS=';' read -r operador nroPieza apeNom docTipo nroDoc codigo_postal;
		do
		   #
		   let "cant_registro=cant_registro+1"
		   let "total_suma_CP=total_suma_CP+codigo_postal"
		   #valores que estan en la ultima fila y las 2 ultimas columnas de los archivos entregas_nn
		   sumatoria_postal_trailer=$codigo_postal
	           cant_registros_trailer=$nroDoc
		done < $f
		#verifico los valores del trailer.
		let "total_suma_CP=total_suma_CP-sumatoria_postal_trailer"
                if [ "$cant_registros_trailer" -eq "$cant_registro" ] && [ "$sumatoria_postal_trailer" -eq "$total_suma_CP" ];
		then
			log "El trailer de " "$f" " es correcto"
		else
			log "El trailer de " "$f" "es incorrecto los datos son distintos, sera rechazado"
			mv "$f" "$PATH_RECHAZADOS"
		fi
	done
}


procesamos(){
#para iniciar esto ya hemos validado los archivos generando un archivo aceptados correcto.
	for f in "$PATH_ACEPTADOS"/*
	do
	  while IFS=';' read -r operador nroPieza apeNom docTipo nroDoc codigo_postal;
	  do
		regValido=true
		#verificar que el operador exista en el archivo operadores
		if ! (grep -q  "$operador" "$ARCH_OPERADORES") ;
		then 
			motivo="El operador no se encuentra registrado en el archivo de operadores"
			regValido=false
		else #ahora verifico si posee un contrato vigente para el operador

			while IFS=';' read -r cod_operador nom_operador operador_cuit finicio_operacion ffin_operacion;
			do
			   mes_inicio=$(echo "$finicio_operacion" | cut -d'/' -f2)
			   mes_fin=$(echo "$ffin_operacion" | cut -d'/' -f2)
			   mes_corriente=$(date + "%m")
			   if [ "$operador" == "$cod_operador" ] && [ "$mes_inicio" -le "$mes_corriente" ] && [ "$mes_fin" -ge "$mes_corriente" ]
			   then
			 	regValido=true
				log "Se encontro el operador $operador en el archivo de operadores, y esta activo desde $mes_inicio hasta $mes_fin"
				break;
			   else
				regValido=false
				motivo="El operador no tiene vigente el contrato"
				break;
				
			   fi
				
			done < "$ARCH_OPERADORES"
			
		fi
		
		if ! (grep -q "$operador\|$codigo_postal" "$ARCH_SUCURSALES") ;
		then
			motivo="El operador con el codigo postal registrado no existe en el archivo sucursal"
			regValido=false
		else #verifico que la dupla operador-codigopostal exista en sucursal
		    while IFS=';' read -r cod_sucursal nom_sucursal domicilio_suc localidad_suc provincia_suc codigopostal_suc cod_ope_suc precio;
		    do
			if [ "$operador"=="$cod_ope_suc" ] && [ "$codigo_postal"=="$codigopostal_suc" ]
			then
				regValido=true
				log "La dupla $operador-$codigo_postal se encuentra en el archivo sucursal"
				break;
			else 
				regValido=false
  				motivo="dupla no encontrada en el archivo sucursal"
				break;
			fi
		    done < "$ARCH_SUCURSALES"

		fi
	        
		if [ "$regValido"==true ]
		then
			log "Operador:$operador Codigo Postal: $codigo_postal Numero de pieza aceptada:$nroPieza"
		else
			log "Operador:$operador Codigo Postal: $codigo_postal Numero de pieza rechazada:$nroPieza Motivo:$motivo"
		fi
		


		#si tenemos todo OK, genero o agrego registros a los archivos
		printf -v pieza '%020d' "$nroPieza"
		nombre=$(echo $apeNom | awk '$1=$1')

		printf -v nombre_pad '%48s' "$apeNom"
		printf -v doc_numero '%011d' "$nroDoc"

		archivo=$(basename "$f")
		codigo_suc_destino=$(awk -v codigo="$codigo_postal" -F "," '{ if($6 == codigo) {print $1 } }' "$ARCH_SUCURSALES")
		printf -v codigo_suc_destino '%3s' "$codigo_suc_destino"

		suc_destino=$(awk -v codigo="$codigo_postal" -F "," '{ if($6 == codigo) {print $2 } }' "$ARCH_SUCURSALES")
		printf -v suc_destino '%25s' "$suc_destino"

	        direccion_suc_destino=$(awk -v codigo="$codigo_postal" -F "," '{if($6 == codigo) {print $3 } }' "$ARCh_SUCURSALES")
		printf -v direccion_suc_destino '%25s' "$direccion_suc_destino"

		costo_entrega=$(awk -v codigo="$codigo_postal" -F "," '{ if($6 == codigo) {print $8 } }' "$ARCH_SUCURSALES")
		printf -v costo_entrega '%06d' "$costo_entrega"


		if [ "$regValido" == true ]
		then
		  	echo "$pieza-$nombre_pad-$docTipo$nroDoc$codigo_postal-$codigo_suc_destino-$suc_destino-$direccion_suc_destino-$costo_entrega$archivo" >> "$PATH_SALIDA/Entregas_$operador"
		else
		  	echo "$pieza-$nombre_pad-$doctipo$nroDoc$codigo_postal-$codigo_suc_destino-$suc_destino-$direccion_suc_destino-$costo_entrega$archivo" >> "$PATH_SALIDA/Entregas_Rechazadas"
		fi

	  done < "$f"
    #fin procesamiento movemos los archivos a procesado
	mv "$f" "$PATH_PROCESADOS"
	done
}


while true
do
	let "CICLO=CICLO+1"
	log "Voy por el ciclo: $CICLO"
        #verificandoSystemInicializado()

	
	if [ "$(ls -A "$PATH_NOVEDADES")" ]
	then	
		verificandoNombreDeArchExternos
	fi

	if [ "$(ls -A "$PATH_NOVEDADES")" ]
	then	
		validarArchivo
	fi	

	#Proceso los archivos de aceptados
	if [ "$(ls -A "$PATH_ACEPTADOS")" ]
	then	
		verificandoTrailer
	fi
	if [ "$(ls -A "$PATH_ACEPTADOS")" ]
	then	
		procesamos
	fi

	sleep 1m
done

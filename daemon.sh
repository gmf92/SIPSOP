#! /bin/bash

# RAIZ
# GRUPO=$(pwd | sed "s-\(.*Grupo01\).*-\1-")

# DIRECTORIOS RESERVADOS
CONF="$GRUPO/conf"
LOG="$CONF/log"

NOVEDADES_PATH="$NOVEDADES"
ACEPTADOS_PATH="$ACEPTADOS"
RECHAZADOS_PATH="$RECHAZADOS"
SALIDA_PATH="$SALIDA"
PROCESADOS_PATH="$PROCESADOS"
ARCHIVO_OPERADORES="$MAESTROS/operadores.txt"
ARCHIVO_SUCURSALES="$MAESTROS/sucursales.txt"
CICLO=0

log ()
{
        date +"%x %X-$USER-$1-$2-$3" >> "$LOG/proceso.log" 
}

validoNombreDeNovedades()
{
	#Mando a rechazados todos los archivos de "novedades" cuyo nombre no cumplen con el formato de entrega_mesMenorOIgualAlCorriente
	MES=`date +"%m"`
	MES=$(expr $MES + 0 )
	#MES=5
	if (( $MES < 10 ))
		then
			find "$NOVEDADES_PATH" -type f -not -name "entregas_0[1-$MES].txt" |
				while read file
				do
					if [ -f "$file" ]
					then
						log "proceso" "INF" "$file tiene un nombre incorrecto. Ha sido rechazado"
						mv "$file" "$RECHAZADOS_PATH"
					fi
				done
		fi

		if (( $MES > 9 ))
		then
			let "MES=$MES - 10"
			find "$NOVEDADES_PATH" -type f -not -name "entregas_0[1-9].txt" -and -not -name "entregas_[1][0-$MES].txt" |
				while read file
				do
					if [ -f "$file" ]
					then
						log "proceso" "INF" "$file tiene un nombre incorrecto. Ha sido rechazado"
						mv "$file" "$RECHAZADOS_PATH"
					fi
				done
		fi
}

validoNovedades()
{
	#Verifico cada archivo que quedo en el directorio de "novedades"
	#Mover al directorio aceptados o rechazados
	for f in "$NOVEDADES_PATH"/*
	do
		VALIDO=true  

		if ! [ -f $f ] 
		then
			log "proceso" "INF" "$f no es un archivo regular"
			VALIDO=false
	 	fi

	  	if ! [ -s $f ] 
		then
			log "proceso" "INF" "$f está vacio"
			VALIDO=false
		fi

		if [ -f "$PROCESADOS_PATH/$(basename "$f")" ] 
		then
			log "proceso" "INF" "$f ya ha sido procesado"
			VALIDO=false
		fi

		if [ $VALIDO = true ]
		then
			mv $f "$ACEPTADOS_PATH"
			log "proceso" "INF" "$f ha sido aceptado"
		else		
			mv $f "$RECHAZADOS_PATH"
			log "proceso" "INF" "$f ha sido rechazado"
	 	fi
	done
}

procesamiento()
{
	#Por cada archivo en el directorio de aceptados
	#Verifico que sean validos para procesar o los muevo a rechazados
	for f in "$ACEPTADOS_PATH"/* 
	do
	  #Vars para verificar si archivo debe ser movido a rechazados
	  cantidad_lineas=-1 #no se porque me cuenta una linea de mas
	  codigo_postal_suma=0
	  trailer_cantidad_lineas=0
	  trailer_codigo_postal=0
	  #leo el archivo linea por linea
	  #verifico que el codigo postal y la cant de lineas sean las correctas
	  #sino, muevo el archivo a rechazados
	  while IFS=';' read -r  operador pieza nombre doc_tipo doc_numero codigo_postal;
	  do
		let "cantidad_lineas=cantidad_lineas + 1"
		let "codigo_postal_suma=codigo_postal_suma + codigo_postal"
		trailer_codigo_postal=$codigo_postal
		trailer_cantidad_lineas=$doc_numero
	  done < $f
	  #Comparo cantidad de lineas del archivo y suma codigo postal con los trailers
	  let "codigo_postal_suma=codigo_postal_suma -trailer_codigo_postal " #le resto porque me suma el ultimo dos veces
	  if [ $cantidad_lineas -eq $trailer_cantidad_lineas ] && [ $codigo_postal_suma -eq $trailer_codigo_postal ];
	  then
		log "proceso" "INF" "El trailer de $f es correcto"
	  else
		log "proceso" "INF" "El trailer de $f es incorrecto"
		mv $f $RECHAZADOS_PATH
	  fi
	done

 	#Ya tengo los archivos validados, empiezo a procesesar
	#Es lo mismo que arriba, capaz conviene hacer todo en el mismo loop
	#PROCESANDO EL CONTENIDO DEL ARCHIVO
	for f in "$ACEPTADOS_PATH"/*
	do
	  while IFS=';' read -r  operador pieza nombre doc_tipo doc_numero codigo_postal;
	  do
		registroValido=1	  	
		#Verificar que el operador exista en archivo operadores
		if  ! ( grep -q $operador "$ARCHIVO_OPERADORES" ) ;
		then
			motivo="Su operador no se encuentra en el archivo de operadores"
			registroValido=0
		fi
		#verificar que operador codigo postal en sucursales
		if  ! ( grep -q "$operador\|$codigo_postal" "$ARCHIVO_SUCURSALES" ) ;
		then
			motivo="Operador-Codigo Postal no existe en sucursales"
			registroValido=0
		fi
		
                #Verifico si existe el OP en operadores.txt y si tiene contrato vigente
                if [ $registroValido == 1 ]
                then
                        registroValido=0
                        while IFS=';' read -r o_cod_op o_nom_op o_cuit o_fi o_ff;
                        do
                                mes_i=$(echo "$o_fi" | cut -d'/' -f2)
                                mes_f=$(echo "$o_ff" | cut -d'/' -f2)
                                mes_c=$(date +"%m")
                                if [ "$operador" == "$o_cod_op" ] && [ $mes_i -le $mes_c ] && [ $mes_f -ge $mes_c ]
                                then
                                        registroValido=1
                                        log "procesamiento" "INF" "Se encontro $operador en operadores.txt, activo desde $mes_i hasta $mes_f"
                                        break;
                                fi
                        done < "$ARCHIVO_OPERADORES"
                fi
                
                # Verifico que la dupla operador-codigo postal exista
                if [ $registroValido == 1 ]
                then
                        registroValido=0
                        while IFS=';' read -r s_cod_suc s_nom_suc s_dom s_loc s_pro s_cod_pos s_cod_op s_precio;
                        do
                                if [ "$operador" == "$s_cod_op" ] && [ "$codigo_postal" == "$s_cod_pos" ]
                                then
                                        registroValido=1
                                        log "procesamiento" "INF" "Se encontro dupla $operador-$codigo_postal en sucursales.txt"
                                        break;
                                fi
                        done < "$ARCHIVO_SUCURSALES"
                fi

		if (( registroValido  == 1 ))
		then
			log "proceso" "INF" "Pieza aceptada: $pieza Operador: $operador Codigo Postal: $codigo_postal"
		else
			log "proceso" "INF" "Pieza rechazada: $pieza Operador: $operador Codigo Postal: $codigo_postal Motivo: $motivo"
		fi

		#si ok, genero o agrego a archivo correspondiente y escribo registro en el archivo
		#completo con ceros
		printf -v pieza '%020d' $pieza
	        nombre=$(echo $nombre | awk '$1=$1')
		#completo con espacios
	       	printf -v nombre_pad '%48s' "$nombre"
		printf -v doc_numero '%011d' $doc_numero
		archivo=$(basename "$f")
	        codigo_suc_destino=$(awk -v codigo=$codigo_postal -F ";" '{ if($6 == codigo) {print $1 } }' "$ARCHIVO_SUCURSALES")
		printf -v codigo_suc_destino '%3s' $codigo_suc_destino
		suc_destino=$(awk -v codigo=$codigo_postal -F ";" '{ if($6 == codigo) {print $2 } }' "$ARCHIVO_SUCURSALES")
		printf -v suc_destino '%25s' "$suc_destino"
	        direccion_suc_destino=$(awk -v codigo=$codigo_postal -F ";" '{if($6 == codigo) {print $3 } }' "$ARCHIVO_SUCURSALES")
		printf -v direccion_suc_destino '%25s' "$direccion_suc_destino"
		costo_entrega=$(awk -v codigo=$codigo_postal -F ";" '{ if($6 == codigo) {print $8 } }' "$ARCHIVO_SUCURSALES")
		printf -v costo_entrega '%06d' $costo_entrega
		if (( registroValido  == 1 ))
		then
			echo $pieza"$nombre_pad"$doc_tipo$doc_numero$codigo_postal"$codigo_suc_destino""$suc_destino""$direccion_suc_destino"$costo_entrega$archivo >> $SALIDA_PATH/"Entregas_"$operador
		else
			echo $pieza"$nombre_pad"$doc_tipo$doc_numero$codigo_postal"$codigo_suc_destino""$suc_destino""$direccion_suc_destino"$costo_entrega$archivo >> $SALIDA_PATH/"Entregas_Rechazadas"
		fi
	  done < $f
	  #Fin proceso, mover archivo a procesado
	  mv $f $PROCESADOS_PATH

	done
}


while true
do
	let "CICLO=CICLO+1"
	log "proceso" "INF" "Nº de ciclo: $CICLO"

	#Verifico que sean validos los archivos de novedades
	#Mando a aceptados o rechazados segun corresponda
	if [ "$(ls -A "$NOVEDADES_PATH")" ]
	then	
		validoNombreDeNovedades
	fi

	if [ "$(ls -A "$NOVEDADES_PATH")" ]
	then	
		validoNovedades
	fi

	#Proceso los archivos de aceptados
	if [ "$(ls -A "$ACEPTADOS_PATH")" ]
	then	
		procesamiento
	fi

	sleep 1m
done

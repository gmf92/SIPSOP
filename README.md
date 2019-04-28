********************************************
# Sistemas Operativos - Trabajo Práctico Nº1
# Grupo 01 - 1º Cuatrimestre del 2019
********************************************

# Requisitos del Sistema
* Tener instalado Bash.


# Descarga y descompresión del sistema
* Descargar el paquete Grupo01.tgz del siguiente link: https://github.com/gmf92/SIPSOP.git
* Mover el paquete descargado a una ubicación deseada
* Con la terminal en la ubicación elegida para la instalación, ejecutar el comando: -xzvf Grupo01.tar.gz
* Con la ejecución anterior, se generará una carpeta llamadada Grupo01 en el cual en su interior se encontrará
  los archivos maestros y archivos ejecutables del sistema


# Instalación
* Abrir la consola y ubicarse en el directorio elegido. 
* Dar permiso de ejecucion al archivo "instalacion.sh" con el comando: chmod +x instalacion.sh
* Y luego ingresar: ./instalacion.sh
* Se observará una pantalla de bienvenida y se crearan las carpetas conf y log.
* Se pedira configurar los directorios de ejecutables, maestros, novedades, aceptados, rechazados, procesados, salida. Usted podrá ingresar una ruta, en caso contrario se asignará una por defecto.
* Se pedirá una confirmación. Si confirma se completará la instalación, en caso contrato se reiniciara y se pedirá nuevamente que se configuren los directorios.

(Nota: si el sistema ya ha sido correctamente instalado, la ejecución del comando ./instalacion.sh informará la situación e informará los directorios de la instalación)

* Para reparar el sistema ingrese al directorio de la instalación y ejecute el comando ./instalacion.sh -r


# Inicializacion
* Luego dirigirse al directorios de los archivos ejecutables (Por defecto ejecutables). Ej: cd ejecutables
* Dar permisos de ejecucion: chmod +x inicializacion.sh
* Y el comando: source inicializacion.sh
* El programa cumple con las siguientes funciones:

         - Chequea que los directorios existan, en caso contrario lanza una advertencia 
         - Se le otorga los permisos correspondientes a los directorios maestros y ejecutables


# Uso
* Para iniciar el proceso daemon, ubicado en el directorio ejecutables, ingrese el comando ./START.SH el cual pondra en funcionamiento el proceso daemon, siempre y cuando estén dadas las condiciones (variables inicializadas, directorios y archivos maestros disponibles/accesibles). En caso de que ya se encuentre un proceso daemon corriendo, no se correra uno adicional y se informará de la situación.
* Con el proceso daemon funcionando, se puede detener desde el mismo directorio de ejecutables y escribiendo el comando ./STOP.SH el cual informa si sea ha detenido el proceso o si no había proceso funcionando que detener.
* Para procesar archivos debe colocar los archivos de entregas dentro del directorio novedades.


# Estructuras
* maestros/Operadores.txt
* maestros/Sucursales.txt
* Grupo01/conf/tpconfig.txt

# Listado de archivos de prueba dados por la cátedra
* entregas_07.txt
* entregas_08.txt
* entregas_09.txt
* entregas_10.txt
* entregas_11.txt

# Listado de archivos de prueba del grupo
RECHAZADOS POR TENER UN MAL NOMBRE


RECHAZADOS POR ESTAR VACIO


RECHAZADO POR SER UN PDF


RECHAZADO POR TRAILER INCORRECTO



- Entregas_09.txt No posee trailer Incorrecta sumatoria de codigo postal


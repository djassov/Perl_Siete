#!/usr/bin/perl
use DBI;
use File::Find;
use File::stat;
use Time::Local;
use File::Copy;

#--------+       
#--------+       Declaracion de Variables
#--------+       
$debug=0;
$Errores=0;  
$dir_proceso=`pwd`;
$dir_proceso=~s/(\r|\n)*$//;

$proceso_id = shift;
$proceso_actual="Proceso ".$proceso_id;

#--------+       
#--------+       Calcula el dia de ayer (no se para que)
#--------+       

$today = timelocal(localtime);
$dias=1;
$dias=$dias*24;
@yesterday = localtime($today - ($dias * 60 * 60));

$year  = (@yesterday)[5] + 1900;
$month = (@yesterday)[4] + 1;
if(length($month)<2){$month="0$month";}
$day   = (@yesterday)[3];
if(length($day)<2){$day="0$day";}


#--------+       
#--------+       Calcula la fecha del proceso 
#--------+       

use Time::localtime;

$tiempo=localtime;
$dia=$tiempo->mday;
if(length($dia)<2){$dia="0".($tiempo->mday);}
$mes=($tiempo->mon+1);
if(length($mes)<2){$mes="0".($tiempo->mon+1);}
$ano=($tiempo->year+1900);
$fecha_sistema="$dia-$mes-$ano";
$FechaProceso=$ano.$mes.$dia;


#--------+       
#--------+       Calcula la hora del proceso 
#--------+       

$segundo=$tiempo->sec;
if(length($segundo)<2){$segundo="0".$tiempo->sec;}
$minuto=$tiempo->min;
if(length($minuto)<2){$minuto="0".$tiempo->min;}
$hora=$tiempo->hour;
if(length($hora)<2){$hora="0".$tiempo->hour;}
$hora_sistema="$hora:$minuto:$segundo";

$date_proceso="$fecha_sistema $hora_sistema";

$date_proceso="$ano-$mes-$dia $hora_sistema";
#--------+       
#--------+       Calcula el nombre del archivo LOG 
#--------+       

$nombrearchivoLOG=$proceso_id."-".$ano.$mes.$dia.$hora.$minuto.$segundo.".log";

#--------+       
#--------+       Crea un archivo para guardar mensajes de error del proceso 
#--------+       

$archivoerror=$dir_proceso."/ERROR_Proceso_". $proceso_id .".err";
$correo_error="gserna\@7-eleven.com.mx";

open(ERROR,"> $archivoerror");

#--------+       
#--------+       Valido los parametros de entrada 
#--------+

if(!$proceso_id)
{
  print "° Dede proporcionar el ID del proceso a correr !";
  print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
  print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
  print ERROR "\nNo se proporcionaron los parametros adecuados.";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\n_clave";
  close(ERROR);
  #system ("bash $archivoerror");
  exit();
}


#--------+       
#--------+       Obtiene datos de configuracion 
#--------+       

$archivo_pm="pm.ini";
$sia=open(PM,"<$archivo_pm");
if($sia==0)
{
  $debug && print "° NO está el archivo de  información inicial !";
  print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
  print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
  print ERROR "\nNo existe archivo de configuracion inicial.";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\n_clave";
  close(ERROR);
  #system ("bash $archivoerror");
  exit();
}
@lineaa=<PM>;
close(PM);

#--------+       
#--------+       Datos de conexion a la base de datos 
#--------+       (contenidos en archivo de configuracion)
#--------+       
$v0="db=";
$v1="conexion=";
$v2="usuario=";
$v3="clave=";
foreach $l(@lineaa){
  
  if(index($l,$v0)>=0){$variableDB=trim(substr($l,length($v0))); }
  if(index($l,$v1)>=0){$variableDSN=trim(substr($l,length($v1))); }
  if(index($l,$v2)>=0){$usuario=trim(substr($l,length($v2))); }
  if(index($l,$v3)>=0){$password=trim(substr($l,length($v3))); }
}

$variableDB ="Oracle" if $variableDB eq "";

if("$variableDSN" eq "" || $usuario eq "" || $password eq "")
{
  $debug && print "° No hay información válida en el archivo de información inicial !";
  print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
  print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
  print ERROR "\nNo hay informacion en el archivo de configuracion inicial.";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\n_clave";
  close(ERROR);
  #system ("bash $archivoerror");
  exit();
}

#--------+       
#--------+       Conexion a la base de datos 
#--------+       

$conexione = DBI->connect ("dbi:$variableDB:$variableDSN","$usuario","$password");

#                          or die "NO SE PUEDE CONECTAR CON LA BASE DE DATOS ";
if(! $conexione)
{
  print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
  print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
  print ERROR "\nNO SE PUDO CONECTAR CON LA BASE DE DATOS...";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\n_clave";

  print ERROR "\nmail \"5120338\" mail\@radiobeep\.com\.mx \<\<\_clave";
  print ERROR "\nPROCESO DE VALIDACION DE $proceso_actual...";
  print ERROR "\nNO SE PUDO CONECTAR CON LA BASE DE DATOS...";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\n_clave";

  close(ERROR);
  #system ("bash $archivoerror");
  exit();
}

#--------+       
#--------+       Query a tabla de parametros
#--------+       
$debug && print "SELECT * FROM apps.procesos where id=".$proceso_id;

$conexion=$conexione->prepare("SELECT * FROM apps.procesos where id=".$proceso_id);
$conexion->execute;
if ($fila = $conexion->fetchrow_hashref())
{
  $proceso_nombre=trim($fila->{'nombre'});
  $proceso_prefijo=trim($fila->{'prefijo'});
  $proceso_path=trim($fila->{'path_dir'});
  $proceso_filename=trim($fila->{'filename'});
  
  $proceso_header_tienda=trim($fila->{'header_tienda'});
  $proceso_longitud_hr=trim($fila->{'longitud_hr'});
  
  $proceso_header_recepcion=trim($fila->{'header_recepcion'});
  $proceso_longitud_hr=trim($fila->{'longitud_hr'});
  
  $proceso_articulo=trim($fila->{'articulo'});
  $proceso_longitud_articulo=trim($fila->{'longitud_articulo'});
  
  $proceso_lineasmin=trim($fila->{'lineas_minimas'});
  $proceso_softerror=trim($fila->{'softerror'});
  
  $nombrearchivoLOG=$proceso_prefijo.$nombrearchivoLOG;
  $proceso_actual=$proceso_nombre;
  
}
else
{
    $debug && print "Faltan parámetros";
    print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
    print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
    print ERROR "\nNo hay informacion en LA TABLA DE PARAMETROS.";
    print ERROR "\n$fecha_sistema *** $hora_sistema";
    print ERROR "\n_clave";
    close(ERROR);
    #system ("bash $archivoerror");
    exit();
}



$path_lock=$dir_proceso."/locks/";
$archivo_lock=$proceso_prefijo.$FechaProceso.".lock";

$DIRECTORIO_BITACORAS="logs";


#--------+       
#--------+       Abre LOG
#--------+       

open(LOG, ">> $DIRECTORIO_BITACORAS/$nombrearchivoLOG");

print LOG "-----------------------------------------------------------\n";
print LOG "\nCONSOLIDACION DE $proceso_actual";
print LOG "\n$fecha_sistema  $hora_sistema";
print LOG "\n";

$debug && print "\n1*$path_lock*";
$debug && print "\n2*$archivo_lock*";
$debug && print "\n3*$proceso_path*";
$debug && print "\n ENCONTRADO";
$debug && print "\n4*$DIRECTORIO_BITACORAS*";
$debug && print "\nFecha: $fecha_sistema";
$debug && print "\n";


#--------+       
#--------+       Verifica si existe archivo candado
#--------+       

chdir("$path_lock");
if(-e "$archivo_lock")
{
  $debug && print "\nSe ha detectado a otro proceso en ejecución";
  print LOG "\n    Proceso abortado, otro proceso se estaba ejecutando.";
  print LOG "\n    Se encontro archivo candado.";
  print LOG "\n-----------------------------------------------------------";
  print LOG "\n  $path_lock                      $archivo_lock";
  print LOG "\n-----------------------------------------------------------";
  $debug && print "\nERROR candado encontrado $path_lock $archivo_lock";
  close(LOG);
  
  print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
  print ERROR "\nPROCESO QUE CONSOLIDA LAS $proceso_actual...";
  print ERROR "\n$fecha_sistema *** $hora_sistema";
  print ERROR "\nERROR SE ENCONTR” EL ARCHIVO DE CANDADO.";
  print ERROR "\n_clave";

  close(ERROR);
  #system ("bash $archivoerror");
  exit();
}
else
{
  $nombredelcandado1="$archivo_lock";
  open(CANDADO, ">> $path_lock/$nombredelcandado1");
  close(CANDADO);
}

#Abro el directorio donde se encuentran los archivos
#para tomar el listado de archivos
$abc=chdir("$proceso_path");
  if($abc==0)
  {
    print LOG "\n      No existe la carpeta del proceso : $proceso_path ...";
    #Salidalimpia.
  }
  
   #mi variable de salida
        %salida=();
        %salida_err=();
        $salir_archivo=0;
        
   @archivos=(<*.*>);
   
   foreach $a(@archivos){
    
    if ($salir_archivo) {
      $salir_archivo=0;
      next;
    }
    
    $debug && print $a."\n";
    
    if ($a=~ /$proceso_filename/) {
      print LOG "\n\n    Procesando Archivo: $a ...\n";
      $debug && print "\n    Procesando Archivo: $a ...\n";
      
      if (open(CONTENIDO,"<$a")) {
        @lineas=<CONTENIDO>;
        close CONTENIDO;
        
       #Verifico el tamaño del archivo (contenido >0)
        $TotalLineas=$#lineas+1;
    
         if($TotalLineas eq 0)
         {
          print LOG "ERROR: El archivo $a esta vacio. se renombra a $a.err\n\n";
          $debug && $debug && print "ERROR: El archivo $a esta vacio. se renombra a $a.err\n\n";
          
          print ERROR "ERROR: El archivo $a esta vacio. se renombra a $a.err\n\n";
           $a_err=$a."err";
           rename("$a", "$a_err");
           $Errores++;
           
           next;
         }
          if ($proceso_lineasmin >0) {
          
            if($TotalLineas < $proceso_lineasmin)
            {
              print LOG "ERROR: El archivo $a no cumple con la cantidad mínima de líneas. Se renombra a  $a.err_lm\n\n";
              $debug && $debug && print "ERROR: El archivo $a no cumple con la cantidad mínima de líneas. Se renombra a  $a.err_lm\n\n";
              
              print ERROR "ERROR: El archivo $a no cumple con la cantidad mínima de líneas. Se renombra a  $a.err_lm\n\n";
               $a_err=$a."err_lm";
               rename("$a", "$a_err");
               $Errores++;
               
               next;
            }  
          }

       #----------------------------------------------
        
        # Verifico cada linea para saber que tipo es
        # Verifico tambien el tamaño de la linea
        #
        
        foreach $renglon(@lineas){
          $renglon=~s/(\r|\n)*$//;
        
          
          
         $debug && print $renglon."\n";
         
          if($renglon =~/$proceso_header_tienda/){
            
            $HT_error=0;
            #Valido la longitud del registro, si está definida
            if ($proceso_longitud_ht >0) {
            
              #Si son de diferente longitud, lo marco como error
              if ( length($renglon) != $proceso_longitud_ht) {
            
                #Verifico el tipo de error a generar, si termina el archivo o solo las lineas mal formadas.
                if ($proceso_softerror) {
                  #Guardo esta linea y continuo con el proceso
                  #Coloco una bandera para decir que tengo un error en HT
                  $HT_error = 1;
                  $ht=$renglon;
                  $salida_err{$ht}=();
                  $salida_err{"err_".$ht}=1;
                  next;
                  
                }else{
                  #termino con el archivo y lo marco con error.
                  $HT_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                  
                }
                
              }
              
            }
            
            if(exists $salida{$renglon}){
              # Ya existe este header
            }
            else{
              $debug && print "Es header tienda\n";
              $ht=$renglon;
              $salida{$ht}=();
              $salida_err{$ht}=();
            }
            
          }elsif($renglon =~/$proceso_header_recepcion/){
            
            $HR_error=0;
            #Valido la longitud del registro, si está definida
            if ($proceso_longitud_hr >0) {
            
              #Si son de diferente longitud, lo marco como error
              if ( (length($renglon) != $proceso_longitud_hr) || $HT_error) {
            
                #Verifico el tipo de error a generar, si termina el archivo o solo las lineas mal formadas.
                if ($proceso_softerror) {
                  #Guardo esta linea y continuo con el proceso
                  #Coloco una bandera para decir que tengo un error en HR
                  $HR_error = 1;
                  $hr=$renglon;
                  $salida_err{$ht}{$hr}=0;
                  $salida_err{$ht}{"err_".$hr}=1 if ( (length($renglon) != $proceso_longitud_hr));
                  next;
                  
                }else{
                  #termino con el archivo y lo marco con error.
                  $HR_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                  
                }
                
              }
              
            }
            
            if(exists $salida{$ht}{$renglon}){
              # Error, ya existe este header Recepcion
            }
            else{
              $debug && print "Es header Recepcion\n";
              $hr=$renglon;
              $salida{$ht}{$hr}=0;
              $salida_err{$ht}{$hr}=0;
            }
            
          }elsif($renglon =~/$proceso_articulo/){
            
            $ART_error=0;
            #Valido la longitud del registro, si está definida
            if ($proceso_longitud_articulo >0) {
            
              #Si son de diferente longitud, lo marco como error
              if ( (length($renglon) != $proceso_longitud_articulo)  || $HT_error || $HR_error) {
            
                #Verifico el tipo de error a generar, si termina el archivo o solo las lineas mal formadas.
                if ($proceso_softerror) {
                  #Guardo esta linea y continuo con el proceso
                  #Coloco una bandera para decir que tengo un error en Articulo
                  $ART_error = 1;
                  $salida_err{$ht}{$hr}++ if (length($renglon) != $proceso_longitud_articulo);
                  print "\n$ht | $hr | $renglon\n";
                  print "$HT_error | $HR_error | $ART_error";
                  next;
                  
                }else{
                  #termino con el archivo y lo marco con error.
                  $ART_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                  
                }
                
              }
              
            }
            
            $debug && print "Es articulo \n";
              $salida{$ht}{$hr}++;
            }
          
            
        } #Fin Foreach de renglones
      }else{
        $debug && print "No se pudo abrir el archivo $a n";
      } #Fin de apertura de archivo
      
      
      
      
      
    
    
        
       print LOG "\nResultados archivo $a  \n";
       $proceso_plaza='\.(\d\d\d)';
       if($a=~/$proceso_plaza/){
        $plaza=$1;
       }
       foreach $s_tienda(keys %salida){
        
        foreach $s_recepcion(keys %{$salida{$s_tienda}}){
          print LOG "$s_tienda | ";
          print LOG "$s_recepcion | ";
          print LOG $salida{$s_tienda}{$s_recepcion}."\n";
          $cantidad=$salida{$s_tienda}{$s_recepcion};
          #manejamos los errores
          $err_art=0;
          $err_art=$salida_err{$s_tienda}{$s_recepcion} if (exists $salida_err{$s_tienda}{$s_recepcion});
          
          $err_ht=0;
          $err_ht=$salida_err{"err_".$s_tienda} if (exists $salida_err{"err_".$s_tienda});
          
          $err_hr=0;
          $err_hr=$salida_err{$s_tienda}{"err_".$s_recepcion} if (exists $salida_err{$s_tienda}{"err_".$s_recepcion});
          
          
          $query="INSERT INTO apps.procesados values(null,$proceso_id,'$proceso_nombre','$plaza','$a','$date_proceso','$s_tienda','$s_recepcion',$cantidad,$err_ht,$err_hr,$err_art)";
          $conexion4=$conexione->prepare($query);
          $conexion4->execute;
        }
        
       }
   
      %salida=();
      %salida_err=();
    
    } #Fin de if de nombre
    
   } #Fin de listado de archivos
   
   
  


#verificar si no han sido procesadas
#abrir archivo
#validar nombre de archivo
#leer linea por linea
#si es header tienda (HT), guardarlo en variable de hash (Hash{$HT}) (Validar longitud)
#Si es Header Recepción, guardarlo en variable de hash(Hash{$HT}{$HR}) (Validar longitud)
#Si es articulo, sumarlo al hash  Hash{$HT}{$HR}++ (Validar longitud)
#Marcar archivo como procesado
#Guardar hash
#siguiente




##--------+       
##--------+       Abre el archivo que contiene los encabezados de las liquidaciones  
##--------+       que ya fueron consolidadas y esta pendiente de cargarse a PDI (de lectura),
##--------+       su contenido lo pasa a un arreglo y cierra el archivo.
#
#$LiqLeidas="$DIRECTORIO_BITACORAS/$proceso_actualLeidas.txt";
#open(ParaRevisar,"< $LiqLeidas");
#
#@EncLiqPendientes=<ParaRevisar>; 
#close(ParaRevisar);
#
##--------+       
##--------+       Abre nuevamente el archivo que contiene los encabezados de las liquidaciones  
##--------+       para agregar aquellas que pasen las validaciones y sean agregadas al archivo 
##--------+       consolidado de liquidaciones.
#
#$LiqLeidas="$DIRECTORIO_BITACORAS/$proceso_actualLeidas.txt";
#open(ParaRevisar,">> $LiqLeidas");
#
##--------+       
##--------+       Query que trae la lista de tiendas a procesar
##--------+       
#
#$conexion2=$conexione->prepare("SELECT DISTINCT tienda,division,cat_path,cat_archivo 
#FROM apps.vst_7e_tiendas ,apps.cat_plazas 
#WHERE UPPER(cat_plaza) = UPPER(division) AND id_tienda > 0 AND substr(tienda,1,1) < '2' 
#AND UPPER(campo) NOT LIKE '%APERTURAS%' ORDER BY division,tienda");
#
#$conexion2->execute;
#
#$indice=0;
#$indice2=0;
#
##--------+       
##--------+       Inicia ciclo para procesar cada una de las tiendas
##--------+       
#
#while (@fila = $conexion2->fetchrow_array)
#{
#  $debug && print "Inicio ciclo $indice-$indice2";
#
##--------+        
##--------+       Modificado el 23 Ene 2008
##--------+       para soportar numeros de 
##--------+       tienda con 4 digitos
##--------+       GSC
#
##--------+        se agrega la siguiente linea
#
#  $_numtda=substr(trim($fila[0]), 0, 4);
#
##--------+        Original-> $tienda_a_procesar[$indice][1] = "TDA".substr(trim($fila[0]),1,3);
##--------+        sustituido por:
#
#  $tienda_a_procesar[$indice][1] = sprintf "TDA%03d", $_numtda;
#
#  $tienda_a_procesar[$indice][2] = trim($fila[1]);
#  $tienda_a_procesar[$indice][3] = trim("$fila[2]")."/".trim("$fila[3]");
#
#  print LOG "\n\n    Procesando Tienda: $tienda_a_procesar[$indice][1] ...";
#
##--------+       
##--------+       1.- TIENDA
##--------+       2.- DIVISION
##--------+       3.- PATH y archivo de salida
##--------+       Forma el nombre de la carpeta que contiene los archivos a concatenar 
##--------+       para la tienda que se esta procesando
##--------+       
#
#  $carpeta="RECV";
#
#  $abc=chdir("$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta");
#  if($abc==0)
#  {
#    print LOG "\n      No existe la carpeta para esta tienda: $tienda_a_procesar[$indice][1] ...";
#    $indice++;
#    next;
#  }
#
##--------+       
##--------+       Crea una array con los archivos cuya extension sea PDI
##--------+       
#
#  @archivos=(<*.[p|P][d|D][i|I]>);
#  $indice2=0;
#
##--------+       
##--------+       Inicia ciclo para procesar cada uno de los archivos contenidos en 
##--------+       la carpeta de la tienda
##--------+       
#
#  foreach $a(@archivos){
#    print LOG "\n      Procesando archivo: $a";
#    $debug && print "\nLectura de archivo válido +$a+ +++++++++++++++++++ $indice-$indice2 TIENDA: $tienda_a_procesar[$indice][1]";
#    $fecha_corte=substr($a,0,2)."-".substr($a,2,2)."-".substr($a,4,4);
#    $archivo_a_procesar[$indice2][1]=trim($a);
#    $fecha_archivo=substr($archivo_a_procesar[$indice2][1],0,2)."-".substr($archivo_a_procesar[$indice2][1],2,2)."-".substr($archivo_a_procesar[$indice2][1],4,4);
#
#    $debug && print "\nAbre el archivo de liquidación... $indice-$indice2";
#    $car=open(CONTIENE,"<$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$archivo_a_procesar[$indice2][1]");
#    if($car==0){$debug && print "\n$tienda_a_procesar[$indice][1] - No se pudo abrir el archivo: $archivo_a_procesar[$indice2][1]...";$indice2++;next;}
#    @contenido_archivo=<CONTIENE>; #CARGA EL CONTENIDO EN UN ARREGLO
#    close(CONTIENE);
#
##--------+       
##--------+       Lee el archivo para identificar tienda y fecha de la liquidacion
##--------+       
#
#    $fecha_liq_archivo=substr(trim($contenido_archivo[0]),4,8);
#    $Fecha_Liquidacion=substr($fecha_liq_archivo,0,4).substr($fecha_liq_archivo,4,2).substr($fecha_liq_archivo,6,2);
#    $fecha_liq_archivo=substr($fecha_liq_archivo,6,2)."-".substr($fecha_liq_archivo,4,2)."-".substr($fecha_liq_archivo,0,4);
#
#    $tienda_archivo=sprintf "TDA%03d", substr(trim($contenido_archivo[0]),12,4);
#
##--------+       
##--------+       Verifica que el archivo tenga al menos 8 renglones
##--------+       $proceso_actual con menos de 8 renglones seran consideradas como incompletas
##--------+       
#
#     $TotalLineas=$#contenido_archivo+1;
#
#     if($TotalLineas eq 0)
#     {
#       $debug && print "*$tienda_a_procesar[$indice][1]*$tienda_archivo*";
#       $debug && print "\nSe detectó que la liquidacion no esta completa...";
#       print ERROR "ERROR: El archivo de liquidacion esta vacio. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: El archivo de liquidacion vacio. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)";
#       $indice2++;
#       next;
#     }
#
#     if($TotalLineas < 8)
#     {
#       $debug && print "*$tienda_a_procesar[$indice][1]*$tienda_archivo*";
#       $debug && print "\nSe detectó que la liquidacion no esta completa...";
#       print ERROR "ERROR: El archivo de liquidacion esta incompleto. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a $TotalLineas )\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: El archivo de liquidacion esta incompleto. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)";
#       $indice2++;
#       next;
#     }
#
##--------+       
##--------+       Verifica que el numero de tienda contenido en el archivo
##--------+       sea igual al numero de tienda al que corresponde la carpeta
##--------+       
#
#     if($tienda_a_procesar[$indice][1] ne $tienda_archivo)
#     {
#       $debug && print "*$tienda_a_procesar[$indice][1]*$tienda_archivo*";
#       $debug && print "\nSe detectó un error, no coinciden la tienda con el archivo de liquidación...";
#       print ERROR "ERROR: No coinciden la tienda (nombre de carpeta) con el archivo de liquidación. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a Checar $tienda_archivo)\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: No coinciden la tienda (nombre de carpeta) con el archivo de liquidación. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)";
#       $indice2++;
#       next;
#     }
#
##--------+       
##--------+       Verifica que la fecha contenida en el archivo sea igual a la
##--------+       que corresponde al nombre del archivo
##--------+       
#
#     if($fecha_archivo ne $fecha_liq_archivo)
#     {
#       $debug && print "\nSe detectó un error, no coinciden la fecha del archivo con la de liquidación...";
#       print ERROR "ERROR: No coinciden la fecha del archivo con la de liquidación. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: No coinciden la fecha del archivo con la de liquidación. (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)";
#       $indice2++;
#       next;
#     }
#
##--------+       
##--------+       Verifica que la fecha contenida en el archivo sea menor al
##--------+       dia del proceso, esto es, que la fecha de la liquidacion no sea del
##--------+       dia de hoy o posterior. Si la liquidacion tiene error entonces es renombrada
##--------+       a .err. Por ejemplo: 14052009.pdi se renombra como 14052009.pdi.err
##--------+       
#
#     if($Fecha_Liquidacion ge $FechaProceso)
#     {
#       $debug && print "\nERROR: La fecha de la liquidacion es igual o posterior al dia de hoy.";
#       print ERROR "\nERROR: La fecha de la liquidacion es igual o posterior al dia de hoy. \n La liquidacion es renombrada a .err (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: La fecha de la liquidacion es igual o posterior al dia de hoy.";
#       $indice2++;
#       next;
#     }
#
##--------+       
##--------+       Verifica que la liquidacion no este contenida en el archivo consolidado que
##--------+       esta pendiente por cargar. Para eso, busca el encabezado de la liquidacion 
##--------+       en el arreglo que contiene los encabezados de las liquidaciones pendientes
##--------+       por cargar
##--------+       
#
#     $EstaDuplicada="No";
#     foreach $EncLiquidacion (@EncLiqPendientes){
#       if(index($EncLiquidacion,$contenido_archivo[0])>=0){
#         $debug && print "\nERROR: La liquidacion fue trasmitida dos veces en un periodo muy corto de tiempo, la segunda es liquidacion es ignorada.";
#         print ERROR "\nERROR: La liquidacion fue trasmitida dos veces en un periodo muy corto de tiempo, la segunda es liquidacion es ignorada. \n La liquidacion es renombrada a .err (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)\n      La liquidacion fue renombrada a .err\n\n";
#         $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#         $liq_err=$liq_orig."err";
#         rename("$liq_orig", "$liq_err");
#         $Errores++;
#         print LOG "\n      ERROR: La liquidacion fue trasmitida dos veces en un periodo muy corto de tiempo, la segunda es liquidacion es ignorada.";
#         $indice2++; 
#         $EstaDuplicada="Si";
#       }
#     }
#     if($EstaDuplicada eq "Si") { next; }
#
##--------+       
##--------+       Verifica que los renglones de la liquidacion de ventas tengan 114 caracteres 
##--------+       exactamente. Con esto, se evita la carga de liquidaciones donde no aparece
##--------+       algun caracter (Problema de liquidaciones incompletas).
##--------+       1000 = Indica que este registro es de la liquidacion de ventas
##--------+       114 = La longitud del registro.
##--------+       41 = Existen registros equivocados pero que no afectan la carga de datos
##--------+            Estos registros tienen un Enter.
##--------+       
#
#
#     $ConError="No";
#     foreach $Renglon(@contenido_archivo){
#       $TipoRegistro=substr($Renglon,0,4);
#       if($TipoRegistro=="1000"){
#         if(length($Renglon)!=114) {
#           if(length($Renglon)!=41) {
#             $Signo=substr($Renglon, 110, 1);
#             if($Signo eq "+") {
#               $ConError="Si";
#               $Largo=length($Renglon);
#               $debug && print "$Largo \n";
#             }
#           }
#         }
#       }
#     }
#     if($ConError eq "Si"){ 
#       $debug && print "\nERROR: La liquidacion tiene al menos un registro incompleto.";
#       print ERROR "\nERROR: La liquidacion tiene al menos un registro incompleto. \n La liquidacion es renombrada a .err (Tienda $tienda_a_procesar[$indice][1] Archivo: $a)\n      La liquidacion fue renombrada a .err\n\n";
#       $liq_orig=$proceso_path."/".$tienda_a_procesar[$indice][1]."/".$carpeta."/".$archivo_a_procesar[$indice2][1];
#       $liq_err=$liq_orig."err";
#       rename("$liq_orig", "$liq_err");
#       $Errores++;
#       print LOG "\n      ERROR: La liquidacion tiene al menos un registro incompleto.";
#       $indice2++; 
#       next; 
#     }
#
##--------+       
##--------+       Agrega encabezado de la liquidacion a Archivo de $proceso_actual Consolidadas...
##--------+       
#
#     print ParaRevisar $contenido_archivo[0];
#
#
##--------+       
##--------+       AquÌ va la concatenación...
##--------+       
#
#     $contiene="@contenido_archivo";
#     $debug && print "\nAbre el archivo al que se concatenará la liquidación... $indice-$indice2";
#
#     open (CONCATENA, ">> $tienda_a_procesar[$indice][3]");
#     $contiene=join('',@contenido_archivo);
#     $contiene=~s///g;
#
#     print CONCATENA $contiene;
#     close(CONCATENA);
#
#     $debug && print "\nCierra el archivo al que se concatenará la liquidación... $indice-$indice2";
#
##--------+       
##--------+       Respalda el archivo en la carpeta de procesados...
##--------+       
#
#     $procesado="PROCESADOS";
#     $abc=chdir("$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$procesado");
#     if($abc==0)
#     {
#       print LOG "\n      No existe la carpeta de procesados, se creará para la tienda: $tienda_a_procesar[$indice][1] ...";
#       mkdir("$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$procesado");
#     }
#     $debug && print "\nCopia archivo...";
#     copy ("$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$archivo_a_procesar[$indice2][1]","$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$procesado/");
#     unlink("$proceso_path/$tienda_a_procesar[$indice][1]/$carpeta/$archivo_a_procesar[$indice2][1]");
#
##--------+       
##--------+       Borra registro en tabla de liquidaciones pendientes...
##--------+       
#
#     $debug && print "\nBorrando registro... $indice-$indice2";
#
#     $conexion3=$conexione->prepare("DELETE FROM apps.vigencia_liquida WHERE UPPER(liq_tienda)='".$tienda_a_procesar[$indice][1]."' AND liq_fecha='".$fecha_corte."'");
#     $conexion3->execute;
#
#     $status="REPORTADO";
#     $justifica="*";
#
##--------+       
##--------+       Actualiza tabla de historial...
##--------+       
#
#     $debug && print "\nInsertando registro en historial... $indice-$indice2";
#     $conexion4=$conexione->prepare("INSERT INTO apps.historial_liquida ( hl_tienda, hl_fecha, hl_status, hl_justifica, hl_fecha_carga ) VALUES('".$tienda_a_procesar[$indice][1]."','".$fecha_corte."','".$status."','".$justifica."','".$fecha_sistema."')");
#     $conexion4->execute;
#     $indice2++;
#     $debug && print "\n********************************************************" ;
#  } #--------+       Fin del ciclo de archivos
#  if($indice2==0){
#    $debug && print "\nNo se encontraron registros o archivos en esta carpeta: $tienda_a_procesar[$indice][1]";
#    print LOG "\n    No se encontraron registros o archivos en esta carpeta: $tienda_a_procesar[$indice][1]";
#  }
#  $indice++;
#} #--------+       Fin del ciclo de tiendas

  print LOG "\n";

#--------+       
#--------+       Elimina archivo candado...
#--------+       

chdir("$path_lock");
unlink("$archivo_lock");

#--------+       
#--------+       Se escriben datos finales en LOG...
#--------+       

$tiempo=localtime;
$segundo=$tiempo->sec;
if(length($segundo)<2){$segundo="0".$tiempo->sec;}
$minuto=$tiempo->min;
if(length($minuto)<2){$minuto="0".$tiempo->min;}
$hora=$tiempo->hour;
if(length($hora)<2){$hora="0".$tiempo->hour;}
$hora_sistema="$hora:$minuto:$segundo";

print LOG "\n\nHora de fin de proceso  $hora_sistema...";
print LOG "\n-----------------------------------------------------------";
$debug && print "\nFIN DE PROCESO...";

#--------+       
#--------+       Se cierran archivos Log, de errores y de encabezados de liquidaciones leidas...
#--------+       

close(ERROR);
close(LOG);
close(ParaRevisar);

#--------+       
#--------+       Se envia log y errores que reportar por correo electronico...
#--------+       

$ArchivoCorreo=$dir_proceso."/Correo.sh";
$ListaCorreoLog="gserna\@7-eleven.com.mx";
$ListaCorreoErr="gserna\@7-eleven.com.mx, jlealvil\@7-eleven.com.mx, ncontreras\@7-eleven.com.mx, pquintan\@7-eleven.com.mx";
$Asunto="\"Log consolidacion de liquidacion electronica.\"";
open(Correo,"> $ArchivoCorreo");
# Se cancela la linea que envia el correo electronico con el log para dejar solo los errores
# print Correo "\necho \| mutt -s $Asunto -i $DIRECTORIO_BITACORAS/$nombrearchivoLOG $ListaCorreoLog";

if($Errores>0)
{
  $Asunto="\"Errores en carga de liquidacion electronica\"";
  print Correo "\necho \| mutt -s $Asunto -i $archivoerror $ListaCorreoErr";
}

close(Correo);

if($Errores>0)
{
    system ("bash $ArchivoCorreo");
}
unlink("$ArchivoCorreo");

##############################################################
##############################################################

##### FUNCIONES #####
#*******************************************************************************
#SUBRUTINA PARA QUITAR ESPACIOS DE LOS LADOS
sub trim {
   my($string)=@_;
   for ($string) {
       s/^\s+//;
       s/\s+$//;
   }
   return $string;
}#FIN SUB
#FINALIZA LA SUBRUTINA
#*******************************************************************************

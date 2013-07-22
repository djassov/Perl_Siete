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
$mover=1;  #Esta bandera sirve para saber si hay que mover los archivos una vez terminado el proceso.
$debug_vars=0;
$dir_proceso=`pwd`;
$dir_proceso=~s/(\r|\n)*$//;

$proceso_id = shift;
$proceso_actual="Proceso ".$proceso_id;

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

$archivoerror=$dir_proceso."/errors/ERROR_Proceso_". $nombrearchivoLOG .".err";
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
$v4="tabla_procesos=";
$v5="tabla_procesados=";
$v6="tabla_error=";
$v7="tabla_plazas=";


#Defino las variables de config
$variableDB="";
$variableDSN="";
$usuario="";
$password="";
$tabla_procesos="";
$tabla_procesados="";
$tabla_error="";
$tabla_plazas="";
  

foreach $l(@lineaa){
  
  if(index($l,$v0)>=0){$variableDB=trim(substr($l,length($v0))); }
  if(index($l,$v1)>=0){$variableDSN=trim(substr($l,length($v1))); }
  if(index($l,$v2)>=0){$usuario=trim(substr($l,length($v2))); }
  if(index($l,$v3)>=0){$password=trim(substr($l,length($v3))); }
  if(index($l,$v4)>=0){$tabla_procesos=trim(substr($l,length($v4))); }
  if(index($l,$v5)>=0){$tabla_procesados=trim(substr($l,length($v5))); }
  if(index($l,$v6)>=0){$tabla_error=trim(substr($l,length($v6))); }
  if(index($l,$v7)>=0){$tabla_plazas=trim(substr($l,length($v7))); }
  

}

$variableDB ="Oracle" if $variableDB eq "";

if("$variableDSN" eq "" || $usuario eq "" || $password eq "" || $tabla_procesos eq "" || $tabla_procesados eq "" || $tabla_error eq "" || $tabla_plazas eq "" )
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
$debug && print "SELECT * FROM $tabla_procesos where id=".$proceso_id;

$conexion=$conexione->prepare("SELECT * FROM $tabla_procesos where id=".$proceso_id);
$conexion->execute;

if ($fila = $conexion->fetchrow_hashref())
{
  $proceso_nombre=trim($fila->{'nombre'});
  $proceso_prefijo=trim($fila->{'prefijo'});
  $proceso_path=trim($fila->{'path_dir'});
  $proceso_filename=trim($fila->{'filename'});
  
  $proceso_header_tienda=trim($fila->{'header_tienda'});
  $proceso_longitud_ht=trim($fila->{'longitud_ht'});
  
  $proceso_header_recepcion=trim($fila->{'header_recepcion'});
  $proceso_longitud_hr=trim($fila->{'longitud_hr'});
  
  $proceso_articulo=trim($fila->{'articulo'});
  $proceso_longitud_articulo=trim($fila->{'longitud_articulo'});
  
  $proceso_lineasmin=trim($fila->{'lineas_minimas'});
  $proceso_softerror=trim($fila->{'softerror'});
  
  $proceso_plaza=trim($fila->{'plaza'});
  $proceso_path_procesados=trim($fila->{'path_procesados'});
  
  $nombrearchivoLOG=$proceso_prefijo.$nombrearchivoLOG;
  $proceso_actual=$proceso_nombre;
  
}
else
{
    $debug && print "Faltan parámetros";
    print ERROR "\nmail \"ERROR $proceso_actual\" $correo_error \<\<\_clave";
    print ERROR "\nPROCESO DE VALIDACIÓN DE $proceso_actual...";
    print ERROR "\nNo hay informacion en LA TABLA $tabla_procesos .";
    print ERROR "\n$fecha_sistema *** $hora_sistema";
    print ERROR "\n_clave";
    close(ERROR);
    #system ("bash $archivoerror");
    exit();
}

if ($debug_vars) {
  print "proceso_nombre= $proceso_nombre \n";
  print "proceso_prefijo= $proceso_prefijo \n";
  print "proceso_path= $proceso_path \n";
  print "proceso_filename= $proceso_filename \n";
  
  print "proceso_header_tienda=$proceso_header_tienda \n";
  print "proceso_longitud_ht=$proceso_longitud_ht \n";
  
  print "proceso_header_recepcio=$proceso_header_recepcion \n";
  print "proceso_longitud_hr=$proceso_longitud_hr \n";
  
  print "proceso_articulo=$proceso_articulo \n";
  print "proceso_longitud_articulo=$proceso_longitud_articulo \n";
  
  print "proceso_lineasmin=$proceso_lineasmin \n";
  print "proceso_softerror=$proceso_softerror \n";
  
  print "proceso_plaza=$proceso_plaza \n";
  print "proceso_path_procesados=$proceso_path_procesados \n";
  
  print "nombrearchivoLOG=$nombrearchivoLOG \n";
  print "proceso_actual=$proceso_actual \n";
  
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
        $archivos_procesados=0;
        
        
  #--------+       
  #--------+       Selecciono las plazas, y proceso cada una
  #--------+       
  $debug && print "SELECT * FROM $tabla_plazas where estado=1\n";
  
  $conexion=$conexione->prepare("SELECT * FROM $tabla_plazas where estado=1");
  $conexion->execute;

  while ($registro = $conexion->fetchrow_hashref()){
    
    $plaza_id=trim($registro->{'id'});
    $plaza_reg=trim($registro->{'extension'});
    $plaza=trim($registro->{'nombre'});
    
    print LOG "\nProcesando Plaza: $plaza \n";
    print "\nProcesando Plaza: $plaza \n";
        
   @archivos=(<*$plaza_reg>);
   
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
          $archivos_procesados++;
          
          foreach $renglon(@lineas){
            $renglon=~s/(\r|\n)*$//;
            
            
           $debug && print $renglon."\n";
           
            if($renglon =~/$proceso_header_tienda/){
              
              $ht=$renglon;
              
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
                    $Errores++;
                    
                    next;
                    
                  }else{
                    #termino con el archivo y lo marco con error.
                    $HT_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                    $Errores++;
                    
                  }
                  
                }
                
              }
              
              
              
              if(exists $salida{$renglon}){
                # Ya existe este header
              }
              else{
                $debug && print "Es header tienda\n";
                
                $salida{$ht}=();
                $salida_err{$ht}=();
                $salida_err{"err_".$ht}=0;
                
              }
              
            }elsif($renglon =~/$proceso_header_recepcion/){
              
              $hr=$renglon;
              
              
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
                    $salida_err{$ht}{$hr}=();
                    
                    if ( (length($renglon) != $proceso_longitud_hr)){ $salida_err{$ht}{"err_".$hr}=1; $debug_vars && print "ERROR HR: '$renglon' \n";}
                      $Errores++;
                      next;
                  }else{
                    #termino con el archivo y lo marco con error.
                    $HR_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                    $Errores++;
                  }
                  
                }
                
              }
              
              if(exists $salida{$ht}{$renglon}){
                # Error, ya existe este header Recepcion
              }
              else{
                $salida{$ht}{$hr}=0;
                $salida_err{$ht}{$hr}=();
                $salida_err{$ht}{$hr}{"cant"}=0;
              }
              
            }
            elsif($renglon =~/$proceso_articulo/){
              
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
                    
                    if (length($renglon) != $proceso_longitud_articulo){$salida_err{$ht}{$hr}{"cant"}++;}
                    $salida_err{$ht}{$hr}{$renglon}=1;
                    $debug_vars && print "\n$ht | $hr | $renglon\n";
                    $debug_vars && print "$HT_error | $HR_error | $ART_error \n";
                    $Errores++;
                    next;
                    
                  }else{
                    #termino con el archivo y lo marco con error.
                    $ART_error=0; #lo pongo en 0 para que el proximo archivo no marque error
                    $Errores++;
                    
                  }
                  
                }
                
              }
              
              $debug && print "Es articulo \n";
                $salida{$ht}{$hr}++;
              }else{
              #Si no es ninguno de los tipos que buscamos, lo marco como error de artículo.
              $salida_err{$ht}{$hr}{$renglon}=1;
              $salida_err{$ht}{$hr}{"cant"}++;
                $debug_vars && print "\n$ht | $hr | $renglon\n";
                $debug_vars && print "DESC: $HT_error | $HR_error | $ART_error \n";
                $Errores++;
              next;
            }
            
          } #Fin Foreach de renglones
          
        }else{
          $debug && print "No se pudo abrir el archivo $a n";
        } #Fin de apertura de archivo
          
         print LOG "\nResultados archivo $a  \n";
         
         #Como ya procesamos por cada plaza, no requerimos este paso.
         #$plaza=0;
         #if($a=~/$proceso_plaza/){
        #   $plaza=$1;
         #}
         
         foreach $s_tienda(keys %salida){
          
          foreach $s_recepcion(keys %{$salida{$s_tienda}}){
            print LOG "$s_tienda | ";
            print LOG "$s_recepcion | ";
            print LOG $salida{$s_tienda}{$s_recepcion}."\n";
            $cantidad=$salida{$s_tienda}{$s_recepcion};
            #manejamos los errores
            $err_art=0;
            $err_art=$salida_err{$s_tienda}{$s_recepcion}{"cant"} if (exists $salida_err{$s_tienda}{$s_recepcion}{"cant"});
            
            
            $query="INSERT INTO $tabla_procesados values(null,$proceso_id,'$proceso_nombre','$plaza','$a','$date_proceso','$s_tienda','$s_recepcion',$cantidad,$err_art,$plaza_id)";
            $conexion4=$conexione->prepare($query);
            $conexion4->execute;
          }
          
         }
         
         foreach $s_tienda(keys %salida_err){
          
          foreach $s_recepcion(keys %{$salida_err{$s_tienda}}){
            foreach $s_art(keys %{$salida_err{$s_tienda}{$s_recepcion}}){
              next if $s_art eq "cant" ;
            print LOG "ERROR_LINEA: $s_tienda | ";
            print LOG "$s_recepcion | ";
            print LOG "$s_art\n";
            $err_ht=0;
            $err_hr=0;
            $err_art=0;
            $err_ht=$salida_err{"err_".$s_tienda} if (exists $salida_err{"err_".$s_tienda});
            $err_hr=$salida_err{$s_tienda}{"err_".$s_recepcion} if (exists $salida_err{$s_tienda}{"err_".$s_recepcion} );
            $err_art=$salida_err{$s_tienda}{$s_recepcion}{"cant"} if(exists $salida_err{$s_tienda}{$s_recepcion}{"cant"});
            
            $query="INSERT INTO $tabla_error values(null,$proceso_id,'$proceso_nombre','$plaza','$a','$date_proceso','$s_tienda','$s_recepcion','$s_art',$err_ht,$err_hr,$err_art,$plaza_id)";
            $conexion4=$conexione->prepare($query);
            $conexion4->execute;
            }
          }
          
         }
     
        %salida=();
        %salida_err=();
       
       #Muevo el archivo a los procesados.
       if ($mover) {
        #code
       
       
       $a_procesado=$proceso_path_procesados."/".$proceso_prefijo."_".$a;
        rename("$a", "$a_procesado");
       print LOG "\n\nEl archivo $a se procesó correctamente y fue enviado a $a_procesado \n";
       
       print "\n\nEl archivo $a se procesó correctamente y fue enviado a $a_procesado \n";
       }else{
         print LOG "\n\nEl archivo $a se procesó correctamente \n";
       
       print "\n\nEl archivo $a se procesó correctamente \n";
       }
      } #Fin de if de nombre
      
    } #Fin de listado de archivos
}
   
   
  

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

if ($archivos_procesados>0) {
  
  print LOG "\n\nSe procesaron $archivos_procesados archivos. \n";
  $debug && print  "\n\nSe procesaron $archivos_procesados archivos. \n";
  
}else{
   print LOG "\n\nNo se encontraron archivos que procesar. \n";
  $debug && print  "\n\nNo se encontraron archivos que procesar. \n";
  print ERROR "\n\nNo se encontraron archivos que procesar. \n";
  $Errores++;
}


print LOG "\n\nHora de fin de proceso  $hora_sistema...";
print LOG "\n-----------------------------------------------------------";
$debug && print "\nFIN DE PROCESO...";

#--------+       
#--------+       Se cierran archivos Log, de errores y de encabezados de liquidaciones leidas...
#--------+       

close(ERROR);
close(LOG);


#--------+       
#--------+       Se envia log y errores que reportar por correo electronico...
#--------+       

$ArchivoCorreo=$dir_proceso."/Correo.sh";
$ListaCorreoLog="gserna\@7-eleven.com.mx";
$ListaCorreoErr="gserna\@7-eleven.com.mx, jlealvil\@7-eleven.com.mx, ncontreras\@7-eleven.com.mx, pquintan\@7-eleven.com.mx";
$Asunto="\"Log de Proceso $proceso_nombre.\"";
open(Correo,"> $ArchivoCorreo");
# Se cancela la linea que envia el correo electronico con el log para dejar solo los errores
# print Correo "\necho \| mutt -s $Asunto -i $DIRECTORIO_BITACORAS/$nombrearchivoLOG $ListaCorreoLog";

if($Errores>0)
{
  $Asunto="\"Errores en proceso $proceso_nombre\"";
  print Correo "\necho \| mutt -s $Asunto -i $archivoerror $ListaCorreoErr";
}

close(Correo);

if($Errores>0)
{
    #system ("bash $ArchivoCorreo");
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

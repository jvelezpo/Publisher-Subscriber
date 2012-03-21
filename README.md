#Servicio de anuncios distribuido
========
Implementación de un sistema de anuncios (advertisement) que permite a un conjunto de clientes
obtener mensajes de anuncios de productos o servicios. El sistema tiene dos módulos principales:
Proveedor de anuncios (AdFuente), es decir, es desde donde se generan los mensajes y un Cliente de
anuncios (AdCliente), el cual recibe los mensajes enviados a un Canal por un AdFuente.

###Reto 1

 **Por:**
  Juan Sebastian Velez Posada

##Requisitos & Instalación

Se debe tener instalado Ruby 1.9. (Ruby 1.8 no soporta funciones como 'tcp_server_loop' entre otras.)



##Ejecución

En la carpeta _Reto1_ hay 3 archivos ejecuatables, AdServidor.rb, AdCliente.rb y AdFuente.rb. El primer archivo que se debe ejecutar
es AdServidor.rb, especificando el puerto que se desea utilizar `$ ruby AdServidor.rb 5555`.


Teniendo en ejecución el servidor podemos correr ya sea AdFuente.rb o AdCliente.rb. Para esto se debe especificar la ip del servidor 
al igual que el puerto. `$ ruby AdCliente.rb localhost 5555` ó `$ ruby AdFuente.rb localhost 5555`.

>"Los anuncios son recibidos por los clientes en modo PUSH y PULL. Por anuncios PUSH se entiende la característica de recibir en un cliente 
>mensajes sin haber sido solicitada explícitamente por el cliente. Por anuncios PULL se entiende cuando el cliente explícitamente recupera mensajes de un canal específico."


Las 3 entidades cuentan con un comando `help` con el cual se pueden ver todos los comandos disponibles y que hace cada uno
de ellos.
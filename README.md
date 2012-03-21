#Reto 1 Telematica II

 **Por:**
  Juan Sebastian Velez Posada

##Requisitos & Instalación

Se debe tener instalado Ruby 1.9. (Ruby 1.8 no soporta funciones como 'tcp_server_loop' entre otras.)



##Ejecución

Correr el servidor antes que todo, para eso de debera utilizar el comando `$ ruby AdServidor.rb 30000`.


Luego de tener el servidor corriendo podemos ejecutar ya sea el adCliente o el adFuente, para esto debemos de utilizar los siguiente comandos `$ ruby AdCliente.rb localhost 5555` ó `$ ruby AdFuente.rb localhost 5555`.


Los anuncios son recibidos por los clientes en modo push y pull. 
Push cuando un cliente los pide explicitamente de un canal o de varios canales
Pull cuando un cliente esta subscrito en un canal y el adFuente publica algo, este inmediatamente le llega a todos los subscriptores


Para mas ayuda se puede utilizar el comando `help` en cualquiera de las entidades

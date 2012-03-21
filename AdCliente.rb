

def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mingw32'
end

require "socket"
require 'readline'

if Kernel.is_windows? == true
  require 'win32console'
end


class AdCliente

	attr_accessor :host, :puerto

	def initialize(host,puerto)
		@host = host
		@puerto = puerto
	end

	def run
	    @socket = TCPSocket.new(host, puerto)
	    begin
	    	@socket.puts "AdCliente"
	    	STDOUT.sync = true
	    	print "Nombre de usuario: "
	    	nombreUsuario = STDIN.gets.chomp
	      @socket.puts nombreUsuario

	      puts "Conectado"

	    	hilo_leer = Thread.new { leer }
		    hilo_escribir = Thread.new { escribir}
		    hilo_leer.join
		    hilo_escribir.join
	    ensure
	      @socket.close
	    end
	end

	private


	def leer
		begin
      while not @socket.eof?
        line = @socket.gets.chomp
        puts line
		  end
	    rescue Exception => e
	      puts "Error: #{e}"
	  end

	end

	def escribir
		begin
	      while not STDIN.eof?
	        line = STDIN.gets.chomp.downcase
	      	if line == "help"
	      		ayuda
	      	elsif line == "exit"
	        	exit
	        else
	        	@socket.puts line
	        end	
	      end
	    rescue SystemExit, Interrupt
			  Thread.list.each { |t| t.kill }
	    rescue Exception => e
	      puts "Ha ocurrido un error: #{e}"      
	    end
	end

  def ayuda
    puts "\nAvailable commands: "
    puts "- lista chs: Lista de todos los canales disponibles en el servidor"
    puts "- lista mis chs: Lista de los canales a los cuales estoy subscrito"
    puts "- mensajes Canal1,.. : Obtiene los mensajes de los canales especificados"
    puts "- subscribe Canal1,..: Subscribirte a los canales especificados"
    puts "- unsubscribe Canal1,..: Cancelar la subscripcion de uno o mas canales"
    puts "- exit: Sale de la aplicacion"
  end

end

if ARGV.size < 2
  puts "Usage: ruby #{__FILE__} [host] [port]"
else
  client = AdCliente.new(ARGV[0], ARGV[1].to_i)
  client.run
end
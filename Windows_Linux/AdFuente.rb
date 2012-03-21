
def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mingw32'
end

require "socket"


if Kernel.is_windows? == true
  require 'win32console'
end


class AdFuente

	def initialize(host,puerto)
		@host = host
		@puerto = puerto
	end

	def run
	    @socket = TCPSocket.new(@host, @puerto)
	    begin
	    	@socket.puts "AdFuente"
		    hilo_leer = Thread.new { leer }
		    hilo_escribir = Thread.new { escribir}
		    puts "Conectado"
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
		        mensaje = @socket.gets.chomp
            puts mensaje
		    end#while
	    rescue Exception => e     				
	      puts "An exception has occurred: #{e}"
	    end

	end

	def escribir
		begin
	      while not STDIN.eof?
	        line = STDIN.gets.chomp
          line.downcase
	        if line == "help"
	        	helpFuente
	        elsif line == "exit"
	        	exit
	        else
	        	@socket.puts line
	        end	      	
	      end
	    rescue SystemExit, Interrupt
			  Thread.list.each { |t| t.kill }
	    rescue Exception => e
	      puts "Error: #{e}"
	    end
	end

  def helpFuente
    puts "Comandos: "
    puts "- lista chs: Lista de todos los canales disponibles en el servidor"
    puts "- newM (Canal1,..) Mensage: Envia un mensaje a los canales destino"
    puts "- exit: Sale de la aplicacion"
  end

end

if ARGV.size < 2
  puts "Usage: ruby #{__FILE__} [host] [port]"
else
  fuente = AdFuente.new(ARGV[0], ARGV[1].to_i)
  fuente.run
end
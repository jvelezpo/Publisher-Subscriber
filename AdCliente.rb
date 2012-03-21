

def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mingw32'
end

require "socket"
require 'nokogiri'
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
	    	@socket.puts "AdCliente"					#Me identifico ante el servidor como un AdCliente
	    	STDOUT.sync = true
	    	print "Enter an username: "
	    	nombreUsuario = STDIN.gets.chomp
	      	@socket.puts nombreUsuario

	      	puts "Conected..."

	    	hiloLeer = Thread.new { leer }
		    hiloEscribir = Thread.new { escribir}
		    hiloLeer.join
		    hiloEscribir.join
	    ensure
	      @socket.close
	    end
	end

	private


	def leer
		begin
	      while not @socket.eof?
		        line = @socket.gets.chomp
		        if line=~ /(ERR) (1|2)/
		        	case $2
			    		when "1"
			    			puts "Command not found"
				    	when "2"
					    	puts "Error: You have to set at least one channel"
				    end
				else
					puts line	
		        end	
		   end
	    rescue Exception => e     				#Catch de RUBY
	      puts "Ha ocurrido un error: #{e}"
	    end

	end

	def escribir
		begin
	      while not STDIN.eof?
	        line = STDIN.gets.chomp
	      	if line == "-HELP" || line == "-help"
	      		helpCliente
	      	elsif line == "QUIT" || line == "quit"
	        	exit
	        else
	        	@socket.puts line
	        end	
	      end
	    rescue SystemExit, Interrupt
		    puts("Good Bye! :).")
			Thread.list.each { |t| t.kill }
	    rescue Exception => e
	      puts "Ha ocurrido un error: #{e}"      
	    end
	end

  def helpCliente
    puts "\nAvailable commands: "
    puts "-LIST CH => Lists all channels that are currently active in the server"
    puts "-LIST MY CH => Lists all channels that you are subscribed"
    puts "-GETMSGS (Channel1,...) => Get all the messages from channel(s) Channel1,..."
    puts "-SUBSCRIBE (Channel1,...) => Subscribes you into channel(s) Channel1,..."
    puts "-UNSUBSCRIBE (Channel1,...) => Unsubscribes you into channel(s) Channel1,..."
    puts "- -HELP => Shows all the Available commands"
    puts "-QUIT => Quits the program"
  end

end

if ARGV.size < 2
  puts "Usage: ruby #{__FILE__} [host] [port]"
else
  client = AdCliente.new(ARGV[0], ARGV[1].to_i)
  client.run
end
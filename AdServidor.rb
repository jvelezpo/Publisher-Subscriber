
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

load "Persistence/XmlHandler.rb"

class AdServidor

	include XmlHandler

	attr_accessor :puerto, :canales, :fuentes, :clientes, :doc

	def initialize(puerto=1212)
		@puerto = puerto
		@fuentes = []
		@canales = {}							  #Creación del Hash de canales
		@clientes = {}
		@doc = Nokogiri::XML File.open 'Persistence/data.xml'	
		cargarInfoXML('canales')				  #Cargamos los canales del XML
		cargarInfoXML('mensajes')				  #Cargamos los mensajes del XML
		cargarInfoXML('clientes')				  #Cargamos los clientes del XML
	end

	def run
		puts "Server running..."
		
		hiloAdministrador = Thread.new {mainADMIN} #Main principal del administrador

		Socket.tcp_server_loop(@puerto) {|socket, client_addrinfo|
		  Thread.new {
		    begin
		    	identificacion(socket, client_addrinfo)	    
		    	if @fuentes.include?(socket)
		    		mainAdFuente(socket)		   #Main principal de las acciones del AdFuente
		    	else
		    		mainAdCliente(socket)		   #Main principal de las acciones del AdCliente
				end
			ensure
		      socket.close 
		    end
		  }
		}
	end

	private	
	
	def identificacion(socket, client_addrinfo)
    	typeOfEntity = socket.readline.chomp
    	case typeOfEntity
	    	when "AdCliente"
	    		nombreUsuario = socket.readline.chomp.downcase
	    		@clientes[nombreUsuario] = socket
	    		puts "A new client has entered -> #{nombreUsuario}\n"

	    	when "AdFuente"	
	    		@fuentes.push(socket)
	    		puts "A new 'source' has entered -> ip: #{client_addrinfo.ip_address} - port: #{client_addrinfo.ip_port} \n"
    	end
  end







  def mainADMIN()
    begin
      while not STDIN.eof?
        line = STDIN.gets.chomp
        line = line.downcase
         unless line.nil?

          if line == "list ch"
            puts "Actual channels:"
            @canales.keys.each do |canal|
              puts "- #{canal}"
            end
            puts "\n"
          end
          if line == "list clients"
              puts "Online clients:"
            if @clientes.length == 0
              puts "no clients are connected yet"
            else
               @clientes.keys.each do |cliente|
               puts "- #{cliente}"
              end
            end
            puts "\n"
          end
          if line =~ /new ch/
            line["new ch "] = ""
            if line.to_s.empty?
              puts "You have not entered any channel |Type '-HELP'|"
            else
              asCanal = line.split(',')
              if asCanal.size > 1
                puts "Only one channel at a time"
              elsif @canales.include?(line.upcase)
                puts "Channel #{line} already exists."
              else
                @canales[line.upcase] = [[],[]]
                puts "Successfully created channel -> #{line.upcase}"
              end
            end
          end
          if line =~ /remove ch/
            line["remove ch "] = ""
            if line.to_s.empty?
              puts "You have not entered any channel |Type '-HELP'|"
            else
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.upcase
                if @canales.has_key?(canal)
                  @canales.delete(canal)
                  puts "Successfully removed channel -> #{canal}"
                else
                  puts "Channel -> #{canal} does not exist"
                end
              end
            end
          end
          if line == "-help"
           helpAdmin
          end
          if line == "quit"
           exit
          end

        else
          puts "Command not found"
        end
      end
    rescue SystemExit, Interrupt
      puts("Good Bye :).")
      guardarInfo()
      Thread.list.each { |t| t.kill }
    rescue Exception => e
      puts "An exception has occurred: #{e}"
    end
  end

  def helpAdmin
    puts "\nAvailable commands: "
    puts "-LIST CH => Lists all channels that are currently active in the server"
    puts "-LIST CLIENTS => Lists all clients that are currently conected in the server"
    puts "-NEW CH ChannelName => Creates a new channel"
    puts "-REMOVE CH Channel1,.. => Removes multiple channels"
    puts "- -HELP => Shows all the available commands"
    puts "-QUIT => Quits the program"
  end











  # ---------- MAIN ADCLIENTE ----------
  def mainAdCliente(socket)
    #Ver los mensajes de un canal () socket.puts @canales[line][0]
    begin
      while not socket.eof?
        line = socket.readline.chomp
        line = line.downcase
        unless line.nil?

          if line == "list ch"
            socket.puts "Actual channels:"
            @canales.keys.each do |canal|
              socket.puts "\t- #{canal}"
            end
            socket.puts "\n"
          end

          if line == "list my ch"
            nombreUsuario = @clientes.invert[socket]
            socket.puts "Your channels:"
            if @canales.length == 0
              socket.puts "no channels in your list"
            else
              @canales.each do |k,v|
                if v[1].include?(nombreUsuario)
                  socket.puts "\t- #{k}"
                end
              end
            end
            socket.puts "\n"
          end

          if line =~ /getmsgs/
            line["getmsgs "] = ""
            if line.to_s.empty?
              socket.puts "you have to type one channel minimum"
            else
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.upcase
                if @canales.has_key?(canal.upcase)
                  if @canales[canal][0].empty?
                    socket.puts "There are no messages on channel #{canal}"
                  else
                    socket.puts "Messages from channel #{canal}"
                    @canales[canal][0].each do |mensaje|
                      socket.puts "\t-> #{mensaje}"
                    end
                  end
                else
                  socket.puts "Channel #{canal.upcase} does not exist"
                end
              end
            end
          end

          if line =~ /unsubscribe/
            line["unsubscribe "] = ""
            if line.to_s.empty?
              socket.puts "you have to type one channel minimum"
            else
              nombreUsuario = @clientes.invert[socket]
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.upcase
                if @canales.has_key?(canal) && @canales[canal][1].include?(nombreUsuario)
                  socket.puts "Successfully unsubscribed from channel -> #{canal}"
                  @canales[canal][1].delete(nombreUsuario)
                elsif !@canales[canal][1].include?(nombreUsuario)
                  socket.puts "You are not subscribed to channel -> #{canal}"
                end
              end
            end
          end

          if line =~ /subscribe/
            line["subscribe "] = ""
            if line.to_s.empty?
              socket.puts "you have to type one channel minimum"
            else
             nombreUsuario = @clientes.invert[socket]
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.upcase
                if @canales.has_key?(canal) && !@canales[canal][1].include?(nombreUsuario)
                  socket.puts "Successfully subscribed to channel -> #{canal}"
                  @canales[canal][1].push(nombreUsuario)
                elsif !@canales.has_key?(canal)
                  socket.puts "Channel #{canal.upcase} does not exist"
                elsif @canales[canal][1].include?(nombreUsuario)
                  socket.puts "You are already subscribed to channel -> #{canal}"
                end
              end
            end
          end

        else
          socket.puts "ERR 1"
        end
      end#while
    rescue Exception => e
      puts "An exception has occurred: #{e}"
    ensure
      @clientes.delete_if {|k,v| v == socket}			#Eliminamos cliente dle hash
    end

  end














  # ---------- MAIN ADFUENTE ----------
  def mainAdFuente(socket)
    begin
      while not socket.eof?
        line = socket.readline.chomp
        line = line.downcase
        unless line.nil?
          if line == "list ch"
            socket.puts "Actual channels:"
            @canales.keys.each do |canal|
              socket.puts "- #{canal}"
            end
            socket.puts "\n"
          end

          if line =~ /newmsg/
            line["newmsg "] = ""
            if line.to_s.empty?
              socket.puts "you have to tye a channel"
            elsif line.to_s.empty?
              socket.puts "you have to type a msg"
            else
              canalesMSG = line.slice(0..(line.index(')'))).to_s.sub!(/\(/,'').sub!(/\)/,'')
              line[line.slice(0..(line.index(')')))] = ""
              mensajeMSG =  line.to_s
              asCanales = canalesMSG.split(',')
              asCanales.each do |canal|
                canal = canal.strip.upcase
                if @canales.has_key?(canal)
                  @canales[canal][0].push(mensajeMSG)
                  @canales[canal][1].each do |cliente|
                    if	@clientes.include?(cliente)
                      @clientes[cliente].puts "A new message from channel canal\n\t-> #{mensajeMSG}"
                      socket.puts "Message sent to channel -> #{canal}"
                    end
                  end
                end
              end
            end
          end
        else
          socket.puts "ERR 1"
        end
      end#while
    rescue Exception => e
      puts "An exception has occurred: #{e}"
    ensure
      @fuentes.delete(socket)
    end
  end

end

#Corriendo...
if ARGV.size < 1
  puts "Usage: ruby #{__FILE__} [puerto]"
else
  servidor = AdServidor.new(ARGV[0].to_i)
  servidor.run
end


def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mingw32'
end

require "socket"


if Kernel.is_windows? == true
  require 'win32console'
end


class AdServidor


	def initialize(puerto)
		@puerto = puerto
		@fuentes = []
		@canales = {}
		@clientes = {}
	end

	def run
		puts "Servidor Activo"
		
		Thread.new {hilo_admin}

		Socket.tcp_server_loop(@puerto) {|socket|
		  Thread.new {
		    begin
		    	connection_type?(socket)
		    	if @fuentes.include?(socket)
		    		hilo_adFuente(socket)
		    	else
		    		hilo_adCliente(socket)
				  end
			  ensure
		      socket.close 
		    end
		  }
		}
	end

	private	
	
	def connection_type?(socket)
    	typeOfEntity = socket.readline.chomp
    	case typeOfEntity
	    	when "AdCliente"
	    		nombreUsuario = socket.readline.chomp.capitalize
	    		@clientes[nombreUsuario] = socket
	    		puts "Un cliente se ha conectado con nombre: #{nombreUsuario}\n"
	    	when "AdFuente"	
	    		@fuentes.push(socket)
	    		puts "Un adFuente se ha conectado \n"
    	end
  end







  def hilo_admin
    begin
      while not STDIN.eof?
        line = STDIN.gets.chomp
        line = line.downcase
         unless line.nil?

          if line == "lista chs"
            puts "Lista de canales:"
            if @canales.length == 0
              puts "vacio"
            else
              @canales.keys.each do |canal|
                puts "- #{canal}"
              end
            end
            puts "\n"


          elsif line == "lista clientes"
              puts "Clientes conectados:"
            if @clientes.length == 0
              puts "0 clientes conectados"
            else
               @clientes.keys.each do |cliente|
               puts "- #{cliente}"
              end
            end
            puts "\n"


          elsif line =~ /nuevo ch/
            line["nuevo ch "] = ""
            if line.to_s.empty?
              puts "Debes de entrar un canal"
            else
              asCanal = line.split(',')
              if asCanal.size > 1
                puts "Solo puedes crear un canal a la vez"
              elsif @canales.include?(line.capitalize)
                puts "Canal #{line} ya existe."
              else
                @canales[line.capitalize] = [[],[]]
                puts "Canal: #{line.capitalize} creado con exito"
              end
            end


          elsif line =~ /del ch/
            line["del ch "] = ""
            if line.to_s.empty?
              puts "Debes de entrar un canal"
            else
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.capitalize
                if @canales.has_key?(canal)
                  @canales.delete(canal)
                  puts "canal: #{canal} borrado con exito"
                else
                  puts "Canal: #{canal} no existe"
                end
              end
            end

          elsif line == "help"
           helpAdmin

          elsif line == "exit"
           exit

          else
            puts "Command not found"
          end
        end
      end
    rescue SystemExit, Interrupt

      Thread.list.each { |t| t.kill }
    rescue Exception => e
      puts "An exception has occurred: #{e}"
    end
  end

  def helpAdmin
    puts "\nComandos: "
    puts "- lista chs: Lista de todos los canales disponibles en el servidor"
    puts "- lista clientes: Lista de los clientes conectados al servidor"
    puts "- nuevo ch canal: Crea un nuevo canal"
    puts "- del ch canal1,... : Borra un canal existente"
    puts "- exit: Sale de la aplicacion"
  end












  def hilo_adCliente(socket)

    begin
      while not socket.eof?
        line = socket.readline.chomp
        line = line.downcase
        unless line.nil?

          if line == "lista chs"
            socket.puts "Lista de canales:"
            if @canales.length == 0
              socket.puts "vacio"
            else
              @canales.keys.each do |canal|
                socket.puts "- #{canal}"
              end
            end
            socket.puts "\n"


          elsif line == "lista mis chs"
            nombreUsuario = @clientes.invert[socket]
            socket.puts "Tus subscripciones:"
            if @canales.length == 0
              socket.puts "vacio"
            else
              @canales.each do |k,v|
                if v[1].include?(nombreUsuario)
                  socket.puts "- #{k}"
                end
              end
            end
            socket.puts "\n"


          elsif line =~ /mensajes/
            line["mensajes "] = ""
            if line.to_s.empty?
              socket.puts "Error: debes de entrar un canal"
            else
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.capitalize
                if @canales.has_key?(canal.capitalize)
                  if @canales[canal][0].empty?
                    socket.puts "No existen mensajes en el canal #{canal}"
                  else
                    socket.puts "Mensages de: #{canal}"
                    @canales[canal][0].each do |mensaje|
                      socket.puts "- #{mensaje}"
                    end
                  end
                else
                  socket.puts "Canal: #{canal.capitalize} no existe"
                end
              end
            end


          elsif line =~ /unsubscribe/
            line["unsubscribe "] = ""
            if line.to_s.empty?
              socket.puts "Error: debes de entrar un canal"
            else
              nombreUsuario = @clientes.invert[socket]
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.capitalize
                if @canales.has_key?(canal) && @canales[canal][1].include?(nombreUsuario)
                  socket.puts "Cancelaste la subscripcion de: #{canal}"
                  @canales[canal][1].delete(nombreUsuario)
                elsif !@canales[canal][1].include?(nombreUsuario)
                  socket.puts "No te encuentras subscrito a: #{canal}"
                end
              end
            end


          elsif line =~ /subscribe/
            line["subscribe "] = ""
            if line.to_s.empty?
              socket.puts "Error: debes de entrar un canal"
            else
             nombreUsuario = @clientes.invert[socket]
              asCanales = line.split(',')
              asCanales.each do |canal|
                canal = canal.strip.capitalize
                if @canales.has_key?(canal) && !@canales[canal][1].include?(nombreUsuario)
                  socket.puts "Subscrito al canal: #{canal}"
                  @canales[canal][1].push(nombreUsuario)
                elsif !@canales.has_key?(canal)
                  socket.puts "Canal: #{canal.capitalize} no existe"
                elsif @canales[canal][1].include?(nombreUsuario)
                  socket.puts "Ya te encuentras subscrito a: #{canal}"
                end
              end
            end

          else
            socket.puts "Error: comando no valido"
          end
        end
      end#while
    rescue Exception => e
      puts "Error: #{e}"
    ensure
      @clientes.delete_if {|k,v| v == socket}
    end

  end















  def hilo_adFuente(socket)
    begin
      while not socket.eof?
        line = socket.readline.chomp
        line = line.downcase
        unless line.nil?
          if line == "lista chs"
            socket.puts "Lista de canales:"
            if @canales.length == 0
              socket.puts "vacio"
            else
              @canales.keys.each do |canal|
                socket.puts "- #{canal}"
              end
            end
            socket.puts "\n"

          elsif line =~ /newm/
            line["newm "] = ""
            if line.to_s.empty?
              socket.puts "Error: debes de entrar un canal"
            elsif line.to_s.empty?
              socket.puts "Error: debes de entrar un mensaje"
            else
              canalesMSG = line.slice(0..(line.index(')'))).to_s.sub!(/\(/,'').sub!(/\)/,'')
              line[line.slice(0..(line.index(')')))] = ""
              mensajeMSG =  line.to_s
              asCanales = canalesMSG.split(',')
              asCanales.each do |canal|
                canal = canal.strip.capitalize
                if @canales.has_key?(canal)
                  @canales[canal][0].push(mensajeMSG)
                  @canales[canal][1].each do |cliente|
                    if	@clientes.include?(cliente)
                      @clientes[cliente].puts "Mensaje nuevo de #{canalesMSG}\n\t- #{mensajeMSG}"
                    end
                  end
                  socket.puts "Su mensaje ha sido enviado a: #{canal}"
                end
              end
            end
          else
            socket.puts "Error: comando no valido"
          end
        end
      end#while
    rescue Exception => e
      puts "Error: #{e}"
    ensure
      @fuentes.delete(socket)
    end
  end

end





if ARGV.size < 1
  puts "Usage: ruby #{__FILE__} [puerto]"
else
  servidor = AdServidor.new(ARGV[0].to_i)
  servidor.run
end


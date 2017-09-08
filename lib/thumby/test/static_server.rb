require 'webrick'
class Thumby
  class Test
    module StaticServer

      def self.run!(options = {})
        port = options[:port] || 9999
        root_dir = options[:root_dir] || Dir.pwd
        thread = Thread.new do
          begin
            options = { :Port => port, :BindAddress => '127.0.0.1', :DocumentRoot => root_dir, :AccessLog => [], :Logger => WEBrick::Log.new('/dev/null'), :OutputBufferSize => 5 }

            server = ::WEBrick::HTTPServer.new(options)
            #server.mount "/", Rack::Handler::WEBrick #, VtDirectServer::Server
            server.start
          rescue Exception => e
            puts e.message
            puts e.backtrace
          end
        end

        #wait for opening port
        while port_open?('127.0.0.1', port, 1)
          sleep 0.01
        end
        sleep 0.1

        puts "Running StaticServer => http://localhost:#{port}, DocumentRoot: #{root_dir}"
      end

       def self.port_open?(ip, port, seconds = 1)
         Timeout::timeout(seconds) do
           begin
             TCPSocket.new(ip, port).close
             true
           rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
             false
           end
         end
       rescue Timeout::Error
         false
       end

    end
  end
end

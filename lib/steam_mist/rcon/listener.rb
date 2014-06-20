module SteamMist
  class Rcon

    # Listens on a TCP stream for packets.  This is completely synchronus.
    class Listener

      extend Forwardable

      # The ip address this listener is bound to.
      #
      # @return [String]
      attr_reader :ip

      # The port the listener is bound to.
      #
      # @return [Numeric]
      attr_reader :port

      # The connection the listener is using.
      #
      # @return [TCPSocket]
      attr_reader :connection
      
      # Initialize the listener.
      #
      # @param ip [String] the ip address to bind to.
      # @param port [Numeric] the port to bind to.
      def initialize(ip, port)
        @ip     = ip
        @port   = port
        @closed = false
      end

      # Connect to the set port and ip address.
      #
      # @return [void]
      def bind!
        @connection = TCPSocket.new ip, port
      end

      # Sets the ip.
      #
      # @param new_ip [String]
      # @raise [ArgumentError] if already connected.
      # @return [void]
      def ip=(new_ip)
        raise ArgumentError, 
          "Already connected; cannot change IP" if connection

        @ip = new_ip
      end

      # Sets the port.
      #
      # @param new_port [Numeric]
      # @raise [ArgumentError] if already connected.
      # @return [void]
      def port=(new_port)
        raise ArgumentError,
          "Already connected; cannot change port" if connection

        @port = new_port
      end

      # Listens to the connection for any data; when there is some, it'll call
      # the block and then return.
      #
      # @yieldparam socket [TCPSocket]
      # @yieldreturn [void]
      # @raise [TimeoutError] when select takes too long.
      # @return [void]
      def on_data
        return false if closed?

        result = IO.select [connection], [], [], 10

        raise TimeoutError, "timeout" unless result

        yield connection
      end

      # Closes the connection.
      #
      # @return [void]
      def close
        unless @closed
          @closed = true
          connection.close
        end
      end

      # This returns true or false depending on whether or not the connection
      # is closed.
      #
      # @return [Boolean]
      def closed?
        @closed
      end

      # This passes the write through to the connection if the connection isn't
      # closed.
      def write(*args, &block)
        return false if closed?
        
        connection.write(*args, &block)
      end
    end

    # When {IO#select} takes too long to respond, this is raised.
    class TimeoutError < IOError; end
  end
end

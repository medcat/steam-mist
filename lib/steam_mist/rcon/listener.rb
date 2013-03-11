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
        @ip   = ip
        @port = port
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
      # @return [void]
      def on_data
        result = IO.select [connection], nil, nil, 10

        raise IOError, "timeout" unless result

        yield
      end

      def_delegator :@connection, :write
    end
  end
end

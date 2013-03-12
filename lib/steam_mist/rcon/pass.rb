module SteamMist
  class Rcon

    # This basically handles sending and receiving packets.
    class Pass
        
      # The packet factory that should be used when creating packets.  This
      # factory is used to increment the ID number on sequential packets.
      #
      # @return [PacketFactory]
      attr_reader :packet_factory

      # The listener for sending and receiving data from the server.
      #
      # @return [Listener]
      attr_reader :listener

      # Initialize.
      #
      # @param ip [String] the IP address of the Rcon server.  Passed to 
      #   Listener.
      # @param port [Numeric] the port of the Rcon server.  Passed to Listener.
      def initialize(ip, port = 27015)
        @packet_factory = PacketFactory.new
        @listener       = Listener.new ip, port
        @empty_packet   = Packet.from_hash :type => Packet::SERVERDATA_RESPONSE_VALUE
      end

      # Retrieves the next packet from the stream.  If a block is given, it
      # yields to that.
      #
      # @yieldparam packet [Packet]
      # @return [Packet]
      def on_packet(&block)
        ensure_connected.on_data do |con|
          packet = Packet.from_stream con
          
          if block
            block.call packet
          end

          packet
        end
      end

      # Sends the given packet to the server.
      #
      # @param packet [Packet]
      # @return [void, Numeric]
      def write(packet)
        ensure_connected.write packet.format
      end

      # Sends a packet along with an empty packet.  This allows the client to
      # figure out the server sent multiple packets to the client for the same
      # request packet.  Returns an array of packets if the server sent
      # multiple packets.
      #
      # @param packet [Packet] the packet to send
      # @return [Packet, Array<Packet>]
      def send_packet(packet)
        empty_packet = @empty_packet.dup
        empty_packet.id = packet.id
        write(packet) and write(empty_packet)
        response_packets = []

        begin
          while response_packets.empty? || !response_packets.last.weird? do
            response_packets << on_packet
          end

        rescue TimeoutError; end

        response_packets.pop(2)

        if response_packets.length == 1
          response_packets[0]
        else
          response_packets
        end
      end

      # This authenticates the connection with the server.  A password is
      # required.
      #
      # @param password [String] the password to authenticate with.
      # @return [Boolean]
      def auth(password)
        packet = packet_factory.create_packet
        packet.type = Packet::SERVERDATA_AUTH
        packet.body = password

        #response = send_packet packet
        write packet

        # discard
        on_packet

        response = on_packet

        response.id == packet.id
      end

      # This closes the connection by calling {Listener#close}.
      #
      # @return [void]
      def close
        listener.close
      end

      private

      # This makes sure the listener is connected before trying to perform an
      # I/O operation.
      #
      # @return [Listener]
      def ensure_connected
        listener.bind! unless listener.connection
        listener
      end
    end
  end
end

require 'steam_mist/rcon/packet_factory'
require 'steam_mist/rcon/packet'

module SteamMist

  # This class provides RCON capabilities.
  class Rcon

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
    end

    # Retrieves the next packet from the stream.  If a block is given, it
    # yields to that.
    #
    # @yieldparam packet [Packet]
    # @return [Packet]
    def on_packet(&block)
      listener.on_data do |con|
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
    def send_packet(packet)
      listener.write packet.format
    end

    private

    # This makes sure the listener is connected before trying to perform an
    # I/O operation.
    def ensure_connected
      listener.bind! unless listener.connector
    end

  end
end

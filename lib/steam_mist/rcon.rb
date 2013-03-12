require 'forwardable'
require 'steam_mist/rcon/pass'
require 'steam_mist/rcon/packet'
require 'steam_mist/rcon/listener'
require 'steam_mist/rcon/packet_factory'

module SteamMist

  # This class provides RCON capabilities.
  class Rcon

    extend Forwardable

    # This is the class that handles reading and writing packets from the
    # listener.
    #
    # @return [Pass]
    attr_reader :pass

    # Initialize.
    #
    # @param ip [String] the IP to connect to.
    # @param port [Numeric] the port to connect to.
    def initialize(ip, port = 27015)
      @pass = Pass.new(ip, port)
    end

    # This takes a hash, turns it into a packet, and sends it.
    #
    # @param hash [Hash] the data to turn into a packet.
    # @return [Packet, Array<Packet>]
    def send(hash)
      send_packet packet_factory.create_packet.load!(hash)
    end

    # Pretty inspect
    #
    # @return [String]
    def inspect
      "#<SteamMist::Rcon>"
    end

    def_delegators :@pass, :on_packet, :send_packet, :auth, :close, 
      :packet_factory

  end
end

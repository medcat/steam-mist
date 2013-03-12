require 'set'

module SteamMist
  class Rcon

    # Creates packets for use.
    class PacketFactory

      # An {SortedSet} containing all of the packets that have been created.
      #
      # @return [SortedSet]
      attr_accessor :packets

      # The current packet number.
      #
      # @return [Numeric]
      attr_accessor :number

      # initializes.
      def initialize
        @number  = 1
        @packets = SortedSet.new
      end

      # Creates a packet.  Automatically assigns it an id, based off of the
      # current packet number.
      #
      # @return [Packet]
      def create_packet
        packet = Packet.new(@number)
        @packets << packet
        @number = @number + 1
        packet
      end

      # Pretty inspect
      #
      # @return [String]
      def inspect
        "#<SteamMist::Rcon::PacketFactory #{@number}>"
      end
      
    end
  end
end

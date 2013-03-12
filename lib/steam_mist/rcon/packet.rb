module SteamMist
  class Rcon

    # Represents a packet either received from the server or sent by the
    # client.
    class Packet

      # This is used as a {#type}.  This is for the client, authenticating to
      # the server.
      SERVERDATA_AUTH = 3

      # Used for {#type}.  This is for the response from the server from the 
      # client.
      SERVERDATA_AUTH_RESPONSE = 2

      # Used for {#type}.  This is for the client executing a response to the
      # server.
      SERVERDATA_EXECCOMMAND = 2

      # Used for {#type}.  This is for the server sending back response data
      # for `EXECCOMMAND`.
      SERVERDATA_RESPONSE_VALUE = 0

      # This matches the requests with their responses.
      RESPONSE_MATCH = { SERVERDATA_AUTH        => SERVERDATA_AUTH_RESPONSE,
                         SERVERDATA_EXECCOMMAND => SERVERDATA_RESPONSE_VALUE }
      
      # The id of the packet.  This is mainly used to match request packets
      # with their response.
      #
      # @return [Numeric]
      attr_accessor :id

      # The type of the packet.
      #
      # @return [Numeric]
      attr_accessor :type

      # The body of the packet.
      #
      # @return [Numeric]
      attr_accessor :body

      # Initialize the packet.
      #
      # @param id [Numeric] the id of the packet.
      def initialize(id=nil)
        @id   = id || 0
        @type = SERVERDATA_EXECCOMMAND
        @body = ""
      end

      # Formats the packet for sending to the server. See
      # [this](https://developer.valvesoftware.com/wiki/Source_RCON_Protocol)
      # on how it's done.
      #
      # @return [String] a formatted string containing the data.
      def format
        [size, id, type, body].pack("l<l<l<a#{body.bytesize+1}x")
      end

      # This returns the size of the packet.  This is the size of the body, in
      # bytes.  It also adds 10 bytes for the type (4 bytes), id (4 bytes), and
      # the two nul-terminators (one for the body and one for the packet).
      #
      # @return [Numeric]
      def size
        body.bytesize + 10
      end

      # Compare this with another object.  Calls {#to_i} on the other object
      # and this one and delegates to that.
      #
      # @return [Numeric]
      def <=>(other)
        self.to_i <=> other.to_i
      end

      # Shows whether or not the packet is empty.  The packet is not empty if
      # the body contains more than "" and the type is not 2.
      #
      # @return [Boolean]
      def empty?
        body.empty? && (type != 2)
      end

      # This checks to see if it is SRCDS's weird packet response.
      #
      # @return [Boolean]
      def weird?
        (type == 0) and (body == "\x00\x01\x00\x00")
      end

      # This loads the packet data from a hash.  Overwrites the contents of the
      # packet.
      #
      # @param hash [Hash]
      # @return [self]
      def load!(hash)
        self.id   = hash[:id]   || hash["id"]   || id
        self.type = hash[:type] || hash["type"] || type
        self.body = hash[:body] || hash["body"] || body
        self
      end

      alias :to_i :id

      # This takes a formatted string and turns it into a packet instance.
      # This is mainly used for responses from the server.
      #
      # @param raw [String] the raw data from the server.
      # @return [Packet] the packet representing the data.
      def self.from_raw(raw)
        packet = Packet.new
        size, = raw.unpack("l<")
        _, packet.id, packet.type, packet.body = 
          raw.unpack("l<l<l<a#{size - 10}xx")
        packet
      end

      # This reads from a stream and converts it into a packet.
      #
      # @param socket [#read] the stream to read from.
      # @return [Packet] the packet representing the data.
      def self.from_stream(socket)
        packet = Packet.new
        size, = socket.read(4).unpack("l<")
        packet.id, packet.type, packet.body = 
          socket.read(size).unpack("l<l<a#{size - 10}xx")
        packet
      end

      # This sets up the packet from a given hash.
      #
      # @param [Hash] the data to map to the packet.
      # @return [Packet]
      def self.from_hash(data)
        packet = Packet.new
        packet.load! data

        packet
      end

    end
  end
end

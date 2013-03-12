require 'open-uri'

module SteamMist

  # @abstract Subclass and implement {#[], #each} to create a connector usable 
  #   by SteamMist.
  class Connector

    include Enumerable

    # This is the data that the connector received from Steam.  It may be null
    # if the connector is lazy (in terms of when it grabs data).
    #
    # @return [Hash, nil]
    attr_reader :data

    # This is the request that the connector used to grab information from the
    # steam api.
    #
    # @return [RequestUri]
    attr_reader :request_uri

    # Whether or not the connector has made the request to the API.
    #
    # @return [Boolean]
    attr_reader :made_request

    # This is a hash of headers that will be sent upon request.
    #
    # @return [Hash]
    attr_reader :headers

    # This initializes the connector.
    #
    # @param request_uri [RequestUri] the request uri to connect to.
    def initialize(request_uri)
      @request_uri = request_uri
      @headers = {}
    end

    # Retrieve data from #data.  This is normally used to force the connector
    # (if it's lazy) to grab data.
    #
    # @param _ [Object] the key for data access.
    # @raise NotImplementedError if the subclass hasn't implemented the method.
    # @return [Object]
    def [](_)
      raise NotImplementedError
    end

    # This loops through the data.  It should be implented for enumerable
    # access.
    #
    # @raise NotImplementedError if the subclass hasn't implemented the method.
    # @return [void]
    def each
      raise NotImplementedError
    end

    # If the connector is lazy, this should force the connector to make the
    # request to Steam.
    #
    # @return [Hash] the data from the request to steam.
    def force_request!
      # It may or may not work with a psudo-io object...
      @data = Oj.load(request, :mode => :strict)
    end

    protected

    # The request used for retrieving information from Steam.
    #
    # @return [IO]
    def request
      @_request ||= open(request_uri, headers)
    end
    
  end
end

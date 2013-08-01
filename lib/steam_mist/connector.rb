require 'open-uri'
require 'time'
require 'fileutils'

module SteamMist

  # @abstract Subclass and implement {#[], #each} to create a connector usable 
  #   by SteamMist.
  # @todo Test caching.
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
      @cache = false
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
    # @param force [Boolean] whether or not to force the request to
    #   return fresh data.
    # @return [Hash] the data from the request to steam.
    def force_request!(force = false)
      @data = with_cache(force) { Oj.load(request, :mode => :strict) }
    end

    # Enables caching on this connector.
    #
    # @param path [String] the path to the cache file.
    # @return [Object]
    def enable_caching(path)
      @cache = path
    end

    # Whether or not this connector will cache the response.
    #
    # @return [Boolean]
    def cache?
      !!@cache
    end

    # Disables caching on this connector.
    #
    # @return [false]
    def disable_caching
      @cache = false
    end

    protected

    # The request used for retrieving information from Steam.
    #
    # @return [IO]
    def request
      @_request ||= open(request_uri, headers)
    end

    # This handles caching the file, if it was requested.  Accepts a
    # single block, which it yields to only when the cache data wasn't
    # there.
    #
    # @return [Hash] the data.
    def with_cache(force = false)
      if cache
        headers['If-Modified-Since'] = cache[:last_modified].utc.rfc2822
      end

      if force || !cache
        write_cache yield
      else
        cache[:data]
      end

    rescue OpenURI::HTTPError => ex
      if ex.message =~ /\A304 Not Modified\z/
        return cache[:data]
      else
        raise ex
      end
    end

    # Loads the data from the cache file.
    #
    # @param force [Boolean] whether or not to force loading from the
    #   file again.
    def cache(force = false)
      return nil unless cache? && File.exists?(@cache)

      @_cache = if force || !@_cache
        File.open(@cache) { |f| Oj.load(f) }[request_uri.to_s]
      else
        @_cache
      end
    end

    # Writes the cache data to the file, and forces a reload of the
    # cache data in memory.
    #
    # @param data [Object] the data to store.
    # @return [Object] the data stored.
    def write_cache(data)
      return data unless cache?
      write_data = {
        request_uri.to_s => {
          :data => data,
          :last_modified => Time.now
        }
      }

      FileUtils.mkdir_p File.dirname(@cache)
      File.open(@cache, "w") do |f|
        f.write Oj.dump(write_data, :time_format => :ruby)
      end

      cache(true)
      data
    end
    
  end
end

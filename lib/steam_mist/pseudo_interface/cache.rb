require 'time'

module SteamMist
  class PseudoInterface

    # This allows the {Connector} to cache the data from the steam API.  Pretty
    # cool, eh?
    module Cache

      # This means that the cache module will use the HTTP headers for caching the
      # data.
      HTTP_CACHE = 0

      # This means that it'll use the .cache file, which means that if it's in the
      # file, it'll use it; this also means that any new data will be overwritten.
      FILE_CACHE = 1

      # This overwrites the {Connector}'s {#force_request!}, since it
      # inherits it from the parent.  Hopefully, it won't define it itself
      # otherwise this won't be called.
      #
      # @return [Hash]
      def force_request!(force = false)

        if force || @_type == Cache::HTTP_CACHE || !cache
          write_cache(super())
        else
          cache
        end

      rescue OpenURI::HTTPError => ex
        if ex.message =~ /\A304 Not Modified\z/
          return cache[:data]
        else
          raise ex
        end
      end

      # This takes in a path which defines where our cache file is.  It'll
      # store the data in the format:
      #     { "http://some.domain/path/to/resource": { :data => {}, :last_modified => Time } }
      # This also sets the 'If-Modified-Since' header if the cache file exists
      # and contains our data.
      #      
      # @param path [String]
      # @return [void]
      def enable_caching(path, type)
        @_path = path
        @_cache_key = request_uri.to_s
        @_type = type

        headers['If-Modified-Since'] = cache[:last_modified].utc.rfc2822 if \
          cache && type == Cache::HTTP_CACHE
      end

      # This checks the cache if the data exists.  If it does, it'll read
      # from it.
      #
      # @param force [Boolean] force it to load from the file.
      # @return [Hash, nil]
      def cache(force = false)
        return nil unless File.exists? @_path || ""

        if force || @_cache.nil?
          @_cache = File.open(@_path, "r") do |f|
            Oj.load f
          end[@_cache_key]
        else
          @_cache
        end

      rescue Oj::ParseError
        nil
      end

      private

      # This writes to the cache.
      #
      # @param data [Hash] the data to write.
      # @return [Hash] the data.
      def write_cache(data)
        return data unless @_path

        cache(true)
        write_data = generate_cache_data(data)

        File.open(@_path, "w") do |f|
          f.write Oj.dump(write_data, :time_format => :ruby)
        end

        data
      end

      # This generates cache data based on the passed value.  This includes
      # stuff like time.
      #
      # @return [Hash]
      def generate_cache_data(data)
        {
          @_cache_key => {
            :data => data.dup,
            :last_modified => Time.now
          }
        }
      end

    end
  end
end

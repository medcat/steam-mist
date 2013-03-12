module SteamMist
  class PseudoInterface

    # A representation of a Steam Web API method.
    class PseudoMethod

      # The version of the method.  Used for {RequestUri}.
      #
      # @return [Numeric] the version.
      attr_reader :version

      # The name of the method.
      #
      # @return [Symbol] the name.
      attr_reader :name

      # The interface that this method is a part of.
      #
      # @return [PseudoInterface] the interface.
      attr_reader :interface

      # The arguments passed along with the method.
      #
      # @return [Hash] the arguments.
      attr_reader :arguments

      # Whether or not the connector is going to implement caching.
      #
      # @return [Boolean]
      attr_reader :cached

      # Initialize the method.
      #
      # @param interface [PseudoInterface] the interface this method is a part
      #   of.  Used to help build the {RequestUri}.
      # @param method [Symbol] the name of the method.  See {#api_name} on how
      #   it's used.
      # @param version [Numeric] the version of the method.  Can be found on
      #   the steam web api wiki.
      def initialize(interface, method, version=1)
        @interface   = interface
        @name        = method
        @version     = version
        @arguments   = {}
        @cached      = false
      end

      # This merges the passed hash with the arguments.
      #
      # @param new_arguments [Hash] the arguments to be added.
      # @return [PseudoMethod] a {PseudoMethod} with the new arguments.
      def with_arguments(new_arguments)
        dup.with_arguments! new_arguments
      end

      # This merges the current arguments with the passed arguments.  This
      # modifies the instance it is called on.   Invalidates the current
      # connector.
      #
      # @param new_arguments [Hash] the arguments to merge with.
      # @return [self]
      def with_arguments!(new_arguments)
        @arguments.merge!(new_arguments)
        reset_connector
      end

      # This sets the version.
      #
      # @param new_version [Numeric] the version number to use.
      # @return [PseudoMethod] a {PseudoMethod} with the version set to the
      #   new version.
      def with_version(new_version)
        dup.with_version!(new_version)
      end

      # Sets the version of the current method.  This modifies the instance it
      # is called on.  Invalidates the current connector.
      #
      # @param new_version [Numeric] the version to set to.
      # @return [self]
      def with_version!(new_version)
        @version = new_version
        reset_connector
      end

      # This makes sure the connector is set up to cache its results.  Does not
      # modify the connector until #{get} is called.
      #
      # @param path [String] the path of the cache file.
      # @param type [Numeric] the type of caching to be performed.
      # @return [PseudoMethod] a {PseudoMethod} with caching.
      def with_caching(path, type = Cache::HTTP_CACHE)
        dup.with_caching!(path, type)
      end

      # This modifies the current method to make sure the connector is set up
      # to cache its results.  Invalidates the current connector.
      #
      # @param path [String] the path of the cache file.
      # @param type [Numeric] the type of caching to be performed.
      # @return [self]
      def with_caching!(path, type = Cache::HTTP_CACHE)
        @cached = [path, type]
        reset_connector
      end

      # This makes sure the connector is set up to not cache its results.
      #
      # @return [PseudoMethod] a {PseudoMethod} without caching.
      def without_caching
        dup.without_caching!
      end

      # This modifies the current method to make sure the connector is set up
      # to not cache its results.  Invalidates the current connector.
      #
      # @return [self]
      def without_caching!
        @cached = false
        reset_connector
      end

      # Open up a connector for use.  This is cached with this method.
      #
      # @return [Connector] the connector that will grab data.
      def get
        @_connector ||= begin
          connector = interface.session.connector.new(request_uri)

          if @cached
            connector.extend Cache
            connector.enable_caching *@cached
          end

          connector
        end
      end

      # Turns the method name into the name the Steam Web API uses.  It turns
      # the method name from snake case to camel case if the first character
      # isn't uppercase.  Otherwise, it uses the string form of it.
      #
      # @return [String] the Steam Web API compatible method name.
      def api_name
        @_api_name ||= begin
          str = name.to_s

          if str[0] =~ /[A-Z]/
            str
          else
            str.gsub!(/_[a-z]/) { |m| m[1].upcase }
            str[0] = str[0].upcase
            str
          end
        end
      end

      # This turns the method into its corresponding {RequestUri}.  It uses
      # {#api_name} and {PseudoInterface#api_name} to help create the uri.
      #
      # @return [RequestUri]
      def request_uri
        @_request_uri ||= RequestUri.new :interface => interface.api_name,
          :method    => api_name,
          :arguments => interface.session.default_arguments.dup.merge(arguments),
          :version   => version
      end

      # Pretty inspection.
      #
      # @return [String]
      def inspect
        "#<SteamMist::PseudoInterface::PseudoMethod #{interface.name}/#{name}>"
      end

      private

      # This is used to show that the connector is out of date; it forces the
      # method to use a seperate connector.
      #
      # @return [self]
      def reset_connector
        @_connector = nil
        @_request_uri = nil
        self
      end

    end
  end
end

module SteamMist

  # This represents a request that may be made to the steam api.  It is mainly
  # used for obtaining paths to request to.
  class RequestUri

    extend Forwardable

    # This is the interface the request will be made to, like +ISteamUser+.
    #
    # @return [String]
    attr_accessor :interface

    # This is the method of the interface the request will be made to.
    #
    # @return [String]
    attr_accessor :method

    # These are the arguments that will be passed for the request.
    #
    # @return [Enumerable]
    attr_accessor :arguments

    # The version of the method to request.
    #
    # @return [Numeric]
    attr_accessor :version

    # The domain to make the reuqest to.
    #
    # @return [String]
    attr_accessor :domain

    # Initialize the request.  Can take a hash.  Options for the hash can be
    # `:interface`, `:method`, `:version`, `:domain` and `:arguments`.  
    # Anything else will cause an  argument error.  See the attributes for 
    # each respectively on what they're for.
    #
    # @param options [Hash] the options to be used.
    def initialize(options)
      {
        :interface => "", 
        :method => "", 
        :arguments => {}, 
        :version   => 0,  
        :domain => "api.steampowered.com"
       }.merge(options).each do |k, v|
        if respond_to? "#{k}="
          send "#{k}=", v
        else
          raise ArgumentError, "don't know how to handle #{k}!"
        end
      end
    end

    # Takes the request data and formats it into an URI.
    #
    # @return [URI] the URI of the request.
    def format_uri
      basic = "http://%s/%s/%s/v%04d" % [domain, interface, method, version]

      uri = URI(basic)
      uri.query = URI.encode_www_form(arguments)

      uri
    end

    # Outputs a string version of the request.
    #
    # @return [String] the fully formated URL of the request.
    def to_s
      format_uri.to_s
    end

    def_delegator :format_uri, :open
  end
end

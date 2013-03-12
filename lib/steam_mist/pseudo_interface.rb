require 'steam_mist/pseudo_interface/cache'
require 'steam_mist/pseudo_interface/pseudo_method'

module SteamMist
  # This basically represents an interface for the Web API.
  class PseudoInterface

    # The interface's name that this is representing.  This should be in
    # underscore form.
    # 
    # @return [Symbol] the name of the interface.
    attr_reader :name

    # The session that the interface is running under.  This is used mainly for
    # the connector.
    #
    # @return [Session]
    attr_reader :session

    # Initialize the pseudointerface with the interface name.  See {#api_name}
    # for information about how this is handled.
    #
    # @param session [Session] the session the interface is a part of.
    # @param interface_name [Symbol] the interface name.
    def initialize(session, interface_name)
      @name     = interface_name
      @session  = session
      @_methods = {}
    end

    # Grab a method from this interface.  All methods are cached, so successive
    # calls with the same arguments return the same object.
    #
    # @param method_name [Symbol] the name of the method.
    # @param version [Numeric] the version of the method.
    # @return [PseudoMethod]
    def get_method(method_name, version=1)
      @_methods["#{method_name}/#{version}"] ||= 
        PseudoMethod.new(self, method_name, version)
    end

    # Turns the interface name into the corresponding api name.  If the
    # interface starts with an `I`, it makes no modifications to it (other than
    # turning it into a string).  If it doesn't, however, it turns it from
    # snake case to camel case (i.e. `some_interface` to `SomeInterface`).
    # It then adds an `I` to the front of it.
    #
    # @return [String] the API name used by the Steam Web API.
    def api_name
      @_api_name ||= begin
        str = name.to_s

        if str[0] == "I"
          str
        else
          str.gsub!(/_([a-z])/) { |m| m[1].upcase }
          str[0] = str[0].upcase
          "I#{str}"
        end
      end
    end

    # Pretty inspection.
    #
    # @return [String]
    def inspect
      "#<SteamMist::PseudoInterface #{name}>"
    end

  end
end

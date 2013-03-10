module SteamMist

	# The session is used as a starting point for connecting to the Steam API.
	class Session

		# The connector that the session is going to use.
		#
		# @return [Class] the connector.
		attr_accessor :connector

		# The default arguments that the session will use.
		#
		# @return [Hash]
		attr_accessor :default_arguments

		# Initialize.
		#
		# @param connector [Class] the connector (should be subclass of {Connector}).
		def initialize(connector)
			@connector   = connector
			@_interfaces = {}
			@default_arguments = {}
		end

		# Grabs an interface for use.  These are cached, so every call with the
		# same argument returns the same object.
		#
		# @param interface [Symbol] the interface name.
		# @return [PseudoInterface]
		def get_interface(interface)
			@_interfaces[interface] ||= PseudoInterface.new(self, interface)
		end

		# pretty inspection
		def inspect
			"#<SteamMist::Session #{connector.inspect}>"
		end

	end
end

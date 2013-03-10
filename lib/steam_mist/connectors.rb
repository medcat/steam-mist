module SteamMist

	# The connectors that will be used by SteamMist.
	module Connectors

		autoload :LazyConnector, "steam_mist/connectors/lazy_connector"

		autoload :EagerConnector, "steam_mist/connectors/eager_connector"

	end
end

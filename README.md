# SteamMist
Steam Mist (for the lack of a better name) is a library for interfacing with
the Steam Web API.  It handles the HTTP requests for you while providing a
nice API for you to use.

Have some code samples:

	require 'steam_mist'
	session = SteamMist::Session.new SteamMist::Connectors::LazyConnector
	session.default_arguments.merge! :key => "XXXXXXXXXXXXXXXXXXX", :format => :json
	interface = session.get_interface(:player_service)
	method = interface.get_method(:get_recently_played_games).with_version(1) \
		.with_arguments(:steamid => "76561198025418738")

	method.request_uri # => http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=XXXXXXXXXXXXXXXXX&steamid=76561197960434622&format=json
	# It's a URI object so #inspect doesn't include the quotes ;)
	method.get # => #<SteamMist::Connectors::LazyConnector>
	method.get.force_request! # => our json data
	


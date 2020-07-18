# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :loggregate,
  ecto_repos: [Loggregate.Repo]

# Configures the endpoint
config :loggregate, LoggregateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7O7qqAqsTBL2c7Y0+8mBM2gLqQkUPBm0trBcpHsoh2ZprTBQeUfFJkh353+25yam",
  live_view: [signing_salt: "HipaJWD0AOxWMVJc/EzWT1SVv7eglA5ucsIEDVnWCz8HhjzGpHBtCOwa18B4qE+Q"],
  render_errors: [view: LoggregateWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Loggregate.PubSub

config :loggregate, Loggregate.ElasticSearch,
  elasticsearch_url: "http://localhost:9200"

config :elastix,
  shield: true,
  username: "elastic",
  password: "9KockPcnwY6dH6ZZKhur"

maxmind_key = System.get_env("MAXMIND_KEY")
if maxmind_key do
  config :locus, :license_key, maxmind_key
else
  config :locus, :license_key, nil
end

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  slimeex: PhoenixSlime.LiveViewEngine

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

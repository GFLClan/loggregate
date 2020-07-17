# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :loggregate, Loggregate.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_salt =
  System.get_env("LIVE_VIEW_SALT") ||
    raise """
    environment variable LIVE_VIEW_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

elastic_user =
  System.get_env("ELASTIC_USER") ||
    raise """
    environment variable ELASTIC_USER is missing.
    You must provide an ElasticSearch user
    """

elastic_password =
  System.get_env("ELASTIC_PASSWORD") ||
    raise """
    environment variable ELASTIC_PASSWORD is missing.
    You must provide an ElasticSearch user
    """

maxmind_key = System.get_env("MAXMIND_KEY")
if maxmind_key do
  config: :locus, :license_key maxmind_key
end

config :loggregate, LoggregateWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: live_view_salt]

config :elastix,
  shield: true,
  username: elastic_user,
  password: elastic_password

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :loggregate, LoggregateWeb.Endpoint, server: true

#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

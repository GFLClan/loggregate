defmodule LoggregateWeb.Router do
  use LoggregateWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LoggregateWeb.LayoutView, :root}
    plug LoggregateWeb.Plugs.GetUser
    plug LoggregateWeb.Plugs.GetIndexSize
  end

  pipeline :authenticate do
    plug :browser
    plug Loggregate.Plugs.LoginRequired
  end

  steamex_route_auth()

  scope "/", LoggregateWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/logout", PageController, :do_logout
  end

  scope "/dashboard", LoggregateWeb do
    pipe_through :authenticate

    get "/", SearchController, :index
    get "/log/:log_id", SearchController, :log_detail
    live "/live", DashboardLive

    scope "/settings" do
      pipe_through LoggregateWeb.Plugs.AdminOnly

      get "/users", SettingsController, :users
      get "/users/new", SettingsController, :new_user
      put "/users/new", SettingsController, :create_user
      get "/users/:id", SettingsController, :user
      put "/users/:id", SettingsController, :save_user
      delete "/users/:id", SettingsController, :delete_user

      get "/servers", SettingsController, :servers
      get "/servers/new", SettingsController, :new_server
      put "/servers/new", SettingsController, :create_server
      get "/servers/:id", SettingsController, :server
      put "/servers/:id", SettingsController, :save_server
      post "/servers/:id/refresh_token", SettingsController, :refresh_server_token
      delete "/servers/:id", SettingsController, :delete_server

      get "/grok/patterns", SettingsController, :grok_patterns
      get "/grok/patterns/new", SettingsController, :new_grok_pattern
      post "/grok/patterns/new", SettingsController, :new_grok_pattern
      get "/grok/patterns/:id", SettingsController, :edit_grok_pattern
      put "/grok/patterns/:id", SettingsController, :save_grok_pattern
      delete "/grok/patterns/:id", SettingsController, :delete_grok_pattern
      get "/grok/parsers", SettingsController, :grok_parsers
      get "/grok/parsers/new", SettingsController, :new_grok_parser
      post "/grok/parsers/new", SettingsController, :new_grok_parser
      get "/grok/parsers/:id", SettingsController, :edit_grok_parser
      put "/grok/parsers/:id", SettingsController, :save_grok_parser
      delete "/grok/parsers/:id", SettingsController, :delete_grok_parser
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LoggregateWeb do
  #   pipe_through :api
  # end
end

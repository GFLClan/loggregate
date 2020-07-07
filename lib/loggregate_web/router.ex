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

    get "/settings/users", SettingsController, :users
    get "/settings/users/new", SettingsController, :new_user
    get "/settings/users/:id", SettingsController, :user
    put "/settings/users/:id", SettingsController, :save_user
    get "/settings/servers", SettingsController, :servers
    get "/settings/servers/new", SettingsController, :new_server
    get "/settings/servers/:id", SettingsController, :server
  end

  # Other scopes may use custom stacks.
  # scope "/api", LoggregateWeb do
  #   pipe_through :api
  # end
end

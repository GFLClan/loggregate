defmodule LoggregateWeb.Plugs.GetUser do
  use LoggregateWeb, :controller
  alias Loggregate.Accounts

  def init(_params) do

  end

  def call(conn, _params) do
    steamid = get_session(conn, :steamex_steamid64)
    if steamid != nil do
      case Accounts.get_by_steamid(steamid) do
        %Loggregate.Accounts.User{} = user ->
          assign(conn, :user, user)
        _ ->
          conn
      end
    else
      conn
    end
  end
end

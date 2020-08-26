defmodule LoggregateWeb.SettingsController do
  use LoggregateWeb, :controller
  alias Loggregate.{Accounts, ServerMapping, Grok}

  def users(conn, _params) do
    users = Accounts.list_users()
    render(conn, "users.html", users: users, settings: :users)
  end

  def user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      render(conn, "user.html", changeset: Accounts.User.changeset(user, %{}), settings: :users)
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def save_user(conn, %{"id" => id, "user" => target_user}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      case Accounts.update_user(user, target_user) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :users))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "user.html", changeset: changeset, settings: :users)
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def new_user(conn, _params) do
    changeset = %Accounts.User{} |> Accounts.User.changeset(%{})
    render(conn, "new_user.html", changeset: changeset, settings: :users)
  end

  def create_user(conn, %{"user" => new_user}) do
    case Accounts.create_user(new_user) do
      {:ok, user} ->
        redirect(conn, to: Routes.settings_path(conn, :user, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_user.html", changeset: changeset, settings: :users)
    end
  end

  def delete_user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :users))
        {:error, _err} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def servers(conn, _params) do
    servers = ServerMapping.list_servers()
    render(conn, "servers.html", servers: servers, settings: :servers)
  end

  def server(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      render(conn, "server.html", changeset: ServerMapping.ServerMapping.changeset(server, %{}), settings: :servers)
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def save_server(conn, %{"id" => id, "server_mapping" => target_server}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      case ServerMapping.update_server_mapping(server, target_server) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :servers))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "server.html", changeset: changeset, settings: :servers)
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def refresh_server_token(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      <<new_id::unsigned-24>> = :crypto.strong_rand_bytes(3)
      {:ok, _} = ServerMapping.update_server_mapping(server, %{server_id: new_id})
      redirect(conn, to: Routes.settings_path(conn, :server, server))
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def new_server(conn, _params) do
    <<server_id::unsigned-24>> = :crypto.strong_rand_bytes(3)
    changeset = %ServerMapping.ServerMapping{} |> ServerMapping.ServerMapping.changeset(%{server_id: server_id})
    render(conn, "new_server.html", changeset: changeset, settings: :servers)
  end

  def create_server(conn, %{"server_mapping" => server}) do
    case ServerMapping.create_server_mapping(server) do
      {:ok, server} ->
        redirect(conn, to: Routes.settings_path(conn, :server, server))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_server.html", changeset: changeset, settings: :servers)
    end
  end

  def delete_server(conn, %{"id" => id}) do
    with server when not is_nil(server) <- ServerMapping.get_server(id) do
      case ServerMapping.delete_server_mapping(server) do
        {:ok, _user} ->
          redirect(conn, to: Routes.settings_path(conn, :servers))
        {:error, _err} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def grok_patterns(conn, _params) do
    render(conn, "grok_patterns.html", patterns: Grok.list_grok_patterns(), settings: :grok, grok: :patterns)
  end

  def edit_grok_pattern(conn, %{"id" => id}) do
    pattern = Grok.get_pattern!(id)
    render(conn, "grok_pattern.html", changeset: Grok.Pattern.changeset(pattern, %{}), settings: :grok, grok: :patterns)
  end

  def save_grok_pattern(conn, %{"id" => id, "pattern" => changeset}) do
    pattern = Grok.get_pattern!(id)
    case Grok.update_pattern(pattern, changeset) do
      {:ok, _} ->
        Grok.reload_config_cache()
        redirect(conn, to: Routes.settings_path(conn, :grok_patterns))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
    end
  end

  def new_grok_pattern(conn, %{"pattern" => changeset}) do
    case Grok.create_pattern(changeset) do
      {:ok, pattern} ->
        Grok.reload_config_cache()
        redirect(conn, to: Routes.settings_path(conn, :edit_grok_pattern, pattern))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
    end
  end

  def new_grok_pattern(conn, _) do
    changeset = %Grok.Pattern{} |> Grok.Pattern.changeset(%{})
    render(conn, "new_grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
  end

  def delete_grok_pattern(conn, %{"id" => id}) do
    pattern = Grok.get_pattern!(id)
    case Grok.delete_pattern(pattern) do
      {:ok, _} ->
        redirect(conn, to: Routes.settings_path(conn, :grok_patterns))
      {:error, _} ->
        put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
    end
  end

  def grok_parsers(conn, _params) do
    render(conn, "grok_parsers.html", msg_patterns: Grok.list_grok_msg_patterns(), settings: :grok, grok: :parsers)
  end

  def edit_grok_parser(conn, %{"id" => id}) do
    pattern = Grok.get_message_pattern!(id)
    render(conn, "grok_parser.html", changeset: Grok.MessagePattern.changeset(pattern, %{}), settings: :grok, grok: :parsers)
  end

  def save_grok_parser(conn, %{"id" => id, "message_pattern" => changeset}) do
    pattern = Grok.get_message_pattern!(id)
    case Grok.update_message_pattern(pattern, changeset) do
      {:ok, _} ->
        Grok.reload_config_cache()
        redirect(conn, to: Routes.settings_path(conn, :grok_parsers))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
    end
  end

  def new_grok_parser(conn, %{"message_pattern" => changeset}) do
    case Grok.create_message_pattern(changeset) do
      {:ok, pattern} ->
        Grok.reload_config_cache()
        redirect(conn, to: Routes.settings_path(conn, :edit_grok_parser, pattern))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
    end
  end

  def new_grok_parser(conn, _) do
    changeset = %Grok.MessagePattern{} |> Grok.MessagePattern.changeset(%{})
    render(conn, "new_grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
  end

  def delete_grok_parser(conn, %{"id" => id}) do
    pattern = Grok.get_message_pattern!(id)
    case Grok.delete_message_pattern(pattern) do
      {:ok, _} ->
        redirect(conn, to: Routes.settings_path(conn, :grok_parsers))
      {:error, _} ->
        put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
    end
  end
end

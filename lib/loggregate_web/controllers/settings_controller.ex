defmodule LoggregateWeb.SettingsController do
  use LoggregateWeb, :controller
  alias Loggregate.{Accounts, Permissions, Repo, Grok}
  require Loggregate.Permissions

  def users(conn, _params) do
    users = Permissions.get_managed_users(conn.assigns[:user])
    render(conn, "users.html", users: users, settings: :users)
  end

  def user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      Permissions.user_has_permission(conn, user, :manage) do
        render(conn, "user.html", changeset: Accounts.User.changeset(user, %{}), indices: Permissions.get_managed_indices(conn.assigns[:user]), settings: :users)
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def save_user(conn, %{"id" => id, "user" => target_user}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      Permissions.user_has_permission(conn, user, :manage) do
        new_user = Accounts.User.changeset(user, target_user)
          |> Permissions.sanitize_changeset(conn)

        case Repo.update(new_user) do
          {:ok, _user} ->
            redirect(conn, to: Routes.settings_path(conn, :users))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "user.html", changeset: changeset, settings: :users)
        end
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
    new_user = %Accounts.User{} |> Accounts.User.changeset(new_user)
      |> Permissions.sanitize_changeset(conn)

    case Repo.insert(new_user) do
      {:ok, user} ->
        redirect(conn, to: Routes.settings_path(conn, :user, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_user.html", changeset: changeset, settings: :users)
    end
  end

  def delete_user(conn, %{"id" => id}) do
    with user when not is_nil(user) <- Accounts.get_user(id) do
      Permissions.user_has_permission(conn, user, :manage) do
        case Accounts.delete_user(user) do
          {:ok, _user} ->
            redirect(conn, to: Routes.settings_path(conn, :users))
          {:error, _err} ->
            put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
        end
      end
    else
      nil -> put_status(conn, 404) |> put_view(LoggregateWeb.ErrorView) |> render(:"404")
    end
  end

  def indices(conn, _params) do
    indices = Permissions.get_managed_indices(conn.assigns[:user])
    render(conn, "indices.html", indices: indices, settings: :indices)
  end

  def new_index(conn, _params) do
    Permissions.is_admin?(conn) do
      render(conn, "new_index.html", settings: :indices)
    end
  end

  def impersonate(conn, %{"steamid" => steamid}) do
    Permissions.is_admin?(conn) do
      put_session(conn, :steamex_steamid64, steamid)
      |> redirect(to: Routes.search_path(conn, :index))
    end
  end

  def grok_patterns(conn, _params) do
    Permissions.is_admin?(conn) do
      render(conn, "grok_patterns.html", patterns: Grok.list_grok_patterns(), settings: :grok, grok: :patterns)
    end
  end

  def edit_grok_pattern(conn, %{"id" => id}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_pattern!(id)
      render(conn, "grok_pattern.html", changeset: Grok.Pattern.changeset(pattern, %{}), settings: :grok, grok: :patterns)
    end
  end

  def save_grok_pattern(conn, %{"id" => id, "pattern" => changeset}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_pattern!(id)
      case Grok.update_pattern(pattern, changeset) do
        {:ok, _} ->
          Grok.reload_config_cache()
          redirect(conn, to: Routes.settings_path(conn, :grok_patterns))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
      end
    end
  end

  def new_grok_pattern(conn, %{"pattern" => changeset}) do
    Permissions.is_admin?(conn) do
      case Grok.create_pattern(changeset) do
        {:ok, pattern} ->
          Grok.reload_config_cache()
          redirect(conn, to: Routes.settings_path(conn, :edit_grok_pattern, pattern))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new_grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
      end
    end
  end

  def new_grok_pattern(conn, _) do
    Permissions.is_admin?(conn) do
      changeset = %Grok.Pattern{} |> Grok.Pattern.changeset(%{})
      render(conn, "new_grok_pattern.html", changeset: changeset, settings: :grok, grok: :patterns)
    end
  end

  def delete_grok_pattern(conn, %{"id" => id}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_pattern!(id)
      case Grok.delete_pattern(pattern) do
        {:ok, _} ->
          redirect(conn, to: Routes.settings_path(conn, :grok_patterns))
        {:error, _} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    end
  end

  def grok_parsers(conn, _params) do
    Permissions.is_admin?(conn) do
      render(conn, "grok_parsers.html", msg_patterns: Grok.list_grok_msg_patterns(), settings: :grok, grok: :parsers)
    end
  end

  def edit_grok_parser(conn, %{"id" => id}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_message_pattern!(id)
      render(conn, "grok_parser.html", changeset: Grok.MessagePattern.changeset(pattern, %{}), settings: :grok, grok: :parsers)
    end
  end

  def save_grok_parser(conn, %{"id" => id, "message_pattern" => changeset}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_message_pattern!(id)
      case Grok.update_message_pattern(pattern, changeset) do
        {:ok, _} ->
          Grok.reload_config_cache()
          redirect(conn, to: Routes.settings_path(conn, :grok_parsers))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
      end
    end
  end

  def new_grok_parser(conn, %{"message_pattern" => changeset}) do
    Permissions.is_admin?(conn) do
      case Grok.create_message_pattern(changeset) do
        {:ok, pattern} ->
          Grok.reload_config_cache()
          redirect(conn, to: Routes.settings_path(conn, :edit_grok_parser, pattern))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new_grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
      end
    end
  end

  def new_grok_parser(conn, _) do
    Permissions.is_admin?(conn) do
      changeset = %Grok.MessagePattern{} |> Grok.MessagePattern.changeset(%{})
      render(conn, "new_grok_parser.html", changeset: changeset, settings: :grok, grok: :parsers)
    end
  end

  def delete_grok_parser(conn, %{"id" => id}) do
    Permissions.is_admin?(conn) do
      pattern = Grok.get_message_pattern!(id)
      case Grok.delete_message_pattern(pattern) do
        {:ok, _} ->
          redirect(conn, to: Routes.settings_path(conn, :grok_parsers))
        {:error, _} ->
          put_status(conn, 500) |> put_view(LoggregateWeb.ErrorView) |> render(:"500")
      end
    end
  end
end

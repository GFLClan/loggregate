defmodule Loggregate.LogSearch do
  import Ecto.Query
  alias Loggregate.LikeQuery
  alias Loggregate.ServerMapping

  def search_line(search_term) do
    dynamic(fragment("(to_tsvector('english', log_data ->> 'line') @@ plainto_tsquery('english', ?))", ^search_term))
  end

  def search_message(search_term) do
    dynamic(fragment("(to_tsvector('english', log_data ->> 'message') @@ plainto_tsquery('english', ?))", ^search_term))
  end

  def search_server(server_id) do
    dynamic(fragment("(log_data -> 'server')::integer") == ^server_id)
  end

  def search_type(type) do
    dynamic(fragment("(jsonb_exists(log_data -> 'type', ?))", ^type))
  end

  def search_cvar(cvar) do
    dynamic(ilike(fragment("log_data -> 'cvar' ->> 'name'"), ^"%#{LikeQuery.like_sanitize(cvar)}%"))
  end

  def search_name(name) do
    dynamic(ilike(fragment("log_data -> 'who' ->> 'name'"), ^"%#{LikeQuery.like_sanitize(name)}%") or fragment("to_tsvector('english', log_data -> 'who' ->> 'name') @@ plainto_tsquery('english', ?)", ^name))
  end

  def search_steamid(steamid) do
    dynamic(ilike(fragment("log_data -> 'who' ->> 'steamid'"), ^"%#{LikeQuery.like_sanitize(steamid)}%"))
  end

  def search_address(address) do
    dynamic(ilike(fragment("(log_data ->> 'address')"), ^"%#{LikeQuery.like_sanitize(address)}%"))
  end

  def build_search_conditions(search_string) do
    {opts, args, _} = OptionParser.parse(OptionParser.split(search_string), strict: [type: :string, cvar: :string, server: :string, name: :string, steamid: :string, address: :string])
    conditions = true
    conditions = unless opts[:cvar] == nil do
      dynamic(^search_cvar(opts[:cvar]) and ^conditions)
    else
      conditions
    end

    conditions = unless opts[:server] == nil do
      server = ServerMapping.search_by_server_name(opts[:server])
      if server != nil do
        dynamic(^search_server(server.server_id) and ^conditions)
      else
        conditions
      end
    else
      conditions
    end

    conditions = unless opts[:type] == nil do
      dynamic(^search_type(opts[:type]) and ^conditions)
    else
      conditions
    end

    conditions = unless opts[:name] == nil do
      dynamic(^search_name(opts[:name]) and ^conditions)
    else
      conditions
    end

    conditions = unless opts[:steamid] == nil do
      dynamic(^search_steamid(opts[:steamid]) and ^conditions)
    else
      conditions
    end

    conditions = unless opts[:address] == nil do
      dynamic(^search_address(opts[:address]) and ^conditions)
    else
      conditions
    end

    line_search = Enum.join(args, " ")
    conditions = unless line_search == "" do
      dynamic(^search_line(line_search) or ^search_message(line_search) and ^conditions)
    else
      conditions
    end

    conditions
  end
end

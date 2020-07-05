defmodule Loggregate.LogSearch do
  import Ecto.Query
  alias Loggregate.LikeQuery
  alias Loggregate.ServerMapping
  alias Loggregate.LogReceiver.ParsedLogEntry

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

  def parse_search_string(search_string) do
    OptionParser.parse(OptionParser.split(search_string), strict: [type: :string, cvar: :string, server: :string, name: :string, steamid: :string, address: :string])
  end

  def build_search_conditions(search_string) do
    {opts, args, _} = parse_search_string(search_string)
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
      dynamic(^dynamic(^search_line(line_search) or ^search_message(line_search)) and ^conditions)
    else
      conditions
    end

    conditions
  end

  def build_search_predicate(search_string) do
    {opts, args, _} = parse_search_string(search_string)
    predicate = fn %ParsedLogEntry{} = _entry ->
      true
    end

    predicate = unless opts[:cvar] == nil do
      predicate_cvar(opts[:cvar], predicate)
    else
      predicate
    end

    predicate = unless opts[:server] == nil do
      predicate_server_name(opts[:server], predicate)
    else
      predicate
    end

    predicate = unless opts[:type] == nil do
      predicate_type(opts[:type], predicate)
    else
      predicate
    end

    predicate = unless opts[:name] == nil do
      predicate_name(opts[:name], predicate)
    else
      predicate
    end

    predicate = unless opts[:steamid] == nil do
      predicate_steam_id(opts[:steamid], predicate)
    else
      predicate
    end

    line_search = Enum.join(args, " ")
    predicate = unless line_search == "" do
      predicate_line(line_search, predicate)
    else
      predicate
    end

    predicate
  end

  def predicate_cvar(cvar_name, predicate) do
    fn %ParsedLogEntry{} = entry ->
      entry.log_data.type == :cvar and downcase_cmp(entry.log_data.cvar.name, cvar_name) and predicate.(entry)
    end
  end

  def predicate_server_name(server_name, predicate) do
    fn %ParsedLogEntry{} = entry ->
      server = ServerMapping.search_by_server_name(server_name)
      if server != nil do
        entry.server_id == server.server_id and predicate.(entry)
      else
        predicate
      end
    end
  end

  def predicate_type(type, predicate) do
    fn %ParsedLogEntry{} = entry ->
      to_string(entry.log_data.type) == String.downcase(type) and predicate.(entry)
    end
  end

  def predicate_name(name, predicate) do
    fn %ParsedLogEntry{} = entry ->
      Map.has_key?(entry.log_data, :who) and FuzzyCompare.similarity(entry.log_data.who.name, name) > 0.9 and predicate.(entry)
    end
  end

  def predicate_steam_id(steam_id, predicate) do
    fn %ParsedLogEntry{} = entry ->
      Map.has_key?(entry.log_data, :who) and downcase_cmp(entry.log_data.who.steamid, steam_id) and predicate.(entry)
    end
  end

  def predicate_line(line_search, predicate) do
    fn %ParsedLogEntry{} = entry ->
      FuzzyCompare.similarity(entry.log_data.line, line_search) > 0.9 and predicate.(entry)
    end
  end

  def downcase_cmp(a, b) do
    String.downcase(a) == String.downcase(b)
  end
end

defmodule Loggregate.LogSearch do
  alias Loggregate.ServerMapping
  alias Loggregate.LogReceiver.ParsedLogEntry
  alias Loggregate.Accounts.User
  alias Loggregate.Permissions

  def parse_search_string(search_string) do
    OptionParser.parse(OptionParser.split(search_string), strict: [type: :string, cvar: :string, server: :string, name: :string, steamid: :string, address: :string])
  end

  def build_es_query(search_string, {start_date, end_date}, %User{} = user) do
    {opts, args, _} = parse_search_string(search_string)
    conditions = []
    filter = [%{range: %{timestamp: %{gte: start_date, lte: end_date}}}]
    filter = filter ++ Permissions.get_es_permissions_filter(user)

    conditions = unless opts[:cvar] == nil do
      [%{match: %{"cvar.name": %{query: opts[:cvar]}}} | conditions]
    else
      conditions
    end

    filter = unless opts[:server] == nil do
      server = ServerMapping.search_by_server_name(opts[:server])
      if server != nil do
        [%{term: %{server: server.server_id}} | filter]
      else
        [%{term: %{server: opts[:server]}} | filter]
      end
    else
      filter
    end

    filter = unless opts[:type] == nil do
      [%{match: %{type: %{query: opts[:type]}}} | filter]
    else
      filter
    end

    conditions = unless opts[:name] == nil do
      [%{fuzzy: %{"who.name": opts[:name]}} | conditions]
    else
      conditions
    end

    filter = unless opts[:steamid] == nil do
      [%{match: %{"who.steamid": %{query: opts[:steamid]}}} | filter]
    else
      filter
    end

    line_search = Enum.join(args, " ")
    conditions = unless line_search == "" do
      [%{bool: %{should: [%{match: %{line: %{query: line_search, operator: "AND"}}}, %{fuzzy: %{message: line_search}}]}} | conditions]
    else
      conditions
    end

    %{bool: %{must: conditions, filter: filter}}
  end

  def build_search_predicate(_, nil) do
    fn _ ->
      false
    end
  end

  def build_search_predicate(search_string, %User{} = user) do
    {opts, args, _} = parse_search_string(search_string)
    predicate = Permissions.get_permissions_predicate(user)

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

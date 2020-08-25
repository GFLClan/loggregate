defmodule Loggregate.LogSearch.ESCompileMacros do
  defmacro def_leaf_operator(struct, body) do
    quote do
      def compile_es_query(%unquote(struct){left_side: %_{ident: lhs}, right_side: %_{value: rhs}}, query) do
        {lhs, rhs} = transform_ident(lhs, rhs)
        [%{bool: unquote(body).(lhs, rhs)} | query]
      end
    end
  end

  defmacro def_leaf_predicate(struct, operator) do
    quote do
      alias Loggregate.LogReceiver.ParsedLogEntry
      def compile_predicate(%unquote(struct){left_side: %_{ident: ident}, right_side: %_{value: value}}, predicate) do
        {ident, value} = transform_ident(ident, value)
        fn %ParsedLogEntry{} = entry ->
          flat_entry = Map.put(entry.log_data, :server, entry.server_id)
          unquote(operator).(flat_entry[String.to_atom(ident)], value) and predicate.(entry)
        end
      end
    end
  end

  defmacro __using__(_params) do
    quote do
      alias Loggregate.LogSearch.ESCompileMacros
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.Equals, &(%{must: %{match: Map.put(%{}, &1, &2)}}))
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.NotEquals, &(%{must: %{match: Map.put(%{}, &1, &2)}}))
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.LessThan, &(%{must: %{range: Map.put(%{}, &1, %{lt: &2})}}))
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.LessThanEquals, &(%{must: %{range: Map.put(%{}, &1, %{lt: &2})}}))
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.GreaterThan, &(%{must: %{range: Map.put(%{}, &1, %{lt: &2})}}))
      ESCompileMacros.def_leaf_operator(DreaeQL.Operators.GreaterThanEquals, &(%{must: %{range: Map.put(%{}, &1, %{lt: &2})}}))

      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.Equals, &Kernel.==/2)
      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.NotEquals, &Kernel.!=/2)
      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.LessThanEquals, &Kernel.<=/2)
      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.GreaterThanEquals, &Kernel.>=/2)
      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.GreaterThan, &Kernel.>/2)
      ESCompileMacros.def_leaf_predicate(DreaeQL.Operators.LessThanEquals, &Kernel.</2)
    end
  end
end
defmodule Loggregate.LogSearch do
  alias Loggregate.ServerMapping
  alias Loggregate.LogReceiver.ParsedLogEntry
  alias Loggregate.Permissions

  def build_es_query(search_string, {start_date, end_date}, %User{} = user) do
    permissions_fitler = Permissions.get_es_permissions_filter(user)
    try do
      {ast, []} = DreaeQL.parse(search_string)
      {:ok, %{bool: %{must: compile_es_query(ast), filter: [%{range: %{timestamp: %{gte: start_date, lte: end_date}}} | permissions_fitler]}}}
    rescue
      _e -> {:error, nil}
    end
  end

  def compile_es_query(ast) do
    compile_es_query(ast, [])
  end

  def compile_es_query(%DreaeQL.Operators.And{left_side: lhs, right_side: rhs}, query) do
    must = compile_es_query(lhs)

    [%{bool: %{must: compile_es_query(rhs, must)}} | query]
  end
  def compile_es_query(%DreaeQL.Operators.Or{left_side: lhs, right_side: rhs}, query) do
    must = compile_es_query(lhs)

    [%{bool: %{should: compile_es_query(rhs, must)}} | query]
  end
  def compile_es_query(%DreaeQL.Operators.Not{expr: expr}, query) do
    [%{bool: %{must_not: compile_es_query(expr)}} | query]
  end
  use Loggregate.LogSearch.ESCompileMacros

  def transform_ident("steamid", value), do: {"who.steamid", value}
  def transform_ident("name", value), do: {"who.name", value}
  def transform_ident("server", value) do
    case ServerMapping.search_by_server_name(value) do
      nil -> {"server", value}
      server -> {"server", server.server_id}
    end
  end
  def transform_ident(ident, value), do: {ident, value}

  def build_search_predicate(_, nil), do: fn _ -> false end

  def build_search_predicate(search_string, %User{} = user) do
    permissions_predicate = Permissions.get_permissions_predicate(user)
    try do
      {ast, []} = DreaeQL.parse(search_string)
      {:ok, compile_predicate(ast, permissions_predicate)}
    rescue
      _e -> {:error, nil}
    end
  end

  def compile_predicate(%DreaeQL.Operators.And{left_side: left_side, right_side: right_side}, predicate) do
    fn %ParsedLogEntry{} = entry ->
      compile_predicate(left_side).(entry) and compile_predicate(right_side).(entry) and predicate.(entry)
    end
  end
  def compile_predicate(%DreaeQL.Operators.Or{left_side: left_side, right_side: right_side}, predicate) do
    fn %ParsedLogEntry{} = entry ->
      compile_predicate(left_side).(entry) or compile_predicate(right_side).(entry) and predicate.(entry)
    end
  end
  def compile_predicate(%DreaeQL.Operators.Not{expr: expr}, predicate) do
    fn %ParsedLogEntry{} = entry ->
      not compile_predicate(expr).(entry) and predicate.(entry)
    end
  end
end

defmodule LoggregateWeb.SearchController do
  use LoggregateWeb, :controller
  import Ecto.Query
  alias Loggregate.{Repo, LogEntry, LogSearch}
  alias Loggregate.ServerMapping.ServerMapping

  def index(conn, %{"query" => query, "date_range" => date_range, "after" => after_id}) do
    {start_date, end_date} = parse_date_range(date_range)

    results = search_log_entries(LogSearch.build_search_conditions(query), {start_date, end_date}, after_id)
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: query)
  end

  def index(conn, %{"query" => query, "date_range" => date_range}) do
    {start_date, end_date} = parse_date_range(date_range)
    results = search_log_entries(LogSearch.build_search_conditions(query), {start_date, end_date})
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: query)
  end

  def index(conn, %{"query" => query}) do
    {start_date, end_date} = default_date_range()
    results = search_log_entries(LogSearch.build_search_conditions(query), {start_date, end_date})
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: query)
  end

  def index(conn, _params) do
    {start_date, end_date} = default_date_range()
    results = search_log_entries(true, {start_date, end_date})
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: "")
  end

  def log_detail(conn, %{"log_id" => id}) do
    log_entry = Repo.one!(from e in LogEntry, where: e.id == ^id, join: s in ServerMapping, on: s.server_id == fragment("(log_data -> 'server')::integer"))
    render(conn, "entry.html", entry: log_entry)
  end

  def search_log_entries(conditions, {start_date, end_date}, after_id) do
    after_query = from a in LogEntry, where: a.id == ^after_id, select: %{after_id: a.id, after_timestamp: a.timestamp}
    query = from e in LogEntry,
      join: s in ServerMapping, on: s.server_id == fragment("(log_data -> 'server')::integer"),
      join: a in subquery(after_query),
      where: ^dynamic([e, s, a], e.timestamp >= ^start_date and e.timestamp <= ^end_date and e.id < a.after_id and e.timestamp <= a.after_timestamp and ^conditions)
    Repo.all(from [e, s, a] in query,
      select: %{timestamp: e.timestamp, log_data: e.log_data, id: e.id, server_name: s.server_name},
      order_by: [desc: e.timestamp, desc: e.id], limit: 50
    )
  end

  def search_log_entries(conditions, {start_date, end_date}) do
    query = from e in LogEntry,
      join: s in ServerMapping, on: s.server_id == fragment("(log_data -> 'server')::integer"),
      where: ^dynamic([e], e.timestamp >= ^start_date and e.timestamp <= ^end_date and ^conditions)
    Repo.all(from [e, s] in query,
      select: %{timestamp: e.timestamp, log_data: e.log_data, id: e.id, server_name: s.server_name},
      order_by: [desc: e.timestamp, desc: e.id], limit: 50
    )
  end

  def default_date_range() do
    end_date = NaiveDateTime.from_erl!(:calendar.local_time())
    start_date = NaiveDateTime.add(end_date, -14 * 24 * 3600)

    {start_date, end_date}
  end

  def parse_date_range(date_range) do
    IO.puts(date_range)
    [_, start_date, end_date] = Regex.run(~r/^([0-9\/:\s]+) - ([0-9\/:\s]+)$/, date_range)
    {:ok, start_timestamp} = parse_date(start_date)
    {:ok, end_timestamp} = parse_date(end_date)

    {start_timestamp, end_timestamp}
  end

  def parse_date(date) do
    [_, month, day, year, hour, minute] = Regex.run(~r/^(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+)$/, date)
    [month, day, year, hour, minute] = Enum.map([month, day, year, hour, minute], fn i ->
      {int, _} = Integer.parse(i)
      int
    end)

    NaiveDateTime.from_erl({{year, month, day}, {hour, minute, 0}})
  end
end

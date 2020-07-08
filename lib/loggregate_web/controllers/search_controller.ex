defmodule LoggregateWeb.SearchController do
  use LoggregateWeb, :controller
  alias Loggregate.{ElasticSearch, LogSearch}

  def index(conn, %{"query" => query, "date_range" => date_range, "from" => from} = _params) do
    {start_date, end_date} = parse_date_range(date_range)
    {from, _} = Integer.parse(from)

    results = ElasticSearch.get_log_entries(LogSearch.build_es_query(query, {start_date, end_date}), from)
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: query, next_page: from + 50)
  end

  def index(conn, %{"query" => query, "date_range" => date_range} = _params) do
    {start_date, end_date} = parse_date_range(date_range)
    results = ElasticSearch.get_log_entries(LogSearch.build_es_query(query, {start_date, end_date}))
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: query, next_page: 50)
  end

  def index(conn, _params) do
    {start_date, end_date} = default_date_range()
    results = ElasticSearch.get_log_entries()
    render(conn, "index.html", results: results, start_date: start_date, end_date: end_date, query: "")
  end

  def log_detail(conn, %{"log_id" => id}) do
    case ElasticSearch.get(id) do
      nil ->
        conn
        |> put_status(404)
        |> put_view(LoggregateWeb.ErrorView)
        |> render(:"404")
      entry -> render(conn, "entry.html", entry: entry)
    end
  end

  def default_date_range() do
    end_date = NaiveDateTime.from_erl!(:calendar.local_time())
    start_date = NaiveDateTime.add(end_date, -14 * 24 * 3600)

    {start_date, end_date}
  end

  def parse_date_range(date_range) do
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

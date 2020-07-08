defmodule Loggregate.ElasticSearch do
  @mapping %{
    properties: %{
      line: %{
        type: "text",
        analyzer: "simple"
      },
      server: %{type: "long"},
      timestamp: %{type: "date"},
      server_time: %{type: "date"},
      type: %{type: "keyword"},
      address: %{type: "ip"},
      port: %{type: "long"},
      message: %{
        type: "text",
        analyzer: "english",
        search_analyzer: "english"
      },
      who: %{
        properties: %{
          steamid: %{type: "keyword"},
          name: %{
            type: "text",
            analyzer: "simple"
          }
        }
      },
      cvar: %{
        properties: %{
          name: %{
            type: "text",
            analyzer: "simple"
          },
          value: %{
            type: "text",
            analyzer: "simple"
          }
        }
      }
    }
  }

  @settings %{
    settings: %{
      analysis: %{
        analyzer: %{
          default: %{
            type: "simple"
          }
        }
      }
    }
  }

  def get_url() do
    [elasticsearch_url: url] = Application.fetch_env!(:loggregate, Loggregate.ElasticSearch)
    url
  end

  def update_mapping!() do
    {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/loggregate/_mapping", Poison.encode!(@mapping))
  end

  def create_index!() do
    case Elastix.Index.get(get_url(), "loggregate") do
      {:ok, %HTTPoison.Response{status_code: 200} = _resp} -> nil
      {:ok, %HTTPoison.Response{status_code: 404} = _resp} ->
        {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/loggregate", Poison.encode!(@settings))
    end
  end

  def insert!(entries) do
    entries = Enum.flat_map(entries, &([%{index: %{_index: "loggregate"}}, &1]))
    {:ok, %HTTPoison.Response{status_code: 200} = _res} = Elastix.Bulk.post(get_url(), entries, index: "loggregate")
  end

  def get_log_entries() do
    get_log_entries(%{match_all: %{}}, 0)
  end

  def get_log_entries(conditions) do
    get_log_entries(conditions, 0)
  end

  def get_log_entries(conditions, from) do
    case Elastix.Search.search(get_url(), "loggregate", [], %{
      query: conditions,
      sort: [
        %{timestamp: "desc"}
      ],
      size: 50,
      from: from
    }) do
      {:ok, %HTTPoison.Response{status_code: 200} = res} ->
        res.body["hits"]["hits"]
      _res ->
        []
    end
  end

  def get(id) do
    case Elastix.HTTP.get("#{get_url()}/loggregate/_doc/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200} = res} ->
        res.body
      res ->
        IO.inspect(res)
    end
  end
end

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
      command: %{
        type: "text",
        analyzer: "simple"
      },
      who: %{
        properties: %{
          steamid: %{type: "keyword"},
          name: %{
            type: "text",
            analyzer: "simple"
          },
          name_kw: %{type: "keyword"},
          address: %{type: "ip"},
          port: %{type: "long"},
          location: %{type: "geo_point"}
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
      },
      from_addr: %{
        properties: %{
          address: %{type: "ip"},
          location: %{type: "geo_point"},
          port: %{type: "long"}
        }
      }
    }
  }

  @policy %{
    policy: %{
      phases: %{
        hot: %{
          actions: %{
            rollover: %{
              max_size: "15GB",
              max_age: "30d"
            }
          }
        },
        delete: %{
          min_age: "90d",
          actions: %{
            delete: %{}
          }
        }
      }
    }
  }

  @settings %{
    settings: %{
      "index.lifecycle.rollover_alias": "loggregate",
      "index.lifecycle.name": "loggregate_policy"
    },
    aliases: %{
      loggregate: %{
        is_write_index: true
      }
    }
  }

  @template %{
    index_patterns: ["loggregate-*"],
    template: %{
      settings: %{
        "index.lifecycle.rollover_alias": "loggregate",
        "index.lifecycle.name": "loggregate_policy"
      },
      mappings: @mapping
    }
  }

  def get_url() do
    [elasticsearch_url: url] = Application.fetch_env!(:loggregate, Loggregate.ElasticSearch)
    url
  end

  def update_settings!() do
    case Elastix.HTTP.get("#{get_url()}/_ilm/policy/loggregate_policy") do
      {:ok, %HTTPoison.Response{status_code: 200} = _resp} -> nil
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/_ilm/policy/loggregate_policy", Poison.encode!(@policy))
    end

    {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/_index_template/loggregate_template", Poison.encode!(@template))
  end

  def create_index!() do
    case Elastix.Index.get(get_url(), "loggregate") do
      {:ok, %HTTPoison.Response{status_code: 200} = _resp} -> nil
      {:ok, %HTTPoison.Response{status_code: 404} = _resp} ->
        {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/loggregate-000001", Poison.encode!(@settings))
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
      _res ->
        nil
    end
  end

  def get_index_count() do
    case Elastix.HTTP.get("#{get_url()}/loggregate/_count") do
      {:ok, %HTTPoison.Response{status_code: 200} = res} ->
        res.body["count"]
      _res ->
        0
    end
  end
end

defmodule Loggregate.ElasticSearch do
  @mapping %{
    properties: %{
      line: %{
        type: "text",
        analyzer: "simple"
      },
      server: %{type: "long"},
      server_name: %{type: "keyword"},
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

  defmacro settings(index) do
    quote do
      %{
        settings: %{
          "index.lifecycle.rollover_alias": "loggregate_#{unquote(index)}",
          "index.lifecycle.name": "loggregate_#{unquote(index)}_policy"
        },
        aliases: %{
          "loggregate_#{unquote(index)}": %{
            is_write_index: true
          }
        }
      }
    end
  end

  defmacro template(index) do
    quote do
      %{
        index_patterns: ["loggregate_#{unquote(index)}-*"],
        template: %{
          settings: %{
            "index.lifecycle.rollover_alias": "loggregate_#{unquote(index)}",
            "index.lifecycle.name": "loggregate_#{unquote(index)}_policy"
          },
          mappings: @mapping
        }
      }
    end
  end

  use Task
  alias Loggregate.Indices
  require Logger

  def start_link(_) do
    Task.start_link(__MODULE__, :create_indices, [])
  end

  def create_indices() do
    Indices.list_indices() |> Enum.map(fn index ->
      create_index!(index.name)
      update_settings!(index.name)
    end)
  end

  def get_url() do
    [elasticsearch_url: url] = Application.fetch_env!(:loggregate, Loggregate.ElasticSearch)
    url
  end

  def update_settings!(index) do
    case Elastix.HTTP.get("#{get_url()}/_ilm/policy/loggregate_#{index}_policy") do
      {:ok, %HTTPoison.Response{status_code: 200} = _resp} -> nil
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/_ilm/policy/loggregate_#{index}_policy", Poison.encode!(@policy))
    end

    {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/_index_template/loggregate_#{index}_template", Poison.encode!(template(index)))

    tmp = template(index)
    template = tmp.template |> Map.put_new(:index_patterns, tmp.index_patterns) |> Map.put_new(:settings, settings(index))
    {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/_template/loggregate_template", Poison.encode!(template))
  end

  def create_index!(index) do
    case Elastix.Index.get(get_url(), "loggregate_#{index}") do
      {:ok, %HTTPoison.Response{status_code: 200} = _resp} -> nil
      {:ok, %HTTPoison.Response{status_code: 404} = _resp} ->
        {:ok, %HTTPoison.Response{status_code: 200} = _resp} = Elastix.HTTP.put("#{get_url()}/loggregate_#{index}-000001", Poison.encode!(settings(index)))
    end
  end

  def insert!(entries) do
    entries = Enum.flat_map(entries, &([%{index: %{_index: &1.index}}, &1]))
    {:ok, %HTTPoison.Response{status_code: 200} = _res} = Elastix.Bulk.post(get_url(), entries)
  end

  def get_log_entries(indices, conditions, from) do
    Logger.debug("Searching indices #{Enum.join(indices, ",")} #{Poison.encode!(conditions)}")
    case Elastix.Search.search(get_url(), Enum.join(indices, ","), [], %{
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

  def get(index, id) do
    case Elastix.HTTP.get("#{get_url()}/#{index}/_doc/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200} = res} ->
        res.body
      _res ->
        nil
    end
  end

  def get_index_count(indices) do
    case Elastix.HTTP.get("#{get_url()}/#{Enum.join(indices, ",")}/_count") do
      {:ok, %HTTPoison.Response{status_code: 200} = res} ->
        res.body["count"]
      _res ->
        0
    end
  end
end

defmodule LoggregateWeb.Plugs.GetIndexSize do
  use LoggregateWeb, :controller
  alias Loggregate.ElasticSearch
  alias Loggregate.Indices

  def init(_params) do

  end

  def call(conn, _params) do
    indices = Indices.list_indices() |> Enum.map(&(&1.name))
    assign(conn, :count, ElasticSearch.get_index_count(indices))
  end
end

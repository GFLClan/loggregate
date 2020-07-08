defmodule LoggregateWeb.Plugs.GetIndexSize do
  use LoggregateWeb, :controller
  alias Loggregate.ElasticSearch

  def init(_params) do

  end

  def call(conn, _params) do
    assign(conn, :count, ElasticSearch.get_index_count())
  end
end

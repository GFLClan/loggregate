defmodule Loggregate.Repo.Migrations.IndexLogData do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION pg_trgm", "DROP EXTENSION pg_trgm"
    create index("log_entries", [:timestamp])
    create index("log_entries", ["to_tsvector('english', log_data ->> 'message')"], using: "GIN")
    create index("log_entries", ["to_tsvector('english', log_data ->> 'line')"], using: "GIN")
    create index("log_entries", ["cast(log_data -> 'server' as integer)"])
    create index("log_entries", ["(log_data -> 'type')"], using: "GIN")
    create index("log_entries", ["(log_data -> 'who' ->> 'name') gist_trgm_ops"], using: "GIST")
    create index("log_entries", ["to_tsvector('english', log_data -> 'who' ->> 'name')"], using: "GIN")
    create index("log_entries", ["(log_data -> 'who' ->> 'steamid') gist_trgm_ops"], using: "GIST")
    create index("log_entries", ["(log_data -> 'cvar' ->> 'name') gist_trgm_ops"], using: "GIST")
    create index("log_entries", ["(log_data ->> 'address') gist_trgm_ops"], using: "GIST")
  end
end

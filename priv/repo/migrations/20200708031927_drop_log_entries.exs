defmodule Loggregate.Repo.Migrations.DropLogEntries do
  use Ecto.Migration

  def change do
    drop table(:log_entries)
  end
end

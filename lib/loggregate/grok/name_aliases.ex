defmodule Loggregate.Grok.NameAliases do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grok_name_aliases" do
    field :alias, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(name_aliases, attrs) do
    name_aliases
    |> cast(attrs, [:name, :alias])
    |> validate_required([:name, :alias])
    |> unique_constraint(:name)
  end
end

defmodule Loggregate.Grok.MessagePattern do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grok_msg_patterns" do
    field :name, :string
    field :pattern, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(message_pattern, attrs) do
    message_pattern
    |> cast(attrs, [:name, :pattern, :type])
    |> validate_required([:name, :pattern, :type])
    |> unique_constraint(:name)
  end
end

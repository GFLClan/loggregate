# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Loggregate.Repo.insert!(%Loggregate.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Loggregate.{Repo, ServerMapping, Accounts, Grok}
{:ok, _} = ServerMapping.create_server_mapping(%{server_id: 1234, server_name: "test"})
{:ok, _} = Accounts.create_user(%{steamid: "76561197984674419", name: "Dreae", admin: true})
